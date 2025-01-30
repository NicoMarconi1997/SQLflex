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
