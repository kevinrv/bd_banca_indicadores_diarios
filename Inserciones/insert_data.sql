USE bd_banca_indicadores_diarios;
GO

--Insercion de datos
--- Responsables
SELECT * FROM responsables;

INSERT INTO responsables (cod_empleado,cargo,unidad,fecha_inicio,fecha_fin)
VALUES('E001', 'Data Analyst','Ingeniería', '2025-05-25',NULL);

--- Sistemas fuente

SELECT*FROM sistemas_fuente;

INSERT INTO sistemas_fuente (responsable_id, nombre, descripcion,version, area) 
VALUES ('2','Sistema de transacciones', 'Registro de transacciones diarias', '1.0', 'Ventas');

---Eliminar datos Tabla
DELETE FROM sistemas_fuente;

---Resetear el ID de una tabla
DBCC CHECKIDENT ('sistemas_fuente', RESEED, 0);


---Indicadores

SELECT*FROM indicadores;
DELETE FROM indicadores;
INSERT INTO indicadores (responsable_id, sistema_fuente_id,nombre, descripcion, unidad_medida, categoria)
VALUES (2,1,'Transacciones diarias','Número de transacciones diarias','cantidad','Transacciones bancarias');


--- horas 
SELECT*FROM horas;
DELETE FROM horas;

DBCC CHECKIDENT ('horas', RESEED, 0);
UPDATE horas SET dia = 'sabado' WHERE id > 120;
INSERT INTO horas (dia, hora_inicio, hora_fin) VALUES ('Lunes','00:00:00','01:00:00');

SELECT HOUR(GETDATE());
--- Horarios
SELECT*FROM sucursales;
SELECT*FROM horarios;



--- Insertar horarios de L-V para todas las usucrsales
DECLARE @COUNTER INT;

SET @COUNTER=1

WHILE @COUNTER <= 20
BEGIN
INSERT INTO horarios
SELECT 
	@COUNTER AS 'sucursal_id',
	id AS 'hora_id',
	'activo' AS 'estado', 
	GETDATE() AS 'fecha_registro'
FROM horas
WHERE 
	dia NOT IN ('sabado') AND 
	hora_inicio >= '09:00:00' AND 
	hora_inicio < '18:00:00';
SET @COUNTER=@COUNTER+1;

END

--- Insertar horarios de S para todas las sucursales
DECLARE @COUNTER INT;

SET @COUNTER=1

WHILE @COUNTER <= 20
BEGIN
INSERT INTO horarios
SELECT 
	@COUNTER AS 'sucursal_id',
	id AS 'hora_id',
	'activo' AS 'estado', 
	GETDATE() AS 'fecha_registro'
FROM horas
WHERE 
	dia IN ('sabado') AND 
	hora_inicio >= '09:00:00' AND 
	hora_inicio < '13:00:00';
SET @COUNTER=@COUNTER+1;

END

--- Indicadores Horarios
SELECT*FROM indicadores_horario;

DECLARE @Counter INT
SET @Counter = 0

WHILE @Counter < ROUND(RAND()*5000,0)
BEGIN
INSERT INTO indicadores_horario(horario_inicio_id, horario_fin_id, indicador_id, fecha_reporte, valor)
SELECT 
  hi.id AS 'horario_inicio_id',
  hi.id + ROUND(RAND()*8,0)+1 AS 'horario_fin_id',
  i.id AS 'indicador_id',
  DATEADD(DAY, -ROUND(RAND() * 780,0), GETDATE()) AS 'fecha_reporte', -- Fecha de reporte en los últimos 2 años
  CASE 
	WHEN i.unidad_medida ='Índice' THEN ROUND(RAND()*4,1)+1
	WHEN i.unidad_medida ='Monto (S/.)' THEN ROUND(RAND()*500000,2)+50000
	WHEN i.unidad_medida ='Número' THEN ROUND(RAND()*5000,0)+1000
	WHEN i.unidad_medida ='Porcentaje' THEN ROUND(RAND()*150,2)
	WHEN i.unidad_medida ='Ratio' THEN ROUND(RAND(),3)
	WHEN i.unidad_medida ='Segundos' THEN ROUND(RAND()*300,1)+30
  ELSE '0' END AS 'valor'
FROM indicadores i
CROSS JOIN horarios hi 
WHERE hi.estado ='activo'
ORDER BY NEWID()
OFFSET 0 ROWS
FETCH NEXT 1 ROWS ONLY;
    SET @Counter = @Counter + 1
END;

SELECT * FROM indicadores WHERE unidad_medida='Porcentaje';

SELECT RAND();

--- Registros Diarios Indicadores