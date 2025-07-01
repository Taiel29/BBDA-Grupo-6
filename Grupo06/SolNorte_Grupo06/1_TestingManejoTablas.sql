--En este script se prueba la funcionalidad de los scripts de manejo de tablas

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

--====Insertar Recargo de factura====--

--Se espera mensaje informando que el medio de pago se insertó.
--El medio de pago insertado estará en mayusculas
--Al ejecutar una segunda vez, se muestra que ya hay un recargo para esa cantidad de días
EXEC tesoreria.Insert_Recargo
    @DiasDesdeVencimiento = 2,
    @Porcentaje = 10
SELECT * FROM tesoreria.Recargo
--No se aceptan porcentajes iguales o menores a 0
EXEC tesoreria.Insert_Recargo
    @DiasDesdeVencimiento = 2,
    @Porcentaje = -1
SELECT * FROM tesoreria.Recargo
--No se aceptan días menores a 0
EXEC tesoreria.Insert_Recargo
    @DiasDesdeVencimiento = -1,
    @Porcentaje = 10
SELECT * FROM tesoreria.Recargo

--====Insertar Medio de pago====--

--Se espera mensaje informando que el medio de pago se insertó.
--El medio de pago insertado estará en mayusculas
--Al ejecutar una segunda vez, se muestra que el medio de pago ya existe
EXEC tesoreria.Insert_Medio_Pago @Descripcion = 'EfecTIVo'
SELECT * FROM tesoreria.Medio_Pago
--No se aceptan medios de pago sin descripción
EXEC tesoreria.Insert_Medio_Pago @Descripcion = ''
SELECT * FROM tesoreria.Medio_Pago
--------------------------------------

--====tesoreria.Insert_Estado_Factura====--

--Se espera mensaje informando que el estado de factura fue registrado.
--El estado de factura insertado estará en mayusculas
--Al ejecutar una segunda vez, se muestra que el estado de factura ya existe
EXEC tesoreria.Insert_Estado_Factura @Descripcion = 'PAgADA'
EXEC tesoreria.Insert_Estado_Factura @Descripcion = 'GeNerAda'
SELECT * FROM tesoreria.Estado_Factura
--Se espera que no se agregue el estado de factura con descripción vacía
EXEC tesoreria.Insert_Estado_Factura @Descripcion = ''
SELECT * FROM tesoreria.Estado_Factura
---------------------------

--====actividades.Insert_Actividad====--

--Se espera mensaje informando que la actividad fue registrada.
--La actividad insertada tendrá el primer caracter en masyuculas
--Al ejecutar una segunda vez, se muestra que la actividad ya existe
EXEC actividades.Insert_Actividad @Descripcion = 'WaTERpolo', @IDTarifa = 3
Select * FROM actividades.Actividad
--Si la actividad ya existe, no se debe poder actualizar su ID de tarifa con esta sp
EXEC actividades.Insert_Actividad @Descripcion = 'Waterpolo', @IDTarifa = 2
Select * FROM actividades.Actividad
--No se aceptan IDTarifa negativos, en blanco, o que no existan
EXEC actividades.Insert_Actividad @Descripcion = 'WATERPOLO', @IDTarifa = -1
Select * FROM actividades.Actividad
--No se aceptan descripciones vacías
EXEC actividades.Insert_Actividad @Descripcion = '', @IDTarifa = 3
Select * FROM actividades.Actividad
-------------------------------------

--====tesoreria.Insert_Tarifa_Actividad====--

--Se espera mensaje informando que la tarifa fue registrada.
--Se insertará la tarifa solo si no existe una con ese valor y esa fecha de vigencia
--Al ejecutar una segunda vez, se muestra que la tarifa ya existe
EXEC tesoreria.Insert_Tarifa_Actividad @Valor = 1500.00, @Fecha = '2026-03-13'
Select * FROM tesoreria.Tarifa_Actividad
--No se aceptan fechas inferiores a la fecha actual
EXEC tesoreria.Insert_Tarifa_Actividad @Valor = 3000, @Fecha = '2024-03-13'
Select * FROM tesoreria.Tarifa_Actividad
--No se aceptan valores negativos
EXEC tesoreria.Insert_Tarifa_Actividad @Valor = -3000, @Fecha = '2026-03-13'
Select * FROM tesoreria.Tarifa_Actividad
--No se aceptan fechas vacías
EXEC tesoreria.Insert_Tarifa_Actividad @Valor = 3000, @Fecha = ''

Select * FROM tesoreria.Tarifa_Actividad

-------------------------------------

--====actividades.Update_Tarifa_Actividad====--

--Se espera mensaje informando que la tarifa fue actualizada.
--Se actualiza la actividad con la nueva tarifa
EXEC actividades.Update_Actividad_Tarifa @Descripcion = 'WaTERpolo', @IDTarifa = 2
Select * FROM actividades.Actividad
--Si la actividad no existe, no se debe poder actualizar su ID de tarifa
EXEC actividades.Update_Actividad_Tarifa @Descripcion = 'Watpolo', @IDTarifa = 2
Select * FROM actividades.Actividad
--No se aceptan IDTarifa negativos, en blanco, o que no existan
EXEC actividades.Insert_Actividad @Descripcion = 'WATERPOLO', @IDTarifa = -1
Select * FROM actividades.Actividad
--No se aceptan descripciones vacías
EXEC actividades.Insert_Actividad @Descripcion = '', @IDTarifa = 3
Select * FROM actividades.Actividad
-------------------------------------

--====tesoreria.Insert_Tesoreria====--

--Se espera mensaje informando que la factura fue insertada con éxito.
DECLARE @FechaActual DATE = CAST(GETDATE() AS DATE);
DECLARE @HoraActual TIME = CAST(GETDATE() AS TIME);
DECLARE @ID_Factura INT

EXEC tesoreria.Insert_Factura
    @FechaEmision = @FechaActual,
    @HoraEmision = @HoraActual,
    @Importe = 1500.75,
    @ID_Factura = @ID_Factura OUTPUT
PRINT ('ID de la factura generada: ' + CAST(@ID_Factura AS VARCHAR))

SELECT * FROM tesoreria.Factura ORDER BY ID desc
-- Se espera:
-- Rechazar las fechas de emisión vacías
-- Hora de emisión en 0 si no se especifica
-- Rechazar importes negativos
-- Que se genera una factura con la tarifa según si el socio es mayor o menor de 12 años, y el tipo de pase.
------------------------------------

--====actividades.Insert_Inscripcion_Pileta====--

-- Generar una inscripción a la pileta declarando si se tiene pase Diario, Mensual, o de Temporada
-- Generar una factura con la tarifa correspondiente al tipo de pase

SELECT * FROM socios.Socio ORDER BY Nro_Socio; --Para ver qué Nro_Socios se pueden usar

EXEC actividades.Insert_Inscripcion_Pileta
    @NroSocio = 'SN-4010',
    @TipoPase = 'Diario',
    @Fecha = '2024-06-24',
    @Hora = '';

SELECT * FROM tesoreria.Tarifa_Pileta;
SELECT * FROM actividades.Pileta;
SELECT * FROM actividades.Inscripcion;
SELECT * FROM actividades.Actividad_Extra;
SELECT TOP 100 * FROM tesoreria.Factura ORDER BY ID desc

-- Se espera:
-- Rechazar los tipos de pase que no sean Mensual, Diario, o Temporada
-- Rechazar los números de socio invalidos
-- Hora de emisión en 0 en la factura si no se especifica
-- Que se genere una factura con la tarifa según si el socio es mayor o menor de 12 años, y el tipo de pase.


-- Nota: La factura estará impaga, para pagarla se utiliza el sp "Insert_Pago", habilitando de esta forma el reembolso por lluvia
-------------------------------------

--====tesoreria.Insert_Pago====--

-- Se espera mensaje informando que la factura fue insertada con éxito.
-- Referencia de los ID de medios de pago:
-- Medio de pago 1: Tarjeta
-- Medio de pago 2: Transferencia
-- Medio de pago 3: Sucursal de Pago
-- Medio de pago 4: Debito automático

DECLARE @Fecha DATE = CAST(GETDATE() AS DATE);
DECLARE @Hora TIME = CAST(GETDATE() AS TIME);
DECLARE @ID_Pago_Creado INT

EXEC tesoreria.Insert_Pago
    @Fecha = @Fecha,
    @Hora = '',
    @ID_Medio_De_Pago = 3,
    @ID_Pago = 123456789015,
    @ID_Factura = 1006,
    @ID_Pago_Creado = @ID_Pago_Creado OUTPUT

PRINT ('ID del pago creado: ' + CAST(@ID_Pago_Creado AS VARCHAR))

SELECT TOP 100 * FROM tesoreria.Pago ORDER BY ID desc
SELECT TOP 100 * FROM tesoreria.Factura ORDER BY ID desc

-- Se espera:
-- Rechazar el ID de medio de pago si no existe
-- Rechazar si el ID_Pago ya está en uso
-- Rechazar si se proporciona un ID de una factura inexistente o que ya esté pagada
-- Hora de pago en 0 si no se especifica
-- Actualizar el estado de la factura envíada por parametro, y asignarle el ID de pago correspondiente

------------------------------
--====socios.Insert_Cuentas====--

-- Se le crea una cuenta con saldo en 0 a los socios que no poseían una cuenta
--Para probar:
INSERT INTO socios.Socio (DNI, Apellido, Nombre)
VALUES ('31091218', 'Gallardo', 'Marcelo')
SELECT * FROM socios.Socio ORDER BY ID DESC
SELECT * FROM socios.Cuenta ORDER BY ID DESC
EXEC socios.Insert_Cuentas
SELECT * FROM socios.Cuenta ORDER BY ID DESC
GO

--Se crean cuotas junto con sus facturas y se les crea pagos retrasados (un mes). Esto para testear el funcionamiento del reporte de morosidad
DECLARE @ID_Factura INT;
DECLARE @ID_Pago_Creado INT;
EXEC tesoreria.Insert_Cuota
	@Mes = 1,
	@Socio = 20,
	@Importe = 5000,
	@ID_Factura = @ID_Factura OUTPUT

EXEC tesoreria.Insert_Pago
    @Fecha = '2025-02-01',
    @Hora = '',
    @ID_Medio_De_Pago = 3,
    @ID_Pago = 123456789019,
    @ID_Factura = @ID_Factura,
    @ID_Pago_Creado = @ID_Pago_Creado OUTPUT
GO

DECLARE @ID_Factura INT;
DECLARE @ID_Pago_Creado INT;
EXEC tesoreria.Insert_Cuota
	@Mes = 2,
	@Socio = 20, 
	@Importe = 5000,
	@ID_Factura = @ID_Factura OUTPUT

EXEC tesoreria.Insert_Pago
    @Fecha = '2025-03-01',
    @Hora = '',
    @ID_Medio_De_Pago = 3,
    @ID_Pago = 123456789029,
    @ID_Factura = @ID_Factura,
    @ID_Pago_Creado = @ID_Pago_Creado OUTPUT
GO


DECLARE @ID_Factura INT;
DECLARE @ID_Pago_Creado INT;
EXEC tesoreria.Insert_Cuota
	@Mes = 3,
	@Socio = 20,
	@Importe = 5000,
	@ID_Factura = @ID_Factura OUTPUT

EXEC tesoreria.Insert_Pago
    @Fecha = '2025-04-01',
    @Hora = '',
    @ID_Medio_De_Pago = 3,
    @ID_Pago = 123456789529,
    @ID_Factura = @ID_Factura,
    @ID_Pago_Creado = @ID_Pago_Creado OUTPUT
GO

DECLARE @ID_Factura INT;
DECLARE @ID_Pago_Creado INT;
EXEC tesoreria.Insert_Cuota
	@Mes = 4,
	@Socio = 20,
	@Importe = 5000,
	@ID_Factura = @ID_Factura OUTPUT

EXEC tesoreria.Insert_Pago
    @Fecha = '2025-05-01',
    @Hora = '',
    @ID_Medio_De_Pago = 3,
    @ID_Pago = 123456789829,
    @ID_Factura = @ID_Factura,
    @ID_Pago_Creado = @ID_Pago_Creado OUTPUT
GO

DECLARE @ID_Factura INT;
DECLARE @ID_Pago_Creado INT;
EXEC tesoreria.Insert_Cuota
	@Mes = 1,
	@Socio = 25,
	@Importe = 5000,
	@ID_Factura = @ID_Factura OUTPUT

EXEC tesoreria.Insert_Pago
    @Fecha = '2025-05-01',
    @Hora = '',
    @ID_Medio_De_Pago = 3,
    @ID_Pago = 123456734029,
    @ID_Factura = @ID_Factura,
    @ID_Pago_Creado = @ID_Pago_Creado OUTPUT
GO

DECLARE @ID_Factura INT;
DECLARE @ID_Pago_Creado INT;
EXEC tesoreria.Insert_Cuota
	@Mes = 2,
	@Socio = 25,
	@Importe = 5000,
	@ID_Factura = @ID_Factura OUTPUT

EXEC tesoreria.Insert_Pago
    @Fecha = '2025-05-01',
    @Hora = '',
    @ID_Medio_De_Pago = 3,
    @ID_Pago = 123456555029,
    @ID_Factura = @ID_Factura,
    @ID_Pago_Creado = @ID_Pago_Creado OUTPUT
GO

DECLARE @ID_Factura INT;
DECLARE @ID_Pago_Creado INT;
EXEC tesoreria.Insert_Cuota
	@Mes = 3,
	@Socio = 25,
	@Importe = 5000,
	@ID_Factura = @ID_Factura OUTPUT

EXEC tesoreria.Insert_Pago
    @Fecha = '2025-05-01',
    @Hora = '',
    @ID_Medio_De_Pago = 3,
    @ID_Pago = 123456234029,
    @ID_Factura = @ID_Factura,
    @ID_Pago_Creado = @ID_Pago_Creado OUTPUT
GO