DROP DATABASE IF EXISTS repositorio_pozos;
CREATE DATABASE repositorio_pozos;

USE repositorio_pozos;

CREATE TABLE repositorio_pozos.pozos(
	pozo_id VARCHAR (100) UNIQUE primary key,
    pad INT NOT NULL,
    costo_total DECIMAL (10,2),
    frac_id INT NOT NULL,
    perfo_id INT NOT NULL,
    locacion_id INT NOT NULL,
    fpem DATE
);
CREATE TABLE repositorio_pozos.zona(
	zona_id INT NOT NULL auto_increment primary key,
    pozo_id VARCHAR (100) UNIQUE,
    tipo_zona ENUM('Dry Gas','Wet Gas','Volatalile Oil','Black Oil'),
    yacimiento VARCHAR (100)
);
CREATE TABLE repositorio_pozos.prod(
	indice_prod INT NOT NULL auto_increment primary key,
    pozo_dia VARCHAR (100) UNIQUE,
    prod_gas DECIMAL (10,2),
    prod_oil DECIMAL (10,2),
    prod_agua DECIMAL (10,2),
    fecha_prod DATE
);
CREATE TABLE repositorio_pozos.perforacion(
	perfo_id VARCHAR (100) UNIQUE primary key,
    fecha_perfo DATE,
    costo_perfo DECIMAL (10,2),
    tiempo_perfo DECIMAL (10,2),
    prof_ver DECIMAL (10,2),
    prof_hor DECIMAL (10,2)
);
CREATE TABLE repositorio_pozos.completacion(
	comple_id INT NOT NULL auto_increment primary key,
    fecha_comple DATE,
    costo_comple DECIMAL (10,2),
    tiempo_comple DECIMAL (10,2),
    intensidad_frac INT NOT NULL
);
CREATE TABLE repositorio_pozos.locacion(
	locacion_id INT NOT NULL auto_increment primary key,
    fecha_locacion DATE,
    costo_locacion DECIMAL (10,2),
    tiempo_locacion DECIMAL (10,2)
);
CREATE TABLE repositorio_pozos.prod_pozos(
	pozo_dia VARCHAR (100) UNIQUE primary key,
    pozo_id VARCHAR (100) UNIQUE
);

