-- Creaci�n de la base de datos

CREATE DATABASE bd_banca_indicadores_diarios;
GO
-- Seleccionar la base de datos
USE bd_banca_indicadores_diarios;
GO
/**/
-- Creaci�n de la tabl "sucursales"
CREATE TABLE sucursales (
id INT IDENTITY(1,1) PRIMARY KEY,
codigo VARCHAR(10) UNIQUE NOT NULL,
nombre VARCHAR(155) NOT NULL,
ciudad VARCHAR(100) NOT NULL,
region VARCHAR(100) NOT NULL,
direccion VARCHAR(255) NULL,
estado VARCHAR(25) NOT NULL,
telefono VARCHAR(25) NULL
);

-- Creaci�n de la tabl "horas"
CREATE TABLE horas (
id INT IDENTITY(1,1) PRIMARY KEY,
dia VARCHAR(25) NOT NULL,
hora_inicio TIME NOT NULL,
hora_fin TIME NOT NULL
);

-- Creaci�n de la tabl "responsables"

CREATE TABLE responsables (
id INT IDENTITY(1,1) PRIMARY KEY,
cod_empleado CHAR(6) UNIQUE NOT NULL,
cargo VARCHAR(100) NOT NULL,
unidad VARCHAR(100) NOT NULL,
fecha_inicio DATE NOT NULL,
fecha_fin DATE NULL
);


-- Creaci�n de la tabl "sistemas_fuente"
CREATE TABLE sistemas_fuente (
id INT IDENTITY(1,1) PRIMARY KEY,
responsable_id INT,
nombre VARCHAR(155) NOT NULL,
descripcion VARCHAR(MAX) NULL,
version VARCHAR(20) NULL,
area Varchar(100) NOT NULL,
CONSTRAINT fk_sistema_fuente_responsable FOREIGN KEY (responsable_id) REFERENCES responsables(id)
);

--EXEC SP_HELP sistemas_fuente;


-- Creaci�n de la tabla "horarios"

CREATE TABLE horarios(
id INT IDENTITY(1,1) PRIMARY KEY,
sucursal_id INT NOT NULL,
hora_id INT NOT NULL,
estado VARCHAR (55),
fecha_registro DATETIME DEFAULT GETDATE(),
FOREIGN KEY (sucursal_id) REFERENCES sucursales(id)
);
---- Modificar la estructura de la tabla con ALTER TABLE
ALTER TABLE horarios
ADD FOREIGN KEY (hora_id) REFERENCES horas(id);

--EXEC SP_HELP horarios;
--SELECT GETDATE();

--- Creaci�n de la tabla "Indicadores"

CREATE TABLE indicadores (
id INT IDENTITY(1,1) PRIMARY KEY,
responsable_id INT NOT NULL,
sistema_fuente_id INT NOT NULL,
nombre VARCHAR (255) NOT NULL,
descripcion VARCHAR(MAX),
unidad_medida VARCHAR(100),
categoria VARCHAR(100),
FOREIGN KEY (responsable_id) REFERENCES responsables(id),
FOREIGN KEY (sistema_fuente_id) REFERENCES sistemas_fuente(id)
);

--- Crear tabla registros_diarios_indicadores
CREATE TABLE registros_diarios_indicadores (
id INT IDENTITY(1,1) PRIMARY KEY,
sucursal_id INT NOT NULL,
indicador_id INT NOT NULL,
valor_meta DECIMAL(9,2),
valor_real DECIMAL(9,2) NOT NULL,
fecha_reporte DATETIME NOT NULL,
FOREIGN KEY (sucursal_id) REFERENCES sucursales(id),
FOREIGN KEY (indicador_id) REFERENCES indicadores(id)
);

--- CREAR TABLA indicadores_horario

CREATE TABLE indicadores_horario (
id INT IDENTITY(1,1) PRIMARY KEY,
horario_inicio_id INT NOT NULL,
horario_fin_id INT NOT NULL,
indicador_id INT NOT NULL,
fecha_reporte DATETIME DEFAULT GETDATE() NOT NULL,
valor DECIMAL(9,2) NOT NULL,
FOREIGN KEY (horario_inicio_id) REFERENCES horarios(id),
FOREIGN KEY (horario_fin_id) REFERENCES horarios(id),
FOREIGN KEY (indicador_id) REFERENCES indicadores(id)
);


---- Crear tabla desviaciones_indicador

CREATE TABLE desviaciones_indicador (
id INT IDENTITY(1,1) PRIMARY KEY,
registro_diario_indicador_id INT NOT NULL,
diferencia_absoluta DECIMAL(9,2)  NOT NULL,
diferencia_porcentual DECIMAL(9,2) NOT NULL,
clasificacion VARCHAR (100) NOT NULL,
FOREIGN KEY (registro_diario_indicador_id) REFERENCES registros_diarios_indicadores(id)
);