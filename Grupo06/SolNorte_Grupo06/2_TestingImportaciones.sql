--En este script se prueba la funcionalidad de los scripts de importación a tablas

--Fecha de entrega: 24/06/2025
--Comisión: 2900
--Grupo: 6
--Base de datos Aplicada
--Integrantes:
--Fariello Ramiro - DNI: 46124109
--Rojas Taiel Ezequiel - DNI: 46183434
--Cropalati Franco Nicolas - DNI: 43404823
--Miguez Alejo - DNI: 41667306

USE Com2900G06
GO

-- Probar SP "importaciones.Import_Tarifa_Actividad"
-- Al final deben quedar las tablas tesoreria.Tarifa_Actividad y actividades.Actividad actualizadas sin duplicados

EXEC importaciones.Import_Actividades
    @rutaArch = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO

SELECT * FROM tesoreria.Tarifa_Actividad
SELECT * FROM actividades.Actividad

-- Probar SP "importaciones.Import_Tarifas_Cuotas"
-- Al final deben quedar actualizadas y sin duplicados:
-- Tabla tesoreria.Tarifa_Categoria con los importes y sus vigencias
-- Tabla socios.Categoria_Socio con los tipos de socios disponibles y a cual tarifa se corresponden

EXEC importaciones.Import_Tarifas_Cuotas
    @rutaArch = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO

SELECT * FROM tesoreria.Tarifa_Categoria
SELECT * FROM socios.Categoria_Socio

-- Probar SP "importaciones.Importar_Socios_Desde_Excel"
-- Al final deben quedar actualizadas y sin duplicados:
-- Tabla socios.Socio con todos los socios que sean responsables de pago
-- Tabla importaciones.Errores_Importacion_Socios con aquellos socios que no se puedan cargar y la razón

EXEC importaciones.Importar_Socios_Desde_Excel
	@RutaExcel = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO

SELECT * FROM socios.Socio
SELECT s.ID, s.Nombre, s.Apellido, s.Fecha_Nacimiento, cs.Nombre FROM socios.Socio s JOIN socios.Categoria_Socio cs on cs.ID = s.ID_Categoria_Socio
SELECT * FROM importaciones.Errores_Importacion_Socios ORDER BY Nro_Socio

-- Probar SP "importaciones.Importar_Grupo_Familiar"
-- Al final deben quedar actualizadas y sin duplicados:
-- Tabla socios.Socio con todos los socios que pertenezcan a un grupo familiar
-- Tabla socios.Grupo_Familiar con los responsables de cada grupo

EXEC importaciones.Importar_Grupo_Familiar
	@RutaExcel = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO

SELECT * FROM socios.Socio ORDER BY Nro_Socio
SELECT ss.Nro_Socio
FROM socios.Socio ss
JOIN socios.Grupo_Familiar gf on ss.ID = gf.ID_Socio_Responsable

-- Probar SP "importaciones.Import_Asistencias"
-- Al final deben quedar actualizadas y sin duplicados:
-- Tabla club.Empleado con el nombre completo del profesor
-- Tabla actividades.Clase con el día de la semana que se da, a que actividad pertenece, y cual profe la da
-- Tabla actividades.Socio_Asiste_Clase con el alumno, la fecha, la clase, y si asistió

EXEC importaciones.Import_Asistencias
    @rutaArch = 'C:\Users\Public\Documents\Datos socios.xlsx',
	@password = '#BBDA.2025'
GO

SELECT * FROM club.Empleado
SELECT * FROM actividades.Clase
SELECT * FROM actividades.Socio_Asiste_Clase

-- Probar SP "importaciones.Import_Tarifas_Pileta"
-- Al final deben quedar actualizadas y sin duplicados:
-- Tabla tesoreria.Tarifa_Categoria con los importes y sus vigencias
-- Tabla socios.Categoria_Socio con los tipos de socios disponibles y a cual tarifa se corresponden

EXEC importaciones.Import_Tarifas_Pileta
    @rutaArch = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO

SELECT * FROM tesoreria.Tarifa_Pileta

-- Probar SP "importaciones.ImportarPagoCuotasDesdeExcel"
-- Al final deben quedar actualizadas y sin duplicados:
-- tesoreria.Medio_Pago con las descripciones de los tipos de pago disponibles
-- Tabla tesoreria.Cuota con el mes y socio que corresponde, y su factura relacionada
-- Tabla tesoreria.Pago con su ID y Fecha de pago, y NULL en la hora de pago (Dato que no se nos proporciona)
-- Tabla tesoreria.Factura con las fechas, importe, e ID_Pago correspondientes

EXEC importaciones.ImportarPagoCuotasDesdeExcel
	@RutaExcel = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO

SELECT * From tesoreria.Medio_Pago
SELECT * FROM tesoreria.Cuota
SELECT * FROM tesoreria.Pago
SELECT * FROM tesoreria.Factura

-- Probar SP "importaciones.Importar_Lluvia"
-- Al final deben quedar actualizadas y sin duplicados:
-- Tabla #TempImport_lluvia con los datos de los días que llovieron en el 2024 y 2025

EXEC importaciones.Importar_Lluvia
	@RutaArch1 = 'C:\Users\Public\Documents\open-meteo-buenosaires_2024.csv',
	@RutaArch2 = 'C:\Users\Public\Documents\open-meteo-buenosaires_2025.csv'
GO

SELECT * FROM ##TempLluviaDiaria
