USE bd_banca_indicadores_diarios;
/*
Detectar los indicadores cuyo valor real fue menor al valor meta en más del 50% 
de los días del mes actual.*/

--mes actual
SELECT
	s.nombre AS 'Sucursal',
	i.nombre AS 'Indicador',
	rdi.valor_real,
	rdi.valor_meta,
	rdi.fecha_reporte,
	(100-(rdi.valor_real/rdi.valor_meta)*100) AS 'Menor que el valor meta en un ..%'
FROM registros_diarios_indicadores rdi
	INNER JOIN sucursales s ON s.id=rdi.sucursal_id
	INNER JOIN indicadores i ON i.id=rdi.indicador_id
WHERE (100-(rdi.valor_real/rdi.valor_meta)*100)>50 AND 
		MONTH(GETDATE())=MONTH(rdi.fecha_reporte) AND
		YEAR(GETDATE())=YEAR(rdi.fecha_reporte);


-- últimos 30 días

SELECT
	s.nombre AS 'Sucursal',
	i.nombre AS 'Indicador',
	rdi.valor_real,
	rdi.valor_meta,
	rdi.fecha_reporte,
	(100-(rdi.valor_real/rdi.valor_meta)*100) AS 'Menor que el valor meta en un ..%'
FROM registros_diarios_indicadores rdi
	INNER JOIN sucursales s ON s.id=rdi.sucursal_id
	INNER JOIN indicadores i ON i.id=rdi.indicador_id
WHERE (100-(rdi.valor_real/rdi.valor_meta)*100)>50 AND 
		DATEDIFF(DAY,rdi.fecha_reporte,GETDATE())<=30

