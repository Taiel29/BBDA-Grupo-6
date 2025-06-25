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
        Print('No se inserta medio de pago vacío')
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM tesoreria.Medio_Pago WHERE Descripcion = @Descripcion)
        BEGIN
            INSERT INTO tesoreria.Medio_Pago (Descripcion)
            VALUES (@Descripcion);
            Print('Nuevo medio de pago registrado')
        END
        ELSE
            Print('El medio de pago ya existe')
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
        Print('No se inserta estado de factura vacío')
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM tesoreria.Estado_Factura WHERE Descripcion = @Descripcion)
        BEGIN
            INSERT INTO tesoreria.Estado_Factura(Descripcion)
            VALUES (@Descripcion);
            Print('Nuevo estado de factura registrado')
        END
        ELSE
            Print('El estado de factura ya existe')
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
        Print('No se inserta actividad vacía')
    ELSE
    BEGIN
        IF (@IDTarifa IS NULL OR @IDTarifa = '' OR @IDTarifa < 0) OR NOT EXISTS (SELECT 1 FROM tesoreria.Tarifa_Actividad WHERE ID = @IDTarifa)
            Print('Valor de tarifa inválido')
        ELSE
            IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE Descripcion = @Descripcion COLLATE Modern_Spanish_CI_AI)
            BEGIN
                INSERT INTO actividades.Actividad(Descripcion, ID_Tarifa)
                VALUES (@Descripcion, @IDTarifa);
                Print('Nueva actividad registrada')
            END
            ELSE
                Print('La actividad ya existe')
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
        Print('No se inserta medio de pago vacío')
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM tesoreria.Medio_Pago WHERE Descripcion = @Descripcion)
        BEGIN
            INSERT INTO tesoreria.Medio_Pago (Descripcion)
            VALUES (@Descripcion);
            Print('Nuevo medio de pago registrado')
        END
        ELSE
            Print('El medio de pago ya existe')
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
        Print('Valor de tarifa negativo o inexistente')
    ELSE
    BEGIN
        IF @Fecha IS NULL OR @Fecha < GETDATE()
            Print('Fecha de vigencia nula o menor a la fecha actual')
        ELSE
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM tesoreria.Tarifa_Actividad ta WHERE ta.Importe_Por_Mes = @Valor AND ta.Vigente_Hasta = @Fecha)
                BEGIN
                    INSERT INTO tesoreria.Tarifa_Actividad (Importe_Por_Mes, Vigente_Hasta)
                    VALUES (@Valor, @Fecha);
                    Print('Nueva tarifa registrada')
                END
                ELSE
                    Print('La tarifa ya existe')
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
        Print('No se acepta actividad vacía')
    ELSE
    BEGIN
        IF (@IDTarifa IS NULL OR @IDTarifa = '' OR @IDTarifa < 0) OR NOT EXISTS (SELECT 1 FROM tesoreria.Tarifa_Actividad WHERE ID = @IDTarifa)
            Print('Valor de tarifa inválido')
        ELSE
        BEGIN
            IF EXISTS (SELECT 1 FROM actividades.Actividad WHERE Descripcion = @Descripcion COLLATE Modern_Spanish_CI_AI)
            BEGIN
                UPDATE actividades.Actividad
                SET ID_Tarifa = @IDTarifa
                WHERE Descripcion = @Descripcion COLLATE Modern_Spanish_CI_AI
                Print('Nueva tarifa actualizada')
            END
            ELSE
                Print('La actividad no existe')
        END
    END
END
GO

----------------------------------
CREATE OR ALTER PROCEDURE actividades.Insert_Inscripcion_Pileta
    @NroSocio CHAR(8),
    @IDTarifa VARCHAR(100),
    @Fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ID_Socio INT,
            @ID_Tarifa_Pileta INT,
            @ID_Actividad_Extra INT

    SELECT @ID_Socio = ID
    FROM socios.Socio
    WHERE Nro_Socio = @NroSocio;

    IF @ID_Socio IS NULL
    BEGIN
        Print('El número de socio no existe.');
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM tesoreria.Tarifa_Pileta tf WHERE tf.ID = @IDTarifa AND tf.Vigente_Hasta >= @Fecha)
    BEGIN
        Print('No se encontró una tarifa vigente con la descripción proporcionada.');
        RETURN;
    END

    -- Buscar ID_Actividad_Extra asociado a la tarifa en Pileta
    INSERT INTO actividades.Pileta VALUES (@IDTarifa)
    
    INSERT INTO actividades.Actividad_Extra (Tipo, ID_Pileta)
    SELECT 'Pileta', ap.ID
    FROM actividades.Pileta ap
    WHERE ap.ID_Tarifa_Pileta = @IDTarifa

    SELECT @ID_Actividad_Extra = ID
    FROM actividades.Actividad_Extra AE
    WHERE Tipo = 'Pileta' AND AE.ID_Pileta = @IDTarifa

    -- Insertar inscripción
    INSERT INTO actividades.Inscripcion (
        Fecha, Tipo, ID_Socio, ID_Actividad_Extra
    )
    VALUES (
        @Fecha, 'Pileta', @ID_Socio, @ID_Actividad_Extra
    );

    PRINT 'Inscripción realizada con éxito.';
END
