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

SELECT*FROM sucursales;
