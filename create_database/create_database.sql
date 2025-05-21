-- Creación de la base de datos

CREATE DATABASE bd_banca_indicadores_diarios;
GO
-- Seleccionar la base de datos
USE bd_banca_indicadores_diarios;
GO

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

CREATE TABLE horas (
id INT IDENTITY(1,1) PRIMARY KEY,
dia VARCHAR(25) NOT NULL,
hora_inicio TIME NOT NULL,
hora_fin TIME NOT NULL
);

CREATE TABLE responsables (
id INT IDENTITY(1,1) PRIMARY KEY,
cod_empleado CHAR(6) UNIQUE NOT NULL,
cargo VARCHAR(100) NOT NULL,
unidad VARCHAR(100) NOT NULL,
fecha_inicio DATE NOT NULL,
fecha_fin DATE NULL
);

CREATE TABLE sistemas_fuente (
id INT IDENTITY(1,1) PRIMARY KEY,
responsable_id INT,
nombre VARCHAR(155) NOT NULL,
descripcion VARCHAR(MAX) NULL,
version VARCHAR(20) NULL,
area Varchar(100) NOT NULL,
CONSTRAINT fk_sistema_fuente_responsable FOREIGN KEY (responsable_id) REFERENCES responsables(id)
);
