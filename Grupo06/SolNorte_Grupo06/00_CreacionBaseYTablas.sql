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


CREATE TABLE grupo_familiar(
	 ID INT Identity(1,1) PRIMARY KEY,
	 ID_Socio INT NULL,

);

CREATE TABLE estado_socio(
	ID INT Identity(1,1) PRIMARY KEY,
	Descripcion VARCHAR(100) NOT NULL
);

CREATE TABLE tarifa_categoria(
	ID INT Identity (1,1) PRIMARY KEY,
	Importe FLOAT NOT NULL,
	Vigente_hasta DATE NOT NULL
);
CREATE TABLE cuenta(
	ID INT Identity(1,1) PRIMARY KEY,
	Saldo FLOAT,
	ID_socio INT,
);

CREATE TABLE categoria_socio(
	ID INT Identity (1,1) PRIMARY KEY,
	Nombre VARCHAR(50) NOT NULL,
	Descripcion VARCHAR(100),
	ID_tarifa_categoria INT
	FOREIGN KEY(ID_tarifa_categoria) REFERENCES tarifa_categoria(ID) ON DELETE CASCADE

);


CREATE TABLE socio( -- realizar schema por seguridad
	ID INT Identity(1,1) PRIMARY KEY,
	DNI CHAR(9) NOT NULL UNIQUE,
	Fecha_nacimiento DATE,
	Apellido VARCHAR(50) NOT NULL,
	Nombre VARCHAR(50) NOT NULL,
	Numero_de_socio_OS INT NOT NULL UNIQUE,
	Telefono_de_emergencias_OS INT NOT NULL,
	Telefono_contacto_emergencia INT NOT NULL,
	Nombre_obra_social VARCHAR(50),
	Telefono_contacto INT,
	ID_estado_socio INT,
	ID_grupo_familiar INT,
	ID_categoria_socio INT,
	FOREIGN KEY(ID_estado_socio) REFERENCES estado_socio(ID) ON DELETE CASCADE,
	FOREIGN KEY(ID_grupo_familiar) REFERENCES grupo_familiar(ID) ON DELETE CASCADE,
	FOREIGN KEY(ID_categoria_socio) REFERENCES categoria_socio(ID) ON DELETE CASCADE,
);

ALTER TABLE cuenta
ADD CONSTRAINT FK_id_socio FOREIGN KEY (ID_socio)
REFERENCES socio(ID) ON DELETE CASCADE

ALTER TABLE grupo_familiar
ADD CONSTRAINT FK_id_socio FOREIGN KEY (ID_socio)
REFERENCES socio(ID) ON DELETE CASCADE

CREATE TABLE empleado( -- realizar schema por seguridad
	ID INT Identity (1,1) PRIMARY KEY,
	DNI CHAR(9) NOT NULL UNIQUE,
	Fecha_nacimiento DATE,
	Nombre VARCHAR(50) NOT NULL,
	Apellido VARCHAR(50) NOT NULL,
	Area VARCHAR(20) NOT NULL,
	Telefono_de_contacto INT,
	Telefono_de_emergencia INT NOT NULL
);

CREATE TABLE rol ( -- realizar schema por seguridad
	ID INT Identity (1,1) PRIMARY KEY,
	Nombre_del_puesto VARCHAR(30) NOT NULL
);

CREATE TABLE usuario(
	ID INT Identity (1,1) PRIMARY KEY,
	Contraseña VARCHAR(10) NOT NULL,
	Email VARCHAR(100) NOT NULL,
	Nombre_usuario VARCHAR(20) NOT NULL,
	Fecha_de_vigencia_contraseña DATE NOT NULL,
	ID_socio INT NULL,
	ID_empleado INT NULL,
	ID_rol INT,
	FOREIGN KEY(ID_socio) REFERENCES socio(ID) ON DELETE CASCADE,
	FOREIGN KEY (ID_empleado) REFERENCES empleado(ID) ON DELETE CASCADE,
	FOREIGN KEY (ID_rol) REFERENCES rol(ID) ON DELETE CASCADE
); 

CREATE TABLE cuenta_utilizo_medio_de_pago (-- falta tabla medio de pago
	ID_cuenta INT UNIQUE,
	ID_medio_de_pago INT,
	FOREIGN KEY(ID_cuenta) REFERENCES cuenta(ID) ON DELETE CASCADE,
	--FOREIGN KEY(ID_medio_de_pago) REFERENCES medio_de_pago(ID) -- falta tabla medio de pago
); 

CREATE TABLE socio_asiste_clase(
	ID_socio INT UNIQUE,
	ID_clase INT,
	Fecha DATE,
	--FOREIGN KEY(ID_clase) REFERENCES clase(ID) ON DELETE CASCADE -- falta tabla clase 
	FOREIGN KEY(ID_socio) REFERENCES socio(ID) ON DELETE CASCADE
);

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


