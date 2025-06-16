--En este script se implementan los mecanismos de seguridad pedidos, tales como la encriptación de datos y la creación de roles

--Fecha de entrega: 17/06/2025
--Comisión: 2900
--Grupo: 6
--Base de datos Aplicada
--Integrantes:
--Fariello Ramiro - DNI: 46124109
--Rojas Taiel Ezequiel - DNI: 46183434
--Cropalati Franco Nicolas - DNI: 43404823
--Miguez Alejo - DNI: 41667306

-- Creación de Login

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

--- Creacion de users
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

--- Creación de roles

IF DATABASE_PRINCIPAL_ID('rol_Jefe_Tesoreria') IS NULL
BEGIN
    CREATE ROLE rol_Jefe_Tesoreria AUTHORIZATION dbo;
END;

IF DATABASE_PRINCIPAL_ID('rol_Administrativo_Cobranza') IS NULL
BEGIN
    CREATE ROLE rol_Administrativo_Cobranza AUTHORIZATION dbo;
END;

IF DATABASE_PRINCIPAL_ID('rol_Administrativo_Morosidad') IS NULL
BEGIN
    CREATE ROLE rol_Administrativo_Morosidad AUTHORIZATION dbo;
END;

IF DATABASE_PRINCIPAL_ID('rol_Administrativo_Facturacion') IS NULL
BEGIN
    CREATE ROLE rol_Administrativo_Facturacion AUTHORIZATION dbo;
END;

IF DATABASE_PRINCIPAL_ID('rol_Administrativo_Socio') IS NULL
BEGIN
    CREATE ROLE rol_Administrativo_Socio AUTHORIZATION dbo;
END;

IF DATABASE_PRINCIPAL_ID('rol_Socios_Web') IS NULL
BEGIN
    CREATE ROLE rol_Socios_Web AUTHORIZATION user_Administrativo_Socio;
END;

IF DATABASE_PRINCIPAL_ID('rol_Presidente') IS NULL
BEGIN
    CREATE ROLE rol_Presidente AUTHORIZATION dbo;
END;

IF DATABASE_PRINCIPAL_ID('rol_Vicepresidente') IS NULL
BEGIN
    CREATE ROLE rol_Vicepresidente AUTHORIZATION dbo;
END;

IF DATABASE_PRINCIPAL_ID('rol_Secretario') IS NULL
BEGIN
    CREATE ROLE rol_Secretario AUTHORIZATION dbo;
END;

IF DATABASE_PRINCIPAL_ID('rol_Vocal') IS NULL
BEGIN
    CREATE ROLE rol_Vocal AUTHORIZATION dbo;
END;

-- Asignar miembros a roles

-- Asignar permisos a roles