Use bd_banca_indicadores_diarios;

SELECT
    r.fecha_reporte,
    r.sucursal_id,
    s.nombre AS 'Sucursal',
    r.indicador_id,
    i.nombre AS 'Indicador',
    di.diferencia_porcentual,
    AVG(di.diferencia_porcentual) OVER (
        PARTITION BY r.sucursal_id, r.indicador_id, YEAR(r.fecha_reporte), MONTH(r.fecha_reporte)
    ) AS promedio_mensual_desviacion
FROM 
    registros_diarios_indicadores r
    JOIN sucursales s ON r.sucursal_id = s.id
    JOIN indicadores i ON r.indicador_id = i.id
    JOIN desviaciones_indicador di ON di.registro_diario_indicador_id = r.id
WHERE 
    r.fecha_reporte BETWEEN '2025-04-01' AND '2025-04-30'
ORDER BY 
    r.sucursal_id, r.indicador_id, r.fecha_reporte;

-- Triguer

drop table bitacora_registros_diarios;
CREATE TABLE bitacora_registros_diarios (
    id INT IDENTITY PRIMARY KEY,
    registro_diario_id INT,
    sucursal_id INT,
    indicador_id INT,
    fecha_reporte DATE,
    usuario NVARCHAR(100),
	accion NVARCHAR(100),
    fecha_auditoria DATETIME DEFAULT GETDATE()

);

CREATE TRIGGER trg_Auditoria_RegistrosDiarios
ON registros_diarios_indicadores
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Manejar INSERT
    INSERT INTO bitacora_registros_diarios (
        registro_diario_id,
        sucursal_id,
        indicador_id,
        fecha_reporte,
        accion,
        usuario
    )
    SELECT 
        i.id,
        i.sucursal_id,
        i.indicador_id,
        i.fecha_reporte,
        'INSERT',
        SYSTEM_USER
    FROM inserted i
    WHERE NOT EXISTS (
        SELECT 1 FROM deleted d WHERE d.id = i.id
    );

    -- Manejar UPDATE
    INSERT INTO bitacora_registros_diarios (
        registro_diario_id,
        sucursal_id,
        indicador_id,
        fecha_reporte,
        accion,
        usuario
    )
    SELECT 
        i.id,
        i.sucursal_id,
        i.indicador_id,
        i.fecha_reporte,
        'UPDATE',
        SYSTEM_USER
    FROM inserted i
    INNER JOIN deleted d ON i.id = d.id;

    -- Manejar DELETE
    INSERT INTO bitacora_registros_diarios (
        registro_diario_id,
        sucursal_id,
        indicador_id,
        fecha_reporte,
        accion,
        usuario
    )
    SELECT 
        d.id,
        d.sucursal_id,
        d.indicador_id,
        d.fecha_reporte,
        'DELETE',
        SYSTEM_USER
    FROM deleted d
    WHERE NOT EXISTS (
        SELECT 1 FROM inserted i WHERE i.id = d.id
    );
END;

SELECT*FROM bitacora_registros_diarios;


UPDATE registros_diarios_indicadores SET valor_real='123121'
WHERE id=15

INSERT INTO registros_diarios_indicadores 
VALUES (5,6,15,10,GETDATE());

DELETE FROM registros_diarios_indicadores WHERE id = '10133'


SELECT*FROM registros_diarios_indicadores;

---ejemplo cursor

DECLARE @nombreSucursal NVARCHAR(100);
DECLARE @id NVARCHAR(100);
DECLARE @result DATETIME;

-- Declarar el cursor
DECLARE cursor_sucursales CURSOR FOR
SELECT id ,nombre FROM sucursales;

-- Abrir el cursor
OPEN cursor_sucursales;

-- Obtener la primera fila
FETCH NEXT FROM cursor_sucursales INTO @id, @nombreSucursal;

-- Recorrer todas las filas
WHILE @@FETCH_STATUS = 0
BEGIN
	
	SET @result=(SELECT MAX(fecha_reporte) FROM registros_diarios_indicadores WHERE sucursal_id=@id)

    PRINT '|Sucursal: ' + @nombreSucursal +'|Fecha de ultimo reporte:' + CONVERT(VARCHAR(255),@result);

	

    -- Siguiente fila
    FETCH NEXT FROM cursor_sucursales INTO @id, @nombreSucursal;
END;

-- Cerrar y liberar recursos
CLOSE cursor_sucursales;
DEALLOCATE cursor_sucursales;
