--En este script se realiza la creación de los Store Procedure para la generación de los reportes

--Fecha de entrega: 1/07/2025
--Comisión: 2900
--Grupo: 6
--Base de datos Aplicada
--Integrantes:
--Fariello Ramiro - DNI: 46124109
--Rojas Taiel Ezequiel - DNI: 46183434
--Cropalati Franco Nicolas - DNI: 43404823

USE Com2900G06
GO

/*Reporte 1
Reporte de los socios morosos, que hayan incumplido en más de dos oportunidades dado un
rango de fechas a ingresar. El reporte debe contener los siguientes datos:
Nombre del reporte: Morosos Recurrentes
Período: rango de fechas
Nro de socio
Nombre y apellido.
Mes incumplido
Ordenados de Mayor a menor por ranking de morosidad
El mismo debe ser desarrollado utilizando Windows Function.*/

CREATE OR ALTER PROCEDURE reportes.MorososRecurrentes
@FechaDesde DATE,
@FechaHasta DATE
AS
BEGIN
	WITH Incumplimientos AS(
		SELECT 
			s.Nro_Socio, 
			s.Nombre, 
			s.Apellido, 
			COUNT(DISTINCT c.Mes) AS CantIncumplimientos,
			STRING_AGG(CAST(c.Mes AS VARCHAR), ', ') AS Meses_Incumplidos
		FROM tesoreria.Factura f
		JOIN tesoreria.Cuota c ON c.ID_Factura = f.ID
		JOIN socios.Socio s ON c.ID_Socio = s.ID
		JOIN tesoreria.Estado_Factura ef ON f.ID_Estado = ef.ID
		WHERE 
			--f.ID_Pago IS NULL
			f.Fecha_Emision BETWEEN @FechaDesde AND @FechaHasta
			AND ef.Descripcion = 'PAGADA CON RETRASO'
			AND ef.ID = f.ID_Estado
		GROUP BY 
			s.Nro_Socio, s.Nombre, s.Apellido
	) SELECT Nro_Socio, Nombre, Apellido, Meses_Incumplidos, RANK() OVER (ORDER BY CantIncumplimientos DESC) AS RANKING 
	  FROM Incumplimientos
	  WHERE CantIncumplimientos > 2
END
GO

/*Reporte 2
Reporte acumulado mensual de ingresos por actividad deportiva al momento en que se saca
el reporte tomando como inicio enero.*/

CREATE OR ALTER PROCEDURE reportes.IngresosMensualesPorActividad
AS
BEGIN
    SELECT 
        DATENAME(MONTH, asist.Fecha) AS Mes,
        MONTH(asist.Fecha) AS NumeroMes,
        YEAR(asist.Fecha) AS Anio,
        act.Descripcion AS Actividad,
        SUM(tarifa.Importe_Por_Mes) AS Ingreso_Total
    FROM actividades.Socio_Asiste_Clase asist
    JOIN actividades.Clase clase ON asist.ID_Clase = clase.ID
    JOIN actividades.Actividad act ON clase.ID_Actividad = act.ID
    JOIN tesoreria.Tarifa_Actividad tarifa ON act.ID_Tarifa = tarifa.ID
    WHERE asist.Asiste = 'P'
        AND YEAR(asist.Fecha) = YEAR(GETDATE())
        AND MONTH(asist.Fecha) <= MONTH(GETDATE())
    GROUP BY 
        DATENAME(MONTH, asist.Fecha), 
        MONTH(asist.Fecha),
        YEAR(asist.Fecha), 
        act.Descripcion
    ORDER BY Anio, NumeroMes, Actividad;
END
GO

/* REPORTE 3
Reporte de la cantidad de socios que han realizado alguna actividad de forma alternada
(inasistencias) por categoría de socios y actividad, ordenado según cantidad de inasistencias
ordenadas de mayor a menor*/

CREATE OR ALTER PROCEDURE reportes.ReporteInasistencias
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

CREATE OR ALTER PROCEDURE reportes.SociosConInasistencias
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

