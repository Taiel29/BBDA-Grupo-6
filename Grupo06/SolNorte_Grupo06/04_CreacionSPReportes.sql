--En este script se realiza la creación de los Store Procedure para la generación de los reportes

--Fecha de entrega: 24/06/2025
--Comisión: 2900
--Grupo: 6
--Base de datos Aplicada
--Integrantes:
--Fariello Ramiro - DNI: 46124109
--Rojas Taiel Ezequiel - DNI: 46183434
--Cropalati Franco Nicolas - DNI: 43404823
--Miguez Alejo - DNI: 41667306

/* REPORTE 3
Reporte de la cantidad de socios que han realizado alguna actividad de forma alternada
(inasistencias) por categoría de socios y actividad, ordenado según cantidad de inasistencias
ordenadas de mayor a menor*/

USE Com2900G06
GO

CREATE OR ALTER PROCEDURE reportes.sp_ReporteInasistencias
AS
BEGIN
    SELECT 
        cat.Nombre,
        act.Descripcion AS Actividad,
        COUNT(*) AS Cantidad_Inasistencias
    FROM actividades.Socio_Asiste_Clase asist
    JOIN socios.Socio soc ON asist.ID_Socio = soc.ID
    JOIN actividades.Clase cl ON asist.ID_Clase = cl.ID
    JOIN actividades.Actividad act ON cl.ID_Actividad = act.ID
     JOIN socios.Categoria_Socio cat ON soc.ID_Categoria_Socio = cat.ID
    WHERE asist.Asiste IN ('A', 'J')  -- A: ausente, J: justificado
    GROUP BY cat.Nombre, act.Descripcion
    ORDER BY Cantidad_Inasistencias DESC;
END;
GO

/* REPORTE 4
Reporte que contenga a los socios que no han asistido a alguna clase de la actividad que
realizan. El reporte debe contener: Nombre, Apellido, edad, categoría y la actividad*/

CREATE OR ALTER PROCEDURE reportes.sp_SociosConInasistencias
AS
BEGIN
    SELECT DISTINCT
        soc.Nombre,
        soc.Apellido,
        DATEDIFF(YEAR, soc.Fecha_Nacimiento, GETDATE()) AS Edad,
        cat.Nombre AS Categoria,
        act.Descripcion AS Actividad
    FROM actividades.Socio_Asiste_Clase asist
    JOIN socios.Socio soc ON asist.ID_Socio = soc.ID
    JOIN socios.Categoria_Socio cat ON soc.ID_Categoria_Socio = cat.ID
    JOIN actividades.Clase clase ON asist.ID_Clase = clase.ID
    JOIN actividades.Actividad act ON clase.ID_Actividad = act.ID
    WHERE asist.Asiste IN ('A', 'J');  -- Inasistencias: Ausente o Justificado
END;
GO

