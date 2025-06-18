/* REPORTE 3
Reporte de la cantidad de socios que han realizado alguna actividad de forma alternada
(inasistencias) por categoría de socios y actividad, ordenado según cantidad de inasistencias
ordenadas de mayor a menor*/

CREATE OR ALTER PROCEDURE sp_ReporteInasistencias
AS
BEGIN
    SELECT 
        soc.Categoria,
        act.Nombre AS Actividad,
        COUNT(*) AS Cantidad_Inasistencias
    FROM actividades.Socio_Asiste_Clase asist
    JOIN socios.Socio soc ON asist.ID_Socio = soc.ID
    JOIN actividades.Clase cl ON asist.ID_Clase = cl.ID
    JOIN actividades.Actividad act ON cl.ID_Actividad = act.ID
    WHERE asist.Asiste IN ('A', 'J')  -- A: ausente, J: justificado
    GROUP BY soc.Categoria, act.Nombre
    ORDER BY Cantidad_Inasistencias DESC;
END;

--EXEC sp_ReporteInasistencias;


/* REPORTE 4
Reporte que contenga a los socios que no han asistido a alguna clase de la actividad que
realizan. El reporte debe contener: Nombre, Apellido, edad, categoría y la actividad*/

CREATE OR ALTER PROCEDURE sp_SociosConInasistencias
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

--EXEC sp_SociosConInasistencias;