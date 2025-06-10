--En este script se realiza la creación de la base de datos y las tablas contenidas en esta junto con sus restricciones

--Fecha de entrega: 19/06/2025
--Comisión: 2900
--Grupo: 6
--Base de datos Aplicada
--Integrantes:
--Fariello Ramiro - DNI: 46124109
--Rojas Taiel Ezequiel - DNI: 46183434
--Cropalati Franco Nicolas - DNI: 43404823
--Miguez Alejo - DNI: 41667306

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'Com2900G06')
BEGIN
    USE master
	DROP DATABASE Com2900G06
END
GO

CREATE DATABASE Com2900G06
GO

USE Com2900G06

-- CREACIÓN DE ESQUEMAS--

IF SCHEMA_ID(N'tesoreria') IS NULL
    EXEC('CREATE SCHEMA tesoreria');

IF SCHEMA_ID(N'actividades') IS NULL
    EXEC('CREATE SCHEMA actividades');

-- CREACIÓN DE TABLAS--

IF OBJECT_ID(N'actividades.Adulto_Responsable', N'U') IS NOT NULL
	DROP TABLE actividades.Adulto_Responsable
GO

CREATE TABLE actividades.Adulto_Responsable(
    ID INT Identity(1,1) Primary Key,
    DNI CHAR(9) NOT NULL UNIQUE,
    Apellido VARCHAR(50) NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Fecha_nacimiento DATE,
    Email VARCHAR(100),
    Telefono_contacto VARCHAR(20),
    Parentesco VARCHAR(50)
);

IF OBJECT_ID(N'actividades.Inscripcion', N'U') IS NOT NULL
	DROP TABLE actividades.Inscripcion
GO

CREATE TABLE actividades.Inscripcion(
    ID INT Identity(1,1) Primary Key,
    Fecha DATE NOT NULL,
    ID_Adulto INT NULL,
    Tipo VARCHAR(20) NOT NULL,
    -- Falta la tabla socio pero: ID_Socio INT,
    FOREIGN KEY (ID_Adulto) REFERENCES actividades.Adulto_Responsable(ID) ON DELETE CASCADE
    -- Falta la tabla socio pero: FOREIGN KEY (ID_Socio) REFERENCES socios.socio(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'tesoreria.Tarifa_Actividad', N'U') IS NOT NULL
	DROP TABLE tesoreria.Tarifa_Actividad
GO

CREATE TABLE tesoreria.Tarifa_Actividad(
    ID INT IDENTITY(1,1) Primary Key,
    Importe_Por_Mes NUMERIC(10,2),
    Vigente_Hasta DATE
);

-- Falta terminar
IF OBJECT_ID(N'actividades.Actividad', N'U') IS NOT NULL
	DROP TABLE actividades.Actividad
GO

CREATE TABLE actividades.Actividad(
    Descripcion VARCHAR(50) NOT NULL,
    ID_Tarifa
);


