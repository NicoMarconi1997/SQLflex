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
