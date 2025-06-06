USE bd_banca_indicadores_diarios;
GO

/*
🔧 FUNCIONES ESCALARES Y DE TABLA – Ejercicios Propuestos
🔹 Funciones Escalares
Crear una función que reciba un id de sucursal y devuelva su nombre completo (nombre + ciudad + región).*/

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

Crear una función que reciba los valores real y meta de un indicador y devuelva el porcentaje de cumplimiento.*/

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

Crear una función que retorne la clasificación de una desviación dado su valor porcentual.*/

SELECT*FROM desviaciones_indicador;
CREATE FUNCTION fn_ClasificacionDesviacion
( @valor_real DECIMAL(9,2), @valor_meta DECIMAL(9,2))
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE @clasificacion VARCHAR(255);
    DECLARE @desviacion DECIMAL(9,2);
 
    IF @valor_meta = 0
        SET @clasificacion = 'Sin Meta'; -- opcional, evita división por cero
    ELSE
    BEGIN
        SET @desviacion = (ABS(@valor_real - @valor_meta) / @valor_meta) * 100;
        SET @clasificacion =
            CASE
                WHEN @desviacion >= 30 THEN 'Crítica'
                WHEN @desviacion >= 20 THEN 'Alta'
                WHEN @desviacion >= 10 THEN 'Moderada'
                WHEN @desviacion > 0 THEN 'Baja'
                ELSE 'Sin Desviación'
            END;
    END
    RETURN @clasificacion;
END;

SELECT dbo.fn_ClasificacionDesviacion(15,100);

/*

Crear una función que indique si un responsable aún está activo (fecha_fin es NULL o mayor a la fecha actual).*/

CREATE FUNCTION fn_kv_estado_responsable (@responsable_id INT)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @estado VARCHAR(20)
	DECLARE @fecha_fin DATE

	SELECT @fecha_fin = fecha_fin
	FROM responsables WHERE id=@responsable_id

    IF @fecha_fin IS NULL OR @fecha_fin > GETDATE()
        SET @estado = 'Activo'
    ELSE
        SET @estado = 'Inactivo'
    RETURN @estado
END

SELECT *, dbo.fn_kv_estado_responsable(id) AS estado_responsable
FROM responsables;

CREATE FUNCTION fn_kv_Responsable_estado (@fecha_fin DATE)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @estado VARCHAR(20)
    IF @fecha_fin IS NULL OR @fecha_fin > GETDATE()
        SET @estado = 'Activo'
    ELSE
        SET @estado = 'Inactivo'
    RETURN @estado
END
SELECT *, dbo.fn_kv_Responsable_estado(fecha_fin) AS estado_responsable
FROM responsables;

/*

Crear una función que calcule el tiempo total (en minutos) entre hora_inicio y hora_fin de un registro de la tabla horas.

🔹 Funciones de Tabla
Crear una función de tabla que retorne todos los indicadores registrados para una sucursal específica en una fecha dada.*/

SELECT
s.id,
	s.nombre AS 'Sucursal',
	i.nombre AS 'Indicador',
	rdi.fecha_reporte AS 'Fecha'
FROM sucursales s 
INNER JOIN registros_diarios_indicadores rdi ON rdi.sucursal_id=s.id
INNER JOIN indicadores i ON i.id=rdi.indicador_id


ALTER FUNCTION fn_kv_indicadores_registrados (@sucursal_id INT, @fecha DATE)
RETURNS TABLE 
AS
RETURN(SELECT
	s.nombre AS 'Sucursal',
	i.nombre AS 'Indicador',
	rdi.fecha_reporte AS 'Fecha'
FROM sucursales s 
INNER JOIN registros_diarios_indicadores rdi ON rdi.sucursal_id=s.id
INNER JOIN indicadores i ON i.id=rdi.indicador_id
WHERE s.id=@sucursal_id AND CONVERT(DATE,rdi.fecha_reporte)=@fecha) --SUBSTRING(CAST(rdi.fecha_reporte AS VARCHAR(100)),1,11)=CAST(@fecha AS VARCHAR(100)))

SELECT*FROM dbo.fn_kv_indicadores_registrados(5,'2024-04-26')


SELECT CONVERT(DATE,rdi.fecha_reporte,2),SUBSTRING(CAST(rdi.fecha_reporte AS VARCHAR(100)),1,11),fecha_reporte
FROM registros_diarios_indicadores rdi;
/*

Crear una función de tabla que devuelva los registros diarios de indicadores con desviaciones clasificadas como 
“Alta” en el último mes(mes actual).*/
CREATE FUNCTION fn_kv_desviaciones_altas_mes_actual()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        s.nombre AS Sucursal,
        i.nombre AS Indicador,
        rdi.fecha_reporte AS Fecha,
        rdi.valor_meta AS ValorMeta,
        rdi.valor_real AS ValorReal,
        di.diferencia_absoluta AS DifAbsoluta,
        di.diferencia_porcentual AS DifPorcentual,
        di.clasificacion AS Clasificacion
    FROM registros_diarios_indicadores rdi
    INNER JOIN desviaciones_indicador di ON di.registro_diario_indicador_id = rdi.id
    INNER JOIN sucursales s ON s.id = rdi.sucursal_id
    INNER JOIN indicadores i ON i.id = rdi.indicador_id
    WHERE di.clasificacion = 'Alta'
      AND YEAR(rdi.fecha_reporte) = YEAR(GETDATE()) AND MONTH(rdi.fecha_reporte) = MONTH(GETDATE())
);

SELECT*FROM fn_kv_desviaciones_altas_mes_actual()
/*

Crear una función de tabla que devuelva los registros diarios de indicadores con desviaciones clasificadas como 
“Alta” en el último mes(ultimos 30 días).*/
CREATE FUNCTION fn_kv_desviaciones_altas_ultimo_mes()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        s.nombre AS Sucursal,
        i.nombre AS Indicador,
        rdi.fecha_reporte AS Fecha,
        rdi.valor_meta AS ValorMeta,
        rdi.valor_real AS ValorReal,
        di.diferencia_absoluta AS DifAbsoluta,
        di.diferencia_porcentual AS DifPorcentual,
        di.clasificacion AS Clasificacion
    FROM registros_diarios_indicadores rdi
    INNER JOIN desviaciones_indicador di ON di.registro_diario_indicador_id = rdi.id
    INNER JOIN sucursales s ON s.id = rdi.sucursal_id
    INNER JOIN indicadores i ON i.id = rdi.indicador_id
    WHERE di.clasificacion = 'Alta'
      AND CAST(rdi.fecha_reporte AS DATE) >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
);
SELECT * FROM dbo.fn_kv_desviaciones_altas_ultimo_mes();
/*

Crear una función de tabla que muestre el historial de indicadores de un sistema fuente específico.*/


CREATE FUNCTION fn_kv_historial_indicadores_por_sistema_fuente(@sistema_fuente_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        sf.nombre AS SistemaFuente,
        s.nombre AS Sucursal,
        i.nombre AS Indicador,
        rdi.fecha_reporte AS Fecha,
        rdi.valor_meta AS ValorMeta,
        rdi.valor_real AS ValorReal
    FROM sistemas_fuente sf
    INNER JOIN indicadores i ON i.sistema_fuente_id = sf.id
    INNER JOIN registros_diarios_indicadores rdi ON rdi.indicador_id = i.id
    INNER JOIN sucursales s ON s.id = rdi.sucursal_id
    WHERE sf.id = @sistema_fuente_id
);
SELECT * FROM dbo.fn_kv_historial_indicadores_por_sistema_fuente(3);



/*


⚙️ PROCEDIMIENTOS ALMACENADOS – Ejercicios Propuestos
🔹 Inserción y Mantenimiento
Crear un procedimiento almacenado que registre un nuevo indicador, validando que el responsable y el sistema fuente existan.*/

CREATE PROCEDURE sp_kv_registrar_indicador
	@id_responsable INT,
	@id_sistema_fuente INT,
	@nombre VARCHAR(255),
	@descripcion VARCHAR(MAX),
	@unidad_medida VARCHAR(100),
	@categoria VARCHAR(100)
AS 
	SET NOCOUNT ON;

	IF @id_responsable = (SELECT id FROM responsables WHERE id=@id_responsable)
		IF @id_sistema_fuente = (SELECT id FROM sistemas_fuente WHERE id=@id_sistema_fuente)
			INSERT INTO indicadores VALUES(@id_responsable,@id_sistema_fuente,@nombre,@descripcion,@unidad_medida,@categoria);
		ELSE
			PRINT 'EL SISTEMA FUENTE NO EXISTE'
	ELSE
		PRINT 'EL RESPONSABLE INGRESADO NO EXISTE'
GO

EXEC dbo.sp_kv_registrar_indicador 2,200,'test1','test 1','Porcentaje','Eficiencia';


SELECT*FROM indicadores;

SELECT*FROM sistemas_fuente;
/*

Crear un procedimiento que permita ingresar un nuevo registro diario de indicador y calcule automáticamente 
su desviación (insertando en la tabla desviaciones_indicador).*/


ALTER PROCEDURE sp_insertar_registro_diario_con_desviacion    @sucursal_id INT,    @indicador_id INT,    @valor_meta DECIMAL(9,2),    @valor_real DECIMAL(9,2)    AS    SET NOCOUNT ON;	DECLARE @last_rdi_id INT;	IF @sucursal_id = (SELECT id FROM sucursales WHERE id=@sucursal_id)
		IF @indicador_id = (SELECT id FROM indicadores WHERE id=@indicador_id)			INSERT INTO registros_diarios_indicadores (sucursal_id, indicador_id, valor_meta, valor_real, fecha_reporte)			VALUES (@sucursal_id, @indicador_id, @valor_meta, @valor_real, GETDATE());
		ELSE
			PRINT 'EL INDICADOR INGRESADO NO EXISTE'
	ELSE
		PRINT 'LA SUCURSAL INGRESADA NO EXISTE'
	
	SET @last_rdi_id = (SELECT MAX(id) FROM registros_diarios_indicadores);

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
	FROM registros_diarios_indicadores
	WHERE id=@last_rdi_id;
GO

EXEC dbo.sp_insertar_registro_diario_con_desviacion 8,11,'7880000.00','5265055'

SELECT*FRom sucursales;

SELECT*FROM registros_diarios_indicadores;
SELECT*FROM desviaciones_indicador;
/*

Crear un procedimiento para actualizar la información de una sucursal (por ejemplo, teléfono y dirección).*/


CREATE PROCEDURE sp_actualizar_sucursal    @id_sucursal INT,    @nueva_direccion VARCHAR(255),    @nuevo_telefono VARCHAR(25)ASBEGIN    SET NOCOUNT ON;    UPDATE sucursales    SET        direccion = @nueva_direccion,        telefono = @nuevo_telefono    WHERE id = @id_sucursal;END;GO

SELECT*FROM sucursales;

EXEC sp_actualizar_sucursal 5,'Av. Los Laureles 456','01-7890135'

/*

Crear un procedimiento para cambiar el responsable de un sistema fuente.*/
CREATE PROCEDURE sp_cambiar_responsable_sistema_fuente    @id_sistema_fuente INT,    @id_responsable INTASBEGIN    SET NOCOUNT ON;    IF @id_responsable = (SELECT id FROM responsables WHERE id = @id_responsable)    BEGIN        IF @id_sistema_fuente = (SELECT id FROM sistemas_fuente WHERE id = @id_sistema_fuente)        BEGIN            UPDATE sistemas_fuente            SET responsable_id = @id_responsable            WHERE id = @id_sistema_fuente;            PRINT 'Responsable actualizado correctamente.';        END        ELSE        BEGIN            PRINT 'EL SISTEMA FUENTE NO EXISTE';        END    END    ELSE    BEGIN        PRINT 'EL RESPONSABLE INGRESADO NO EXISTE';    ENDEND;GO


SELECT*FROM sistemas_fuente;


EXEC sp_cambiar_responsable_sistema_fuente 8,11
/*

🔹 Consultas y Reportes
Crear un procedimiento que liste todos los indicadores que han superado el 90% de cumplimiento en la última semana.

Crear un procedimiento que muestre un resumen de indicadores por sucursal, incluyendo:

Total reportes diarios

Promedio valor_real

Porcentaje promedio de cumplimiento*/

ALTER PROCEDURE sp_kv_resumen_indicadores_sucursal 
 @sucursal_id INT,
 @fecha DATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @total_reportes_diarios INT;
	DECLARE @promedio_cumplimiento DECIMAL(9,2);
	DECLARE @promedio_vr_indice DECIMAL(9,2);
	DECLARE @promedio_vr_moneda DECIMAL(9,2);
	DECLARE @promedio_vr_num DECIMAL(9,2);
	DECLARE @promedio_vr_porcentaje DECIMAL(9,2);
	DECLARE @promedio_vr_ratio DECIMAL(9,2);
	DECLARE @promedio_vr_segundos DECIMAL(9,2);

	--Calcular el valor de @total_reportes_diarios
	SELECT @total_reportes_diarios=COUNT(id)
	FROM registros_diarios_indicadores
	WHERE CONVERT(DATE,fecha_reporte)=@fecha AND sucursal_id=@sucursal_id;

	--Calcular el valor de @promedio_cumplimiento

	SELECT @promedio_cumplimiento=AVG((valor_real/valor_meta)*100)
	FROM registros_diarios_indicadores
	WHERE CONVERT(DATE,fecha_reporte)=@fecha AND sucursal_id=@sucursal_id;

	-- PROMEDIO VALOR REAL Índice

	SELECT @promedio_vr_indice=AVG(rdi.valor_real)
	FROM registros_diarios_indicadores rdi
	INNER JOIN indicadores i ON i.id=rdi.indicador_id
	WHERE 
		CONVERT(DATE,rdi.fecha_reporte)=@fecha AND
		rdi.sucursal_id=@sucursal_id AND
		i.unidad_medida='Índice';
	-- PROMEDIO VALOR REAL Monto (S/.)

	SELECT @promedio_vr_moneda=AVG(rdi.valor_real)
	FROM registros_diarios_indicadores rdi
	INNER JOIN indicadores i ON i.id=rdi.indicador_id
	WHERE 
		CONVERT(DATE,rdi.fecha_reporte)=@fecha AND
		rdi.sucursal_id=@sucursal_id AND
		i.unidad_medida='Monto (S/.)';
	-- PROMEDIO VALOR REAL Número

	SELECT @promedio_vr_num=AVG(rdi.valor_real)
	FROM registros_diarios_indicadores rdi
	INNER JOIN indicadores i ON i.id=rdi.indicador_id
	WHERE 
		CONVERT(DATE,rdi.fecha_reporte)=@fecha AND
		rdi.sucursal_id=@sucursal_id AND
		i.unidad_medida='Número';
	-- PROMEDIO VALOR REAL Porcentaje

	SELECT @promedio_vr_porcentaje=AVG(rdi.valor_real)
	FROM registros_diarios_indicadores rdi
	INNER JOIN indicadores i ON i.id=rdi.indicador_id
	WHERE 
		CONVERT(DATE,rdi.fecha_reporte)=@fecha AND
		rdi.sucursal_id=@sucursal_id AND
		i.unidad_medida='Porcentaje';
	-- PROMEDIO VALOR REAL Ratio

	SELECT @promedio_vr_ratio=AVG(rdi.valor_real)
	FROM registros_diarios_indicadores rdi
	INNER JOIN indicadores i ON i.id=rdi.indicador_id
	WHERE 
		CONVERT(DATE,rdi.fecha_reporte)=@fecha AND
		rdi.sucursal_id=@sucursal_id AND
		i.unidad_medida='Ratio';

	-- PROMEDIO VALOR REAL Segundos
	SELECT @promedio_vr_segundos=AVG(rdi.valor_real)
	FROM registros_diarios_indicadores rdi
	INNER JOIN indicadores i ON i.id=rdi.indicador_id
	WHERE 
		CONVERT(DATE,rdi.fecha_reporte)=@fecha AND
		rdi.sucursal_id=@sucursal_id AND
		i.unidad_medida='Segundos';

SELECT 
	@sucursal_id AS 'sucursal_id',
	@fecha AS 'fecha_analisis',
	@total_reportes_diarios AS 'total_reportes_diarios',
	 @promedio_cumplimiento AS 'promedio_cumplimiento',
	 @promedio_vr_indice AS 'promedio_vr_indice',
	 @promedio_vr_moneda AS 'promedio_vr_moneda',
	 @promedio_vr_num AS 'promedio_vr_num',
	 @promedio_vr_porcentaje AS 'promedio_vr_porcentaje',
	 @promedio_vr_ratio AS 'promedio_vr_ratio',
	 @promedio_vr_segundos AS 'promedio_vr_segundos';

END;


EXEC dbo.sp_kv_resumen_indicadores_sucursal 1,'2024-11-30';

SELECT*FROM sucursales;
SELECT*FROM registros_diarios_indicadores;
SELECT DISTINCT unidad_medida FROM indicadores
/*

Crear un procedimiento que muestre las desviaciones de un indicador específico en un rango de fechas.

🔹 Análisis y Procesamiento
Crear un procedimiento que genere la clasificación automática de desviaciones según su porcentaje (si aún no tienen clasificación).

Crear un procedimiento que revise los indicadores reportados sin meta (valor_meta IS NULL) y registre una alerta.

Crear un procedimiento para generar un ranking de las 5 sucursales con mayor cantidad de desviaciones altas en el mes actual.
*/