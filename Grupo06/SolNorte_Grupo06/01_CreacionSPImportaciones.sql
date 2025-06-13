--En este script se realiza la creación de los Store Procedure para importar archivos

--Fecha de entrega: 19/06/2025
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
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'AllowInProcess', 1;
    
EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'DynamicParameters', 1;
*/

--Importar tarifas de actividades

CREATE OR ALTER PROCEDURE importaciones.Import_Actividades
	@rutaArch NVARCHAR(255)
AS
BEGIN
	
	CREATE TABLE #TempImport_Actividad(
    ID INT IDENTITY(1,1) Primary Key,
    Actividad VARCHAR(50) NOT NULL,
    Importe INT NOT NULL,
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
		WHERE
		(a.Descripcion = '' OR a.Descripcion IS NULL)
		OR
		(a.Descripcion = tmp.Actividad
		AND a.ID_Tarifa = t.ID)
	);

	DROP TABLE #TempImport_Actividad;
END
GO

-- Importar asistencias a clases
/* POR TERMINAR
CREATE OR ALTER PROCEDURE importaciones.Import_Asistencias
	@rutaArch NVARCHAR(255)
AS
BEGIN

	Create table #TempImport_Asiste (
		ID INT Identity(1,1) Primary Key,
		Descripcion VARCHAR(50),
		Fecha DATE NOT NULL,
		Asiste CHAR NOT NULL,
		ID_Socio CHAR(8) NOT NULL,
		Profesor VARCHAR(50) NOT NULL
	);
	
	EXEC('INSERT INTO #TempImport_Asiste (Descripcion, Fecha, Asiste, ID_Socio, Profesor)' +
		'SELECT
		LTRIM(RTRIM([Actividad])),
		[fecha de asistencia],
		LEFT(LTRIM(RTRIM([Asistencia])), 1) AS Asiste, 
		[Nro de Socio],
		LTRIM(RTRIM([Profesor]))' +
		'FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'','+
		'''Excel 12.0;Database='+@rutaArch+';HDR=YES'','+
		'''SELECT * FROM [presentismo_actividades$]'');
	');



	--El campo ASISTE presentaba espacios en blanco y caracteres duplicados, con LTRIM y RTRIM eliminamos los espacios en blanco y con LEFT nos quedamos con 1 caracter
	
	SELECT TOP 100 * FROM #TempImport_Asiste

	
	INSERT INTO club.Empleado(Nombre, Apellido)
	SELECT
		LEFT(tmp.Profesor,LEN(tmp.Profesor) - CHARINDEX(' ', REVERSE(tmp.Profesor)) + 1) AS Nombre,
		LTRIM(RIGHT(tmp.Profesor, LEN(tmp.Profesor) - CHARINDEX(' ', tmp.Profesor))) AS Apellido
	FROM #TempImport_Asiste tmp

	/*
	INSERT INTO actividades.Socio_Asiste_Clase (Fecha, Asiste, ID_Socio)
	SELECT Fecha,Asiste,ID_Socio
	FROM #TempImport_Asiste*/
	
	DROP TABLE #TempImport_Asiste;
END
GO

*/
