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

IF SCHEMA_ID(N'socios') IS NULL
    EXEC('CREATE SCHEMA socios');

IF SCHEMA_ID(N'club') IS NULL
    EXEC('CREATE SCHEMA club');
-- CREACIÓN DE TABLAS--

IF OBJECT_ID(N'socios.Grupo_Familiar', N'U') IS NOT NULL
	DROP TABLE socios.Grupo_Familiar
GO

CREATE TABLE socios.Grupo_Familiar(
	 ID INT Identity(1,1) PRIMARY KEY,
	 ID_Socio_Responsable INT NULL,
);

IF OBJECT_ID(N'socios.Estado_Socio', N'U') IS NOT NULL
	DROP TABLE socios.Estado_Socio
GO

CREATE TABLE socios.Estado_Socio(
	ID INT Identity(1,1) PRIMARY KEY,
	Descripcion VARCHAR(100) NOT NULL
);

IF OBJECT_ID(N'tesoreria.Tarifa_Categoria', N'U') IS NOT NULL
	DROP TABLE tesoreria.Tarifa_Categoria
GO

CREATE TABLE tesoreria.Tarifa_Categoria(
	ID INT Identity (1,1) PRIMARY KEY,
	Importe NUMERIC(10,2) NOT NULL,
	Vigente_Hasta DATE NOT NULL
);

IF OBJECT_ID(N'socios.Categoria_Socio', N'U') IS NOT NULL
	DROP TABLE socios.Categoria_Socio
GO

CREATE TABLE socios.Categoria_Socio(
	ID INT Identity (1,1) PRIMARY KEY,
	Nombre VARCHAR(50) NOT NULL,
	Descripcion VARCHAR(100),
	ID_Tarifa_Categoria INT
	FOREIGN KEY(ID_Tarifa_Categoria) REFERENCES tesoreria.Tarifa_Categoria(ID) ON DELETE CASCADE

);

IF OBJECT_ID(N'socios.Socio', N'U') IS NOT NULL
	DROP TABLE socios.Socio
GO

CREATE TABLE socios.Socio(
	ID INT Identity(1,1) PRIMARY KEY,
	DNI CHAR(9) NOT NULL UNIQUE,
	Fecha_Nacimiento DATE,
	Apellido VARCHAR(50) NOT NULL,
	Nombre VARCHAR(50) NOT NULL,
	Numero_De_Socio_OS INT NOT NULL UNIQUE,
	Telefono_De_Emergencias_OS INT NOT NULL,
	Telefono_Contacto_Emergencia INT NOT NULL,
	Nombre_Obra_Social VARCHAR(50),
	Telefono_Contacto INT,
	ID_Estado_Socio INT,
	ID_Grupo_Familiar INT,
	ID_Categoria_Socio INT,
	FOREIGN KEY(ID_Estado_Socio) REFERENCES socios.Estado_Socio(ID) ON DELETE CASCADE,
	FOREIGN KEY(ID_Grupo_Familiar) REFERENCES socios.Grupo_Familiar(ID) ON DELETE SET NULL,
	FOREIGN KEY(ID_Categoria_Socio) REFERENCES socios.Categoria_Socio(ID) ON DELETE CASCADE,
);

IF OBJECT_ID(N'socios.Cuenta', N'U') IS NOT NULL
	DROP TABLE socios.Cuenta
GO

CREATE TABLE socios.Cuenta(
	ID INT Identity(1,1) PRIMARY KEY,
	Saldo FLOAT,
	ID_Socio INT,
	FOREIGN KEY(ID_Socio) REFERENCES socios.Socio(ID) ON DELETE CASCADE,
);

ALTER TABLE socios.Grupo_Familiar
ADD CONSTRAINT FK_ID_SocioR FOREIGN KEY (ID_Socio_Responsable)
REFERENCES socios.Socio(ID) ON DELETE SET NULL

IF OBJECT_ID(N'club.Empleado', N'U') IS NOT NULL
	DROP TABLE club.Empleado
GO

CREATE TABLE club.Empleado(
	ID INT Identity (1,1) PRIMARY KEY,
	DNI CHAR(9) NOT NULL UNIQUE,
	Fecha_Nacimiento DATE,
	Nombre VARCHAR(50) NOT NULL,
	Apellido VARCHAR(50) NOT NULL,
	Area VARCHAR(20) NOT NULL,
	Telefono_De_Contacto INT,
	Telefono_De_Emergencia INT NOT NULL
);

IF OBJECT_ID(N'club.Rol', N'U') IS NOT NULL
	DROP TABLE club.Rol
GO

CREATE TABLE club.Rol (
	ID INT Identity (1,1) PRIMARY KEY,
	Nombre_del_puesto VARCHAR(30) NOT NULL
);

IF OBJECT_ID(N'club.Usuario', N'U') IS NOT NULL
	DROP TABLE club.Usuario
GO

CREATE TABLE club.Usuario(
	ID INT Identity (1,1) PRIMARY KEY,
	Contraseña VARCHAR(10) NOT NULL,
	Email VARCHAR(100) NOT NULL,
	Nombre_Usuario VARCHAR(20) NOT NULL,
	Fecha_De_Vigencia_Contraseña DATE NOT NULL,
	ID_Socio INT NULL,
	ID_Empleado INT NULL,
	ID_Rol INT,
	FOREIGN KEY(ID_Socio) REFERENCES socios.Socio(ID) ON DELETE CASCADE,
	FOREIGN KEY (ID_Empleado) REFERENCES club.Empleado(ID) ON DELETE CASCADE,
	FOREIGN KEY (ID_Rol) REFERENCES club.Rol(ID) ON DELETE CASCADE
); 

IF OBJECT_ID(N'socios.Cuenta_Utilizo_Medio_De_Pago', N'U') IS NOT NULL
	DROP TABLE socios.Cuenta_Utilizo_Medio_De_Pago
GO

CREATE TABLE socios.Cuenta_Utilizo_Medio_De_Pago (-- falta tabla medio de pago
	ID_Cuenta INT UNIQUE,
	ID_Medio_De_Pago INT,
	FOREIGN KEY(ID_Cuenta) REFERENCES socios.Cuenta(ID) ON DELETE CASCADE,
	--FOREIGN KEY(ID_medio_de_pago) REFERENCES medio_de_pago(ID) -- falta tabla medio de pago
); 

IF OBJECT_ID(N'club.socio_Asiste_Clase', N'U') IS NOT NULL
	DROP TABLE club.socio_Asiste_Clase
GO

CREATE TABLE club.socio_Asiste_Clase(
	ID_Socio INT UNIQUE,
	ID_Clase INT,
	Fecha DATE,
	--FOREIGN KEY(ID_clase) REFERENCES clase(ID) ON DELETE CASCADE -- falta tabla clase 
	FOREIGN KEY(ID_socio) REFERENCES socios.Socio(ID) ON DELETE CASCADE
);

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
    ID_Socio INT NOT NULL,
    FOREIGN KEY (ID_Adulto) REFERENCES actividades.Adulto_Responsable(ID) ON DELETE CASCADE,
    FOREIGN KEY (ID_Socio) REFERENCES socios.Socio(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'tesoreria.Tarifa_Actividad', N'U') IS NOT NULL
	DROP TABLE tesoreria.Tarifa_Actividad
GO

CREATE TABLE tesoreria.Tarifa_Actividad(
    ID INT IDENTITY(1,1) Primary Key,
    Importe_Por_Mes NUMERIC(10,2) NOT NULL,
    Vigente_Hasta DATE
);

IF OBJECT_ID(N'actividades.Actividad', N'U') IS NOT NULL
	DROP TABLE actividades.Actividad
GO

CREATE TABLE actividades.Actividad(
	ID INT Identity(1,1) Primary Key,
    Descripcion VARCHAR(50) NOT NULL,
    ID_Tarifa INT NOT NULL,
	FOREIGN KEY(ID_Tarifa) REFERENCES tesoreria.Tarifa_Actividad(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'actividades.Clase', N'U') IS NOT NULL
	DROP TABLE actividades.Clase
GO

CREATE TABLE actividades.Clase(
	ID INT Identity(1,1) Primary Key,
	Día_De_La_Semana CHAR (10) NOT NULL,
	Horario_Inicio TIME,
	Horario_Fin TIME,
	ID_Profesor INT NOT NULL,
	FOREIGN KEY(ID_Profesor) REFERENCES club.Empleado(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'actividades.Asiste', N'U') IS NOT NULL
	DROP TABLE actividades.Asiste
GO

CREATE TABLE actividades.Asiste(
	ID INT Identity(1,1) Primary Key,
	Fecha DATE NOT NULL,
	ID_Socio INT NOT NULL,
	ID_Clase INT NOT NULL,
	FOREIGN KEY(ID_Socio) REFERENCES socios.Socio(ID) ON DELETE CASCADE,
	FOREIGN KEY(ID_Clase) REFERENCES actividades.Clase(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'actividades.Actividad_Extra', N'U') IS NOT NULL
	DROP TABLE actividades.Actividad_Extra
GO

CREATE TABLE actividades.Actividad_Extra(
	ID INT Identity(1,1) Primary Key,
--Probablemente vaya fecha pero no está en el DER
	Tipo VARCHAR(20) NOT NULL,
);

IF OBJECT_ID(N'actividades.Reserva_SUM', N'U') IS NOT NULL
	DROP TABLE actividades.Reserva_SUM
GO

CREATE TABLE actividades.Reserva_SUM(
	ID INT Identity(1,1) Primary Key,
	Horario_Inicio TIME NOT NULL,
	Horario_Fin TIME NOT NULL,
	Monto_De_Reserva NUMERIC(10,2),
	ID_Actividad_Extra INT,
	FOREIGN KEY(ID_Actividad_Extra) REFERENCES actividades.Actividad_Extra(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'actividades.Colonia', N'U') IS NOT NULL
	DROP TABLE actividades.Colonia
GO

CREATE TABLE actividades.Colonia(
	ID INT Identity(1,1) Primary Key,
	Importe NUMERIC(10,2),
	ID_Actividad_Extra INT,
	FOREIGN KEY(ID_Actividad_Extra) REFERENCES actividades.Actividad_Extra(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'tesoreria.Tarifa_Pileta', N'U') IS NOT NULL
	DROP TABLE tesoreria.Tarifa_Pileta
GO

CREATE TABLE tesoreria.Tarifa_Pileta(
    ID INT IDENTITY(1,1) Primary Key,
	Descripcion VARCHAR(100),
    Importe NUMERIC(10,2) NOT NULL,
    Vigente_Hasta DATE
);

IF OBJECT_ID(N'actividades.Pileta', N'U') IS NOT NULL
	DROP TABLE actividades.Pileta
GO

CREATE TABLE actividades.Pileta(
	ID INT Identity(1,1) Primary Key,
--Seguramente va fecha acá
	ID_Tarifa_Pileta INT,
	ID_Actividad_Extra INT,
	FOREIGN KEY(ID_Tarifa_Pileta) REFERENCES tesoreria.Tarifa_Pileta(ID) ON DELETE CASCADE,
	FOREIGN KEY(ID_Actividad_Extra) REFERENCES actividades.Actividad_Extra(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'socios.Invitado', N'U') IS NOT NULL
	DROP TABLE socios.Invitado
GO

CREATE TABLE socios.Invitado(
	ID INT Identity(1,1) Primary Key,
	ID_Pileta INT,
	FOREIGN KEY(ID_Pileta) REFERENCES actividades.Pileta(ID) ON DELETE CASCADE,
);

IF OBJECT_ID(N'socios.Invita', N'U') IS NOT NULL
	DROP TABLE socios.Invita
GO

CREATE TABLE socios.Invita(
	ID INT Identity(1,1) Primary Key,
	Fecha_De_Invitacion DATE NOT NULL,
	ID_Socio INT NOT NULL,
	ID_Invitado INT NOT NULL,
	FOREIGN KEY(ID_Socio) REFERENCES socios.Socio(ID) ON DELETE CASCADE,
	FOREIGN KEY(ID_Invitado) REFERENCES socios.Invitado(ID) ON DELETE CASCADE
);