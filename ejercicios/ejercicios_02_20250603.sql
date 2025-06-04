USE bd_banca_indicadores_diarios;
GO

/*
?? FUNCIONES ESCALARES Y DE TABLA � Ejercicios Propuestos
?? Funciones Escalares
Crear una funci�n que reciba un id de sucursal y devuelva su nombre completo (nombre + ciudad + regi�n).*/

ALTER FUNCTION fn_kv_nombre_completo_suscursal (@sucursal_id INT)
RETURNS VARCHAR(255)
AS 
BEGIN
	DECLARE @nombre_completo VARCHAR(255);

	SELECT @nombre_completo = CONCAT(nombre,ciudad,region) 
	FROM sucursales
	WHERE id = @sucursal_id;

	RETURN @nombre_completo
END

SELECT dbo.fn_kv_nombre_completo_suscursal(6);

SELECT dbo.fn_kv_nombre_completo_suscursal(id)
FROM sucursales;
/*

Crear una funci�n que reciba los valores real y meta de un indicador y devuelva el porcentaje de cumplimiento.*/

CREATE FUNCTION fn_kv_porcentaje_cumplimiento (@real DECIMAL(9,2),@meta DECIMAL(9,2))

RETURNS DECIMAL(9,2)
AS BEGIN
DECLARE @porcentaje_cumpliento DECIMAL(9,2);

SET @porcentaje_cumpliento = ROUND((@real/@meta)*100,2);

RETURN @porcentaje_cumpliento
END

SELECT dbo.fn_kv_porcentaje_cumplimiento(1800,2000);

SELECT DISTINCT unidad_medida FROM indicadores;

/*

Crear una funci�n que retorne la clasificaci�n de una desviaci�n dado su valor porcentual.*/

SELECT*FROM desviaciones_indicador;

	CASE 
	  WHEN (ABS(valor_real-valor_meta)/valor_meta)*100 >= 30 THEN 'Cr�tica'
	  WHEN (ABS(valor_real-valor_meta)/valor_meta)*100 >= 20 THEN 'Alta'
	  WHEN (ABS(valor_real-valor_meta)/valor_meta)*100 >= 10 THEN 'Moderada'
	  WHEN (ABS(valor_real-valor_meta)/valor_meta)*100> 0 THEN 'Baja'
	ELSE 'Sin Desviaci�n' END AS 'clasificacion'
/*

Crear una funci�n que indique si un responsable a�n est� activo (fecha_fin es NULL o mayor a la fecha actual).

Crear una funci�n que calcule el tiempo total (en minutos) entre hora_inicio y hora_fin de un registro de la tabla horas.

?? Funciones de Tabla
Crear una funci�n de tabla que retorne todos los indicadores registrados para una sucursal espec�fica en una fecha dada.

Crear una funci�n de tabla que devuelva los registros diarios de indicadores con desviaciones clasificadas como �Alta� en el �ltimo mes.

Crear una funci�n de tabla que muestre el historial de indicadores de un sistema fuente espec�fico.

?? PROCEDIMIENTOS ALMACENADOS � Ejercicios Propuestos
?? Inserci�n y Mantenimiento
Crear un procedimiento almacenado que registre un nuevo indicador, validando que el responsable y el sistema fuente existan.

Crear un procedimiento que permita ingresar un nuevo registro diario de indicador y calcule autom�ticamente su desviaci�n (insertando en la tabla desviaciones_indicador).

Crear un procedimiento para actualizar la informaci�n de una sucursal (por ejemplo, tel�fono y direcci�n).

Crear un procedimiento para cambiar el responsable de un sistema fuente.

?? Consultas y Reportes
Crear un procedimiento que liste todos los indicadores que han superado el 90% de cumplimiento en la �ltima semana.

Crear un procedimiento que muestre un resumen de indicadores por sucursal, incluyendo:

Total reportes diarios

Promedio valor_real

Porcentaje promedio de cumplimiento

Crear un procedimiento que muestre las desviaciones de un indicador espec�fico en un rango de fechas.

?? An�lisis y Procesamiento
Crear un procedimiento que genere la clasificaci�n autom�tica de desviaciones seg�n su porcentaje (si a�n no tienen clasificaci�n).

Crear un procedimiento que revise los indicadores reportados sin meta (valor_meta IS NULL) y registre una alerta.

Crear un procedimiento para generar un ranking de las 5 sucursales con mayor cantidad de desviaciones altas en el mes actual.
*/