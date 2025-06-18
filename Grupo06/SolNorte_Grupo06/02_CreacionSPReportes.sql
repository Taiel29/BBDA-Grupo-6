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
