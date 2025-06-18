--En este script se realiza la creación de los Store Procedure para importar archivos

--Fecha de entrega: 17/06/2025
--Comisión: 2900
--Grupo: 6
--Base de datos Aplicada
--Integrantes:
--Fariello Ramiro - DNI: 46124109
--Rojas Taiel Ezequiel - DNI: 46183434
--Cropalati Franco Nicolas - DNI: 43404823
--Miguez Alejo - DNI: 41667306

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

EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'AllowInProcess', 1;
    
EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'DynamicParameters', 1;
*/

--Importar tarifas de actividades y crear las actividades si no están

CREATE OR ALTER PROCEDURE importaciones.Import_Actividades
	@rutaArch NVARCHAR(255)
AS
BEGIN
	
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

	INSERT INTO tesoreria.Tarifa_Actividad(Importe_Por_Mes, Vigente_Hasta)
	SELECT DISTINCT Importe, Vigente_Hasta
	FROM #TempImport_Actividad tmp
	WHERE NOT EXISTS (
		SELECT 1
		FROM tesoreria.Tarifa_Actividad t
		WHERE t.Importe_Por_Mes = tmp.Importe
		  AND t.Vigente_Hasta = tmp.Vigente_Hasta
		  AND tmp.Importe >= 0
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


	DROP TABLE #TempImport_Actividad;
END
GO

--Importar tarifas de pileta
CREATE OR ALTER PROCEDURE importaciones.Import_Tarifas_Pileta
	@rutaArch NVARCHAR(255)
AS
BEGIN
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

	DROP TABLE #TempImport_Tarifa_Pileta;
END
GO

--Importar tarifas de cuotas y crea las categorias de socios

CREATE OR ALTER PROCEDURE importaciones.Import_Tarifas_Cuotas
	@rutaArch NVARCHAR(255)
AS
BEGIN
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
END
GO

-- Importar asistencias a clases

CREATE OR ALTER PROCEDURE importaciones.Import_Asistencias
	@rutaArch NVARCHAR(255)
AS
BEGIN
	-- Crear tabla temporal para importar los datos del archivo Excel.
	-- This temporary table will hold the raw data from the Excel file.
	CREATE TABLE #TempImport_Asiste (
		ID INT IDENTITY(1,1) PRIMARY KEY,
		Descripcion VARCHAR(50),
		Fecha DATE NOT NULL,
		Asiste CHAR(1) NOT NULL, -- Changed to CHAR(1) for consistency with LEFT(..., 1)
		ID_Socio CHAR(8) NOT NULL,
		Profesor VARCHAR(50) NOT NULL
	);
	
	-- Import data from the Excel file into the temporary table.
	-- OPENROWSET is used to read data from the Excel spreadsheet.
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
		DATENAME(weekday, tmp.Fecha) AS Dia_De_La_Semana
	FROM #TempImport_Asiste tmp
	WHERE CHARINDEX(' ', tmp.Profesor) > 0;

	EXEC club.sp_DesencriptarEmpleado @password = 'EkAHYL]cv92=#Z!1EuDH';

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
	EXEC club.sp_DesencriptarEmpleado @password = 'EkAHYL]cv92=#Z!1EuDH';

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
	EXEC club.sp_EncriptarEmpleado @password = 'EkAHYL]cv92=#Z!1EuDH';

END
GO


CREATE OR ALTER PROCEDURE importaciones.ImportarSociosDesdeExcel
    @RutaExcel NVARCHAR(260)
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

    SELECT * FROM #SociosExcel;

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
	),
	DatosInvalidos AS (
		SELECT DNI
		FROM #SociosExcel
		WHERE fecha IS NULL
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
			WHEN DATEDIFF(YEAR, fecha, GETDATE()) <= 12 THEN 1
			WHEN DATEDIFF(YEAR, fecha, GETDATE()) <= 17 THEN 2
			ELSE 3
		END
	FROM DatosValidos;

	-- Se pueden almacenar los errores en una tabla específica para esto
	/*INSERT INTO importaciones.Errores_Importacion_Socios (DNI, Motivo)
	SELECT DNI, 'Fecha de nacimiento inválida (NULL luego de conversión)' FROM #SociosExcel
	WHERE fecha IS NULL;*/

    DROP TABLE #SociosExcel;
END;