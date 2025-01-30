DROP DATABASE IF EXISTS repositorio_pozos;
CREATE DATABASE repositorio_pozos;

USE repositorio_pozos;

-- Creación de tablas
CREATE TABLE repositorio_pozos.perforacion(
	perfo_id INT NOT NULL auto_increment primary key,
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
CREATE TABLE repositorio_pozos.pozos(
	pozo_id VARCHAR (100) UNIQUE primary key,
    pad INT NOT NULL,
    frac_id INT NOT NULL,
    perfo_id INT NOT NULL,
    locacion_id INT NOT NULL,
    fpem DATE,
    FOREIGN KEY (frac_id) REFERENCES repositorio_pozos.completacion(comple_id),
    FOREIGN KEY (perfo_id) REFERENCES repositorio_pozos.perforacion(perfo_id),
    FOREIGN KEY (locacion_id) REFERENCES repositorio_pozos.locacion(locacion_id)
);
CREATE TABLE repositorio_pozos.zona(
	zona_id INT NOT NULL auto_increment primary key,
    pozo_id VARCHAR (100),
    tipo_zona ENUM('Dry Gas','Wet Gas','Volatalile Oil','Black Oil'),
    yacimiento VARCHAR (100),
    FOREIGN KEY (pozo_id) REFERENCES repositorio_pozos.pozos(pozo_id) ON DELETE CASCADE
);
CREATE TABLE repositorio_pozos.prod_pozos(
	pozo_id VARCHAR (100),
    pozo_dia VARCHAR (100) UNIQUE primary key,
    FOREIGN KEY (pozo_id) REFERENCES repositorio_pozos.pozos(pozo_id) ON DELETE CASCADE
);
CREATE TABLE repositorio_pozos.prod(
	indice_prod INT NOT NULL auto_increment primary key,
    pozo_dia VARCHAR (100) UNIQUE,
    prod_gas DECIMAL (10,2),
    prod_oil DECIMAL (10,2),
    prod_agua DECIMAL (10,2),
    fecha_prod DATE,
    FOREIGN KEY (pozo_dia) REFERENCES repositorio_pozos.prod_pozos(pozo_dia) ON DELETE CASCADE
);

-- Carga de datos
SET GLOBAL local_infile=ON;
LOAD DATA LOCAL INFILE 'C:/Users/nicom/OneDrive/Documentos/SQL/Perfora.csv'
INTO TABLE repositorio_pozos.perforacion
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/nicom/OneDrive/Documentos/SQL/comple.csv'
INTO TABLE repositorio_pozos.completacion
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/nicom/OneDrive/Documentos/SQL/locacion.csv'
INTO TABLE repositorio_pozos.locacion
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/nicom/OneDrive/Documentos/SQL/pozos.csv'
INTO TABLE repositorio_pozos.pozos
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/nicom/OneDrive/Documentos/SQL/zona.csv'
INTO TABLE repositorio_pozos.zona
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/nicom/OneDrive/Documentos/SQL/prod_aux.csv'
INTO TABLE repositorio_pozos.prod_pozos
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/nicom/OneDrive/Documentos/SQL/prod.csv'
INTO TABLE repositorio_pozos.prod
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES;
