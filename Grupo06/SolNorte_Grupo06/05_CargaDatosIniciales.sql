/*En este script se cargan los datos iniciales en el sistema, tanto como los que se reciben por archivo como
aquellos que no se reciben pero se saben sus valores, tales como los medios de pago que maneja el club*/

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

EXEC tesoreria.Insert_Medio_Pago @Descripcion = 'TaRJeta'
EXEC tesoreria.Insert_Medio_Pago @Descripcion = 'TRANSFERENCIA'
EXEC tesoreria.Insert_Medio_Pago @Descripcion = 'sucursal de pago'
EXEC tesoreria.Insert_Medio_Pago @Descripcion = 'Debito AUTOMÁTICO'
GO

EXEC tesoreria.Insert_Recargo
    @DiasDesdeVencimiento = 5,
    @Porcentaje = 10
GO

EXEC tesoreria.Insert_Tipo_Reembolso
    @Descripcion = 'Por lluvia',
    @Porcentaje = 60
GO

EXEC tesoreria.Insert_Estado_Factura @Descripcion = 'PAgADA'
GO
WAITFOR DELAY '00:00:00.200';

EXEC tesoreria.Insert_Estado_Factura @Descripcion = 'GeNerAda'
GO
WAITFOR DELAY '00:00:01';

EXEC tesoreria.Insert_Estado_Factura @Descripcion = 'Pagada con retraso'
GO
WAITFOR DELAY '00:00:02';

EXEC importaciones.Import_Actividades
    @rutaArch = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO
WAITFOR DELAY '00:00:01';

EXEC importaciones.Import_Tarifas_Cuotas
    @rutaArch = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO
WAITFOR DELAY '00:00:01';

EXEC importaciones.Importar_Socios_Desde_Excel
	@RutaExcel = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO
WAITFOR DELAY '00:00:01';

EXEC importaciones.Importar_Grupo_Familiar
	@RutaExcel = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO
WAITFOR DELAY '00:00:01';

EXEC importaciones.Import_Asistencias
    @rutaArch = 'C:\Users\Public\Documents\Datos socios.xlsx',
	@password = '#BBDA.2025'
GO
WAITFOR DELAY '00:00:01';

EXEC importaciones.Import_Tarifas_Pileta
    @rutaArch = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO
WAITFOR DELAY '00:00:01';

EXEC importaciones.ImportarPagoCuotasDesdeExcel
	@RutaExcel = 'C:\Users\Public\Documents\Datos socios.xlsx'
GO
WAITFOR DELAY '00:00:01';

EXEC importaciones.Importar_Lluvia
	@RutaArch1 = 'C:\Users\Public\Documents\open-meteo-buenosaires_2024.csv',
	@RutaArch2 = 'C:\Users\Public\Documents\open-meteo-buenosaires_2025.csv'
GO