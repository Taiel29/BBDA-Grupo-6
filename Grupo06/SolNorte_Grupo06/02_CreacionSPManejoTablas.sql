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

CREATE OR ALTER PROCEDURE tesoreria.Insert_Recargo
    @DiasDesdeVencimiento INT,
    @Porcentaje NUMERIC(5,2)
AS
BEGIN
    SET NOCOUNT ON

    IF (@Porcentaje > 0)
    BEGIN
        IF (@DiasDesdeVencimiento IS NULL OR @DiasDesdeVencimiento < 0)
            RAISERROR('Se debe proporcionar una cantidad de dias igual o mayor a 0', 10, 1);
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1
                FROM tesoreria.Recargo
                WHERE Cantidad_Dias_Desde_Vencimiento = @DiasDesdeVencimiento)
            BEGIN
                INSERT INTO tesoreria.Recargo(Cantidad_Dias_Desde_Vencimiento, Porcentaje)
                VALUES (@DiasDesdeVencimiento, @Porcentaje);
                RAISERROR('Nuevo recargo registrado.', 10, 1);
            END
            ELSE
                RAISERROR('Ya hay un recargo para esa cantidad de dias', 10, 1);
        END
    END
    ELSE
        RAISERROR('Se debe proporcionar un porcentaje mayor a 0', 10, 1);
END
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

------------------------

CREATE OR ALTER PROCEDURE tesoreria.Insert_Factura
    @FechaEmision DATE,
    @HoraEmision TIME = NULL,
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

    IF (@FechaEmision IS NULL or @FechaEmision = '')
    BEGIN
        RAISERROR('La fecha no puede ser nula', 10, 1);
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
CREATE OR ALTER PROCEDURE tesoreria.Insert_Cuota
@Mes INT,
@Socio INT,
@Importe DECIMAL(10,2),
@ID_Factura INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF (@Mes < 1 OR @Mes > 12)
    BEGIN
        RAISERROR('El mes tiene que estar entre 1 y 12.', 10, 1);
        RETURN;
    END

	DECLARE @SocioExiste INT;
	DECLARE @FechaInicio DATE;

	SET @SocioExiste = (SELECT 1 FROM socios.Socio WHERE ID = @Socio);

	IF(@SocioExiste != 1)
	BEGIN
		RAISERROR('El socio ingresado no existe', 10, 1);
        RETURN;
	END

	SET @FechaInicio = DATEFROMPARTS(YEAR(GETDATE()), @Mes, 1);

	INSERT INTO tesoreria.Cuota (
		Fecha_Inicio,
		Fecha_Final,
		Mes,
		ID_Socio,
		ID_Factura
	)
	VALUES (
		@FechaInicio,
		EOMONTH(@FechaInicio),
		@Mes,
		@Socio,
		NULL
	)

	DECLARE @FechaEmision DATE;
	SET @FechaEmision = DATEFROMPARTS(YEAR(GETDATE()), MONTH(@FechaInicio), DAY(@FechaInicio));

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
        NULL,
        @Importe,
        DATEADD(DAY, 5, @FechaEmision),
        DATEADD(DAY, 10, @FechaEmision),
        NULL,              
        2,                
        NULL              
    );

	UPDATE tesoreria.Cuota SET ID_Factura = (SELECT MAX(ID) FROM tesoreria.Factura)
	WHERE ID = (SELECT MAX(ID) FROM tesoreria.Cuota);

	SET @ID_Factura = (SELECT MAX(ID) FROM tesoreria.Factura);

    RAISERROR ('Cuota con factura insertada con éxito.',10,1);
END;
GO
----------------------------------

CREATE OR ALTER PROCEDURE actividades.Insert_Inscripcion_Pileta
    @NroSocio CHAR(8),
    @TipoPase VARCHAR(50),
    @Fecha DATE,
    @Hora Time = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @TipoPase = ltrim(rtrim(UPPER(@TipoPase)))

    IF (@Fecha IS NULL or @Fecha = '')
    BEGIN
        RAISERROR('La fecha no puede ser nula', 10, 1);
        RETURN;
    END

    DECLARE @ID_Socio INT,
            @FechaNacimiento DATE,
            @Edad INT,
            @ID_Pileta INT,
            @ID_Tarifa_Pileta INT,
            @ID_Actividad_Extra INT,
            @ID_Factura INT,
            @ImporteFactura DECIMAL(10,2),
            @Descripcion VARCHAR(100);

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

    SET @Descripcion = 
    CASE 
        WHEN UPPER(@TipoPase) = 'DIARIO'    AND @Edad < 12 THEN 'Valor del dia Menores de 12 años Socio'
        WHEN UPPER(@TipoPase) = 'DIARIO'    AND @Edad >= 12 THEN 'Valor del dia Adultos Socio'
        WHEN UPPER(@TipoPase) = 'TEMPORADA' AND @Edad < 12 THEN 'Valor de temporada Menores de 12 años Socio'
        WHEN UPPER(@TipoPase) = 'TEMPORADA' AND @Edad >= 12 THEN 'Valor de temporada Adultos Socio'
        WHEN UPPER(@TipoPase) = 'MENSUAL'   AND @Edad < 12 THEN 'Valor del Mes Menores de 12 años Socio'
        WHEN UPPER(@TipoPase) = 'MENSUAL'   AND @Edad >= 12 THEN 'Valor del Mes Adultos Socio'
        ELSE NULL
    END;

    IF @Descripcion IS NULL
    BEGIN
        RAISERROR('Tipo de pase inválido. Debe ser Diario, Mensual o Temporada.',10,1);
        RETURN;
    END

    SELECT TOP 1 @ID_Tarifa_Pileta = ID
    FROM tesoreria.Tarifa_Pileta
    WHERE 
        ltrim(rtrim(Descripcion)) = ltrim(rtrim(@Descripcion))
        AND Vigente_Hasta >= @Fecha
    ORDER BY Vigente_Hasta ASC;

    IF @ID_Tarifa_Pileta IS NULL
    BEGIN
        RAISERROR('No hay tarifa vigente',10,1);
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

    INSERT INTO actividades.Pileta (ID_Tarifa_Pileta)
    VALUES (@ID_Tarifa_Pileta);

    SET @ID_Pileta = SCOPE_IDENTITY();
    
    INSERT INTO actividades.Actividad_Extra (Tipo, ID_Pileta)
    VALUES ('PILETA', @ID_Pileta);

    SET @ID_Actividad_Extra = SCOPE_IDENTITY();

    EXEC tesoreria.Insert_Factura
        @FechaEmision = @Fecha,
        @HoraEmision = @Hora,
        @Importe = @ImporteFactura,
        @ID_Factura = @ID_Factura OUTPUT;

    INSERT INTO actividades.Inscripcion (
        Fecha, Tipo, ID_Socio, ID_Actividad_Extra, ID_Factura
    )
    VALUES (
        @Fecha, 'PILETA '+ @TipoPase, @ID_Socio, @ID_Actividad_Extra, @ID_Factura
    );

    RAISERROR('Inscripción realizada con éxito.',10,1)
END
GO

------------------------

CREATE OR ALTER PROCEDURE tesoreria.Insert_Pago
    @Fecha DATE,
    @Hora TIME = NULL,
    @ID_Medio_De_Pago INT,
    @ID_Pago BIGINT,
    @ID_Factura INT,
    @ID_Pago_Creado INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    IF (@Fecha IS NULL or @Fecha = '')
    BEGIN
        RAISERROR('La fecha no puede ser nula', 10, 1);
        RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM tesoreria.Medio_Pago WHERE ID = @ID_Medio_De_Pago)
    BEGIN
        RAISERROR('No existe medio de pago con ese ID', 10, 1);
        RETURN;
    END

    IF (@ID_Pago IS NULL or @ID_Pago < 0)
    BEGIN
        RAISERROR('ID_Pago no válido (NULL o Negativo)', 10, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM tesoreria.Pago WHERE ID_Pago = @ID_Pago)
    BEGIN
        RAISERROR('El ID_Pago proporcionado ya está en uso', 10, 1);
        RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM tesoreria.Factura WHERE ID = @ID_Factura AND ID_Pago IS NULL)
    BEGIN
        RAISERROR('No hay una factura impaga con esa ID', 10, 1);
        RETURN;
    END

    INSERT INTO tesoreria.Pago (ID_Pago, Fecha_Pago, Hora_Pago, Medio_Pago)
    SELECT @ID_Pago, @Fecha, @Hora, @ID_Medio_De_Pago

    SET @ID_Pago_Creado = SCOPE_IDENTITY();

	IF EXISTS(SELECT 1 FROM tesoreria.Factura WHERE ID = @ID_Factura AND @Fecha > Fecha_Segundo_Vencimiento)
	BEGIN
		UPDATE tesoreria.Factura
		SET ID_Estado = 3,
		ID_Pago = @ID_Pago_Creado
		WHERE ID = @ID_Factura
	END
	ELSE
	BEGIN
		UPDATE tesoreria.Factura
		SET ID_Estado = 1,
		ID_Pago = @ID_Pago_Creado
		WHERE ID = @ID_Factura
	END
    

    IF EXISTS (SELECT 1 FROM tesoreria.Factura WHERE ID = @ID_Factura AND Fecha_Primer_Vencimiento <= @Fecha AND @Fecha <= Fecha_Segundo_Vencimiento)
    BEGIN
        DECLARE @IDRecargo INT

        SELECT TOP 1 @IDRecargo = tr.ID
        FROM tesoreria.Recargo tr
        INNER JOIN tesoreria.Factura tf ON tf.ID = @ID_Factura
        WHERE DATEDIFF(DAY, tf.Fecha_Primer_Vencimiento, @Fecha) >= tr.Cantidad_Dias_Desde_Vencimiento
        ORDER BY tr.Cantidad_Dias_Desde_Vencimiento DESC;

        UPDATE tesoreria.Factura
        SET ID_Recargo = @IDRecargo
        WHERE ID = @ID_Factura
    END
    RAISERROR('Pago guardado correctamente y estado de factura actualizado', 10, 1);
END
GO

CREATE OR ALTER PROCEDURE socios.Insert_Cuentas
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO socios.Cuenta (ID_Socio)
    SELECT s.ID
    FROM socios.Socio s
    WHERE NOT EXISTS (
        SELECT 1
        FROM socios.Cuenta c
        WHERE c.ID_Socio = s.ID
    );
    RAISERROR('Se les ha creado una cuenta a los socios que no poseían', 10, 1);
END
GO

----------------------

CREATE OR ALTER PROCEDURE tesoreria.Insert_Tipo_Reembolso
    @Descripcion VARCHAR(100),
    @Porcentaje NUMERIC(5,2)
AS
BEGIN
    SET NOCOUNT ON

    SET @Descripcion = UPPER(LEFT(LOWER(@Descripcion), 1)) + SUBSTRING(LOWER(@Descripcion), 2, LEN(@Descripcion) - 1) 

    IF (@Porcentaje > 0)
    BEGIN
        IF (@Descripcion IS NULL OR @Descripcion = '')
            RAISERROR('Se debe proporcionar una descripcion no vacía', 10, 1);
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1
                FROM tesoreria.Tipo_Reembolso
                WHERE Descripcion = @Descripcion)
            BEGIN
                INSERT INTO tesoreria.Tipo_Reembolso(Descripcion, Porcentaje)
                VALUES (@Descripcion, @Porcentaje);
                RAISERROR('Nuevo tipo de reembolso registrado.', 10, 1);
            END
            ELSE
                RAISERROR('La descripcion proporcionada ya está en uso', 10, 1);
        END
    END
    ELSE
        RAISERROR('Se debe proporcionar un porcentaje mayor a 0', 10, 1);
END
GO

---------------------------

CREATE or ALTER PROCEDURE tesoreria.Insert_Reembolsos
    @IDCuenta INT,
    @IDPago INT,
    @IDTipoReembolso INT
AS
BEGIN
    SET NOCOUNT ON

    IF NOT EXISTS (Select 1 FROM socios.Cuenta WHERE ID = @IDCuenta)
    BEGIN
        RAISERROR('No existe cuenta con el ID Proporcionado', 10, 1);
        RETURN;
    END

    IF NOT EXISTS (Select 1 FROM tesoreria.Pago WHERE ID = @IDPago)
    BEGIN
        RAISERROR('No existe un pago con el ID Proporcionado', 10, 1);
        RETURN;
    END

    IF NOT EXISTS (Select 1 FROM tesoreria.Tipo_Reembolso WHERE ID = @IDTipoReembolso)
    BEGIN
        RAISERROR('No existe un tipo de reembolso con el ID Proporcionado', 10, 1);
        RETURN;
    END

    IF EXISTS (Select 1 FROM tesoreria.Reembolso WHERE ID_Pago = @IDPago)
    BEGIN
        RAISERROR('El pago asociado al ID proporcionado ya fue reembolsado', 10, 1);
        RETURN;
    END

    UPDATE socios.Cuenta
    SET Saldo += tf.Importe * tr.Porcentaje/100
    FROM socios.Cuenta sc
    JOIN tesoreria.Pago tp ON tp.ID=@IDPago
    JOIN tesoreria.Factura tf ON tf.ID_Pago = @IDPago
    JOIN tesoreria.Tipo_Reembolso tr on tr.ID = @IDTipoReembolso
    WHERE sc.ID = @IDCuenta

    INSERT INTO tesoreria.Reembolso (ID_Cuenta, ID_Pago, ID_Tipo)
    VALUES (@IDCuenta, @IDPago, @IDTipoReembolso);

    RAISERROR('Reembolso registrado y saldo actualizado', 10, 1);

END
GO

----------------------------

CREATE OR ALTER PROCEDURE tesoreria.Generar_Reembolsos_Por_Lluvia
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tesoreria.Reembolso (ID_Cuenta, ID_Pago, ID_Tipo)
    SELECT
        c.ID AS ID_Cuenta,
        f.ID_Pago,
        1 AS ID_Tipo
    FROM actividades.Inscripcion i
    INNER JOIN tesoreria.Factura f
        ON f.ID = i.ID_Factura
    INNER JOIN tesoreria.Pago p
        ON p.ID = f.ID_Pago
    INNER JOIN socios.Cuenta c
        ON c.ID_Socio = i.ID_Socio
    INNER JOIN ##TempLluviaDiaria lluv
        ON (
            (
                UPPER(i.Tipo) LIKE '%DIARIO%' AND
                CONVERT(DATE, lluv.Fecha) = i.Fecha
            )
            OR (
                UPPER(i.Tipo) LIKE '%MENSUAL%' AND
                CONVERT(DATE, lluv.Fecha) BETWEEN i.Fecha AND DATEADD(DAY,30,i.Fecha)
            )
            OR (
                UPPER(i.Tipo) LIKE '%TEMPORADA%' AND
                CONVERT(DATE, lluv.Fecha) BETWEEN i.Fecha AND DATEADD(DAY,90,i.Fecha)
            )
        )
    WHERE
        lluv.TotalLluvia > 0
        AND f.ID_Pago IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM tesoreria.Reembolso r
            WHERE r.ID_Pago = f.ID_Pago
        );

    UPDATE c
    SET c.Saldo += f.Importe * 0.6
    FROM socios.Cuenta c
    INNER JOIN tesoreria.Reembolso r
        ON r.ID_Cuenta = c.ID
    INNER JOIN tesoreria.Pago p
        ON p.ID = r.ID_Pago
    INNER JOIN tesoreria.Factura f
        ON f.ID_Pago = p.ID
    WHERE r.ID_Tipo = 1;

    PRINT 'Reembolsos por lluvia procesados correctamente.';
END;
