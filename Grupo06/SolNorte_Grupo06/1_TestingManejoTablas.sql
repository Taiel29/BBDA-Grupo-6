--En este script se prueba la funcionalidad de los scripts de manejo de tablas

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

--====Insertar Medio de pago====--

--Se espera mensaje informando que el medio de pago se insertó.
--El medio de pago insertado estará en mayusculas
--Al ejecutar una segunda vez, se muestra que el medio de pago ya existe
EXEC tesoreria.Insert_Medio_Pago @Descripcion = 'TaRJeta'
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

--====tesoreria.Insert_Actividad====--
--Se espera mensaje informando que la actividad fue registrada.
--La actividad insertada tendrá el primer caracter en masyuculas
--Al ejecutar una segunda vez, se muestra que la actividad ya existe
EXEC actividades.Insert_Actividad @Descripcion = 'WaTERpolo', @IDTarifa = '3'
Select * FROM actividades.Actividad
--Si la actividad ya existe, no se debe poder actualizar su ID de tarifa con esta sp
EXEC actividades.Insert_Actividad @Descripcion = 'Waterpolo', @IDTarifa = '2'
Select * FROM actividades.Actividad
--No se aceptan IDTarifa negativos, en blanco, o que no existan
EXEC actividades.Insert_Actividad @Descripcion = 'WATERPOLO', @IDTarifa = '9'
Select * FROM actividades.Actividad
--No se aceptan descripciones vacías
EXEC actividades.Insert_Actividad @Descripcion = '', @IDTarifa = '3'
Select * FROM actividades.Actividad