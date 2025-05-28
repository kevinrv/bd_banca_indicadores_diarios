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

Mostrar cuántos indicadores tiene registrados cada sistema fuente.

Obtener el promedio del valor real reportado por indicador en los últimos 7 días.

Listar los indicadores con desviaciones absolutas mayores a 1000 soles, ordenados de mayor a menor.

🔹 Nivel Avanzado
Calcular el porcentaje de cumplimiento (valor_real / valor_meta * 100) de todos los indicadores reportados ayer por cada sucursal.

Mostrar un ranking de sucursales según el total de indicadores reportados en el último mes.

Detectar los indicadores cuyo valor real fue menor al valor meta en más del 50% de los días del mes actual.

Listar todos los indicadores cuyo ratio de desviación porcentual promedio supere el 10%.

Obtener el tiempo total (en segundos) que transcurre entre cada horario de inicio y fin para los registros de indicadores_horario, agrupado por indicador.

🔹 Nivel Experto / Análisis Gerencial
Elaborar un reporte que muestre por cada sucursal:

Total de indicadores reportados en el último trimestre.

Promedio del valor real.

Número de desviaciones clasificadas como “Alta”.

Detectar los sistemas fuente cuyo responsable ha cambiado en el último año.

Calcular un "Índice de consistencia" por indicador, que mida la diferencia promedio diaria entre el valor real y el valor meta.

Identificar los 5 indicadores más críticos (con mayor cantidad de desviaciones severas en el último mes).

Generar una tabla resumen que indique, por día, cuántos indicadores fueron registrados por franja horaria (mañana, tarde, noche).*/