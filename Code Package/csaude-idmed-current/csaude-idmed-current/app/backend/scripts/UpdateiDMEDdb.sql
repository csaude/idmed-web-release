
-- 1.2.0
ALTER TABLE IF EXISTS pack ADD COLUMN  IF NOT EXISTS isreferral bool DEFAULT false;
ALTER TABLE IF EXISTS pack ADD COLUMN  IF NOT EXISTS isreferalsynced bool DEFAULT false;
ALTER TABLE IF EXISTS mmia_report ADD COLUMN  IF NOT EXISTS dbM0 Integer DEFAULT 0;
ALTER TABLE IF EXISTS mmia_report ADD COLUMN  IF NOT EXISTS dbM1 Integer DEFAULT 0;
ALTER TABLE IF EXISTS packaged_drug ADD column  IF NOT EXISTS quantity_remain Integer DEFAULT 0;
ALTER TABLE IF EXISTS drug_quantity_temp ADD COLUMN IF NOT EXISTS nid character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS historico_levantamento_report ADD COLUMN  IF NOT EXISTS clinicsector character varying(255) DEFAULT 'N/A';
ALTER TABLE IF EXISTS inventory_report_temp ADD COLUMN  IF NOT EXISTS operation_type character varying(255) DEFAULT 'N/A';

ALTER TABLE IF EXISTS not_synchronizing_packs_open_mrs_report ALTER COLUMN json_request TYPE text COLLATE pg_catalog."default";
ALTER TABLE IF EXISTS not_synchronizing_packs_open_mrs_report ALTER COLUMN error_description TYPE text COLLATE pg_catalog."default";

-- Caso a coluna ja tenha sido criada
UPDATE pack set isreferral = false where isreferral is null;
UPDATE pack set isreferalsynced = false where isreferalsynced is null;

ALTER TABLE pack ALTER COLUMN isreferral SET DEFAULT false;
ALTER TABLE pack ALTER COLUMN isreferalsynced SET DEFAULT false;

-- 1.3.0

do $$
declare
BEGIN

   	IF NOT EXISTS (select 1 from pg_extension where extname = 'unaccent') THEN
   		EXECUTE 'CREATE EXTENSION unaccent';
    END IF;

end;
$$;

ALTER TABLE IF EXISTS sec_user ADD COLUMN  IF NOT EXISTS login_retries Integer DEFAULT 3;
ALTER TABLE IF EXISTS sec_user ADD COLUMN IF NOT EXISTS last_login date DEFAULT now();


CREATE OR REPLACE VIEW public.patientserviceview
 AS
 SELECT p.id,
    p.first_names,
    p.last_names,
    p.gender,
    psi.value,
    p.date_of_birth
   FROM patient p
     JOIN patient_service_identifier psi ON p.id::text = psi.patient_id::text
  GROUP BY p.id, p.first_names, p.last_names, p.gender, psi.value, p.date_of_birth
  ORDER BY p.last_names, p.first_names;
ALTER TABLE public.patientserviceview
    OWNER TO postgres;

-- funcao para zerar o stock para cada um dos lotes
CREATE OR REPLACE FUNCTION public.addZeroStockToBatch()
    RETURNS void
    LANGUAGE 'plpgsql'
    VOLATILE
    PARALLEL UNSAFE
    COST 100

AS $BODY$
DECLARE
    stockRecord RECORD;
    lastLoteDate DATE;
    entranceDate DATE;
    realDate DATE;
    stockMov INT;
    uuidgenID UUID;
BEGIN
	stockMov :=0;
    FOR stockRecord IN
        SELECT s.*
        FROM Stock s
    LOOP
    	SELECT sum(incomes + posetiveadjustment) - sum(outcomes + negativeadjustment + loses) INTO stockMov
	FROM drug_stock_batch_summary_vw
	WHERE  stock = stockRecord.id;

    	SELECT max(sa.capture_date) INTO lastLoteDate
	FROM Stock_Adjustment sa
	WHERE sa.adjusted_stock_id = stockRecord.id;

    	SELECT max(se.date_received) INTO entranceDate
 	FROM stock_entrance se
 	INNER JOIN stock s on s.entrance_id = se.id
 	where s.id = stockRecord.id;

	uuidgenID := gen_random_uuid();

	IF entranceDate IS NULL THEN
		IF lastLoteDate IS NULL THEN
			realDate:= CURRENT_DATE;
		ELSE
			realDate := lastLoteDate;
		END IF;
	ELSE
		IF lastLoteDate IS NULL THEN
			realDate := entranceDate;
		ELSE
			IF lastLoteDate > entranceDate THEN
				realDate := lastLoteDate;
			ELSE
				realDate := entranceDate;
			END IF;
		END IF;
	END IF;

    IF stockMov < 0 THEN

	INSERT INTO public.refered_stock_moviment(
		id, version, origin, date, update_status, quantity, clinic_id, order_number)
		VALUES (uuidgenID, 0, 'Ajuste', realDate, 'P', stockMov*(-1), stockRecord.clinic_id, 'Ordem_ajuste');

	INSERT INTO public.stock_adjustment(
		id, version, operation_id, balance, capture_date, finalised, notes, stock_take, adjusted_value, clinic_id, adjusted_stock_id, class, reference_id, inventory_id, destruction_id)
		VALUES (gen_random_uuid(), 0, '919327EC-CA8B-4529-9B92-769CECB96785', stockMov*(-1), realDate, true, 'Ajuste stock zero', 0, stockMov*(-1), stockRecord.clinic_id, stockRecord.id, 'mz.org.fgh.sifmoz.backend.stockadjustment.StockReferenceAdjustment', uuidgenID, null, null);

    ELSE
		INSERT INTO public.refered_stock_moviment(
		id, version, origin, date, update_status, quantity, clinic_id, order_number)
		VALUES (uuidgenID, 0, 'Ajuste', realDate, 'P', stockMov, stockRecord.clinic_id, 'Ordem_ajuste');

	INSERT INTO public.stock_adjustment(
		id, version, operation_id, balance, capture_date, finalised, notes, stock_take, adjusted_value, clinic_id, adjusted_stock_id, class, reference_id, inventory_id, destruction_id)
		VALUES (gen_random_uuid(), 0, 'B54FDBC8-5DD2-4CFA-9B22-627B3CC58D36', stockMov, realDate, true, 'Ajuste stock zero', 0, stockMov, stockRecord.clinic_id, stockRecord.id, 'mz.org.fgh.sifmoz.backend.stockadjustment.StockReferenceAdjustment', uuidgenID, null, null);
    END IF;
    END LOOP;

END;
$BODY$;

CREATE OR REPLACE FUNCTION public.addZeroStockToBatchWithDate(dataMigracao date)
    RETURNS void
    LANGUAGE 'plpgsql'
    VOLATILE
    PARALLEL UNSAFE
    COST 100

AS $BODY$
DECLARE
    stockRecord RECORD;
    lastLoteDate DATE;
    entranceDate DATE;
    realDate DATE;
    stockMov INT;
    uuidgenID UUID;
BEGIN
    stockMov :=0;
    FOR stockRecord IN
        SELECT s.*
        FROM Stock s
        INNER JOIN stock_entrance se on se.id = s.entrance_id
    LOOP
    SELECT sum(incomes + posetiveadjustment) - sum(outcomes + negativeadjustment + loses) INTO stockMov
	FROM drug_stock_batch_summary_vw
	WHERE  stock = stockRecord.id;

    SELECT max(sa.capture_date) INTO lastLoteDate
	FROM Stock_Adjustment sa
	WHERE sa.adjusted_stock_id = stockRecord.id AND sa.capture_date <= dataMigracao;

    	SELECT max(se.date_received) INTO entranceDate
 	FROM stock_entrance se
 	INNER JOIN stock s on s.entrance_id = se.id
 	where s.id = stockRecord.id AND se.date_received <= dataMigracao;

	uuidgenID := gen_random_uuid();

	IF entranceDate IS NULL THEN
		IF lastLoteDate IS NULL THEN
			realDate:= CURRENT_DATE;
		ELSE
			realDate := lastLoteDate;
		END IF;
	ELSE
		IF lastLoteDate IS NULL THEN
			realDate := entranceDate;
		ELSE
			IF lastLoteDate > entranceDate THEN
				realDate := lastLoteDate;
			ELSE
				realDate := entranceDate;
			END IF;
		END IF;
	END IF;

    IF stockMov < 0 THEN

	INSERT INTO public.refered_stock_moviment(
		id, version, origin, date, update_status, quantity, clinic_id, order_number)
		VALUES (uuidgenID, 0, 'Ajuste', realDate, 'P', stockMov*(-1), stockRecord.clinic_id, 'Ordem_ajuste');

	INSERT INTO public.stock_adjustment(
		id, version, operation_id, balance, capture_date, finalised, notes, stock_take, adjusted_value, clinic_id, adjusted_stock_id, class, reference_id, inventory_id, destruction_id)
		VALUES (gen_random_uuid(), 0, '919327EC-CA8B-4529-9B92-769CECB96785', stockMov*(-1), realDate, true, 'Ajuste stock zero', 0, stockMov*(-1), stockRecord.clinic_id, stockRecord.id, 'mz.org.fgh.sifmoz.backend.stockadjustment.StockReferenceAdjustment', uuidgenID, null, null);

    ELSE
    	IF realDate <= dataMigracao THEN
		INSERT INTO public.refered_stock_moviment(
			id, version, origin, date, update_status, quantity, clinic_id, order_number)
			VALUES (uuidgenID, 0, 'Ajuste', realDate, 'P', stockMov, stockRecord.clinic_id, 'Ordem_ajuste');

		INSERT INTO public.stock_adjustment(
			id, version, operation_id, balance, capture_date, finalised, notes, stock_take, adjusted_value, clinic_id, adjusted_stock_id, class, reference_id, inventory_id, destruction_id)
			VALUES (gen_random_uuid(), 0, 'B54FDBC8-5DD2-4CFA-9B22-627B3CC58D36', stockMov, realDate, true, 'Ajuste stock zero', 0, stockMov, stockRecord.clinic_id, stockRecord.id, 'mz.org.fgh.sifmoz.backend.stockadjustment.StockReferenceAdjustment', uuidgenID, null, null);
	END IF;
    END IF;
    END LOOP;

END;
$BODY$;


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


DROP VIEW IF EXISTS public.patient_last_pack_vw CASCADE;
CREATE OR REPLACE VIEW public.patient_last_pack_vw
AS SELECT DISTINCT ON (p.id) p2.id,
    p2.version,
    p2.reason_for_package_return,
    p2.pickup_date,
    p2.package_returned,
    p2.modified,
    p2.date_received,
    p2.provider_uuid,
    p2.stock_returned,
    p2.next_pick_up_date,
    p2.group_pack_id,
    p2.sync_status,
    p2.date_returned,
    p2.dispense_mode_id,
    p2.date_left,
    p2.clinic_id,
    p2.pack_date,
    p2.weeks_supply
   FROM patient_visit_details pvd
     JOIN patient_visit pv ON pvd.patient_visit_id::text = pv.id::text
     JOIN patient p ON p.id::text = pv.patient_id::text
     JOIN pack p2 ON pvd.pack_id::text = p2.id::text
  ORDER BY p.id, pv.visit_date DESC;

DROP VIEW IF EXISTS public.patient_last_prescription_vw CASCADE;
CREATE OR REPLACE VIEW public.patient_last_prescription_vw
AS SELECT DISTINCT ON (p.id) p2.id,
    p2.version,
    p2.modified,
    p2.expiry_date,
    p2.prescription_date,
    p2.notes,
    p2.duration_id,
    p2.patient_status,
    p2.prescription_seq,
    p2.current,
    p2.clinic_id,
    p2.doctor_id,
    p2.patient_type
   FROM patient_visit_details pvd
     JOIN patient_visit pv ON pvd.patient_visit_id::text = pv.id::text
     JOIN patient p ON p.id::text = pv.patient_id::text
     JOIN prescription p2 ON pvd.prescription_id::text = p2.id::text
  ORDER BY p.id, pv.visit_date DESC;

DROP VIEW IF EXISTS public.patient_last_visit_details_vw CASCADE;
CREATE OR REPLACE VIEW public.patient_last_visit_details_vw
AS SELECT DISTINCT ON (p.id) pvd.id,
    pvd.version,
    pvd.episode_id,
    pvd.patient_visit_id,
    pvd.prescription_id,
    pvd.clinic_id,
    pvd.pack_id
   FROM patient_visit_details pvd
     JOIN patient_visit pv ON pvd.patient_visit_id::text = pv.id::text
     JOIN patient p ON p.id::text = pv.patient_id::text
  ORDER BY p.id, pv.visit_date DESC;

DROP VIEW IF EXISTS public.patient_info_group_view CASCADE;
CREATE OR REPLACE VIEW public.patient_info_group_view
 AS
 SELECT DISTINCT ON (p.id) concat(p.first_names, ' ', p.middle_names, ' ', p.last_names) AS full_name,
    psi.value AS nid,
    max(pr.prescription_date) AS last_prescription_date,
    max(pk.pickup_date) AS last_pickup_date,
    max(pk.next_pick_up_date) AS next_pickup_date,
        CASE
            WHEN ((COALESCE(d.weeks, 0) - COALESCE(sum(pk.weeks_supply)::integer, 0)) / 4) < 0 THEN 0
            ELSE (COALESCE(d.weeks, 0) - COALESCE(sum(pk.weeks_supply)::integer, 0)) / 4
        END AS validade,
    max(pr2.prescription_date) AS last_prescription_date_member,
        CASE
            WHEN ((COALESCE(d2.weeks, 0) - COALESCE(sum(pk2.weeks_supply)::integer, 0)) / 4) < 0 THEN 0
            ELSE (COALESCE(d2.weeks, 0) - COALESCE(sum(pk2.weeks_supply)::integer, 0)) / 4
        END AS validade_nova,
    p.id AS patientid,
    gm.id AS groupmemberid,
    psi.id AS patientserviceid,
    pvd.episode_id AS episodeid,
    gm.end_date AS membership_enddate,
    gi.id AS group_id
   FROM patient p
     JOIN patient_service_identifier psi ON p.id::text = psi.patient_id::text
     JOIN patient_visit pv ON p.id::text = pv.patient_id::text
     JOIN patient_visit_details pvd ON pv.id::text = pvd.patient_visit_id::text
     JOIN prescription pr ON pvd.prescription_id::text = pr.id::text
     JOIN pack pk ON pvd.pack_id::text = pk.id::text
     JOIN group_member gm ON gm.patient_id::text = p.id::text
     JOIN group_info gi ON gi.id::text = gm.group_id::text
     JOIN duration d ON d.id::text = pr.duration_id::text
     LEFT JOIN group_member_prescription gmp ON gmp.member_id::text = gm.id::text
     LEFT JOIN prescription pr2 ON pr2.id::text = gmp.prescription_id::text
     LEFT JOIN duration d2 ON d2.id::text = pr2.duration_id::text
     LEFT JOIN patient_visit_details pvd2 ON pvd2.prescription_id::text = pr2.id::text
	 LEFT JOIN episode ep on ep.id = pvd.episode_id
     LEFT JOIN pack pk2 ON pvd2.pack_id::text = pk2.id::text
  WHERE (p.id::text IN ( SELECT group_member.patient_id
           FROM group_member)) and ep.patient_service_identifier_id = psi.id and psi.service_id = gi.service_id
  GROUP BY p.id, p.first_names, p.middle_names, p.last_names, psi.value, gi.id, d.weeks, pr.prescription_date, pk.pickup_date, d2.weeks, gm.id, psi.id, pvd.episode_id
  ORDER BY p.id, gm.end_date DESC, pr.prescription_date DESC, pk.pickup_date DESC;
 ALTER TABLE public.patient_info_group_view
    OWNER TO postgres;

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

-- funcao que actualiza o stock moviment  (saldo actual do lote ) para cada um doslotes
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

-- 1.4.0

ALTER TABLE IF EXISTS form ADD COLUMN IF NOT EXISTS unit character varying(255) NOT NULL DEFAULT '';
ALTER TABLE IF EXISTS form ADD COLUMN IF NOT EXISTS how_to_use character varying(255) NOT NULL DEFAULT '';
ALTER TABLE IF EXISTS packaged_drug ADD COLUMN IF NOT EXISTS clinic_id character varying(255) NOT NULL DEFAULT '';
ALTER TABLE IF EXISTS prescribed_drug ADD COLUMN IF NOT EXISTS clinic_id character varying(255) NOT NULL DEFAULT '';
ALTER TABLE IF EXISTS prescription_detail ADD COLUMN IF NOT EXISTS clinic_id character varying(255) NOT NULL DEFAULT '';
ALTER TABLE IF EXISTS adherence_screening ADD COLUMN IF NOT EXISTS clinic_id character varying(255) NOT NULL DEFAULT '';
ALTER TABLE IF EXISTS pregnancy_screening ADD COLUMN IF NOT EXISTS clinic_id character varying(255) NOT NULL DEFAULT '';
ALTER TABLE IF EXISTS ramscreening ADD COLUMN IF NOT EXISTS clinic_id character varying(255) NOT NULL DEFAULT '';
ALTER TABLE IF EXISTS tbscreening ADD COLUMN IF NOT EXISTS clinic_id character varying(255) NOT NULL DEFAULT '';
ALTER TABLE IF EXISTS vital_signs_screening ADD COLUMN IF NOT EXISTS clinic_id character varying(255) NOT NULL DEFAULT '';
ALTER TABLE IF EXISTS episode ADD COLUMN IF NOT EXISTS is_abandonmentdc bool DEFAULT false;
ALTER TABLE IF EXISTS facility_type ADD COLUMN  IF NOT EXISTS type VARCHAR(255);
ALTER TABLE IF EXISTS clinic ADD COLUMN IF NOT EXISTS matchfc VARCHAR(1);
ALTER TABLE IF EXISTS clinic ADD COLUMN IF NOT EXISTS parent_clinic_id VARCHAR(255);
ALTER TABLE IF EXISTS clinic ADD COLUMN IF NOT EXISTS sync_status VARCHAR(1);
ALTER TABLE IF EXISTS clinic ADD COLUMN IF NOT EXISTS class VARCHAR(255);
ALTER TABLE IF EXISTS stock_distributor ADD COLUMN IF NOT EXISTS status varchar(255);
ALTER TABLE IF EXISTS stock_entrance ADD COLUMN IF NOT EXISTS is_distribution bool default false;
ALTER TABLE IF EXISTS stock_adjustment ADD COLUMN IF NOT EXISTS is_distribution bool default false;
ALTER TABLE IF EXISTS mmia_regimen_sub_report ADD COLUMN IF NOT EXISTS total_referidos INT DEFAULT 0;
ALTER TABLE IF EXISTS mmia_regimen_sub_report ADD COLUMN IF NOT EXISTS totalrefline1 INT DEFAULT 0;
ALTER TABLE IF EXISTS mmia_regimen_sub_report ADD COLUMN IF NOT EXISTS totalrefline2 INT DEFAULT 0;
ALTER TABLE IF EXISTS mmia_regimen_sub_report ADD COLUMN IF NOT EXISTS totalrefline3 INT DEFAULT 0;
ALTER TABLE IF EXISTS episode ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS pack ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS patient ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS patient_service_identifier ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS patient_visit ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS patient_visit_details ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS prescription ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS packaged_drug ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS prescribed_drug ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS prescription_detail ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS adherence_screening ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS pregnancy_screening ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS ramscreening ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS tbscreening ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';
ALTER TABLE IF EXISTS vital_signs_screening ADD COLUMN IF NOT EXISTS origin character varying(255) DEFAULT '';

UPDATE clinic set class = 'mz.org.fgh.sifmoz.backend.clinic.Clinic' WHERE class IS NULL;
update clinic set sync_status = 'N' where sync_status is null;
update facility_type set type = 'clinic' where type is null;
UPDATE packaged_drug set clinic_id = (select id from clinic where main_clinic = true);
UPDATE prescribed_drug set clinic_id = (select id from clinic where main_clinic = true);
UPDATE prescription_detail set clinic_id = (select id from clinic where main_clinic = true);
UPDATE adherence_screening set clinic_id = (select id from clinic where main_clinic = true);
UPDATE pregnancy_screening set clinic_id = (select id from clinic where main_clinic = true);
UPDATE ramscreening set clinic_id = (select id from clinic where main_clinic = true);
UPDATE tbscreening set clinic_id = (select id from clinic where main_clinic = true);
UPDATE vital_signs_screening set clinic_id = (select id from clinic where main_clinic = true);
update dispense_type set description = 'Dispensa Bimestral' where code = 'DB';

ALTER TABLE IF EXISTS packaged_drug ALTER COLUMN clinic_id SET DEFAULT '';
ALTER TABLE IF EXISTS prescribed_drug ALTER COLUMN clinic_id SET DEFAULT '';
ALTER TABLE IF EXISTS prescription_detail ALTER COLUMN clinic_id SET DEFAULT '';
ALTER TABLE IF EXISTS adherence_screening ALTER COLUMN clinic_id SET DEFAULT '';
ALTER TABLE IF EXISTS pregnancy_screening ALTER COLUMN clinic_id SET DEFAULT '';
ALTER TABLE IF EXISTS ramscreening ALTER COLUMN clinic_id SET DEFAULT '';
ALTER TABLE IF EXISTS tbscreening ALTER COLUMN clinic_id SET DEFAULT '';
ALTER TABLE IF EXISTS vital_signs_screening ALTER COLUMN clinic_id SET DEFAULT '';

ALTER TABLE IF EXISTS packaged_drug ALTER COLUMN clinic_id SET NOT NULL;
ALTER TABLE IF EXISTS prescribed_drug ALTER COLUMN clinic_id SET NOT NULL;
ALTER TABLE IF EXISTS prescription_detail ALTER COLUMN clinic_id SET NOT NULL;
ALTER TABLE IF EXISTS adherence_screening ALTER COLUMN clinic_id SET NOT NULL;
ALTER TABLE IF EXISTS pregnancy_screening ALTER COLUMN clinic_id SET NOT NULL;
ALTER TABLE IF EXISTS ramscreening ALTER COLUMN clinic_id SET NOT NULL;
ALTER TABLE IF EXISTS tbscreening ALTER COLUMN clinic_id SET NOT NULL;
ALTER TABLE IF EXISTS vital_signs_screening ALTER COLUMN clinic_id SET NOT NULL;
ALTER TABLE IF EXISTS drug ALTER COLUMN clinical_service_id DROP NOT NULL;



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
             JOIN stock s ON sa.adjusted_stock_id::text = s.id::text AND date(s.expire_date) >= CURRENT_DATE
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


DROP VIEW IF EXISTS public.patient_last_visit_screening_vw CASCADE;
CREATE OR REPLACE VIEW public.patient_last_visit_screening_vw
 AS
 SELECT DISTINCT ON (p.id) pv.id,
    pv.version,
    pv.patient_id,
    pv.visit_date,
    pv.clinic_id,
    pv.creation_date,
    pv.origin
   FROM patient_visit pv
     JOIN patient p ON p.id::text = pv.patient_id::text
     JOIN vital_signs_screening vss ON vss.visit_id::text = pv.id::text
  ORDER BY p.id, pv.visit_date DESC;
ALTER TABLE public.patient_last_visit_screening_vw
    OWNER TO postgres;


DROP VIEW IF EXISTS public.patient_last_3_visits_screening_vw CASCADE;
CREATE OR REPLACE VIEW public.patient_last_3_visits_screening_vw
 AS
 WITH ranked_visits AS (
         SELECT pv.id,
            pv.version,
            pv.patient_id,
            pv.visit_date,
            pv.clinic_id,
            pv.creation_date,
            pv.origin,
            row_number() OVER (PARTITION BY p.id ORDER BY pv.visit_date DESC) AS visit_rank
           FROM patient_visit pv
             JOIN patient p ON p.id::text = pv.patient_id::text
             JOIN vital_signs_screening vss ON vss.visit_id::text = pv.id::text
        )
 SELECT ranked_visits.id,
    ranked_visits.version,
    ranked_visits.patient_id,
    ranked_visits.visit_date,
    ranked_visits.clinic_id,
    ranked_visits.creation_date,
    ranked_visits.origin
   FROM ranked_visits
  WHERE ranked_visits.visit_rank <= 3;
ALTER TABLE public.patient_last_3_visits_screening_vw
    OWNER TO postgres;

do $$
DECLARE
	clinicRecord RECORD;
BEGIN
	FOR clinicRecord IN
		select c.* from clinic c where main_clinic = true

	LOOP

		IF EXISTS (
		SELECT 1 FROM clinic c
		INNER JOIN system_configs sc on sc.description = c.id
		WHERE sc.value = 'LOCAL' AND c.main_clinic = true) THEN

			EXECUTE ' UPDATE episode SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE pack SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE patient SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE patient_service_identifier SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE patient_visit SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE patient_visit_details SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE prescription SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE packaged_drug SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE prescribed_drug SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE prescription_detail SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE adherence_screening SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE pregnancy_screening SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE ramscreening SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE tbscreening SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';
			EXECUTE ' UPDATE vital_signs_screening SET origin = '''||clinicRecord.id||''' WHERE origin IS NULL OR origin = ''''';


    		END IF;

    END LOOP;
END;
$$;

-- 1.5.0
ALTER TABLE IF EXISTS public.therapeutic_regimen ALTER COLUMN clinical_service_id DROP NOT NULL;
ALTER TABLE stock_level  DROP COLUMN full_container_remaining;
ALTER TABLE stock_level  DROP COLUMN loose_pills_remaining;
ALTER TABLE stock_level  DROP COLUMN bacth;
ALTER TABLE stock_level  DROP COLUMN stock_id;
