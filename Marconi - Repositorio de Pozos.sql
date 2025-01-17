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

-- Creación de vistas

CREATE VIEW v_costo AS
	SELECT
	p.pozo_id as Pozos,
	perf.costo_perfo+comp.costo_comple+loc.costo_locacion as "Costo total pozo"
	FROM repositorio_pozos.pozos p
	INNER JOIN repositorio_pozos.perforacion perf ON (perf.perfo_id=p.perfo_id)
	INNER JOIN repositorio_pozos.completacion comp ON (comp.comple_id=p.frac_id)
    INNER JOIN repositorio_pozos.locacion loc ON (loc.locacion_id=p.locacion_id);

CREATE VIEW v_tiempo AS
	SELECT
	p.pozo_id as Pozo,
	perf.tiempo_perfo+comp.tiempo_comple+loc.tiempo_locacion as "Tiempo total pozo"
	FROM repositorio_pozos.pozos p
	INNER JOIN repositorio_pozos.perforacion perf ON (perf.perfo_id=p.perfo_id)
	INNER JOIN repositorio_pozos.completacion comp ON (comp.comple_id=p.frac_id)
    INNER JOIN repositorio_pozos.locacion loc ON (loc.locacion_id=p.locacion_id);

CREATE VIEW v_prod_mensual AS
		SELECT
		p.pozo_id as "Pozo",
        f_produce(AVG(d.prod_gas)) AS "Estado de pozo",
		ROUND(AVG(d.prod_gas),0) as "Prod gas",
		ROUND(AVG(d.prod_oil),0) as "Prod oil",
		ROUND(AVG(d.prod_agua),0) as "Prod agua",
        MONTH(d.fecha_prod) as "Mes"
		FROM repositorio_pozos.prod_pozos p
		INNER JOIN repositorio_pozos.prod d ON (d.pozo_dia=p.pozo_dia)
		GROUP BY MONTH(d.fecha_prod), p.pozo_id
        ORDER BY p.pozo_id;

CREATE VIEW v_prod_yacimiento AS
		SELECT
		y.yacimiento as "Yacimiento",
        ROUND(SUM(d.prod_gas),0) as "Prod gas",
		ROUND(SUM(d.prod_oil),0) as "Prod oil",
		ROUND(SUM(d.prod_agua),0) as "Prod agua",
        MONTH(d.fecha_prod) as "Mes"
		FROM repositorio_pozos.prod_pozos p
		INNER JOIN repositorio_pozos.prod d ON (d.pozo_dia=p.pozo_dia)
        INNER JOIN repositorio_pozos.zona y ON (y.pozo_id=p.pozo_id)
		GROUP BY MONTH(d.fecha_prod), y.yacimiento
        ORDER BY y.yacimiento;

CREATE VIEW v_inversion_yacimiento AS
		SELECT
		y.yacimiento as "Yacimiento",
        SUM(perf.costo_perfo+comp.costo_comple+loc.costo_locacion) as "Inversión [Mill.US$]",
        MONTH(d.fecha_prod) as "Mes"
        FROM repositorio_pozos.pozos p
        INNER JOIN repositorio_pozos.prod_pozos pd ON (pd.pozo_id=p.pozo_id)
        INNER JOIN repositorio_pozos.perforacion perf ON (perf.perfo_id=p.perfo_id)
		INNER JOIN repositorio_pozos.completacion comp ON (comp.comple_id=p.frac_id)
		INNER JOIN repositorio_pozos.locacion loc ON (loc.locacion_id=p.locacion_id)
        INNER JOIN repositorio_pozos.zona y ON (y.pozo_id=p.pozo_id)
        INNER JOIN repositorio_pozos.prod d ON (d.pozo_dia=pd.pozo_dia)
        GROUP BY MONTH(d.fecha_prod), y.yacimiento
        ORDER BY y.yacimiento;

-- Creación de funciones y stored procedures
-- La función permite ver el estado de pozo: activo o inactivo.
DELIMITER //
DROP FUNCTION IF EXISTS f_produce //
CREATE FUNCTION f_produce (prod decimal(10,2))
RETURNS VARCHAR(50)
DETERMINISTIC
NO SQL
BEGIN 
	IF (prod)>0 THEN 
		RETURN 'Pozo activo';
	ELSE 
		RETURN 'Pozo inactivo';
END IF;
END
//

DELIMITER ;

-- La función permite elegir costos por por mes y año.
DELIMITER //
DROP FUNCTION IF EXISTS f_costos //
CREATE FUNCTION f_costos (mes INT, año INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN 
	DECLARE inversion DECIMAL(10,2) DEFAULT 0;
SELECT
	SUM(perf.costo_perfo+comp.costo_comple+loc.costo_locacion) INTO inversion
FROM repositorio_pozos.pozos p
        INNER JOIN repositorio_pozos.perforacion perf ON (perf.perfo_id=p.perfo_id)
		INNER JOIN repositorio_pozos.completacion comp ON (comp.comple_id=p.frac_id)
		INNER JOIN repositorio_pozos.locacion loc ON (loc.locacion_id=p.locacion_id)
		WHERE MONTH(fecha_locacion)=mes AND YEAR(fecha_locacion)=año;
RETURN inversion;
END
//

DELIMITER ;

SELECT f_costos(11,2020);

-- El procedimiento permite pedir la producción mensual por pozo pasando un parametro de fecha (YYYY-M) y luego ordenarlo por alguna de las columnas en forma ascendente o descendente.

CREATE DATABASE new_schema_data;

CREATE TABLE IF NOT EXISTS new_schema_data.agg_data(
		Pozo VARCHAR(100) PRIMARY KEY,
        Prod_gas decimal(10,2),
        Prod_oil decimal(10,2));
        
DELIMITER //
DROP PROCEDURE IF EXISTS sp_orden //
CREATE PROCEDURE sp_orden (IN fecha_ varchar(100),IN order_by varchar(100),IN _asc BOOLEAN  )
BEGIN 	
		SET @stmt_query =
        "INSERT INTO new_schema_data.agg_data
        (Pozo,Prod_gas,Prod_oil)
        SELECT * FROM data";
 
		DROP TEMPORARY TABLE IF EXISTS data;
        CREATE TEMPORARY TABLE data
        SELECT
			base_data.Pozo,
            base_data.Prod_gas,
            base_data.Prod_oil
            FROM(
			SELECT
				p.pozo_id as Pozo,
				ROUND(AVG(prod.prod_gas),2) AS "Prod_Gas",
				ROUND(AVG(prod.prod_oil),2) AS "Prod_Oil",
				CONCAT(YEAR(fecha_prod),"-",MONTH(prod.fecha_prod)) AS Fecha
			FROM	repositorio_pozos.pozos p
			INNER JOIN	repositorio_pozos.prod_pozos pp ON (pp.pozo_id=p.pozo_id)
			INNER JOIN repositorio_pozos.prod prod ON (prod.pozo_dia=pp.pozo_dia)
            WHERE CONCAT(YEAR(fecha_prod),"-",MONTH(prod.fecha_prod))=fecha_
			GROUP BY Fecha,p.pozo_id) AS base_data;
		SET @stmt_query = CONCAT(@stmt_query ," ORDER BY ",order_by, IF (_asc=1," ASC"," DESC;"));
        PREPARE query_ FROM @stmt_query;
        EXECUTE query_;
        DEALLOCATE PREPARE query_;

END
//
DELIMITER ;
		
CALL sp_orden('2022-5','Prod_gas',1);   


-- El procedimiento permite eliminar pozos de la base de datos
DELIMITER //
DROP PROCEDURE IF EXISTS sp_eliminar_pozo //
CREATE PROCEDURE sp_eliminar_pozo (IN id varchar(100))
BEGIN 
	DELETE FROM repositorio_pozos.pozos
    WHERE pozo_id=id;
END
//
DELIMITER ;

CALL sp_eliminar_pozo("FP-1014(h)")

