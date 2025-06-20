-- 1.7.0


CREATE OR REPLACE FUNCTION return_estatistic_month(thedate DATE)
RETURNS NUMERIC AS $$
BEGIN
    CASE
        WHEN thedate BETWEEN (date_trunc('year', thedate) + interval '21 days') AND (date_trunc('year', thedate) + interval '1 month' + interval '20 days') THEN
            RETURN 2;
        WHEN thedate BETWEEN (date_trunc('year', thedate) + interval '1 month' + interval '21 days') AND (date_trunc('year', thedate) + interval '2 month' + interval '20 days') THEN
            RETURN 3;
        WHEN thedate BETWEEN (date_trunc('year', thedate) + interval '2 month' + interval '21 days') AND (date_trunc('year', thedate) + interval '3 month' + interval '20 days') THEN
            RETURN 4;
        WHEN thedate BETWEEN (date_trunc('year', thedate) + interval '3 month' + interval '21 days') AND (date_trunc('year', thedate) + interval '4 month' + interval '20 days') THEN
            RETURN 5;
        WHEN thedate BETWEEN (date_trunc('year', thedate) + interval '4 month' + interval '21 days') AND (date_trunc('year', thedate) + interval '5 month' + interval '20 days') THEN
            RETURN 6;
        WHEN thedate BETWEEN (date_trunc('year', thedate) + interval '5 month' + interval '21 days') AND (date_trunc('year', thedate) + interval '6 month' + interval '20 days') THEN
            RETURN 7;
        WHEN thedate BETWEEN (date_trunc('year', thedate) + interval '6 month' + interval '21 days') AND (date_trunc('year', thedate) + interval '7 month' + interval '20 days') THEN
            RETURN 8;
        WHEN thedate BETWEEN (date_trunc('year', thedate) + interval '7 month' + interval '21 days') AND (date_trunc('year', thedate) + interval '8 month' + interval '20 days') THEN
            RETURN 9;
        WHEN thedate BETWEEN (date_trunc('year', thedate) + interval '8 month' + interval '21 days') AND (date_trunc('year', thedate) + interval '9 month' + interval '20 days') THEN
            RETURN 10;
        WHEN thedate BETWEEN (date_trunc('year', thedate) + interval '9 month' + interval '21 days') AND (date_trunc('year', thedate) + interval '10 month' + interval '20 days') THEN
            RETURN 11;
        WHEN thedate BETWEEN (date_trunc('year', thedate) + interval '10 month' + interval '21 days') AND (date_trunc('year', thedate) + interval '11 month' + interval '20 days') THEN
            RETURN 12;
        ELSE
            RETURN 1;
    END CASE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION initStockMovementBatch()
RETURNS VOID AS $$
DECLARE
    stockRecord RECORD;
    stockMov INT;
BEGIN
    FOR stockRecord IN
        SELECT s.id, dsb.balance
        FROM Stock s
        JOIN drug_stock_balance_vw dsb ON s.id = dsb.stock
        WHERE s.expire_date >= CURRENT_DATE
    LOOP
        -- Update the stock table with the stock_moviment value
        UPDATE stock
        SET stock_moviment = stockRecord.balance
        WHERE id = stockRecord.id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


ALTER TABLE IF EXISTS public.therapeutic_regimen ALTER COLUMN clinical_service_id DROP NOT NULL;
ALTER TABLE IF EXISTS historico_levantamento_report ADD COLUMN  IF NOT EXISTS dispense_origin character varying(255) DEFAULT 'N/A';

UPDATE dispense_type SET description = 'Dispensa Bimestral' WHERE code = 'DB';
UPDATE inventory SET end_date = start_date WHERE end_date < '1900-01-01'::date AND end_date IS NOT NULL;

DO $$
DECLARE
	inventory_rec RECORD;
BEGIN
	FOR inventory_rec IN
		select i.* from inventory i where end_date is not null
		LOOP
			UPDATE stock_adjustment SET capture_date = inventory_rec.end_date where inventory_id = inventory_rec.id;
	    END LOOP;
	END;
$$;

DROP VIEW IF EXISTS public.drug_stock_summary_vw CASCADE;
CREATE OR REPLACE VIEW public.drug_stock_summary_vw
AS
WITH entrada AS (
         SELECT EXTRACT(year FROM se.date_received) AS event_year,
            return_estatistic_month(se.date_received::date) AS event_month,
            s.drug_id,
                CASE
                    WHEN se.is_distribution = true THEN 'Distrib. Entrada de Stock'::text
                    ELSE 'Entrada de Stock'::text
                END AS moviment,
            sum(ceil(s.units_received::double precision)) AS incomes,
            0 AS outcomes,
            0 AS positiveadjustment,
            0 AS negativeadjustment,
            0 AS losses,
            se.clinic_id,
            'ENTRADA'::text AS code,
            ''::text AS stock,
            max(se.date_received) AS max_date
           FROM stock_entrance se
             JOIN stock s ON se.id::text = s.entrance_id::text
          WHERE date(s.expire_date) >= CURRENT_DATE
          GROUP BY (EXTRACT(year FROM se.date_received)), (return_estatistic_month(se.date_received::date)),s.drug_id, (
                CASE
                    WHEN se.is_distribution = true THEN 'Distrib. Entrada de Stock'::text
                    ELSE 'Entrada de Stock'::text
                END), 0::integer, se.clinic_id
          ORDER BY (EXTRACT(year FROM se.date_received)) DESC, (return_estatistic_month(se.date_received::date)) DESC
        )
 SELECT entrada.event_year,
    entrada.event_month,
    entrada.drug_id,
    entrada.moviment,
    entrada.incomes,
    entrada.outcomes,
    entrada.positiveadjustment,
    entrada.negativeadjustment,
    entrada.losses,
    entrada.clinic_id,
    entrada.code,
    entrada.stock,
    entrada.max_date
   FROM entrada
UNION
( WITH saida AS (
         SELECT EXTRACT(year FROM p.pickup_date) AS event_year,
            return_estatistic_month(p.pickup_date::date) AS event_month,
            pd.drug_id,
            'Saídas'::text AS moviment,
            0 AS incomes,
            sum(ceil(pd.quantity_supplied)) AS outcomes,
            0 AS positiveadjustment,
            0 AS negativeadjustment,
            0 AS losses,
            p.clinic_id,
            'SAIDA'::text AS code,
            ''::text AS stock,
            max(p.pickup_date) AS max_date
           FROM packaged_drug pd
             JOIN packaged_drug_stock pds ON pd.id::text = pds.packaged_drug_id::text
             JOIN stock s ON s.id::text = pds.stock_id::text
             JOIN pack p ON p.id::text = pd.pack_id::text
          WHERE date(s.expire_date) >= CURRENT_DATE
          GROUP BY (EXTRACT(year FROM p.pickup_date)), (return_estatistic_month(p.pickup_date::date)), pd.drug_id, 'Saídas'::text, 0::integer, p.clinic_id
          ORDER BY (EXTRACT(year FROM p.pickup_date)) DESC, (return_estatistic_month(p.pickup_date::date)) DESC
        )
 SELECT saida.event_year,
    saida.event_month,
    saida.drug_id,
    saida.moviment,
    saida.incomes,
    saida.outcomes,
    saida.positiveadjustment,
    saida.negativeadjustment,
    saida.losses,
    saida.clinic_id,
    saida.code,
    saida.stock,
    saida.max_date
   FROM saida)
UNION
( WITH ajuste_positivo AS (
         SELECT EXTRACT(year FROM rsm.date) AS event_year,
            return_estatistic_month(rsm.date::date) AS event_month,
            s.drug_id,
                CASE
                    WHEN sa.is_distribution = true THEN 'Distrib. Ajuste positivo'::text
                    ELSE 'Ajuste positivo'::text
                END AS moviment,
            0 AS incomes,
            0 AS outcomes,
            sum(ceil(sa.adjusted_value::double precision)) AS positiveadjustment,
            0 AS negativeadjustment,
            0 AS losses,
            rsm.clinic_id,
            'AJUSTE_POSETIVO'::text AS code,
            ''::text AS stock,
            max(rsm.date) AS max_date
           FROM stock_adjustment sa
             JOIN refered_stock_moviment rsm ON sa.reference_id::text = rsm.id::text
             JOIN stock s ON sa.adjusted_stock_id::text = s.id::text
             JOIN stock_operation_type sot ON sa.operation_id::text = sot.id::text
          WHERE sot.code::text = 'AJUSTE_POSETIVO'::text AND date(s.expire_date) >= CURRENT_DATE
          GROUP BY (EXTRACT(year FROM rsm.date)), (return_estatistic_month(rsm.date::date)), s.drug_id, (
                CASE
                    WHEN sa.is_distribution = true THEN 'Distrib. Ajuste positivo'::text
                    ELSE 'Ajuste positivo'::text
                END), 0::integer, rsm.clinic_id
          ORDER BY (EXTRACT(year FROM rsm.date)) DESC, (return_estatistic_month(rsm.date::date)) DESC
        )
 SELECT ajuste_positivo.event_year,
    ajuste_positivo.event_month,
    ajuste_positivo.drug_id,
    ajuste_positivo.moviment,
    ajuste_positivo.incomes,
    ajuste_positivo.outcomes,
    ajuste_positivo.positiveadjustment,
    ajuste_positivo.negativeadjustment,
    ajuste_positivo.losses,
    ajuste_positivo.clinic_id,
    ajuste_positivo.code,
    ajuste_positivo.stock,
    ajuste_positivo.max_date
   FROM ajuste_positivo)
UNION
( WITH ajuste_negativo AS (
         SELECT EXTRACT(year FROM rsm.date) AS event_year,
            return_estatistic_month(rsm.date::date) AS event_month,
            s.drug_id,
                CASE
                    WHEN sa.is_distribution = true THEN 'Distrib. Ajuste Negativo'::text
                    ELSE 'Ajuste Negativo'::text
                END AS moviment,
            0 AS incomes,
            0 AS outcomes,
            0 AS positiveadjustment,
            sum(sa.adjusted_value) AS negativeadjustment,
            0 AS losses,
            rsm.clinic_id,
            'AJUSTE_NEGATIVO'::text AS code,
            ''::text AS stock,
            max(rsm.date) AS max_date
           FROM stock_adjustment sa
             JOIN refered_stock_moviment rsm ON sa.reference_id::text = rsm.id::text
             JOIN stock s ON sa.adjusted_stock_id::text = s.id::text
             JOIN stock_operation_type sot ON sa.operation_id::text = sot.id::text
          WHERE sot.code::text = 'AJUSTE_NEGATIVO'::text AND date(s.expire_date) >= CURRENT_DATE
          GROUP BY (EXTRACT(year FROM rsm.date)), (return_estatistic_month(rsm.date::date)), s.drug_id, (
                CASE
                    WHEN sa.is_distribution = true THEN 'Distrib. Ajuste Negativo'::text
                    ELSE 'Ajuste Negativo'::text
                END), 0::integer, rsm.clinic_id
          ORDER BY (EXTRACT(year FROM rsm.date)) DESC, (return_estatistic_month(rsm.date::date)) DESC
        )
 SELECT ajuste_negativo.event_year,
    ajuste_negativo.event_month,
    ajuste_negativo.drug_id,
    ajuste_negativo.moviment,
    ajuste_negativo.incomes,
    ajuste_negativo.outcomes,
    ajuste_negativo.positiveadjustment,
    ajuste_negativo.negativeadjustment,
    ajuste_negativo.losses,
    ajuste_negativo.clinic_id,
    ajuste_negativo.code,
    ajuste_negativo.stock,
    ajuste_negativo.max_date
   FROM ajuste_negativo)
UNION
( WITH perda AS (
         SELECT EXTRACT(year FROM ds.date) AS event_year,
            return_estatistic_month(ds.date::date) AS event_month,
            s.drug_id,
            'Perda'::text AS moviment,
            0 AS incomes,
            0 AS outcomes,
            0 AS positiveadjustment,
            0 AS negativeadjustment,
            sum(sa.adjusted_value) AS losses,
            ds.clinic_id,
            'PERDA'::text AS code,
            ''::text AS stock,
            max(ds.date) AS max_date
           FROM stock_adjustment sa
             JOIN destroyed_stock ds ON sa.destruction_id::text = ds.id::text
             JOIN stock s ON sa.adjusted_stock_id::text = s.id::text 
           WHERE date(s.expire_date) >= CURRENT_DATE
          GROUP BY (EXTRACT(year FROM ds.date)), (return_estatistic_month(ds.date::date)), s.drug_id, 'Perda'::text, ds.clinic_id, 'PERDA'::text, ''::text
          ORDER BY (EXTRACT(year FROM ds.date)) DESC, (return_estatistic_month(ds.date::date)) DESC
        )
 SELECT perda.event_year,
    perda.event_month,
    perda.drug_id,
    perda.moviment,
    perda.incomes,
    perda.outcomes,
    perda.positiveadjustment,
    perda.negativeadjustment,
    perda.losses,
    perda.clinic_id,
    perda.code,
    perda.stock,
    perda.max_date
   FROM perda)
UNION
( WITH inventario AS (
         SELECT EXTRACT(year FROM i.end_date) AS event_year,
            return_estatistic_month(i.end_date::date) AS event_month,
            s.drug_id,
            'Inventário'::text AS moviment,
            0 AS incomes,
            0 AS outcomes,
            sum(
                CASE
                    WHEN sot.code::text = 'AJUSTE_POSETIVO'::text THEN ceil(sa.adjusted_value::double precision)
                    ELSE 0::double precision
                END) AS positiveadjustment,
            sum(
                CASE
                    WHEN sot.code::text = 'AJUSTE_NEGATIVO'::text THEN ceil(sa.adjusted_value::double precision)
                    ELSE 0::double precision
                END) AS negativeadjustment,
            0 AS losses,
            i.clinic_id,
            'INVENTARIO'::text AS code,
            ''::text AS stock,
            max(i.end_date) AS max_date
           FROM stock_adjustment sa
             JOIN inventory i ON sa.inventory_id::text = i.id::text
             JOIN stock s ON sa.adjusted_stock_id::text = s.id::text
             JOIN stock_operation_type sot ON sa.operation_id::text = sot.id::text
          WHERE i.end_date IS NOT NULL AND date(s.expire_date) >= CURRENT_DATE
          GROUP BY (EXTRACT(year FROM i.end_date)), (return_estatistic_month(i.end_date::date)), s.drug_id, 'Inventário'::text, 0::integer, i.clinic_id
          ORDER BY (EXTRACT(year FROM i.end_date)) DESC, (return_estatistic_month(i.end_date::date)) DESC
        )
 SELECT inventario.event_year,
    inventario.event_month,
    inventario.drug_id,
    inventario.moviment,
    inventario.incomes,
    inventario.outcomes,
    inventario.positiveadjustment,
    inventario.negativeadjustment,
    inventario.losses,
    inventario.clinic_id,
    inventario.code,
    inventario.stock,
    inventario.max_date
   FROM inventario);

DROP VIEW IF EXISTS public.drug_stock_batch_summary_vw CASCADE;
CREATE OR REPLACE VIEW public.drug_stock_batch_summary_vw
AS WITH entrada AS (
         SELECT s.drug_id,
            date(se.date_received) AS event_date,
                CASE
                    WHEN se.is_distribution = true THEN 'Distrib. Entrada de Stock'::text
                    ELSE 'Entrada de Stock'::text
                END AS moviment,
            sum(ceil(s.units_received::double precision)) AS incomes,
            0 AS outcomes,
            0 AS posetiveadjustment,
            0 AS negativeadjustment,
            0 AS loses,
            se.clinic_id,
            'ENTRADA'::text AS code,
            s.id AS stock,
            max(se.date_received) AS max_date
           FROM stock_entrance se
             JOIN stock s ON se.id::text = s.entrance_id::text
          -- WHERE date(s.expire_date) >= CURRENT_DATE
          GROUP BY (date(se.date_received)), s.drug_id, se.clinic_id, se.is_distribution, s.id
          ORDER BY (date(se.date_received)) DESC
        )
 SELECT entrada.drug_id,
    entrada.event_date,
    entrada.moviment,
    entrada.incomes,
    entrada.outcomes,
    entrada.posetiveadjustment,
    entrada.negativeadjustment,
    entrada.loses,
    entrada.clinic_id,
    entrada.code,
    entrada.stock,
    entrada.max_date
   FROM entrada
UNION
( WITH saida AS (
         SELECT pd.drug_id,
            date(p.pickup_date) AS event_date,
            'Saídas'::text AS moviment,
            0 AS incomes,
            sum(ceil(pd.quantity_supplied)) AS outcomes,
            0 AS posetiveadjustment,
            0 AS negativeadjustment,
            0 AS loses,
            p.clinic_id,
            'SAIDA'::text AS code,
            s.id AS stock,
            max(p.pickup_date) AS max_date
           FROM packaged_drug pd
             JOIN packaged_drug_stock pds ON pd.id::text = pds.packaged_drug_id::text
             JOIN stock s ON s.id::text = pds.stock_id::text
             JOIN pack p ON p.id::text = pd.pack_id::text
         -- WHERE date(s.expire_date) >= CURRENT_DATE
          GROUP BY (date(p.pickup_date)), pd.drug_id, p.clinic_id, s.id
          ORDER BY (date(p.pickup_date)) DESC
        )
 SELECT saida.drug_id,
    saida.event_date,
    saida.moviment,
    saida.incomes,
    saida.outcomes,
    saida.posetiveadjustment,
    saida.negativeadjustment,
    saida.loses,
    saida.clinic_id,
    saida.code,
    saida.stock,
    saida.max_date
   FROM saida)
UNION
( WITH ajuste_positivo AS (
         SELECT s.drug_id,
            date(rsm.date) AS event_date,
                CASE
                    WHEN sa.is_distribution = true THEN 'Distrib. Ajuste positivo'::text
                    ELSE 'Ajuste positivo'::text
                END AS moviment,
            0 AS incomes,
            0 AS outcomes,
            sum(sa.adjusted_value) AS posetiveadjustment,
            0 AS negativeadjustment,
            0 AS loses,
            rsm.clinic_id,
            'AJUSTE_POSETIVO'::text AS code,
            s.id AS stock,
            max(rsm.date) AS max_date
           FROM stock_adjustment sa
             JOIN refered_stock_moviment rsm ON sa.reference_id::text = rsm.id::text
             JOIN stock s ON sa.adjusted_stock_id::text = s.id::text
             JOIN stock_operation_type sot ON sa.operation_id::text = sot.id::text
          WHERE sot.code::text = 'AJUSTE_POSETIVO'::text 
          --AND date(s.expire_date) >= CURRENT_DATE
          GROUP BY (date(rsm.date)), s.drug_id, rsm.clinic_id, s.id, sa.is_distribution
          ORDER BY (date(rsm.date)) DESC
        )
 SELECT ajuste_positivo.drug_id,
    ajuste_positivo.event_date,
    ajuste_positivo.moviment,
    ajuste_positivo.incomes,
    ajuste_positivo.outcomes,
    ajuste_positivo.posetiveadjustment,
    ajuste_positivo.negativeadjustment,
    ajuste_positivo.loses,
    ajuste_positivo.clinic_id,
    ajuste_positivo.code,
    ajuste_positivo.stock,
    ajuste_positivo.max_date
   FROM ajuste_positivo)
UNION
( WITH ajuste_negativo AS (
         SELECT s.drug_id,
            date(rsm.date) AS event_date,
                CASE
                    WHEN sa.is_distribution = true THEN 'Distrib. Ajuste negativo'::text
                    ELSE 'Ajuste negativo'::text
                END AS moviment,
            0 AS incomes,
            0 AS outcomes,
            0 AS posetiveadjustment,
            sum(ceil(sa.adjusted_value::double precision)) AS negativeadjustment,
            0 AS loses,
            rsm.clinic_id,
            'AJUSTE_NEGATIVO'::text AS code,
            s.id AS stock,
            max(rsm.date) AS max_date
           FROM stock_adjustment sa
             JOIN refered_stock_moviment rsm ON sa.reference_id::text = rsm.id::text
             JOIN stock s ON sa.adjusted_stock_id::text = s.id::text
             JOIN stock_operation_type sot ON sa.operation_id::text = sot.id::text
          WHERE sot.code::text = 'AJUSTE_NEGATIVO'::text 
          --AND date(s.expire_date) >= CURRENT_DATE
          GROUP BY (date(rsm.date)), s.drug_id, rsm.clinic_id, s.id, sa.notes, sa.is_distribution
          ORDER BY (date(rsm.date)) DESC
        )
 SELECT ajuste_negativo.drug_id,
    ajuste_negativo.event_date,
    ajuste_negativo.moviment,
    ajuste_negativo.incomes,
    ajuste_negativo.outcomes,
    ajuste_negativo.posetiveadjustment,
    ajuste_negativo.negativeadjustment,
    ajuste_negativo.loses,
    ajuste_negativo.clinic_id,
    ajuste_negativo.code,
    ajuste_negativo.stock,
    ajuste_negativo.max_date
   FROM ajuste_negativo)
UNION
( WITH perda AS (
         SELECT s.drug_id,
            date(ds.date) AS event_date,
            'Perda'::text AS moviment,
            0 AS incomes,
            0 AS outcomes,
            0 AS posetiveadjustment,
            0 AS negativeadjustment,
            sum(ceil(sa.adjusted_value::double precision)) AS loses,
            ds.clinic_id,
            'PERDA'::text AS code,
            s.id AS stock,
            max(ds.date) AS max_date
           FROM stock_adjustment sa
             JOIN destroyed_stock ds ON sa.destruction_id::text = ds.id::text
             JOIN stock s ON sa.adjusted_stock_id::text = s.id::text
          --WHERE date(s.expire_date) >= CURRENT_DATE
          GROUP BY (date(ds.date)), s.drug_id, ds.clinic_id, s.id
          ORDER BY (date(ds.date)) DESC
        )
 SELECT perda.drug_id,
    perda.event_date,
    perda.moviment,
    perda.incomes,
    perda.outcomes,
    perda.posetiveadjustment,
    perda.negativeadjustment,
    perda.loses,
    perda.clinic_id,
    perda.code,
    perda.stock,
    perda.max_date
   FROM perda)
UNION
( WITH inventario AS (
         SELECT s.drug_id,
            date(i.end_date) AS event_date,
            'Inventário'::text AS moviment,
            0 AS incomes,
            0 AS outcomes,
            sum(
                CASE
                    WHEN sot.code::text = 'AJUSTE_POSETIVO'::text THEN sa.adjusted_value
                    ELSE 0
                END) AS posetiveadjustment,
            sum(
                CASE
                    WHEN sot.code::text = 'AJUSTE_NEGATIVO'::text THEN sa.adjusted_value
                    ELSE 0
                END) AS negativeadjustment,
            0 AS loses,
            i.clinic_id,
            'INVENTARIO'::text AS code,
            s.id AS stock,
            max(i.end_date) AS max_date
           FROM stock_adjustment sa
             JOIN inventory i ON sa.inventory_id::text = i.id::text
             JOIN stock s ON sa.adjusted_stock_id::text = s.id::text
             JOIN stock_operation_type sot ON sa.operation_id::text = sot.id::text
          WHERE i.end_date IS NOT NULL 
          --AND date(s.expire_date) >= CURRENT_DATE
          GROUP BY (date(i.end_date)), s.drug_id, i.clinic_id, s.id
          ORDER BY (date(i.end_date)) DESC
        )
 SELECT inventario.drug_id,
    inventario.event_date,
    inventario.moviment,
    inventario.incomes,
    inventario.outcomes,
    inventario.posetiveadjustment,
    inventario.negativeadjustment,
    inventario.loses,
    inventario.clinic_id,
    inventario.code,
    inventario.stock,
    inventario.max_date
   FROM inventario);

DROP VIEW IF EXISTS public.drug_stock_balance_vw CASCADE;
CREATE OR REPLACE VIEW public.drug_stock_balance_vw
 AS
(

	select  b.stock,st.batch_number,
	(sum(b.incomes)+sum(b.posetiveadjustment) - sum(b.negativeadjustment) - sum(b.loses)-sum(b.outcomes) )AS  balance
	from public.drug_stock_batch_summary_vw b
	inner join public.stock st on (st.id =b.stock)
	group by b.stock, st.batch_number

);


select initstockmovementbatch();

CREATE TABLE poc_prescription_log (
    id VARCHAR(255) NOT NULL PRIMARY KEY,          
    message_id VARCHAR(255) NOT NULL, 
    prescription_id VARCHAR(255) NOT NULL,
    prescription_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    service_id VARCHAR(255) NOT NULL,
    patient_id VARCHAR(255) NOT NULL,
    nid VARCHAR(255) NOT NULL,           
    status VARCHAR(50) NOT NULL,         
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE interoperability_transation_log (
    id VARCHAR(255) NOT NULL PRIMARY KEY,          
    message_id VARCHAR(255) NOT NULL, 
    queue_name VARCHAR(255) NOT NULL,
    source_name VARCHAR(255) NOT NULL,
    payload_request TEXT NOT NULL,
    payload_response TEXT NOT NULL,           
    status VARCHAR(50) NOT NULL,     
    error_message TEXT NULL,         
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

