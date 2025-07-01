--En este script se prueba la funcionalidad de los scripts de importación a tablas

--Fecha de entrega: 1/07/2025
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

-- Reporte 1


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

EXEC reportes.MorososRecurrentes
	@FechaDesde = '2025-01-01',
	@FechaHasta = '2025-04-01'

-- Reporte 2
EXEC reportes.IngresosMensualesPorActividad

-- Reporte 3
EXEC reportes.ReporteInasistencias;

-- Reporte 4
EXEC reportes.SociosConInasistencias;