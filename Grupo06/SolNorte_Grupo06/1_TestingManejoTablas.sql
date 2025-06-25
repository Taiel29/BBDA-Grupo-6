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

EXEC actividades.Insert_Inscripcion_Pileta
    @NroSocio = 'SN-4028',
    @IDTarifa = 1,
    @Fecha = '2024-06-24';

SELECT * FROM socios.Socio;
SELECT * FROM tesoreria.Tarifa_Pileta;
SELECT * FROM actividades.Pileta;
SELECT * FROM actividades.Inscripcion;
SELECT * FROM actividades.Actividad_Extra;
