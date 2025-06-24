--En este script se realiza la creación de los Store Procedure para manejar la verificación, inserción, y borrado de tablas

--Fecha de entrega: 24/06/2025
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
            IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE Descripcion = @Descripcion)
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