USE bd_banca_indicadores_diarios;
GO

-- A-> Igualdad simple

SELECT*FROM responsables;

SELECT
	cod_empleado,
	cargo,
	unidad,
	fecha_inicio,
	fecha_fin
FROM responsables
WHERE cod_empleado='EMP008';

--B valor como parte de una cadena 'LIKE'

SELECT*FROM indicadores

---- Indicadores que tengan la palabra 'diaria' en su descripción
SELECT 
	nombre,
	descripcion,
	unidad_medida, 
	categoria
FROM indicadores
WHERE descripcion LIKE ('%diaria%');

--- Indicadores que comiencen por la palabra 'porcentaje'

SELECT 
	nombre,
	descripcion,
	unidad_medida, 
	categoria
FROM indicadores
WHERE descripcion LIKE ('Porcentaje%');

--- Indicadores que terminen por la palabra 'diario.'

SELECT 
	nombre,
	descripcion,
	unidad_medida, 
	categoria
FROM indicadores
WHERE descripcion LIKE ('%diario.');

--- Operador de comparación

SELECT 
	dia,
	hora_inicio,
	hora_fin
FROM horas
WHERE 
	hora_inicio >= '09:00:00' AND 
	hora_inicio < '18:00:00';

--- Filas que cumplan cualquier de las condiones OR

SELECT*FROM responsables;

SELECT 
	cod_empleado, 
	cargo, 
	unidad, 
	fecha_inicio
FROM responsables
WHERE cargo='Analista' OR unidad = 'Operaciones' OR YEAR(fecha_inicio) = '2022';

--- Filas que cumplan todas las condiones AND

SELECT 
	cod_empleado, 
	cargo, 
	unidad, 
	fecha_inicio
FROM responsables
WHERE cargo='Analista' AND unidad = 'Operaciones' AND YEAR(fecha_inicio) = '2022';

--- Muestre todos los indicadores	que su unidad de medida sea 'porcentaje' y que su
--- categoría sea 'Eficiencia' ó 'Riesgo'

-- Anibal
	select * from indicadores 
	where 
	unidad_medida like ('%porcentaje%') and
	(categoria = 'Eficiencia' or categoria = 'Riesgo');
-- Alejandro
	SELECT *
	FROM indicadores
	WHERE 
	unidad_medida = 'Porcentaje' 
	AND categoria IN ('Eficiencia', 'Riesgo')
-- renat 
	SELECT *
	FROM indicadores
	WHERE unidad_medida = 'porcentaje' 
	AND (categoria = 'Eficiencia' OR categoria = 'Riesgo');
-- Eduardho
SELECT
nombre,
descripcion,
unidad_medida,
categoria
FROM indicadores
WHERE unidad_medida = 'Porcentaje' AND (categoria = 'Eficiencia' OR categoria = 'Riesgo');

--- Diana

select*from indicadores
where 
unidad_medida='porcentaje' AND
(categoria='Eficiencia' or categoria='Riesgo');

--- Encontrar valores que estan en una lista

--- Seleccionar los responsables que se encuentren en las siguientes unidades:
--- 'Operaciones', 'Riesgos', 'TI' y 'Finanzas'
SELECT*FROM responsables
WHERE unidad IN ('Operaciones', 'Riesgos', 'TI' , 'Finanzas');

--- Seleccionar los responsables que NO se encuentren en las siguientes unidades:
--- 'Operaciones', 'Riesgos', 'TI' y 'Finanzas'
SELECT*FROM responsables
WHERE unidad NOT IN ('Operaciones', 'Riesgos', 'TI' , 'Finanzas');

--Between 

--- Seleciona los responsables que ingresaron entre 2022 y 2023

SELECT *
FROM responsables
WHERE YEAR(fecha_inicio) BETWEEN '2022' AND  '2023';

SELECT *
FROM responsables
WHERE YEAR(fecha_inicio) >= '2022' AND YEAR(fecha_inicio)<= '2023';

SELECT*FROM indicadores_horario;
SELECT*FROM registros_diarios_indicadores;

-- INNER JOIN

SELECT r.cod_empleado, r.cargo, sf.*
FROM responsables r
INNER JOIN sistemas_fuente sf ON r.id=sf.responsable_id;

SELECT r.cod_empleado, r.cargo, sf.*
FROM responsables r, sistemas_fuente sf
WHERE r.id=sf.responsable_id;

--- LEFT JOIN

SELECT r.cod_empleado, r.cargo, sf.*
FROM responsables r
LEFT JOIN sistemas_fuente sf ON r.id=sf.responsable_id
-- RIGTH JOIN
SELECT r.cod_empleado, r.cargo, sf.*
FROM sistemas_fuente sf
RIGHT JOIN  responsables r ON r.id=sf.responsable_id;


--- FULL JOIN
SELECT r.cod_empleado, r.cargo, sf.*
FROM sistemas_fuente sf
FULL JOIN  responsables r ON r.id=sf.responsable_id;

--- CROSS JOIN
SELECT r.cod_empleado, r.cargo, sf.*
FROM sistemas_fuente sf
CROSS JOIN  responsables r;
