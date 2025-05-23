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

INSERT INTO horarios
SELECT 
	3 AS 'sucursal_id',
	id AS 'hora_id',
	'activo' AS 'estado', 
	GETDATE() AS 'fecha_registro'
FROM horas
WHERE 
	dia NOT IN ('sabado') AND 
	hora_inicio >= '09:00:00' AND 
	hora_inicio < '18:00:00';
