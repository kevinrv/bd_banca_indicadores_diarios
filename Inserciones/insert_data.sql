USE bd_banca_indicadores_diarios;
GO

--Insercion de datos

SELECT*FROM responsables;

INSERT INTO responsables (cod_empleado,cargo,unidad,fecha_inicio,fecha_fin)
VALUES('E001', 'Data Analyst','Ingeniería', '2025-05-25',NULL);