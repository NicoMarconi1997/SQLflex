 -- Trigger para guardar valores viejos de pozos cuando hago updates
 
 CREATE TABLE repositorio_pozos.historico(
	pozo_id VARCHAR (100) UNIQUE primary key,
    pad INT NOT NULL,
    frac_id INT NOT NULL,
    perfo_id INT NOT NULL,
    locacion_id INT NOT NULL,
    fpem DATE,
    usuario varchar(200),
    fecha date);
 
DELIMITER //

-- Trigger para generar un registro histórico de los pozos antes de modificarlos
CREATE TRIGGER registro_historico
BEFORE UPDATE ON repositorio_pozos.pozos
FOR EACH ROW
BEGIN
	INSERT INTO repositorio_pozos.historico (pozo_id,pad,frac_id,perfo_id,locacion_id,fpem,usuario,fecha)
	VALUES (OLD.pozo_id,OLD.pad,OLD.frac_id,OLD.perfo_id,OLD.locacion_id,OLD.fpem,USER(),CURRENT_DATE());
END;
//
DELIMITER ;
