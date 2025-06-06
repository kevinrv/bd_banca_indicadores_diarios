USE bd_banca_indicadores_diarios;
GO

/*🔹 Nivel Básico
--Listar todas las sucursales activas con su código, nombre, ciudad y teléfono.*/
 SELECT
	codigo,
	nombre, 
	ciudad, 
	telefono
 FROM sucursales
 WHERE estado='activo'

/*
Obtener los nombres de todos los sistemas fuente registrados junto con el codigo 
de empleado del responsable asignado.*/

SELECT 
	sf.nombre,
	r.cod_empleado
FROM sistemas_fuente sf
	INNER JOIN responsables r ON sf.responsable_id=r.id;

/*

Mostrar los indicadores registrados en el sistema, incluyendo su nombre, unidad de medida y categoría.*/

SELECT nombre, unidad_medida,categoria
FROM indicadores;

/*

Listar todos los responsables cuyo contrato comenzó antes del 2023.*/
SELECT*FROM responsables
WHERE YEAR(fecha_inicio)<'2023';

/*

Mostrar las horas registradas con su respectivo día, hora de inicio y hora de fin ordenadas por hora de inicio.*/

SELECT dia, hora_inicio, hora_fin
FROM horas
ORDER BY hora_inicio;

/*

🔹 Nivel Intermedio
Listar todos los indicadores que se miden en porcentaje y que pertenecen al área de Operaciones.*/

SELECT i.*, sf.area
FROM indicadores i
INNER JOIN sistemas_fuente sf ON sf.id=i.sistema_fuente_id
WHERE 
	i.unidad_medida = 'porcentaje' AND 
	sf.area = 'Operaciones';

/*

Mostrar los 10 últimos registros diarios de indicadores reportados en una sucursal específica.*/

SELECT TOP 10
	s.nombre AS 'Sucursal',
	i.nombre AS 'indicador',
	rd.fecha_reporte
FROM sucursales s
	INNER JOIN registros_diarios_indicadores rd ON rd.sucursal_id=s.id
	INNER JOIN indicadores i ON i.id = rd.indicador_id
WHERE s.id=1
ORDER BY fecha_reporte DESC;

/*

Mostrar cuántos indicadores tiene registrados cada sistema fuente.*/

SELECT 
	sf.nombre 'Sistema_Fuente',
	COUNT(i.id) 'num_indicadores'
FROM sistemas_fuente AS sf 
INNER JOIN indicadores AS i ON i.sistema_fuente_id=sf.id
GROUP BY sf.nombre;


SELECT 
	sistemas_fuente.nombre AS 'Sistema_Fuente',
	COUNT(indicadores.id) AS 'num_indicadores'
FROM sistemas_fuente 
INNER JOIN indicadores  ON indicadores.sistema_fuente_id=sistemas_fuente.id
GROUP BY sistemas_fuente.nombre;

/*

Obtener el promedio del valor real reportado por indicador en los últimos 7 días.*/

-- DATEDIFF
SELECT
	i.nombre AS 'Indicador',
	i.unidad_medida,
	AVG(rdi.valor_real) AS 'avg_valor_real'
FROM indicadores i
INNER JOIN registros_diarios_indicadores rdi ON rdi.indicador_id=i.id
WHERE DATEDIFF(DAY,rdi.fecha_reporte,GETDATE())<=7
GROUP BY i.nombre,i.unidad_medida;

-- DATEADD
SELECT
	i.nombre AS 'Indicador',
	i.unidad_medida,
	AVG(rdi.valor_real) AS 'avg_valor_real'
FROM indicadores i
INNER JOIN registros_diarios_indicadores rdi ON rdi.indicador_id=i.id
WHERE DATEADD(DAY,-7,GETDATE())<=rdi.fecha_reporte
GROUP BY i.nombre,i.unidad_medida;

SELECT*FROM indicadores;
/*

Listar los indicadores con desviaciones absolutas mayores a 1000 soles, ordenados de mayor a menor.*/
--- Insertando dato en la tabla desviaciones

SELECT*FROM desviaciones_indicador;

INSERT INTO desviaciones_indicador
SELECT
	id AS 'registro_diario_indicador',
	ABS(valor_real-valor_meta) AS 'diferencia_absoluta',
	(ABS(valor_real-valor_meta)/valor_meta)*100 AS 'diferencia_porcentual',
	CASE 
	  WHEN (ABS(valor_real-valor_meta)/valor_meta)*100 >= 30 THEN 'Crítica'
	  WHEN (ABS(valor_real-valor_meta)/valor_meta)*100 >= 20 THEN 'Alta'
	  WHEN (ABS(valor_real-valor_meta)/valor_meta)*100 >= 10 THEN 'Moderada'
	  WHEN (ABS(valor_real-valor_meta)/valor_meta)*100> 0 THEN 'Baja'
	ELSE 'Sin Desviación' END AS 'clasificacion'
FROM registros_diarios_indicadores;

-- No puede haber valores meta iguales a 0
UPDATE registros_diarios_indicadores SET valor_meta = 0.5
WHERE valor_meta=0;

SELECT distinct unidad_medida
FROM indicadores;
--Solución ejercicio:

SELECT*FROM registros_diarios_indicadores;


SELECT 
	rdi.fecha_reporte,
	s.nombre AS 'Sucursal',
	i.nombre AS 'Indicador',
	di.diferencia_absoluta
FROM desviaciones_indicador di
	INNER JOIN registros_diarios_indicadores rdi ON rdi.id=di.registro_diario_indicador_id
	INNER JOIN indicadores i ON i.id=rdi.indicador_id
	INNER JOIN sucursales s ON s.id=rdi.sucursal_id
WHERE 
	di.diferencia_absoluta>'1000' AND
	i.unidad_medida='Monto (S/.)'
ORDER BY  s.nombre,di.diferencia_absoluta DESC;
--Generamos una vista
CREATE VIEW vw_kv_indicadores_abs_mayor_100 AS
SELECT 
	rdi.fecha_reporte,
	s.nombre AS 'Sucursal',
	i.nombre AS 'Indicador',
	di.diferencia_absoluta
FROM desviaciones_indicador di
	INNER JOIN registros_diarios_indicadores rdi ON rdi.id=di.registro_diario_indicador_id
	INNER JOIN indicadores i ON i.id=rdi.indicador_id
	INNER JOIN sucursales s ON s.id=rdi.sucursal_id
WHERE 
	di.diferencia_absoluta>'1000' AND
	i.unidad_medida='Monto (S/.)';

SELECT*FROM vw_kv_indicadores_abs_mayor_100
ORDER BY diferencia_absoluta DESC;

/*

🔹 Nivel Avanzado
Calcular el porcentaje de cumplimiento (valor_real / valor_meta * 100) de todos los indicadores reportados 
ayer por cada sucursal.*/

SELECT
	s.nombre AS 'Sucursal',
	i.nombre AS 'Indicador',
	valor_meta,
	valor_real,
	CONCAT(ROUND((valor_real / valor_meta * 100),2),' %') AS 'porcentaje_cumpliento',
	fecha_reporte
FROM registros_diarios_indicadores rdi
	INNER JOIN sucursales AS s ON rdi.sucursal_id = s.id
	INNER JOIN indicadores as i ON rdi.indicador_id = i.id
WHERE DATEDIFF(DAY,fecha_reporte,GETDATE())=1
ORDER BY s.nombre, i.nombre;

/*


Mostrar un ranking de sucursales según el total de indicadores reportados en el último mes.*/

SELECT
    s.nombre AS 'Sucursal',
    COUNT(rdi.id) AS 'Total_Indicadores_Reportados'
FROM
    registros_diarios_indicadores rdi
INNER JOIN
    sucursales s ON rdi.sucursal_id = s.id
WHERE
    rdi.fecha_reporte >= DATEADD(DAY, -30, GETDATE())
GROUP BY
    s.nombre
ORDER BY 2 DESC;

SELECT 
s.nombre AS 'Sucursal',
COUNT(rdi.id) AS 'Total_Indicadores_Reportados'
FROM registros_diarios_indicadores rdi
	INNER JOIN sucursales s ON rdi.sucursal_id = s.id
	WHERE rdi.fecha_reporte >= DATEADD(DAY, -30, GETDATE())
GROUP BY s.nombre
ORDER BY Total_Indicadores_Reportados DESC;

--Mostrar un ranking de sucursales que tenga  reportados mas de 20 indicadores en el último mes.*/
SELECT
    s.nombre AS 'Sucursal',
    COUNT(rdi.id) AS 'Total_Indicadores_Reportados'
FROM
    registros_diarios_indicadores rdi
INNER JOIN
    sucursales s ON rdi.sucursal_id = s.id
WHERE
    rdi.fecha_reporte >= DATEADD(DAY, -30, GETDATE()) 
GROUP BY
    s.nombre
HAVING COUNT(rdi.id)>20
ORDER BY 2 DESC;

/*

Detectar los indicadores cuyo valor real fue menor al valor meta en más del 50% de los días del mes actual.*/

SELECT 
	s.nombre AS 'Sucursal',
	i.nombre AS 'Indicador',
	rdi.valor_real,
	rdi.valor_meta,
	rdi.fecha_reporte,
	100-((rdi.valor_real/rdi.valor_meta)*100) AS 'Menor que el valor meta en un ..%'
FROM registros_diarios_indicadores rdi
	INNER JOIN sucursales s ON rdi.sucursal_id = s.id
	INNER JOIN indicadores i ON rdi.indicador_id = i.id
WHERE 
	MONTH(GETDATE())=MONTH(rdi.fecha_reporte) AND 
	YEAR(GETDATE())=YEAR(rdi.fecha_reporte) AND 
	100-((rdi.valor_real/rdi.valor_meta)*100)>50
ORDER BY 1,2;

/*

Listar todos los indicadores cuyo ratio de desviación porcentual promedio supere el 10%.(Tarea)


Obtener el tiempo total (en segundos) que transcurre entre cada horario de inicio y fin para los
registros de indicadores_horario, agrupado por indicador.
*/

SELECT*FROM horas;
SELECT*FROM horarios;

SELECT
	s.nombre AS 'Sucursal',
	i.nombre AS 'Indicador',
	hi.hora_id 'i',
	hf.hora_id 'f',
	hri.hora_inicio 'hi',
	hrf.hora_fin 'hf',
	CASE
	 WHEN DATEDIFF(HOUR,hri.hora_inicio,hrf.hora_fin)>0 THEN (DATEDIFF(HOUR,hri.hora_inicio,hrf.hora_fin))*60
	 ELSE (DATEDIFF(HOUR,hri.hora_inicio,hrf.hora_fin)+24)*60
	 END AS 'tiempo_en_segundos'
FROM indicadores i
	INNER JOIN indicadores_horario ih ON ih.indicador_id=i.id
	INNER JOIN horarios hi ON hi.id=ih.horario_inicio_id
	INNER JOIN horas hri ON hri.id=hi.hora_id
	INNER JOIN horarios hf ON hf.id=ih.horario_fin_id
	INNER JOIN horas hrf ON hrf.id=hf.hora_id
	INNER JOIN sucursales s ON s.id=hi.sucursal_id AND s.id=hf.sucursal_id 
GROUP BY s.nombre, i.nombre,hrf.hora_fin,hri.hora_inicio,hi.hora_id,
	hf.hora_id




/*




🔹 Nivel Experto / Análisis Gerencial
Elaborar un reporte que muestre por cada sucursal:

Total de indicadores reportados en el último trimestre.

Promedio del valor real.

Número de desviaciones clasificadas como “Alta”.

Detectar los sistemas fuente cuyo responsable ha cambiado en el último año.

Calcular un "Índice de consistencia" por indicador, que mida la diferencia promedio diaria entre el valor real y el valor meta.

Identificar los 5 indicadores más críticos (con mayor cantidad de desviaciones críticas en el último mes).*/

SELECT  TOP 5
	i.nombre AS 'Indicador',
	COUNT(di.registro_diario_indicador_id) AS 'num_indicadores'
FROM registros_diarios_indicadores rdi
	INNER JOIN indicadores i ON rdi.indicador_id = i.id
	INNER JOIN desviaciones_indicador di ON di.registro_diario_indicador_id=rdi.id
WHERE 
	di.clasificacion='Crítica' AND
	MONTH(GETDATE())=MONTH(rdi.fecha_reporte) AND 
	YEAR(GETDATE())=YEAR(rdi.fecha_reporte) 
GROUP BY i.nombre
ORDER BY 2 DESC;

-- Ranking dinamico
SELECT 
	i.nombre AS 'Indicador',
	COUNT(di.registro_diario_indicador_id) AS 'num_indicadores'
	INTO #t01
FROM registros_diarios_indicadores rdi
	INNER JOIN indicadores i ON rdi.indicador_id = i.id
	INNER JOIN desviaciones_indicador di ON di.registro_diario_indicador_id=rdi.id
WHERE 
	di.clasificacion='Crítica' AND
	MONTH(GETDATE())=MONTH(rdi.fecha_reporte) AND 
	YEAR(GETDATE())=YEAR(rdi.fecha_reporte)
GROUP BY i.nombre
ORDER BY 2 DESC;

SELECT 
	Indicador,
	num_indicadores
FROM #t01
WHERE num_indicadores IN (SELECT TOP 5 num_indicadores FROM #t01 ORDER BY num_indicadores DESC)
ORDER BY 2 DESC;

DROP TABLE #t01



/*




Generar una tabla resumen que indique, por día, cuántos indicadores fueron registrados por franja horaria (mañana, tarde, noche).*/