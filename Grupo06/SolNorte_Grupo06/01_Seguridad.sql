--En este script se implementan los mecanismos de seguridad pedidos, tales como la encriptación de datos y la creación de roles

--Fecha de entrega: 24/06/2025
--Comisión: 2900
--Grupo: 6
--Base de datos Aplicada
--Integrantes:
--Fariello Ramiro - DNI: 46124109
--Rojas Taiel Ezequiel - DNI: 46183434
--Cropalati Franco Nicolas - DNI: 43404823
--Miguez Alejo - DNI: 41667306

-- Creación de Login---

USE master
GO

IF SUSER_ID(N'login_Jefe_Tesoreria') IS NULL
BEGIN
    CREATE LOGIN login_Jefe_Tesoreria
		WITH PASSWORD = 'ManejoMuchaPlata.912',
		DEFAULT_DATABASE = Com2900G06;
END
GO

IF SUSER_ID(N'login_Administrativo_Cobranza') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Cobranza
		WITH PASSWORD = 'ManejoCobranzas#001',
		DEFAULT_DATABASE = Com2900G06;
END
GO

IF SUSER_ID(N'login_Administrativo_Cobranza') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Cobranza
		WITH PASSWORD = 'ManejoCobranzas#001',
		DEFAULT_DATABASE = Com2900G06;
END
GO

IF SUSER_ID(N'login_Administrativo_Morosidad') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Morosidad
        WITH PASSWORD = 'ManejoMorosos.12345',
        DEFAULT_DATABASE = Com2900G06;
END
GO

IF SUSER_ID(N'login_Administrativo_Facturacion') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Facturacion
        WITH PASSWORD = 'TenesQueCerrarElEstadio.01',
        DEFAULT_DATABASE = Com2900G06;
END
GO

IF SUSER_ID(N'login_Administrativo_Socio') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Socio
        WITH PASSWORD = 'RiverElMasGrande#91218',
        DEFAULT_DATABASE = Com2900G06;
END
GO

IF SUSER_ID(N'login_Socios_Web') IS NULL
BEGIN
    CREATE LOGIN login_Socios_Web
        WITH PASSWORD = 'ILoveCats.4Ever',
        DEFAULT_DATABASE = Com2900G06;
END
GO

IF SUSER_ID(N'login_Presidente') IS NULL
BEGIN
    CREATE LOGIN login_Presidente
        WITH PASSWORD = 'JorgeBrito.12345',
        DEFAULT_DATABASE = Com2900G06;
END
GO

IF SUSER_ID(N'login_Vicepresidente') IS NULL
BEGIN
    CREATE LOGIN login_Vicepresidente
        WITH PASSWORD = 'JuanRoncarRiquelme.2606',
        DEFAULT_DATABASE = Com2900G06;
END
GO

IF SUSER_ID(N'login_Secretario') IS NULL
BEGIN
    CREATE LOGIN login_Secretario
        WITH PASSWORD = '2025.QueLaGenteCrea',
        DEFAULT_DATABASE = Com2900G06;
END
GO

IF SUSER_ID(N'login_Vocal') IS NULL
BEGIN
    CREATE LOGIN login_Vocal
        WITH PASSWORD = '290195.NoEsMiNacimiento',
        DEFAULT_DATABASE = Com2900G06;
END
GO

--- Creacion de users---
USE Com2900G06
GO
IF DATABASE_PRINCIPAL_ID('user_Jefe_Tesoreria') IS NULL
    CREATE USER user_Jefe_Tesoreria FOR LOGIN login_Jefe_Tesoreria WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('user_Administrativo_Cobranza') IS NULL
    CREATE USER user_Administrativo_Cobranza FOR LOGIN login_Administrativo_Cobranza WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('user_Administrativo_Morosidad') IS NULL
    CREATE USER user_Administrativo_Morosidad FOR LOGIN login_Administrativo_Morosidad WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('user_Administrativo_Facturacion') IS NULL
    CREATE USER user_Administrativo_Facturacion FOR LOGIN login_Administrativo_Facturacion WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('user_Administrativo_Socio') IS NULL
    CREATE USER user_Administrativo_Socio FOR LOGIN login_Administrativo_Socio WITH DEFAULT_SCHEMA = socios;

IF DATABASE_PRINCIPAL_ID('user_Socios_Web') IS NULL
    CREATE USER user_Socios_Web FOR LOGIN login_Socios_Web WITH DEFAULT_SCHEMA = socios;

IF DATABASE_PRINCIPAL_ID('user_Presidente') IS NULL
    CREATE USER user_Presidente FOR LOGIN login_Presidente WITH DEFAULT_SCHEMA = club;

IF DATABASE_PRINCIPAL_ID('user_Vicepresidente') IS NULL
    CREATE USER user_Vicepresidente FOR LOGIN login_Vicepresidente WITH DEFAULT_SCHEMA = club;

IF DATABASE_PRINCIPAL_ID('user_Secretario') IS NULL
    CREATE USER user_Secretario FOR LOGIN login_Secretario WITH DEFAULT_SCHEMA = club;

IF DATABASE_PRINCIPAL_ID('user_Vocal') IS NULL
    CREATE USER user_Vocal FOR LOGIN login_Vocal WITH DEFAULT_SCHEMA = club;
GO
--- Creación de roles---

IF DATABASE_PRINCIPAL_ID('rol_Jefe_Tesoreria') IS NULL
    CREATE ROLE rol_Jefe_Tesoreria AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Administrativo_Cobranza') IS NULL
    CREATE ROLE rol_Administrativo_Cobranza AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Administrativo_Morosidad') IS NULL
    CREATE ROLE rol_Administrativo_Morosidad AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Administrativo_Facturacion') IS NULL
    CREATE ROLE rol_Administrativo_Facturacion AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Administrativo_Socio') IS NULL
    CREATE ROLE rol_Administrativo_Socio AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Socios_Web') IS NULL
    CREATE ROLE rol_Socios_Web AUTHORIZATION user_Administrativo_Socio;

IF DATABASE_PRINCIPAL_ID('rol_Presidente') IS NULL
    CREATE ROLE rol_Presidente AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Vicepresidente') IS NULL
    CREATE ROLE rol_Vicepresidente AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Secretario') IS NULL
    CREATE ROLE rol_Secretario AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Vocal') IS NULL
    CREATE ROLE rol_Vocal AUTHORIZATION dbo;
GO

-- Asignar usuarios a roles---
ALTER ROLE rol_Jefe_Tesoreria ADD MEMBER user_Jefe_Tesoreria;
ALTER ROLE rol_Administrativo_Cobranza ADD MEMBER user_Administrativo_Cobranza;
ALTER ROLE rol_Administrativo_Morosidad ADD MEMBER user_Administrativo_Morosidad;
ALTER ROLE rol_Administrativo_Facturacion ADD MEMBER user_Administrativo_Facturacion;
ALTER ROLE rol_Administrativo_Socio ADD MEMBER user_Administrativo_Socio;
ALTER ROLE rol_Socios_Web ADD MEMBER user_Socios_Web;
ALTER ROLE rol_Presidente ADD MEMBER user_Presidente;
ALTER ROLE rol_Vicepresidente ADD MEMBER user_Vicepresidente;
ALTER ROLE rol_Secretario ADD MEMBER user_Secretario;
ALTER ROLE rol_Vocal ADD MEMBER user_Vocal;
GO
---Asignar permisos a roles---

--Permisos para el jefe de tesoreria
GRANT CONTROL ON SCHEMA::tesoreria TO rol_Jefe_Tesoreria;
GRANT CONTROL ON SCHEMA::reportes TO rol_Jefe_Tesoreria;

--Permisos para el administrativo de cobranza
GRANT SELECT ON SCHEMA::tesoreria TO rol_Administrativo_Cobranza;
GRANT UPDATE ON SCHEMA::tesoreria TO rol_Administrativo_Cobranza;
GRANT SELECT ON socios.Socio TO rol_Administrativo_Cobranza;
GRANT SELECT ON socios.Cuenta TO rol_Administrativo_Cobranza;
GRANT EXECUTE ON SCHEMA::reportes TO rol_Administrativo_Cobranza;

--Permisos para el administrativo de morosidad
GRANT SELECT ON SCHEMA::tesoreria TO rol_Administrativo_Morosidad;
GRANT UPDATE ON SCHEMA::tesoreria TO rol_Administrativo_Morosidad;
GRANT SELECT ON socios.Socio TO rol_Administrativo_Morosidad;
GRANT SELECT ON socios.Estado_Socio TO rol_Administrativo_Morosidad;
GRANT UPDATE ON socios.Estado_Socio TO rol_Administrativo_Morosidad;
GRANT EXECUTE ON SCHEMA::reportes TO rol_Administrativo_Morosidad;

--Permisos para el administrativo de facturacion
GRANT SELECT ON SCHEMA::tesoreria TO rol_Administrativo_Facturacion;
GRANT UPDATE ON SCHEMA::tesoreria TO rol_Administrativo_Cobranza;
GRANT SELECT ON SCHEMA::actividades TO rol_Administrativo_Facturacion;
GRANT SELECT ON socios.Socio TO rol_Administrativo_Facturacion;
GRANT SELECT ON socios.Estado_Socio TO rol_Administrativo_Facturacion;
GRANT EXECUTE ON SCHEMA::reportes TO rol_Administrativo_Facturacion;

--Permisos para el administrativo socio
GRANT CONTROL ON SCHEMA::socios TO rol_Administrativo_Socio;
GRANT UPDATE ON SCHEMA::socios TO rol_Administrativo_Socio;
GRANT SELECT ON SCHEMA::actividades TO rol_Administrativo_Socio;
GRANT UPDATE ON SCHEMA::actividades TO rol_Administrativo_Socio;

--Permisos para el socio web
GRANT SELECT ON SCHEMA::socios TO rol_Socios_Web;
GRANT UPDATE ON socios.Socio TO rol_Socios_Web;
GRANT SELECT ON socios.Grupo_Familiar TO rol_Socios_Web;
GRANT UPDATE ON socios.Grupo_Familiar TO rol_Socios_Web;

--Permisos para el presidente
GRANT CONTROL ON SCHEMA::club TO rol_Presidente;
GRANT EXECUTE ON SCHEMA::reportes TO rol_Presidente;
GRANT EXECUTE ON SCHEMA::importaciones TO rol_Presidente;
GRANT SELECT ON SCHEMA::socios TO rol_Presidente;
GRANT SELECT ON SCHEMA::tesoreria TO rol_Presidente;
GRANT SELECT ON SCHEMA::actividades TO rol_Presidente;

--Permisos para el vice presidente
GRANT SELECT ON SCHEMA::club TO rol_Vicepresidente;
GRANT UPDATE ON SCHEMA::club TO rol_Vicepresidente;
GRANT EXECUTE ON SCHEMA::reportes TO rol_Vicepresidente;
GRANT SELECT ON SCHEMA::socios TO rol_Vicepresidente;
GRANT SELECT ON SCHEMA::tesoreria TO rol_Vicepresidente;
GRANT SELECT ON SCHEMA::actividades TO rol_Vicepresidente;

--Permisos para el secretario
GRANT SELECT ON SCHEMA::club TO rol_Secretario;
GRANT EXECUTE ON SCHEMA::reportes TO rol_Secretario;
GRANT SELECT ON SCHEMA::socios TO rol_Secretario;
GRANT SELECT ON SCHEMA::tesoreria TO rol_Secretario;
GRANT SELECT ON SCHEMA::actividades TO rol_Secretario;

--Permisos para el vocal
GRANT SELECT ON SCHEMA::club TO rol_Vocal;
GRANT SELECT ON SCHEMA::socios TO rol_Vocal;
GRANT SELECT ON SCHEMA::tesoreria TO rol_Vocal;
GRANT SELECT ON SCHEMA::actividades TO rol_Vocal;


-- AGREGO CAMPOS A ENCRIPTAR PARA NO PISAR LOS DATOS ORIGINALES (empleado)

-- ================== IDENTIFICADORES ==================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'club' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'DNI_Enc')
    ALTER TABLE club.Empleado ADD DNI_Enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'club' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'Fecha_Nacimiento_Enc')
    ALTER TABLE club.Empleado ADD Fecha_Nacimiento_Enc VARBINARY(MAX);

-- ================== INFORMACIÓN PERSONAL =============
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'club' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'Nombre_Enc')
    ALTER TABLE club.Empleado ADD Nombre_Enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'club' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'Apellido_Enc')
    ALTER TABLE club.Empleado ADD Apellido_Enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'club' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'Area_Enc')
    ALTER TABLE club.Empleado ADD Area_Enc VARBINARY(MAX);

-- ================== CONTACTO =========================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'club' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'Telefono_De_Contacto_Enc')
    ALTER TABLE club.Empleado ADD Telefono_De_Contacto_Enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'club' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'Telefono_De_Emergencia_Enc')
    ALTER TABLE club.Empleado ADD Telefono_De_Emergencia_Enc VARBINARY(MAX);
GO

IF EXISTS (SELECT 1 FROM sys.triggers WHERE name='trg_Empleado_Encrypt')
    DROP TRIGGER club.trg_Empleado_Encrypt;
GO

CREATE OR ALTER TRIGGER club.trg_Empleado_Encrypt
ON club.Empleado
AFTER INSERT
AS
BEGIN
	Declare @password as varchar(50)
	Set @password = '#BBDA.2025'
		-- Encriptar y actualizar las columnas encriptadas
		UPDATE emp
		SET 
			emp.Nombre_Enc = ENCRYPTBYPASSPHRASE(@password, i.Nombre),
			emp.Apellido_Enc = ENCRYPTBYPASSPHRASE(@password, i.Apellido),
			emp.DNI_Enc = ENCRYPTBYPASSPHRASE(@password, i.DNI),
			emp.Fecha_Nacimiento_Enc = ENCRYPTBYPASSPHRASE(@password, CONVERT(VARCHAR, i.Fecha_Nacimiento, 23)),
			emp.Area_Enc = ENCRYPTBYPASSPHRASE(@password, i.Area),
			emp.Telefono_De_Contacto_Enc = ENCRYPTBYPASSPHRASE(@password, CAST(i.Telefono_De_Contacto AS VARCHAR)),
			emp.Telefono_De_Emergencia_Enc = ENCRYPTBYPASSPHRASE(@password, CAST(i.Telefono_De_Emergencia AS VARCHAR))
		FROM club.Empleado emp
		INNER JOIN inserted i ON emp.ID = i.ID;

		UPDATE emp
		SET 
			emp.Nombre = 'encryp',
			emp.Apellido = 'encryp',
			emp.DNI = NULL,
			emp.Fecha_Nacimiento = NULL,
			emp.Area = NULL,
			emp.Telefono_De_Contacto = NULL,
			emp.Telefono_De_Emergencia = NULL
		FROM club.Empleado emp
		INNER JOIN inserted i ON emp.ID = i.ID;
END;
GO

--DESENCRIPTAR TABLA EMPLEADO Y MOSTRAR

CREATE OR ALTER PROCEDURE club.sp_DesencriptarEmpleado
	@password NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE emp
	SET 
		Nombre = CONVERT(VARCHAR(50), DECRYPTBYPASSPHRASE(@password, Nombre_Enc)),
		Apellido = CONVERT(VARCHAR(50), DECRYPTBYPASSPHRASE(@password, Apellido_Enc)),
		DNI = CONVERT(CHAR(9), DECRYPTBYPASSPHRASE(@password, DNI_Enc)),
		Fecha_Nacimiento = CONVERT(DATE, DECRYPTBYPASSPHRASE(@password, Fecha_Nacimiento_Enc)),
		Area = CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE(@password, Area_Enc)),
		Telefono_De_Contacto = CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE(@password, Telefono_De_Contacto_Enc)),
		Telefono_De_Emergencia = CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE(@password, Telefono_De_Emergencia_Enc))
	FROM club.Empleado emp;
END;
GO

CREATE OR ALTER PROCEDURE club.sp_EncriptarEmpleado
	@password NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
		-- Encriptar y actualizar las columnas encriptadas
		UPDATE emp
		SET 
			emp.Nombre_Enc = ENCRYPTBYPASSPHRASE(@password, emp.Nombre),
			emp.Apellido_Enc = ENCRYPTBYPASSPHRASE(@password, emp.Apellido),
			emp.DNI_Enc = ENCRYPTBYPASSPHRASE(@password, emp.DNI),
			emp.Fecha_Nacimiento_Enc = ENCRYPTBYPASSPHRASE(@password, CONVERT(VARCHAR, emp.Fecha_Nacimiento, 23)),
			emp.Area_Enc = ENCRYPTBYPASSPHRASE(@password, emp.Area),
			emp.Telefono_De_Contacto_Enc = ENCRYPTBYPASSPHRASE(@password, CAST(emp.Telefono_De_Contacto AS VARCHAR)),
			emp.Telefono_De_Emergencia_Enc = ENCRYPTBYPASSPHRASE(@password, CAST(emp.Telefono_De_Emergencia AS VARCHAR))
		FROM club.Empleado emp
		WHERE emp.Nombre <> 'encryp'

		UPDATE emp
		SET 
			emp.Nombre = 'encryp',
			emp.Apellido = 'encryp',
			emp.DNI = NULL,
			emp.Fecha_Nacimiento = NULL,
			emp.Area = NULL,
			emp.Telefono_De_Contacto = NULL,
			emp.Telefono_De_Emergencia = NULL
		FROM club.Empleado emp
END;
GO