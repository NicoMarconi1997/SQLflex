-- Creación de funciones
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
