--En este script se realiza la creación de los Store Procedure para importar archivos

--Fecha de entrega: 24/06/2025
--Comisión: 2900
--Grupo: 6
--Base de datos Aplicada
--Integrantes:
--Fariello Ramiro - DNI: 46124109
--Rojas Taiel Ezequiel - DNI: 46183434
--Cropalati Franco Nicolas - DNI: 43404823

--Importar tarifas y actividades
 
USE Com2900G06
GO

/* Necesario para que funcione pero solo hace falta ejecutar una vez:
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO
*/

--Importar tarifas de actividades y crear las actividades si no están

CREATE OR ALTER PROCEDURE importaciones.Import_Actividades
	@rutaArch VARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempImport_Actividad(
    ID INT IDENTITY(1,1) Primary Key,
    Actividad VARCHAR(50) NOT NULL,
    Importe NUMERIC(10,2) NOT NULL,
	Vigente_Hasta DATE NOT NULL
	);
	
	EXEC('INSERT INTO #TempImport_Actividad (Actividad, Importe, Vigente_Hasta)' +
		'SELECT LTRIM(RTRIM([Actividad])),
		[Valor por mes],
		[Vigente hasta]' +
		'FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'','+
		'''Excel 12.0;Database='+@rutaArch+';HDR=YES'','+
		'''SELECT * FROM [Tarifas$B2:D8]'');
	');

	UPDATE #TempImport_Actividad
	SET Actividad = 'Ajedrez'
	WHERE LTRIM(RTRIM(Actividad)) COLLATE Latin1_General_CI_AI = 'Ajederez';
	
	IF EXISTS (
        SELECT 1
        FROM #TempImport_Actividad
        WHERE Actividad IS NULL OR Importe IS NULL OR Vigente_Hasta IS NULL
    )
        PRINT 'Algunos registros tienen campos nulos (Actividad, Importe o Vigente_Hasta).';

    -- Importes negativos
    IF EXISTS (
        SELECT 1
        FROM #TempImport_Actividad
        WHERE Importe < 0
    )
        PRINT 'Algunos registros tienen importes negativos.';

    -- Tarifas ya existentes
    IF EXISTS (
        SELECT 1
        FROM #TempImport_Actividad tmp
        WHERE Importe IS NOT NULL AND Vigente_Hasta IS NOT NULL
        AND EXISTS (
            SELECT 1
            FROM tesoreria.Tarifa_Actividad t
            WHERE t.Importe_Por_Mes = tmp.Importe
              AND t.Vigente_Hasta = tmp.Vigente_Hasta
        )
    )
        PRINT 'Algunas tarifas ya existen en la base de datos.';

    -- Inserción de las tarifas válidas
    INSERT INTO tesoreria.Tarifa_Actividad (Importe_Por_Mes, Vigente_Hasta)
    SELECT DISTINCT tmp.Importe, tmp.Vigente_Hasta
    FROM #TempImport_Actividad tmp
    WHERE tmp.Actividad IS NOT NULL
      AND tmp.Importe IS NOT NULL AND tmp.Importe >= 0
      AND tmp.Vigente_Hasta IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM tesoreria.Tarifa_Actividad t
          WHERE t.Importe_Por_Mes = tmp.Importe
            AND t.Vigente_Hasta = tmp.Vigente_Hasta
      );

	INSERT INTO actividades.Actividad (Descripcion, ID_Tarifa)
	SELECT tmp.Actividad, t.ID
	FROM #TempImport_Actividad tmp
	JOIN
	tesoreria.Tarifa_Actividad t
	on t.Importe_Por_Mes = tmp.Importe
	AND t.Vigente_Hasta =tmp.Vigente_Hasta
	WHERE NOT EXISTS (
		SELECT 1
		FROM actividades.Actividad a
		WHERE a.Descripcion = tmp.Actividad
		  AND a.ID_Tarifa = t.ID
	);

	Print('Actividades importadas')

	DROP TABLE #TempImport_Actividad;
END
GO

--Importar tarifas de pileta
CREATE OR ALTER PROCEDURE importaciones.Import_Tarifas_Pileta
	@rutaArch VARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #TempImport_Tarifa_Pileta(
    ID INT IDENTITY(1,1) Primary Key,
    Descripcion VARCHAR(50),
	Rango_Edad VARCHAR(50),
    Valor_Socios NUMERIC(10,2) NOT NULL,
	Valor_Invitados NUMERIC(10,2),
	Vigente_Hasta DATE NOT NULL
	);
	
	EXEC('INSERT INTO #TempImport_Tarifa_Pileta (Descripcion, Rango_Edad, Valor_Socios, Valor_Invitados, Vigente_Hasta)' +
		'SELECT F1 as Descripcion, F2 as Rango_Edad, F3 as Valor_Socios, F4 as Valor_Invitados, F5 as Vigente_Hasta ' +
		'FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'','+
		'''Excel 12.0;Database='+@rutaArch+';HDR=NO'','+
		'''SELECT * FROM [Tarifas$B17:F22]'');
	');
	
	UPDATE #TempImport_Tarifa_Pileta
	SET Descripcion = b.DescripcionAnterior
	FROM #TempImport_Tarifa_Pileta tmp
	JOIN (
		SELECT ID, Descripcion, LAG(Descripcion) OVER (ORDER BY ID) AS DescripcionAnterior
		FROM #TempImport_Tarifa_Pileta
	) b on tmp.ID = b.ID
	WHERE tmp.Descripcion IS NULL;

	INSERT INTO tesoreria.Tarifa_Pileta (Descripcion, Importe, Vigente_Hasta)
	SELECT 
		Descripcion + ' ' + Rango_Edad + ' Socio' AS Descripcion,
		Valor_Socios,
		Vigente_Hasta
	FROM #TempImport_Tarifa_Pileta
	WHERE Valor_Socios IS NOT NULL

	UNION ALL

	SELECT 
		Descripcion + ' ' + Rango_Edad + ' Invitado' AS Descripcion,
		Valor_Invitados,
		Vigente_Hasta
	FROM #TempImport_Tarifa_Pileta
	WHERE Valor_Invitados IS NOT NULL;

	Print('Tarifas de pileta importadas')

	DROP TABLE #TempImport_Tarifa_Pileta;
END
GO

--Importar tarifas de cuotas y crea las categorias de socios

CREATE OR ALTER PROCEDURE importaciones.Import_Tarifas_Cuotas
	@rutaArch VARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempImport_Tarifa_Cuota(
    ID INT IDENTITY(1,1) Primary Key,
    Descripcion VARCHAR(50),
    Valor NUMERIC(10,2) NOT NULL,
	Vigente_Hasta DATE NOT NULL
	);
	
	EXEC('INSERT INTO #TempImport_Tarifa_Cuota (Descripcion, Valor, Vigente_Hasta)' +
		'SELECT LTRIM(RTRIM([Categoria socio])),
		[Valor cuota],
		[Vigente hasta]' +
		'FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'','+
		'''Excel 12.0;Database='+@rutaArch+';HDR=YES'','+
		'''SELECT * FROM [Tarifas$B10:D13]'');
	');

	INSERT INTO tesoreria.Tarifa_Categoria (Importe, Vigente_Hasta)
	SELECT tmp.Valor, tmp.Vigente_Hasta
	FROM #TempImport_Tarifa_Cuota tmp
	WHERE NOT EXISTS (
		SELECT 1
		FROM tesoreria.Tarifa_Categoria tc
		WHERE
		tc.Importe = tmp.Valor
		AND
		tc.Vigente_Hasta = tmp.Vigente_Hasta
	);

	INSERT INTO socios.Categoria_Socio (Nombre, ID_Tarifa_Categoria)
	SELECT tmp.Descripcion, tc.ID
	FROM #TempImport_Tarifa_Cuota tmp
	JOIN tesoreria.Tarifa_Categoria tc
	ON
	tc.Importe = tmp.Valor
	AND
	tc.Vigente_Hasta = tmp.Vigente_Hasta
	WHERE NOT EXISTS (
		SELECT 1
		FROM socios.Categoria_Socio cs
		WHERE
		cs.Nombre = tmp.Descripcion
		);

	DROP TABLE #TempImport_Tarifa_Cuota;

	Print('Categorías y tarifas de socios importadas')

END
GO

-- Importar asistencias a clases

CREATE OR ALTER PROCEDURE importaciones.Import_Asistencias
	@rutaArch VARCHAR(255),
	@password VARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempImport_Asiste (
		ID INT IDENTITY(1,1) PRIMARY KEY,
		Descripcion VARCHAR(50),
		Fecha DATE NOT NULL,
		Asiste CHAR(1) NOT NULL,
		ID_Socio CHAR(8) NOT NULL,
		Profesor VARCHAR(50) NOT NULL
	);
	
	EXEC('INSERT INTO #TempImport_Asiste (Descripcion, Fecha, Asiste, ID_Socio, Profesor)' +
		' SELECT
		LTRIM(RTRIM([Actividad])),
		[fecha de asistencia],
		LEFT(LTRIM(RTRIM([Asistencia])), 1) AS Asiste, 
		LTRIM(RTRIM([Nro de Socio])),
		LTRIM(RTRIM([Profesor]))' +
		' FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'','+
		'''Excel 12.0;Database='+@rutaArch+';HDR=YES'','+
		'''SELECT * FROM [presentismo_actividades$]'');
	');

	CREATE TABLE #Datos_Procesados (
		ID INT PRIMARY KEY,
		Actividad_Descripcion VARCHAR(50),
		Fecha DATE NOT NULL,
		Asiste CHAR(1) NOT NULL,
		ID_Socio CHAR(8) NOT NULL,
		Nombre_Completo VARCHAR(50),
		Profesor_Nombre VARCHAR(50),
		Profesor_Apellido VARCHAR(50),
		Dia_De_La_Semana VARCHAR(20)
	);

	INSERT INTO #Datos_Procesados (
		ID, Actividad_Descripcion, Fecha, Asiste, ID_Socio, Nombre_Completo, 
		Profesor_Nombre, Profesor_Apellido, Dia_De_La_Semana
	)
	SELECT
		tmp.ID,
		tmp.Descripcion AS Actividad_Descripcion,
		tmp.Fecha,
		tmp.Asiste,
		tmp.ID_Socio,
		tmp.Profesor AS Nombre_Completo,
		LTRIM(RTRIM(LEFT(tmp.Profesor, LEN(tmp.Profesor) - CHARINDEX(' ', REVERSE(tmp.Profesor))))) AS Profesor_Nombre,
		LTRIM(RTRIM(RIGHT(tmp.Profesor, CHARINDEX(' ', REVERSE(tmp.Profesor)) - 1))) AS Profesor_Apellido,
		CASE DATENAME(weekday, tmp.Fecha)
			WHEN 'Monday' THEN 'Lunes'
			WHEN 'Tuesday' THEN 'Martes'
			WHEN 'Wednesday' THEN 'Miércoles'
			WHEN 'Thursday' THEN 'Jueves'
			WHEN 'Friday' THEN 'Viernes'
			WHEN 'Saturday' THEN 'Sábado'
			WHEN 'Sunday' THEN 'Domingo'
			ELSE 'Desconocido'
		END AS Dia_De_La_Semana
	FROM #TempImport_Asiste tmp
	WHERE CHARINDEX(' ', tmp.Profesor) > 0;

	EXEC club.sp_DesencriptarEmpleado @password;

	INSERT INTO club.Empleado(Nombre, Apellido, Area)
	SELECT DISTINCT
		pd.Profesor_Nombre,
		pd.Profesor_Apellido,
		'Profesor' AS Area
	FROM #Datos_Procesados pd
	WHERE NOT EXISTS (
		SELECT 1
		FROM club.Empleado e
		WHERE LTRIM(RTRIM(e.Nombre)) = pd.Profesor_Nombre
		  AND LTRIM(RTRIM(e.Apellido)) = pd.Profesor_Apellido
	);
	EXEC club.sp_DesencriptarEmpleado @password;

	INSERT INTO actividades.Clase(Día_De_La_Semana, ID_Profesor, ID_Actividad)
	SELECT DISTINCT
		pd.Dia_De_La_Semana,
		ce.ID AS ID_Profesor,
		aa.ID AS ID_Actividad
	FROM #Datos_Procesados pd
	JOIN club.Empleado ce 
		ON LTRIM(RTRIM(ce.Nombre)) = pd.Profesor_Nombre 
		AND LTRIM(RTRIM(ce.Apellido)) = pd.Profesor_Apellido
	JOIN actividades.Actividad aa ON aa.Descripcion = pd.Actividad_Descripcion
	WHERE NOT EXISTS (
		SELECT 1
		FROM actividades.Clase c
		WHERE c.Día_De_La_Semana = pd.Dia_De_La_Semana
		  AND c.ID_Profesor = ce.ID
		  AND c.ID_Actividad = aa.ID
	);

	INSERT INTO actividades.Socio_Asiste_Clase (Fecha, Asiste, ID_Socio, ID_Clase)
	SELECT
		pd.Fecha,
		pd.Asiste,
		ss.ID AS ID_Socio,
		ac.ID AS ID_Clase
	FROM #Datos_Procesados pd
	JOIN actividades.Actividad aa ON aa.Descripcion = pd.Actividad_Descripcion
	JOIN club.Empleado ce 
		ON LTRIM(RTRIM(ce.Nombre)) = pd.Profesor_Nombre 
		AND LTRIM(RTRIM(ce.Apellido)) = pd.Profesor_Apellido
	JOIN actividades.Clase ac
		ON ac.Día_De_La_Semana = pd.Dia_De_La_Semana
		AND ac.ID_Profesor = ce.ID
		AND ac.ID_Actividad = aa.ID
	JOIN socios.Socio ss ON pd.ID_Socio = ss.Nro_Socio
	WHERE NOT EXISTS (
		SELECT 1
		FROM actividades.Socio_Asiste_Clase sac
		WHERE sac.Fecha = pd.Fecha
		  AND sac.ID_Socio = ss.ID
		  AND sac.ID_Clase = ac.ID
	);
	
	DROP TABLE #TempImport_Asiste;
	DROP TABLE #Datos_Procesados;
	EXEC club.sp_EncriptarEmpleado @password;

	Print('Asistencias importadas')

END
GO

CREATE OR ALTER PROCEDURE importaciones.Importar_Socios_Desde_Excel
    @RutaExcel VARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('#SociosExcel') IS NOT NULL
        DROP TABLE #SociosExcel;

    CREATE TABLE #SociosExcel (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        nro CHAR(8),
        nombre VARCHAR(50),
        apellido VARCHAR(50),
        DNI CHAR(9),
        email VARCHAR(150),
        fecha DATE,
        telefono_contacto VARCHAR(50),
        telefono_contacto_emergencia VARCHAR(50),
        nombre_OS VARCHAR(50),
        nro_OS VARCHAR(50),
        telefono_contacto_emergencia_OS VARCHAR(50)
    );

	WITH nuevos_estados (estado) AS (
		SELECT 'ACTIVO' UNION ALL
		SELECT 'MOROSO' UNION ALL
		SELECT 'INACTIVO'
	)
	-- Insertar solo si no existe en la tabla
	INSERT INTO socios.Estado_Socio (Descripcion)
	SELECT ne.estado
	FROM nuevos_estados ne
	WHERE NOT EXISTS (
		SELECT 1
		FROM socios.Estado_Socio es
		WHERE es.Descripcion = ne.estado
	);

    DECLARE @sql NVARCHAR(MAX) = '
    INSERT INTO #SociosExcel (
        nro, nombre, apellido, DNI, email, fecha,
        telefono_contacto, telefono_contacto_emergencia,
        nombre_OS, nro_OS, telefono_contacto_emergencia_OS
    )
    SELECT
        Ltrim(rtrim(F1)),
        Ltrim(rtrim(F2)),
        Ltrim(rtrim(F3)),
		LTRIM(RTRIM(LEFT(CAST(CONVERT(BIGINT, F4) AS VARCHAR), 8))),
        Ltrim(rtrim(F5)),
        Ltrim(rtrim(F6)),
		LTRIM(RTRIM(CAST(CONVERT(BIGINT, F7) AS VARCHAR))),
		LTRIM(RTRIM(CAST(CONVERT(BIGINT, F8) AS VARCHAR))),
        Ltrim(rtrim(F9)),
        Ltrim(rtrim(F10)),
        Ltrim(rtrim(F11))
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.16.0'',
        ''Excel 12.0;Database=' + @RutaExcel + ';HDR=NO'',
        ''SELECT * FROM [Responsables de Pago$A2:K]''
    );
    ';

    EXEC sp_executesql @sql;

	--DATOS VALIDOS
	WITH DatosValidos AS (
		SELECT *
		FROM #SociosExcel s
		WHERE 
			fecha IS NOT NULL
			AND NOT EXISTS (
				SELECT 1 FROM socios.Socio so WHERE so.DNI = s.DNI
			)
			AND NOT EXISTS (
				SELECT 1 FROM socios.Socio so WHERE so.Numero_De_Socio_OS = s.nro_OS
			)
			AND NOT EXISTS (
				SELECT 1 FROM #SociosExcel s2 WHERE s2.DNI = s.DNI AND s2.ID < s.ID
			)
			AND NOT EXISTS (
				SELECT 1 FROM #SociosExcel s2 WHERE s2.nro_OS = s.nro_OS AND s2.ID < s.ID
		)
	)
	-- Insertar los válidos
	INSERT INTO socios.Socio (
		Nro_Socio,
		DNI,
		Fecha_Nacimiento,
		Apellido,
		Nombre,
		Numero_De_Socio_OS,
		Telefono_De_Emergencias_OS,
		Telefono_Contacto_Emergencia,
		Nombre_Obra_Social,
		Telefono_Contacto,
		ID_Estado_Socio,
		ID_Grupo_Familiar,
		ID_Categoria_Socio
	)
	SELECT
		LEFT(nro, 7),
		DNI,
		fecha,
		UPPER(apellido),
		UPPER(nombre),
		nro_OS,
		telefono_contacto_emergencia_OS,
		telefono_contacto_emergencia,
		nombre_OS,
		telefono_contacto,
		1,
		NULL,
		CASE 
			WHEN DATEDIFF(YEAR, fecha, GETDATE()) <= 12 THEN 3
			WHEN DATEDIFF(YEAR, fecha, GETDATE()) <= 17 THEN 2
			ELSE 1
		END
	FROM DatosValidos;

	--DATOS INVALIDOS
	CREATE TABLE #Errores (
		DNI CHAR(9),
		Nro_Socio CHAR(8),
		Numero_De_Socio_OS VARCHAR(50),
		Motivo VARCHAR(255)
	);

	INSERT INTO #Errores (DNI, Nro_Socio, Numero_De_Socio_OS, Motivo)
	SELECT DISTINCT DNI, nro, nro_OS, 'Fecha de nacimiento inválida (NULL luego de conversión)'
	FROM #SociosExcel
	WHERE fecha IS NULL;

	INSERT INTO #Errores (DNI, Nro_Socio, Numero_De_Socio_OS, Motivo)
	SELECT DISTINCT s.DNI, nro, s.nro_OS, 'DNI duplicado en el Excel. Se inserta solo primer encuentro'
	FROM #SociosExcel s
	JOIN (
		SELECT DNI
		FROM #SociosExcel
		GROUP BY DNI
		HAVING COUNT(*) > 1
	) d ON s.DNI = d.DNI;

	INSERT INTO #Errores (DNI, Nro_Socio, Numero_De_Socio_OS, Motivo)
	SELECT DISTINCT s.DNI,nro, s.nro_OS, 'Número de socio OS duplicado en el Excel. Se inserta solo primer encuentro'
	FROM #SociosExcel s
	JOIN (
		SELECT nro_OS
		FROM #SociosExcel
		GROUP BY nro_OS
		HAVING COUNT(*) > 1
	) d ON s.nro_OS = d.nro_OS;

	--Ingresar los inválidos
	INSERT INTO importaciones.Errores_Importacion_Socios (DNI,Nro_Socio, Numero_De_Socio_OS, Motivo)
	SELECT DISTINCT DNI, Nro_Socio, Numero_De_Socio_OS, Motivo
	FROM #Errores;

	DROP TABLE #Errores;
    DROP TABLE #SociosExcel;

	Print('Socios responsables de pago importados')

END;
GO

CREATE OR ALTER PROCEDURE importaciones.Importar_Grupo_Familiar
    @RutaExcel VARCHAR(260)
AS
BEGIN
	SET NOCOUNT ON;

    IF OBJECT_ID('#GrupoFamiliarExcel') IS NOT NULL
        DROP TABLE #GrupoFamiliarExcel;

    CREATE TABLE #GrupoFamiliarExcel (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        nro CHAR(8),
		nro_RP CHAR(8),
        nombre VARCHAR(50),
        apellido VARCHAR(50),
        DNI CHAR(9),
        email VARCHAR(150),
        fecha DATE,
        telefono_contacto VARCHAR(50),
        telefono_contacto_emergencia VARCHAR(50),
        nombre_OS VARCHAR(50),
        nro_OS VARCHAR(50),
        telefono_contacto_emergencia_OS VARCHAR(50)
    );

	DECLARE @sql NVARCHAR(MAX) = '
    INSERT INTO #GrupoFamiliarExcel (
        nro, nro_RP, nombre, apellido, DNI, email, fecha,
        telefono_contacto, telefono_contacto_emergencia,
        nombre_OS, nro_OS, telefono_contacto_emergencia_OS
    )
    SELECT
        Ltrim(rtrim(F1)),
		Ltrim(rtrim(F2)),
        Ltrim(rtrim(F3)),
        Ltrim(rtrim(F4)),
		LTRIM(RTRIM(LEFT(CAST(CONVERT(BIGINT, F5) AS VARCHAR), 8))),
        Ltrim(rtrim(F6)),
        Ltrim(rtrim(F7)),
		LTRIM(RTRIM(CAST(CONVERT(BIGINT, F8) AS VARCHAR))),
		LTRIM(RTRIM(CAST(CONVERT(BIGINT, F9) AS VARCHAR))),
        Ltrim(rtrim(F10)),
        Ltrim(rtrim(F11)),
        Ltrim(rtrim(F12))
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.16.0'',
        ''Excel 12.0;Database=' + @RutaExcel + ';HDR=NO'',
        ''SELECT * FROM [Grupo familiar$A2:L]''
    );
    ';

    EXEC sp_executesql @sql;

	INSERT INTO socios.Grupo_Familiar (ID_Socio_Responsable)
	SELECT DISTINCT s.ID FROM socios.Socio s, #GrupoFamiliarExcel gf 
	WHERE s.Nro_Socio = gf.nro_RP;

	INSERT INTO socios.Socio (
    Nro_Socio,
    DNI,
    Fecha_Nacimiento,
    Apellido,
    Nombre,
    Numero_De_Socio_OS,
    Telefono_De_Emergencias_OS,
    Telefono_Contacto_Emergencia,
    Nombre_Obra_Social,
    Telefono_Contacto,
    ID_Estado_Socio,
    ID_Grupo_Familiar,
    ID_Categoria_Socio
	)
	SELECT
		LEFT(gf.nro, 7),
		gf.DNI,
		gf.fecha,
		UPPER(gf.apellido),
		UPPER(gf.nombre),
		gf.nro_OS,
		gf.telefono_contacto_emergencia_OS,
		gf.telefono_contacto_emergencia,
		gf.nombre_OS,
		gf.telefono_contacto,
		1,
		NULL,
		CASE 
			WHEN DATEDIFF(YEAR, gf.fecha, GETDATE()) <= 12 THEN 3
			WHEN DATEDIFF(YEAR, gf.fecha, GETDATE()) <= 17 THEN 2
			ELSE 1
		END
	FROM #GrupoFamiliarExcel gf
	WHERE NOT EXISTS (
		SELECT 1 FROM socios.Socio s WHERE s.Nro_Socio = LEFT(gf.nro, 7)
	);


	UPDATE s
	SET s.ID_Grupo_Familiar = gf.ID
	FROM socios.Socio s
	JOIN #GrupoFamiliarExcel g ON s.Nro_Socio = g.nro
	JOIN socios.Socio responsable ON responsable.Nro_Socio = g.nro_RP
	JOIN socios.Grupo_Familiar gf ON gf.ID_Socio_Responsable = responsable.ID;

	DROP TABLE #GrupoFamiliarExcel;

	Print('Socios y grupos familiares importados')

END;
GO

CREATE OR ALTER PROCEDURE importaciones.ImportarPagoCuotasDesdeExcel
    @RutaExcel VARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#PagosExcel') IS NOT NULL
        DROP TABLE #PagosExcel;

    CREATE TABLE #PagosExcel (
        ID_PagoExcel VARCHAR(20),
        Fecha_Pago DATE,
        Nro_Socio CHAR(7),
        Importe DECIMAL(10,2),
        Medio_Pago VARCHAR(50)
    );

    DECLARE @sql NVARCHAR(MAX) = '
    INSERT INTO #PagosExcel (ID_PagoExcel, Fecha_Pago, Nro_Socio, Importe, Medio_Pago)
    SELECT
        LTRIM(RTRIM(CAST(CONVERT(BIGINT, F1) AS VARCHAR))),
        TRY_CAST(F2 AS DATE),
        LTRIM(RTRIM(F3)),
        TRY_CAST(F4 AS DECIMAL(10,2)),
        CASE
			WHEN LTRIM(RTRIM(F5)) = ''efectivo'' THEN ''SUCURSAL DE PAGO''
			ELSE LTRIM(RTRIM(F5))
		END
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.16.0'',
        ''Excel 12.0;HDR=NO;Database=' + @RutaExcel + ''',
        ''SELECT * FROM [pago cuotas$A2:E]''
    );';

    EXEC sp_executesql @sql;

    IF OBJECT_ID('tempdb..#DatosPago') IS NOT NULL
        DROP TABLE #DatosPago;

    SELECT 
		ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID_Interno,
		pe.ID_PagoExcel,
		pe.Fecha_Pago,
		NULL AS Hora_Pago,
		pe.Nro_Socio,
		pe.Importe,
		mp.ID AS ID_Medio_Pago
	INTO #DatosPago
	FROM #PagosExcel pe
	INNER JOIN tesoreria.Medio_Pago mp 
		ON LTRIM(RTRIM(UPPER(mp.Descripcion))) = LTRIM(RTRIM(UPPER(pe.Medio_Pago)));

    IF OBJECT_ID('tempdb..#PagosInsertados') IS NOT NULL
        DROP TABLE #PagosInsertados;

    CREATE TABLE #PagosInsertados (
        ID_Pago INT,
        ID_Interno INT,
		ID_Pago_OG BIGINT,
        Nro_Socio CHAR(7),
        Fecha_Pago DATE,
        Importe DECIMAL(10,2)
    );

   MERGE INTO tesoreria.Pago AS t
   USING (
		SELECT 
			ID_Interno,
			ID_PagoExcel,
			Fecha_Pago,
			Hora_Pago,
			src.Nro_Socio,
			Importe,
			ID_Medio_Pago
		FROM #DatosPago src
		INNER JOIN socios.Socio s ON src.Nro_Socio = s.Nro_Socio
	) AS src
	ON 1 = 0
	WHEN NOT MATCHED THEN
		INSERT (ID_Pago, Fecha_Pago, Hora_Pago, Medio_Pago)
		VALUES (src.ID_PagoExcel, src.Fecha_Pago, NULL, src.ID_Medio_Pago)
	OUTPUT 
		INSERTED.ID AS ID_Pago,
		src.ID_Interno,
		src.ID_PagoExcel,
		src.Nro_Socio,
		src.Fecha_Pago,
		src.Importe
	INTO #PagosInsertados (ID_Pago, ID_Interno, ID_Pago_OG, Nro_Socio, Fecha_Pago, Importe);

    IF OBJECT_ID('tempdb..#FacturasInsertadas') IS NOT NULL
        DROP TABLE #FacturasInsertadas;

    CREATE TABLE #FacturasInsertadas (
        ID_Factura INT,
        ID_Pago INT,
        Nro_Socio CHAR(7)
    );

    MERGE INTO tesoreria.Factura AS target
	USING (
		SELECT
			dp.Fecha_Pago,
			dp.Importe,
			pi.ID_Pago,
			dp.Nro_Socio
		FROM #DatosPago dp
		JOIN #PagosInsertados pi ON pi.ID_Pago_OG = dp.ID_PagoExcel
	) AS src
	ON 1 = 0
	WHEN NOT MATCHED THEN
		INSERT (
			PDV, Numero, Fecha_Emision, Hora_Emision, Importe,
			Fecha_Primer_Vencimiento, Fecha_Segundo_Vencimiento,
			ID_Recargo, ID_Estado, ID_Pago
		)
		VALUES (
			1, 1, src.Fecha_Pago, NULL, src.Importe,
			DATEADD(DAY, 5, src.Fecha_Pago), DATEADD(DAY, 10, src.Fecha_Pago),
			NULL, 1, src.ID_Pago
		)
	OUTPUT
		INSERTED.ID, INSERTED.ID_Pago, src.Nro_Socio
	INTO #FacturasInsertadas (ID_Factura, ID_Pago, Nro_Socio);

    INSERT INTO tesoreria.Cuota (
        Fecha_Inicio, Fecha_Final, Mes, ID_Socio, ID_Factura
    )
    SELECT
        DATEFROMPARTS(YEAR(f.Fecha_Emision), MONTH(f.Fecha_Emision), 1),
        EOMONTH(f.Fecha_Emision),
        MONTH(f.Fecha_Emision),
        s.ID,
        f.ID
    FROM #FacturasInsertadas fi, tesoreria.Factura f, socios.Socio s
	WHERE s.Nro_Socio = fi.Nro_Socio AND fi.ID_Factura = f.ID

    DROP TABLE #PagosExcel;
    DROP TABLE #DatosPago;
    DROP TABLE #PagosInsertados;
    DROP TABLE #FacturasInsertadas;

    PRINT 'Importación de pagos, facturas y asignación de cuotas completada.';
END;
GO

CREATE or ALTER PROCEDURE importaciones.Importar_Lluvia
    @RutaArch1 VARCHAR(260), @RutaArch2 VARCHAR(260)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..##TempImport_lluvia') IS NULL
	BEGIN
		CREATE TABLE ##TempImport_lluvia (
		Tiempo CHAR(16) NOT NULL,
		Temperatura Numeric (3,1),
		Lluvia Numeric (4,2),
		Humedad Numeric (5,2),
		Viento Numeric (4,1)
		);
	END

	EXEC('
	BULK INSERT ##TempImport_lluvia
	FROM ''' + @RutaArch1 + '''
	WITH (
		DATAFILETYPE = ''char'',
		FIRSTROW = 5,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''0x0a'',
		CODEPAGE = ''65001'',
		TABLOCK
	);');

	EXEC('
	BULK INSERT ##TempImport_lluvia
	FROM ''' + @RutaArch2 + '''
	WITH (
		DATAFILETYPE = ''char'',
		FIRSTROW = 5,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''0x0a'',
		CODEPAGE = ''65001'',
		TABLOCK
	);');


	WITH Duplicados AS (
		SELECT *,
			   ROW_NUMBER() OVER (
				   PARTITION BY Tiempo, Lluvia
				   ORDER BY Tiempo, Lluvia
			   ) AS rn
		FROM ##TempImport_lluvia
	)
	DELETE FROM Duplicados WHERE rn > 1 OR Duplicados.Lluvia = 0;
	
	Print('Lluvias del 2024 y 2025 importadas')

END
GO
