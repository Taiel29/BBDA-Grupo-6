--En este script se prueba la funcionalidad de los scripts de importación a tablas

--Fecha de entrega: 19/06/2025
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

-- Probar SP "importaciones.Import_Asistencias"
-- Al final deben quedar actualizadas y sin duplicados:
-- Tabla socios.Socio con todos los socios que sean responsables de pago


EXEC importaciones.ImportarSociosDesdeExcel
	@RutaExcel = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO

SELECT * FROM socios.Socio
SELECT s.ID, s.Nombre, s.Apellido, s.Fecha_Nacimiento, cs.Nombre FROM socios.Socio s JOIN socios.Categoria_Socio cs on cs.ID = s.ID_Categoria_Socio


-- Probar SP "importaciones.Import_Asistencias"
-- Al final deben quedar actualizadas y sin duplicados:
-- Tabla club.Empleado con el nombre completo del profesor
-- Tabla actividades.Clase con el día de la semana que se da, a que actividad pertenece, y cual profe la da
-- Tabla actividades.Socio_Asiste_Clase con el alumno, la fecha, la clase, y si asistió

EXEC importaciones.Import_Asistencias
    @rutaArch = 'C:\Users\Public\Documents\Datos socios.xlsx'
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

EXEC importaciones.ImportarPagoCuotasDesdeExcel
	@RutaExcel = 'C:\Users\messi\Desktop\UNLAM\Tercer año\BASE DE DATOS APLICADAS\TP\SQL\TPI-2025-1C\Datos socios.xlsx'
GO

SELECT * FROM tesoreria.Cuota
SELECT * FROM tesoreria.Pago
SELECT * FROM tesoreria.Factura