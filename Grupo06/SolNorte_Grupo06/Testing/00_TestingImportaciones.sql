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
    @rutaArch = 'T:\Descargas\TPI-2025-1C (2)\TPI-2025-1C\Datos socios.xlsx'
GO

SELECT * FROM tesoreria.Tarifa_Actividad
SELECT * FROM actividades.Actividad

-- Probar SP "importaciones.Import_Asistencias"
-- En proceso

EXEC importaciones.Import_Asistencias
    @rutaArch = 'T:\Descargas\TPI-2025-1C (2)\TPI-2025-1C\Datos socios.xlsx'
GO

SELECT* FROM club.Empleado
SELECT* FROM actividades.Socio_Asiste_Clase