--En este script se realiza la creación de la base de datos y las tablas contenidas en esta junto con sus restricciones

--Fecha de entrega: 17/06/2025
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

	ALTER DATABASE Com2900G06
	SET SINGLE_USER
	WITH ROLLBACK IMMEDIATE;

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

IF SCHEMA_ID(N'importaciones') IS NULL
    EXEC('CREATE SCHEMA importaciones');

IF SCHEMA_ID(N'reportes') IS NULL
    EXEC('CREATE SCHEMA reportes');
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
	ID INT IDENTITY(1,1) Primary Key,
	Nro_Socio CHAR(7) UNIQUE,
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
	CONSTRAINT CK_ID_SOCIO CHECK (ID LIKE '[A-Z][A-Z]-[0-9][0-9][0-9][0-9]')
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
	DNI CHAR(9),
	Fecha_Nacimiento DATE,
	Nombre VARCHAR(50) NOT NULL,
	Apellido VARCHAR(50) NOT NULL,
	Area VARCHAR(20),
	Telefono_De_Contacto INT,
	Telefono_De_Emergencia INT
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

IF OBJECT_ID(N'tesoreria.Medio_Pago', N'U') IS NOT NULL
	DROP TABLE tesoreria.Medio_Pago
GO

CREATE TABLE tesoreria.Medio_Pago(
	ID INT IDENTITY(1,1) PRIMARY KEY
	--Capaz habría que meter otro atributo
);

IF OBJECT_ID(N'tesoreria.Tarjeta', N'U') IS NOT NULL
	DROP TABLE tesoreria.Tarjeta
GO

CREATE TABLE tesoreria.Tarjeta(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Banco VARCHAR(100),
	Tipo_Tarjeta VARCHAR(50),
	Nombre_Titular VARCHAR(100),
	Numero_Tarjeta VARCHAR(50),
	ID_Medio_Pago INT NOT NULL,
	FOREIGN KEY (ID_Medio_Pago) REFERENCES tesoreria.Medio_Pago(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'tesoreria.Transferencia', N'U') IS NOT NULL
	DROP TABLE tesoreria.Transferencia
GO

CREATE TABLE tesoreria.Transferencia(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Nombre_Titular VARCHAR(100),
	CVU VARCHAR(50),
	ID_Medio_Pago INT NOT NULL,
	FOREIGN KEY (ID_Medio_Pago) REFERENCES tesoreria.Medio_Pago(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'tesoreria.Sucursal_Pago', N'U') IS NOT NULL
	DROP TABLE tesoreria.Sucursal_Pago
GO

CREATE TABLE tesoreria.Sucursal_Pago(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Direccion VARCHAR(100),
	Red_Pago VARCHAR(50),
	Nombre_Local VARCHAR(50),
	ID_Medio_Pago INT NOT NULL,
	FOREIGN KEY (ID_Medio_Pago) REFERENCES tesoreria.Medio_Pago(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'tesoreria.Debito_Automatico', N'U') IS NOT NULL
	DROP TABLE tesoreria.Debito_Automatico
GO

CREATE TABLE tesoreria.Debito_Automatico(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Banco VARCHAR(100),
	Numero_Tarjeta VARCHAR(50),
	Nombre_Titular VARCHAR(50),
	ID_Medio_Pago INT NOT NULL,
	FOREIGN KEY (ID_Medio_Pago) REFERENCES tesoreria.Medio_Pago(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'socios.Cuenta_Utilizo_Medio_De_Pago', N'U') IS NOT NULL
	DROP TABLE socios.Cuenta_Utilizo_Medio_De_Pago
GO

CREATE TABLE socios.Cuenta_Utilizo_Medio_De_Pago (
	ID_Cuenta INT UNIQUE,
	ID_Medio_De_Pago INT,
	FOREIGN KEY(ID_Cuenta) REFERENCES socios.Cuenta(ID) ON DELETE CASCADE,
	FOREIGN KEY(ID_medio_de_pago) REFERENCES tesoreria.Medio_Pago(ID) ON DELETE CASCADE
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
    Vigente_Hasta DATE,
	CONSTRAINT CK_TarifaVigente UNIQUE (Importe_Por_Mes, Vigente_Hasta)
);

IF OBJECT_ID(N'actividades.Actividad', N'U') IS NOT NULL
	DROP TABLE actividades.Actividad
GO

CREATE TABLE actividades.Actividad(
	ID INT Identity(1,1) Primary Key,
    Descripcion VARCHAR(50) NOT NULL,
    ID_Tarifa INT NOT NULL,
	FOREIGN KEY(ID_Tarifa) REFERENCES tesoreria.Tarifa_Actividad(ID) ON DELETE CASCADE,
	CONSTRAINT CK_Actividad_Descripcion_Tarifa UNIQUE (Descripcion, ID_Tarifa)
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
	ID_Actividad INT NOT NULL,
	FOREIGN KEY(ID_Profesor) REFERENCES club.Empleado(ID) ON DELETE CASCADE,
	FOREIGN KEY(ID_Actividad) REFERENCES actividades.Actividad(ID) ON DELETE CASCADE

);

IF OBJECT_ID(N'actividades.Socio_Asiste_Clase', N'U') IS NOT NULL
	DROP TABLE actividades.Socio_Asiste_Clase
GO

CREATE TABLE actividades.Socio_Asiste_Clase(
	ID INT Identity(1,1) Primary Key,
	Fecha DATE NOT NULL,
	Asiste CHAR NOT NULL,
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

CREATE TABLE socios.Socio_Invita_Invitado(
	ID INT Identity(1,1) Primary Key,
	Fecha_De_Invitacion DATE NOT NULL,
	ID_Socio INT NOT NULL,
	ID_Invitado INT NOT NULL,
	FOREIGN KEY(ID_Socio) REFERENCES socios.Socio(ID) ON DELETE CASCADE,
	FOREIGN KEY(ID_Invitado) REFERENCES socios.Invitado(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'tesoreria.Estado_Factura', N'U') IS NOT NULL
	DROP TABLE tesoreria.Estado_Factura
GO

CREATE TABLE tesoreria.Estado_Factura(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Descripcion VARCHAR(50)
);

IF OBJECT_ID(N'tesoreria.Pago', N'U') IS NOT NULL
	DROP TABLE tesoreria.Pago
GO

CREATE TABLE tesoreria.Pago(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Fecha_Pago DATE,
	Hora_Pago TIME
);

IF OBJECT_ID(N'tesoreria.Recargo', N'U') IS NOT NULL
	DROP TABLE tesoreria.Recargo
GO

CREATE TABLE tesoreria.Recargo(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Porcentaje DECIMAL(5,2) CHECK(Porcentaje >= 0 AND Porcentaje <= 100),
	Cantidad_Dias_Desde_Vencimiento INT
);

IF OBJECT_ID(N'tesoreria.Factura', N'U') IS NOT NULL
	DROP TABLE tesoreria.Factura
GO

CREATE TABLE tesoreria.Factura(
	ID INT IDENTITY (1,1) PRIMARY KEY,
	PDV INT,
	Numero INT,
	Fecha_Emision DATE,
	Hora_Emision TIME,
	Importe DECIMAL(10,2),
	Fecha_Primer_Vencimiento DATE,
	Fecha_Segundo_Vencimiento DATE,
	ID_Recargo INT,
	ID_Estado INT,
	ID_Pago INT,
	FOREIGN KEY (ID_Recargo) REFERENCES tesoreria.Recargo(ID) ON DELETE CASCADE,
	FOREIGN KEY (ID_Estado) REFERENCES tesoreria.Estado_Factura(ID) ON DELETE CASCADE,
	FOREIGN KEY (ID_Pago) REFERENCES tesoreria.Pago(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'tesoreria.Detalle_Factura', N'U') IS NOT NULL
	DROP TABLE tesoreria.Detalle_Factura
GO

CREATE TABLE tesoreria.Detalle_Factura(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Subtotal DECIMAL(10,2),
	ID_Inscripcion INT NOT NULL,
	FOREIGN KEY (ID_Inscripcion) REFERENCES actividades.Inscripcion(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'tesoreria.Tipo_Reembolso', N'U') IS NOT NULL
	DROP TABLE tesoreria.Tipo_Reembolso
GO

CREATE TABLE tesoreria.Tipo_Reembolso(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Descripcion VARCHAR(100),
	Porcentaje DECIMAL(5,2) CHECK(Porcentaje >= 0 AND Porcentaje <= 100)
);

IF OBJECT_ID(N'tesoreria.Reembolso', N'U') IS NOT NULL
	DROP TABLE tesoreria.Reembolso
GO

CREATE TABLE tesoreria.Reembolso(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	ID_Pago INT,
	ID_Tipo INT,
	ID_Cuenta INT,
	FOREIGN KEY (ID_Pago) REFERENCES tesoreria.Pago(ID) ON DELETE CASCADE,
	FOREIGN KEY (ID_Tipo) REFERENCES tesoreria.Tipo_Reembolso(ID) ON DELETE CASCADE,
	FOREIGN KEY (ID_Cuenta) REFERENCES socios.Cuenta(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'tesoreria.Descuento', N'U') IS NOT NULL
	DROP TABLE tesoreria.Descuento
GO

CREATE TABLE tesoreria.Descuento(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Descripcion VARCHAR(100),
	Porcentaje DECIMAL(5,2) CHECK(Porcentaje >= 0 AND Porcentaje <= 100)
);

IF OBJECT_ID(N'tesoreria.Descuento_Aplicado_Factura', N'U') IS NOT NULL
	DROP TABLE tesoreria.Descuento_Aplicado_Factura
GO

CREATE TABLE tesoreria.Descuento_Aplicado_Factura(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	ID_Descuento INT NOT NULL,
	ID_Factura INT NOT NULL,
	FOREIGN KEY (ID_Descuento) REFERENCES tesoreria.Descuento(ID) ON DELETE CASCADE,
	FOREIGN KEY (ID_Factura) REFERENCES tesoreria.Factura(ID) ON DELETE CASCADE
);

IF OBJECT_ID(N'tesoreria.Cuota', N'U') IS NOT NULL
	DROP TABLE tesoreria.Cuota
GO

CREATE TABLE tesoreria.Cuota(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Fecha_Inicio DATE,
	Fecha_Final DATE,
	Mes INT,
	ID_Socio INT,
	ID_Factura INT,
	FOREIGN KEY (ID_Socio) REFERENCES socios.Socio (ID) ON DELETE CASCADE,
	FOREIGN KEY (ID_Factura) REFERENCES tesoreria.Factura(ID) ON DELETE CASCADE
);
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

CREATE TRIGGER club.trg_Empleado_Encrypt
ON club.Empleado
AFTER INSERT
AS
BEGIN
		-- Encriptar y actualizar las columnas encriptadas
		UPDATE emp
		SET 
			emp.Nombre_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', i.Nombre),
			emp.Apellido_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', i.Apellido),
			emp.DNI_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', i.DNI),
			emp.Fecha_Nacimiento_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', CONVERT(VARCHAR, i.Fecha_Nacimiento, 23)),
			emp.Area_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', i.Area),
			emp.Telefono_De_Contacto_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', CAST(i.Telefono_De_Contacto AS VARCHAR)),
			emp.Telefono_De_Emergencia_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', CAST(i.Telefono_De_Emergencia AS VARCHAR))
		FROM club.Empleado emp
		INNER JOIN inserted i ON emp.ID = i.ID;

		-- esto es opcional.
		UPDATE emp
		SET 
			emp.Nombre = NULL,
			emp.Apellido = NULL,
			emp.DNI = NULL,
			emp.Fecha_De_Nacimiento = NULL,
			emp.Area = NULL,
			emp.Telefono_De_Contacto = NULL,
			emp.Telefono_De_Emergencia = NULL
		FROM club.Empleado emp
		INNER JOIN inserted i ON emp.ID = i.ID;
END;
PRINT 'TRIGGER CREADO CORRECTAMENTE';

GO

-- AGREGO CAMPOS A ENCRIPTAR PARA NO PISAR LOS DATOS ORIGINALES (socio)

-- ================== IDENTIFICADORES ==================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'socios' AND TABLE_NAME = 'Socio' AND COLUMN_NAME = 'Nro_Socio_Enc')
    ALTER TABLE socios.Socio ADD Nro_Socio_Enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'socios' AND TABLE_NAME = 'Socio' AND COLUMN_NAME = 'DNI_Enc')
    ALTER TABLE socios.Socio ADD DNI_Enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'socios' AND TABLE_NAME = 'Socio' AND COLUMN_NAME = 'Numero_De_Socio_OS_Enc')
    ALTER TABLE socios.Socio ADD Numero_De_Socio_OS_Enc VARBINARY(MAX);

-- ================== INFORMACIÓN PERSONAL =============
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'socios' AND TABLE_NAME = 'Socio' AND COLUMN_NAME = 'Fecha_Nacimiento_Enc')
    ALTER TABLE socios.Socio ADD Fecha_Nacimiento_Enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'socios' AND TABLE_NAME = 'Socio' AND COLUMN_NAME = 'Apellido_Enc')
    ALTER TABLE socios.Socio ADD Apellido_Enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'socios' AND TABLE_NAME = 'Socio' AND COLUMN_NAME = 'Nombre_Enc')
    ALTER TABLE socios.Socio ADD Nombre_Enc VARBINARY(MAX);

-- ================== CONTACTO =========================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'socios' AND TABLE_NAME = 'Socio' AND COLUMN_NAME = 'Telefono_De_Emergencias_OS_Enc')
    ALTER TABLE socios.Socio ADD Telefono_De_Emergencias_OS_Enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'socios' AND TABLE_NAME = 'Socio' AND COLUMN_NAME = 'Telefono_Contacto_Emergencia_Enc')
    ALTER TABLE socios.Socio ADD Telefono_Contacto_Emergencia_Enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'socios' AND TABLE_NAME = 'Socio' AND COLUMN_NAME = 'Nombre_Obra_Social_Enc')
    ALTER TABLE socios.Socio ADD Nombre_Obra_Social_Enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'socios' AND TABLE_NAME = 'Socio' AND COLUMN_NAME = 'Telefono_Contacto_Enc')
    ALTER TABLE socios.Socio ADD Telefono_Contacto_Enc VARBINARY(MAX);
GO


IF EXISTS (SELECT 1 FROM sys.triggers WHERE name='trg_Socio_Encrypt')
    DROP TRIGGER socios.trg_Socio_Encrypt;
GO

CREATE TRIGGER socios.trg_Socio_Encrypt
ON socios.Socio
AFTER INSERT
AS
BEGIN
    -- Encriptar y actualizar las columnas encriptadas
    UPDATE soc
    SET 
        soc.Nro_Socio_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', i.Nro_Socio),
        soc.DNI_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', i.DNI),
        soc.Numero_De_Socio_OS_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', i.Numero_De_Socio_OS),
        soc.Fecha_Nacimiento_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', CONVERT(VARCHAR, i.Fecha_Nacimiento, 23)),
        soc.Nombre_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', i.Nombre),
        soc.Apellido_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', i.Apellido),
        soc.Nombre_Obra_Social_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', i.Nombre_Obra_Social),
        soc.Telefono_De_Emergencias_OS_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', CAST(i.Telefono_De_Emergencias_OS AS VARCHAR)),
        soc.Telefono_Contacto_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', CAST(i.Telefono_Contacto AS VARCHAR)),
        soc.Telefono_Contacto_Emergencia_Enc = ENCRYPTBYPASSPHRASE('EkAHYL]cv92=#Z!1EuDH', CAST(i.Telefono_Contacto_Emergencia AS VARCHAR))
    FROM socios.Socio soc
    INNER JOIN inserted i ON soc.ID = i.ID;

	-- esto es opcional. 
	UPDATE soc
	SET 
		soc.Nro_Socio = NULL,
		soc.DNI = NULL,
		soc.Numero_De_Socio_OS = NULL,
		soc.Fecha_Nacimiento = NULL,
		soc.Nombre = NULL,
		soc.Apellido = NULL,
		soc.Nombre_Obra_Social = NULL,
		soc.Telefono_De_Emergencias_OS = NULL,
		soc.Telefono_Contacto = NULL,
		soc.Telefono_Contacto_Emergencia = NULL
	FROM socios.Socio soc
	INNER JOIN inserted i ON soc.ID = i.ID;
END;
PRINT 'TRIGGER CREADO CORRECTAMENTE';
GO


/* DESENCRIPTAR TABLA EMPLEADO Y MOSTRAR

password = EkAHYL]cv92=#Z!1EuDH

SELECT 
	ID AS id_empleado,
	CONVERT(VARCHAR, DECRYPTBYPASSPHRASE('password', Nombre_Enc)) AS Nombre,
	CONVERT(VARCHAR, DECRYPTBYPASSPHRASE('password', Apellido_Enc)) AS Apellido,
	CONVERT(CHAR(9), DECRYPTBYPASSPHRASE('password', DNI_Enc)) AS DNI,
	CONVERT(DATE, DECRYPTBYPASSPHRASE('password', Fecha_Nacimiento_Enc)) AS Fecha_Nacimiento,
	CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE('password', Area_Enc)) AS Area,
	CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE('password', Telefono_De_Contacto_Enc)) AS Telefono_De_Contacto,
	CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE('password', Telefono_De_Emergencia_Enc)) AS Telefono_De_Emergencia
FROM club.Empleado;

	DESENCRIPTAR TABLA EMPLEADO Y MOSTRAR
SELECT 
	ID AS id_socio,
	CONVERT(CHAR(7), DECRYPTBYPASSPHRASE('password', Nro_Socio_Enc)) AS Nro_Socio,
	CONVERT(CHAR(9), DECRYPTBYPASSPHRASE('password', DNI_Enc)) AS DNI,
	CONVERT(INT, DECRYPTBYPASSPHRASE('password', Numero_De_Socio_OS_Enc)) AS Numero_De_Socio_OS,
	CONVERT(DATE, DECRYPTBYPASSPHRASE('password', Fecha_Nacimiento_Enc)) AS Fecha_Nacimiento,
	CONVERT(VARCHAR(50), DECRYPTBYPASSPHRASE('password', Nombre_Enc)) AS Nombre,
	CONVERT(VARCHAR(50), DECRYPTBYPASSPHRASE('password', Apellido_Enc)) AS Apellido,
	CONVERT(VARCHAR(50), DECRYPTBYPASSPHRASE('password', Nombre_Obra_Social_Enc)) AS Nombre_Obra_Social,
	CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE('password', Telefono_De_Emergencias_OS_Enc)) AS Telefono_De_Emergencias_OS,
	CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE('password', Telefono_Contacto_Emergencia_Enc)) AS Telefono_Contacto_Emergencia,
	CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE('password', Telefono_Contacto_Enc)) AS Telefono_Contacto
FROM socios.Socio;

*/