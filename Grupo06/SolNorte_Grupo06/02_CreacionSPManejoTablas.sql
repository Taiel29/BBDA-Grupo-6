--En este script se realiza la creación de los Store Procedure para manejar la verificación, inserción, y borrado de tablas

--Fecha de entrega: 24/06/2025
--Comisión: 2900
--Grupo: 6
--Base de datos Aplicada
--Integrantes:
--Fariello Ramiro - DNI: 46124109
--Rojas Taiel Ezequiel - DNI: 46183434
--Cropalati Franco Nicolas - DNI: 43404823

USE Com2900G06
GO

CREATE OR ALTER PROCEDURE tesoreria.Insert_Medio_Pago
    @Descripcion VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON
    SET @Descripcion = UPPER(@Descripcion);

    IF @Descripcion IS NULL OR ltrim(rtrim(@Descripcion)) = ''
        RAISERROR('No se inserta medio de pago vacío.', 10, 1);
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM tesoreria.Medio_Pago WHERE Descripcion = @Descripcion)
        BEGIN
            INSERT INTO tesoreria.Medio_Pago (Descripcion)
            VALUES (@Descripcion);
            RAISERROR('Nuevo medio de pago registrado.', 10, 1);
        END
        ELSE
            RAISERROR('El medio de pago ya existe.', 10, 1);
    END
END
GO
-------------------
CREATE OR ALTER PROCEDURE tesoreria.Insert_Estado_Factura
    @Descripcion VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON
    SET @Descripcion = UPPER(@Descripcion);

    IF @Descripcion IS NULL OR ltrim(rtrim(@Descripcion)) = ''
        RAISERROR('No se inserta estado de factura vacío', 10, 1);
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM tesoreria.Estado_Factura WHERE Descripcion = @Descripcion)
        BEGIN
            INSERT INTO tesoreria.Estado_Factura(Descripcion)
            VALUES (@Descripcion);
            RAISERROR('Nuevo estado de factura registrado', 10, 1)
        END
        ELSE
            RAISERROR('El estado de factura ya existe', 10, 1)
    END
END
GO
--------------------------
CREATE OR ALTER PROCEDURE actividades.Insert_Actividad
    @Descripcion VARCHAR(20),
    @IDTarifa INT
AS
BEGIN
    SET NOCOUNT ON
    SET @Descripcion = ltrim(rtrim(@Descripcion))
    SET @Descripcion = UPPER(LEFT(@Descripcion, 1)) + LOWER(SUBSTRING(@Descripcion, 2, LEN(@Descripcion)))

    IF @Descripcion IS NULL OR @Descripcion = ''
        RAISERROR('No se inserta actividad vacía', 10, 1)
    ELSE
    BEGIN
        IF (@IDTarifa IS NULL OR @IDTarifa = '' OR @IDTarifa < 0) OR NOT EXISTS (SELECT 1 FROM tesoreria.Tarifa_Actividad WHERE ID = @IDTarifa)
            RAISERROR('Valor de tarifa inválido', 10, 1)
        ELSE
            IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE Descripcion = @Descripcion COLLATE Modern_Spanish_CI_AI)
            BEGIN
                INSERT INTO actividades.Actividad(Descripcion, ID_Tarifa)
                VALUES (@Descripcion, @IDTarifa);
                RAISERROR('Nueva actividad registrada', 10, 1)
            END
            ELSE
                RAISERROR('La actividad ya existe', 10, 1)
    END
END
GO
-------------------------------------
CREATE OR ALTER PROCEDURE tesoreria.Insert_Medio_Pago
    @Descripcion VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON
    SET @Descripcion = UPPER(@Descripcion);

    IF @Descripcion IS NULL OR ltrim(rtrim(@Descripcion)) = ''
        RAISERROR('No se inserta medio de pago vacío', 10,1)
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM tesoreria.Medio_Pago WHERE Descripcion = @Descripcion)
        BEGIN
            INSERT INTO tesoreria.Medio_Pago (Descripcion)
            VALUES (@Descripcion);
            RAISERROR('Nuevo medio de pago registrado',10,1)
        END
        ELSE
            RAISERROR('El medio de pago ya existe',10,1)
    END
END
GO
----------------------------------
CREATE OR ALTER PROCEDURE tesoreria.Insert_Tarifa_Actividad
    @Valor NUMERIC(10,2),
    @Fecha DATE
AS
BEGIN
    SET NOCOUNT ON

    IF @Valor IS NULL OR @Valor < 0
        RAISERROR('Valor de tarifa negativo o inexistente',10,1)
    ELSE
    BEGIN
        IF @Fecha IS NULL OR @Fecha < GETDATE()
            RAISERROR('Fecha de vigencia nula o menor a la fecha actual',10,1)
        ELSE
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM tesoreria.Tarifa_Actividad ta WHERE ta.Importe_Por_Mes = @Valor AND ta.Vigente_Hasta = @Fecha)
                BEGIN
                    INSERT INTO tesoreria.Tarifa_Actividad (Importe_Por_Mes, Vigente_Hasta)
                    VALUES (@Valor, @Fecha);
                    RAISERROR('Nueva tarifa registrada',10,1)
                END
                ELSE
                    RAISERROR('La tarifa ya existe',10,1)
            END
    END
END
GO
----------------------------

CREATE OR ALTER PROCEDURE actividades.Update_Actividad_Tarifa
    @Descripcion VARCHAR(20),
    @IDTarifa INT
AS
BEGIN
    SET NOCOUNT ON
    SET @Descripcion = ltrim(rtrim(@Descripcion))
    SET @Descripcion = UPPER(LEFT(@Descripcion, 1)) + LOWER(SUBSTRING(@Descripcion, 2, LEN(@Descripcion)))

    IF @Descripcion IS NULL OR @Descripcion = ''
        RAISERROR('No se acepta actividad vacía',10,1)
    ELSE
    BEGIN
        IF (@IDTarifa IS NULL OR @IDTarifa = '' OR @IDTarifa < 0) OR NOT EXISTS (SELECT 1 FROM tesoreria.Tarifa_Actividad WHERE ID = @IDTarifa)
            RAISERROR('Valor de tarifa inválido',10,1)
        ELSE
        BEGIN
            IF EXISTS (SELECT 1 FROM actividades.Actividad WHERE Descripcion = @Descripcion COLLATE Modern_Spanish_CI_AI)
            BEGIN
                UPDATE actividades.Actividad
                SET ID_Tarifa = @IDTarifa
                WHERE Descripcion = @Descripcion COLLATE Modern_Spanish_CI_AI
                RAISERROR('Nueva tarifa actualizada',10,1)
            END
            ELSE
                RAISERROR('La actividad no existe',10,1)
        END
    END
END
GO

CREATE OR ALTER PROCEDURE tesoreria.Insert_Factura
    @FechaEmision DATE,
    @HoraEmision TIME,
    @Importe DECIMAL(10,2),
    @ID_Factura INT OUTPUT

AS
BEGIN
    SET NOCOUNT ON;

    IF (@Importe IS NULL OR @Importe < 0)
    BEGIN
        RAISERROR('El importe no puede ser negativo.', 10, 1);
        RETURN;
    END

    INSERT INTO tesoreria.Factura (
        PDV,
        Numero,
        Fecha_Emision,
        Hora_Emision,
        Importe,
        Fecha_Primer_Vencimiento,
        Fecha_Segundo_Vencimiento,
        ID_Recargo,
        ID_Estado,
        ID_Pago
    )
    VALUES (
        1,              
        1,              
        @FechaEmision,
        @HoraEmision,
        @Importe,
        DATEADD(DAY, 5, @FechaEmision),            
        DATEADD(DAY, 10, @FechaEmision),             
        NULL,              
        2,                
        NULL              
    );
    SET @ID_Factura = SCOPE_IDENTITY();

    RAISERROR ('Factura insertada con éxito.',10,1);
END;
GO
----------------------------------
CREATE OR ALTER PROCEDURE actividades.Insert_Inscripcion_Pileta
    @NroSocio CHAR(8),
    @TipoPase VARCHAR(50),
    @Fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    SET @TipoPase = ltrim(rtrim(UPPER(@TipoPase)))

    DECLARE @ID_Socio INT,
            @FechaNacimiento DATE,
            @Edad INT,
            @ID_Pileta INT,
            @ID_Tarifa_Pileta INT,
            @ID_Actividad_Extra INT,
            @ID_Factura INT,
            @ImporteFactura DECIMAL(10,2),
            @FechaEmision DATE,
            @HoraEmision TIME;

    SELECT @ID_Socio = ID,
           @FechaNacimiento = ss.Fecha_Nacimiento
    FROM socios.Socio ss
    WHERE Nro_Socio = @NroSocio;

    IF @ID_Socio IS NULL
    BEGIN
        RAISERROR('El número de socio no existe.',10,1);
        RETURN;
    END

    SET @Edad = DATEDIFF(YEAR, @FechaNacimiento, @Fecha);
    IF MONTH(@FechaNacimiento) > MONTH(@Fecha) OR 
       (MONTH(@FechaNacimiento) = MONTH(@Fecha) AND DAY(@FechaNacimiento) > DAY(@Fecha))
    BEGIN
        SET @Edad = @Edad - 1;
    END

    SET @ID_Tarifa_Pileta = 
        CASE 
            WHEN UPPER(@TipoPase) = 'DIARIO'    AND @Edad < 12 THEN 2
            WHEN UPPER(@TipoPase) = 'DIARIO'    AND @Edad >= 12 THEN 1
            WHEN UPPER(@TipoPase) = 'TEMPORADA' AND @Edad < 12 THEN 4
            WHEN UPPER(@TipoPase) = 'TEMPORADA' AND @Edad >= 12 THEN 3
            WHEN UPPER(@TipoPase) = 'MENSUAL'   AND @Edad < 12 THEN 6
            WHEN UPPER(@TipoPase) = 'MENSUAL'   AND @Edad >= 12 THEN 5
            ELSE NULL
        END;

    IF @ID_Tarifa_Pileta IS NULL
    BEGIN
        RAISERROR('Tipo de pase inválido. Debe ser Diario, Mensual o Temporada.',10,1);
        RETURN;
    END
    
    SELECT @ImporteFactura = tp.Importe FROM tesoreria.Tarifa_Pileta tp WHERE tp.ID = @ID_Tarifa_Pileta;

    IF EXISTS (
        SELECT 1
        FROM actividades.Inscripcion i
            INNER JOIN actividades.Actividad_Extra ae ON ae.ID = i.ID_Actividad_Extra
            INNER JOIN actividades.Pileta p ON p.ID = ae.ID_Pileta
        WHERE 
            i.ID_Socio = @ID_Socio
            AND i.Fecha = @Fecha
            AND p.ID_Tarifa_Pileta = @ID_Tarifa_Pileta
    )
    BEGIN
        RAISERROR('Ya existe una inscripción de este tipo de pase para este socio en esta fecha.',10,1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM tesoreria.Tarifa_Pileta tf WHERE tf.ID = @ID_Tarifa_Pileta AND tf.Vigente_Hasta >= @Fecha)
    BEGIN
        RAISERROR('No se encontró una tarifa vigente con el ID proporcionado.',10,1);
        RETURN;
    END

    INSERT INTO actividades.Pileta (ID_Tarifa_Pileta)
    VALUES (@ID_Tarifa_Pileta);

    SET @ID_Pileta = SCOPE_IDENTITY();
    
    INSERT INTO actividades.Actividad_Extra (Tipo, ID_Pileta)
    VALUES ('PILETA', @ID_Pileta);

    SET @ID_Actividad_Extra = SCOPE_IDENTITY();

    SET @FechaEmision = CAST(GETDATE() AS DATE);
    SET @HoraEmision = CAST(GETDATE() AS TIME)

    EXEC tesoreria.Insert_Factura
        @FechaEmision,
        @HoraEmision,
        @Importe = @ImporteFactura,
        @ID_Factura = @ID_Factura OUTPUT;

    INSERT INTO actividades.Inscripcion (
        Fecha, Tipo, ID_Socio, ID_Actividad_Extra
    )
    VALUES (
        @Fecha, 'PILETA '+ @TipoPase, @ID_Socio, @ID_Actividad_Extra
    );

    RAISERROR('Inscripción realizada con éxito.',10,1)
END
GO

