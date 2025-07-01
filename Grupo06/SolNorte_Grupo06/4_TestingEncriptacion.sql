--En este script se prueba la funcionalidad de los scripts de encriptado y desencriptado de tablas

--Fecha de entrega: 1/07/2025
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

EXEC club.sp_DesencriptarEmpleado @password = '#BBDA.2025';
GO
SELECT * FROM club.Empleado

EXEC club.sp_EncriptarEmpleado @password = '#BBDA.2025';
GO
SELECT * FROM club.Empleado
