--
-- PostgreSQL database dump
--

-- Dumped from database version 15.6 (Debian 15.6-1.pgdg110+2)
-- Dumped by pg_dump version 16.4 (Ubuntu 16.4-1.pgdg22.04+1)

-- Started on 2024-12-02 14:06:22 CAT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 123285)
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- TOC entry 7603 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- TOC entry 571 (class 1255 OID 123292)
-- Name: addzerostocktobatch(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addzerostocktobatch() RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.addzerostocktobatch() OWNER TO postgres;

--
-- TOC entry 583 (class 1255 OID 123293)
-- Name: addzerostocktobatchwithdate(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addzerostocktobatchwithdate(datamigracao date) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.addzerostocktobatchwithdate(datamigracao date) OWNER TO postgres;

--
-- TOC entry 584 (class 1255 OID 123294)
-- Name: id_main_clinic(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.id_main_clinic() RETURNS character varying
    LANGUAGE sql
    AS $$
   SELECT id FROM clinic WHERE main_clinic = true;
$$;


ALTER FUNCTION public.id_main_clinic() OWNER TO postgres;

--
-- TOC entry 585 (class 1255 OID 123295)
-- Name: initstockmovementbatch(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.initstockmovementbatch() RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.initstockmovementbatch() OWNER TO postgres;

--
-- TOC entry 586 (class 1255 OID 123296)
-- Name: return_estatistic_month(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.return_estatistic_month(thedate date) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.return_estatistic_month(thedate date) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 123297)
-- Name: absent_patients_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.absent_patients_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    served_service character varying(255),
    date_missed_pick_up timestamp without time zone,
    returned_pick_up timestamp without time zone,
    nid character varying(255) NOT NULL,
    date_identified_abandonment timestamp without time zone,
    idade integer,
    contact character varying(255),
    end_date timestamp without time zone,
    start_date timestamp without time zone,
    period_type character varying(8) NOT NULL,
    address text,
    district_id character varying(255),
    name character varying(255) NOT NULL,
    period character varying(255),
    clinic character varying(255),
    province_id character varying(255),
    clinical_service_id character varying(255) NOT NULL,
    date_back_us timestamp without time zone,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.absent_patients_report OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 123302)
-- Name: active_patient_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.active_patient_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    pickup_date timestamp without time zone NOT NULL,
    province character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255) NOT NULL,
    prescription_date timestamp without time zone,
    gender character varying(255) NOT NULL,
    district character varying(255),
    nid character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone,
    period_type character varying(8) NOT NULL,
    middle_names character varying(255) NOT NULL,
    therapeutic_regimen character varying(255) NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    age character varying(255) NOT NULL,
    dispense_type character varying(255),
    last_names character varying(255) NOT NULL,
    clinic character varying(255),
    year integer,
    patient_type character varying(255) NOT NULL,
    report_id character varying(255) NOT NULL,
    therapeutic_line character varying(255) NOT NULL
);


ALTER TABLE public.active_patient_report OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 123307)
-- Name: adherence_screening; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adherence_screening (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    days_without_medicine integer,
    visit_id character varying(255) NOT NULL,
    late_days integer,
    patient_forgot_medicine boolean NOT NULL,
    has_patient_came_correct_date boolean NOT NULL,
    late_motives character varying(1000),
    clinic_id character varying(255) DEFAULT ''::character varying NOT NULL,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.adherence_screening REPLICA IDENTITY FULL;


ALTER TABLE public.adherence_screening OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 123314)
-- Name: appointment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointment (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone,
    appointment_date timestamp without time zone,
    clinic_id character varying(255) NOT NULL
);


ALTER TABLE public.appointment OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 123319)
-- Name: appointmet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointmet (
    id bigint NOT NULL,
    version bigint NOT NULL
);


ALTER TABLE public.appointmet OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 123322)
-- Name: arv_daily_register_report_temp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.arv_daily_register_report_temp (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    age_group_10_14 character varying(255) NOT NULL,
    pickup_date timestamp without time zone NOT NULL,
    next_pickup_date timestamp without time zone NOT NULL,
    age_group_5_9 character varying(255) NOT NULL,
    prep character varying(255),
    regime character varying(255),
    month character varying(255),
    pharmacy_id character varying(255),
    nid character varying(255) NOT NULL,
    arv_type character varying(255),
    end_date timestamp without time zone,
    start_reason character varying(255) NOT NULL,
    start_date timestamp without time zone,
    period_type character varying(255),
    age_group_greater_than_15 character varying(255) NOT NULL,
    pack_id character varying(255),
    dispensation_type character varying(255) NOT NULL,
    patient_name character varying(255) NOT NULL,
    ppe character varying(255),
    district_id character varying(255),
    age_group_0_4 character varying(255) NOT NULL,
    semester character varying(255),
    period character varying(255),
    patient_visit_detail_id character varying(255),
    quarter character varying(255),
    province_id character varying(255),
    year integer,
    patient_type character varying(255),
    report_id character varying(255) NOT NULL,
    order_number character varying(255) NOT NULL,
    therapeutic_line character varying(255) NOT NULL
);


ALTER TABLE public.arv_daily_register_report_temp OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 123327)
-- Name: audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_log (
    id bigint NOT NULL,
    persisted_object_id character varying(255),
    property_name character varying(255),
    date_created timestamp without time zone NOT NULL,
    last_updated timestamp without time zone NOT NULL,
    new_value character varying(65534),
    class_name character varying(255),
    event_name character varying(255),
    actor character varying(255),
    old_value character varying(65534),
    persisted_object_version bigint,
    uri character varying(255)
);


ALTER TABLE public.audit_log OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 123332)
-- Name: balancete_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.balancete_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    notas character varying(255) NOT NULL,
    fnm character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    end_date timestamp without time zone NOT NULL,
    start_date timestamp without time zone NOT NULL,
    period_type character varying(255) NOT NULL,
    validade_medicamento timestamp without time zone NOT NULL,
    stock_existente bigint NOT NULL,
    period integer NOT NULL,
    perdaseajustes integer NOT NULL,
    saidas integer NOT NULL,
    medicamento character varying(255) NOT NULL,
    entradas integer NOT NULL,
    unidade character varying(255) NOT NULL,
    year integer NOT NULL,
    dia_do_evento timestamp without time zone NOT NULL,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.balancete_report OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 123337)
-- Name: clinic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinic (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    province_id character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    uuid character varying(255) NOT NULL,
    matchfc character varying(255),
    national_clinic boolean,
    active boolean NOT NULL,
    facility_type_id character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    notes character varying(255),
    parent_clinic_id character varying(255),
    telephone character varying(12),
    main_clinic boolean NOT NULL,
    sync_status character varying(255) NOT NULL,
    clinic_name character varying(255) NOT NULL,
    class character varying(255) NOT NULL
);


ALTER TABLE public.clinic OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 123342)
-- Name: clinic_sector; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinic_sector (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    uuid character varying(255) NOT NULL,
    active boolean NOT NULL,
    sync_status character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    clinic_sector_type_id character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.clinic_sector OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 123347)
-- Name: clinic_sector_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinic_sector_type (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.clinic_sector_type OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 123352)
-- Name: clinic_sector_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinic_sector_users (
    sec_user_id bigint NOT NULL,
    clinic_sector_id character varying(255) NOT NULL
);


ALTER TABLE public.clinic_sector_users OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 123355)
-- Name: clinic_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinic_users (
    sec_user_id bigint NOT NULL,
    clinic_id character varying(255) NOT NULL
);


ALTER TABLE public.clinic_users OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 123358)
-- Name: clinical_service; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinical_service (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    active boolean NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.clinical_service OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 123363)
-- Name: clinical_service_attribute; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinical_service_attribute (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    clinical_service_id character varying(255) NOT NULL,
    clinical_service_attribute_type_id character varying(255) NOT NULL
);


ALTER TABLE public.clinical_service_attribute OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 123368)
-- Name: clinical_service_attribute_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinical_service_attribute_type (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.clinical_service_attribute_type OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 123373)
-- Name: clinical_service_clinic_sector; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinical_service_clinic_sector (
    clinical_service_clinic_sectors_id character varying(255) NOT NULL,
    clinic_sector_id character varying(255)
);


ALTER TABLE public.clinical_service_clinic_sector OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 123378)
-- Name: clinical_service_clinic_sectors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinical_service_clinic_sectors (
    clinical_service_id character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL
);


ALTER TABLE public.clinical_service_clinic_sectors OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 123383)
-- Name: clinical_service_clinical_service_attribute_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinical_service_clinical_service_attribute_type (
    clinical_service_clinical_service_attributes_id character varying(255) NOT NULL,
    clinical_service_attribute_type_id character varying(255)
);


ALTER TABLE public.clinical_service_clinical_service_attribute_type OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 123388)
-- Name: clinical_service_therapeutic_regimens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinical_service_therapeutic_regimens (
    clinical_service_id character varying(255) NOT NULL,
    therapeutic_regimen_id character varying(255) NOT NULL
);


ALTER TABLE public.clinical_service_therapeutic_regimens OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 123393)
-- Name: destroyed_stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.destroyed_stock (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    date timestamp without time zone NOT NULL,
    update_status character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL
);


ALTER TABLE public.destroyed_stock OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 123398)
-- Name: dispense_mode; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dispense_mode (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    openmrs_uuid character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.dispense_mode OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 123403)
-- Name: dispense_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dispense_type (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.dispense_type OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 123408)
-- Name: district; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.district (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    province_id character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.district OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 123413)
-- Name: doctor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctor (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    active boolean NOT NULL,
    gender character varying(255) NOT NULL,
    telephone character varying(12),
    clinic_id character varying(255) NOT NULL,
    firstnames character varying(255) NOT NULL,
    lastname character varying(255) NOT NULL,
    email character varying(255)
);


ALTER TABLE public.doctor OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 123418)
-- Name: drug; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drug (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    default_treatment double precision NOT NULL,
    default_times integer NOT NULL,
    pack_size integer NOT NULL,
    default_period_treatment character varying(255) NOT NULL,
    active boolean NOT NULL,
    fnm_code character varying(255) NOT NULL,
    form_id character varying(255) NOT NULL,
    clinical_service_id character varying(255),
    name character varying(255) NOT NULL,
    uuid_openmrs character varying(255)
);


ALTER TABLE public.drug OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 123423)
-- Name: drug_distributor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drug_distributor (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    drug_id character varying(255) NOT NULL,
    stock_distributor_id character varying(255) NOT NULL,
    quantity integer NOT NULL,
    status character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL
);


ALTER TABLE public.drug_distributor OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 123428)
-- Name: drug_quantity_temp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drug_quantity_temp (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    quantity bigint NOT NULL,
    nid character varying(255) NOT NULL,
    arv_daily_register_report_temp_id character varying(255) NOT NULL,
    drug_name character varying(255) NOT NULL
);


ALTER TABLE public.drug_quantity_temp OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 123433)
-- Name: inventory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    sequence integer NOT NULL,
    open boolean NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    generic boolean NOT NULL,
    clinic_id character varying(255) NOT NULL
);


ALTER TABLE public.inventory OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 123438)
-- Name: pack; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
)
PARTITION BY RANGE (pickup_date);

ALTER TABLE ONLY public.pack REPLICA IDENTITY FULL;


ALTER TABLE public.pack OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 123444)
-- Name: packaged_drug; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.packaged_drug (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    amt_per_time double precision,
    to_continue boolean NOT NULL,
    drug_id character varying(255) NOT NULL,
    quantity_supplied double precision NOT NULL,
    form character varying(255),
    times_per_day integer,
    next_pick_up_date timestamp without time zone,
    quantity_remain integer NOT NULL,
    creation_date timestamp without time zone,
    pack_id character varying(255) NOT NULL,
    clinic_id character varying(255) DEFAULT ''::character varying NOT NULL,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.packaged_drug REPLICA IDENTITY FULL;


ALTER TABLE public.packaged_drug OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 123451)
-- Name: packaged_drug_stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.packaged_drug_stock (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    drug_id character varying(255) NOT NULL,
    quantity_supplied double precision NOT NULL,
    packaged_drug_id character varying(255) NOT NULL,
    stock_id character varying(255) NOT NULL,
    creation_date timestamp without time zone
);


ALTER TABLE public.packaged_drug_stock OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 123456)
-- Name: refered_stock_moviment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refered_stock_moviment (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    origin character varying(100) NOT NULL,
    date timestamp without time zone NOT NULL,
    update_status character(1) NOT NULL,
    quantity integer NOT NULL,
    clinic_id character varying(255) NOT NULL,
    order_number character varying(100) NOT NULL
);


ALTER TABLE public.refered_stock_moviment OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 123461)
-- Name: stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    entrance_id character varying(255) NOT NULL,
    units_received integer NOT NULL,
    modified boolean NOT NULL,
    shelf_number character varying(255),
    drug_id character varying(255) NOT NULL,
    stock_moviment integer NOT NULL,
    batch_number character varying(255) NOT NULL,
    manufacture character varying(255),
    center_id character varying(255) NOT NULL,
    has_units_remaining boolean NOT NULL,
    expire_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL
);


ALTER TABLE public.stock OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 123466)
-- Name: stock_adjustment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_adjustment (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    operation_id character varying(255) NOT NULL,
    balance integer NOT NULL,
    capture_date timestamp without time zone NOT NULL,
    finalised boolean NOT NULL,
    notes character varying(255),
    stock_take integer NOT NULL,
    adjusted_value integer NOT NULL,
    clinic_id character varying(255) NOT NULL,
    adjusted_stock_id character varying(255) NOT NULL,
    class character varying(255) NOT NULL,
    reference_id character varying(255),
    inventory_id character varying(255),
    destruction_id character varying(255),
    is_distribution boolean DEFAULT false
);


ALTER TABLE public.stock_adjustment OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 123472)
-- Name: stock_entrance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_entrance (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    notes character varying(255),
    date_received timestamp without time zone NOT NULL,
    creation_date timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    is_distribution boolean NOT NULL,
    order_number character varying(255) NOT NULL
);


ALTER TABLE public.stock_entrance OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 123477)
-- Name: stock_operation_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_operation_type (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(50) NOT NULL,
    description character varying(50) NOT NULL
);


ALTER TABLE public.stock_operation_type OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 123480)
-- Name: drug_stock_batch_summary_vw; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.drug_stock_batch_summary_vw AS
 WITH entrada AS (
         SELECT s.drug_id,
            date(se.date_received) AS event_date,
                CASE
                    WHEN (se.is_distribution = true) THEN 'Distrib. Entrada de Stock'::text
                    ELSE 'Entrada de Stock'::text
                END AS moviment,
            sum(ceil((s.units_received)::double precision)) AS incomes,
            0 AS outcomes,
            0 AS posetiveadjustment,
            0 AS negativeadjustment,
            0 AS loses,
            se.clinic_id,
            'ENTRADA'::text AS code,
            s.id AS stock,
            max(se.date_received) AS max_date
           FROM (public.stock_entrance se
             JOIN public.stock s ON (((se.id)::text = (s.entrance_id)::text)))
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
           FROM (((public.packaged_drug pd
             JOIN public.packaged_drug_stock pds ON (((pd.id)::text = (pds.packaged_drug_id)::text)))
             JOIN public.stock s ON (((s.id)::text = (pds.stock_id)::text)))
             JOIN public.pack p ON (((p.id)::text = (pd.pack_id)::text)))
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
                    WHEN (sa.is_distribution = true) THEN 'Distrib. Ajuste positivo'::text
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
           FROM (((public.stock_adjustment sa
             JOIN public.refered_stock_moviment rsm ON (((sa.reference_id)::text = (rsm.id)::text)))
             JOIN public.stock s ON (((sa.adjusted_stock_id)::text = (s.id)::text)))
             JOIN public.stock_operation_type sot ON (((sa.operation_id)::text = (sot.id)::text)))
          WHERE ((sot.code)::text = 'AJUSTE_POSETIVO'::text)
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
                    WHEN (sa.is_distribution = true) THEN 'Distrib. Ajuste negativo'::text
                    ELSE 'Ajuste negativo'::text
                END AS moviment,
            0 AS incomes,
            0 AS outcomes,
            0 AS posetiveadjustment,
            sum(ceil((sa.adjusted_value)::double precision)) AS negativeadjustment,
            0 AS loses,
            rsm.clinic_id,
            'AJUSTE_NEGATIVO'::text AS code,
            s.id AS stock,
            max(rsm.date) AS max_date
           FROM (((public.stock_adjustment sa
             JOIN public.refered_stock_moviment rsm ON (((sa.reference_id)::text = (rsm.id)::text)))
             JOIN public.stock s ON (((sa.adjusted_stock_id)::text = (s.id)::text)))
             JOIN public.stock_operation_type sot ON (((sa.operation_id)::text = (sot.id)::text)))
          WHERE ((sot.code)::text = 'AJUSTE_NEGATIVO'::text)
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
            sum(ceil((sa.adjusted_value)::double precision)) AS loses,
            ds.clinic_id,
            'PERDA'::text AS code,
            s.id AS stock,
            max(ds.date) AS max_date
           FROM ((public.stock_adjustment sa
             JOIN public.destroyed_stock ds ON (((sa.destruction_id)::text = (ds.id)::text)))
             JOIN public.stock s ON (((sa.adjusted_stock_id)::text = (s.id)::text)))
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
                    WHEN ((sot.code)::text = 'AJUSTE_POSETIVO'::text) THEN sa.adjusted_value
                    ELSE 0
                END) AS posetiveadjustment,
            sum(
                CASE
                    WHEN ((sot.code)::text = 'AJUSTE_NEGATIVO'::text) THEN sa.adjusted_value
                    ELSE 0
                END) AS negativeadjustment,
            0 AS loses,
            i.clinic_id,
            'INVENTARIO'::text AS code,
            s.id AS stock,
            max(i.end_date) AS max_date
           FROM (((public.stock_adjustment sa
             JOIN public.inventory i ON (((sa.inventory_id)::text = (i.id)::text)))
             JOIN public.stock s ON (((sa.adjusted_stock_id)::text = (s.id)::text)))
             JOIN public.stock_operation_type sot ON (((sa.operation_id)::text = (sot.id)::text)))
          WHERE (i.end_date IS NOT NULL)
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


ALTER VIEW public.drug_stock_batch_summary_vw OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 123485)
-- Name: drug_stock_summary_vw; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.drug_stock_summary_vw AS
 WITH entrada AS (
         SELECT EXTRACT(year FROM se.date_received) AS event_year,
            public.return_estatistic_month((se.date_received)::date) AS event_month,
            s.drug_id,
                CASE
                    WHEN (se.is_distribution = true) THEN 'Distrib. Entrada de Stock'::text
                    ELSE 'Entrada de Stock'::text
                END AS moviment,
            sum(ceil((s.units_received)::double precision)) AS incomes,
            0 AS outcomes,
            0 AS positiveadjustment,
            0 AS negativeadjustment,
            0 AS losses,
            se.clinic_id,
            'ENTRADA'::text AS code,
            ''::text AS stock,
            max(se.date_received) AS max_date
           FROM (public.stock_entrance se
             JOIN public.stock s ON (((se.id)::text = (s.entrance_id)::text)))
          WHERE (date(s.expire_date) >= CURRENT_DATE)
          GROUP BY (EXTRACT(year FROM se.date_received)), (public.return_estatistic_month((se.date_received)::date)), s.drug_id,
                CASE
                    WHEN (se.is_distribution = true) THEN 'Distrib. Entrada de Stock'::text
                    ELSE 'Entrada de Stock'::text
                END, 0::integer, se.clinic_id
          ORDER BY (EXTRACT(year FROM se.date_received)) DESC, (public.return_estatistic_month((se.date_received)::date)) DESC
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
            public.return_estatistic_month((p.pickup_date)::date) AS event_month,
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
           FROM (((public.packaged_drug pd
             JOIN public.packaged_drug_stock pds ON (((pd.id)::text = (pds.packaged_drug_id)::text)))
             JOIN public.stock s ON (((s.id)::text = (pds.stock_id)::text)))
             JOIN public.pack p ON (((p.id)::text = (pd.pack_id)::text)))
          WHERE (date(s.expire_date) >= CURRENT_DATE)
          GROUP BY (EXTRACT(year FROM p.pickup_date)), (public.return_estatistic_month((p.pickup_date)::date)), pd.drug_id, 'Saídas'::text, 0::integer, p.clinic_id
          ORDER BY (EXTRACT(year FROM p.pickup_date)) DESC, (public.return_estatistic_month((p.pickup_date)::date)) DESC
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
            public.return_estatistic_month((rsm.date)::date) AS event_month,
            s.drug_id,
                CASE
                    WHEN (sa.is_distribution = true) THEN 'Distrib. Ajuste positivo'::text
                    ELSE 'Ajuste positivo'::text
                END AS moviment,
            0 AS incomes,
            0 AS outcomes,
            sum(ceil((sa.adjusted_value)::double precision)) AS positiveadjustment,
            0 AS negativeadjustment,
            0 AS losses,
            rsm.clinic_id,
            'AJUSTE_POSETIVO'::text AS code,
            ''::text AS stock,
            max(rsm.date) AS max_date
           FROM (((public.stock_adjustment sa
             JOIN public.refered_stock_moviment rsm ON (((sa.reference_id)::text = (rsm.id)::text)))
             JOIN public.stock s ON (((sa.adjusted_stock_id)::text = (s.id)::text)))
             JOIN public.stock_operation_type sot ON (((sa.operation_id)::text = (sot.id)::text)))
          WHERE (((sot.code)::text = 'AJUSTE_POSETIVO'::text) AND (date(s.expire_date) >= CURRENT_DATE))
          GROUP BY (EXTRACT(year FROM rsm.date)), (public.return_estatistic_month((rsm.date)::date)), s.drug_id,
                CASE
                    WHEN (sa.is_distribution = true) THEN 'Distrib. Ajuste positivo'::text
                    ELSE 'Ajuste positivo'::text
                END, 0::integer, rsm.clinic_id
          ORDER BY (EXTRACT(year FROM rsm.date)) DESC, (public.return_estatistic_month((rsm.date)::date)) DESC
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
            public.return_estatistic_month((rsm.date)::date) AS event_month,
            s.drug_id,
                CASE
                    WHEN (sa.is_distribution = true) THEN 'Distrib. Ajuste Negativo'::text
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
           FROM (((public.stock_adjustment sa
             JOIN public.refered_stock_moviment rsm ON (((sa.reference_id)::text = (rsm.id)::text)))
             JOIN public.stock s ON (((sa.adjusted_stock_id)::text = (s.id)::text)))
             JOIN public.stock_operation_type sot ON (((sa.operation_id)::text = (sot.id)::text)))
          WHERE (((sot.code)::text = 'AJUSTE_NEGATIVO'::text) AND (date(s.expire_date) >= CURRENT_DATE))
          GROUP BY (EXTRACT(year FROM rsm.date)), (public.return_estatistic_month((rsm.date)::date)), s.drug_id,
                CASE
                    WHEN (sa.is_distribution = true) THEN 'Distrib. Ajuste Negativo'::text
                    ELSE 'Ajuste Negativo'::text
                END, 0::integer, rsm.clinic_id
          ORDER BY (EXTRACT(year FROM rsm.date)) DESC, (public.return_estatistic_month((rsm.date)::date)) DESC
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
            public.return_estatistic_month((ds.date)::date) AS event_month,
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
           FROM ((public.stock_adjustment sa
             JOIN public.destroyed_stock ds ON (((sa.destruction_id)::text = (ds.id)::text)))
             JOIN public.stock s ON ((((sa.adjusted_stock_id)::text = (s.id)::text) AND (date(s.expire_date) >= CURRENT_DATE))))
          GROUP BY (EXTRACT(year FROM ds.date)), (public.return_estatistic_month((ds.date)::date)), s.drug_id, 'Perda'::text, ds.clinic_id, 'PERDA'::text, ''::text
          ORDER BY (EXTRACT(year FROM ds.date)) DESC, (public.return_estatistic_month((ds.date)::date)) DESC
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
            public.return_estatistic_month((i.end_date)::date) AS event_month,
            s.drug_id,
            'Inventário'::text AS moviment,
            0 AS incomes,
            0 AS outcomes,
            sum(
                CASE
                    WHEN ((sot.code)::text = 'AJUSTE_POSETIVO'::text) THEN ceil((sa.adjusted_value)::double precision)
                    ELSE (0)::double precision
                END) AS positiveadjustment,
            sum(
                CASE
                    WHEN ((sot.code)::text = 'AJUSTE_NEGATIVO'::text) THEN ceil((sa.adjusted_value)::double precision)
                    ELSE (0)::double precision
                END) AS negativeadjustment,
            0 AS losses,
            i.clinic_id,
            'INVENTARIO'::text AS code,
            ''::text AS stock,
            max(i.end_date) AS max_date
           FROM (((public.stock_adjustment sa
             JOIN public.inventory i ON (((sa.inventory_id)::text = (i.id)::text)))
             JOIN public.stock s ON (((sa.adjusted_stock_id)::text = (s.id)::text)))
             JOIN public.stock_operation_type sot ON (((sa.operation_id)::text = (sot.id)::text)))
          WHERE ((i.end_date IS NOT NULL) AND (date(s.expire_date) >= CURRENT_DATE))
          GROUP BY (EXTRACT(year FROM i.end_date)), (public.return_estatistic_month((i.end_date)::date)), s.drug_id, 'Inventário'::text, 0::integer, i.clinic_id
          ORDER BY (EXTRACT(year FROM i.end_date)) DESC, (public.return_estatistic_month((i.end_date)::date)) DESC
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


ALTER VIEW public.drug_stock_summary_vw OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 123490)
-- Name: duration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.duration (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    description character varying(255) NOT NULL,
    weeks integer NOT NULL
);


ALTER TABLE public.duration OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 123495)
-- Name: episode; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
)
PARTITION BY RANGE (episode_date);

ALTER TABLE ONLY public.episode REPLICA IDENTITY FULL;


ALTER TABLE public.episode OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 123500)
-- Name: episode_21122008; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122008 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122008 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122008 OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 123507)
-- Name: episode_21122009; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122009 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122009 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122009 OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 123514)
-- Name: episode_21122010; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122010 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122010 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122010 OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 123521)
-- Name: episode_21122011; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122011 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122011 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122011 OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 123528)
-- Name: episode_21122012; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122012 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122012 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122012 OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 123535)
-- Name: episode_21122013; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122013 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122013 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122013 OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 123542)
-- Name: episode_21122014; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122014 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122014 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122014 OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 123549)
-- Name: episode_21122015; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122015 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122015 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122015 OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 123556)
-- Name: episode_21122016; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122016 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122016 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122016 OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 123563)
-- Name: episode_21122017; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122017 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122017 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122017 OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 123570)
-- Name: episode_21122018; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122018 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122018 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122018 OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 123577)
-- Name: episode_21122019; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122019 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122019 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122019 OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 123584)
-- Name: episode_21122020; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122020 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122020 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122020 OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 123591)
-- Name: episode_21122021; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122021 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122021 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122021 OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 123598)
-- Name: episode_21122022; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122022 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122022 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122022 OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 123605)
-- Name: episode_21122023; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122023 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122023 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122023 OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 123612)
-- Name: episode_21122024; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122024 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122024 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122024 OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 123619)
-- Name: episode_21122025; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122025 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122025 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122025 OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 123626)
-- Name: episode_21122026; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122026 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122026 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122026 OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 123633)
-- Name: episode_21122027; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122027 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122027 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122027 OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 123640)
-- Name: episode_21122028; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122028 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122028 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122028 OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 123647)
-- Name: episode_21122029; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122029 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122029 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122029 OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 123654)
-- Name: episode_21122030; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122030 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122030 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122030 OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 123661)
-- Name: episode_21122031; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_21122031 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_21122031 REPLICA IDENTITY FULL;


ALTER TABLE public.episode_21122031 OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 123668)
-- Name: episode_others; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_others (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_type_id character varying(255) NOT NULL,
    notes character varying(255) NOT NULL,
    clinic_sector_id character varying(255) NOT NULL,
    start_stop_reason_id character varying(255) NOT NULL,
    patient_service_identifier_id character varying(255) NOT NULL,
    referral_clinic_id character varying(255),
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    episode_date timestamp without time zone NOT NULL,
    is_abandonmentdc boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.episode_others REPLICA IDENTITY FULL;


ALTER TABLE public.episode_others OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 123675)
-- Name: episode_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.episode_type (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.episode_type OWNER TO postgres;

--
-- TOC entry 282 (class 1259 OID 123680)
-- Name: expected_patient_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expected_patient_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    province character varying(255),
    first_names character varying(255) NOT NULL,
    district character varying(255),
    nid character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone,
    period_type character varying(8) NOT NULL,
    middle_names character varying(255) NOT NULL,
    therapeutic_regimen character varying(255) NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    dispense_type character varying(255),
    last_names character varying(255) NOT NULL,
    clinic character varying(255),
    clinic_sector_name character varying(255),
    year integer,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.expected_patient_report OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 123685)
-- Name: facility_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facility_type (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.facility_type OWNER TO postgres;

--
-- TOC entry 284 (class 1259 OID 123690)
-- Name: form; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.form (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    unit character varying(255) DEFAULT ''::character varying NOT NULL,
    how_to_use character varying(255) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.form OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 123697)
-- Name: group_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_info (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    group_type_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    dispense_type_id character varying(255),
    creation_date timestamp without time zone,
    clinic_id character varying(255) NOT NULL
);


ALTER TABLE public.group_info OWNER TO postgres;

--
-- TOC entry 286 (class 1259 OID 123702)
-- Name: group_member; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_member (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    group_id character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL
);


ALTER TABLE public.group_member OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 123707)
-- Name: group_member_prescription; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_member_prescription (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    used boolean NOT NULL,
    member_id character varying(255) NOT NULL,
    prescription_id character varying(255) NOT NULL
);


ALTER TABLE public.group_member_prescription OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 123712)
-- Name: group_pack; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_pack (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    header_id character varying(255) NOT NULL,
    pack_id character varying(255)
);


ALTER TABLE public.group_pack OWNER TO postgres;

--
-- TOC entry 289 (class 1259 OID 123717)
-- Name: group_pack_header; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_pack_header (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    group_id character varying(255) NOT NULL,
    duration_id character varying(255) NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    pack_date timestamp without time zone NOT NULL
);


ALTER TABLE public.group_pack_header OWNER TO postgres;

--
-- TOC entry 290 (class 1259 OID 123722)
-- Name: group_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_type (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.group_type OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 123727)
-- Name: health_information_system; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.health_information_system (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    abbreviation character varying(255) NOT NULL,
    active boolean NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.health_information_system OWNER TO postgres;

--
-- TOC entry 292 (class 1259 OID 123732)
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hibernate_sequence OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 123733)
-- Name: historico_levantamento_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historico_levantamento_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    nex_pick_up_date timestamp without time zone NOT NULL,
    province character varying(255) NOT NULL,
    first_names character varying(255) NOT NULL,
    cellphone character varying(255) NOT NULL,
    tipo_tarv character varying(255) NOT NULL,
    nid character varying(255) NOT NULL,
    district character varying(255) NOT NULL,
    therapeutical_regimen character varying(255) NOT NULL,
    clinicsector character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_reason character varying(255),
    start_date timestamp without time zone,
    period_type character varying(8) NOT NULL,
    middle_names character varying(255) NOT NULL,
    age character varying(255) NOT NULL,
    clinical_service character varying(255) NOT NULL,
    dispense_mode character varying(255) NOT NULL,
    period integer NOT NULL,
    pick_up_date timestamp without time zone NOT NULL,
    dispense_type character varying(255) NOT NULL,
    last_names character varying(255) NOT NULL,
    clinic character varying(255) NOT NULL,
    year integer NOT NULL,
    patient_type character varying(255),
    idmeduser character varying(255),
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.historico_levantamento_report OWNER TO postgres;

--
-- TOC entry 294 (class 1259 OID 123738)
-- Name: identifier_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.identifier_type (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    pattern character varying(255),
    description character varying(255) NOT NULL
);


ALTER TABLE public.identifier_type OWNER TO postgres;

--
-- TOC entry 295 (class 1259 OID 123743)
-- Name: interoperability_attribute; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.interoperability_attribute (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    health_information_system_id character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    interoperability_type_id character varying(255) NOT NULL
);


ALTER TABLE public.interoperability_attribute OWNER TO postgres;

--
-- TOC entry 296 (class 1259 OID 123748)
-- Name: interoperability_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.interoperability_type (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.interoperability_type OWNER TO postgres;

--
-- TOC entry 297 (class 1259 OID 123753)
-- Name: inventory_report_response; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_report_response (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    total_balance bigint NOT NULL,
    drug_name character varying(255) NOT NULL,
    total_adjusted_value bigint NOT NULL
);


ALTER TABLE public.inventory_report_response OWNER TO postgres;

--
-- TOC entry 298 (class 1259 OID 123758)
-- Name: inventory_report_response_inventory_report_temp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_report_response_inventory_report_temp (
    inventory_report_response_adjustments_id character varying(255) NOT NULL,
    inventory_report_temp_id character varying(255),
    adjustments_idx integer
);


ALTER TABLE public.inventory_report_response_inventory_report_temp OWNER TO postgres;

--
-- TOC entry 299 (class 1259 OID 123763)
-- Name: inventory_report_temp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_report_temp (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    province character varying(255) NOT NULL,
    balance bigint,
    capture_date timestamp without time zone,
    month character varying(255),
    pharmacy_id character varying(255),
    district character varying(255) NOT NULL,
    notes character varying(255),
    inventory_type character varying(255),
    end_date timestamp without time zone,
    inventory_start_date timestamp without time zone,
    start_date timestamp without time zone,
    period_type character varying(255),
    adjusted_value bigint,
    inventory_id character varying(255),
    batch_number character varying(255),
    district_id character varying(255),
    operation_type character varying(255) NOT NULL,
    semester character varying(255),
    form_description character varying(255),
    period character varying(255),
    inventory_end_date timestamp without time zone,
    clinic character varying(255) NOT NULL,
    expire_date timestamp without time zone,
    quarter character varying(255),
    province_id character varying(255),
    year integer,
    drug_name character varying(255),
    report_id character varying(255) NOT NULL,
    order_number character varying(255)
);


ALTER TABLE public.inventory_report_temp OWNER TO postgres;

--
-- TOC entry 300 (class 1259 OID 123768)
-- Name: linhas_usadas_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.linhas_usadas_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    linha_terapeutica character varying(255) NOT NULL,
    estado character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    total_prescricoes integer NOT NULL,
    codigo_regime character varying(255) NOT NULL,
    end_date timestamp without time zone NOT NULL,
    start_date timestamp without time zone NOT NULL,
    period_type character varying(255) NOT NULL,
    regime_terapeutico character varying(255) NOT NULL,
    period integer NOT NULL,
    year integer NOT NULL,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.linhas_usadas_report OWNER TO postgres;

--
-- TOC entry 301 (class 1259 OID 123773)
-- Name: localidade; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.localidade (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    district_id character varying(255),
    posto_administrativo_id character varying(255),
    description character varying(255) NOT NULL
);


ALTER TABLE public.localidade OWNER TO postgres;

--
-- TOC entry 302 (class 1259 OID 123778)
-- Name: menu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menu (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.menu OWNER TO postgres;

--
-- TOC entry 303 (class 1259 OID 123783)
-- Name: migration_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
)
PARTITION BY HASH (source_id);

ALTER TABLE ONLY public.migration_log REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 123786)
-- Name: migration_log_000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_000 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_000 OWNER TO postgres;

--
-- TOC entry 305 (class 1259 OID 123791)
-- Name: migration_log_001; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_001 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_001 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_001 OWNER TO postgres;

--
-- TOC entry 306 (class 1259 OID 123796)
-- Name: migration_log_002; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_002 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_002 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_002 OWNER TO postgres;

--
-- TOC entry 307 (class 1259 OID 123801)
-- Name: migration_log_003; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_003 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_003 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_003 OWNER TO postgres;

--
-- TOC entry 308 (class 1259 OID 123806)
-- Name: migration_log_004; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_004 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_004 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_004 OWNER TO postgres;

--
-- TOC entry 309 (class 1259 OID 123811)
-- Name: migration_log_005; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_005 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_005 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_005 OWNER TO postgres;

--
-- TOC entry 310 (class 1259 OID 123816)
-- Name: migration_log_006; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_006 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_006 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_006 OWNER TO postgres;

--
-- TOC entry 311 (class 1259 OID 123821)
-- Name: migration_log_007; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_007 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_007 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_007 OWNER TO postgres;

--
-- TOC entry 312 (class 1259 OID 123826)
-- Name: migration_log_008; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_008 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_008 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_008 OWNER TO postgres;

--
-- TOC entry 313 (class 1259 OID 123831)
-- Name: migration_log_009; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_009 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_009 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_009 OWNER TO postgres;

--
-- TOC entry 314 (class 1259 OID 123836)
-- Name: migration_log_010; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_010 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_010 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_010 OWNER TO postgres;

--
-- TOC entry 315 (class 1259 OID 123841)
-- Name: migration_log_011; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_011 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_011 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_011 OWNER TO postgres;

--
-- TOC entry 316 (class 1259 OID 123846)
-- Name: migration_log_012; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_012 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_012 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_012 OWNER TO postgres;

--
-- TOC entry 317 (class 1259 OID 123851)
-- Name: migration_log_013; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_013 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_013 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_013 OWNER TO postgres;

--
-- TOC entry 318 (class 1259 OID 123856)
-- Name: migration_log_014; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_014 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_014 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_014 OWNER TO postgres;

--
-- TOC entry 319 (class 1259 OID 123861)
-- Name: migration_log_015; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_015 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_015 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_015 OWNER TO postgres;

--
-- TOC entry 320 (class 1259 OID 123866)
-- Name: migration_log_016; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_016 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_016 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_016 OWNER TO postgres;

--
-- TOC entry 321 (class 1259 OID 123871)
-- Name: migration_log_017; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_017 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_017 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_017 OWNER TO postgres;

--
-- TOC entry 322 (class 1259 OID 123876)
-- Name: migration_log_018; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_018 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_018 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_018 OWNER TO postgres;

--
-- TOC entry 323 (class 1259 OID 123881)
-- Name: migration_log_019; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_019 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_019 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_019 OWNER TO postgres;

--
-- TOC entry 324 (class 1259 OID 123886)
-- Name: migration_log_020; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_020 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_020 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_020 OWNER TO postgres;

--
-- TOC entry 325 (class 1259 OID 123891)
-- Name: migration_log_021; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_021 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_021 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_021 OWNER TO postgres;

--
-- TOC entry 326 (class 1259 OID 123896)
-- Name: migration_log_022; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_022 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_022 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_022 OWNER TO postgres;

--
-- TOC entry 327 (class 1259 OID 123901)
-- Name: migration_log_023; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_023 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_023 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_023 OWNER TO postgres;

--
-- TOC entry 328 (class 1259 OID 123906)
-- Name: migration_log_024; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_024 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_024 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_024 OWNER TO postgres;

--
-- TOC entry 329 (class 1259 OID 123911)
-- Name: migration_log_025; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_025 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_025 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_025 OWNER TO postgres;

--
-- TOC entry 330 (class 1259 OID 123916)
-- Name: migration_log_026; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_026 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_026 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_026 OWNER TO postgres;

--
-- TOC entry 331 (class 1259 OID 123921)
-- Name: migration_log_027; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_027 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_027 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_027 OWNER TO postgres;

--
-- TOC entry 332 (class 1259 OID 123926)
-- Name: migration_log_028; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_028 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_028 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_028 OWNER TO postgres;

--
-- TOC entry 333 (class 1259 OID 123931)
-- Name: migration_log_029; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_029 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_029 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_029 OWNER TO postgres;

--
-- TOC entry 334 (class 1259 OID 123936)
-- Name: migration_log_030; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_030 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_030 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_030 OWNER TO postgres;

--
-- TOC entry 335 (class 1259 OID 123941)
-- Name: migration_log_031; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_031 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_031 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_031 OWNER TO postgres;

--
-- TOC entry 336 (class 1259 OID 123946)
-- Name: migration_log_032; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_032 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_032 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_032 OWNER TO postgres;

--
-- TOC entry 337 (class 1259 OID 123951)
-- Name: migration_log_033; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_033 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_033 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_033 OWNER TO postgres;

--
-- TOC entry 338 (class 1259 OID 123956)
-- Name: migration_log_034; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_034 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_034 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_034 OWNER TO postgres;

--
-- TOC entry 339 (class 1259 OID 123961)
-- Name: migration_log_035; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_035 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_035 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_035 OWNER TO postgres;

--
-- TOC entry 340 (class 1259 OID 123966)
-- Name: migration_log_036; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_036 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_036 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_036 OWNER TO postgres;

--
-- TOC entry 341 (class 1259 OID 123971)
-- Name: migration_log_037; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_037 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_037 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_037 OWNER TO postgres;

--
-- TOC entry 342 (class 1259 OID 123976)
-- Name: migration_log_038; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_038 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_038 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_038 OWNER TO postgres;

--
-- TOC entry 343 (class 1259 OID 123981)
-- Name: migration_log_039; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_039 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_039 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_039 OWNER TO postgres;

--
-- TOC entry 344 (class 1259 OID 123986)
-- Name: migration_log_040; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_040 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_040 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_040 OWNER TO postgres;

--
-- TOC entry 345 (class 1259 OID 123991)
-- Name: migration_log_041; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_041 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_041 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_041 OWNER TO postgres;

--
-- TOC entry 346 (class 1259 OID 123996)
-- Name: migration_log_042; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_042 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_042 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_042 OWNER TO postgres;

--
-- TOC entry 347 (class 1259 OID 124001)
-- Name: migration_log_043; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_043 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_043 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_043 OWNER TO postgres;

--
-- TOC entry 348 (class 1259 OID 124006)
-- Name: migration_log_044; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_044 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_044 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_044 OWNER TO postgres;

--
-- TOC entry 349 (class 1259 OID 124011)
-- Name: migration_log_045; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_045 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_045 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_045 OWNER TO postgres;

--
-- TOC entry 350 (class 1259 OID 124016)
-- Name: migration_log_046; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_046 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_046 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_046 OWNER TO postgres;

--
-- TOC entry 351 (class 1259 OID 124021)
-- Name: migration_log_047; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_047 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_047 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_047 OWNER TO postgres;

--
-- TOC entry 352 (class 1259 OID 124026)
-- Name: migration_log_048; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_048 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_048 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_048 OWNER TO postgres;

--
-- TOC entry 353 (class 1259 OID 124031)
-- Name: migration_log_049; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_log_049 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    error_description bytea NOT NULL,
    error_code character varying(255) NOT NULL,
    source_entity character varying(255) NOT NULL,
    source_id integer NOT NULL,
    idmedentity character varying(255),
    idmedid character varying(255),
    creation_date timestamp without time zone,
    status character varying(255) NOT NULL
);

ALTER TABLE ONLY public.migration_log_049 REPLICA IDENTITY FULL;


ALTER TABLE public.migration_log_049 OWNER TO postgres;

--
-- TOC entry 354 (class 1259 OID 124036)
-- Name: migration_stage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_stage (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.migration_stage OWNER TO postgres;

--
-- TOC entry 355 (class 1259 OID 124041)
-- Name: mmia_regimen_sub_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mmia_regimen_sub_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    regimen character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    line character varying(255),
    total_patients integer NOT NULL,
    line_code character varying(255),
    totalline1 integer,
    line3 character varying(255),
    line2 character varying(255),
    totaldcline4 integer,
    line1 character varying(255),
    totalline2 integer,
    mmia_report_id character varying(255),
    line4 character varying(255),
    totalline3 integer,
    totaldcline2 integer,
    totalline4 integer,
    totaldcline1 integer,
    cumunitary_clinic integer NOT NULL,
    totaldcline3 integer,
    report_id character varying(255) NOT NULL,
    total_referidos integer DEFAULT 0,
    totalrefline1 integer,
    totalrefline3 integer,
    totalrefline2 integer
);


ALTER TABLE public.mmia_regimen_sub_report OWNER TO postgres;

--
-- TOC entry 356 (class 1259 OID 124047)
-- Name: mmia_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mmia_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    total_pacientes_adulto integer NOT NULL,
    dm integer NOT NULL,
    dsm0 integer NOT NULL,
    dsm3 integer NOT NULL,
    total_pacientes59 integer NOT NULL,
    totalpacientesce integer NOT NULL,
    clinic_id character varying(255) NOT NULL,
    dsm1 integer NOT NULL,
    dbm1 integer NOT NULL,
    total_pacientes_inicio integer NOT NULL,
    dbm0 integer NOT NULL,
    end_date timestamp without time zone NOT NULL,
    dsm5 integer NOT NULL,
    total_pacientes_transito integer NOT NULL,
    total_pacientesppe integer NOT NULL,
    start_date timestamp without time zone NOT NULL,
    total_pacientes_manter integer NOT NULL,
    period_type character varying(5) NOT NULL,
    dtm1 integer NOT NULL,
    total_pacientes_transferido_de integer NOT NULL,
    total_pacientes_alterar integer NOT NULL,
    total_pacientes1014 integer NOT NULL,
    dsm2 integer NOT NULL,
    period integer NOT NULL,
    dsm4 integer NOT NULL,
    dtm2 integer NOT NULL,
    dtm0 integer NOT NULL,
    total_pacientes04 integer NOT NULL,
    year integer NOT NULL,
    report_id character varying(255) NOT NULL,
    total_pacientesprep integer NOT NULL
);


ALTER TABLE public.mmia_report OWNER TO postgres;

--
-- TOC entry 357 (class 1259 OID 124052)
-- Name: mmia_report_clinic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mmia_report_clinic (
    clinic_id character varying(255) NOT NULL,
    mmia_report_clinic_id character varying(255) NOT NULL
);


ALTER TABLE public.mmia_report_clinic OWNER TO postgres;

--
-- TOC entry 358 (class 1259 OID 124057)
-- Name: mmia_stock_sub_report_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mmia_stock_sub_report_item (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    losses_adjustments integer NOT NULL,
    balance integer NOT NULL,
    outcomes integer NOT NULL,
    fnm_code character varying(255) NOT NULL,
    mmia_report_id character varying(255),
    inventory integer NOT NULL,
    unit character varying(255) NOT NULL,
    expire_date timestamp without time zone NOT NULL,
    initial_entrance integer NOT NULL,
    drug_name character varying(255) NOT NULL,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.mmia_stock_sub_report_item OWNER TO postgres;

--
-- TOC entry 359 (class 1259 OID 124062)
-- Name: national_clinic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.national_clinic (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    province_id character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    active boolean NOT NULL,
    facility_type_id character varying(255) NOT NULL,
    facility_name character varying(255) NOT NULL,
    telephone character varying(12)
);


ALTER TABLE public.national_clinic OWNER TO postgres;

--
-- TOC entry 360 (class 1259 OID 124067)
-- Name: national_clinic_clinic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.national_clinic_clinic (
    national_clinic_clinics_id character varying(255) NOT NULL,
    clinic_id character varying(255)
);


ALTER TABLE public.national_clinic_clinic OWNER TO postgres;

--
-- TOC entry 361 (class 1259 OID 124072)
-- Name: not_synchronizing_packs_open_mrs_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.not_synchronizing_packs_open_mrs_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient character varying(255) NOT NULL,
    pickup_date timestamp without time zone NOT NULL,
    error_description text,
    date_created timestamp without time zone,
    json_request text,
    pharmacy_id character varying(255),
    nid character varying(255),
    end_date timestamp without time zone,
    start_date timestamp without time zone,
    period_type character varying(255) NOT NULL,
    return_pickup_date timestamp without time zone,
    patient_visit_details character varying(255) NOT NULL,
    clinical_service character varying(255),
    district_id character varying(255),
    period character varying(255),
    province_id character varying(255),
    year integer,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.not_synchronizing_packs_open_mrs_report OWNER TO postgres;

--
-- TOC entry 362 (class 1259 OID 124077)
-- Name: openmrs_error_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.openmrs_error_log (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient character varying(255) NOT NULL,
    pickup_date timestamp without time zone NOT NULL,
    error_description text NOT NULL,
    return_pickup_date timestamp without time zone,
    date_created timestamp without time zone NOT NULL,
    patient_visit_details character varying(255) NOT NULL,
    json_request character varying(15000) NOT NULL,
    servico_clinico character varying(255) NOT NULL,
    nid character varying(255) NOT NULL
);


ALTER TABLE public.openmrs_error_log OWNER TO postgres;

--
-- TOC entry 363 (class 1259 OID 124082)
-- Name: pack_21122008; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122008 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122008 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122008 OWNER TO postgres;

--
-- TOC entry 364 (class 1259 OID 124090)
-- Name: pack_21122009; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122009 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122009 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122009 OWNER TO postgres;

--
-- TOC entry 365 (class 1259 OID 124098)
-- Name: pack_21122010; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122010 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122010 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122010 OWNER TO postgres;

--
-- TOC entry 366 (class 1259 OID 124106)
-- Name: pack_21122011; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122011 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122011 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122011 OWNER TO postgres;

--
-- TOC entry 367 (class 1259 OID 124114)
-- Name: pack_21122012; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122012 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122012 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122012 OWNER TO postgres;

--
-- TOC entry 368 (class 1259 OID 124122)
-- Name: pack_21122013; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122013 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122013 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122013 OWNER TO postgres;

--
-- TOC entry 369 (class 1259 OID 124130)
-- Name: pack_21122014; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122014 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122014 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122014 OWNER TO postgres;

--
-- TOC entry 370 (class 1259 OID 124138)
-- Name: pack_21122015; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122015 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122015 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122015 OWNER TO postgres;

--
-- TOC entry 371 (class 1259 OID 124146)
-- Name: pack_21122016; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122016 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122016 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122016 OWNER TO postgres;

--
-- TOC entry 372 (class 1259 OID 124154)
-- Name: pack_21122017; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122017 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122017 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122017 OWNER TO postgres;

--
-- TOC entry 373 (class 1259 OID 124162)
-- Name: pack_21122018; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122018 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122018 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122018 OWNER TO postgres;

--
-- TOC entry 374 (class 1259 OID 124170)
-- Name: pack_21122019; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122019 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122019 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122019 OWNER TO postgres;

--
-- TOC entry 375 (class 1259 OID 124178)
-- Name: pack_21122020; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122020 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122020 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122020 OWNER TO postgres;

--
-- TOC entry 376 (class 1259 OID 124186)
-- Name: pack_21122021; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122021 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122021 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122021 OWNER TO postgres;

--
-- TOC entry 377 (class 1259 OID 124194)
-- Name: pack_21122022; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122022 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122022 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122022 OWNER TO postgres;

--
-- TOC entry 378 (class 1259 OID 124202)
-- Name: pack_21122023; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122023 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122023 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122023 OWNER TO postgres;

--
-- TOC entry 379 (class 1259 OID 124210)
-- Name: pack_21122024; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122024 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122024 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122024 OWNER TO postgres;

--
-- TOC entry 380 (class 1259 OID 124218)
-- Name: pack_21122025; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122025 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122025 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122025 OWNER TO postgres;

--
-- TOC entry 381 (class 1259 OID 124226)
-- Name: pack_21122026; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122026 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122026 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122026 OWNER TO postgres;

--
-- TOC entry 382 (class 1259 OID 124234)
-- Name: pack_21122027; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122027 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122027 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122027 OWNER TO postgres;

--
-- TOC entry 383 (class 1259 OID 124242)
-- Name: pack_21122028; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122028 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122028 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122028 OWNER TO postgres;

--
-- TOC entry 384 (class 1259 OID 124250)
-- Name: pack_21122029; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122029 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122029 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122029 OWNER TO postgres;

--
-- TOC entry 385 (class 1259 OID 124258)
-- Name: pack_21122030; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122030 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122030 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122030 OWNER TO postgres;

--
-- TOC entry 386 (class 1259 OID 124266)
-- Name: pack_21122031; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_21122031 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_21122031 REPLICA IDENTITY FULL;


ALTER TABLE public.pack_21122031 OWNER TO postgres;

--
-- TOC entry 387 (class 1259 OID 124274)
-- Name: pack_others; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_others (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_package_return character varying(500),
    pickup_date timestamp without time zone NOT NULL,
    package_returned integer NOT NULL,
    modified boolean NOT NULL,
    date_received timestamp without time zone,
    provider_uuid character varying(255),
    stock_returned integer NOT NULL,
    next_pick_up_date timestamp without time zone NOT NULL,
    group_pack_id character varying(255),
    sync_status character(1),
    date_returned timestamp without time zone,
    dispense_mode_id character varying(255) NOT NULL,
    date_left timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_date timestamp without time zone,
    weeks_supply integer NOT NULL,
    creation_date timestamp without time zone,
    isreferral boolean DEFAULT false,
    isreferalsynced boolean DEFAULT false,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pack_others REPLICA IDENTITY FULL;


ALTER TABLE public.pack_others OWNER TO postgres;

--
-- TOC entry 388 (class 1259 OID 124282)
-- Name: patient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
)
PARTITION BY RANGE (match_id);

ALTER TABLE ONLY public.patient REPLICA IDENTITY FULL;


ALTER TABLE public.patient OWNER TO postgres;

--
-- TOC entry 389 (class 1259 OID 124287)
-- Name: patient_1000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_1000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_1000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_1000 OWNER TO postgres;

--
-- TOC entry 390 (class 1259 OID 124294)
-- Name: patient_10000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_10000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_10000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_10000 OWNER TO postgres;

--
-- TOC entry 391 (class 1259 OID 124301)
-- Name: patient_11000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_11000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_11000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_11000 OWNER TO postgres;

--
-- TOC entry 392 (class 1259 OID 124308)
-- Name: patient_12000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_12000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_12000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_12000 OWNER TO postgres;

--
-- TOC entry 393 (class 1259 OID 124315)
-- Name: patient_13000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_13000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_13000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_13000 OWNER TO postgres;

--
-- TOC entry 394 (class 1259 OID 124322)
-- Name: patient_14000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_14000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_14000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_14000 OWNER TO postgres;

--
-- TOC entry 395 (class 1259 OID 124329)
-- Name: patient_15000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_15000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_15000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_15000 OWNER TO postgres;

--
-- TOC entry 396 (class 1259 OID 124336)
-- Name: patient_16000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_16000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_16000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_16000 OWNER TO postgres;

--
-- TOC entry 397 (class 1259 OID 124343)
-- Name: patient_17000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_17000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_17000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_17000 OWNER TO postgres;

--
-- TOC entry 398 (class 1259 OID 124350)
-- Name: patient_18000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_18000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_18000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_18000 OWNER TO postgres;

--
-- TOC entry 399 (class 1259 OID 124357)
-- Name: patient_19000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_19000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_19000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_19000 OWNER TO postgres;

--
-- TOC entry 400 (class 1259 OID 124364)
-- Name: patient_2000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_2000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_2000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_2000 OWNER TO postgres;

--
-- TOC entry 401 (class 1259 OID 124371)
-- Name: patient_20000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_20000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_20000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_20000 OWNER TO postgres;

--
-- TOC entry 402 (class 1259 OID 124378)
-- Name: patient_21000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_21000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_21000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_21000 OWNER TO postgres;

--
-- TOC entry 403 (class 1259 OID 124385)
-- Name: patient_22000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_22000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_22000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_22000 OWNER TO postgres;

--
-- TOC entry 404 (class 1259 OID 124392)
-- Name: patient_23000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_23000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_23000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_23000 OWNER TO postgres;

--
-- TOC entry 405 (class 1259 OID 124399)
-- Name: patient_24000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_24000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_24000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_24000 OWNER TO postgres;

--
-- TOC entry 406 (class 1259 OID 124406)
-- Name: patient_25000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_25000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_25000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_25000 OWNER TO postgres;

--
-- TOC entry 407 (class 1259 OID 124413)
-- Name: patient_26000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_26000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_26000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_26000 OWNER TO postgres;

--
-- TOC entry 408 (class 1259 OID 124420)
-- Name: patient_27000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_27000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_27000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_27000 OWNER TO postgres;

--
-- TOC entry 409 (class 1259 OID 124427)
-- Name: patient_28000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_28000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_28000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_28000 OWNER TO postgres;

--
-- TOC entry 410 (class 1259 OID 124434)
-- Name: patient_29000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_29000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_29000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_29000 OWNER TO postgres;

--
-- TOC entry 411 (class 1259 OID 124441)
-- Name: patient_3000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_3000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_3000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_3000 OWNER TO postgres;

--
-- TOC entry 412 (class 1259 OID 124448)
-- Name: patient_30000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_30000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_30000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_30000 OWNER TO postgres;

--
-- TOC entry 413 (class 1259 OID 124455)
-- Name: patient_31000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_31000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_31000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_31000 OWNER TO postgres;

--
-- TOC entry 414 (class 1259 OID 124462)
-- Name: patient_32000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_32000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_32000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_32000 OWNER TO postgres;

--
-- TOC entry 415 (class 1259 OID 124469)
-- Name: patient_33000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_33000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_33000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_33000 OWNER TO postgres;

--
-- TOC entry 416 (class 1259 OID 124476)
-- Name: patient_34000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_34000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_34000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_34000 OWNER TO postgres;

--
-- TOC entry 417 (class 1259 OID 124483)
-- Name: patient_35000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_35000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_35000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_35000 OWNER TO postgres;

--
-- TOC entry 418 (class 1259 OID 124490)
-- Name: patient_36000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_36000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_36000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_36000 OWNER TO postgres;

--
-- TOC entry 419 (class 1259 OID 124497)
-- Name: patient_37000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_37000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_37000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_37000 OWNER TO postgres;

--
-- TOC entry 420 (class 1259 OID 124504)
-- Name: patient_38000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_38000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_38000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_38000 OWNER TO postgres;

--
-- TOC entry 421 (class 1259 OID 124511)
-- Name: patient_39000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_39000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_39000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_39000 OWNER TO postgres;

--
-- TOC entry 422 (class 1259 OID 124518)
-- Name: patient_4000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_4000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_4000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_4000 OWNER TO postgres;

--
-- TOC entry 423 (class 1259 OID 124525)
-- Name: patient_40000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_40000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_40000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_40000 OWNER TO postgres;

--
-- TOC entry 424 (class 1259 OID 124532)
-- Name: patient_41000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_41000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_41000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_41000 OWNER TO postgres;

--
-- TOC entry 425 (class 1259 OID 124539)
-- Name: patient_42000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_42000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_42000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_42000 OWNER TO postgres;

--
-- TOC entry 426 (class 1259 OID 124546)
-- Name: patient_43000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_43000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_43000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_43000 OWNER TO postgres;

--
-- TOC entry 427 (class 1259 OID 124553)
-- Name: patient_44000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_44000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_44000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_44000 OWNER TO postgres;

--
-- TOC entry 428 (class 1259 OID 124560)
-- Name: patient_45000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_45000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_45000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_45000 OWNER TO postgres;

--
-- TOC entry 429 (class 1259 OID 124567)
-- Name: patient_46000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_46000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_46000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_46000 OWNER TO postgres;

--
-- TOC entry 430 (class 1259 OID 124574)
-- Name: patient_47000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_47000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_47000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_47000 OWNER TO postgres;

--
-- TOC entry 431 (class 1259 OID 124581)
-- Name: patient_48000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_48000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_48000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_48000 OWNER TO postgres;

--
-- TOC entry 432 (class 1259 OID 124588)
-- Name: patient_49000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_49000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_49000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_49000 OWNER TO postgres;

--
-- TOC entry 433 (class 1259 OID 124595)
-- Name: patient_5000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_5000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_5000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_5000 OWNER TO postgres;

--
-- TOC entry 434 (class 1259 OID 124602)
-- Name: patient_50000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_50000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_50000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_50000 OWNER TO postgres;

--
-- TOC entry 435 (class 1259 OID 124609)
-- Name: patient_6000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_6000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_6000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_6000 OWNER TO postgres;

--
-- TOC entry 436 (class 1259 OID 124616)
-- Name: patient_7000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_7000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_7000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_7000 OWNER TO postgres;

--
-- TOC entry 437 (class 1259 OID 124623)
-- Name: patient_8000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_8000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_8000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_8000 OWNER TO postgres;

--
-- TOC entry 438 (class 1259 OID 124630)
-- Name: patient_9000; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_9000 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_9000 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_9000 OWNER TO postgres;

--
-- TOC entry 439 (class 1259 OID 124637)
-- Name: patient_attribute; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_attribute (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    attribute_type_id character varying(255) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.patient_attribute OWNER TO postgres;

--
-- TOC entry 440 (class 1259 OID 124642)
-- Name: patient_attribute_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_attribute_type (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    datatype character varying(255),
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.patient_attribute_type OWNER TO postgres;

--
-- TOC entry 441 (class 1259 OID 124647)
-- Name: patient_info_group_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.patient_info_group_view AS
SELECT
    NULL::text AS full_name,
    NULL::character varying(255) AS nid,
    NULL::timestamp without time zone AS last_prescription_date,
    NULL::timestamp without time zone AS last_pickup_date,
    NULL::timestamp without time zone AS next_pickup_date,
    NULL::integer AS validade,
    NULL::timestamp without time zone AS last_prescription_date_member,
    NULL::integer AS validade_nova,
    NULL::character varying(255) AS patientid,
    NULL::character varying(255) AS groupmemberid,
    NULL::character varying(255) AS patientserviceid,
    NULL::character varying(255) AS episodeid,
    NULL::timestamp without time zone AS membership_enddate,
    NULL::character varying(255) AS group_id;


ALTER VIEW public.patient_info_group_view OWNER TO postgres;

--
-- TOC entry 442 (class 1259 OID 124651)
-- Name: patient_visit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
)
PARTITION BY RANGE (visit_date);

ALTER TABLE ONLY public.patient_visit REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit OWNER TO postgres;

--
-- TOC entry 443 (class 1259 OID 124655)
-- Name: vital_signs_screening; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vital_signs_screening (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    imc character varying(255) NOT NULL,
    distort integer NOT NULL,
    visit_id character varying(255) NOT NULL,
    weight double precision NOT NULL,
    height double precision NOT NULL,
    systole integer NOT NULL,
    clinic_id character varying(255) DEFAULT ''::character varying NOT NULL,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.vital_signs_screening REPLICA IDENTITY FULL;


ALTER TABLE public.vital_signs_screening OWNER TO postgres;

--
-- TOC entry 444 (class 1259 OID 124662)
-- Name: patient_last_3_visits_screening_vw; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.patient_last_3_visits_screening_vw AS
 WITH ranked_visits AS (
         SELECT pv.id,
            pv.version,
            pv.patient_id,
            pv.visit_date,
            pv.clinic_id,
            pv.creation_date,
            pv.origin,
            row_number() OVER (PARTITION BY p.id ORDER BY pv.visit_date DESC) AS visit_rank
           FROM ((public.patient_visit pv
             JOIN public.patient p ON (((p.id)::text = (pv.patient_id)::text)))
             JOIN public.vital_signs_screening vss ON (((vss.visit_id)::text = (pv.id)::text)))
        )
 SELECT ranked_visits.id,
    ranked_visits.version,
    ranked_visits.patient_id,
    ranked_visits.visit_date,
    ranked_visits.clinic_id,
    ranked_visits.creation_date,
    ranked_visits.origin
   FROM ranked_visits
  WHERE (ranked_visits.visit_rank <= 3);


ALTER VIEW public.patient_last_3_visits_screening_vw OWNER TO postgres;

--
-- TOC entry 445 (class 1259 OID 124667)
-- Name: patient_visit_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_details (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    episode_id character varying(255) NOT NULL,
    patient_visit_id character varying(255) NOT NULL,
    prescription_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    clinic_id character varying(255) NOT NULL,
    pack_id character varying(255) NOT NULL,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_details REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_details OWNER TO postgres;

--
-- TOC entry 446 (class 1259 OID 124673)
-- Name: patient_last_pack_vw; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.patient_last_pack_vw AS
 SELECT DISTINCT ON (p.id) p2.id,
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
   FROM (((public.patient_visit_details pvd
     JOIN public.patient_visit pv ON (((pvd.patient_visit_id)::text = (pv.id)::text)))
     JOIN public.patient p ON (((p.id)::text = (pv.patient_id)::text)))
     JOIN public.pack p2 ON (((pvd.pack_id)::text = (p2.id)::text)))
  ORDER BY p.id, pv.visit_date DESC;


ALTER VIEW public.patient_last_pack_vw OWNER TO postgres;

--
-- TOC entry 447 (class 1259 OID 124678)
-- Name: prescription; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
)
PARTITION BY RANGE (prescription_date);

ALTER TABLE ONLY public.prescription REPLICA IDENTITY FULL;


ALTER TABLE public.prescription OWNER TO postgres;

--
-- TOC entry 448 (class 1259 OID 124682)
-- Name: patient_last_prescription_vw; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.patient_last_prescription_vw AS
 SELECT DISTINCT ON (p.id) p2.id,
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
   FROM (((public.patient_visit_details pvd
     JOIN public.patient_visit pv ON (((pvd.patient_visit_id)::text = (pv.id)::text)))
     JOIN public.patient p ON (((p.id)::text = (pv.patient_id)::text)))
     JOIN public.prescription p2 ON (((pvd.prescription_id)::text = (p2.id)::text)))
  ORDER BY p.id, pv.visit_date DESC;


ALTER VIEW public.patient_last_prescription_vw OWNER TO postgres;

--
-- TOC entry 449 (class 1259 OID 124687)
-- Name: patient_last_visit_details_vw; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.patient_last_visit_details_vw AS
 SELECT DISTINCT ON (p.id) pvd.id,
    pvd.version,
    pvd.episode_id,
    pvd.patient_visit_id,
    pvd.prescription_id,
    pvd.clinic_id,
    pvd.pack_id
   FROM ((public.patient_visit_details pvd
     JOIN public.patient_visit pv ON (((pvd.patient_visit_id)::text = (pv.id)::text)))
     JOIN public.patient p ON (((p.id)::text = (pv.patient_id)::text)))
  ORDER BY p.id, pv.visit_date DESC;


ALTER VIEW public.patient_last_visit_details_vw OWNER TO postgres;

--
-- TOC entry 450 (class 1259 OID 124692)
-- Name: patient_last_visit_screening_vw; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.patient_last_visit_screening_vw AS
 SELECT DISTINCT ON (p.id) pv.id,
    pv.version,
    pv.patient_id,
    pv.visit_date,
    pv.clinic_id,
    pv.creation_date,
    pv.origin
   FROM ((public.patient_visit pv
     JOIN public.patient p ON (((p.id)::text = (pv.patient_id)::text)))
     JOIN public.vital_signs_screening vss ON (((vss.visit_id)::text = (pv.id)::text)))
  ORDER BY p.id, pv.visit_date DESC;


ALTER VIEW public.patient_last_visit_screening_vw OWNER TO postgres;

--
-- TOC entry 451 (class 1259 OID 124697)
-- Name: patient_others; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_others (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    bairro_id character varying(255),
    province_id character varying(255) NOT NULL,
    his_uuid character varying(255),
    first_names character varying(255) NOT NULL,
    cellphone character varying(255),
    gender character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    his_location character varying(255),
    accountstatus boolean NOT NULL,
    date_of_birth timestamp without time zone,
    posto_administrativo_id character varying(255),
    middle_names character varying(255),
    address character varying(750),
    his_location_name character varying(255),
    alternative_cellphone character varying(12),
    his_id character varying(255),
    address_reference character varying(750),
    last_names character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    his_provider character varying(255),
    match_id numeric NOT NULL,
    his_sync_status character varying(1) DEFAULT 'N'::character varying,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_others REPLICA IDENTITY FULL;


ALTER TABLE public.patient_others OWNER TO postgres;

--
-- TOC entry 452 (class 1259 OID 124704)
-- Name: patient_service_identifier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
)
PARTITION BY RANGE (start_date);

ALTER TABLE ONLY public.patient_service_identifier REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier OWNER TO postgres;

--
-- TOC entry 453 (class 1259 OID 124708)
-- Name: patient_service_identifier_21122008; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122008 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122008 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122008 OWNER TO postgres;

--
-- TOC entry 454 (class 1259 OID 124714)
-- Name: patient_service_identifier_21122009; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122009 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122009 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122009 OWNER TO postgres;

--
-- TOC entry 455 (class 1259 OID 124720)
-- Name: patient_service_identifier_21122010; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122010 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122010 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122010 OWNER TO postgres;

--
-- TOC entry 456 (class 1259 OID 124726)
-- Name: patient_service_identifier_21122011; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122011 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122011 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122011 OWNER TO postgres;

--
-- TOC entry 457 (class 1259 OID 124732)
-- Name: patient_service_identifier_21122012; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122012 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122012 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122012 OWNER TO postgres;

--
-- TOC entry 458 (class 1259 OID 124738)
-- Name: patient_service_identifier_21122013; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122013 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122013 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122013 OWNER TO postgres;

--
-- TOC entry 459 (class 1259 OID 124744)
-- Name: patient_service_identifier_21122014; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122014 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122014 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122014 OWNER TO postgres;

--
-- TOC entry 460 (class 1259 OID 124750)
-- Name: patient_service_identifier_21122015; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122015 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122015 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122015 OWNER TO postgres;

--
-- TOC entry 461 (class 1259 OID 124756)
-- Name: patient_service_identifier_21122016; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122016 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122016 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122016 OWNER TO postgres;

--
-- TOC entry 462 (class 1259 OID 124762)
-- Name: patient_service_identifier_21122017; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122017 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122017 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122017 OWNER TO postgres;

--
-- TOC entry 463 (class 1259 OID 124768)
-- Name: patient_service_identifier_21122018; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122018 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122018 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122018 OWNER TO postgres;

--
-- TOC entry 464 (class 1259 OID 124774)
-- Name: patient_service_identifier_21122019; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122019 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122019 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122019 OWNER TO postgres;

--
-- TOC entry 465 (class 1259 OID 124780)
-- Name: patient_service_identifier_21122020; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122020 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122020 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122020 OWNER TO postgres;

--
-- TOC entry 466 (class 1259 OID 124786)
-- Name: patient_service_identifier_21122021; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122021 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122021 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122021 OWNER TO postgres;

--
-- TOC entry 467 (class 1259 OID 124792)
-- Name: patient_service_identifier_21122022; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122022 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122022 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122022 OWNER TO postgres;

--
-- TOC entry 468 (class 1259 OID 124798)
-- Name: patient_service_identifier_21122023; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122023 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122023 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122023 OWNER TO postgres;

--
-- TOC entry 469 (class 1259 OID 124804)
-- Name: patient_service_identifier_21122024; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122024 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122024 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122024 OWNER TO postgres;

--
-- TOC entry 470 (class 1259 OID 124810)
-- Name: patient_service_identifier_21122025; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122025 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122025 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122025 OWNER TO postgres;

--
-- TOC entry 471 (class 1259 OID 124816)
-- Name: patient_service_identifier_21122027; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122027 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122027 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122027 OWNER TO postgres;

--
-- TOC entry 472 (class 1259 OID 124822)
-- Name: patient_service_identifier_21122028; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122028 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122028 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122028 OWNER TO postgres;

--
-- TOC entry 473 (class 1259 OID 124828)
-- Name: patient_service_identifier_21122029; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122029 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122029 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122029 OWNER TO postgres;

--
-- TOC entry 474 (class 1259 OID 124834)
-- Name: patient_service_identifier_21122030; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122030 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122030 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122030 OWNER TO postgres;

--
-- TOC entry 475 (class 1259 OID 124840)
-- Name: patient_service_identifier_21122031; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21122031 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21122031 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21122031 OWNER TO postgres;

--
-- TOC entry 476 (class 1259 OID 124846)
-- Name: patient_service_identifier_21212026; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_21212026 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_21212026 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_21212026 OWNER TO postgres;

--
-- TOC entry 477 (class 1259 OID 124852)
-- Name: patient_service_identifier_others; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_service_identifier_others (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    identifier_type_id character varying(255) NOT NULL,
    reopen_date timestamp without time zone,
    state character varying(255) NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone NOT NULL,
    service_id character varying(255) NOT NULL,
    value character varying(255),
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_service_identifier_others REPLICA IDENTITY FULL;


ALTER TABLE public.patient_service_identifier_others OWNER TO postgres;

--
-- TOC entry 478 (class 1259 OID 124858)
-- Name: patient_trans_reference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_trans_reference (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    origin_id character varying(255) NOT NULL,
    match_id bigint,
    operation_date timestamp without time zone NOT NULL,
    operation_type_id character varying(255) NOT NULL,
    patient_status character varying(255),
    sync_status character varying(255) NOT NULL,
    destination character varying(255) NOT NULL,
    creation_date timestamp without time zone NOT NULL,
    identifier_id character varying(255) NOT NULL
);


ALTER TABLE public.patient_trans_reference OWNER TO postgres;

--
-- TOC entry 479 (class 1259 OID 124863)
-- Name: patient_trans_reference_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_trans_reference_type (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(50) NOT NULL,
    description character varying(50) NOT NULL
);


ALTER TABLE public.patient_trans_reference_type OWNER TO postgres;

--
-- TOC entry 480 (class 1259 OID 124866)
-- Name: patient_visit_21122008; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122008 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122008 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122008 OWNER TO postgres;

--
-- TOC entry 481 (class 1259 OID 124872)
-- Name: patient_visit_21122009; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122009 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122009 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122009 OWNER TO postgres;

--
-- TOC entry 482 (class 1259 OID 124878)
-- Name: patient_visit_21122010; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122010 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122010 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122010 OWNER TO postgres;

--
-- TOC entry 483 (class 1259 OID 124884)
-- Name: patient_visit_21122011; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122011 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122011 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122011 OWNER TO postgres;

--
-- TOC entry 484 (class 1259 OID 124890)
-- Name: patient_visit_21122012; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122012 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122012 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122012 OWNER TO postgres;

--
-- TOC entry 485 (class 1259 OID 124896)
-- Name: patient_visit_21122013; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122013 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122013 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122013 OWNER TO postgres;

--
-- TOC entry 486 (class 1259 OID 124902)
-- Name: patient_visit_21122014; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122014 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122014 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122014 OWNER TO postgres;

--
-- TOC entry 487 (class 1259 OID 124908)
-- Name: patient_visit_21122015; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122015 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122015 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122015 OWNER TO postgres;

--
-- TOC entry 488 (class 1259 OID 124914)
-- Name: patient_visit_21122016; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122016 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122016 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122016 OWNER TO postgres;

--
-- TOC entry 489 (class 1259 OID 124920)
-- Name: patient_visit_21122017; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122017 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122017 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122017 OWNER TO postgres;

--
-- TOC entry 490 (class 1259 OID 124926)
-- Name: patient_visit_21122018; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122018 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122018 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122018 OWNER TO postgres;

--
-- TOC entry 491 (class 1259 OID 124932)
-- Name: patient_visit_21122019; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122019 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122019 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122019 OWNER TO postgres;

--
-- TOC entry 492 (class 1259 OID 124938)
-- Name: patient_visit_21122020; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122020 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122020 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122020 OWNER TO postgres;

--
-- TOC entry 493 (class 1259 OID 124944)
-- Name: patient_visit_21122021; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122021 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122021 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122021 OWNER TO postgres;

--
-- TOC entry 494 (class 1259 OID 124950)
-- Name: patient_visit_21122022; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122022 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122022 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122022 OWNER TO postgres;

--
-- TOC entry 495 (class 1259 OID 124956)
-- Name: patient_visit_21122023; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122023 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122023 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122023 OWNER TO postgres;

--
-- TOC entry 496 (class 1259 OID 124962)
-- Name: patient_visit_21122024; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122024 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122024 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122024 OWNER TO postgres;

--
-- TOC entry 497 (class 1259 OID 124968)
-- Name: patient_visit_21122025; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122025 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122025 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122025 OWNER TO postgres;

--
-- TOC entry 498 (class 1259 OID 124974)
-- Name: patient_visit_21122026; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122026 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122026 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122026 OWNER TO postgres;

--
-- TOC entry 499 (class 1259 OID 124980)
-- Name: patient_visit_21122027; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122027 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122027 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122027 OWNER TO postgres;

--
-- TOC entry 500 (class 1259 OID 124986)
-- Name: patient_visit_21122028; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122028 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122028 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122028 OWNER TO postgres;

--
-- TOC entry 501 (class 1259 OID 124992)
-- Name: patient_visit_21122029; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122029 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122029 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122029 OWNER TO postgres;

--
-- TOC entry 502 (class 1259 OID 124998)
-- Name: patient_visit_21122030; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122030 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122030 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122030 OWNER TO postgres;

--
-- TOC entry 503 (class 1259 OID 125004)
-- Name: patient_visit_21122031; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_21122031 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_21122031 REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_21122031 OWNER TO postgres;

--
-- TOC entry 504 (class 1259 OID 125010)
-- Name: patient_visit_others; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_visit_others (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    visit_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.patient_visit_others REPLICA IDENTITY FULL;


ALTER TABLE public.patient_visit_others OWNER TO postgres;

--
-- TOC entry 505 (class 1259 OID 125016)
-- Name: patient_without_dispense_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_without_dispense_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    province character varying(255),
    first_names character varying(255) NOT NULL,
    district character varying(255),
    nid character varying(255) NOT NULL,
    end_date timestamp without time zone,
    create_date timestamp without time zone NOT NULL,
    start_date timestamp without time zone,
    period_type character varying(8) NOT NULL,
    middle_names character varying(255),
    uuid_open_mrs character varying(255),
    last_names character varying(255),
    clinic character varying(255) NOT NULL,
    year integer,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.patient_without_dispense_report OWNER TO postgres;

--
-- TOC entry 506 (class 1259 OID 125021)
-- Name: patients_abandonment_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patients_abandonment_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    served_service character varying(255),
    date_missed_pick_up timestamp without time zone,
    returned_pick_up timestamp without time zone,
    nid character varying(255) NOT NULL,
    date_identified_abandonment timestamp without time zone,
    idade integer,
    contact character varying(255),
    end_date timestamp without time zone,
    start_date timestamp without time zone,
    period_type character varying(8) NOT NULL,
    address text,
    district_id character varying(255),
    name character varying(255) NOT NULL,
    period character varying(255),
    clinic character varying(255),
    province_id character varying(255),
    clinical_service_id character varying(255) NOT NULL,
    date_back_us timestamp without time zone,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.patients_abandonment_report OWNER TO postgres;

--
-- TOC entry 507 (class 1259 OID 125026)
-- Name: patients_in_semestral_dispense; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patients_in_semestral_dispense (
    id bigint NOT NULL,
    version bigint NOT NULL
);


ALTER TABLE public.patients_in_semestral_dispense OWNER TO postgres;

--
-- TOC entry 508 (class 1259 OID 125029)
-- Name: patientserviceview; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.patientserviceview AS
 SELECT p.id,
    p.first_names,
    p.last_names,
    p.gender,
    psi.value,
    p.date_of_birth
   FROM (public.patient p
     JOIN public.patient_service_identifier psi ON (((p.id)::text = (psi.patient_id)::text)))
  GROUP BY p.id, p.first_names, p.last_names, p.gender, psi.value, p.date_of_birth
  ORDER BY p.last_names, p.first_names;


ALTER VIEW public.patientserviceview OWNER TO postgres;

--
-- TOC entry 509 (class 1259 OID 125034)
-- Name: possible_patient_duplicates_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.possible_patient_duplicates_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    month character varying(255),
    gender character varying(255),
    pharmacy_id character varying(255),
    nid character varying(255) NOT NULL,
    number_of_times character varying(255),
    date_of_birth timestamp without time zone,
    period_type character varying(255),
    patient_name character varying(255) NOT NULL,
    district_id character varying(255),
    semester character varying(255),
    period character varying(255),
    quarter character varying(255),
    province_id character varying(255),
    year integer,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.possible_patient_duplicates_report OWNER TO postgres;

--
-- TOC entry 510 (class 1259 OID 125039)
-- Name: posto_administrativo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.posto_administrativo (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    district_id character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.posto_administrativo OWNER TO postgres;

--
-- TOC entry 511 (class 1259 OID 125044)
-- Name: pregnancy_screening; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pregnancy_screening (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    pregnant boolean NOT NULL,
    visit_id character varying(255) NOT NULL,
    menstruation_last_two_months boolean NOT NULL,
    last_menstruation timestamp without time zone,
    clinic_id character varying(255) DEFAULT ''::character varying NOT NULL,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.pregnancy_screening REPLICA IDENTITY FULL;


ALTER TABLE public.pregnancy_screening OWNER TO postgres;

--
-- TOC entry 512 (class 1259 OID 125051)
-- Name: prescribed_drug; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescribed_drug (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    prescribed_qty integer NOT NULL,
    amt_per_time double precision NOT NULL,
    modified boolean NOT NULL,
    drug_id character varying(255) NOT NULL,
    form character varying(255) NOT NULL,
    times_per_day integer NOT NULL,
    prescription_id character varying(255) NOT NULL,
    clinic_id character varying(255) DEFAULT ''::character varying NOT NULL,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescribed_drug REPLICA IDENTITY FULL;


ALTER TABLE public.prescribed_drug OWNER TO postgres;

--
-- TOC entry 513 (class 1259 OID 125058)
-- Name: prescription_21122008; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122008 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122008 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122008 OWNER TO postgres;

--
-- TOC entry 514 (class 1259 OID 125064)
-- Name: prescription_21122009; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122009 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122009 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122009 OWNER TO postgres;

--
-- TOC entry 515 (class 1259 OID 125070)
-- Name: prescription_21122010; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122010 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122010 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122010 OWNER TO postgres;

--
-- TOC entry 516 (class 1259 OID 125076)
-- Name: prescription_21122011; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122011 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122011 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122011 OWNER TO postgres;

--
-- TOC entry 517 (class 1259 OID 125082)
-- Name: prescription_21122012; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122012 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122012 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122012 OWNER TO postgres;

--
-- TOC entry 518 (class 1259 OID 125088)
-- Name: prescription_21122013; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122013 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122013 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122013 OWNER TO postgres;

--
-- TOC entry 519 (class 1259 OID 125094)
-- Name: prescription_21122014; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122014 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122014 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122014 OWNER TO postgres;

--
-- TOC entry 520 (class 1259 OID 125100)
-- Name: prescription_21122015; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122015 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122015 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122015 OWNER TO postgres;

--
-- TOC entry 521 (class 1259 OID 125106)
-- Name: prescription_21122016; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122016 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122016 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122016 OWNER TO postgres;

--
-- TOC entry 522 (class 1259 OID 125112)
-- Name: prescription_21122017; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122017 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122017 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122017 OWNER TO postgres;

--
-- TOC entry 523 (class 1259 OID 125118)
-- Name: prescription_21122018; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122018 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122018 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122018 OWNER TO postgres;

--
-- TOC entry 524 (class 1259 OID 125124)
-- Name: prescription_21122019; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122019 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122019 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122019 OWNER TO postgres;

--
-- TOC entry 525 (class 1259 OID 125130)
-- Name: prescription_21122020; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122020 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122020 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122020 OWNER TO postgres;

--
-- TOC entry 526 (class 1259 OID 125136)
-- Name: prescription_21122021; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122021 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122021 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122021 OWNER TO postgres;

--
-- TOC entry 527 (class 1259 OID 125142)
-- Name: prescription_21122022; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122022 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122022 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122022 OWNER TO postgres;

--
-- TOC entry 528 (class 1259 OID 125148)
-- Name: prescription_21122023; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122023 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122023 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122023 OWNER TO postgres;

--
-- TOC entry 529 (class 1259 OID 125154)
-- Name: prescription_21122024; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122024 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122024 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122024 OWNER TO postgres;

--
-- TOC entry 530 (class 1259 OID 125160)
-- Name: prescription_21122025; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122025 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122025 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122025 OWNER TO postgres;

--
-- TOC entry 531 (class 1259 OID 125166)
-- Name: prescription_21122026; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122026 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122026 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122026 OWNER TO postgres;

--
-- TOC entry 532 (class 1259 OID 125172)
-- Name: prescription_21122027; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122027 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122027 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122027 OWNER TO postgres;

--
-- TOC entry 533 (class 1259 OID 125178)
-- Name: prescription_21122028; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122028 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122028 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122028 OWNER TO postgres;

--
-- TOC entry 534 (class 1259 OID 125184)
-- Name: prescription_21122029; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122029 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122029 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122029 OWNER TO postgres;

--
-- TOC entry 535 (class 1259 OID 125190)
-- Name: prescription_21122030; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122030 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122030 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122030 OWNER TO postgres;

--
-- TOC entry 536 (class 1259 OID 125196)
-- Name: prescription_21122031; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_21122031 (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_21122031 REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_21122031 OWNER TO postgres;

--
-- TOC entry 537 (class 1259 OID 125202)
-- Name: prescription_detail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_detail (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    reason_for_update_desc character varying(255),
    spetial_prescription_motive_id character varying(255),
    therapeutic_regimen_id character varying(255),
    prescription_id character varying(255) NOT NULL,
    dispense_type_id character varying(255) NOT NULL,
    creation_date timestamp without time zone,
    reason_for_update character varying(255),
    therapeutic_line_id character varying(255),
    clinic_id character varying(255) DEFAULT ''::character varying NOT NULL,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_detail REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_detail OWNER TO postgres;

--
-- TOC entry 538 (class 1259 OID 125209)
-- Name: prescription_others; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_others (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    modified boolean NOT NULL,
    expiry_date timestamp without time zone,
    photo bytea,
    prescription_date timestamp without time zone NOT NULL,
    notes character varying(1500),
    duration_id character varying(255) NOT NULL,
    patient_status character varying(255),
    photo_content_type character varying(255),
    prescription_seq character varying(255),
    current boolean NOT NULL,
    clinic_id character varying(255) NOT NULL,
    photo_name character varying(255),
    doctor_id character varying(255) NOT NULL,
    patient_type character varying(255),
    creation_date timestamp without time zone,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.prescription_others REPLICA IDENTITY FULL;


ALTER TABLE public.prescription_others OWNER TO postgres;

--
-- TOC entry 539 (class 1259 OID 125215)
-- Name: province; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.province (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.province OWNER TO postgres;

--
-- TOC entry 540 (class 1259 OID 125220)
-- Name: provincial_server; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provincial_server (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    port character varying(255) NOT NULL,
    code character varying(50) NOT NULL,
    url_path character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    destination character varying(255) NOT NULL
);


ALTER TABLE public.provincial_server OWNER TO postgres;

--
-- TOC entry 541 (class 1259 OID 125225)
-- Name: ramscreening; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ramscreening (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    adverse_reaction character varying(255),
    visit_id character varying(255) NOT NULL,
    adverse_reaction_medicine boolean NOT NULL,
    clinic_id character varying(255) DEFAULT ''::character varying NOT NULL,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.ramscreening REPLICA IDENTITY FULL;


ALTER TABLE public.ramscreening OWNER TO postgres;

--
-- TOC entry 542 (class 1259 OID 125232)
-- Name: referred_patients_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.referred_patients_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    date_missed_pick_up timestamp without time zone,
    returned_pick_up timestamp without time zone,
    pharmacy_id character varying(255),
    nid character varying(255) NOT NULL,
    therapeutical_regimen character varying(255),
    notes character varying(255),
    date_identified_abandonment timestamp without time zone,
    contact character varying(255),
    end_date timestamp without time zone,
    start_date timestamp without time zone,
    period_type character varying(8) NOT NULL,
    last_pick_up_date timestamp without time zone,
    next_pick_up_date timestamp without time zone,
    age integer NOT NULL,
    referrence_date timestamp without time zone,
    district_id character varying(255),
    name character varying(255) NOT NULL,
    period character varying(255),
    pick_up_date timestamp without time zone,
    dispense_type character varying(255),
    last_prescription_date timestamp without time zone,
    tarv_type character varying(255),
    province_id character varying(255),
    referral_pharmacy character varying(255),
    clinical_service_id character varying(255) NOT NULL,
    date_back_us timestamp without time zone,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.referred_patients_report OWNER TO postgres;

--
-- TOC entry 543 (class 1259 OID 125237)
-- Name: registered_in_idmed_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.registered_in_idmed_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    first_name character varying(255),
    month character varying(255),
    gender character varying(255),
    pharmacy_id character varying(255),
    nid character varying(255) NOT NULL,
    date_of_birth timestamp without time zone,
    end_date timestamp without time zone,
    start_date timestamp without time zone,
    period_type character varying(255),
    district_id character varying(255),
    semester character varying(255),
    period character varying(255),
    creation_date timestamp without time zone,
    last_name character varying(255),
    quarter character varying(255),
    province_id character varying(255),
    year integer,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.registered_in_idmed_report OWNER TO postgres;

--
-- TOC entry 544 (class 1259 OID 125242)
-- Name: report_process_monitor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.report_process_monitor (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    progress double precision NOT NULL,
    msg character varying(255) NOT NULL,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.report_process_monitor OWNER TO postgres;

--
-- TOC entry 545 (class 1259 OID 125247)
-- Name: requestmap; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.requestmap (
    id bigint NOT NULL,
    version bigint NOT NULL,
    http_method character varying(255),
    config_attribute character varying(255) NOT NULL,
    url character varying(255) NOT NULL
);


ALTER TABLE public.requestmap OWNER TO postgres;

--
-- TOC entry 546 (class 1259 OID 125252)
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    id bigint NOT NULL,
    version bigint NOT NULL,
    name character varying(255) NOT NULL,
    authority character varying(255) NOT NULL,
    active boolean NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.role OWNER TO postgres;

--
-- TOC entry 547 (class 1259 OID 125257)
-- Name: role_menu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_menu (
    menus_id character varying(255) NOT NULL,
    roles_id bigint NOT NULL
);


ALTER TABLE public.role_menu OWNER TO postgres;

--
-- TOC entry 548 (class 1259 OID 125260)
-- Name: sec_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sec_user (
    id bigint NOT NULL,
    version bigint NOT NULL,
    password_expired boolean NOT NULL,
    account_expired boolean NOT NULL,
    login_retries integer NOT NULL,
    contact character varying(255),
    full_name character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    account_locked boolean NOT NULL,
    openmrs_password character varying(255),
    password character varying(255) NOT NULL,
    enabled boolean NOT NULL,
    email character varying(255),
    last_login timestamp without time zone NOT NULL
);


ALTER TABLE public.sec_user OWNER TO postgres;

--
-- TOC entry 549 (class 1259 OID 125265)
-- Name: sec_user_clinic_sectors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sec_user_clinic_sectors (
    sec_user_id bigint NOT NULL,
    clinic_id character varying(255)
);


ALTER TABLE public.sec_user_clinic_sectors OWNER TO postgres;

--
-- TOC entry 550 (class 1259 OID 125268)
-- Name: sec_user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sec_user_role (
    sec_user_id bigint NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE public.sec_user_role OWNER TO postgres;

--
-- TOC entry 551 (class 1259 OID 125271)
-- Name: segundas_linhas_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.segundas_linhas_report (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    linha_terapeutica character varying(255) NOT NULL,
    estado character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    total_prescricoes integer NOT NULL,
    codigo_regime character varying(255) NOT NULL,
    end_date timestamp without time zone NOT NULL,
    start_date timestamp without time zone NOT NULL,
    period_type character varying(255) NOT NULL,
    regime_terapeutico character varying(255) NOT NULL,
    period integer NOT NULL,
    year integer NOT NULL,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.segundas_linhas_report OWNER TO postgres;

--
-- TOC entry 552 (class 1259 OID 125276)
-- Name: service_patient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service_patient (
    id bigint NOT NULL,
    version bigint NOT NULL,
    patient_id character varying(255) NOT NULL,
    start_notes character varying(255) NOT NULL,
    stop_date timestamp without time zone,
    stop_notes character varying(255),
    stop_reason_id character varying(255),
    reopen_date timestamp without time zone NOT NULL,
    start_reason_id character varying(255) NOT NULL,
    start_date timestamp without time zone NOT NULL,
    clinical_service_id character varying(255) NOT NULL,
    prefered boolean NOT NULL
);


ALTER TABLE public.service_patient OWNER TO postgres;

--
-- TOC entry 553 (class 1259 OID 125281)
-- Name: spetial_prescription_motive; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spetial_prescription_motive (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.spetial_prescription_motive OWNER TO postgres;

--
-- TOC entry 554 (class 1259 OID 125286)
-- Name: start_stop_reason; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.start_stop_reason (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    reason character varying(255) NOT NULL,
    is_start_reason boolean NOT NULL
);


ALTER TABLE public.start_stop_reason OWNER TO postgres;

--
-- TOC entry 555 (class 1259 OID 125291)
-- Name: stock_center; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_center (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    clinic_id character varying(255) NOT NULL,
    prefered boolean NOT NULL
);


ALTER TABLE public.stock_center OWNER TO postgres;

--
-- TOC entry 556 (class 1259 OID 125296)
-- Name: stock_distributor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_distributor (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    notes character varying(255) NOT NULL,
    creation_date timestamp without time zone NOT NULL,
    clinic_id character varying(255) NOT NULL,
    order_number character varying(255) NOT NULL,
    status character varying(255)
);


ALTER TABLE public.stock_distributor OWNER TO postgres;

--
-- TOC entry 557 (class 1259 OID 125301)
-- Name: stock_distributor_batch; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_distributor_batch (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    stock_distributor_id character varying(255) NOT NULL,
    quantity integer NOT NULL,
    stock_id character varying(255) NOT NULL,
    drug_distributor_id character varying(255) NOT NULL
);


ALTER TABLE public.stock_distributor_batch OWNER TO postgres;

--
-- TOC entry 558 (class 1259 OID 125306)
-- Name: stock_level; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_level (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    clinic_id character varying(255) NOT NULL,
    drug_id character varying(255) NOT NULL,
    quantity integer NOT NULL
);


ALTER TABLE public.stock_level OWNER TO postgres;

--
-- TOC entry 559 (class 1259 OID 125311)
-- Name: stock_report_temp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_report_temp (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    units_received bigint NOT NULL,
    expiry_date timestamp without time zone NOT NULL,
    month character varying(255),
    pharmacy_id character varying(255),
    date_received timestamp without time zone NOT NULL,
    end_date timestamp without time zone,
    start_date timestamp without time zone,
    period_type character varying(255),
    manufacture character varying(255),
    batch_number character varying(255),
    district_id character varying(255),
    semester character varying(255),
    period character varying(255),
    quarter character varying(255),
    province_id character varying(255),
    year integer,
    drug_name character varying(255) NOT NULL,
    report_id character varying(255) NOT NULL,
    order_number character varying(255)
);


ALTER TABLE public.stock_report_temp OWNER TO postgres;

--
-- TOC entry 560 (class 1259 OID 125316)
-- Name: system_configs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_configs (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    value character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.system_configs OWNER TO postgres;

--
-- TOC entry 561 (class 1259 OID 125321)
-- Name: tbscreening; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbscreening (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    fatigue_or_tiredness_last_two_weeks boolean NOT NULL,
    fever boolean NOT NULL,
    sweating boolean NOT NULL,
    start_treatment_date timestamp without time zone,
    treatmenttb boolean NOT NULL,
    parenttbtreatment boolean NOT NULL,
    cough boolean NOT NULL,
    visit_id character varying(255),
    treatmenttpi boolean NOT NULL,
    losing_weight boolean NOT NULL,
    clinic_id character varying(255) DEFAULT ''::character varying NOT NULL,
    origin character varying(255) DEFAULT ''::character varying
);

ALTER TABLE ONLY public.tbscreening REPLICA IDENTITY FULL;


ALTER TABLE public.tbscreening OWNER TO postgres;

--
-- TOC entry 562 (class 1259 OID 125328)
-- Name: therapeutic_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.therapeutic_line (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    code character varying(255) NOT NULL,
    uuid character varying(255) NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.therapeutic_line OWNER TO postgres;

--
-- TOC entry 563 (class 1259 OID 125333)
-- Name: therapeutic_regimen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.therapeutic_regimen (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    regimen_scheme character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    active boolean NOT NULL,
    clinical_service_id character varying(255) NOT NULL,
    openmrs_uuid character varying(255),
    description character varying(255)
);


ALTER TABLE public.therapeutic_regimen OWNER TO postgres;

--
-- TOC entry 564 (class 1259 OID 125338)
-- Name: therapeutic_regimen_clinical_services; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.therapeutic_regimen_clinical_services (
    therapeutic_regimen_id character varying(255) NOT NULL,
    clinical_service_id character varying(255) NOT NULL
);


ALTER TABLE public.therapeutic_regimen_clinical_services OWNER TO postgres;

--
-- TOC entry 565 (class 1259 OID 125343)
-- Name: therapeutic_regimen_drugs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.therapeutic_regimen_drugs (
    drug_id character varying(255) NOT NULL,
    therapeutic_regimen_id character varying(255) NOT NULL
);


ALTER TABLE public.therapeutic_regimen_drugs OWNER TO postgres;

--
-- TOC entry 566 (class 1259 OID 125348)
-- Name: used_stock_report_temp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.used_stock_report_temp (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    received_stock bigint NOT NULL,
    balance bigint NOT NULL,
    drug_id character varying(255),
    pack_size character varying(255),
    fn_name character varying(255),
    month character varying(255),
    pharmacy_id character varying(255),
    notes character varying(255),
    end_date timestamp without time zone,
    start_date timestamp without time zone,
    period_type character varying(255),
    destroyed_stock bigint,
    district_id character varying(255),
    quantity_remain character varying(255),
    actual_stock bigint,
    semester character varying(255),
    period character varying(255),
    stock_issued bigint NOT NULL,
    quarter character varying(255),
    province_id character varying(255),
    year integer,
    drug_name character varying(255) NOT NULL,
    adjustment bigint,
    report_id character varying(255) NOT NULL
);


ALTER TABLE public.used_stock_report_temp OWNER TO postgres;

--
-- TOC entry 4588 (class 0 OID 0)
-- Name: episode_21122008; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122008 FOR VALUES FROM ('2008-12-21 00:00:00') TO ('2009-12-21 00:00:00');


--
-- TOC entry 4589 (class 0 OID 0)
-- Name: episode_21122009; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122009 FOR VALUES FROM ('2009-12-21 00:00:00') TO ('2010-12-21 00:00:00');


--
-- TOC entry 4590 (class 0 OID 0)
-- Name: episode_21122010; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122010 FOR VALUES FROM ('2010-12-21 00:00:00') TO ('2011-12-21 00:00:00');


--
-- TOC entry 4591 (class 0 OID 0)
-- Name: episode_21122011; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122011 FOR VALUES FROM ('2011-12-21 00:00:00') TO ('2012-12-21 00:00:00');


--
-- TOC entry 4592 (class 0 OID 0)
-- Name: episode_21122012; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122012 FOR VALUES FROM ('2012-12-21 00:00:00') TO ('2013-12-21 00:00:00');


--
-- TOC entry 4593 (class 0 OID 0)
-- Name: episode_21122013; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122013 FOR VALUES FROM ('2013-12-21 00:00:00') TO ('2014-12-21 00:00:00');


--
-- TOC entry 4594 (class 0 OID 0)
-- Name: episode_21122014; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122014 FOR VALUES FROM ('2014-12-21 00:00:00') TO ('2015-12-21 00:00:00');


--
-- TOC entry 4595 (class 0 OID 0)
-- Name: episode_21122015; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122015 FOR VALUES FROM ('2015-12-21 00:00:00') TO ('2016-12-21 00:00:00');


--
-- TOC entry 4596 (class 0 OID 0)
-- Name: episode_21122016; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122016 FOR VALUES FROM ('2016-12-21 00:00:00') TO ('2017-12-21 00:00:00');


--
-- TOC entry 4597 (class 0 OID 0)
-- Name: episode_21122017; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122017 FOR VALUES FROM ('2017-12-21 00:00:00') TO ('2018-12-21 00:00:00');


--
-- TOC entry 4598 (class 0 OID 0)
-- Name: episode_21122018; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122018 FOR VALUES FROM ('2018-12-21 00:00:00') TO ('2019-12-21 00:00:00');


--
-- TOC entry 4599 (class 0 OID 0)
-- Name: episode_21122019; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122019 FOR VALUES FROM ('2019-12-21 00:00:00') TO ('2020-12-21 00:00:00');


--
-- TOC entry 4600 (class 0 OID 0)
-- Name: episode_21122020; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122020 FOR VALUES FROM ('2020-12-21 00:00:00') TO ('2021-12-21 00:00:00');


--
-- TOC entry 4601 (class 0 OID 0)
-- Name: episode_21122021; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122021 FOR VALUES FROM ('2021-12-21 00:00:00') TO ('2022-12-21 00:00:00');


--
-- TOC entry 4602 (class 0 OID 0)
-- Name: episode_21122022; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122022 FOR VALUES FROM ('2022-12-21 00:00:00') TO ('2023-12-21 00:00:00');


--
-- TOC entry 4603 (class 0 OID 0)
-- Name: episode_21122023; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122023 FOR VALUES FROM ('2023-12-21 00:00:00') TO ('2024-12-21 00:00:00');


--
-- TOC entry 4604 (class 0 OID 0)
-- Name: episode_21122024; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122024 FOR VALUES FROM ('2024-12-21 00:00:00') TO ('2025-12-21 00:00:00');


--
-- TOC entry 4605 (class 0 OID 0)
-- Name: episode_21122025; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122025 FOR VALUES FROM ('2025-12-21 00:00:00') TO ('2026-12-21 00:00:00');


--
-- TOC entry 4606 (class 0 OID 0)
-- Name: episode_21122026; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122026 FOR VALUES FROM ('2026-12-21 00:00:00') TO ('2027-12-21 00:00:00');


--
-- TOC entry 4607 (class 0 OID 0)
-- Name: episode_21122027; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122027 FOR VALUES FROM ('2027-12-21 00:00:00') TO ('2028-12-21 00:00:00');


--
-- TOC entry 4608 (class 0 OID 0)
-- Name: episode_21122028; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122028 FOR VALUES FROM ('2028-12-21 00:00:00') TO ('2029-12-21 00:00:00');


--
-- TOC entry 4609 (class 0 OID 0)
-- Name: episode_21122029; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122029 FOR VALUES FROM ('2029-12-21 00:00:00') TO ('2030-12-21 00:00:00');


--
-- TOC entry 4610 (class 0 OID 0)
-- Name: episode_21122030; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122030 FOR VALUES FROM ('2030-12-21 00:00:00') TO ('2031-12-21 00:00:00');


--
-- TOC entry 4611 (class 0 OID 0)
-- Name: episode_21122031; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_21122031 FOR VALUES FROM ('2031-12-21 00:00:00') TO ('2032-12-21 00:00:00');


--
-- TOC entry 4612 (class 0 OID 0)
-- Name: episode_others; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode ATTACH PARTITION public.episode_others DEFAULT;


--
-- TOC entry 4613 (class 0 OID 0)
-- Name: migration_log_000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_000 FOR VALUES WITH (modulus 50, remainder 0);


--
-- TOC entry 4614 (class 0 OID 0)
-- Name: migration_log_001; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_001 FOR VALUES WITH (modulus 50, remainder 1);


--
-- TOC entry 4615 (class 0 OID 0)
-- Name: migration_log_002; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_002 FOR VALUES WITH (modulus 50, remainder 2);


--
-- TOC entry 4616 (class 0 OID 0)
-- Name: migration_log_003; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_003 FOR VALUES WITH (modulus 50, remainder 3);


--
-- TOC entry 4617 (class 0 OID 0)
-- Name: migration_log_004; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_004 FOR VALUES WITH (modulus 50, remainder 4);


--
-- TOC entry 4618 (class 0 OID 0)
-- Name: migration_log_005; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_005 FOR VALUES WITH (modulus 50, remainder 5);


--
-- TOC entry 4619 (class 0 OID 0)
-- Name: migration_log_006; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_006 FOR VALUES WITH (modulus 50, remainder 6);


--
-- TOC entry 4620 (class 0 OID 0)
-- Name: migration_log_007; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_007 FOR VALUES WITH (modulus 50, remainder 7);


--
-- TOC entry 4621 (class 0 OID 0)
-- Name: migration_log_008; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_008 FOR VALUES WITH (modulus 50, remainder 8);


--
-- TOC entry 4622 (class 0 OID 0)
-- Name: migration_log_009; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_009 FOR VALUES WITH (modulus 50, remainder 9);


--
-- TOC entry 4623 (class 0 OID 0)
-- Name: migration_log_010; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_010 FOR VALUES WITH (modulus 50, remainder 10);


--
-- TOC entry 4624 (class 0 OID 0)
-- Name: migration_log_011; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_011 FOR VALUES WITH (modulus 50, remainder 11);


--
-- TOC entry 4625 (class 0 OID 0)
-- Name: migration_log_012; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_012 FOR VALUES WITH (modulus 50, remainder 12);


--
-- TOC entry 4626 (class 0 OID 0)
-- Name: migration_log_013; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_013 FOR VALUES WITH (modulus 50, remainder 13);


--
-- TOC entry 4627 (class 0 OID 0)
-- Name: migration_log_014; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_014 FOR VALUES WITH (modulus 50, remainder 14);


--
-- TOC entry 4628 (class 0 OID 0)
-- Name: migration_log_015; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_015 FOR VALUES WITH (modulus 50, remainder 15);


--
-- TOC entry 4629 (class 0 OID 0)
-- Name: migration_log_016; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_016 FOR VALUES WITH (modulus 50, remainder 16);


--
-- TOC entry 4630 (class 0 OID 0)
-- Name: migration_log_017; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_017 FOR VALUES WITH (modulus 50, remainder 17);


--
-- TOC entry 4631 (class 0 OID 0)
-- Name: migration_log_018; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_018 FOR VALUES WITH (modulus 50, remainder 18);


--
-- TOC entry 4632 (class 0 OID 0)
-- Name: migration_log_019; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_019 FOR VALUES WITH (modulus 50, remainder 19);


--
-- TOC entry 4633 (class 0 OID 0)
-- Name: migration_log_020; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_020 FOR VALUES WITH (modulus 50, remainder 20);


--
-- TOC entry 4634 (class 0 OID 0)
-- Name: migration_log_021; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_021 FOR VALUES WITH (modulus 50, remainder 21);


--
-- TOC entry 4635 (class 0 OID 0)
-- Name: migration_log_022; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_022 FOR VALUES WITH (modulus 50, remainder 22);


--
-- TOC entry 4636 (class 0 OID 0)
-- Name: migration_log_023; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_023 FOR VALUES WITH (modulus 50, remainder 23);


--
-- TOC entry 4637 (class 0 OID 0)
-- Name: migration_log_024; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_024 FOR VALUES WITH (modulus 50, remainder 24);


--
-- TOC entry 4638 (class 0 OID 0)
-- Name: migration_log_025; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_025 FOR VALUES WITH (modulus 50, remainder 25);


--
-- TOC entry 4639 (class 0 OID 0)
-- Name: migration_log_026; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_026 FOR VALUES WITH (modulus 50, remainder 26);


--
-- TOC entry 4640 (class 0 OID 0)
-- Name: migration_log_027; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_027 FOR VALUES WITH (modulus 50, remainder 27);


--
-- TOC entry 4641 (class 0 OID 0)
-- Name: migration_log_028; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_028 FOR VALUES WITH (modulus 50, remainder 28);


--
-- TOC entry 4642 (class 0 OID 0)
-- Name: migration_log_029; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_029 FOR VALUES WITH (modulus 50, remainder 29);


--
-- TOC entry 4643 (class 0 OID 0)
-- Name: migration_log_030; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_030 FOR VALUES WITH (modulus 50, remainder 30);


--
-- TOC entry 4644 (class 0 OID 0)
-- Name: migration_log_031; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_031 FOR VALUES WITH (modulus 50, remainder 31);


--
-- TOC entry 4645 (class 0 OID 0)
-- Name: migration_log_032; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_032 FOR VALUES WITH (modulus 50, remainder 32);


--
-- TOC entry 4646 (class 0 OID 0)
-- Name: migration_log_033; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_033 FOR VALUES WITH (modulus 50, remainder 33);


--
-- TOC entry 4647 (class 0 OID 0)
-- Name: migration_log_034; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_034 FOR VALUES WITH (modulus 50, remainder 34);


--
-- TOC entry 4648 (class 0 OID 0)
-- Name: migration_log_035; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_035 FOR VALUES WITH (modulus 50, remainder 35);


--
-- TOC entry 4649 (class 0 OID 0)
-- Name: migration_log_036; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_036 FOR VALUES WITH (modulus 50, remainder 36);


--
-- TOC entry 4650 (class 0 OID 0)
-- Name: migration_log_037; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_037 FOR VALUES WITH (modulus 50, remainder 37);


--
-- TOC entry 4651 (class 0 OID 0)
-- Name: migration_log_038; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_038 FOR VALUES WITH (modulus 50, remainder 38);


--
-- TOC entry 4652 (class 0 OID 0)
-- Name: migration_log_039; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_039 FOR VALUES WITH (modulus 50, remainder 39);


--
-- TOC entry 4653 (class 0 OID 0)
-- Name: migration_log_040; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_040 FOR VALUES WITH (modulus 50, remainder 40);


--
-- TOC entry 4654 (class 0 OID 0)
-- Name: migration_log_041; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_041 FOR VALUES WITH (modulus 50, remainder 41);


--
-- TOC entry 4655 (class 0 OID 0)
-- Name: migration_log_042; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_042 FOR VALUES WITH (modulus 50, remainder 42);


--
-- TOC entry 4656 (class 0 OID 0)
-- Name: migration_log_043; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_043 FOR VALUES WITH (modulus 50, remainder 43);


--
-- TOC entry 4657 (class 0 OID 0)
-- Name: migration_log_044; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_044 FOR VALUES WITH (modulus 50, remainder 44);


--
-- TOC entry 4658 (class 0 OID 0)
-- Name: migration_log_045; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_045 FOR VALUES WITH (modulus 50, remainder 45);


--
-- TOC entry 4659 (class 0 OID 0)
-- Name: migration_log_046; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_046 FOR VALUES WITH (modulus 50, remainder 46);


--
-- TOC entry 4660 (class 0 OID 0)
-- Name: migration_log_047; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_047 FOR VALUES WITH (modulus 50, remainder 47);


--
-- TOC entry 4661 (class 0 OID 0)
-- Name: migration_log_048; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_048 FOR VALUES WITH (modulus 50, remainder 48);


--
-- TOC entry 4662 (class 0 OID 0)
-- Name: migration_log_049; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log ATTACH PARTITION public.migration_log_049 FOR VALUES WITH (modulus 50, remainder 49);


--
-- TOC entry 4663 (class 0 OID 0)
-- Name: pack_21122008; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122008 FOR VALUES FROM ('2008-12-21 00:00:00') TO ('2009-12-21 00:00:00');


--
-- TOC entry 4664 (class 0 OID 0)
-- Name: pack_21122009; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122009 FOR VALUES FROM ('2009-12-21 00:00:00') TO ('2010-12-21 00:00:00');


--
-- TOC entry 4665 (class 0 OID 0)
-- Name: pack_21122010; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122010 FOR VALUES FROM ('2010-12-21 00:00:00') TO ('2011-12-21 00:00:00');


--
-- TOC entry 4666 (class 0 OID 0)
-- Name: pack_21122011; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122011 FOR VALUES FROM ('2011-12-21 00:00:00') TO ('2012-12-21 00:00:00');


--
-- TOC entry 4667 (class 0 OID 0)
-- Name: pack_21122012; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122012 FOR VALUES FROM ('2012-12-21 00:00:00') TO ('2013-12-21 00:00:00');


--
-- TOC entry 4668 (class 0 OID 0)
-- Name: pack_21122013; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122013 FOR VALUES FROM ('2013-12-21 00:00:00') TO ('2014-12-21 00:00:00');


--
-- TOC entry 4669 (class 0 OID 0)
-- Name: pack_21122014; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122014 FOR VALUES FROM ('2014-12-21 00:00:00') TO ('2015-12-21 00:00:00');


--
-- TOC entry 4670 (class 0 OID 0)
-- Name: pack_21122015; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122015 FOR VALUES FROM ('2015-12-21 00:00:00') TO ('2016-12-21 00:00:00');


--
-- TOC entry 4671 (class 0 OID 0)
-- Name: pack_21122016; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122016 FOR VALUES FROM ('2016-12-21 00:00:00') TO ('2017-12-21 00:00:00');


--
-- TOC entry 4672 (class 0 OID 0)
-- Name: pack_21122017; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122017 FOR VALUES FROM ('2017-12-21 00:00:00') TO ('2018-12-21 00:00:00');


--
-- TOC entry 4673 (class 0 OID 0)
-- Name: pack_21122018; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122018 FOR VALUES FROM ('2018-12-21 00:00:00') TO ('2019-12-21 00:00:00');


--
-- TOC entry 4674 (class 0 OID 0)
-- Name: pack_21122019; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122019 FOR VALUES FROM ('2019-12-21 00:00:00') TO ('2020-12-21 00:00:00');


--
-- TOC entry 4675 (class 0 OID 0)
-- Name: pack_21122020; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122020 FOR VALUES FROM ('2020-12-21 00:00:00') TO ('2021-12-21 00:00:00');


--
-- TOC entry 4676 (class 0 OID 0)
-- Name: pack_21122021; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122021 FOR VALUES FROM ('2021-12-21 00:00:00') TO ('2022-12-21 00:00:00');


--
-- TOC entry 4677 (class 0 OID 0)
-- Name: pack_21122022; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122022 FOR VALUES FROM ('2022-12-21 00:00:00') TO ('2023-12-21 00:00:00');


--
-- TOC entry 4678 (class 0 OID 0)
-- Name: pack_21122023; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122023 FOR VALUES FROM ('2023-12-21 00:00:00') TO ('2024-12-21 00:00:00');


--
-- TOC entry 4679 (class 0 OID 0)
-- Name: pack_21122024; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122024 FOR VALUES FROM ('2024-12-21 00:00:00') TO ('2025-12-21 00:00:00');


--
-- TOC entry 4680 (class 0 OID 0)
-- Name: pack_21122025; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122025 FOR VALUES FROM ('2025-12-21 00:00:00') TO ('2026-12-21 00:00:00');


--
-- TOC entry 4681 (class 0 OID 0)
-- Name: pack_21122026; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122026 FOR VALUES FROM ('2026-12-21 00:00:00') TO ('2027-12-21 00:00:00');


--
-- TOC entry 4682 (class 0 OID 0)
-- Name: pack_21122027; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122027 FOR VALUES FROM ('2027-12-21 00:00:00') TO ('2028-12-21 00:00:00');


--
-- TOC entry 4683 (class 0 OID 0)
-- Name: pack_21122028; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122028 FOR VALUES FROM ('2028-12-21 00:00:00') TO ('2029-12-21 00:00:00');


--
-- TOC entry 4684 (class 0 OID 0)
-- Name: pack_21122029; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122029 FOR VALUES FROM ('2029-12-21 00:00:00') TO ('2030-12-21 00:00:00');


--
-- TOC entry 4685 (class 0 OID 0)
-- Name: pack_21122030; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122030 FOR VALUES FROM ('2030-12-21 00:00:00') TO ('2031-12-21 00:00:00');


--
-- TOC entry 4686 (class 0 OID 0)
-- Name: pack_21122031; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_21122031 FOR VALUES FROM ('2031-12-21 00:00:00') TO ('2032-12-21 00:00:00');


--
-- TOC entry 4687 (class 0 OID 0)
-- Name: pack_others; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ATTACH PARTITION public.pack_others DEFAULT;


--
-- TOC entry 4688 (class 0 OID 0)
-- Name: patient_1000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_1000 FOR VALUES FROM ('1') TO ('1000');


--
-- TOC entry 4689 (class 0 OID 0)
-- Name: patient_10000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_10000 FOR VALUES FROM ('9000') TO ('10000');


--
-- TOC entry 4690 (class 0 OID 0)
-- Name: patient_11000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_11000 FOR VALUES FROM ('10000') TO ('11000');


--
-- TOC entry 4691 (class 0 OID 0)
-- Name: patient_12000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_12000 FOR VALUES FROM ('11000') TO ('12000');


--
-- TOC entry 4692 (class 0 OID 0)
-- Name: patient_13000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_13000 FOR VALUES FROM ('12000') TO ('13000');


--
-- TOC entry 4693 (class 0 OID 0)
-- Name: patient_14000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_14000 FOR VALUES FROM ('13000') TO ('14000');


--
-- TOC entry 4694 (class 0 OID 0)
-- Name: patient_15000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_15000 FOR VALUES FROM ('14000') TO ('15000');


--
-- TOC entry 4695 (class 0 OID 0)
-- Name: patient_16000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_16000 FOR VALUES FROM ('15000') TO ('16000');


--
-- TOC entry 4696 (class 0 OID 0)
-- Name: patient_17000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_17000 FOR VALUES FROM ('16000') TO ('17000');


--
-- TOC entry 4697 (class 0 OID 0)
-- Name: patient_18000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_18000 FOR VALUES FROM ('17000') TO ('18000');


--
-- TOC entry 4698 (class 0 OID 0)
-- Name: patient_19000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_19000 FOR VALUES FROM ('18000') TO ('19000');


--
-- TOC entry 4699 (class 0 OID 0)
-- Name: patient_2000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_2000 FOR VALUES FROM ('1000') TO ('2000');


--
-- TOC entry 4700 (class 0 OID 0)
-- Name: patient_20000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_20000 FOR VALUES FROM ('19000') TO ('20000');


--
-- TOC entry 4701 (class 0 OID 0)
-- Name: patient_21000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_21000 FOR VALUES FROM ('20000') TO ('21000');


--
-- TOC entry 4702 (class 0 OID 0)
-- Name: patient_22000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_22000 FOR VALUES FROM ('21000') TO ('22000');


--
-- TOC entry 4703 (class 0 OID 0)
-- Name: patient_23000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_23000 FOR VALUES FROM ('22000') TO ('23000');


--
-- TOC entry 4704 (class 0 OID 0)
-- Name: patient_24000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_24000 FOR VALUES FROM ('23000') TO ('24000');


--
-- TOC entry 4705 (class 0 OID 0)
-- Name: patient_25000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_25000 FOR VALUES FROM ('24000') TO ('25000');


--
-- TOC entry 4706 (class 0 OID 0)
-- Name: patient_26000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_26000 FOR VALUES FROM ('25000') TO ('26000');


--
-- TOC entry 4707 (class 0 OID 0)
-- Name: patient_27000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_27000 FOR VALUES FROM ('26000') TO ('27000');


--
-- TOC entry 4708 (class 0 OID 0)
-- Name: patient_28000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_28000 FOR VALUES FROM ('27000') TO ('28000');


--
-- TOC entry 4709 (class 0 OID 0)
-- Name: patient_29000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_29000 FOR VALUES FROM ('28000') TO ('29000');


--
-- TOC entry 4710 (class 0 OID 0)
-- Name: patient_3000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_3000 FOR VALUES FROM ('2000') TO ('3000');


--
-- TOC entry 4711 (class 0 OID 0)
-- Name: patient_30000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_30000 FOR VALUES FROM ('29000') TO ('30000');


--
-- TOC entry 4712 (class 0 OID 0)
-- Name: patient_31000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_31000 FOR VALUES FROM ('30000') TO ('31000');


--
-- TOC entry 4713 (class 0 OID 0)
-- Name: patient_32000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_32000 FOR VALUES FROM ('31000') TO ('32000');


--
-- TOC entry 4714 (class 0 OID 0)
-- Name: patient_33000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_33000 FOR VALUES FROM ('32000') TO ('33000');


--
-- TOC entry 4715 (class 0 OID 0)
-- Name: patient_34000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_34000 FOR VALUES FROM ('33000') TO ('34000');


--
-- TOC entry 4716 (class 0 OID 0)
-- Name: patient_35000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_35000 FOR VALUES FROM ('34000') TO ('35000');


--
-- TOC entry 4717 (class 0 OID 0)
-- Name: patient_36000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_36000 FOR VALUES FROM ('35000') TO ('36000');


--
-- TOC entry 4718 (class 0 OID 0)
-- Name: patient_37000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_37000 FOR VALUES FROM ('36000') TO ('37000');


--
-- TOC entry 4719 (class 0 OID 0)
-- Name: patient_38000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_38000 FOR VALUES FROM ('37000') TO ('38000');


--
-- TOC entry 4720 (class 0 OID 0)
-- Name: patient_39000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_39000 FOR VALUES FROM ('38000') TO ('39000');


--
-- TOC entry 4721 (class 0 OID 0)
-- Name: patient_4000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_4000 FOR VALUES FROM ('3000') TO ('4000');


--
-- TOC entry 4722 (class 0 OID 0)
-- Name: patient_40000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_40000 FOR VALUES FROM ('39000') TO ('40000');


--
-- TOC entry 4723 (class 0 OID 0)
-- Name: patient_41000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_41000 FOR VALUES FROM ('40000') TO ('41000');


--
-- TOC entry 4724 (class 0 OID 0)
-- Name: patient_42000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_42000 FOR VALUES FROM ('41000') TO ('42000');


--
-- TOC entry 4725 (class 0 OID 0)
-- Name: patient_43000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_43000 FOR VALUES FROM ('42000') TO ('43000');


--
-- TOC entry 4726 (class 0 OID 0)
-- Name: patient_44000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_44000 FOR VALUES FROM ('43000') TO ('44000');


--
-- TOC entry 4727 (class 0 OID 0)
-- Name: patient_45000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_45000 FOR VALUES FROM ('44000') TO ('45000');


--
-- TOC entry 4728 (class 0 OID 0)
-- Name: patient_46000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_46000 FOR VALUES FROM ('45000') TO ('46000');


--
-- TOC entry 4729 (class 0 OID 0)
-- Name: patient_47000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_47000 FOR VALUES FROM ('46000') TO ('47000');


--
-- TOC entry 4730 (class 0 OID 0)
-- Name: patient_48000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_48000 FOR VALUES FROM ('47000') TO ('48000');


--
-- TOC entry 4731 (class 0 OID 0)
-- Name: patient_49000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_49000 FOR VALUES FROM ('48000') TO ('49000');


--
-- TOC entry 4732 (class 0 OID 0)
-- Name: patient_5000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_5000 FOR VALUES FROM ('4000') TO ('5000');


--
-- TOC entry 4733 (class 0 OID 0)
-- Name: patient_50000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_50000 FOR VALUES FROM ('49000') TO ('50000');


--
-- TOC entry 4734 (class 0 OID 0)
-- Name: patient_6000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_6000 FOR VALUES FROM ('5000') TO ('6000');


--
-- TOC entry 4735 (class 0 OID 0)
-- Name: patient_7000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_7000 FOR VALUES FROM ('6000') TO ('7000');


--
-- TOC entry 4736 (class 0 OID 0)
-- Name: patient_8000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_8000 FOR VALUES FROM ('7000') TO ('8000');


--
-- TOC entry 4737 (class 0 OID 0)
-- Name: patient_9000; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_9000 FOR VALUES FROM ('8000') TO ('9000');


--
-- TOC entry 4738 (class 0 OID 0)
-- Name: patient_others; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient ATTACH PARTITION public.patient_others DEFAULT;


--
-- TOC entry 4739 (class 0 OID 0)
-- Name: patient_service_identifier_21122008; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122008 FOR VALUES FROM ('2008-12-21 00:00:00') TO ('2009-12-21 00:00:00');


--
-- TOC entry 4740 (class 0 OID 0)
-- Name: patient_service_identifier_21122009; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122009 FOR VALUES FROM ('2009-12-21 00:00:00') TO ('2010-12-21 00:00:00');


--
-- TOC entry 4741 (class 0 OID 0)
-- Name: patient_service_identifier_21122010; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122010 FOR VALUES FROM ('2010-12-21 00:00:00') TO ('2011-12-21 00:00:00');


--
-- TOC entry 4742 (class 0 OID 0)
-- Name: patient_service_identifier_21122011; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122011 FOR VALUES FROM ('2011-12-21 00:00:00') TO ('2012-12-21 00:00:00');


--
-- TOC entry 4743 (class 0 OID 0)
-- Name: patient_service_identifier_21122012; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122012 FOR VALUES FROM ('2012-12-21 00:00:00') TO ('2013-12-21 00:00:00');


--
-- TOC entry 4744 (class 0 OID 0)
-- Name: patient_service_identifier_21122013; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122013 FOR VALUES FROM ('2013-12-21 00:00:00') TO ('2014-12-21 00:00:00');


--
-- TOC entry 4745 (class 0 OID 0)
-- Name: patient_service_identifier_21122014; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122014 FOR VALUES FROM ('2014-12-21 00:00:00') TO ('2015-12-21 00:00:00');


--
-- TOC entry 4746 (class 0 OID 0)
-- Name: patient_service_identifier_21122015; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122015 FOR VALUES FROM ('2015-12-21 00:00:00') TO ('2016-12-21 00:00:00');


--
-- TOC entry 4747 (class 0 OID 0)
-- Name: patient_service_identifier_21122016; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122016 FOR VALUES FROM ('2016-12-21 00:00:00') TO ('2017-12-21 00:00:00');


--
-- TOC entry 4748 (class 0 OID 0)
-- Name: patient_service_identifier_21122017; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122017 FOR VALUES FROM ('2017-12-21 00:00:00') TO ('2018-12-21 00:00:00');


--
-- TOC entry 4749 (class 0 OID 0)
-- Name: patient_service_identifier_21122018; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122018 FOR VALUES FROM ('2018-12-21 00:00:00') TO ('2019-12-21 00:00:00');


--
-- TOC entry 4750 (class 0 OID 0)
-- Name: patient_service_identifier_21122019; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122019 FOR VALUES FROM ('2019-12-21 00:00:00') TO ('2020-12-21 00:00:00');


--
-- TOC entry 4751 (class 0 OID 0)
-- Name: patient_service_identifier_21122020; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122020 FOR VALUES FROM ('2020-12-21 00:00:00') TO ('2021-12-21 00:00:00');


--
-- TOC entry 4752 (class 0 OID 0)
-- Name: patient_service_identifier_21122021; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122021 FOR VALUES FROM ('2021-12-21 00:00:00') TO ('2022-12-21 00:00:00');


--
-- TOC entry 4753 (class 0 OID 0)
-- Name: patient_service_identifier_21122022; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122022 FOR VALUES FROM ('2022-12-21 00:00:00') TO ('2023-12-21 00:00:00');


--
-- TOC entry 4754 (class 0 OID 0)
-- Name: patient_service_identifier_21122023; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122023 FOR VALUES FROM ('2023-12-21 00:00:00') TO ('2024-12-21 00:00:00');


--
-- TOC entry 4755 (class 0 OID 0)
-- Name: patient_service_identifier_21122024; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122024 FOR VALUES FROM ('2024-12-21 00:00:00') TO ('2025-12-21 00:00:00');


--
-- TOC entry 4756 (class 0 OID 0)
-- Name: patient_service_identifier_21122025; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122025 FOR VALUES FROM ('2025-12-21 00:00:00') TO ('2026-12-21 00:00:00');


--
-- TOC entry 4757 (class 0 OID 0)
-- Name: patient_service_identifier_21122027; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122027 FOR VALUES FROM ('2027-12-21 00:00:00') TO ('2028-12-21 00:00:00');


--
-- TOC entry 4758 (class 0 OID 0)
-- Name: patient_service_identifier_21122028; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122028 FOR VALUES FROM ('2028-12-21 00:00:00') TO ('2029-12-21 00:00:00');


--
-- TOC entry 4759 (class 0 OID 0)
-- Name: patient_service_identifier_21122029; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122029 FOR VALUES FROM ('2029-12-21 00:00:00') TO ('2030-12-21 00:00:00');


--
-- TOC entry 4760 (class 0 OID 0)
-- Name: patient_service_identifier_21122030; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122030 FOR VALUES FROM ('2030-12-21 00:00:00') TO ('2031-12-21 00:00:00');


--
-- TOC entry 4761 (class 0 OID 0)
-- Name: patient_service_identifier_21122031; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21122031 FOR VALUES FROM ('2031-12-21 00:00:00') TO ('2032-12-21 00:00:00');


--
-- TOC entry 4762 (class 0 OID 0)
-- Name: patient_service_identifier_21212026; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_21212026 FOR VALUES FROM ('2026-12-21 00:00:00') TO ('2027-12-21 00:00:00');


--
-- TOC entry 4763 (class 0 OID 0)
-- Name: patient_service_identifier_others; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier ATTACH PARTITION public.patient_service_identifier_others DEFAULT;


--
-- TOC entry 4764 (class 0 OID 0)
-- Name: patient_visit_21122008; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122008 FOR VALUES FROM ('2008-12-21 00:00:00') TO ('2009-12-21 00:00:00');


--
-- TOC entry 4765 (class 0 OID 0)
-- Name: patient_visit_21122009; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122009 FOR VALUES FROM ('2009-12-21 00:00:00') TO ('2010-12-21 00:00:00');


--
-- TOC entry 4766 (class 0 OID 0)
-- Name: patient_visit_21122010; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122010 FOR VALUES FROM ('2010-12-21 00:00:00') TO ('2011-12-21 00:00:00');


--
-- TOC entry 4767 (class 0 OID 0)
-- Name: patient_visit_21122011; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122011 FOR VALUES FROM ('2011-12-21 00:00:00') TO ('2012-12-21 00:00:00');


--
-- TOC entry 4768 (class 0 OID 0)
-- Name: patient_visit_21122012; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122012 FOR VALUES FROM ('2012-12-21 00:00:00') TO ('2013-12-21 00:00:00');


--
-- TOC entry 4769 (class 0 OID 0)
-- Name: patient_visit_21122013; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122013 FOR VALUES FROM ('2013-12-21 00:00:00') TO ('2014-12-21 00:00:00');


--
-- TOC entry 4770 (class 0 OID 0)
-- Name: patient_visit_21122014; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122014 FOR VALUES FROM ('2014-12-21 00:00:00') TO ('2015-12-21 00:00:00');


--
-- TOC entry 4771 (class 0 OID 0)
-- Name: patient_visit_21122015; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122015 FOR VALUES FROM ('2015-12-21 00:00:00') TO ('2016-12-21 00:00:00');


--
-- TOC entry 4772 (class 0 OID 0)
-- Name: patient_visit_21122016; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122016 FOR VALUES FROM ('2016-12-21 00:00:00') TO ('2017-12-21 00:00:00');


--
-- TOC entry 4773 (class 0 OID 0)
-- Name: patient_visit_21122017; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122017 FOR VALUES FROM ('2017-12-21 00:00:00') TO ('2018-12-21 00:00:00');


--
-- TOC entry 4774 (class 0 OID 0)
-- Name: patient_visit_21122018; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122018 FOR VALUES FROM ('2018-12-21 00:00:00') TO ('2019-12-21 00:00:00');


--
-- TOC entry 4775 (class 0 OID 0)
-- Name: patient_visit_21122019; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122019 FOR VALUES FROM ('2019-12-21 00:00:00') TO ('2020-12-21 00:00:00');


--
-- TOC entry 4776 (class 0 OID 0)
-- Name: patient_visit_21122020; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122020 FOR VALUES FROM ('2020-12-21 00:00:00') TO ('2021-12-21 00:00:00');


--
-- TOC entry 4777 (class 0 OID 0)
-- Name: patient_visit_21122021; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122021 FOR VALUES FROM ('2021-12-21 00:00:00') TO ('2022-12-21 00:00:00');


--
-- TOC entry 4778 (class 0 OID 0)
-- Name: patient_visit_21122022; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122022 FOR VALUES FROM ('2022-12-21 00:00:00') TO ('2023-12-21 00:00:00');


--
-- TOC entry 4779 (class 0 OID 0)
-- Name: patient_visit_21122023; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122023 FOR VALUES FROM ('2023-12-21 00:00:00') TO ('2024-12-21 00:00:00');


--
-- TOC entry 4780 (class 0 OID 0)
-- Name: patient_visit_21122024; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122024 FOR VALUES FROM ('2024-12-21 00:00:00') TO ('2025-12-21 00:00:00');


--
-- TOC entry 4781 (class 0 OID 0)
-- Name: patient_visit_21122025; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122025 FOR VALUES FROM ('2025-12-21 00:00:00') TO ('2026-12-21 00:00:00');


--
-- TOC entry 4782 (class 0 OID 0)
-- Name: patient_visit_21122026; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122026 FOR VALUES FROM ('2026-12-21 00:00:00') TO ('2027-12-21 00:00:00');


--
-- TOC entry 4783 (class 0 OID 0)
-- Name: patient_visit_21122027; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122027 FOR VALUES FROM ('2027-12-21 00:00:00') TO ('2028-12-21 00:00:00');


--
-- TOC entry 4784 (class 0 OID 0)
-- Name: patient_visit_21122028; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122028 FOR VALUES FROM ('2028-12-21 00:00:00') TO ('2029-12-21 00:00:00');


--
-- TOC entry 4785 (class 0 OID 0)
-- Name: patient_visit_21122029; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122029 FOR VALUES FROM ('2029-12-21 00:00:00') TO ('2030-12-21 00:00:00');


--
-- TOC entry 4786 (class 0 OID 0)
-- Name: patient_visit_21122030; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122030 FOR VALUES FROM ('2030-12-21 00:00:00') TO ('2031-12-21 00:00:00');


--
-- TOC entry 4787 (class 0 OID 0)
-- Name: patient_visit_21122031; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_21122031 FOR VALUES FROM ('2031-12-21 00:00:00') TO ('2032-12-21 00:00:00');


--
-- TOC entry 4788 (class 0 OID 0)
-- Name: patient_visit_others; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit ATTACH PARTITION public.patient_visit_others DEFAULT;


--
-- TOC entry 4789 (class 0 OID 0)
-- Name: prescription_21122008; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122008 FOR VALUES FROM ('2008-12-21 00:00:00') TO ('2009-12-21 00:00:00');


--
-- TOC entry 4790 (class 0 OID 0)
-- Name: prescription_21122009; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122009 FOR VALUES FROM ('2009-12-21 00:00:00') TO ('2010-12-21 00:00:00');


--
-- TOC entry 4791 (class 0 OID 0)
-- Name: prescription_21122010; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122010 FOR VALUES FROM ('2010-12-21 00:00:00') TO ('2011-12-21 00:00:00');


--
-- TOC entry 4792 (class 0 OID 0)
-- Name: prescription_21122011; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122011 FOR VALUES FROM ('2011-12-21 00:00:00') TO ('2012-12-21 00:00:00');


--
-- TOC entry 4793 (class 0 OID 0)
-- Name: prescription_21122012; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122012 FOR VALUES FROM ('2012-12-21 00:00:00') TO ('2013-12-21 00:00:00');


--
-- TOC entry 4794 (class 0 OID 0)
-- Name: prescription_21122013; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122013 FOR VALUES FROM ('2013-12-21 00:00:00') TO ('2014-12-21 00:00:00');


--
-- TOC entry 4795 (class 0 OID 0)
-- Name: prescription_21122014; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122014 FOR VALUES FROM ('2014-12-21 00:00:00') TO ('2015-12-21 00:00:00');


--
-- TOC entry 4796 (class 0 OID 0)
-- Name: prescription_21122015; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122015 FOR VALUES FROM ('2015-12-21 00:00:00') TO ('2016-12-21 00:00:00');


--
-- TOC entry 4797 (class 0 OID 0)
-- Name: prescription_21122016; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122016 FOR VALUES FROM ('2016-12-21 00:00:00') TO ('2017-12-21 00:00:00');


--
-- TOC entry 4798 (class 0 OID 0)
-- Name: prescription_21122017; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122017 FOR VALUES FROM ('2017-12-21 00:00:00') TO ('2018-12-21 00:00:00');


--
-- TOC entry 4799 (class 0 OID 0)
-- Name: prescription_21122018; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122018 FOR VALUES FROM ('2018-12-21 00:00:00') TO ('2019-12-21 00:00:00');


--
-- TOC entry 4800 (class 0 OID 0)
-- Name: prescription_21122019; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122019 FOR VALUES FROM ('2019-12-21 00:00:00') TO ('2020-12-21 00:00:00');


--
-- TOC entry 4801 (class 0 OID 0)
-- Name: prescription_21122020; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122020 FOR VALUES FROM ('2020-12-21 00:00:00') TO ('2021-12-21 00:00:00');


--
-- TOC entry 4802 (class 0 OID 0)
-- Name: prescription_21122021; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122021 FOR VALUES FROM ('2021-12-21 00:00:00') TO ('2022-12-21 00:00:00');


--
-- TOC entry 4803 (class 0 OID 0)
-- Name: prescription_21122022; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122022 FOR VALUES FROM ('2022-12-21 00:00:00') TO ('2023-12-21 00:00:00');


--
-- TOC entry 4804 (class 0 OID 0)
-- Name: prescription_21122023; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122023 FOR VALUES FROM ('2023-12-21 00:00:00') TO ('2024-12-21 00:00:00');


--
-- TOC entry 4805 (class 0 OID 0)
-- Name: prescription_21122024; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122024 FOR VALUES FROM ('2024-12-21 00:00:00') TO ('2025-12-21 00:00:00');


--
-- TOC entry 4806 (class 0 OID 0)
-- Name: prescription_21122025; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122025 FOR VALUES FROM ('2025-12-21 00:00:00') TO ('2026-12-21 00:00:00');


--
-- TOC entry 4807 (class 0 OID 0)
-- Name: prescription_21122026; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122026 FOR VALUES FROM ('2026-12-21 00:00:00') TO ('2027-12-21 00:00:00');


--
-- TOC entry 4808 (class 0 OID 0)
-- Name: prescription_21122027; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122027 FOR VALUES FROM ('2027-12-21 00:00:00') TO ('2028-12-21 00:00:00');


--
-- TOC entry 4809 (class 0 OID 0)
-- Name: prescription_21122028; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122028 FOR VALUES FROM ('2028-12-21 00:00:00') TO ('2029-12-21 00:00:00');


--
-- TOC entry 4810 (class 0 OID 0)
-- Name: prescription_21122029; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122029 FOR VALUES FROM ('2029-12-21 00:00:00') TO ('2030-12-21 00:00:00');


--
-- TOC entry 4811 (class 0 OID 0)
-- Name: prescription_21122030; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122030 FOR VALUES FROM ('2030-12-21 00:00:00') TO ('2031-12-21 00:00:00');


--
-- TOC entry 4812 (class 0 OID 0)
-- Name: prescription_21122031; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_21122031 FOR VALUES FROM ('2031-12-21 00:00:00') TO ('2032-12-21 00:00:00');


--
-- TOC entry 4813 (class 0 OID 0)
-- Name: prescription_others; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription ATTACH PARTITION public.prescription_others DEFAULT;


--
-- TOC entry 5148 (class 2606 OID 125529)
-- Name: absent_patients_report absent_patients_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.absent_patients_report
    ADD CONSTRAINT absent_patients_report_pkey PRIMARY KEY (id);


--
-- TOC entry 5150 (class 2606 OID 125531)
-- Name: active_patient_report active_patient_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.active_patient_report
    ADD CONSTRAINT active_patient_report_pkey PRIMARY KEY (id);


--
-- TOC entry 5152 (class 2606 OID 125533)
-- Name: adherence_screening adherence_screening_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adherence_screening
    ADD CONSTRAINT adherence_screening_pkey PRIMARY KEY (id);


--
-- TOC entry 5155 (class 2606 OID 125535)
-- Name: appointment appointment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT appointment_pkey PRIMARY KEY (id);


--
-- TOC entry 5158 (class 2606 OID 125537)
-- Name: appointmet appointmet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointmet
    ADD CONSTRAINT appointmet_pkey PRIMARY KEY (id);


--
-- TOC entry 5160 (class 2606 OID 125539)
-- Name: arv_daily_register_report_temp arv_daily_register_report_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arv_daily_register_report_temp
    ADD CONSTRAINT arv_daily_register_report_temp_pkey PRIMARY KEY (id);


--
-- TOC entry 5162 (class 2606 OID 125541)
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5164 (class 2606 OID 125543)
-- Name: balancete_report balancete_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balancete_report
    ADD CONSTRAINT balancete_report_pkey PRIMARY KEY (id);


--
-- TOC entry 5166 (class 2606 OID 125545)
-- Name: clinic clinic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic
    ADD CONSTRAINT clinic_pkey PRIMARY KEY (id);


--
-- TOC entry 5173 (class 2606 OID 125547)
-- Name: clinic_sector clinic_sector_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic_sector
    ADD CONSTRAINT clinic_sector_pkey PRIMARY KEY (id);


--
-- TOC entry 5179 (class 2606 OID 125549)
-- Name: clinic_sector_type clinic_sector_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic_sector_type
    ADD CONSTRAINT clinic_sector_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5184 (class 2606 OID 125551)
-- Name: clinic_sector_users clinic_sector_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic_sector_users
    ADD CONSTRAINT clinic_sector_users_pkey PRIMARY KEY (sec_user_id, clinic_sector_id);


--
-- TOC entry 5186 (class 2606 OID 125553)
-- Name: clinic_users clinic_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic_users
    ADD CONSTRAINT clinic_users_pkey PRIMARY KEY (sec_user_id, clinic_id);


--
-- TOC entry 5193 (class 2606 OID 125555)
-- Name: clinical_service_attribute clinical_service_attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_attribute
    ADD CONSTRAINT clinical_service_attribute_pkey PRIMARY KEY (id);


--
-- TOC entry 5195 (class 2606 OID 125557)
-- Name: clinical_service_attribute_type clinical_service_attribute_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_attribute_type
    ADD CONSTRAINT clinical_service_attribute_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5200 (class 2606 OID 125559)
-- Name: clinical_service_clinic_sectors clinical_service_clinic_sectors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_clinic_sectors
    ADD CONSTRAINT clinical_service_clinic_sectors_pkey PRIMARY KEY (clinical_service_id, clinic_sector_id);


--
-- TOC entry 5188 (class 2606 OID 125561)
-- Name: clinical_service clinical_service_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service
    ADD CONSTRAINT clinical_service_pkey PRIMARY KEY (id);


--
-- TOC entry 5202 (class 2606 OID 125563)
-- Name: clinical_service_therapeutic_regimens clinical_service_therapeutic_regimens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_therapeutic_regimens
    ADD CONSTRAINT clinical_service_therapeutic_regimens_pkey PRIMARY KEY (clinical_service_id, therapeutic_regimen_id);


--
-- TOC entry 5204 (class 2606 OID 125565)
-- Name: destroyed_stock destroyed_stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.destroyed_stock
    ADD CONSTRAINT destroyed_stock_pkey PRIMARY KEY (id);


--
-- TOC entry 5207 (class 2606 OID 125567)
-- Name: dispense_mode dispense_mode_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispense_mode
    ADD CONSTRAINT dispense_mode_pkey PRIMARY KEY (id);


--
-- TOC entry 5210 (class 2606 OID 125569)
-- Name: dispense_type dispense_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispense_type
    ADD CONSTRAINT dispense_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5215 (class 2606 OID 125571)
-- Name: district district_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.district
    ADD CONSTRAINT district_pkey PRIMARY KEY (id);


--
-- TOC entry 5220 (class 2606 OID 125573)
-- Name: doctor doctor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_pkey PRIMARY KEY (id);


--
-- TOC entry 5226 (class 2606 OID 125575)
-- Name: drug_distributor drug_distributor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drug_distributor
    ADD CONSTRAINT drug_distributor_pkey PRIMARY KEY (id);


--
-- TOC entry 5223 (class 2606 OID 125577)
-- Name: drug drug_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drug
    ADD CONSTRAINT drug_pkey PRIMARY KEY (id);


--
-- TOC entry 5229 (class 2606 OID 125579)
-- Name: drug_quantity_temp drug_quantity_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drug_quantity_temp
    ADD CONSTRAINT drug_quantity_temp_pkey PRIMARY KEY (id);


--
-- TOC entry 5262 (class 2606 OID 125581)
-- Name: duration duration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.duration
    ADD CONSTRAINT duration_pkey PRIMARY KEY (id);


--
-- TOC entry 5265 (class 2606 OID 125583)
-- Name: episode episode_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode
    ADD CONSTRAINT episode_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5269 (class 2606 OID 125585)
-- Name: episode_21122008 episode_21122008_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122008
    ADD CONSTRAINT episode_21122008_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5272 (class 2606 OID 125587)
-- Name: episode_21122009 episode_21122009_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122009
    ADD CONSTRAINT episode_21122009_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5275 (class 2606 OID 125589)
-- Name: episode_21122010 episode_21122010_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122010
    ADD CONSTRAINT episode_21122010_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5278 (class 2606 OID 125591)
-- Name: episode_21122011 episode_21122011_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122011
    ADD CONSTRAINT episode_21122011_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5281 (class 2606 OID 125593)
-- Name: episode_21122012 episode_21122012_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122012
    ADD CONSTRAINT episode_21122012_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5284 (class 2606 OID 125595)
-- Name: episode_21122013 episode_21122013_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122013
    ADD CONSTRAINT episode_21122013_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5287 (class 2606 OID 125597)
-- Name: episode_21122014 episode_21122014_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122014
    ADD CONSTRAINT episode_21122014_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5290 (class 2606 OID 125599)
-- Name: episode_21122015 episode_21122015_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122015
    ADD CONSTRAINT episode_21122015_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5293 (class 2606 OID 125601)
-- Name: episode_21122016 episode_21122016_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122016
    ADD CONSTRAINT episode_21122016_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5296 (class 2606 OID 125603)
-- Name: episode_21122017 episode_21122017_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122017
    ADD CONSTRAINT episode_21122017_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5299 (class 2606 OID 125605)
-- Name: episode_21122018 episode_21122018_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122018
    ADD CONSTRAINT episode_21122018_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5302 (class 2606 OID 125607)
-- Name: episode_21122019 episode_21122019_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122019
    ADD CONSTRAINT episode_21122019_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5305 (class 2606 OID 125609)
-- Name: episode_21122020 episode_21122020_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122020
    ADD CONSTRAINT episode_21122020_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5308 (class 2606 OID 125611)
-- Name: episode_21122021 episode_21122021_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122021
    ADD CONSTRAINT episode_21122021_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5311 (class 2606 OID 125613)
-- Name: episode_21122022 episode_21122022_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122022
    ADD CONSTRAINT episode_21122022_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5314 (class 2606 OID 125615)
-- Name: episode_21122023 episode_21122023_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122023
    ADD CONSTRAINT episode_21122023_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5317 (class 2606 OID 125617)
-- Name: episode_21122024 episode_21122024_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122024
    ADD CONSTRAINT episode_21122024_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5320 (class 2606 OID 125619)
-- Name: episode_21122025 episode_21122025_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122025
    ADD CONSTRAINT episode_21122025_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5323 (class 2606 OID 125621)
-- Name: episode_21122026 episode_21122026_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122026
    ADD CONSTRAINT episode_21122026_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5326 (class 2606 OID 125623)
-- Name: episode_21122027 episode_21122027_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122027
    ADD CONSTRAINT episode_21122027_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5329 (class 2606 OID 125625)
-- Name: episode_21122028 episode_21122028_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122028
    ADD CONSTRAINT episode_21122028_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5332 (class 2606 OID 125627)
-- Name: episode_21122029 episode_21122029_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122029
    ADD CONSTRAINT episode_21122029_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5335 (class 2606 OID 125629)
-- Name: episode_21122030 episode_21122030_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122030
    ADD CONSTRAINT episode_21122030_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5338 (class 2606 OID 125631)
-- Name: episode_21122031 episode_21122031_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_21122031
    ADD CONSTRAINT episode_21122031_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5341 (class 2606 OID 125633)
-- Name: episode_others episode_others_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_others
    ADD CONSTRAINT episode_others_pkey PRIMARY KEY (id, episode_date);


--
-- TOC entry 5343 (class 2606 OID 125635)
-- Name: episode_type episode_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_type
    ADD CONSTRAINT episode_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5348 (class 2606 OID 125637)
-- Name: expected_patient_report expected_patient_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expected_patient_report
    ADD CONSTRAINT expected_patient_report_pkey PRIMARY KEY (id);


--
-- TOC entry 5350 (class 2606 OID 125639)
-- Name: facility_type facility_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_type
    ADD CONSTRAINT facility_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5355 (class 2606 OID 125641)
-- Name: form form_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form
    ADD CONSTRAINT form_pkey PRIMARY KEY (id);


--
-- TOC entry 5360 (class 2606 OID 125643)
-- Name: group_info group_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_info
    ADD CONSTRAINT group_info_pkey PRIMARY KEY (id);


--
-- TOC entry 5365 (class 2606 OID 125645)
-- Name: group_member group_member_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT group_member_pkey PRIMARY KEY (id);


--
-- TOC entry 5370 (class 2606 OID 125647)
-- Name: group_member_prescription group_member_prescription_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_member_prescription
    ADD CONSTRAINT group_member_prescription_pkey PRIMARY KEY (id);


--
-- TOC entry 5376 (class 2606 OID 125649)
-- Name: group_pack_header group_pack_header_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_pack_header
    ADD CONSTRAINT group_pack_header_pkey PRIMARY KEY (id);


--
-- TOC entry 5373 (class 2606 OID 125651)
-- Name: group_pack group_pack_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_pack
    ADD CONSTRAINT group_pack_pkey PRIMARY KEY (id);


--
-- TOC entry 5379 (class 2606 OID 125653)
-- Name: group_type group_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_type
    ADD CONSTRAINT group_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5384 (class 2606 OID 125655)
-- Name: health_information_system health_information_system_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_information_system
    ADD CONSTRAINT health_information_system_pkey PRIMARY KEY (id);


--
-- TOC entry 5389 (class 2606 OID 125657)
-- Name: historico_levantamento_report historico_levantamento_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historico_levantamento_report
    ADD CONSTRAINT historico_levantamento_report_pkey PRIMARY KEY (id);


--
-- TOC entry 5391 (class 2606 OID 125659)
-- Name: identifier_type identifier_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.identifier_type
    ADD CONSTRAINT identifier_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5396 (class 2606 OID 125661)
-- Name: interoperability_attribute interoperability_attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interoperability_attribute
    ADD CONSTRAINT interoperability_attribute_pkey PRIMARY KEY (id);


--
-- TOC entry 5399 (class 2606 OID 125663)
-- Name: interoperability_type interoperability_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interoperability_type
    ADD CONSTRAINT interoperability_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5231 (class 2606 OID 125665)
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (id);


--
-- TOC entry 5404 (class 2606 OID 125667)
-- Name: inventory_report_response inventory_report_response_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_report_response
    ADD CONSTRAINT inventory_report_response_pkey PRIMARY KEY (id);


--
-- TOC entry 5406 (class 2606 OID 125669)
-- Name: inventory_report_temp inventory_report_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_report_temp
    ADD CONSTRAINT inventory_report_temp_pkey PRIMARY KEY (id);


--
-- TOC entry 5408 (class 2606 OID 125671)
-- Name: linhas_usadas_report linhas_usadas_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linhas_usadas_report
    ADD CONSTRAINT linhas_usadas_report_pkey PRIMARY KEY (id);


--
-- TOC entry 5410 (class 2606 OID 125673)
-- Name: localidade localidade_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localidade
    ADD CONSTRAINT localidade_pkey PRIMARY KEY (id);


--
-- TOC entry 5415 (class 2606 OID 125675)
-- Name: menu menu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu
    ADD CONSTRAINT menu_pkey PRIMARY KEY (id);


--
-- TOC entry 5421 (class 2606 OID 125677)
-- Name: migration_log migration_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log
    ADD CONSTRAINT migration_log_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5425 (class 2606 OID 125679)
-- Name: migration_log_000 migration_log_000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_000
    ADD CONSTRAINT migration_log_000_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5428 (class 2606 OID 125681)
-- Name: migration_log_001 migration_log_001_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_001
    ADD CONSTRAINT migration_log_001_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5431 (class 2606 OID 125683)
-- Name: migration_log_002 migration_log_002_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_002
    ADD CONSTRAINT migration_log_002_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5434 (class 2606 OID 125685)
-- Name: migration_log_003 migration_log_003_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_003
    ADD CONSTRAINT migration_log_003_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5437 (class 2606 OID 125687)
-- Name: migration_log_004 migration_log_004_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_004
    ADD CONSTRAINT migration_log_004_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5440 (class 2606 OID 125689)
-- Name: migration_log_005 migration_log_005_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_005
    ADD CONSTRAINT migration_log_005_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5443 (class 2606 OID 125691)
-- Name: migration_log_006 migration_log_006_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_006
    ADD CONSTRAINT migration_log_006_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5446 (class 2606 OID 125693)
-- Name: migration_log_007 migration_log_007_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_007
    ADD CONSTRAINT migration_log_007_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5449 (class 2606 OID 125695)
-- Name: migration_log_008 migration_log_008_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_008
    ADD CONSTRAINT migration_log_008_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5452 (class 2606 OID 125697)
-- Name: migration_log_009 migration_log_009_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_009
    ADD CONSTRAINT migration_log_009_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5455 (class 2606 OID 125699)
-- Name: migration_log_010 migration_log_010_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_010
    ADD CONSTRAINT migration_log_010_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5458 (class 2606 OID 125701)
-- Name: migration_log_011 migration_log_011_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_011
    ADD CONSTRAINT migration_log_011_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5461 (class 2606 OID 125703)
-- Name: migration_log_012 migration_log_012_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_012
    ADD CONSTRAINT migration_log_012_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5464 (class 2606 OID 125705)
-- Name: migration_log_013 migration_log_013_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_013
    ADD CONSTRAINT migration_log_013_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5467 (class 2606 OID 125707)
-- Name: migration_log_014 migration_log_014_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_014
    ADD CONSTRAINT migration_log_014_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5470 (class 2606 OID 125709)
-- Name: migration_log_015 migration_log_015_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_015
    ADD CONSTRAINT migration_log_015_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5473 (class 2606 OID 125711)
-- Name: migration_log_016 migration_log_016_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_016
    ADD CONSTRAINT migration_log_016_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5476 (class 2606 OID 125713)
-- Name: migration_log_017 migration_log_017_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_017
    ADD CONSTRAINT migration_log_017_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5479 (class 2606 OID 125715)
-- Name: migration_log_018 migration_log_018_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_018
    ADD CONSTRAINT migration_log_018_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5482 (class 2606 OID 125717)
-- Name: migration_log_019 migration_log_019_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_019
    ADD CONSTRAINT migration_log_019_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5485 (class 2606 OID 125719)
-- Name: migration_log_020 migration_log_020_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_020
    ADD CONSTRAINT migration_log_020_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5488 (class 2606 OID 125721)
-- Name: migration_log_021 migration_log_021_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_021
    ADD CONSTRAINT migration_log_021_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5491 (class 2606 OID 125723)
-- Name: migration_log_022 migration_log_022_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_022
    ADD CONSTRAINT migration_log_022_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5494 (class 2606 OID 125725)
-- Name: migration_log_023 migration_log_023_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_023
    ADD CONSTRAINT migration_log_023_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5497 (class 2606 OID 125727)
-- Name: migration_log_024 migration_log_024_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_024
    ADD CONSTRAINT migration_log_024_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5500 (class 2606 OID 125729)
-- Name: migration_log_025 migration_log_025_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_025
    ADD CONSTRAINT migration_log_025_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5503 (class 2606 OID 125731)
-- Name: migration_log_026 migration_log_026_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_026
    ADD CONSTRAINT migration_log_026_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5506 (class 2606 OID 125733)
-- Name: migration_log_027 migration_log_027_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_027
    ADD CONSTRAINT migration_log_027_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5509 (class 2606 OID 125735)
-- Name: migration_log_028 migration_log_028_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_028
    ADD CONSTRAINT migration_log_028_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5512 (class 2606 OID 125737)
-- Name: migration_log_029 migration_log_029_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_029
    ADD CONSTRAINT migration_log_029_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5515 (class 2606 OID 125739)
-- Name: migration_log_030 migration_log_030_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_030
    ADD CONSTRAINT migration_log_030_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5518 (class 2606 OID 125741)
-- Name: migration_log_031 migration_log_031_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_031
    ADD CONSTRAINT migration_log_031_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5521 (class 2606 OID 125743)
-- Name: migration_log_032 migration_log_032_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_032
    ADD CONSTRAINT migration_log_032_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5524 (class 2606 OID 125745)
-- Name: migration_log_033 migration_log_033_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_033
    ADD CONSTRAINT migration_log_033_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5527 (class 2606 OID 125747)
-- Name: migration_log_034 migration_log_034_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_034
    ADD CONSTRAINT migration_log_034_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5530 (class 2606 OID 125749)
-- Name: migration_log_035 migration_log_035_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_035
    ADD CONSTRAINT migration_log_035_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5533 (class 2606 OID 125751)
-- Name: migration_log_036 migration_log_036_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_036
    ADD CONSTRAINT migration_log_036_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5536 (class 2606 OID 125753)
-- Name: migration_log_037 migration_log_037_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_037
    ADD CONSTRAINT migration_log_037_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5539 (class 2606 OID 125755)
-- Name: migration_log_038 migration_log_038_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_038
    ADD CONSTRAINT migration_log_038_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5542 (class 2606 OID 125757)
-- Name: migration_log_039 migration_log_039_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_039
    ADD CONSTRAINT migration_log_039_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5545 (class 2606 OID 125759)
-- Name: migration_log_040 migration_log_040_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_040
    ADD CONSTRAINT migration_log_040_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5548 (class 2606 OID 125761)
-- Name: migration_log_041 migration_log_041_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_041
    ADD CONSTRAINT migration_log_041_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5551 (class 2606 OID 125763)
-- Name: migration_log_042 migration_log_042_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_042
    ADD CONSTRAINT migration_log_042_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5554 (class 2606 OID 125765)
-- Name: migration_log_043 migration_log_043_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_043
    ADD CONSTRAINT migration_log_043_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5557 (class 2606 OID 125767)
-- Name: migration_log_044 migration_log_044_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_044
    ADD CONSTRAINT migration_log_044_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5560 (class 2606 OID 125769)
-- Name: migration_log_045 migration_log_045_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_045
    ADD CONSTRAINT migration_log_045_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5563 (class 2606 OID 125771)
-- Name: migration_log_046 migration_log_046_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_046
    ADD CONSTRAINT migration_log_046_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5566 (class 2606 OID 125773)
-- Name: migration_log_047 migration_log_047_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_047
    ADD CONSTRAINT migration_log_047_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5569 (class 2606 OID 125775)
-- Name: migration_log_048 migration_log_048_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_048
    ADD CONSTRAINT migration_log_048_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5572 (class 2606 OID 125777)
-- Name: migration_log_049 migration_log_049_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_log_049
    ADD CONSTRAINT migration_log_049_pkey PRIMARY KEY (id, source_id);


--
-- TOC entry 5574 (class 2606 OID 125779)
-- Name: migration_stage migration_stage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_stage
    ADD CONSTRAINT migration_stage_pkey PRIMARY KEY (id);


--
-- TOC entry 5579 (class 2606 OID 125781)
-- Name: mmia_regimen_sub_report mmia_regimen_sub_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mmia_regimen_sub_report
    ADD CONSTRAINT mmia_regimen_sub_report_pkey PRIMARY KEY (id);


--
-- TOC entry 5583 (class 2606 OID 125783)
-- Name: mmia_report_clinic mmia_report_clinic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mmia_report_clinic
    ADD CONSTRAINT mmia_report_clinic_pkey PRIMARY KEY (clinic_id, mmia_report_clinic_id);


--
-- TOC entry 5581 (class 2606 OID 125785)
-- Name: mmia_report mmia_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mmia_report
    ADD CONSTRAINT mmia_report_pkey PRIMARY KEY (id);


--
-- TOC entry 5585 (class 2606 OID 125787)
-- Name: mmia_stock_sub_report_item mmia_stock_sub_report_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mmia_stock_sub_report_item
    ADD CONSTRAINT mmia_stock_sub_report_item_pkey PRIMARY KEY (id);


--
-- TOC entry 5587 (class 2606 OID 125789)
-- Name: national_clinic national_clinic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.national_clinic
    ADD CONSTRAINT national_clinic_pkey PRIMARY KEY (id);


--
-- TOC entry 5594 (class 2606 OID 125791)
-- Name: not_synchronizing_packs_open_mrs_report not_synchronizing_packs_open_mrs_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.not_synchronizing_packs_open_mrs_report
    ADD CONSTRAINT not_synchronizing_packs_open_mrs_report_pkey PRIMARY KEY (id);


--
-- TOC entry 5596 (class 2606 OID 125793)
-- Name: openmrs_error_log openmrs_error_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.openmrs_error_log
    ADD CONSTRAINT openmrs_error_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5234 (class 2606 OID 125795)
-- Name: pack pack_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack
    ADD CONSTRAINT pack_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5600 (class 2606 OID 125797)
-- Name: pack_21122008 pack_21122008_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122008
    ADD CONSTRAINT pack_21122008_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5603 (class 2606 OID 125799)
-- Name: pack_21122009 pack_21122009_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122009
    ADD CONSTRAINT pack_21122009_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5606 (class 2606 OID 125801)
-- Name: pack_21122010 pack_21122010_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122010
    ADD CONSTRAINT pack_21122010_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5609 (class 2606 OID 125803)
-- Name: pack_21122011 pack_21122011_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122011
    ADD CONSTRAINT pack_21122011_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5612 (class 2606 OID 125805)
-- Name: pack_21122012 pack_21122012_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122012
    ADD CONSTRAINT pack_21122012_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5615 (class 2606 OID 125807)
-- Name: pack_21122013 pack_21122013_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122013
    ADD CONSTRAINT pack_21122013_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5618 (class 2606 OID 125809)
-- Name: pack_21122014 pack_21122014_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122014
    ADD CONSTRAINT pack_21122014_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5621 (class 2606 OID 125811)
-- Name: pack_21122015 pack_21122015_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122015
    ADD CONSTRAINT pack_21122015_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5624 (class 2606 OID 125813)
-- Name: pack_21122016 pack_21122016_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122016
    ADD CONSTRAINT pack_21122016_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5627 (class 2606 OID 125815)
-- Name: pack_21122017 pack_21122017_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122017
    ADD CONSTRAINT pack_21122017_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5630 (class 2606 OID 125817)
-- Name: pack_21122018 pack_21122018_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122018
    ADD CONSTRAINT pack_21122018_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5633 (class 2606 OID 125819)
-- Name: pack_21122019 pack_21122019_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122019
    ADD CONSTRAINT pack_21122019_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5636 (class 2606 OID 125821)
-- Name: pack_21122020 pack_21122020_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122020
    ADD CONSTRAINT pack_21122020_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5639 (class 2606 OID 125823)
-- Name: pack_21122021 pack_21122021_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122021
    ADD CONSTRAINT pack_21122021_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5642 (class 2606 OID 125825)
-- Name: pack_21122022 pack_21122022_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122022
    ADD CONSTRAINT pack_21122022_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5645 (class 2606 OID 125827)
-- Name: pack_21122023 pack_21122023_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122023
    ADD CONSTRAINT pack_21122023_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5648 (class 2606 OID 125829)
-- Name: pack_21122024 pack_21122024_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122024
    ADD CONSTRAINT pack_21122024_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5651 (class 2606 OID 125831)
-- Name: pack_21122025 pack_21122025_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122025
    ADD CONSTRAINT pack_21122025_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5654 (class 2606 OID 125833)
-- Name: pack_21122026 pack_21122026_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122026
    ADD CONSTRAINT pack_21122026_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5657 (class 2606 OID 125835)
-- Name: pack_21122027 pack_21122027_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122027
    ADD CONSTRAINT pack_21122027_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5660 (class 2606 OID 125837)
-- Name: pack_21122028 pack_21122028_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122028
    ADD CONSTRAINT pack_21122028_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5663 (class 2606 OID 125839)
-- Name: pack_21122029 pack_21122029_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122029
    ADD CONSTRAINT pack_21122029_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5666 (class 2606 OID 125841)
-- Name: pack_21122030 pack_21122030_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122030
    ADD CONSTRAINT pack_21122030_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5669 (class 2606 OID 125843)
-- Name: pack_21122031 pack_21122031_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_21122031
    ADD CONSTRAINT pack_21122031_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5672 (class 2606 OID 125845)
-- Name: pack_others pack_others_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_others
    ADD CONSTRAINT pack_others_pkey PRIMARY KEY (id, pickup_date);


--
-- TOC entry 5237 (class 2606 OID 125847)
-- Name: packaged_drug packaged_drug_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packaged_drug
    ADD CONSTRAINT packaged_drug_pkey PRIMARY KEY (id);


--
-- TOC entry 5240 (class 2606 OID 125849)
-- Name: packaged_drug_stock packaged_drug_stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packaged_drug_stock
    ADD CONSTRAINT packaged_drug_stock_pkey PRIMARY KEY (id);


--
-- TOC entry 5674 (class 2606 OID 125851)
-- Name: patient patient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient
    ADD CONSTRAINT patient_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5681 (class 2606 OID 125853)
-- Name: patient_10000 patient_10000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_10000
    ADD CONSTRAINT patient_10000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5678 (class 2606 OID 125855)
-- Name: patient_1000 patient_1000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_1000
    ADD CONSTRAINT patient_1000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5684 (class 2606 OID 125857)
-- Name: patient_11000 patient_11000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_11000
    ADD CONSTRAINT patient_11000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5687 (class 2606 OID 125859)
-- Name: patient_12000 patient_12000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_12000
    ADD CONSTRAINT patient_12000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5690 (class 2606 OID 125861)
-- Name: patient_13000 patient_13000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_13000
    ADD CONSTRAINT patient_13000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5693 (class 2606 OID 125863)
-- Name: patient_14000 patient_14000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_14000
    ADD CONSTRAINT patient_14000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5696 (class 2606 OID 125865)
-- Name: patient_15000 patient_15000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_15000
    ADD CONSTRAINT patient_15000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5699 (class 2606 OID 125867)
-- Name: patient_16000 patient_16000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_16000
    ADD CONSTRAINT patient_16000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5702 (class 2606 OID 125869)
-- Name: patient_17000 patient_17000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_17000
    ADD CONSTRAINT patient_17000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5705 (class 2606 OID 125871)
-- Name: patient_18000 patient_18000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_18000
    ADD CONSTRAINT patient_18000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5708 (class 2606 OID 125873)
-- Name: patient_19000 patient_19000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_19000
    ADD CONSTRAINT patient_19000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5714 (class 2606 OID 125875)
-- Name: patient_20000 patient_20000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_20000
    ADD CONSTRAINT patient_20000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5711 (class 2606 OID 125877)
-- Name: patient_2000 patient_2000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_2000
    ADD CONSTRAINT patient_2000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5717 (class 2606 OID 125879)
-- Name: patient_21000 patient_21000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_21000
    ADD CONSTRAINT patient_21000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5720 (class 2606 OID 125881)
-- Name: patient_22000 patient_22000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_22000
    ADD CONSTRAINT patient_22000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5723 (class 2606 OID 125883)
-- Name: patient_23000 patient_23000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_23000
    ADD CONSTRAINT patient_23000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5726 (class 2606 OID 125885)
-- Name: patient_24000 patient_24000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_24000
    ADD CONSTRAINT patient_24000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5729 (class 2606 OID 125887)
-- Name: patient_25000 patient_25000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_25000
    ADD CONSTRAINT patient_25000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5732 (class 2606 OID 125889)
-- Name: patient_26000 patient_26000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_26000
    ADD CONSTRAINT patient_26000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5735 (class 2606 OID 125891)
-- Name: patient_27000 patient_27000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_27000
    ADD CONSTRAINT patient_27000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5738 (class 2606 OID 125893)
-- Name: patient_28000 patient_28000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_28000
    ADD CONSTRAINT patient_28000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5741 (class 2606 OID 125895)
-- Name: patient_29000 patient_29000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_29000
    ADD CONSTRAINT patient_29000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5747 (class 2606 OID 125897)
-- Name: patient_30000 patient_30000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_30000
    ADD CONSTRAINT patient_30000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5744 (class 2606 OID 125899)
-- Name: patient_3000 patient_3000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_3000
    ADD CONSTRAINT patient_3000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5750 (class 2606 OID 125901)
-- Name: patient_31000 patient_31000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_31000
    ADD CONSTRAINT patient_31000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5753 (class 2606 OID 125903)
-- Name: patient_32000 patient_32000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_32000
    ADD CONSTRAINT patient_32000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5756 (class 2606 OID 125905)
-- Name: patient_33000 patient_33000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_33000
    ADD CONSTRAINT patient_33000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5759 (class 2606 OID 125907)
-- Name: patient_34000 patient_34000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_34000
    ADD CONSTRAINT patient_34000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5762 (class 2606 OID 125909)
-- Name: patient_35000 patient_35000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_35000
    ADD CONSTRAINT patient_35000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5765 (class 2606 OID 125911)
-- Name: patient_36000 patient_36000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_36000
    ADD CONSTRAINT patient_36000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5768 (class 2606 OID 125913)
-- Name: patient_37000 patient_37000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_37000
    ADD CONSTRAINT patient_37000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5771 (class 2606 OID 125915)
-- Name: patient_38000 patient_38000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_38000
    ADD CONSTRAINT patient_38000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5774 (class 2606 OID 125917)
-- Name: patient_39000 patient_39000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_39000
    ADD CONSTRAINT patient_39000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5780 (class 2606 OID 125919)
-- Name: patient_40000 patient_40000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_40000
    ADD CONSTRAINT patient_40000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5777 (class 2606 OID 125921)
-- Name: patient_4000 patient_4000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_4000
    ADD CONSTRAINT patient_4000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5783 (class 2606 OID 125923)
-- Name: patient_41000 patient_41000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_41000
    ADD CONSTRAINT patient_41000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5786 (class 2606 OID 125925)
-- Name: patient_42000 patient_42000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_42000
    ADD CONSTRAINT patient_42000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5789 (class 2606 OID 125927)
-- Name: patient_43000 patient_43000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_43000
    ADD CONSTRAINT patient_43000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5792 (class 2606 OID 125929)
-- Name: patient_44000 patient_44000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_44000
    ADD CONSTRAINT patient_44000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5795 (class 2606 OID 125931)
-- Name: patient_45000 patient_45000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_45000
    ADD CONSTRAINT patient_45000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5798 (class 2606 OID 125933)
-- Name: patient_46000 patient_46000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_46000
    ADD CONSTRAINT patient_46000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5801 (class 2606 OID 125935)
-- Name: patient_47000 patient_47000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_47000
    ADD CONSTRAINT patient_47000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5804 (class 2606 OID 125937)
-- Name: patient_48000 patient_48000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_48000
    ADD CONSTRAINT patient_48000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5807 (class 2606 OID 125939)
-- Name: patient_49000 patient_49000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_49000
    ADD CONSTRAINT patient_49000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5813 (class 2606 OID 125941)
-- Name: patient_50000 patient_50000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_50000
    ADD CONSTRAINT patient_50000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5810 (class 2606 OID 125943)
-- Name: patient_5000 patient_5000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_5000
    ADD CONSTRAINT patient_5000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5816 (class 2606 OID 125945)
-- Name: patient_6000 patient_6000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_6000
    ADD CONSTRAINT patient_6000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5819 (class 2606 OID 125947)
-- Name: patient_7000 patient_7000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_7000
    ADD CONSTRAINT patient_7000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5822 (class 2606 OID 125949)
-- Name: patient_8000 patient_8000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_8000
    ADD CONSTRAINT patient_8000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5825 (class 2606 OID 125951)
-- Name: patient_9000 patient_9000_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_9000
    ADD CONSTRAINT patient_9000_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5827 (class 2606 OID 125953)
-- Name: patient_attribute patient_attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_attribute
    ADD CONSTRAINT patient_attribute_pkey PRIMARY KEY (id);


--
-- TOC entry 5830 (class 2606 OID 125955)
-- Name: patient_attribute_type patient_attribute_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_attribute_type
    ADD CONSTRAINT patient_attribute_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5850 (class 2606 OID 125957)
-- Name: patient_others patient_others_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_others
    ADD CONSTRAINT patient_others_pkey PRIMARY KEY (id, match_id);


--
-- TOC entry 5852 (class 2606 OID 125959)
-- Name: patient_service_identifier patient_service_identifier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier
    ADD CONSTRAINT patient_service_identifier_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5856 (class 2606 OID 125961)
-- Name: patient_service_identifier_21122008 patient_service_identifier_21122008_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122008
    ADD CONSTRAINT patient_service_identifier_21122008_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5859 (class 2606 OID 125963)
-- Name: patient_service_identifier_21122009 patient_service_identifier_21122009_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122009
    ADD CONSTRAINT patient_service_identifier_21122009_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5862 (class 2606 OID 125965)
-- Name: patient_service_identifier_21122010 patient_service_identifier_21122010_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122010
    ADD CONSTRAINT patient_service_identifier_21122010_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5865 (class 2606 OID 125967)
-- Name: patient_service_identifier_21122011 patient_service_identifier_21122011_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122011
    ADD CONSTRAINT patient_service_identifier_21122011_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5868 (class 2606 OID 125969)
-- Name: patient_service_identifier_21122012 patient_service_identifier_21122012_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122012
    ADD CONSTRAINT patient_service_identifier_21122012_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5871 (class 2606 OID 125971)
-- Name: patient_service_identifier_21122013 patient_service_identifier_21122013_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122013
    ADD CONSTRAINT patient_service_identifier_21122013_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5874 (class 2606 OID 125973)
-- Name: patient_service_identifier_21122014 patient_service_identifier_21122014_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122014
    ADD CONSTRAINT patient_service_identifier_21122014_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5877 (class 2606 OID 125975)
-- Name: patient_service_identifier_21122015 patient_service_identifier_21122015_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122015
    ADD CONSTRAINT patient_service_identifier_21122015_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5880 (class 2606 OID 125977)
-- Name: patient_service_identifier_21122016 patient_service_identifier_21122016_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122016
    ADD CONSTRAINT patient_service_identifier_21122016_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5883 (class 2606 OID 125979)
-- Name: patient_service_identifier_21122017 patient_service_identifier_21122017_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122017
    ADD CONSTRAINT patient_service_identifier_21122017_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5886 (class 2606 OID 125981)
-- Name: patient_service_identifier_21122018 patient_service_identifier_21122018_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122018
    ADD CONSTRAINT patient_service_identifier_21122018_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5889 (class 2606 OID 125983)
-- Name: patient_service_identifier_21122019 patient_service_identifier_21122019_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122019
    ADD CONSTRAINT patient_service_identifier_21122019_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5892 (class 2606 OID 125985)
-- Name: patient_service_identifier_21122020 patient_service_identifier_21122020_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122020
    ADD CONSTRAINT patient_service_identifier_21122020_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5895 (class 2606 OID 125987)
-- Name: patient_service_identifier_21122021 patient_service_identifier_21122021_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122021
    ADD CONSTRAINT patient_service_identifier_21122021_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5898 (class 2606 OID 125989)
-- Name: patient_service_identifier_21122022 patient_service_identifier_21122022_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122022
    ADD CONSTRAINT patient_service_identifier_21122022_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5901 (class 2606 OID 125991)
-- Name: patient_service_identifier_21122023 patient_service_identifier_21122023_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122023
    ADD CONSTRAINT patient_service_identifier_21122023_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5904 (class 2606 OID 125993)
-- Name: patient_service_identifier_21122024 patient_service_identifier_21122024_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122024
    ADD CONSTRAINT patient_service_identifier_21122024_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5907 (class 2606 OID 125995)
-- Name: patient_service_identifier_21122025 patient_service_identifier_21122025_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122025
    ADD CONSTRAINT patient_service_identifier_21122025_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5910 (class 2606 OID 125997)
-- Name: patient_service_identifier_21122027 patient_service_identifier_21122027_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122027
    ADD CONSTRAINT patient_service_identifier_21122027_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5913 (class 2606 OID 125999)
-- Name: patient_service_identifier_21122028 patient_service_identifier_21122028_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122028
    ADD CONSTRAINT patient_service_identifier_21122028_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5916 (class 2606 OID 126001)
-- Name: patient_service_identifier_21122029 patient_service_identifier_21122029_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122029
    ADD CONSTRAINT patient_service_identifier_21122029_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5919 (class 2606 OID 126003)
-- Name: patient_service_identifier_21122030 patient_service_identifier_21122030_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122030
    ADD CONSTRAINT patient_service_identifier_21122030_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5922 (class 2606 OID 126005)
-- Name: patient_service_identifier_21122031 patient_service_identifier_21122031_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21122031
    ADD CONSTRAINT patient_service_identifier_21122031_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5925 (class 2606 OID 126007)
-- Name: patient_service_identifier_21212026 patient_service_identifier_21212026_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_21212026
    ADD CONSTRAINT patient_service_identifier_21212026_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5928 (class 2606 OID 126009)
-- Name: patient_service_identifier_others patient_service_identifier_others_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_service_identifier_others
    ADD CONSTRAINT patient_service_identifier_others_pkey PRIMARY KEY (id, start_date);


--
-- TOC entry 5930 (class 2606 OID 126011)
-- Name: patient_trans_reference patient_trans_reference_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_trans_reference
    ADD CONSTRAINT patient_trans_reference_pkey PRIMARY KEY (id);


--
-- TOC entry 5933 (class 2606 OID 126013)
-- Name: patient_trans_reference_type patient_trans_reference_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_trans_reference_type
    ADD CONSTRAINT patient_trans_reference_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5837 (class 2606 OID 126015)
-- Name: patient_visit patient_visit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit
    ADD CONSTRAINT patient_visit_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5939 (class 2606 OID 126017)
-- Name: patient_visit_21122008 patient_visit_21122008_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122008
    ADD CONSTRAINT patient_visit_21122008_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5942 (class 2606 OID 126019)
-- Name: patient_visit_21122009 patient_visit_21122009_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122009
    ADD CONSTRAINT patient_visit_21122009_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5945 (class 2606 OID 126021)
-- Name: patient_visit_21122010 patient_visit_21122010_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122010
    ADD CONSTRAINT patient_visit_21122010_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5948 (class 2606 OID 126023)
-- Name: patient_visit_21122011 patient_visit_21122011_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122011
    ADD CONSTRAINT patient_visit_21122011_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5951 (class 2606 OID 126025)
-- Name: patient_visit_21122012 patient_visit_21122012_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122012
    ADD CONSTRAINT patient_visit_21122012_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5954 (class 2606 OID 126027)
-- Name: patient_visit_21122013 patient_visit_21122013_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122013
    ADD CONSTRAINT patient_visit_21122013_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5957 (class 2606 OID 126029)
-- Name: patient_visit_21122014 patient_visit_21122014_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122014
    ADD CONSTRAINT patient_visit_21122014_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5960 (class 2606 OID 126031)
-- Name: patient_visit_21122015 patient_visit_21122015_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122015
    ADD CONSTRAINT patient_visit_21122015_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5963 (class 2606 OID 126033)
-- Name: patient_visit_21122016 patient_visit_21122016_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122016
    ADD CONSTRAINT patient_visit_21122016_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5966 (class 2606 OID 126035)
-- Name: patient_visit_21122017 patient_visit_21122017_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122017
    ADD CONSTRAINT patient_visit_21122017_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5969 (class 2606 OID 126037)
-- Name: patient_visit_21122018 patient_visit_21122018_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122018
    ADD CONSTRAINT patient_visit_21122018_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5972 (class 2606 OID 126039)
-- Name: patient_visit_21122019 patient_visit_21122019_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122019
    ADD CONSTRAINT patient_visit_21122019_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5975 (class 2606 OID 126041)
-- Name: patient_visit_21122020 patient_visit_21122020_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122020
    ADD CONSTRAINT patient_visit_21122020_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5978 (class 2606 OID 126043)
-- Name: patient_visit_21122021 patient_visit_21122021_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122021
    ADD CONSTRAINT patient_visit_21122021_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5981 (class 2606 OID 126045)
-- Name: patient_visit_21122022 patient_visit_21122022_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122022
    ADD CONSTRAINT patient_visit_21122022_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5984 (class 2606 OID 126047)
-- Name: patient_visit_21122023 patient_visit_21122023_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122023
    ADD CONSTRAINT patient_visit_21122023_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5987 (class 2606 OID 126049)
-- Name: patient_visit_21122024 patient_visit_21122024_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122024
    ADD CONSTRAINT patient_visit_21122024_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5990 (class 2606 OID 126051)
-- Name: patient_visit_21122025 patient_visit_21122025_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122025
    ADD CONSTRAINT patient_visit_21122025_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5993 (class 2606 OID 126053)
-- Name: patient_visit_21122026 patient_visit_21122026_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122026
    ADD CONSTRAINT patient_visit_21122026_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5996 (class 2606 OID 126055)
-- Name: patient_visit_21122027 patient_visit_21122027_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122027
    ADD CONSTRAINT patient_visit_21122027_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5999 (class 2606 OID 126057)
-- Name: patient_visit_21122028 patient_visit_21122028_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122028
    ADD CONSTRAINT patient_visit_21122028_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 6002 (class 2606 OID 126059)
-- Name: patient_visit_21122029 patient_visit_21122029_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122029
    ADD CONSTRAINT patient_visit_21122029_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 6005 (class 2606 OID 126061)
-- Name: patient_visit_21122030 patient_visit_21122030_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122030
    ADD CONSTRAINT patient_visit_21122030_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 6008 (class 2606 OID 126063)
-- Name: patient_visit_21122031 patient_visit_21122031_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_21122031
    ADD CONSTRAINT patient_visit_21122031_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 5843 (class 2606 OID 126065)
-- Name: patient_visit_details patient_visit_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_details
    ADD CONSTRAINT patient_visit_details_pkey PRIMARY KEY (id);


--
-- TOC entry 6011 (class 2606 OID 126067)
-- Name: patient_visit_others patient_visit_others_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_others
    ADD CONSTRAINT patient_visit_others_pkey PRIMARY KEY (id, visit_date);


--
-- TOC entry 6013 (class 2606 OID 126069)
-- Name: patient_without_dispense_report patient_without_dispense_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_without_dispense_report
    ADD CONSTRAINT patient_without_dispense_report_pkey PRIMARY KEY (id);


--
-- TOC entry 6015 (class 2606 OID 126071)
-- Name: patients_abandonment_report patients_abandonment_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients_abandonment_report
    ADD CONSTRAINT patients_abandonment_report_pkey PRIMARY KEY (id);


--
-- TOC entry 6017 (class 2606 OID 126073)
-- Name: patients_in_semestral_dispense patients_in_semestral_dispense_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients_in_semestral_dispense
    ADD CONSTRAINT patients_in_semestral_dispense_pkey PRIMARY KEY (id);


--
-- TOC entry 6019 (class 2606 OID 126075)
-- Name: possible_patient_duplicates_report possible_patient_duplicates_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.possible_patient_duplicates_report
    ADD CONSTRAINT possible_patient_duplicates_report_pkey PRIMARY KEY (id);


--
-- TOC entry 6022 (class 2606 OID 126077)
-- Name: posto_administrativo posto_administrativo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posto_administrativo
    ADD CONSTRAINT posto_administrativo_pkey PRIMARY KEY (id);


--
-- TOC entry 6027 (class 2606 OID 126079)
-- Name: pregnancy_screening pregnancy_screening_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pregnancy_screening
    ADD CONSTRAINT pregnancy_screening_pkey PRIMARY KEY (id);


--
-- TOC entry 6030 (class 2606 OID 126081)
-- Name: prescribed_drug prescribed_drug_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescribed_drug
    ADD CONSTRAINT prescribed_drug_pkey PRIMARY KEY (id);


--
-- TOC entry 5847 (class 2606 OID 126083)
-- Name: prescription prescription_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription
    ADD CONSTRAINT prescription_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6033 (class 2606 OID 126085)
-- Name: prescription_21122008 prescription_21122008_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122008
    ADD CONSTRAINT prescription_21122008_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6036 (class 2606 OID 126087)
-- Name: prescription_21122009 prescription_21122009_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122009
    ADD CONSTRAINT prescription_21122009_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6039 (class 2606 OID 126089)
-- Name: prescription_21122010 prescription_21122010_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122010
    ADD CONSTRAINT prescription_21122010_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6042 (class 2606 OID 126091)
-- Name: prescription_21122011 prescription_21122011_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122011
    ADD CONSTRAINT prescription_21122011_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6045 (class 2606 OID 126093)
-- Name: prescription_21122012 prescription_21122012_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122012
    ADD CONSTRAINT prescription_21122012_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6048 (class 2606 OID 126095)
-- Name: prescription_21122013 prescription_21122013_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122013
    ADD CONSTRAINT prescription_21122013_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6051 (class 2606 OID 126097)
-- Name: prescription_21122014 prescription_21122014_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122014
    ADD CONSTRAINT prescription_21122014_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6054 (class 2606 OID 126099)
-- Name: prescription_21122015 prescription_21122015_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122015
    ADD CONSTRAINT prescription_21122015_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6057 (class 2606 OID 126101)
-- Name: prescription_21122016 prescription_21122016_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122016
    ADD CONSTRAINT prescription_21122016_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6060 (class 2606 OID 126103)
-- Name: prescription_21122017 prescription_21122017_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122017
    ADD CONSTRAINT prescription_21122017_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6063 (class 2606 OID 126105)
-- Name: prescription_21122018 prescription_21122018_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122018
    ADD CONSTRAINT prescription_21122018_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6066 (class 2606 OID 126107)
-- Name: prescription_21122019 prescription_21122019_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122019
    ADD CONSTRAINT prescription_21122019_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6069 (class 2606 OID 126109)
-- Name: prescription_21122020 prescription_21122020_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122020
    ADD CONSTRAINT prescription_21122020_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6072 (class 2606 OID 126111)
-- Name: prescription_21122021 prescription_21122021_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122021
    ADD CONSTRAINT prescription_21122021_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6075 (class 2606 OID 126113)
-- Name: prescription_21122022 prescription_21122022_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122022
    ADD CONSTRAINT prescription_21122022_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6078 (class 2606 OID 126115)
-- Name: prescription_21122023 prescription_21122023_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122023
    ADD CONSTRAINT prescription_21122023_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6081 (class 2606 OID 126117)
-- Name: prescription_21122024 prescription_21122024_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122024
    ADD CONSTRAINT prescription_21122024_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6084 (class 2606 OID 126119)
-- Name: prescription_21122025 prescription_21122025_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122025
    ADD CONSTRAINT prescription_21122025_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6087 (class 2606 OID 126121)
-- Name: prescription_21122026 prescription_21122026_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122026
    ADD CONSTRAINT prescription_21122026_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6090 (class 2606 OID 126123)
-- Name: prescription_21122027 prescription_21122027_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122027
    ADD CONSTRAINT prescription_21122027_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6093 (class 2606 OID 126125)
-- Name: prescription_21122028 prescription_21122028_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122028
    ADD CONSTRAINT prescription_21122028_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6096 (class 2606 OID 126127)
-- Name: prescription_21122029 prescription_21122029_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122029
    ADD CONSTRAINT prescription_21122029_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6099 (class 2606 OID 126129)
-- Name: prescription_21122030 prescription_21122030_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122030
    ADD CONSTRAINT prescription_21122030_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6102 (class 2606 OID 126131)
-- Name: prescription_21122031 prescription_21122031_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_21122031
    ADD CONSTRAINT prescription_21122031_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6105 (class 2606 OID 126133)
-- Name: prescription_detail prescription_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_detail
    ADD CONSTRAINT prescription_detail_pkey PRIMARY KEY (id);


--
-- TOC entry 6108 (class 2606 OID 126135)
-- Name: prescription_others prescription_others_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_others
    ADD CONSTRAINT prescription_others_pkey PRIMARY KEY (id, prescription_date);


--
-- TOC entry 6111 (class 2606 OID 126137)
-- Name: province province_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.province
    ADD CONSTRAINT province_pkey PRIMARY KEY (id);


--
-- TOC entry 6116 (class 2606 OID 126139)
-- Name: provincial_server provincial_server_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provincial_server
    ADD CONSTRAINT provincial_server_pkey PRIMARY KEY (id);


--
-- TOC entry 6121 (class 2606 OID 126141)
-- Name: ramscreening ramscreening_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ramscreening
    ADD CONSTRAINT ramscreening_pkey PRIMARY KEY (id);


--
-- TOC entry 5244 (class 2606 OID 126143)
-- Name: refered_stock_moviment refered_stock_moviment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refered_stock_moviment
    ADD CONSTRAINT refered_stock_moviment_pkey PRIMARY KEY (id);


--
-- TOC entry 6123 (class 2606 OID 126145)
-- Name: referred_patients_report referred_patients_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referred_patients_report
    ADD CONSTRAINT referred_patients_report_pkey PRIMARY KEY (id);


--
-- TOC entry 6125 (class 2606 OID 126147)
-- Name: registered_in_idmed_report registered_in_idmed_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registered_in_idmed_report
    ADD CONSTRAINT registered_in_idmed_report_pkey PRIMARY KEY (id);


--
-- TOC entry 6127 (class 2606 OID 126149)
-- Name: report_process_monitor report_process_monitor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.report_process_monitor
    ADD CONSTRAINT report_process_monitor_pkey PRIMARY KEY (id);


--
-- TOC entry 6129 (class 2606 OID 126151)
-- Name: requestmap requestmap_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requestmap
    ADD CONSTRAINT requestmap_pkey PRIMARY KEY (id);


--
-- TOC entry 6141 (class 2606 OID 126153)
-- Name: role_menu role_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_menu
    ADD CONSTRAINT role_menu_pkey PRIMARY KEY (roles_id, menus_id);


--
-- TOC entry 6133 (class 2606 OID 126155)
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- TOC entry 6144 (class 2606 OID 126157)
-- Name: sec_user sec_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sec_user
    ADD CONSTRAINT sec_user_pkey PRIMARY KEY (id);


--
-- TOC entry 6148 (class 2606 OID 126159)
-- Name: sec_user_role sec_user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sec_user_role
    ADD CONSTRAINT sec_user_role_pkey PRIMARY KEY (sec_user_id, role_id);


--
-- TOC entry 6150 (class 2606 OID 126161)
-- Name: segundas_linhas_report segundas_linhas_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.segundas_linhas_report
    ADD CONSTRAINT segundas_linhas_report_pkey PRIMARY KEY (id);


--
-- TOC entry 6152 (class 2606 OID 126163)
-- Name: service_patient service_patient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_patient
    ADD CONSTRAINT service_patient_pkey PRIMARY KEY (id);


--
-- TOC entry 6155 (class 2606 OID 126165)
-- Name: spetial_prescription_motive spetial_prescription_motive_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spetial_prescription_motive
    ADD CONSTRAINT spetial_prescription_motive_pkey PRIMARY KEY (id);


--
-- TOC entry 6160 (class 2606 OID 126167)
-- Name: start_stop_reason start_stop_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.start_stop_reason
    ADD CONSTRAINT start_stop_reason_pkey PRIMARY KEY (id);


--
-- TOC entry 5250 (class 2606 OID 126169)
-- Name: stock_adjustment stock_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_adjustment
    ADD CONSTRAINT stock_adjustment_pkey PRIMARY KEY (id);


--
-- TOC entry 6165 (class 2606 OID 126171)
-- Name: stock_center stock_center_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_center
    ADD CONSTRAINT stock_center_pkey PRIMARY KEY (id);


--
-- TOC entry 6171 (class 2606 OID 126173)
-- Name: stock_distributor_batch stock_distributor_batch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_distributor_batch
    ADD CONSTRAINT stock_distributor_batch_pkey PRIMARY KEY (id);


--
-- TOC entry 6169 (class 2606 OID 126175)
-- Name: stock_distributor stock_distributor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_distributor
    ADD CONSTRAINT stock_distributor_pkey PRIMARY KEY (id);


--
-- TOC entry 5253 (class 2606 OID 126177)
-- Name: stock_entrance stock_entrance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_entrance
    ADD CONSTRAINT stock_entrance_pkey PRIMARY KEY (id);


--
-- TOC entry 6174 (class 2606 OID 126179)
-- Name: stock_level stock_level_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_level
    ADD CONSTRAINT stock_level_pkey PRIMARY KEY (id);


--
-- TOC entry 5258 (class 2606 OID 126181)
-- Name: stock_operation_type stock_operation_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_operation_type
    ADD CONSTRAINT stock_operation_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5247 (class 2606 OID 126183)
-- Name: stock stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_pkey PRIMARY KEY (id);


--
-- TOC entry 6176 (class 2606 OID 126185)
-- Name: stock_report_temp stock_report_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_report_temp
    ADD CONSTRAINT stock_report_temp_pkey PRIMARY KEY (id);


--
-- TOC entry 6179 (class 2606 OID 126187)
-- Name: system_configs system_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_configs
    ADD CONSTRAINT system_configs_pkey PRIMARY KEY (id);


--
-- TOC entry 6184 (class 2606 OID 126189)
-- Name: tbscreening tbscreening_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbscreening
    ADD CONSTRAINT tbscreening_pkey PRIMARY KEY (id);


--
-- TOC entry 6187 (class 2606 OID 126191)
-- Name: therapeutic_line therapeutic_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.therapeutic_line
    ADD CONSTRAINT therapeutic_line_pkey PRIMARY KEY (id);


--
-- TOC entry 6194 (class 2606 OID 126193)
-- Name: therapeutic_regimen_clinical_services therapeutic_regimen_clinical_services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.therapeutic_regimen_clinical_services
    ADD CONSTRAINT therapeutic_regimen_clinical_services_pkey PRIMARY KEY (therapeutic_regimen_id, clinical_service_id);


--
-- TOC entry 6196 (class 2606 OID 126195)
-- Name: therapeutic_regimen_drugs therapeutic_regimen_drugs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.therapeutic_regimen_drugs
    ADD CONSTRAINT therapeutic_regimen_drugs_pkey PRIMARY KEY (therapeutic_regimen_id, drug_id);


--
-- TOC entry 6192 (class 2606 OID 126197)
-- Name: therapeutic_regimen therapeutic_regimen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.therapeutic_regimen
    ADD CONSTRAINT therapeutic_regimen_pkey PRIMARY KEY (id);


--
-- TOC entry 5590 (class 2606 OID 126199)
-- Name: national_clinic uk38228fa17427e137293edf8ef342; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.national_clinic
    ADD CONSTRAINT uk38228fa17427e137293edf8ef342 UNIQUE (province_id, facility_name);


--
-- TOC entry 5368 (class 2606 OID 126201)
-- Name: group_member uk391f7e60385b2ac7e5662b112766; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT uk391f7e60385b2ac7e5662b112766 UNIQUE (end_date, group_id, patient_id);


--
-- TOC entry 6131 (class 2606 OID 126203)
-- Name: requestmap uk3d11b687954e6645e90db4e23cb4; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requestmap
    ADD CONSTRAINT uk3d11b687954e6645e90db4e23cb4 UNIQUE (http_method, url);


--
-- TOC entry 5255 (class 2606 OID 126205)
-- Name: stock_entrance uk774f32e7bd7cfe3a2b585431d930; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_entrance
    ADD CONSTRAINT uk774f32e7bd7cfe3a2b585431d930 UNIQUE (clinic_id, date_received, order_number);


--
-- TOC entry 5218 (class 2606 OID 126207)
-- Name: district uk81b35a11253eb55a8d778444f996; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.district
    ADD CONSTRAINT uk81b35a11253eb55a8d778444f996 UNIQUE (province_id, code);


--
-- TOC entry 5169 (class 2606 OID 126209)
-- Name: clinic uk_2j5tyt28hsc67byvwgxq1y9ty; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic
    ADD CONSTRAINT uk_2j5tyt28hsc67byvwgxq1y9ty UNIQUE (uuid);


--
-- TOC entry 6135 (class 2606 OID 126211)
-- Name: role uk_2tysw6t5feqb631yj4kdk99i5; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT uk_2tysw6t5feqb631yj4kdk99i5 UNIQUE (description);


--
-- TOC entry 5577 (class 2606 OID 126213)
-- Name: migration_stage uk_32yul4bib5gb8hl732afimpfp; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_stage
    ADD CONSTRAINT uk_32yul4bib5gb8hl732afimpfp UNIQUE (code);


--
-- TOC entry 5382 (class 2606 OID 126215)
-- Name: group_type uk_43tbcsxkoa0n3icynns9c3weh; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_type
    ADD CONSTRAINT uk_43tbcsxkoa0n3icynns9c3weh UNIQUE (code);


--
-- TOC entry 5198 (class 2606 OID 126217)
-- Name: clinical_service_attribute_type uk_4actpgjmie353fk016lo347vj; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_attribute_type
    ADD CONSTRAINT uk_4actpgjmie353fk016lo347vj UNIQUE (code);


--
-- TOC entry 6146 (class 2606 OID 126219)
-- Name: sec_user uk_5ctbdrlf3eismye20vsdtk8w8; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sec_user
    ADD CONSTRAINT uk_5ctbdrlf3eismye20vsdtk8w8 UNIQUE (username);


--
-- TOC entry 5833 (class 2606 OID 126221)
-- Name: patient_attribute_type uk_5su1ejdranyeccvlaams1guaq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_attribute_type
    ADD CONSTRAINT uk_5su1ejdranyeccvlaams1guaq UNIQUE (name);


--
-- TOC entry 5394 (class 2606 OID 126223)
-- Name: identifier_type uk_660hl2y1espc6pqmifwd0tquq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.identifier_type
    ADD CONSTRAINT uk_660hl2y1espc6pqmifwd0tquq UNIQUE (code);


--
-- TOC entry 6113 (class 2606 OID 126225)
-- Name: province uk_6k05k4x3elbtlqxrmsuere05q; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.province
    ADD CONSTRAINT uk_6k05k4x3elbtlqxrmsuere05q UNIQUE (code);


--
-- TOC entry 5835 (class 2606 OID 126227)
-- Name: patient_attribute_type uk_6wu2a4eqloljxame2tvbffp9o; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_attribute_type
    ADD CONSTRAINT uk_6wu2a4eqloljxame2tvbffp9o UNIQUE (code);


--
-- TOC entry 6137 (class 2606 OID 126229)
-- Name: role uk_8sewwnpamngi6b1dwaa88askk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT uk_8sewwnpamngi6b1dwaa88askk UNIQUE (name);


--
-- TOC entry 6189 (class 2606 OID 126231)
-- Name: therapeutic_line uk_9jaa0sdx22vupy6kfv6glqeg7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.therapeutic_line
    ADD CONSTRAINT uk_9jaa0sdx22vupy6kfv6glqeg7 UNIQUE (code);


--
-- TOC entry 6024 (class 2606 OID 126233)
-- Name: posto_administrativo uk_a52fewstik4rwlw3fbu6v5th1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posto_administrativo
    ADD CONSTRAINT uk_a52fewstik4rwlw3fbu6v5th1 UNIQUE (code);


--
-- TOC entry 5417 (class 2606 OID 126235)
-- Name: menu uk_b7as01rf085qmbog39pictwrw; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu
    ADD CONSTRAINT uk_b7as01rf085qmbog39pictwrw UNIQUE (code);


--
-- TOC entry 6167 (class 2606 OID 126237)
-- Name: stock_center uk_btbbcitbooofqwbm4m54ibpt9; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_center
    ADD CONSTRAINT uk_btbbcitbooofqwbm4m54ibpt9 UNIQUE (code);


--
-- TOC entry 5419 (class 2606 OID 126239)
-- Name: menu uk_cb7pnajg0w0ruv3bfnu25h0h4; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu
    ADD CONSTRAINT uk_cb7pnajg0w0ruv3bfnu25h0h4 UNIQUE (description);


--
-- TOC entry 5402 (class 2606 OID 126241)
-- Name: interoperability_type uk_cpet7qiskhq9hwd33oxpxa74a; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interoperability_type
    ADD CONSTRAINT uk_cpet7qiskhq9hwd33oxpxa74a UNIQUE (code);


--
-- TOC entry 5353 (class 2606 OID 126243)
-- Name: facility_type uk_dw8fqu6vcmx9asdj7hhnyqlnc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_type
    ADD CONSTRAINT uk_dw8fqu6vcmx9asdj7hhnyqlnc UNIQUE (code);


--
-- TOC entry 5213 (class 2606 OID 126245)
-- Name: dispense_type uk_dymyatqkatp8t1j1kqsu0d9ko; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispense_type
    ADD CONSTRAINT uk_dymyatqkatp8t1j1kqsu0d9ko UNIQUE (code);


--
-- TOC entry 5358 (class 2606 OID 126247)
-- Name: form uk_ffy1tngx9fis6kmqn5c5qvhb0; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form
    ADD CONSTRAINT uk_ffy1tngx9fis6kmqn5c5qvhb0 UNIQUE (code);


--
-- TOC entry 6181 (class 2606 OID 126249)
-- Name: system_configs uk_gevsjtyo6clvtg42blge6dfpu; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_configs
    ADD CONSTRAINT uk_gevsjtyo6clvtg42blge6dfpu UNIQUE (key);


--
-- TOC entry 5175 (class 2606 OID 126251)
-- Name: clinic_sector uk_hyt5bdpj308x2bs2ykc9pnjr5; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic_sector
    ADD CONSTRAINT uk_hyt5bdpj308x2bs2ykc9pnjr5 UNIQUE (uuid);


--
-- TOC entry 5346 (class 2606 OID 126253)
-- Name: episode_type uk_i1l9kt62hbq36ybu9gt3iiiav; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.episode_type
    ADD CONSTRAINT uk_i1l9kt62hbq36ybu9gt3iiiav UNIQUE (code);


--
-- TOC entry 5260 (class 2606 OID 126255)
-- Name: stock_operation_type uk_if3i79dnpedbjf23b9ypbl57d; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_operation_type
    ADD CONSTRAINT uk_if3i79dnpedbjf23b9ypbl57d UNIQUE (code);


--
-- TOC entry 5387 (class 2606 OID 126257)
-- Name: health_information_system uk_ilco9yng4d2kl1a7fwd70ivbu; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_information_system
    ADD CONSTRAINT uk_ilco9yng4d2kl1a7fwd70ivbu UNIQUE (abbreviation);


--
-- TOC entry 6157 (class 2606 OID 126259)
-- Name: spetial_prescription_motive uk_iriqtxr88cbcopyw70fjcl2nd; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spetial_prescription_motive
    ADD CONSTRAINT uk_iriqtxr88cbcopyw70fjcl2nd UNIQUE (code);


--
-- TOC entry 6139 (class 2606 OID 126261)
-- Name: role uk_irsamgnera6angm0prq1kemt2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT uk_irsamgnera6angm0prq1kemt2 UNIQUE (authority);


--
-- TOC entry 5191 (class 2606 OID 126263)
-- Name: clinical_service uk_isvk13w0bqfx9eny5cuc7ynx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service
    ADD CONSTRAINT uk_isvk13w0bqfx9eny5cuc7ynx UNIQUE (code);


--
-- TOC entry 5182 (class 2606 OID 126265)
-- Name: clinic_sector_type uk_kc2fdywno22oj8lawmdelcqrh; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic_sector_type
    ADD CONSTRAINT uk_kc2fdywno22oj8lawmdelcqrh UNIQUE (code);


--
-- TOC entry 5177 (class 2606 OID 126267)
-- Name: clinic_sector uk_kv1q1c7k7rf54xxo7ufiq20dd; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic_sector
    ADD CONSTRAINT uk_kv1q1c7k7rf54xxo7ufiq20dd UNIQUE (code);


--
-- TOC entry 5592 (class 2606 OID 126269)
-- Name: national_clinic uk_nlk3o4i9vl79lv3a4bdfkbem4; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.national_clinic
    ADD CONSTRAINT uk_nlk3o4i9vl79lv3a4bdfkbem4 UNIQUE (code);


--
-- TOC entry 5413 (class 2606 OID 126271)
-- Name: localidade uk_nyayq5hle26ddva1cd3ko89p9; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localidade
    ADD CONSTRAINT uk_nyayq5hle26ddva1cd3ko89p9 UNIQUE (code);


--
-- TOC entry 5363 (class 2606 OID 126273)
-- Name: group_info uk_ow92eiebqill0kw2cs9mvf9ks; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_info
    ADD CONSTRAINT uk_ow92eiebqill0kw2cs9mvf9ks UNIQUE (code);


--
-- TOC entry 6162 (class 2606 OID 126275)
-- Name: start_stop_reason uk_qjxc5equ9078aum4mvrm8up6f; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.start_stop_reason
    ADD CONSTRAINT uk_qjxc5equ9078aum4mvrm8up6f UNIQUE (reason);


--
-- TOC entry 5936 (class 2606 OID 126277)
-- Name: patient_trans_reference_type uk_qn4q16maylmmtkcwtwa4lgu44; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_trans_reference_type
    ADD CONSTRAINT uk_qn4q16maylmmtkcwtwa4lgu44 UNIQUE (code);


--
-- TOC entry 6118 (class 2606 OID 126279)
-- Name: provincial_server ukc853247641ca6546807af827d6cc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provincial_server
    ADD CONSTRAINT ukc853247641ca6546807af827d6cc UNIQUE (destination, code);


--
-- TOC entry 5171 (class 2606 OID 126281)
-- Name: clinic ukdf9327f8beb951bb03e42c2bde2a; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic
    ADD CONSTRAINT ukdf9327f8beb951bb03e42c2bde2a UNIQUE (district_id, province_id, clinic_name);


--
-- TOC entry 6198 (class 2606 OID 126283)
-- Name: used_stock_report_temp used_stock_report_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.used_stock_report_temp
    ADD CONSTRAINT used_stock_report_temp_pkey PRIMARY KEY (id);


--
-- TOC entry 5841 (class 2606 OID 126285)
-- Name: vital_signs_screening vital_signs_screening_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vital_signs_screening
    ADD CONSTRAINT vital_signs_screening_pkey PRIMARY KEY (id);


--
-- TOC entry 5266 (class 1259 OID 126286)
-- Name: pk_episode_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_episode_idx ON ONLY public.episode USING btree (id, episode_date);


--
-- TOC entry 5267 (class 1259 OID 126287)
-- Name: episode_21122008_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122008_id_episode_date_idx ON public.episode_21122008 USING btree (id, episode_date);


--
-- TOC entry 5270 (class 1259 OID 126288)
-- Name: episode_21122009_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122009_id_episode_date_idx ON public.episode_21122009 USING btree (id, episode_date);


--
-- TOC entry 5273 (class 1259 OID 126289)
-- Name: episode_21122010_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122010_id_episode_date_idx ON public.episode_21122010 USING btree (id, episode_date);


--
-- TOC entry 5276 (class 1259 OID 126290)
-- Name: episode_21122011_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122011_id_episode_date_idx ON public.episode_21122011 USING btree (id, episode_date);


--
-- TOC entry 5279 (class 1259 OID 126291)
-- Name: episode_21122012_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122012_id_episode_date_idx ON public.episode_21122012 USING btree (id, episode_date);


--
-- TOC entry 5282 (class 1259 OID 126292)
-- Name: episode_21122013_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122013_id_episode_date_idx ON public.episode_21122013 USING btree (id, episode_date);


--
-- TOC entry 5285 (class 1259 OID 126293)
-- Name: episode_21122014_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122014_id_episode_date_idx ON public.episode_21122014 USING btree (id, episode_date);


--
-- TOC entry 5288 (class 1259 OID 126294)
-- Name: episode_21122015_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122015_id_episode_date_idx ON public.episode_21122015 USING btree (id, episode_date);


--
-- TOC entry 5291 (class 1259 OID 126295)
-- Name: episode_21122016_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122016_id_episode_date_idx ON public.episode_21122016 USING btree (id, episode_date);


--
-- TOC entry 5294 (class 1259 OID 126296)
-- Name: episode_21122017_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122017_id_episode_date_idx ON public.episode_21122017 USING btree (id, episode_date);


--
-- TOC entry 5297 (class 1259 OID 126297)
-- Name: episode_21122018_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122018_id_episode_date_idx ON public.episode_21122018 USING btree (id, episode_date);


--
-- TOC entry 5300 (class 1259 OID 126298)
-- Name: episode_21122019_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122019_id_episode_date_idx ON public.episode_21122019 USING btree (id, episode_date);


--
-- TOC entry 5303 (class 1259 OID 126299)
-- Name: episode_21122020_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122020_id_episode_date_idx ON public.episode_21122020 USING btree (id, episode_date);


--
-- TOC entry 5306 (class 1259 OID 126300)
-- Name: episode_21122021_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122021_id_episode_date_idx ON public.episode_21122021 USING btree (id, episode_date);


--
-- TOC entry 5309 (class 1259 OID 126301)
-- Name: episode_21122022_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122022_id_episode_date_idx ON public.episode_21122022 USING btree (id, episode_date);


--
-- TOC entry 5312 (class 1259 OID 126302)
-- Name: episode_21122023_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122023_id_episode_date_idx ON public.episode_21122023 USING btree (id, episode_date);


--
-- TOC entry 5315 (class 1259 OID 126303)
-- Name: episode_21122024_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122024_id_episode_date_idx ON public.episode_21122024 USING btree (id, episode_date);


--
-- TOC entry 5318 (class 1259 OID 126304)
-- Name: episode_21122025_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122025_id_episode_date_idx ON public.episode_21122025 USING btree (id, episode_date);


--
-- TOC entry 5321 (class 1259 OID 126305)
-- Name: episode_21122026_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122026_id_episode_date_idx ON public.episode_21122026 USING btree (id, episode_date);


--
-- TOC entry 5324 (class 1259 OID 126306)
-- Name: episode_21122027_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122027_id_episode_date_idx ON public.episode_21122027 USING btree (id, episode_date);


--
-- TOC entry 5327 (class 1259 OID 126307)
-- Name: episode_21122028_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122028_id_episode_date_idx ON public.episode_21122028 USING btree (id, episode_date);


--
-- TOC entry 5330 (class 1259 OID 126308)
-- Name: episode_21122029_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122029_id_episode_date_idx ON public.episode_21122029 USING btree (id, episode_date);


--
-- TOC entry 5333 (class 1259 OID 126309)
-- Name: episode_21122030_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122030_id_episode_date_idx ON public.episode_21122030 USING btree (id, episode_date);


--
-- TOC entry 5336 (class 1259 OID 126310)
-- Name: episode_21122031_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_21122031_id_episode_date_idx ON public.episode_21122031 USING btree (id, episode_date);


--
-- TOC entry 5339 (class 1259 OID 126311)
-- Name: episode_others_id_episode_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX episode_others_id_episode_date_idx ON public.episode_others USING btree (id, episode_date);


--
-- TOC entry 5422 (class 1259 OID 126312)
-- Name: pk_migration_log_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_migration_log_idx ON ONLY public.migration_log USING btree (id, source_id);


--
-- TOC entry 5423 (class 1259 OID 126313)
-- Name: migration_log_000_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_000_id_source_id_idx ON public.migration_log_000 USING btree (id, source_id);


--
-- TOC entry 5426 (class 1259 OID 126314)
-- Name: migration_log_001_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_001_id_source_id_idx ON public.migration_log_001 USING btree (id, source_id);


--
-- TOC entry 5429 (class 1259 OID 126315)
-- Name: migration_log_002_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_002_id_source_id_idx ON public.migration_log_002 USING btree (id, source_id);


--
-- TOC entry 5432 (class 1259 OID 126316)
-- Name: migration_log_003_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_003_id_source_id_idx ON public.migration_log_003 USING btree (id, source_id);


--
-- TOC entry 5435 (class 1259 OID 126317)
-- Name: migration_log_004_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_004_id_source_id_idx ON public.migration_log_004 USING btree (id, source_id);


--
-- TOC entry 5438 (class 1259 OID 126318)
-- Name: migration_log_005_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_005_id_source_id_idx ON public.migration_log_005 USING btree (id, source_id);


--
-- TOC entry 5441 (class 1259 OID 126319)
-- Name: migration_log_006_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_006_id_source_id_idx ON public.migration_log_006 USING btree (id, source_id);


--
-- TOC entry 5444 (class 1259 OID 126320)
-- Name: migration_log_007_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_007_id_source_id_idx ON public.migration_log_007 USING btree (id, source_id);


--
-- TOC entry 5447 (class 1259 OID 126321)
-- Name: migration_log_008_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_008_id_source_id_idx ON public.migration_log_008 USING btree (id, source_id);


--
-- TOC entry 5450 (class 1259 OID 126322)
-- Name: migration_log_009_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_009_id_source_id_idx ON public.migration_log_009 USING btree (id, source_id);


--
-- TOC entry 5453 (class 1259 OID 126323)
-- Name: migration_log_010_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_010_id_source_id_idx ON public.migration_log_010 USING btree (id, source_id);


--
-- TOC entry 5456 (class 1259 OID 126324)
-- Name: migration_log_011_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_011_id_source_id_idx ON public.migration_log_011 USING btree (id, source_id);


--
-- TOC entry 5459 (class 1259 OID 126325)
-- Name: migration_log_012_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_012_id_source_id_idx ON public.migration_log_012 USING btree (id, source_id);


--
-- TOC entry 5462 (class 1259 OID 126326)
-- Name: migration_log_013_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_013_id_source_id_idx ON public.migration_log_013 USING btree (id, source_id);


--
-- TOC entry 5465 (class 1259 OID 126327)
-- Name: migration_log_014_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_014_id_source_id_idx ON public.migration_log_014 USING btree (id, source_id);


--
-- TOC entry 5468 (class 1259 OID 126328)
-- Name: migration_log_015_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_015_id_source_id_idx ON public.migration_log_015 USING btree (id, source_id);


--
-- TOC entry 5471 (class 1259 OID 126329)
-- Name: migration_log_016_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_016_id_source_id_idx ON public.migration_log_016 USING btree (id, source_id);


--
-- TOC entry 5474 (class 1259 OID 126330)
-- Name: migration_log_017_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_017_id_source_id_idx ON public.migration_log_017 USING btree (id, source_id);


--
-- TOC entry 5477 (class 1259 OID 126331)
-- Name: migration_log_018_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_018_id_source_id_idx ON public.migration_log_018 USING btree (id, source_id);


--
-- TOC entry 5480 (class 1259 OID 126332)
-- Name: migration_log_019_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_019_id_source_id_idx ON public.migration_log_019 USING btree (id, source_id);


--
-- TOC entry 5483 (class 1259 OID 126333)
-- Name: migration_log_020_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_020_id_source_id_idx ON public.migration_log_020 USING btree (id, source_id);


--
-- TOC entry 5486 (class 1259 OID 126334)
-- Name: migration_log_021_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_021_id_source_id_idx ON public.migration_log_021 USING btree (id, source_id);


--
-- TOC entry 5489 (class 1259 OID 126335)
-- Name: migration_log_022_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_022_id_source_id_idx ON public.migration_log_022 USING btree (id, source_id);


--
-- TOC entry 5492 (class 1259 OID 126336)
-- Name: migration_log_023_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_023_id_source_id_idx ON public.migration_log_023 USING btree (id, source_id);


--
-- TOC entry 5495 (class 1259 OID 126337)
-- Name: migration_log_024_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_024_id_source_id_idx ON public.migration_log_024 USING btree (id, source_id);


--
-- TOC entry 5498 (class 1259 OID 126338)
-- Name: migration_log_025_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_025_id_source_id_idx ON public.migration_log_025 USING btree (id, source_id);


--
-- TOC entry 5501 (class 1259 OID 126339)
-- Name: migration_log_026_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_026_id_source_id_idx ON public.migration_log_026 USING btree (id, source_id);


--
-- TOC entry 5504 (class 1259 OID 126340)
-- Name: migration_log_027_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_027_id_source_id_idx ON public.migration_log_027 USING btree (id, source_id);


--
-- TOC entry 5507 (class 1259 OID 126341)
-- Name: migration_log_028_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_028_id_source_id_idx ON public.migration_log_028 USING btree (id, source_id);


--
-- TOC entry 5510 (class 1259 OID 126342)
-- Name: migration_log_029_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_029_id_source_id_idx ON public.migration_log_029 USING btree (id, source_id);


--
-- TOC entry 5513 (class 1259 OID 126343)
-- Name: migration_log_030_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_030_id_source_id_idx ON public.migration_log_030 USING btree (id, source_id);


--
-- TOC entry 5516 (class 1259 OID 126344)
-- Name: migration_log_031_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_031_id_source_id_idx ON public.migration_log_031 USING btree (id, source_id);


--
-- TOC entry 5519 (class 1259 OID 126345)
-- Name: migration_log_032_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_032_id_source_id_idx ON public.migration_log_032 USING btree (id, source_id);


--
-- TOC entry 5522 (class 1259 OID 126346)
-- Name: migration_log_033_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_033_id_source_id_idx ON public.migration_log_033 USING btree (id, source_id);


--
-- TOC entry 5525 (class 1259 OID 126347)
-- Name: migration_log_034_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_034_id_source_id_idx ON public.migration_log_034 USING btree (id, source_id);


--
-- TOC entry 5528 (class 1259 OID 126348)
-- Name: migration_log_035_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_035_id_source_id_idx ON public.migration_log_035 USING btree (id, source_id);


--
-- TOC entry 5531 (class 1259 OID 126349)
-- Name: migration_log_036_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_036_id_source_id_idx ON public.migration_log_036 USING btree (id, source_id);


--
-- TOC entry 5534 (class 1259 OID 126350)
-- Name: migration_log_037_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_037_id_source_id_idx ON public.migration_log_037 USING btree (id, source_id);


--
-- TOC entry 5537 (class 1259 OID 126351)
-- Name: migration_log_038_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_038_id_source_id_idx ON public.migration_log_038 USING btree (id, source_id);


--
-- TOC entry 5540 (class 1259 OID 126352)
-- Name: migration_log_039_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_039_id_source_id_idx ON public.migration_log_039 USING btree (id, source_id);


--
-- TOC entry 5543 (class 1259 OID 126353)
-- Name: migration_log_040_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_040_id_source_id_idx ON public.migration_log_040 USING btree (id, source_id);


--
-- TOC entry 5546 (class 1259 OID 126354)
-- Name: migration_log_041_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_041_id_source_id_idx ON public.migration_log_041 USING btree (id, source_id);


--
-- TOC entry 5549 (class 1259 OID 126355)
-- Name: migration_log_042_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_042_id_source_id_idx ON public.migration_log_042 USING btree (id, source_id);


--
-- TOC entry 5552 (class 1259 OID 126356)
-- Name: migration_log_043_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_043_id_source_id_idx ON public.migration_log_043 USING btree (id, source_id);


--
-- TOC entry 5555 (class 1259 OID 126357)
-- Name: migration_log_044_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_044_id_source_id_idx ON public.migration_log_044 USING btree (id, source_id);


--
-- TOC entry 5558 (class 1259 OID 126358)
-- Name: migration_log_045_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_045_id_source_id_idx ON public.migration_log_045 USING btree (id, source_id);


--
-- TOC entry 5561 (class 1259 OID 126359)
-- Name: migration_log_046_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_046_id_source_id_idx ON public.migration_log_046 USING btree (id, source_id);


--
-- TOC entry 5564 (class 1259 OID 126360)
-- Name: migration_log_047_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_047_id_source_id_idx ON public.migration_log_047 USING btree (id, source_id);


--
-- TOC entry 5567 (class 1259 OID 126361)
-- Name: migration_log_048_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_048_id_source_id_idx ON public.migration_log_048 USING btree (id, source_id);


--
-- TOC entry 5570 (class 1259 OID 126362)
-- Name: migration_log_049_id_source_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX migration_log_049_id_source_id_idx ON public.migration_log_049 USING btree (id, source_id);


--
-- TOC entry 5235 (class 1259 OID 126363)
-- Name: pk_pack_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_pack_idx ON ONLY public.pack USING btree (id, pickup_date);


--
-- TOC entry 5598 (class 1259 OID 126364)
-- Name: pack_21122008_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122008_id_pickup_date_idx ON public.pack_21122008 USING btree (id, pickup_date);


--
-- TOC entry 5601 (class 1259 OID 126365)
-- Name: pack_21122009_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122009_id_pickup_date_idx ON public.pack_21122009 USING btree (id, pickup_date);


--
-- TOC entry 5604 (class 1259 OID 126366)
-- Name: pack_21122010_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122010_id_pickup_date_idx ON public.pack_21122010 USING btree (id, pickup_date);


--
-- TOC entry 5607 (class 1259 OID 126367)
-- Name: pack_21122011_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122011_id_pickup_date_idx ON public.pack_21122011 USING btree (id, pickup_date);


--
-- TOC entry 5610 (class 1259 OID 126368)
-- Name: pack_21122012_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122012_id_pickup_date_idx ON public.pack_21122012 USING btree (id, pickup_date);


--
-- TOC entry 5613 (class 1259 OID 126369)
-- Name: pack_21122013_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122013_id_pickup_date_idx ON public.pack_21122013 USING btree (id, pickup_date);


--
-- TOC entry 5616 (class 1259 OID 126370)
-- Name: pack_21122014_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122014_id_pickup_date_idx ON public.pack_21122014 USING btree (id, pickup_date);


--
-- TOC entry 5619 (class 1259 OID 126371)
-- Name: pack_21122015_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122015_id_pickup_date_idx ON public.pack_21122015 USING btree (id, pickup_date);


--
-- TOC entry 5622 (class 1259 OID 126372)
-- Name: pack_21122016_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122016_id_pickup_date_idx ON public.pack_21122016 USING btree (id, pickup_date);


--
-- TOC entry 5625 (class 1259 OID 126373)
-- Name: pack_21122017_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122017_id_pickup_date_idx ON public.pack_21122017 USING btree (id, pickup_date);


--
-- TOC entry 5628 (class 1259 OID 126374)
-- Name: pack_21122018_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122018_id_pickup_date_idx ON public.pack_21122018 USING btree (id, pickup_date);


--
-- TOC entry 5631 (class 1259 OID 126375)
-- Name: pack_21122019_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122019_id_pickup_date_idx ON public.pack_21122019 USING btree (id, pickup_date);


--
-- TOC entry 5634 (class 1259 OID 126376)
-- Name: pack_21122020_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122020_id_pickup_date_idx ON public.pack_21122020 USING btree (id, pickup_date);


--
-- TOC entry 5637 (class 1259 OID 126377)
-- Name: pack_21122021_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122021_id_pickup_date_idx ON public.pack_21122021 USING btree (id, pickup_date);


--
-- TOC entry 5640 (class 1259 OID 126378)
-- Name: pack_21122022_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122022_id_pickup_date_idx ON public.pack_21122022 USING btree (id, pickup_date);


--
-- TOC entry 5643 (class 1259 OID 126379)
-- Name: pack_21122023_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122023_id_pickup_date_idx ON public.pack_21122023 USING btree (id, pickup_date);


--
-- TOC entry 5646 (class 1259 OID 126380)
-- Name: pack_21122024_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122024_id_pickup_date_idx ON public.pack_21122024 USING btree (id, pickup_date);


--
-- TOC entry 5649 (class 1259 OID 126381)
-- Name: pack_21122025_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122025_id_pickup_date_idx ON public.pack_21122025 USING btree (id, pickup_date);


--
-- TOC entry 5652 (class 1259 OID 126382)
-- Name: pack_21122026_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122026_id_pickup_date_idx ON public.pack_21122026 USING btree (id, pickup_date);


--
-- TOC entry 5655 (class 1259 OID 126383)
-- Name: pack_21122027_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122027_id_pickup_date_idx ON public.pack_21122027 USING btree (id, pickup_date);


--
-- TOC entry 5658 (class 1259 OID 126384)
-- Name: pack_21122028_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122028_id_pickup_date_idx ON public.pack_21122028 USING btree (id, pickup_date);


--
-- TOC entry 5661 (class 1259 OID 126385)
-- Name: pack_21122029_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122029_id_pickup_date_idx ON public.pack_21122029 USING btree (id, pickup_date);


--
-- TOC entry 5664 (class 1259 OID 126386)
-- Name: pack_21122030_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122030_id_pickup_date_idx ON public.pack_21122030 USING btree (id, pickup_date);


--
-- TOC entry 5667 (class 1259 OID 126387)
-- Name: pack_21122031_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_21122031_id_pickup_date_idx ON public.pack_21122031 USING btree (id, pickup_date);


--
-- TOC entry 5670 (class 1259 OID 126388)
-- Name: pack_others_id_pickup_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pack_others_id_pickup_date_idx ON public.pack_others USING btree (id, pickup_date);


--
-- TOC entry 5675 (class 1259 OID 126389)
-- Name: pk_patient_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_patient_idx ON ONLY public.patient USING btree (id, match_id);


--
-- TOC entry 5679 (class 1259 OID 126390)
-- Name: patient_10000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_10000_id_match_id_idx ON public.patient_10000 USING btree (id, match_id);


--
-- TOC entry 5676 (class 1259 OID 126391)
-- Name: patient_1000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_1000_id_match_id_idx ON public.patient_1000 USING btree (id, match_id);


--
-- TOC entry 5682 (class 1259 OID 126392)
-- Name: patient_11000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_11000_id_match_id_idx ON public.patient_11000 USING btree (id, match_id);


--
-- TOC entry 5685 (class 1259 OID 126393)
-- Name: patient_12000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_12000_id_match_id_idx ON public.patient_12000 USING btree (id, match_id);


--
-- TOC entry 5688 (class 1259 OID 126394)
-- Name: patient_13000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_13000_id_match_id_idx ON public.patient_13000 USING btree (id, match_id);


--
-- TOC entry 5691 (class 1259 OID 126395)
-- Name: patient_14000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_14000_id_match_id_idx ON public.patient_14000 USING btree (id, match_id);


--
-- TOC entry 5694 (class 1259 OID 126396)
-- Name: patient_15000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_15000_id_match_id_idx ON public.patient_15000 USING btree (id, match_id);


--
-- TOC entry 5697 (class 1259 OID 126397)
-- Name: patient_16000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_16000_id_match_id_idx ON public.patient_16000 USING btree (id, match_id);


--
-- TOC entry 5700 (class 1259 OID 126398)
-- Name: patient_17000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_17000_id_match_id_idx ON public.patient_17000 USING btree (id, match_id);


--
-- TOC entry 5703 (class 1259 OID 126399)
-- Name: patient_18000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_18000_id_match_id_idx ON public.patient_18000 USING btree (id, match_id);


--
-- TOC entry 5706 (class 1259 OID 126400)
-- Name: patient_19000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_19000_id_match_id_idx ON public.patient_19000 USING btree (id, match_id);


--
-- TOC entry 5712 (class 1259 OID 126401)
-- Name: patient_20000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_20000_id_match_id_idx ON public.patient_20000 USING btree (id, match_id);


--
-- TOC entry 5709 (class 1259 OID 126402)
-- Name: patient_2000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_2000_id_match_id_idx ON public.patient_2000 USING btree (id, match_id);


--
-- TOC entry 5715 (class 1259 OID 126403)
-- Name: patient_21000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_21000_id_match_id_idx ON public.patient_21000 USING btree (id, match_id);


--
-- TOC entry 5718 (class 1259 OID 126404)
-- Name: patient_22000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_22000_id_match_id_idx ON public.patient_22000 USING btree (id, match_id);


--
-- TOC entry 5721 (class 1259 OID 126405)
-- Name: patient_23000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_23000_id_match_id_idx ON public.patient_23000 USING btree (id, match_id);


--
-- TOC entry 5724 (class 1259 OID 126406)
-- Name: patient_24000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_24000_id_match_id_idx ON public.patient_24000 USING btree (id, match_id);


--
-- TOC entry 5727 (class 1259 OID 126407)
-- Name: patient_25000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_25000_id_match_id_idx ON public.patient_25000 USING btree (id, match_id);


--
-- TOC entry 5730 (class 1259 OID 126408)
-- Name: patient_26000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_26000_id_match_id_idx ON public.patient_26000 USING btree (id, match_id);


--
-- TOC entry 5733 (class 1259 OID 126409)
-- Name: patient_27000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_27000_id_match_id_idx ON public.patient_27000 USING btree (id, match_id);


--
-- TOC entry 5736 (class 1259 OID 126410)
-- Name: patient_28000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_28000_id_match_id_idx ON public.patient_28000 USING btree (id, match_id);


--
-- TOC entry 5739 (class 1259 OID 126411)
-- Name: patient_29000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_29000_id_match_id_idx ON public.patient_29000 USING btree (id, match_id);


--
-- TOC entry 5745 (class 1259 OID 126412)
-- Name: patient_30000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_30000_id_match_id_idx ON public.patient_30000 USING btree (id, match_id);


--
-- TOC entry 5742 (class 1259 OID 126413)
-- Name: patient_3000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_3000_id_match_id_idx ON public.patient_3000 USING btree (id, match_id);


--
-- TOC entry 5748 (class 1259 OID 126414)
-- Name: patient_31000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_31000_id_match_id_idx ON public.patient_31000 USING btree (id, match_id);


--
-- TOC entry 5751 (class 1259 OID 126415)
-- Name: patient_32000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_32000_id_match_id_idx ON public.patient_32000 USING btree (id, match_id);


--
-- TOC entry 5754 (class 1259 OID 126416)
-- Name: patient_33000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_33000_id_match_id_idx ON public.patient_33000 USING btree (id, match_id);


--
-- TOC entry 5757 (class 1259 OID 126417)
-- Name: patient_34000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_34000_id_match_id_idx ON public.patient_34000 USING btree (id, match_id);


--
-- TOC entry 5760 (class 1259 OID 126418)
-- Name: patient_35000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_35000_id_match_id_idx ON public.patient_35000 USING btree (id, match_id);


--
-- TOC entry 5763 (class 1259 OID 126419)
-- Name: patient_36000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_36000_id_match_id_idx ON public.patient_36000 USING btree (id, match_id);


--
-- TOC entry 5766 (class 1259 OID 126420)
-- Name: patient_37000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_37000_id_match_id_idx ON public.patient_37000 USING btree (id, match_id);


--
-- TOC entry 5769 (class 1259 OID 126421)
-- Name: patient_38000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_38000_id_match_id_idx ON public.patient_38000 USING btree (id, match_id);


--
-- TOC entry 5772 (class 1259 OID 126422)
-- Name: patient_39000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_39000_id_match_id_idx ON public.patient_39000 USING btree (id, match_id);


--
-- TOC entry 5778 (class 1259 OID 126423)
-- Name: patient_40000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_40000_id_match_id_idx ON public.patient_40000 USING btree (id, match_id);


--
-- TOC entry 5775 (class 1259 OID 126424)
-- Name: patient_4000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_4000_id_match_id_idx ON public.patient_4000 USING btree (id, match_id);


--
-- TOC entry 5781 (class 1259 OID 126425)
-- Name: patient_41000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_41000_id_match_id_idx ON public.patient_41000 USING btree (id, match_id);


--
-- TOC entry 5784 (class 1259 OID 126426)
-- Name: patient_42000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_42000_id_match_id_idx ON public.patient_42000 USING btree (id, match_id);


--
-- TOC entry 5787 (class 1259 OID 126427)
-- Name: patient_43000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_43000_id_match_id_idx ON public.patient_43000 USING btree (id, match_id);


--
-- TOC entry 5790 (class 1259 OID 126428)
-- Name: patient_44000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_44000_id_match_id_idx ON public.patient_44000 USING btree (id, match_id);


--
-- TOC entry 5793 (class 1259 OID 126429)
-- Name: patient_45000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_45000_id_match_id_idx ON public.patient_45000 USING btree (id, match_id);


--
-- TOC entry 5796 (class 1259 OID 126430)
-- Name: patient_46000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_46000_id_match_id_idx ON public.patient_46000 USING btree (id, match_id);


--
-- TOC entry 5799 (class 1259 OID 126431)
-- Name: patient_47000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_47000_id_match_id_idx ON public.patient_47000 USING btree (id, match_id);


--
-- TOC entry 5802 (class 1259 OID 126432)
-- Name: patient_48000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_48000_id_match_id_idx ON public.patient_48000 USING btree (id, match_id);


--
-- TOC entry 5805 (class 1259 OID 126433)
-- Name: patient_49000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_49000_id_match_id_idx ON public.patient_49000 USING btree (id, match_id);


--
-- TOC entry 5811 (class 1259 OID 126434)
-- Name: patient_50000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_50000_id_match_id_idx ON public.patient_50000 USING btree (id, match_id);


--
-- TOC entry 5808 (class 1259 OID 126435)
-- Name: patient_5000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_5000_id_match_id_idx ON public.patient_5000 USING btree (id, match_id);


--
-- TOC entry 5814 (class 1259 OID 126436)
-- Name: patient_6000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_6000_id_match_id_idx ON public.patient_6000 USING btree (id, match_id);


--
-- TOC entry 5817 (class 1259 OID 126437)
-- Name: patient_7000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_7000_id_match_id_idx ON public.patient_7000 USING btree (id, match_id);


--
-- TOC entry 5820 (class 1259 OID 126438)
-- Name: patient_8000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_8000_id_match_id_idx ON public.patient_8000 USING btree (id, match_id);


--
-- TOC entry 5823 (class 1259 OID 126439)
-- Name: patient_9000_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_9000_id_match_id_idx ON public.patient_9000 USING btree (id, match_id);


--
-- TOC entry 5848 (class 1259 OID 126440)
-- Name: patient_others_id_match_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_others_id_match_id_idx ON public.patient_others USING btree (id, match_id);


--
-- TOC entry 5853 (class 1259 OID 126441)
-- Name: pk_patientserviceidentifier_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_patientserviceidentifier_idx ON ONLY public.patient_service_identifier USING btree (id, start_date);


--
-- TOC entry 5854 (class 1259 OID 126442)
-- Name: patient_service_identifier_21122008_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122008_id_start_date_idx ON public.patient_service_identifier_21122008 USING btree (id, start_date);


--
-- TOC entry 5857 (class 1259 OID 126443)
-- Name: patient_service_identifier_21122009_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122009_id_start_date_idx ON public.patient_service_identifier_21122009 USING btree (id, start_date);


--
-- TOC entry 5860 (class 1259 OID 126444)
-- Name: patient_service_identifier_21122010_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122010_id_start_date_idx ON public.patient_service_identifier_21122010 USING btree (id, start_date);


--
-- TOC entry 5863 (class 1259 OID 126445)
-- Name: patient_service_identifier_21122011_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122011_id_start_date_idx ON public.patient_service_identifier_21122011 USING btree (id, start_date);


--
-- TOC entry 5866 (class 1259 OID 126446)
-- Name: patient_service_identifier_21122012_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122012_id_start_date_idx ON public.patient_service_identifier_21122012 USING btree (id, start_date);


--
-- TOC entry 5869 (class 1259 OID 126447)
-- Name: patient_service_identifier_21122013_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122013_id_start_date_idx ON public.patient_service_identifier_21122013 USING btree (id, start_date);


--
-- TOC entry 5872 (class 1259 OID 126448)
-- Name: patient_service_identifier_21122014_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122014_id_start_date_idx ON public.patient_service_identifier_21122014 USING btree (id, start_date);


--
-- TOC entry 5875 (class 1259 OID 126449)
-- Name: patient_service_identifier_21122015_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122015_id_start_date_idx ON public.patient_service_identifier_21122015 USING btree (id, start_date);


--
-- TOC entry 5878 (class 1259 OID 126450)
-- Name: patient_service_identifier_21122016_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122016_id_start_date_idx ON public.patient_service_identifier_21122016 USING btree (id, start_date);


--
-- TOC entry 5881 (class 1259 OID 126451)
-- Name: patient_service_identifier_21122017_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122017_id_start_date_idx ON public.patient_service_identifier_21122017 USING btree (id, start_date);


--
-- TOC entry 5884 (class 1259 OID 126452)
-- Name: patient_service_identifier_21122018_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122018_id_start_date_idx ON public.patient_service_identifier_21122018 USING btree (id, start_date);


--
-- TOC entry 5887 (class 1259 OID 126453)
-- Name: patient_service_identifier_21122019_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122019_id_start_date_idx ON public.patient_service_identifier_21122019 USING btree (id, start_date);


--
-- TOC entry 5890 (class 1259 OID 126454)
-- Name: patient_service_identifier_21122020_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122020_id_start_date_idx ON public.patient_service_identifier_21122020 USING btree (id, start_date);


--
-- TOC entry 5893 (class 1259 OID 126455)
-- Name: patient_service_identifier_21122021_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122021_id_start_date_idx ON public.patient_service_identifier_21122021 USING btree (id, start_date);


--
-- TOC entry 5896 (class 1259 OID 126456)
-- Name: patient_service_identifier_21122022_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122022_id_start_date_idx ON public.patient_service_identifier_21122022 USING btree (id, start_date);


--
-- TOC entry 5899 (class 1259 OID 126457)
-- Name: patient_service_identifier_21122023_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122023_id_start_date_idx ON public.patient_service_identifier_21122023 USING btree (id, start_date);


--
-- TOC entry 5902 (class 1259 OID 126458)
-- Name: patient_service_identifier_21122024_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122024_id_start_date_idx ON public.patient_service_identifier_21122024 USING btree (id, start_date);


--
-- TOC entry 5905 (class 1259 OID 126459)
-- Name: patient_service_identifier_21122025_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122025_id_start_date_idx ON public.patient_service_identifier_21122025 USING btree (id, start_date);


--
-- TOC entry 5908 (class 1259 OID 126460)
-- Name: patient_service_identifier_21122027_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122027_id_start_date_idx ON public.patient_service_identifier_21122027 USING btree (id, start_date);


--
-- TOC entry 5911 (class 1259 OID 126461)
-- Name: patient_service_identifier_21122028_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122028_id_start_date_idx ON public.patient_service_identifier_21122028 USING btree (id, start_date);


--
-- TOC entry 5914 (class 1259 OID 126462)
-- Name: patient_service_identifier_21122029_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122029_id_start_date_idx ON public.patient_service_identifier_21122029 USING btree (id, start_date);


--
-- TOC entry 5917 (class 1259 OID 126463)
-- Name: patient_service_identifier_21122030_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122030_id_start_date_idx ON public.patient_service_identifier_21122030 USING btree (id, start_date);


--
-- TOC entry 5920 (class 1259 OID 126464)
-- Name: patient_service_identifier_21122031_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21122031_id_start_date_idx ON public.patient_service_identifier_21122031 USING btree (id, start_date);


--
-- TOC entry 5923 (class 1259 OID 126465)
-- Name: patient_service_identifier_21212026_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_21212026_id_start_date_idx ON public.patient_service_identifier_21212026 USING btree (id, start_date);


--
-- TOC entry 5926 (class 1259 OID 126466)
-- Name: patient_service_identifier_others_id_start_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_service_identifier_others_id_start_date_idx ON public.patient_service_identifier_others USING btree (id, start_date);


--
-- TOC entry 5838 (class 1259 OID 126467)
-- Name: pk_patientvisit_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_patientvisit_idx ON ONLY public.patient_visit USING btree (id, visit_date);


--
-- TOC entry 5937 (class 1259 OID 126468)
-- Name: patient_visit_21122008_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122008_id_visit_date_idx ON public.patient_visit_21122008 USING btree (id, visit_date);


--
-- TOC entry 5940 (class 1259 OID 126469)
-- Name: patient_visit_21122009_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122009_id_visit_date_idx ON public.patient_visit_21122009 USING btree (id, visit_date);


--
-- TOC entry 5943 (class 1259 OID 126470)
-- Name: patient_visit_21122010_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122010_id_visit_date_idx ON public.patient_visit_21122010 USING btree (id, visit_date);


--
-- TOC entry 5946 (class 1259 OID 126471)
-- Name: patient_visit_21122011_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122011_id_visit_date_idx ON public.patient_visit_21122011 USING btree (id, visit_date);


--
-- TOC entry 5949 (class 1259 OID 126472)
-- Name: patient_visit_21122012_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122012_id_visit_date_idx ON public.patient_visit_21122012 USING btree (id, visit_date);


--
-- TOC entry 5952 (class 1259 OID 126473)
-- Name: patient_visit_21122013_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122013_id_visit_date_idx ON public.patient_visit_21122013 USING btree (id, visit_date);


--
-- TOC entry 5955 (class 1259 OID 126474)
-- Name: patient_visit_21122014_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122014_id_visit_date_idx ON public.patient_visit_21122014 USING btree (id, visit_date);


--
-- TOC entry 5958 (class 1259 OID 126475)
-- Name: patient_visit_21122015_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122015_id_visit_date_idx ON public.patient_visit_21122015 USING btree (id, visit_date);


--
-- TOC entry 5961 (class 1259 OID 126476)
-- Name: patient_visit_21122016_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122016_id_visit_date_idx ON public.patient_visit_21122016 USING btree (id, visit_date);


--
-- TOC entry 5964 (class 1259 OID 126477)
-- Name: patient_visit_21122017_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122017_id_visit_date_idx ON public.patient_visit_21122017 USING btree (id, visit_date);


--
-- TOC entry 5967 (class 1259 OID 126478)
-- Name: patient_visit_21122018_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122018_id_visit_date_idx ON public.patient_visit_21122018 USING btree (id, visit_date);


--
-- TOC entry 5970 (class 1259 OID 126479)
-- Name: patient_visit_21122019_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122019_id_visit_date_idx ON public.patient_visit_21122019 USING btree (id, visit_date);


--
-- TOC entry 5973 (class 1259 OID 126480)
-- Name: patient_visit_21122020_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122020_id_visit_date_idx ON public.patient_visit_21122020 USING btree (id, visit_date);


--
-- TOC entry 5976 (class 1259 OID 126481)
-- Name: patient_visit_21122021_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122021_id_visit_date_idx ON public.patient_visit_21122021 USING btree (id, visit_date);


--
-- TOC entry 5979 (class 1259 OID 126482)
-- Name: patient_visit_21122022_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122022_id_visit_date_idx ON public.patient_visit_21122022 USING btree (id, visit_date);


--
-- TOC entry 5982 (class 1259 OID 126483)
-- Name: patient_visit_21122023_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122023_id_visit_date_idx ON public.patient_visit_21122023 USING btree (id, visit_date);


--
-- TOC entry 5985 (class 1259 OID 126484)
-- Name: patient_visit_21122024_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122024_id_visit_date_idx ON public.patient_visit_21122024 USING btree (id, visit_date);


--
-- TOC entry 5988 (class 1259 OID 126485)
-- Name: patient_visit_21122025_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122025_id_visit_date_idx ON public.patient_visit_21122025 USING btree (id, visit_date);


--
-- TOC entry 5991 (class 1259 OID 126486)
-- Name: patient_visit_21122026_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122026_id_visit_date_idx ON public.patient_visit_21122026 USING btree (id, visit_date);


--
-- TOC entry 5994 (class 1259 OID 126487)
-- Name: patient_visit_21122027_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122027_id_visit_date_idx ON public.patient_visit_21122027 USING btree (id, visit_date);


--
-- TOC entry 5997 (class 1259 OID 126488)
-- Name: patient_visit_21122028_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122028_id_visit_date_idx ON public.patient_visit_21122028 USING btree (id, visit_date);


--
-- TOC entry 6000 (class 1259 OID 126489)
-- Name: patient_visit_21122029_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122029_id_visit_date_idx ON public.patient_visit_21122029 USING btree (id, visit_date);


--
-- TOC entry 6003 (class 1259 OID 126490)
-- Name: patient_visit_21122030_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122030_id_visit_date_idx ON public.patient_visit_21122030 USING btree (id, visit_date);


--
-- TOC entry 6006 (class 1259 OID 126491)
-- Name: patient_visit_21122031_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_21122031_id_visit_date_idx ON public.patient_visit_21122031 USING btree (id, visit_date);


--
-- TOC entry 6009 (class 1259 OID 126492)
-- Name: patient_visit_others_id_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX patient_visit_others_id_visit_date_idx ON public.patient_visit_others USING btree (id, visit_date);


--
-- TOC entry 5153 (class 1259 OID 126493)
-- Name: pk_adherencescreening_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_adherencescreening_idx ON public.adherence_screening USING btree (id);


--
-- TOC entry 5156 (class 1259 OID 126494)
-- Name: pk_appointment_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_appointment_idx ON public.appointment USING btree (id);


--
-- TOC entry 5167 (class 1259 OID 126495)
-- Name: pk_clinic_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_clinic_idx ON public.clinic USING btree (id);


--
-- TOC entry 5189 (class 1259 OID 126496)
-- Name: pk_clinicalservice_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_clinicalservice_idx ON public.clinical_service USING btree (id);


--
-- TOC entry 5196 (class 1259 OID 126497)
-- Name: pk_clinicalserviceattributetype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_clinicalserviceattributetype_idx ON public.clinical_service_attribute_type USING btree (id);


--
-- TOC entry 5180 (class 1259 OID 126498)
-- Name: pk_clinicsectortype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_clinicsectortype_idx ON public.clinic_sector_type USING btree (id);


--
-- TOC entry 5205 (class 1259 OID 126499)
-- Name: pk_destroyedstock_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_destroyedstock_idx ON public.destroyed_stock USING btree (id);


--
-- TOC entry 5208 (class 1259 OID 126500)
-- Name: pk_dispensemode_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_dispensemode_idx ON public.dispense_mode USING btree (id);


--
-- TOC entry 5211 (class 1259 OID 126501)
-- Name: pk_dispensetype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_dispensetype_idx ON public.dispense_type USING btree (id);


--
-- TOC entry 5216 (class 1259 OID 126502)
-- Name: pk_district_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_district_idx ON public.district USING btree (id);


--
-- TOC entry 5221 (class 1259 OID 126503)
-- Name: pk_doctor_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_doctor_idx ON public.doctor USING btree (id);


--
-- TOC entry 5224 (class 1259 OID 126504)
-- Name: pk_drug_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_drug_idx ON public.drug USING btree (id);


--
-- TOC entry 5263 (class 1259 OID 126505)
-- Name: pk_duration_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_duration_idx ON public.duration USING btree (id);


--
-- TOC entry 5344 (class 1259 OID 126506)
-- Name: pk_episodetype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_episodetype_idx ON public.episode_type USING btree (id);


--
-- TOC entry 5351 (class 1259 OID 126507)
-- Name: pk_facilitytype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_facilitytype_idx ON public.facility_type USING btree (id);


--
-- TOC entry 5356 (class 1259 OID 126508)
-- Name: pk_form_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_form_idx ON public.form USING btree (id);


--
-- TOC entry 5361 (class 1259 OID 126509)
-- Name: pk_groupinfo_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_groupinfo_idx ON public.group_info USING btree (id);


--
-- TOC entry 5366 (class 1259 OID 126510)
-- Name: pk_groupmember_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_groupmember_idx ON public.group_member USING btree (id);


--
-- TOC entry 5371 (class 1259 OID 126511)
-- Name: pk_groupmemberprescription_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_groupmemberprescription_idx ON public.group_member_prescription USING btree (id);


--
-- TOC entry 5374 (class 1259 OID 126512)
-- Name: pk_grouppack_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_grouppack_idx ON public.group_pack USING btree (id);


--
-- TOC entry 5377 (class 1259 OID 126513)
-- Name: pk_grouppackheader_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_grouppackheader_idx ON public.group_pack_header USING btree (id);


--
-- TOC entry 5380 (class 1259 OID 126514)
-- Name: pk_grouptype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_grouptype_idx ON public.group_type USING btree (id);


--
-- TOC entry 5385 (class 1259 OID 126515)
-- Name: pk_healthinformationsystem_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_healthinformationsystem_idx ON public.health_information_system USING btree (id);


--
-- TOC entry 5392 (class 1259 OID 126516)
-- Name: pk_identifiertype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_identifiertype_idx ON public.identifier_type USING btree (id);


--
-- TOC entry 5397 (class 1259 OID 126517)
-- Name: pk_interoperabilityattribute_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_interoperabilityattribute_idx ON public.interoperability_attribute USING btree (id);


--
-- TOC entry 5400 (class 1259 OID 126518)
-- Name: pk_interoperabilitytype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_interoperabilitytype_idx ON public.interoperability_type USING btree (id);


--
-- TOC entry 5232 (class 1259 OID 126519)
-- Name: pk_inventory_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_inventory_idx ON public.inventory USING btree (id);


--
-- TOC entry 5411 (class 1259 OID 126520)
-- Name: pk_localidade_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_localidade_idx ON public.localidade USING btree (id);


--
-- TOC entry 5575 (class 1259 OID 126521)
-- Name: pk_migrationstage_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_migrationstage_idx ON public.migration_stage USING btree (id);


--
-- TOC entry 5588 (class 1259 OID 126522)
-- Name: pk_nationalclinic_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_nationalclinic_idx ON public.national_clinic USING btree (id);


--
-- TOC entry 5597 (class 1259 OID 126523)
-- Name: pk_openmrserrorlog_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_openmrserrorlog_idx ON public.openmrs_error_log USING btree (id);


--
-- TOC entry 5238 (class 1259 OID 126524)
-- Name: pk_packageddrug_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_packageddrug_idx ON public.packaged_drug USING btree (id);


--
-- TOC entry 5241 (class 1259 OID 126525)
-- Name: pk_packageddrugstock_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_packageddrugstock_idx ON public.packaged_drug_stock USING btree (id);


--
-- TOC entry 5828 (class 1259 OID 126526)
-- Name: pk_patientattribute_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_patientattribute_idx ON public.patient_attribute USING btree (id);


--
-- TOC entry 5831 (class 1259 OID 126527)
-- Name: pk_patientattributetype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_patientattributetype_idx ON public.patient_attribute_type USING btree (id);


--
-- TOC entry 5931 (class 1259 OID 126528)
-- Name: pk_patienttransreference_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_patienttransreference_idx ON public.patient_trans_reference USING btree (id);


--
-- TOC entry 5934 (class 1259 OID 126529)
-- Name: pk_patienttransreferencetype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_patienttransreferencetype_idx ON public.patient_trans_reference_type USING btree (id);


--
-- TOC entry 5844 (class 1259 OID 126530)
-- Name: pk_patientvisitdetails_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_patientvisitdetails_idx ON public.patient_visit_details USING btree (id);


--
-- TOC entry 6020 (class 1259 OID 126531)
-- Name: pk_postoadministrativo_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_postoadministrativo_idx ON public.posto_administrativo USING btree (id);


--
-- TOC entry 6025 (class 1259 OID 126532)
-- Name: pk_pregnancyscreening_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_pregnancyscreening_idx ON public.pregnancy_screening USING btree (id);


--
-- TOC entry 6028 (class 1259 OID 126533)
-- Name: pk_prescribeddrug_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_prescribeddrug_idx ON public.prescribed_drug USING btree (id);


--
-- TOC entry 5845 (class 1259 OID 126534)
-- Name: pk_prescription_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_prescription_idx ON ONLY public.prescription USING btree (id, prescription_date);


--
-- TOC entry 6103 (class 1259 OID 126535)
-- Name: pk_prescriptiondetail_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_prescriptiondetail_idx ON public.prescription_detail USING btree (id);


--
-- TOC entry 6109 (class 1259 OID 126536)
-- Name: pk_province_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_province_idx ON public.province USING btree (id);


--
-- TOC entry 6114 (class 1259 OID 126537)
-- Name: pk_provincialserver_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_provincialserver_idx ON public.provincial_server USING btree (id);


--
-- TOC entry 6119 (class 1259 OID 126538)
-- Name: pk_ramscreening_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_ramscreening_idx ON public.ramscreening USING btree (id);


--
-- TOC entry 5242 (class 1259 OID 126539)
-- Name: pk_referedstockmoviment_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_referedstockmoviment_idx ON public.refered_stock_moviment USING btree (id);


--
-- TOC entry 6142 (class 1259 OID 126540)
-- Name: pk_secuser_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_secuser_idx ON public.sec_user USING btree (id);


--
-- TOC entry 6153 (class 1259 OID 126541)
-- Name: pk_spetialprescriptionmotive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_spetialprescriptionmotive_idx ON public.spetial_prescription_motive USING btree (id);


--
-- TOC entry 6158 (class 1259 OID 126542)
-- Name: pk_startstopreason_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_startstopreason_idx ON public.start_stop_reason USING btree (id);


--
-- TOC entry 5227 (class 1259 OID 126543)
-- Name: pk_stock_batch_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_stock_batch_idx ON public.drug_distributor USING btree (id);


--
-- TOC entry 5245 (class 1259 OID 126544)
-- Name: pk_stock_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_stock_idx ON public.stock USING btree (id);


--
-- TOC entry 5248 (class 1259 OID 126545)
-- Name: pk_stockadjustment_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_stockadjustment_idx ON public.stock_adjustment USING btree (id);


--
-- TOC entry 6163 (class 1259 OID 126546)
-- Name: pk_stockcenter_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_stockcenter_idx ON public.stock_center USING btree (id);


--
-- TOC entry 5251 (class 1259 OID 126547)
-- Name: pk_stockentrance_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_stockentrance_idx ON public.stock_entrance USING btree (id);


--
-- TOC entry 6172 (class 1259 OID 126548)
-- Name: pk_stocklevel_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_stocklevel_idx ON public.stock_level USING btree (id);


--
-- TOC entry 5256 (class 1259 OID 126549)
-- Name: pk_stockoperationtype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_stockoperationtype_idx ON public.stock_operation_type USING btree (id);


--
-- TOC entry 6177 (class 1259 OID 126550)
-- Name: pk_systemconfigs_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_systemconfigs_idx ON public.system_configs USING btree (id);


--
-- TOC entry 6182 (class 1259 OID 126551)
-- Name: pk_tbscreening_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_tbscreening_idx ON public.tbscreening USING btree (id);


--
-- TOC entry 6185 (class 1259 OID 126552)
-- Name: pk_therapeuticline_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_therapeuticline_idx ON public.therapeutic_line USING btree (id);


--
-- TOC entry 6190 (class 1259 OID 126553)
-- Name: pk_therapeuticregimen_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_therapeuticregimen_idx ON public.therapeutic_regimen USING btree (id);


--
-- TOC entry 5839 (class 1259 OID 126554)
-- Name: pk_vitalsignsscreening_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_vitalsignsscreening_idx ON public.vital_signs_screening USING btree (id);


--
-- TOC entry 6031 (class 1259 OID 126555)
-- Name: prescription_21122008_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122008_id_prescription_date_idx ON public.prescription_21122008 USING btree (id, prescription_date);


--
-- TOC entry 6034 (class 1259 OID 126556)
-- Name: prescription_21122009_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122009_id_prescription_date_idx ON public.prescription_21122009 USING btree (id, prescription_date);


--
-- TOC entry 6037 (class 1259 OID 126557)
-- Name: prescription_21122010_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122010_id_prescription_date_idx ON public.prescription_21122010 USING btree (id, prescription_date);


--
-- TOC entry 6040 (class 1259 OID 126558)
-- Name: prescription_21122011_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122011_id_prescription_date_idx ON public.prescription_21122011 USING btree (id, prescription_date);


--
-- TOC entry 6043 (class 1259 OID 126559)
-- Name: prescription_21122012_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122012_id_prescription_date_idx ON public.prescription_21122012 USING btree (id, prescription_date);


--
-- TOC entry 6046 (class 1259 OID 126560)
-- Name: prescription_21122013_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122013_id_prescription_date_idx ON public.prescription_21122013 USING btree (id, prescription_date);


--
-- TOC entry 6049 (class 1259 OID 126561)
-- Name: prescription_21122014_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122014_id_prescription_date_idx ON public.prescription_21122014 USING btree (id, prescription_date);


--
-- TOC entry 6052 (class 1259 OID 126562)
-- Name: prescription_21122015_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122015_id_prescription_date_idx ON public.prescription_21122015 USING btree (id, prescription_date);


--
-- TOC entry 6055 (class 1259 OID 126563)
-- Name: prescription_21122016_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122016_id_prescription_date_idx ON public.prescription_21122016 USING btree (id, prescription_date);


--
-- TOC entry 6058 (class 1259 OID 126564)
-- Name: prescription_21122017_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122017_id_prescription_date_idx ON public.prescription_21122017 USING btree (id, prescription_date);


--
-- TOC entry 6061 (class 1259 OID 126565)
-- Name: prescription_21122018_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122018_id_prescription_date_idx ON public.prescription_21122018 USING btree (id, prescription_date);


--
-- TOC entry 6064 (class 1259 OID 126566)
-- Name: prescription_21122019_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122019_id_prescription_date_idx ON public.prescription_21122019 USING btree (id, prescription_date);


--
-- TOC entry 6067 (class 1259 OID 126567)
-- Name: prescription_21122020_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122020_id_prescription_date_idx ON public.prescription_21122020 USING btree (id, prescription_date);


--
-- TOC entry 6070 (class 1259 OID 126568)
-- Name: prescription_21122021_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122021_id_prescription_date_idx ON public.prescription_21122021 USING btree (id, prescription_date);


--
-- TOC entry 6073 (class 1259 OID 126569)
-- Name: prescription_21122022_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122022_id_prescription_date_idx ON public.prescription_21122022 USING btree (id, prescription_date);


--
-- TOC entry 6076 (class 1259 OID 126570)
-- Name: prescription_21122023_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122023_id_prescription_date_idx ON public.prescription_21122023 USING btree (id, prescription_date);


--
-- TOC entry 6079 (class 1259 OID 126571)
-- Name: prescription_21122024_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122024_id_prescription_date_idx ON public.prescription_21122024 USING btree (id, prescription_date);


--
-- TOC entry 6082 (class 1259 OID 126572)
-- Name: prescription_21122025_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122025_id_prescription_date_idx ON public.prescription_21122025 USING btree (id, prescription_date);


--
-- TOC entry 6085 (class 1259 OID 126573)
-- Name: prescription_21122026_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122026_id_prescription_date_idx ON public.prescription_21122026 USING btree (id, prescription_date);


--
-- TOC entry 6088 (class 1259 OID 126574)
-- Name: prescription_21122027_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122027_id_prescription_date_idx ON public.prescription_21122027 USING btree (id, prescription_date);


--
-- TOC entry 6091 (class 1259 OID 126575)
-- Name: prescription_21122028_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122028_id_prescription_date_idx ON public.prescription_21122028 USING btree (id, prescription_date);


--
-- TOC entry 6094 (class 1259 OID 126576)
-- Name: prescription_21122029_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122029_id_prescription_date_idx ON public.prescription_21122029 USING btree (id, prescription_date);


--
-- TOC entry 6097 (class 1259 OID 126577)
-- Name: prescription_21122030_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122030_id_prescription_date_idx ON public.prescription_21122030 USING btree (id, prescription_date);


--
-- TOC entry 6100 (class 1259 OID 126578)
-- Name: prescription_21122031_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_21122031_id_prescription_date_idx ON public.prescription_21122031 USING btree (id, prescription_date);


--
-- TOC entry 6106 (class 1259 OID 126579)
-- Name: prescription_others_id_prescription_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prescription_others_id_prescription_date_idx ON public.prescription_others USING btree (id, prescription_date);


--
-- TOC entry 6199 (class 0 OID 0)
-- Name: episode_21122008_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122008_id_episode_date_idx;


--
-- TOC entry 6200 (class 0 OID 0)
-- Name: episode_21122008_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122008_pkey;


--
-- TOC entry 6201 (class 0 OID 0)
-- Name: episode_21122009_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122009_id_episode_date_idx;


--
-- TOC entry 6202 (class 0 OID 0)
-- Name: episode_21122009_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122009_pkey;


--
-- TOC entry 6203 (class 0 OID 0)
-- Name: episode_21122010_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122010_id_episode_date_idx;


--
-- TOC entry 6204 (class 0 OID 0)
-- Name: episode_21122010_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122010_pkey;


--
-- TOC entry 6205 (class 0 OID 0)
-- Name: episode_21122011_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122011_id_episode_date_idx;


--
-- TOC entry 6206 (class 0 OID 0)
-- Name: episode_21122011_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122011_pkey;


--
-- TOC entry 6207 (class 0 OID 0)
-- Name: episode_21122012_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122012_id_episode_date_idx;


--
-- TOC entry 6208 (class 0 OID 0)
-- Name: episode_21122012_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122012_pkey;


--
-- TOC entry 6209 (class 0 OID 0)
-- Name: episode_21122013_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122013_id_episode_date_idx;


--
-- TOC entry 6210 (class 0 OID 0)
-- Name: episode_21122013_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122013_pkey;


--
-- TOC entry 6211 (class 0 OID 0)
-- Name: episode_21122014_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122014_id_episode_date_idx;


--
-- TOC entry 6212 (class 0 OID 0)
-- Name: episode_21122014_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122014_pkey;


--
-- TOC entry 6213 (class 0 OID 0)
-- Name: episode_21122015_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122015_id_episode_date_idx;


--
-- TOC entry 6214 (class 0 OID 0)
-- Name: episode_21122015_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122015_pkey;


--
-- TOC entry 6215 (class 0 OID 0)
-- Name: episode_21122016_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122016_id_episode_date_idx;


--
-- TOC entry 6216 (class 0 OID 0)
-- Name: episode_21122016_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122016_pkey;


--
-- TOC entry 6217 (class 0 OID 0)
-- Name: episode_21122017_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122017_id_episode_date_idx;


--
-- TOC entry 6218 (class 0 OID 0)
-- Name: episode_21122017_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122017_pkey;


--
-- TOC entry 6219 (class 0 OID 0)
-- Name: episode_21122018_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122018_id_episode_date_idx;


--
-- TOC entry 6220 (class 0 OID 0)
-- Name: episode_21122018_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122018_pkey;


--
-- TOC entry 6221 (class 0 OID 0)
-- Name: episode_21122019_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122019_id_episode_date_idx;


--
-- TOC entry 6222 (class 0 OID 0)
-- Name: episode_21122019_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122019_pkey;


--
-- TOC entry 6223 (class 0 OID 0)
-- Name: episode_21122020_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122020_id_episode_date_idx;


--
-- TOC entry 6224 (class 0 OID 0)
-- Name: episode_21122020_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122020_pkey;


--
-- TOC entry 6225 (class 0 OID 0)
-- Name: episode_21122021_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122021_id_episode_date_idx;


--
-- TOC entry 6226 (class 0 OID 0)
-- Name: episode_21122021_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122021_pkey;


--
-- TOC entry 6227 (class 0 OID 0)
-- Name: episode_21122022_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122022_id_episode_date_idx;


--
-- TOC entry 6228 (class 0 OID 0)
-- Name: episode_21122022_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122022_pkey;


--
-- TOC entry 6229 (class 0 OID 0)
-- Name: episode_21122023_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122023_id_episode_date_idx;


--
-- TOC entry 6230 (class 0 OID 0)
-- Name: episode_21122023_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122023_pkey;


--
-- TOC entry 6231 (class 0 OID 0)
-- Name: episode_21122024_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122024_id_episode_date_idx;


--
-- TOC entry 6232 (class 0 OID 0)
-- Name: episode_21122024_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122024_pkey;


--
-- TOC entry 6233 (class 0 OID 0)
-- Name: episode_21122025_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122025_id_episode_date_idx;


--
-- TOC entry 6234 (class 0 OID 0)
-- Name: episode_21122025_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122025_pkey;


--
-- TOC entry 6235 (class 0 OID 0)
-- Name: episode_21122026_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122026_id_episode_date_idx;


--
-- TOC entry 6236 (class 0 OID 0)
-- Name: episode_21122026_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122026_pkey;


--
-- TOC entry 6237 (class 0 OID 0)
-- Name: episode_21122027_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122027_id_episode_date_idx;


--
-- TOC entry 6238 (class 0 OID 0)
-- Name: episode_21122027_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122027_pkey;


--
-- TOC entry 6239 (class 0 OID 0)
-- Name: episode_21122028_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122028_id_episode_date_idx;


--
-- TOC entry 6240 (class 0 OID 0)
-- Name: episode_21122028_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122028_pkey;


--
-- TOC entry 6241 (class 0 OID 0)
-- Name: episode_21122029_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122029_id_episode_date_idx;


--
-- TOC entry 6242 (class 0 OID 0)
-- Name: episode_21122029_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122029_pkey;


--
-- TOC entry 6243 (class 0 OID 0)
-- Name: episode_21122030_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122030_id_episode_date_idx;


--
-- TOC entry 6244 (class 0 OID 0)
-- Name: episode_21122030_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122030_pkey;


--
-- TOC entry 6245 (class 0 OID 0)
-- Name: episode_21122031_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_21122031_id_episode_date_idx;


--
-- TOC entry 6246 (class 0 OID 0)
-- Name: episode_21122031_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_21122031_pkey;


--
-- TOC entry 6247 (class 0 OID 0)
-- Name: episode_others_id_episode_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_episode_idx ATTACH PARTITION public.episode_others_id_episode_date_idx;


--
-- TOC entry 6248 (class 0 OID 0)
-- Name: episode_others_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.episode_pkey ATTACH PARTITION public.episode_others_pkey;


--
-- TOC entry 6249 (class 0 OID 0)
-- Name: migration_log_000_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_000_id_source_id_idx;


--
-- TOC entry 6250 (class 0 OID 0)
-- Name: migration_log_000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_000_pkey;


--
-- TOC entry 6251 (class 0 OID 0)
-- Name: migration_log_001_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_001_id_source_id_idx;


--
-- TOC entry 6252 (class 0 OID 0)
-- Name: migration_log_001_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_001_pkey;


--
-- TOC entry 6253 (class 0 OID 0)
-- Name: migration_log_002_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_002_id_source_id_idx;


--
-- TOC entry 6254 (class 0 OID 0)
-- Name: migration_log_002_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_002_pkey;


--
-- TOC entry 6255 (class 0 OID 0)
-- Name: migration_log_003_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_003_id_source_id_idx;


--
-- TOC entry 6256 (class 0 OID 0)
-- Name: migration_log_003_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_003_pkey;


--
-- TOC entry 6257 (class 0 OID 0)
-- Name: migration_log_004_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_004_id_source_id_idx;


--
-- TOC entry 6258 (class 0 OID 0)
-- Name: migration_log_004_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_004_pkey;


--
-- TOC entry 6259 (class 0 OID 0)
-- Name: migration_log_005_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_005_id_source_id_idx;


--
-- TOC entry 6260 (class 0 OID 0)
-- Name: migration_log_005_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_005_pkey;


--
-- TOC entry 6261 (class 0 OID 0)
-- Name: migration_log_006_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_006_id_source_id_idx;


--
-- TOC entry 6262 (class 0 OID 0)
-- Name: migration_log_006_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_006_pkey;


--
-- TOC entry 6263 (class 0 OID 0)
-- Name: migration_log_007_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_007_id_source_id_idx;


--
-- TOC entry 6264 (class 0 OID 0)
-- Name: migration_log_007_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_007_pkey;


--
-- TOC entry 6265 (class 0 OID 0)
-- Name: migration_log_008_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_008_id_source_id_idx;


--
-- TOC entry 6266 (class 0 OID 0)
-- Name: migration_log_008_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_008_pkey;


--
-- TOC entry 6267 (class 0 OID 0)
-- Name: migration_log_009_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_009_id_source_id_idx;


--
-- TOC entry 6268 (class 0 OID 0)
-- Name: migration_log_009_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_009_pkey;


--
-- TOC entry 6269 (class 0 OID 0)
-- Name: migration_log_010_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_010_id_source_id_idx;


--
-- TOC entry 6270 (class 0 OID 0)
-- Name: migration_log_010_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_010_pkey;


--
-- TOC entry 6271 (class 0 OID 0)
-- Name: migration_log_011_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_011_id_source_id_idx;


--
-- TOC entry 6272 (class 0 OID 0)
-- Name: migration_log_011_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_011_pkey;


--
-- TOC entry 6273 (class 0 OID 0)
-- Name: migration_log_012_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_012_id_source_id_idx;


--
-- TOC entry 6274 (class 0 OID 0)
-- Name: migration_log_012_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_012_pkey;


--
-- TOC entry 6275 (class 0 OID 0)
-- Name: migration_log_013_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_013_id_source_id_idx;


--
-- TOC entry 6276 (class 0 OID 0)
-- Name: migration_log_013_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_013_pkey;


--
-- TOC entry 6277 (class 0 OID 0)
-- Name: migration_log_014_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_014_id_source_id_idx;


--
-- TOC entry 6278 (class 0 OID 0)
-- Name: migration_log_014_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_014_pkey;


--
-- TOC entry 6279 (class 0 OID 0)
-- Name: migration_log_015_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_015_id_source_id_idx;


--
-- TOC entry 6280 (class 0 OID 0)
-- Name: migration_log_015_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_015_pkey;


--
-- TOC entry 6281 (class 0 OID 0)
-- Name: migration_log_016_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_016_id_source_id_idx;


--
-- TOC entry 6282 (class 0 OID 0)
-- Name: migration_log_016_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_016_pkey;


--
-- TOC entry 6283 (class 0 OID 0)
-- Name: migration_log_017_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_017_id_source_id_idx;


--
-- TOC entry 6284 (class 0 OID 0)
-- Name: migration_log_017_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_017_pkey;


--
-- TOC entry 6285 (class 0 OID 0)
-- Name: migration_log_018_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_018_id_source_id_idx;


--
-- TOC entry 6286 (class 0 OID 0)
-- Name: migration_log_018_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_018_pkey;


--
-- TOC entry 6287 (class 0 OID 0)
-- Name: migration_log_019_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_019_id_source_id_idx;


--
-- TOC entry 6288 (class 0 OID 0)
-- Name: migration_log_019_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_019_pkey;


--
-- TOC entry 6289 (class 0 OID 0)
-- Name: migration_log_020_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_020_id_source_id_idx;


--
-- TOC entry 6290 (class 0 OID 0)
-- Name: migration_log_020_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_020_pkey;


--
-- TOC entry 6291 (class 0 OID 0)
-- Name: migration_log_021_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_021_id_source_id_idx;


--
-- TOC entry 6292 (class 0 OID 0)
-- Name: migration_log_021_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_021_pkey;


--
-- TOC entry 6293 (class 0 OID 0)
-- Name: migration_log_022_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_022_id_source_id_idx;


--
-- TOC entry 6294 (class 0 OID 0)
-- Name: migration_log_022_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_022_pkey;


--
-- TOC entry 6295 (class 0 OID 0)
-- Name: migration_log_023_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_023_id_source_id_idx;


--
-- TOC entry 6296 (class 0 OID 0)
-- Name: migration_log_023_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_023_pkey;


--
-- TOC entry 6297 (class 0 OID 0)
-- Name: migration_log_024_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_024_id_source_id_idx;


--
-- TOC entry 6298 (class 0 OID 0)
-- Name: migration_log_024_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_024_pkey;


--
-- TOC entry 6299 (class 0 OID 0)
-- Name: migration_log_025_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_025_id_source_id_idx;


--
-- TOC entry 6300 (class 0 OID 0)
-- Name: migration_log_025_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_025_pkey;


--
-- TOC entry 6301 (class 0 OID 0)
-- Name: migration_log_026_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_026_id_source_id_idx;


--
-- TOC entry 6302 (class 0 OID 0)
-- Name: migration_log_026_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_026_pkey;


--
-- TOC entry 6303 (class 0 OID 0)
-- Name: migration_log_027_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_027_id_source_id_idx;


--
-- TOC entry 6304 (class 0 OID 0)
-- Name: migration_log_027_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_027_pkey;


--
-- TOC entry 6305 (class 0 OID 0)
-- Name: migration_log_028_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_028_id_source_id_idx;


--
-- TOC entry 6306 (class 0 OID 0)
-- Name: migration_log_028_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_028_pkey;


--
-- TOC entry 6307 (class 0 OID 0)
-- Name: migration_log_029_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_029_id_source_id_idx;


--
-- TOC entry 6308 (class 0 OID 0)
-- Name: migration_log_029_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_029_pkey;


--
-- TOC entry 6309 (class 0 OID 0)
-- Name: migration_log_030_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_030_id_source_id_idx;


--
-- TOC entry 6310 (class 0 OID 0)
-- Name: migration_log_030_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_030_pkey;


--
-- TOC entry 6311 (class 0 OID 0)
-- Name: migration_log_031_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_031_id_source_id_idx;


--
-- TOC entry 6312 (class 0 OID 0)
-- Name: migration_log_031_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_031_pkey;


--
-- TOC entry 6313 (class 0 OID 0)
-- Name: migration_log_032_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_032_id_source_id_idx;


--
-- TOC entry 6314 (class 0 OID 0)
-- Name: migration_log_032_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_032_pkey;


--
-- TOC entry 6315 (class 0 OID 0)
-- Name: migration_log_033_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_033_id_source_id_idx;


--
-- TOC entry 6316 (class 0 OID 0)
-- Name: migration_log_033_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_033_pkey;


--
-- TOC entry 6317 (class 0 OID 0)
-- Name: migration_log_034_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_034_id_source_id_idx;


--
-- TOC entry 6318 (class 0 OID 0)
-- Name: migration_log_034_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_034_pkey;


--
-- TOC entry 6319 (class 0 OID 0)
-- Name: migration_log_035_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_035_id_source_id_idx;


--
-- TOC entry 6320 (class 0 OID 0)
-- Name: migration_log_035_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_035_pkey;


--
-- TOC entry 6321 (class 0 OID 0)
-- Name: migration_log_036_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_036_id_source_id_idx;


--
-- TOC entry 6322 (class 0 OID 0)
-- Name: migration_log_036_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_036_pkey;


--
-- TOC entry 6323 (class 0 OID 0)
-- Name: migration_log_037_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_037_id_source_id_idx;


--
-- TOC entry 6324 (class 0 OID 0)
-- Name: migration_log_037_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_037_pkey;


--
-- TOC entry 6325 (class 0 OID 0)
-- Name: migration_log_038_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_038_id_source_id_idx;


--
-- TOC entry 6326 (class 0 OID 0)
-- Name: migration_log_038_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_038_pkey;


--
-- TOC entry 6327 (class 0 OID 0)
-- Name: migration_log_039_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_039_id_source_id_idx;


--
-- TOC entry 6328 (class 0 OID 0)
-- Name: migration_log_039_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_039_pkey;


--
-- TOC entry 6329 (class 0 OID 0)
-- Name: migration_log_040_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_040_id_source_id_idx;


--
-- TOC entry 6330 (class 0 OID 0)
-- Name: migration_log_040_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_040_pkey;


--
-- TOC entry 6331 (class 0 OID 0)
-- Name: migration_log_041_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_041_id_source_id_idx;


--
-- TOC entry 6332 (class 0 OID 0)
-- Name: migration_log_041_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_041_pkey;


--
-- TOC entry 6333 (class 0 OID 0)
-- Name: migration_log_042_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_042_id_source_id_idx;


--
-- TOC entry 6334 (class 0 OID 0)
-- Name: migration_log_042_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_042_pkey;


--
-- TOC entry 6335 (class 0 OID 0)
-- Name: migration_log_043_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_043_id_source_id_idx;


--
-- TOC entry 6336 (class 0 OID 0)
-- Name: migration_log_043_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_043_pkey;


--
-- TOC entry 6337 (class 0 OID 0)
-- Name: migration_log_044_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_044_id_source_id_idx;


--
-- TOC entry 6338 (class 0 OID 0)
-- Name: migration_log_044_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_044_pkey;


--
-- TOC entry 6339 (class 0 OID 0)
-- Name: migration_log_045_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_045_id_source_id_idx;


--
-- TOC entry 6340 (class 0 OID 0)
-- Name: migration_log_045_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_045_pkey;


--
-- TOC entry 6341 (class 0 OID 0)
-- Name: migration_log_046_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_046_id_source_id_idx;


--
-- TOC entry 6342 (class 0 OID 0)
-- Name: migration_log_046_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_046_pkey;


--
-- TOC entry 6343 (class 0 OID 0)
-- Name: migration_log_047_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_047_id_source_id_idx;


--
-- TOC entry 6344 (class 0 OID 0)
-- Name: migration_log_047_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_047_pkey;


--
-- TOC entry 6345 (class 0 OID 0)
-- Name: migration_log_048_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_048_id_source_id_idx;


--
-- TOC entry 6346 (class 0 OID 0)
-- Name: migration_log_048_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_048_pkey;


--
-- TOC entry 6347 (class 0 OID 0)
-- Name: migration_log_049_id_source_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_migration_log_idx ATTACH PARTITION public.migration_log_049_id_source_id_idx;


--
-- TOC entry 6348 (class 0 OID 0)
-- Name: migration_log_049_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.migration_log_pkey ATTACH PARTITION public.migration_log_049_pkey;


--
-- TOC entry 6349 (class 0 OID 0)
-- Name: pack_21122008_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122008_id_pickup_date_idx;


--
-- TOC entry 6350 (class 0 OID 0)
-- Name: pack_21122008_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122008_pkey;


--
-- TOC entry 6351 (class 0 OID 0)
-- Name: pack_21122009_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122009_id_pickup_date_idx;


--
-- TOC entry 6352 (class 0 OID 0)
-- Name: pack_21122009_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122009_pkey;


--
-- TOC entry 6353 (class 0 OID 0)
-- Name: pack_21122010_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122010_id_pickup_date_idx;


--
-- TOC entry 6354 (class 0 OID 0)
-- Name: pack_21122010_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122010_pkey;


--
-- TOC entry 6355 (class 0 OID 0)
-- Name: pack_21122011_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122011_id_pickup_date_idx;


--
-- TOC entry 6356 (class 0 OID 0)
-- Name: pack_21122011_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122011_pkey;


--
-- TOC entry 6357 (class 0 OID 0)
-- Name: pack_21122012_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122012_id_pickup_date_idx;


--
-- TOC entry 6358 (class 0 OID 0)
-- Name: pack_21122012_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122012_pkey;


--
-- TOC entry 6359 (class 0 OID 0)
-- Name: pack_21122013_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122013_id_pickup_date_idx;


--
-- TOC entry 6360 (class 0 OID 0)
-- Name: pack_21122013_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122013_pkey;


--
-- TOC entry 6361 (class 0 OID 0)
-- Name: pack_21122014_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122014_id_pickup_date_idx;


--
-- TOC entry 6362 (class 0 OID 0)
-- Name: pack_21122014_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122014_pkey;


--
-- TOC entry 6363 (class 0 OID 0)
-- Name: pack_21122015_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122015_id_pickup_date_idx;


--
-- TOC entry 6364 (class 0 OID 0)
-- Name: pack_21122015_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122015_pkey;


--
-- TOC entry 6365 (class 0 OID 0)
-- Name: pack_21122016_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122016_id_pickup_date_idx;


--
-- TOC entry 6366 (class 0 OID 0)
-- Name: pack_21122016_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122016_pkey;


--
-- TOC entry 6367 (class 0 OID 0)
-- Name: pack_21122017_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122017_id_pickup_date_idx;


--
-- TOC entry 6368 (class 0 OID 0)
-- Name: pack_21122017_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122017_pkey;


--
-- TOC entry 6369 (class 0 OID 0)
-- Name: pack_21122018_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122018_id_pickup_date_idx;


--
-- TOC entry 6370 (class 0 OID 0)
-- Name: pack_21122018_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122018_pkey;


--
-- TOC entry 6371 (class 0 OID 0)
-- Name: pack_21122019_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122019_id_pickup_date_idx;


--
-- TOC entry 6372 (class 0 OID 0)
-- Name: pack_21122019_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122019_pkey;


--
-- TOC entry 6373 (class 0 OID 0)
-- Name: pack_21122020_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122020_id_pickup_date_idx;


--
-- TOC entry 6374 (class 0 OID 0)
-- Name: pack_21122020_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122020_pkey;


--
-- TOC entry 6375 (class 0 OID 0)
-- Name: pack_21122021_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122021_id_pickup_date_idx;


--
-- TOC entry 6376 (class 0 OID 0)
-- Name: pack_21122021_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122021_pkey;


--
-- TOC entry 6377 (class 0 OID 0)
-- Name: pack_21122022_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122022_id_pickup_date_idx;


--
-- TOC entry 6378 (class 0 OID 0)
-- Name: pack_21122022_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122022_pkey;


--
-- TOC entry 6379 (class 0 OID 0)
-- Name: pack_21122023_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122023_id_pickup_date_idx;


--
-- TOC entry 6380 (class 0 OID 0)
-- Name: pack_21122023_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122023_pkey;


--
-- TOC entry 6381 (class 0 OID 0)
-- Name: pack_21122024_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122024_id_pickup_date_idx;


--
-- TOC entry 6382 (class 0 OID 0)
-- Name: pack_21122024_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122024_pkey;


--
-- TOC entry 6383 (class 0 OID 0)
-- Name: pack_21122025_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122025_id_pickup_date_idx;


--
-- TOC entry 6384 (class 0 OID 0)
-- Name: pack_21122025_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122025_pkey;


--
-- TOC entry 6385 (class 0 OID 0)
-- Name: pack_21122026_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122026_id_pickup_date_idx;


--
-- TOC entry 6386 (class 0 OID 0)
-- Name: pack_21122026_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122026_pkey;


--
-- TOC entry 6387 (class 0 OID 0)
-- Name: pack_21122027_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122027_id_pickup_date_idx;


--
-- TOC entry 6388 (class 0 OID 0)
-- Name: pack_21122027_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122027_pkey;


--
-- TOC entry 6389 (class 0 OID 0)
-- Name: pack_21122028_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122028_id_pickup_date_idx;


--
-- TOC entry 6390 (class 0 OID 0)
-- Name: pack_21122028_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122028_pkey;


--
-- TOC entry 6391 (class 0 OID 0)
-- Name: pack_21122029_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122029_id_pickup_date_idx;


--
-- TOC entry 6392 (class 0 OID 0)
-- Name: pack_21122029_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122029_pkey;


--
-- TOC entry 6393 (class 0 OID 0)
-- Name: pack_21122030_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122030_id_pickup_date_idx;


--
-- TOC entry 6394 (class 0 OID 0)
-- Name: pack_21122030_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122030_pkey;


--
-- TOC entry 6395 (class 0 OID 0)
-- Name: pack_21122031_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_21122031_id_pickup_date_idx;


--
-- TOC entry 6396 (class 0 OID 0)
-- Name: pack_21122031_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_21122031_pkey;


--
-- TOC entry 6397 (class 0 OID 0)
-- Name: pack_others_id_pickup_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_pack_idx ATTACH PARTITION public.pack_others_id_pickup_date_idx;


--
-- TOC entry 6398 (class 0 OID 0)
-- Name: pack_others_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pack_pkey ATTACH PARTITION public.pack_others_pkey;


--
-- TOC entry 6401 (class 0 OID 0)
-- Name: patient_10000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_10000_id_match_id_idx;


--
-- TOC entry 6402 (class 0 OID 0)
-- Name: patient_10000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_10000_pkey;


--
-- TOC entry 6399 (class 0 OID 0)
-- Name: patient_1000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_1000_id_match_id_idx;


--
-- TOC entry 6400 (class 0 OID 0)
-- Name: patient_1000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_1000_pkey;


--
-- TOC entry 6403 (class 0 OID 0)
-- Name: patient_11000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_11000_id_match_id_idx;


--
-- TOC entry 6404 (class 0 OID 0)
-- Name: patient_11000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_11000_pkey;


--
-- TOC entry 6405 (class 0 OID 0)
-- Name: patient_12000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_12000_id_match_id_idx;


--
-- TOC entry 6406 (class 0 OID 0)
-- Name: patient_12000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_12000_pkey;


--
-- TOC entry 6407 (class 0 OID 0)
-- Name: patient_13000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_13000_id_match_id_idx;


--
-- TOC entry 6408 (class 0 OID 0)
-- Name: patient_13000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_13000_pkey;


--
-- TOC entry 6409 (class 0 OID 0)
-- Name: patient_14000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_14000_id_match_id_idx;


--
-- TOC entry 6410 (class 0 OID 0)
-- Name: patient_14000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_14000_pkey;


--
-- TOC entry 6411 (class 0 OID 0)
-- Name: patient_15000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_15000_id_match_id_idx;


--
-- TOC entry 6412 (class 0 OID 0)
-- Name: patient_15000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_15000_pkey;


--
-- TOC entry 6413 (class 0 OID 0)
-- Name: patient_16000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_16000_id_match_id_idx;


--
-- TOC entry 6414 (class 0 OID 0)
-- Name: patient_16000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_16000_pkey;


--
-- TOC entry 6415 (class 0 OID 0)
-- Name: patient_17000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_17000_id_match_id_idx;


--
-- TOC entry 6416 (class 0 OID 0)
-- Name: patient_17000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_17000_pkey;


--
-- TOC entry 6417 (class 0 OID 0)
-- Name: patient_18000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_18000_id_match_id_idx;


--
-- TOC entry 6418 (class 0 OID 0)
-- Name: patient_18000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_18000_pkey;


--
-- TOC entry 6419 (class 0 OID 0)
-- Name: patient_19000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_19000_id_match_id_idx;


--
-- TOC entry 6420 (class 0 OID 0)
-- Name: patient_19000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_19000_pkey;


--
-- TOC entry 6423 (class 0 OID 0)
-- Name: patient_20000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_20000_id_match_id_idx;


--
-- TOC entry 6424 (class 0 OID 0)
-- Name: patient_20000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_20000_pkey;


--
-- TOC entry 6421 (class 0 OID 0)
-- Name: patient_2000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_2000_id_match_id_idx;


--
-- TOC entry 6422 (class 0 OID 0)
-- Name: patient_2000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_2000_pkey;


--
-- TOC entry 6425 (class 0 OID 0)
-- Name: patient_21000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_21000_id_match_id_idx;


--
-- TOC entry 6426 (class 0 OID 0)
-- Name: patient_21000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_21000_pkey;


--
-- TOC entry 6427 (class 0 OID 0)
-- Name: patient_22000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_22000_id_match_id_idx;


--
-- TOC entry 6428 (class 0 OID 0)
-- Name: patient_22000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_22000_pkey;


--
-- TOC entry 6429 (class 0 OID 0)
-- Name: patient_23000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_23000_id_match_id_idx;


--
-- TOC entry 6430 (class 0 OID 0)
-- Name: patient_23000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_23000_pkey;


--
-- TOC entry 6431 (class 0 OID 0)
-- Name: patient_24000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_24000_id_match_id_idx;


--
-- TOC entry 6432 (class 0 OID 0)
-- Name: patient_24000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_24000_pkey;


--
-- TOC entry 6433 (class 0 OID 0)
-- Name: patient_25000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_25000_id_match_id_idx;


--
-- TOC entry 6434 (class 0 OID 0)
-- Name: patient_25000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_25000_pkey;


--
-- TOC entry 6435 (class 0 OID 0)
-- Name: patient_26000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_26000_id_match_id_idx;


--
-- TOC entry 6436 (class 0 OID 0)
-- Name: patient_26000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_26000_pkey;


--
-- TOC entry 6437 (class 0 OID 0)
-- Name: patient_27000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_27000_id_match_id_idx;


--
-- TOC entry 6438 (class 0 OID 0)
-- Name: patient_27000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_27000_pkey;


--
-- TOC entry 6439 (class 0 OID 0)
-- Name: patient_28000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_28000_id_match_id_idx;


--
-- TOC entry 6440 (class 0 OID 0)
-- Name: patient_28000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_28000_pkey;


--
-- TOC entry 6441 (class 0 OID 0)
-- Name: patient_29000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_29000_id_match_id_idx;


--
-- TOC entry 6442 (class 0 OID 0)
-- Name: patient_29000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_29000_pkey;


--
-- TOC entry 6445 (class 0 OID 0)
-- Name: patient_30000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_30000_id_match_id_idx;


--
-- TOC entry 6446 (class 0 OID 0)
-- Name: patient_30000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_30000_pkey;


--
-- TOC entry 6443 (class 0 OID 0)
-- Name: patient_3000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_3000_id_match_id_idx;


--
-- TOC entry 6444 (class 0 OID 0)
-- Name: patient_3000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_3000_pkey;


--
-- TOC entry 6447 (class 0 OID 0)
-- Name: patient_31000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_31000_id_match_id_idx;


--
-- TOC entry 6448 (class 0 OID 0)
-- Name: patient_31000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_31000_pkey;


--
-- TOC entry 6449 (class 0 OID 0)
-- Name: patient_32000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_32000_id_match_id_idx;


--
-- TOC entry 6450 (class 0 OID 0)
-- Name: patient_32000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_32000_pkey;


--
-- TOC entry 6451 (class 0 OID 0)
-- Name: patient_33000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_33000_id_match_id_idx;


--
-- TOC entry 6452 (class 0 OID 0)
-- Name: patient_33000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_33000_pkey;


--
-- TOC entry 6453 (class 0 OID 0)
-- Name: patient_34000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_34000_id_match_id_idx;


--
-- TOC entry 6454 (class 0 OID 0)
-- Name: patient_34000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_34000_pkey;


--
-- TOC entry 6455 (class 0 OID 0)
-- Name: patient_35000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_35000_id_match_id_idx;


--
-- TOC entry 6456 (class 0 OID 0)
-- Name: patient_35000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_35000_pkey;


--
-- TOC entry 6457 (class 0 OID 0)
-- Name: patient_36000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_36000_id_match_id_idx;


--
-- TOC entry 6458 (class 0 OID 0)
-- Name: patient_36000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_36000_pkey;


--
-- TOC entry 6459 (class 0 OID 0)
-- Name: patient_37000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_37000_id_match_id_idx;


--
-- TOC entry 6460 (class 0 OID 0)
-- Name: patient_37000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_37000_pkey;


--
-- TOC entry 6461 (class 0 OID 0)
-- Name: patient_38000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_38000_id_match_id_idx;


--
-- TOC entry 6462 (class 0 OID 0)
-- Name: patient_38000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_38000_pkey;


--
-- TOC entry 6463 (class 0 OID 0)
-- Name: patient_39000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_39000_id_match_id_idx;


--
-- TOC entry 6464 (class 0 OID 0)
-- Name: patient_39000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_39000_pkey;


--
-- TOC entry 6467 (class 0 OID 0)
-- Name: patient_40000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_40000_id_match_id_idx;


--
-- TOC entry 6468 (class 0 OID 0)
-- Name: patient_40000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_40000_pkey;


--
-- TOC entry 6465 (class 0 OID 0)
-- Name: patient_4000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_4000_id_match_id_idx;


--
-- TOC entry 6466 (class 0 OID 0)
-- Name: patient_4000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_4000_pkey;


--
-- TOC entry 6469 (class 0 OID 0)
-- Name: patient_41000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_41000_id_match_id_idx;


--
-- TOC entry 6470 (class 0 OID 0)
-- Name: patient_41000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_41000_pkey;


--
-- TOC entry 6471 (class 0 OID 0)
-- Name: patient_42000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_42000_id_match_id_idx;


--
-- TOC entry 6472 (class 0 OID 0)
-- Name: patient_42000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_42000_pkey;


--
-- TOC entry 6473 (class 0 OID 0)
-- Name: patient_43000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_43000_id_match_id_idx;


--
-- TOC entry 6474 (class 0 OID 0)
-- Name: patient_43000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_43000_pkey;


--
-- TOC entry 6475 (class 0 OID 0)
-- Name: patient_44000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_44000_id_match_id_idx;


--
-- TOC entry 6476 (class 0 OID 0)
-- Name: patient_44000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_44000_pkey;


--
-- TOC entry 6477 (class 0 OID 0)
-- Name: patient_45000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_45000_id_match_id_idx;


--
-- TOC entry 6478 (class 0 OID 0)
-- Name: patient_45000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_45000_pkey;


--
-- TOC entry 6479 (class 0 OID 0)
-- Name: patient_46000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_46000_id_match_id_idx;


--
-- TOC entry 6480 (class 0 OID 0)
-- Name: patient_46000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_46000_pkey;


--
-- TOC entry 6481 (class 0 OID 0)
-- Name: patient_47000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_47000_id_match_id_idx;


--
-- TOC entry 6482 (class 0 OID 0)
-- Name: patient_47000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_47000_pkey;


--
-- TOC entry 6483 (class 0 OID 0)
-- Name: patient_48000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_48000_id_match_id_idx;


--
-- TOC entry 6484 (class 0 OID 0)
-- Name: patient_48000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_48000_pkey;


--
-- TOC entry 6485 (class 0 OID 0)
-- Name: patient_49000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_49000_id_match_id_idx;


--
-- TOC entry 6486 (class 0 OID 0)
-- Name: patient_49000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_49000_pkey;


--
-- TOC entry 6489 (class 0 OID 0)
-- Name: patient_50000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_50000_id_match_id_idx;


--
-- TOC entry 6490 (class 0 OID 0)
-- Name: patient_50000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_50000_pkey;


--
-- TOC entry 6487 (class 0 OID 0)
-- Name: patient_5000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_5000_id_match_id_idx;


--
-- TOC entry 6488 (class 0 OID 0)
-- Name: patient_5000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_5000_pkey;


--
-- TOC entry 6491 (class 0 OID 0)
-- Name: patient_6000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_6000_id_match_id_idx;


--
-- TOC entry 6492 (class 0 OID 0)
-- Name: patient_6000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_6000_pkey;


--
-- TOC entry 6493 (class 0 OID 0)
-- Name: patient_7000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_7000_id_match_id_idx;


--
-- TOC entry 6494 (class 0 OID 0)
-- Name: patient_7000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_7000_pkey;


--
-- TOC entry 6495 (class 0 OID 0)
-- Name: patient_8000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_8000_id_match_id_idx;


--
-- TOC entry 6496 (class 0 OID 0)
-- Name: patient_8000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_8000_pkey;


--
-- TOC entry 6497 (class 0 OID 0)
-- Name: patient_9000_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_9000_id_match_id_idx;


--
-- TOC entry 6498 (class 0 OID 0)
-- Name: patient_9000_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_9000_pkey;


--
-- TOC entry 6499 (class 0 OID 0)
-- Name: patient_others_id_match_id_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patient_idx ATTACH PARTITION public.patient_others_id_match_id_idx;


--
-- TOC entry 6500 (class 0 OID 0)
-- Name: patient_others_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_pkey ATTACH PARTITION public.patient_others_pkey;


--
-- TOC entry 6501 (class 0 OID 0)
-- Name: patient_service_identifier_21122008_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122008_id_start_date_idx;


--
-- TOC entry 6502 (class 0 OID 0)
-- Name: patient_service_identifier_21122008_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122008_pkey;


--
-- TOC entry 6503 (class 0 OID 0)
-- Name: patient_service_identifier_21122009_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122009_id_start_date_idx;


--
-- TOC entry 6504 (class 0 OID 0)
-- Name: patient_service_identifier_21122009_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122009_pkey;


--
-- TOC entry 6505 (class 0 OID 0)
-- Name: patient_service_identifier_21122010_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122010_id_start_date_idx;


--
-- TOC entry 6506 (class 0 OID 0)
-- Name: patient_service_identifier_21122010_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122010_pkey;


--
-- TOC entry 6507 (class 0 OID 0)
-- Name: patient_service_identifier_21122011_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122011_id_start_date_idx;


--
-- TOC entry 6508 (class 0 OID 0)
-- Name: patient_service_identifier_21122011_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122011_pkey;


--
-- TOC entry 6509 (class 0 OID 0)
-- Name: patient_service_identifier_21122012_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122012_id_start_date_idx;


--
-- TOC entry 6510 (class 0 OID 0)
-- Name: patient_service_identifier_21122012_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122012_pkey;


--
-- TOC entry 6511 (class 0 OID 0)
-- Name: patient_service_identifier_21122013_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122013_id_start_date_idx;


--
-- TOC entry 6512 (class 0 OID 0)
-- Name: patient_service_identifier_21122013_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122013_pkey;


--
-- TOC entry 6513 (class 0 OID 0)
-- Name: patient_service_identifier_21122014_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122014_id_start_date_idx;


--
-- TOC entry 6514 (class 0 OID 0)
-- Name: patient_service_identifier_21122014_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122014_pkey;


--
-- TOC entry 6515 (class 0 OID 0)
-- Name: patient_service_identifier_21122015_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122015_id_start_date_idx;


--
-- TOC entry 6516 (class 0 OID 0)
-- Name: patient_service_identifier_21122015_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122015_pkey;


--
-- TOC entry 6517 (class 0 OID 0)
-- Name: patient_service_identifier_21122016_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122016_id_start_date_idx;


--
-- TOC entry 6518 (class 0 OID 0)
-- Name: patient_service_identifier_21122016_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122016_pkey;


--
-- TOC entry 6519 (class 0 OID 0)
-- Name: patient_service_identifier_21122017_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122017_id_start_date_idx;


--
-- TOC entry 6520 (class 0 OID 0)
-- Name: patient_service_identifier_21122017_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122017_pkey;


--
-- TOC entry 6521 (class 0 OID 0)
-- Name: patient_service_identifier_21122018_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122018_id_start_date_idx;


--
-- TOC entry 6522 (class 0 OID 0)
-- Name: patient_service_identifier_21122018_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122018_pkey;


--
-- TOC entry 6523 (class 0 OID 0)
-- Name: patient_service_identifier_21122019_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122019_id_start_date_idx;


--
-- TOC entry 6524 (class 0 OID 0)
-- Name: patient_service_identifier_21122019_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122019_pkey;


--
-- TOC entry 6525 (class 0 OID 0)
-- Name: patient_service_identifier_21122020_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122020_id_start_date_idx;


--
-- TOC entry 6526 (class 0 OID 0)
-- Name: patient_service_identifier_21122020_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122020_pkey;


--
-- TOC entry 6527 (class 0 OID 0)
-- Name: patient_service_identifier_21122021_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122021_id_start_date_idx;


--
-- TOC entry 6528 (class 0 OID 0)
-- Name: patient_service_identifier_21122021_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122021_pkey;


--
-- TOC entry 6529 (class 0 OID 0)
-- Name: patient_service_identifier_21122022_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122022_id_start_date_idx;


--
-- TOC entry 6530 (class 0 OID 0)
-- Name: patient_service_identifier_21122022_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122022_pkey;


--
-- TOC entry 6531 (class 0 OID 0)
-- Name: patient_service_identifier_21122023_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122023_id_start_date_idx;


--
-- TOC entry 6532 (class 0 OID 0)
-- Name: patient_service_identifier_21122023_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122023_pkey;


--
-- TOC entry 6533 (class 0 OID 0)
-- Name: patient_service_identifier_21122024_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122024_id_start_date_idx;


--
-- TOC entry 6534 (class 0 OID 0)
-- Name: patient_service_identifier_21122024_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122024_pkey;


--
-- TOC entry 6535 (class 0 OID 0)
-- Name: patient_service_identifier_21122025_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122025_id_start_date_idx;


--
-- TOC entry 6536 (class 0 OID 0)
-- Name: patient_service_identifier_21122025_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122025_pkey;


--
-- TOC entry 6537 (class 0 OID 0)
-- Name: patient_service_identifier_21122027_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122027_id_start_date_idx;


--
-- TOC entry 6538 (class 0 OID 0)
-- Name: patient_service_identifier_21122027_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122027_pkey;


--
-- TOC entry 6539 (class 0 OID 0)
-- Name: patient_service_identifier_21122028_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122028_id_start_date_idx;


--
-- TOC entry 6540 (class 0 OID 0)
-- Name: patient_service_identifier_21122028_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122028_pkey;


--
-- TOC entry 6541 (class 0 OID 0)
-- Name: patient_service_identifier_21122029_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122029_id_start_date_idx;


--
-- TOC entry 6542 (class 0 OID 0)
-- Name: patient_service_identifier_21122029_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122029_pkey;


--
-- TOC entry 6543 (class 0 OID 0)
-- Name: patient_service_identifier_21122030_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122030_id_start_date_idx;


--
-- TOC entry 6544 (class 0 OID 0)
-- Name: patient_service_identifier_21122030_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122030_pkey;


--
-- TOC entry 6545 (class 0 OID 0)
-- Name: patient_service_identifier_21122031_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21122031_id_start_date_idx;


--
-- TOC entry 6546 (class 0 OID 0)
-- Name: patient_service_identifier_21122031_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21122031_pkey;


--
-- TOC entry 6547 (class 0 OID 0)
-- Name: patient_service_identifier_21212026_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_21212026_id_start_date_idx;


--
-- TOC entry 6548 (class 0 OID 0)
-- Name: patient_service_identifier_21212026_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_21212026_pkey;


--
-- TOC entry 6549 (class 0 OID 0)
-- Name: patient_service_identifier_others_id_start_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientserviceidentifier_idx ATTACH PARTITION public.patient_service_identifier_others_id_start_date_idx;


--
-- TOC entry 6550 (class 0 OID 0)
-- Name: patient_service_identifier_others_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_service_identifier_pkey ATTACH PARTITION public.patient_service_identifier_others_pkey;


--
-- TOC entry 6551 (class 0 OID 0)
-- Name: patient_visit_21122008_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122008_id_visit_date_idx;


--
-- TOC entry 6552 (class 0 OID 0)
-- Name: patient_visit_21122008_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122008_pkey;


--
-- TOC entry 6553 (class 0 OID 0)
-- Name: patient_visit_21122009_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122009_id_visit_date_idx;


--
-- TOC entry 6554 (class 0 OID 0)
-- Name: patient_visit_21122009_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122009_pkey;


--
-- TOC entry 6555 (class 0 OID 0)
-- Name: patient_visit_21122010_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122010_id_visit_date_idx;


--
-- TOC entry 6556 (class 0 OID 0)
-- Name: patient_visit_21122010_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122010_pkey;


--
-- TOC entry 6557 (class 0 OID 0)
-- Name: patient_visit_21122011_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122011_id_visit_date_idx;


--
-- TOC entry 6558 (class 0 OID 0)
-- Name: patient_visit_21122011_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122011_pkey;


--
-- TOC entry 6559 (class 0 OID 0)
-- Name: patient_visit_21122012_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122012_id_visit_date_idx;


--
-- TOC entry 6560 (class 0 OID 0)
-- Name: patient_visit_21122012_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122012_pkey;


--
-- TOC entry 6561 (class 0 OID 0)
-- Name: patient_visit_21122013_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122013_id_visit_date_idx;


--
-- TOC entry 6562 (class 0 OID 0)
-- Name: patient_visit_21122013_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122013_pkey;


--
-- TOC entry 6563 (class 0 OID 0)
-- Name: patient_visit_21122014_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122014_id_visit_date_idx;


--
-- TOC entry 6564 (class 0 OID 0)
-- Name: patient_visit_21122014_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122014_pkey;


--
-- TOC entry 6565 (class 0 OID 0)
-- Name: patient_visit_21122015_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122015_id_visit_date_idx;


--
-- TOC entry 6566 (class 0 OID 0)
-- Name: patient_visit_21122015_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122015_pkey;


--
-- TOC entry 6567 (class 0 OID 0)
-- Name: patient_visit_21122016_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122016_id_visit_date_idx;


--
-- TOC entry 6568 (class 0 OID 0)
-- Name: patient_visit_21122016_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122016_pkey;


--
-- TOC entry 6569 (class 0 OID 0)
-- Name: patient_visit_21122017_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122017_id_visit_date_idx;


--
-- TOC entry 6570 (class 0 OID 0)
-- Name: patient_visit_21122017_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122017_pkey;


--
-- TOC entry 6571 (class 0 OID 0)
-- Name: patient_visit_21122018_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122018_id_visit_date_idx;


--
-- TOC entry 6572 (class 0 OID 0)
-- Name: patient_visit_21122018_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122018_pkey;


--
-- TOC entry 6573 (class 0 OID 0)
-- Name: patient_visit_21122019_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122019_id_visit_date_idx;


--
-- TOC entry 6574 (class 0 OID 0)
-- Name: patient_visit_21122019_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122019_pkey;


--
-- TOC entry 6575 (class 0 OID 0)
-- Name: patient_visit_21122020_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122020_id_visit_date_idx;


--
-- TOC entry 6576 (class 0 OID 0)
-- Name: patient_visit_21122020_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122020_pkey;


--
-- TOC entry 6577 (class 0 OID 0)
-- Name: patient_visit_21122021_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122021_id_visit_date_idx;


--
-- TOC entry 6578 (class 0 OID 0)
-- Name: patient_visit_21122021_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122021_pkey;


--
-- TOC entry 6579 (class 0 OID 0)
-- Name: patient_visit_21122022_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122022_id_visit_date_idx;


--
-- TOC entry 6580 (class 0 OID 0)
-- Name: patient_visit_21122022_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122022_pkey;


--
-- TOC entry 6581 (class 0 OID 0)
-- Name: patient_visit_21122023_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122023_id_visit_date_idx;


--
-- TOC entry 6582 (class 0 OID 0)
-- Name: patient_visit_21122023_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122023_pkey;


--
-- TOC entry 6583 (class 0 OID 0)
-- Name: patient_visit_21122024_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122024_id_visit_date_idx;


--
-- TOC entry 6584 (class 0 OID 0)
-- Name: patient_visit_21122024_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122024_pkey;


--
-- TOC entry 6585 (class 0 OID 0)
-- Name: patient_visit_21122025_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122025_id_visit_date_idx;


--
-- TOC entry 6586 (class 0 OID 0)
-- Name: patient_visit_21122025_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122025_pkey;


--
-- TOC entry 6587 (class 0 OID 0)
-- Name: patient_visit_21122026_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122026_id_visit_date_idx;


--
-- TOC entry 6588 (class 0 OID 0)
-- Name: patient_visit_21122026_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122026_pkey;


--
-- TOC entry 6589 (class 0 OID 0)
-- Name: patient_visit_21122027_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122027_id_visit_date_idx;


--
-- TOC entry 6590 (class 0 OID 0)
-- Name: patient_visit_21122027_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122027_pkey;


--
-- TOC entry 6591 (class 0 OID 0)
-- Name: patient_visit_21122028_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122028_id_visit_date_idx;


--
-- TOC entry 6592 (class 0 OID 0)
-- Name: patient_visit_21122028_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122028_pkey;


--
-- TOC entry 6593 (class 0 OID 0)
-- Name: patient_visit_21122029_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122029_id_visit_date_idx;


--
-- TOC entry 6594 (class 0 OID 0)
-- Name: patient_visit_21122029_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122029_pkey;


--
-- TOC entry 6595 (class 0 OID 0)
-- Name: patient_visit_21122030_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122030_id_visit_date_idx;


--
-- TOC entry 6596 (class 0 OID 0)
-- Name: patient_visit_21122030_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122030_pkey;


--
-- TOC entry 6597 (class 0 OID 0)
-- Name: patient_visit_21122031_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_21122031_id_visit_date_idx;


--
-- TOC entry 6598 (class 0 OID 0)
-- Name: patient_visit_21122031_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_21122031_pkey;


--
-- TOC entry 6599 (class 0 OID 0)
-- Name: patient_visit_others_id_visit_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_patientvisit_idx ATTACH PARTITION public.patient_visit_others_id_visit_date_idx;


--
-- TOC entry 6600 (class 0 OID 0)
-- Name: patient_visit_others_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.patient_visit_pkey ATTACH PARTITION public.patient_visit_others_pkey;


--
-- TOC entry 6601 (class 0 OID 0)
-- Name: prescription_21122008_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122008_id_prescription_date_idx;


--
-- TOC entry 6602 (class 0 OID 0)
-- Name: prescription_21122008_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122008_pkey;


--
-- TOC entry 6603 (class 0 OID 0)
-- Name: prescription_21122009_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122009_id_prescription_date_idx;


--
-- TOC entry 6604 (class 0 OID 0)
-- Name: prescription_21122009_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122009_pkey;


--
-- TOC entry 6605 (class 0 OID 0)
-- Name: prescription_21122010_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122010_id_prescription_date_idx;


--
-- TOC entry 6606 (class 0 OID 0)
-- Name: prescription_21122010_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122010_pkey;


--
-- TOC entry 6607 (class 0 OID 0)
-- Name: prescription_21122011_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122011_id_prescription_date_idx;


--
-- TOC entry 6608 (class 0 OID 0)
-- Name: prescription_21122011_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122011_pkey;


--
-- TOC entry 6609 (class 0 OID 0)
-- Name: prescription_21122012_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122012_id_prescription_date_idx;


--
-- TOC entry 6610 (class 0 OID 0)
-- Name: prescription_21122012_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122012_pkey;


--
-- TOC entry 6611 (class 0 OID 0)
-- Name: prescription_21122013_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122013_id_prescription_date_idx;


--
-- TOC entry 6612 (class 0 OID 0)
-- Name: prescription_21122013_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122013_pkey;


--
-- TOC entry 6613 (class 0 OID 0)
-- Name: prescription_21122014_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122014_id_prescription_date_idx;


--
-- TOC entry 6614 (class 0 OID 0)
-- Name: prescription_21122014_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122014_pkey;


--
-- TOC entry 6615 (class 0 OID 0)
-- Name: prescription_21122015_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122015_id_prescription_date_idx;


--
-- TOC entry 6616 (class 0 OID 0)
-- Name: prescription_21122015_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122015_pkey;


--
-- TOC entry 6617 (class 0 OID 0)
-- Name: prescription_21122016_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122016_id_prescription_date_idx;


--
-- TOC entry 6618 (class 0 OID 0)
-- Name: prescription_21122016_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122016_pkey;


--
-- TOC entry 6619 (class 0 OID 0)
-- Name: prescription_21122017_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122017_id_prescription_date_idx;


--
-- TOC entry 6620 (class 0 OID 0)
-- Name: prescription_21122017_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122017_pkey;


--
-- TOC entry 6621 (class 0 OID 0)
-- Name: prescription_21122018_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122018_id_prescription_date_idx;


--
-- TOC entry 6622 (class 0 OID 0)
-- Name: prescription_21122018_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122018_pkey;


--
-- TOC entry 6623 (class 0 OID 0)
-- Name: prescription_21122019_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122019_id_prescription_date_idx;


--
-- TOC entry 6624 (class 0 OID 0)
-- Name: prescription_21122019_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122019_pkey;


--
-- TOC entry 6625 (class 0 OID 0)
-- Name: prescription_21122020_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122020_id_prescription_date_idx;


--
-- TOC entry 6626 (class 0 OID 0)
-- Name: prescription_21122020_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122020_pkey;


--
-- TOC entry 6627 (class 0 OID 0)
-- Name: prescription_21122021_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122021_id_prescription_date_idx;


--
-- TOC entry 6628 (class 0 OID 0)
-- Name: prescription_21122021_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122021_pkey;


--
-- TOC entry 6629 (class 0 OID 0)
-- Name: prescription_21122022_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122022_id_prescription_date_idx;


--
-- TOC entry 6630 (class 0 OID 0)
-- Name: prescription_21122022_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122022_pkey;


--
-- TOC entry 6631 (class 0 OID 0)
-- Name: prescription_21122023_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122023_id_prescription_date_idx;


--
-- TOC entry 6632 (class 0 OID 0)
-- Name: prescription_21122023_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122023_pkey;


--
-- TOC entry 6633 (class 0 OID 0)
-- Name: prescription_21122024_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122024_id_prescription_date_idx;


--
-- TOC entry 6634 (class 0 OID 0)
-- Name: prescription_21122024_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122024_pkey;


--
-- TOC entry 6635 (class 0 OID 0)
-- Name: prescription_21122025_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122025_id_prescription_date_idx;


--
-- TOC entry 6636 (class 0 OID 0)
-- Name: prescription_21122025_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122025_pkey;


--
-- TOC entry 6637 (class 0 OID 0)
-- Name: prescription_21122026_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122026_id_prescription_date_idx;


--
-- TOC entry 6638 (class 0 OID 0)
-- Name: prescription_21122026_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122026_pkey;


--
-- TOC entry 6639 (class 0 OID 0)
-- Name: prescription_21122027_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122027_id_prescription_date_idx;


--
-- TOC entry 6640 (class 0 OID 0)
-- Name: prescription_21122027_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122027_pkey;


--
-- TOC entry 6641 (class 0 OID 0)
-- Name: prescription_21122028_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122028_id_prescription_date_idx;


--
-- TOC entry 6642 (class 0 OID 0)
-- Name: prescription_21122028_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122028_pkey;


--
-- TOC entry 6643 (class 0 OID 0)
-- Name: prescription_21122029_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122029_id_prescription_date_idx;


--
-- TOC entry 6644 (class 0 OID 0)
-- Name: prescription_21122029_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122029_pkey;


--
-- TOC entry 6645 (class 0 OID 0)
-- Name: prescription_21122030_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122030_id_prescription_date_idx;


--
-- TOC entry 6646 (class 0 OID 0)
-- Name: prescription_21122030_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122030_pkey;


--
-- TOC entry 6647 (class 0 OID 0)
-- Name: prescription_21122031_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_21122031_id_prescription_date_idx;


--
-- TOC entry 6648 (class 0 OID 0)
-- Name: prescription_21122031_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_21122031_pkey;


--
-- TOC entry 6649 (class 0 OID 0)
-- Name: prescription_others_id_prescription_date_idx; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.pk_prescription_idx ATTACH PARTITION public.prescription_others_id_prescription_date_idx;


--
-- TOC entry 6650 (class 0 OID 0)
-- Name: prescription_others_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.prescription_pkey ATTACH PARTITION public.prescription_others_pkey;


--
-- TOC entry 6919 (class 2618 OID 124650)
-- Name: patient_info_group_view _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.patient_info_group_view AS
 SELECT DISTINCT ON (p.id) concat(p.first_names, ' ', p.middle_names, ' ', p.last_names) AS full_name,
    psi.value AS nid,
    max(pr.prescription_date) AS last_prescription_date,
    max(pk.pickup_date) AS last_pickup_date,
    max(pk.next_pick_up_date) AS next_pickup_date,
        CASE
            WHEN (((COALESCE(d.weeks, 0) - COALESCE((sum(pk.weeks_supply))::integer, 0)) / 4) < 0) THEN 0
            ELSE ((COALESCE(d.weeks, 0) - COALESCE((sum(pk.weeks_supply))::integer, 0)) / 4)
        END AS validade,
    max(pr2.prescription_date) AS last_prescription_date_member,
        CASE
            WHEN (((COALESCE(d2.weeks, 0) - COALESCE((sum(pk2.weeks_supply))::integer, 0)) / 4) < 0) THEN 0
            ELSE ((COALESCE(d2.weeks, 0) - COALESCE((sum(pk2.weeks_supply))::integer, 0)) / 4)
        END AS validade_nova,
    p.id AS patientid,
    gm.id AS groupmemberid,
    psi.id AS patientserviceid,
    pvd.episode_id AS episodeid,
    gm.end_date AS membership_enddate,
    gi.id AS group_id
   FROM ((((((((((((((public.patient p
     JOIN public.patient_service_identifier psi ON (((p.id)::text = (psi.patient_id)::text)))
     JOIN public.patient_visit pv ON (((p.id)::text = (pv.patient_id)::text)))
     JOIN public.patient_visit_details pvd ON (((pv.id)::text = (pvd.patient_visit_id)::text)))
     JOIN public.prescription pr ON (((pvd.prescription_id)::text = (pr.id)::text)))
     JOIN public.pack pk ON (((pvd.pack_id)::text = (pk.id)::text)))
     JOIN public.group_member gm ON (((gm.patient_id)::text = (p.id)::text)))
     JOIN public.group_info gi ON (((gi.id)::text = (gm.group_id)::text)))
     JOIN public.duration d ON (((d.id)::text = (pr.duration_id)::text)))
     LEFT JOIN public.group_member_prescription gmp ON (((gmp.member_id)::text = (gm.id)::text)))
     LEFT JOIN public.prescription pr2 ON (((pr2.id)::text = (gmp.prescription_id)::text)))
     LEFT JOIN public.duration d2 ON (((d2.id)::text = (pr2.duration_id)::text)))
     LEFT JOIN public.patient_visit_details pvd2 ON (((pvd2.prescription_id)::text = (pr2.id)::text)))
     LEFT JOIN public.episode ep ON (((ep.id)::text = (pvd.episode_id)::text)))
     LEFT JOIN public.pack pk2 ON (((pvd2.pack_id)::text = (pk2.id)::text)))
  WHERE (((p.id)::text IN ( SELECT group_member.patient_id
           FROM public.group_member)) AND ((ep.patient_service_identifier_id)::text = (psi.id)::text) AND ((psi.service_id)::text = (gi.service_id)::text))
  GROUP BY p.id, p.first_names, p.middle_names, p.last_names, psi.value, gi.id, d.weeks, pr.prescription_date, pk.pickup_date, d2.weeks, gm.id, psi.id, pvd.episode_id
  ORDER BY p.id, gm.end_date DESC, pr.prescription_date DESC, pk.pickup_date DESC;


--
-- TOC entry 6712 (class 2606 OID 126581)
-- Name: group_pack fk118d861taipyrvsm01w2h4ivp; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_pack
    ADD CONSTRAINT fk118d861taipyrvsm01w2h4ivp FOREIGN KEY (header_id) REFERENCES public.group_pack_header(id);


--
-- TOC entry 6688 (class 2606 OID 126586)
-- Name: refered_stock_moviment fk1ccnjnyubfadxq3ihuhv9h1eo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refered_stock_moviment
    ADD CONSTRAINT fk1ccnjnyubfadxq3ihuhv9h1eo FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6738 (class 2606 OID 126591)
-- Name: prescription fk1ppr8greedyrey8nchpr0v4dn; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.prescription
    ADD CONSTRAINT fk1ppr8greedyrey8nchpr0v4dn FOREIGN KEY (doctor_id) REFERENCES public.doctor(id);


--
-- TOC entry 6672 (class 2606 OID 126671)
-- Name: district fk276utu38g5lgqeth6pwfm3rw2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.district
    ADD CONSTRAINT fk276utu38g5lgqeth6pwfm3rw2 FOREIGN KEY (province_id) REFERENCES public.province(id);


--
-- TOC entry 6689 (class 2606 OID 126676)
-- Name: stock fk28u6gfn999w5qm1fw7ch7gu64; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT fk28u6gfn999w5qm1fw7ch7gu64 FOREIGN KEY (drug_id) REFERENCES public.drug(id);


--
-- TOC entry 6750 (class 2606 OID 126681)
-- Name: prescription_detail fk29dglqq6ktv57lshoy1pvjody; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_detail
    ADD CONSTRAINT fk29dglqq6ktv57lshoy1pvjody FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6769 (class 2606 OID 126686)
-- Name: tbscreening fk2leg14w4nocvt85llx626wyvw; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbscreening
    ADD CONSTRAINT fk2leg14w4nocvt85llx626wyvw FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6747 (class 2606 OID 126696)
-- Name: pregnancy_screening fk383s9bmmmpjun4fnh9scwu08c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pregnancy_screening
    ADD CONSTRAINT fk383s9bmmmpjun4fnh9scwu08c FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6662 (class 2606 OID 126701)
-- Name: clinical_service_attribute fk38g3g5l50xvp1fb61wcv206pu; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_attribute
    ADD CONSTRAINT fk38g3g5l50xvp1fb61wcv206pu FOREIGN KEY (clinical_service_id) REFERENCES public.clinical_service(id);


--
-- TOC entry 6760 (class 2606 OID 126706)
-- Name: service_patient fk3dggone4xid9jgxkafurd1yvp; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_patient
    ADD CONSTRAINT fk3dggone4xid9jgxkafurd1yvp FOREIGN KEY (stop_reason_id) REFERENCES public.start_stop_reason(id);


--
-- TOC entry 6667 (class 2606 OID 126716)
-- Name: clinical_service_clinical_service_attribute_type fk3okbx9y719dgej3eb0vhrja5b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_clinical_service_attribute_type
    ADD CONSTRAINT fk3okbx9y719dgej3eb0vhrja5b FOREIGN KEY (clinical_service_clinical_service_attributes_id) REFERENCES public.clinical_service(id);


--
-- TOC entry 6739 (class 2606 OID 126721)
-- Name: prescription fk3pqah6ubl23v17jddi2ncodih; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.prescription
    ADD CONSTRAINT fk3pqah6ubl23v17jddi2ncodih FOREIGN KEY (duration_id) REFERENCES public.duration(id);


--
-- TOC entry 6723 (class 2606 OID 126801)
-- Name: mmia_stock_sub_report_item fk3ttuxn2tut19mdv0rnl47ltmj; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mmia_stock_sub_report_item
    ADD CONSTRAINT fk3ttuxn2tut19mdv0rnl47ltmj FOREIGN KEY (mmia_report_id) REFERENCES public.mmia_report(id);


--
-- TOC entry 6669 (class 2606 OID 126806)
-- Name: clinical_service_therapeutic_regimens fk3uuihads31dtdd5dexk99b2px; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_therapeutic_regimens
    ADD CONSTRAINT fk3uuihads31dtdd5dexk99b2px FOREIGN KEY (clinical_service_id) REFERENCES public.clinical_service(id);


--
-- TOC entry 6668 (class 2606 OID 126811)
-- Name: clinical_service_clinical_service_attribute_type fk4725dxgjshhd2whxtom2q0kjo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_clinical_service_attribute_type
    ADD CONSTRAINT fk4725dxgjshhd2whxtom2q0kjo FOREIGN KEY (clinical_service_attribute_type_id) REFERENCES public.clinical_service_attribute_type(id);


--
-- TOC entry 6709 (class 2606 OID 126816)
-- Name: group_member fk4jcd8ax2icv54oq39iqinr0ml; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT fk4jcd8ax2icv54oq39iqinr0ml FOREIGN KEY (group_id) REFERENCES public.group_info(id);


--
-- TOC entry 6676 (class 2606 OID 126821)
-- Name: drug_distributor fk4lwcvjmxthus91kv6od5sh3vr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drug_distributor
    ADD CONSTRAINT fk4lwcvjmxthus91kv6od5sh3vr FOREIGN KEY (drug_id) REFERENCES public.drug(id);


--
-- TOC entry 6759 (class 2606 OID 126826)
-- Name: sec_user_role fk4tfj7kwsb49tyml9uuv6x8ggf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sec_user_role
    ADD CONSTRAINT fk4tfj7kwsb49tyml9uuv6x8ggf FOREIGN KEY (role_id) REFERENCES public.role(id);


--
-- TOC entry 6718 (class 2606 OID 126831)
-- Name: localidade fk4u70p6hopi7wbq603sop2l6c9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localidade
    ADD CONSTRAINT fk4u70p6hopi7wbq603sop2l6c9 FOREIGN KEY (posto_administrativo_id) REFERENCES public.posto_administrativo(id);


--
-- TOC entry 6761 (class 2606 OID 126836)
-- Name: service_patient fk58w0jybpq9haa4x09ao338aff; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_patient
    ADD CONSTRAINT fk58w0jybpq9haa4x09ao338aff FOREIGN KEY (start_reason_id) REFERENCES public.start_stop_reason(id);


--
-- TOC entry 6700 (class 2606 OID 126841)
-- Name: episode fk5fkridswisxl17ihqo3d1wkbq; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.episode
    ADD CONSTRAINT fk5fkridswisxl17ihqo3d1wkbq FOREIGN KEY (referral_clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6763 (class 2606 OID 126921)
-- Name: stock_center fk5lknybyi4cw9mkbqkfplwxdw9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_center
    ADD CONSTRAINT fk5lknybyi4cw9mkbqkfplwxdw9 FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6663 (class 2606 OID 126926)
-- Name: clinical_service_attribute fk5pv38jej6gjfiew6a33tveo9t; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_attribute
    ADD CONSTRAINT fk5pv38jej6gjfiew6a33tveo9t FOREIGN KEY (clinical_service_attribute_type_id) REFERENCES public.clinical_service_attribute_type(id);


--
-- TOC entry 6741 (class 2606 OID 126931)
-- Name: patient_service_identifier fk5uyxajk9vv2j3vraogcdgth9k; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.patient_service_identifier
    ADD CONSTRAINT fk5uyxajk9vv2j3vraogcdgth9k FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6664 (class 2606 OID 127011)
-- Name: clinical_service_clinic_sector fk62y9l0ysqskvy1b1j2nk22hqq; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_clinic_sector
    ADD CONSTRAINT fk62y9l0ysqskvy1b1j2nk22hqq FOREIGN KEY (clinical_service_clinic_sectors_id) REFERENCES public.clinical_service(id);


--
-- TOC entry 6744 (class 2606 OID 127016)
-- Name: patient_trans_reference fk6mmq6u3clown7ptl1hvpeji5v; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_trans_reference
    ADD CONSTRAINT fk6mmq6u3clown7ptl1hvpeji5v FOREIGN KEY (operation_type_id) REFERENCES public.patient_trans_reference_type(id);


--
-- TOC entry 6693 (class 2606 OID 127021)
-- Name: stock_adjustment fk6n1xb0ctby92rsu21war6yvwc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_adjustment
    ADD CONSTRAINT fk6n1xb0ctby92rsu21war6yvwc FOREIGN KEY (destruction_id) REFERENCES public.destroyed_stock(id);


--
-- TOC entry 6765 (class 2606 OID 127026)
-- Name: stock_distributor_batch fk6qx497r95pgk4xetxksmcfmd4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_distributor_batch
    ADD CONSTRAINT fk6qx497r95pgk4xetxksmcfmd4 FOREIGN KEY (drug_distributor_id) REFERENCES public.drug_distributor(id);


--
-- TOC entry 6748 (class 2606 OID 127031)
-- Name: prescribed_drug fk71diuumdtvcd2n8smw24j2p8a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescribed_drug
    ADD CONSTRAINT fk71diuumdtvcd2n8smw24j2p8a FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6683 (class 2606 OID 127036)
-- Name: packaged_drug fk7cutbjg9fu5llmd153t299by5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packaged_drug
    ADD CONSTRAINT fk7cutbjg9fu5llmd153t299by5 FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6717 (class 2606 OID 127041)
-- Name: inventory_report_response_inventory_report_temp fk7v4rdj0os1pos53jospdi3wxx; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_report_response_inventory_report_temp
    ADD CONSTRAINT fk7v4rdj0os1pos53jospdi3wxx FOREIGN KEY (inventory_report_temp_id) REFERENCES public.inventory_report_temp(id);


--
-- TOC entry 6773 (class 2606 OID 127046)
-- Name: therapeutic_regimen_drugs fk80tx2uqkomv6p0c1d06666orc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.therapeutic_regimen_drugs
    ADD CONSTRAINT fk80tx2uqkomv6p0c1d06666orc FOREIGN KEY (drug_id) REFERENCES public.drug(id);


--
-- TOC entry 6751 (class 2606 OID 127051)
-- Name: prescription_detail fk86y1y2214b2mgdexd1v5wcpsp; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_detail
    ADD CONSTRAINT fk86y1y2214b2mgdexd1v5wcpsp FOREIGN KEY (dispense_type_id) REFERENCES public.dispense_type(id);


--
-- TOC entry 6701 (class 2606 OID 127056)
-- Name: episode fk8b1no6ovs26gvd0966r2vg08q; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.episode
    ADD CONSTRAINT fk8b1no6ovs26gvd0966r2vg08q FOREIGN KEY (episode_type_id) REFERENCES public.episode_type(id);


--
-- TOC entry 6735 (class 2606 OID 127136)
-- Name: patient_visit fk8b8jixs51vmisd1bm051feosm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.patient_visit
    ADD CONSTRAINT fk8b8jixs51vmisd1bm051feosm FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6728 (class 2606 OID 127216)
-- Name: patient fk8ena1rkb5kdlhqalyfxif5hk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.patient
    ADD CONSTRAINT fk8ena1rkb5kdlhqalyfxif5hk1 FOREIGN KEY (province_id) REFERENCES public.province(id);


--
-- TOC entry 6726 (class 2606 OID 127374)
-- Name: national_clinic_clinic fk8gqm7o6fwb4k3cpw7jbdk46l7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.national_clinic_clinic
    ADD CONSTRAINT fk8gqm7o6fwb4k3cpw7jbdk46l7 FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6705 (class 2606 OID 127379)
-- Name: group_info fk8i7tgm8rvib6fpocf8r39l485; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_info
    ADD CONSTRAINT fk8i7tgm8rvib6fpocf8r39l485 FOREIGN KEY (group_type_id) REFERENCES public.group_type(id);


--
-- TOC entry 6679 (class 2606 OID 127384)
-- Name: inventory fk8nhiaiguoxwketkfl8np0hb4p; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT fk8nhiaiguoxwketkfl8np0hb4p FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6713 (class 2606 OID 127389)
-- Name: group_pack_header fk8p5gyocr7lg2lawwkxadb72xx; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_pack_header
    ADD CONSTRAINT fk8p5gyocr7lg2lawwkxadb72xx FOREIGN KEY (group_id) REFERENCES public.group_info(id);


--
-- TOC entry 6706 (class 2606 OID 127394)
-- Name: group_info fk9gbhvscsuou03lntvdh74yxts; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_info
    ADD CONSTRAINT fk9gbhvscsuou03lntvdh74yxts FOREIGN KEY (dispense_type_id) REFERENCES public.dispense_type(id);


--
-- TOC entry 6671 (class 2606 OID 127399)
-- Name: destroyed_stock fk9k5l2c2v3jwpke114rbba7vwk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.destroyed_stock
    ADD CONSTRAINT fk9k5l2c2v3jwpke114rbba7vwk FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6715 (class 2606 OID 127404)
-- Name: interoperability_attribute fka0rj0uaru28mn4f001s0mq8wj; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interoperability_attribute
    ADD CONSTRAINT fka0rj0uaru28mn4f001s0mq8wj FOREIGN KEY (interoperability_type_id) REFERENCES public.interoperability_type(id);


--
-- TOC entry 6659 (class 2606 OID 127409)
-- Name: clinic_sector_users fka92rd6ckvf0700cq9e2hv5152; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic_sector_users
    ADD CONSTRAINT fka92rd6ckvf0700cq9e2hv5152 FOREIGN KEY (clinic_sector_id) REFERENCES public.clinic(id);


--
-- TOC entry 6680 (class 2606 OID 127414)
-- Name: pack fkad917glsj73qxfxf6aj5dbydw; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.pack
    ADD CONSTRAINT fkad917glsj73qxfxf6aj5dbydw FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6653 (class 2606 OID 127494)
-- Name: clinic fkah5b8llknts8eoitj90ny13le; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic
    ADD CONSTRAINT fkah5b8llknts8eoitj90ny13le FOREIGN KEY (facility_type_id) REFERENCES public.facility_type(id);


--
-- TOC entry 6673 (class 2606 OID 127499)
-- Name: doctor fkaqgufpq4bfr4au915m6u0s4dm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT fkaqgufpq4bfr4au915m6u0s4dm FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6685 (class 2606 OID 127504)
-- Name: packaged_drug_stock fkaqn8wlbsdwokkbxru6ylu8w62; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packaged_drug_stock
    ADD CONSTRAINT fkaqn8wlbsdwokkbxru6ylu8w62 FOREIGN KEY (packaged_drug_id) REFERENCES public.packaged_drug(id);


--
-- TOC entry 6749 (class 2606 OID 127509)
-- Name: prescribed_drug fkarwheh56raqx0poegvi9ihfyu; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescribed_drug
    ADD CONSTRAINT fkarwheh56raqx0poegvi9ihfyu FOREIGN KEY (drug_id) REFERENCES public.drug(id);


--
-- TOC entry 6681 (class 2606 OID 127514)
-- Name: pack fkaxjk6i2seegq6f78dpdwl0kkb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.pack
    ADD CONSTRAINT fkaxjk6i2seegq6f78dpdwl0kkb FOREIGN KEY (group_pack_id) REFERENCES public.group_pack(id);


--
-- TOC entry 6729 (class 2606 OID 127594)
-- Name: patient fkb7e51g6yba5kjhf2tkqfytjoi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.patient
    ADD CONSTRAINT fkb7e51g6yba5kjhf2tkqfytjoi FOREIGN KEY (his_id) REFERENCES public.health_information_system(id);


--
-- TOC entry 6694 (class 2606 OID 127752)
-- Name: stock_adjustment fkbpdmn8n7ui0sx9lk9tqkgbgdp; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_adjustment
    ADD CONSTRAINT fkbpdmn8n7ui0sx9lk9tqkgbgdp FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6762 (class 2606 OID 127757)
-- Name: service_patient fkbx134t9jdep8pbr43qxfpc12q; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_patient
    ADD CONSTRAINT fkbx134t9jdep8pbr43qxfpc12q FOREIGN KEY (clinical_service_id) REFERENCES public.clinical_service(id);


--
-- TOC entry 6756 (class 2606 OID 127762)
-- Name: role_menu fkc8fx6iqc9xfciepq06fjkj8q8; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_menu
    ADD CONSTRAINT fkc8fx6iqc9xfciepq06fjkj8q8 FOREIGN KEY (menus_id) REFERENCES public.menu(id);


--
-- TOC entry 6757 (class 2606 OID 127767)
-- Name: role_menu fkcgpn4po6059vf8ihnlpqhd9xr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_menu
    ADD CONSTRAINT fkcgpn4po6059vf8ihnlpqhd9xr FOREIGN KEY (roles_id) REFERENCES public.role(id);


--
-- TOC entry 6755 (class 2606 OID 127772)
-- Name: ramscreening fkcjuaypsgnp3u49xf1m0rmychv; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ramscreening
    ADD CONSTRAINT fkcjuaypsgnp3u49xf1m0rmychv FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6742 (class 2606 OID 127782)
-- Name: patient_service_identifier fkdi9vcwehy53s30xcand3koqbl; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.patient_service_identifier
    ADD CONSTRAINT fkdi9vcwehy53s30xcand3koqbl FOREIGN KEY (service_id) REFERENCES public.clinical_service(id);


--
-- TOC entry 6682 (class 2606 OID 127862)
-- Name: pack fkdjr57ox2s43frfgdji3bhd59e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.pack
    ADD CONSTRAINT fkdjr57ox2s43frfgdji3bhd59e FOREIGN KEY (dispense_mode_id) REFERENCES public.dispense_mode(id);


--
-- TOC entry 6699 (class 2606 OID 127942)
-- Name: stock_entrance fkdsjlhfrt7xrar1l8irom5amj; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_entrance
    ADD CONSTRAINT fkdsjlhfrt7xrar1l8irom5amj FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6767 (class 2606 OID 127947)
-- Name: stock_level fkdsu4lu8f9h9t9otsvtn7ic2kn; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_level
    ADD CONSTRAINT fkdsu4lu8f9h9t9otsvtn7ic2kn FOREIGN KEY (drug_id) REFERENCES public.drug(id);


--
-- TOC entry 6695 (class 2606 OID 127952)
-- Name: stock_adjustment fkdv8udfxs4ijs2febaxxi3g3t8; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_adjustment
    ADD CONSTRAINT fkdv8udfxs4ijs2febaxxi3g3t8 FOREIGN KEY (reference_id) REFERENCES public.refered_stock_moviment(id);


--
-- TOC entry 6690 (class 2606 OID 127957)
-- Name: stock fkdxr7oi0d4ss1nla3tkkll4vln; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT fkdxr7oi0d4ss1nla3tkkll4vln FOREIGN KEY (center_id) REFERENCES public.stock_center(id);


--
-- TOC entry 6702 (class 2606 OID 127962)
-- Name: episode fke3x6ks0vb7oefuvqojbpbh9lj; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.episode
    ADD CONSTRAINT fke3x6ks0vb7oefuvqojbpbh9lj FOREIGN KEY (clinic_sector_id) REFERENCES public.clinic(id);


--
-- TOC entry 6743 (class 2606 OID 128042)
-- Name: patient_service_identifier fkesck4mcu5bvmnvtim7wuxsbc0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.patient_service_identifier
    ADD CONSTRAINT fkesck4mcu5bvmnvtim7wuxsbc0 FOREIGN KEY (identifier_type_id) REFERENCES public.identifier_type(id);


--
-- TOC entry 6707 (class 2606 OID 128122)
-- Name: group_info fkeubo0sto1x64wrp8nyswlu3m; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_info
    ADD CONSTRAINT fkeubo0sto1x64wrp8nyswlu3m FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6730 (class 2606 OID 128127)
-- Name: patient fkf0lahuc83tnr8ejmukvlcngd2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.patient
    ADD CONSTRAINT fkf0lahuc83tnr8ejmukvlcngd2 FOREIGN KEY (posto_administrativo_id) REFERENCES public.posto_administrativo(id);


--
-- TOC entry 6774 (class 2606 OID 128285)
-- Name: therapeutic_regimen_drugs fkf0tn4we9ap0aybahiggpacgyu; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.therapeutic_regimen_drugs
    ADD CONSTRAINT fkf0tn4we9ap0aybahiggpacgyu FOREIGN KEY (therapeutic_regimen_id) REFERENCES public.therapeutic_regimen(id);


--
-- TOC entry 6654 (class 2606 OID 128290)
-- Name: clinic fkf5qpk00evo0bg3u92nn1rprso; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic
    ADD CONSTRAINT fkf5qpk00evo0bg3u92nn1rprso FOREIGN KEY (province_id) REFERENCES public.province(id);


--
-- TOC entry 6724 (class 2606 OID 128295)
-- Name: national_clinic fkgqkhcbo475irdh4py76k7ncoq; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.national_clinic
    ADD CONSTRAINT fkgqkhcbo475irdh4py76k7ncoq FOREIGN KEY (facility_type_id) REFERENCES public.facility_type(id);


--
-- TOC entry 6740 (class 2606 OID 128300)
-- Name: prescription fkguli7w3i6uiujjxub7um7cdfi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.prescription
    ADD CONSTRAINT fkguli7w3i6uiujjxub7um7cdfi FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6696 (class 2606 OID 128380)
-- Name: stock_adjustment fkh7bukyi7n7egigcs4l5mm3ffd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_adjustment
    ADD CONSTRAINT fkh7bukyi7n7egigcs4l5mm3ffd FOREIGN KEY (inventory_id) REFERENCES public.inventory(id);


--
-- TOC entry 6719 (class 2606 OID 128385)
-- Name: localidade fkhbt80h29p7ja7qu27j026ia3t; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localidade
    ADD CONSTRAINT fkhbt80h29p7ja7qu27j026ia3t FOREIGN KEY (district_id) REFERENCES public.district(id);


--
-- TOC entry 6731 (class 2606 OID 128390)
-- Name: patient fkhjsxr9a41eutntp5lmlsfu1g0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.patient
    ADD CONSTRAINT fkhjsxr9a41eutntp5lmlsfu1g0 FOREIGN KEY (bairro_id) REFERENCES public.localidade(id);


--
-- TOC entry 6710 (class 2606 OID 128548)
-- Name: group_member fki5eun21tbpjot0v09oqgybxj3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_member
    ADD CONSTRAINT fki5eun21tbpjot0v09oqgybxj3 FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6752 (class 2606 OID 128553)
-- Name: prescription_detail fki7mhrug2icen6g8xbc6j0ncs3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_detail
    ADD CONSTRAINT fki7mhrug2icen6g8xbc6j0ncs3 FOREIGN KEY (therapeutic_line_id) REFERENCES public.therapeutic_line(id);


--
-- TOC entry 6652 (class 2606 OID 128558)
-- Name: appointment fki7q7b33lue26pe9f0p9tb7j2j; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT fki7q7b33lue26pe9f0p9tb7j2j FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6697 (class 2606 OID 128563)
-- Name: stock_adjustment fkj1m8o1vj74gqxwo81gsspw9xc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_adjustment
    ADD CONSTRAINT fkj1m8o1vj74gqxwo81gsspw9xc FOREIGN KEY (adjusted_stock_id) REFERENCES public.stock(id);


--
-- TOC entry 6732 (class 2606 OID 128568)
-- Name: patient fkj8tcgt32iya29rfi0fkju88yf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.patient
    ADD CONSTRAINT fkj8tcgt32iya29rfi0fkju88yf FOREIGN KEY (district_id) REFERENCES public.district(id);


--
-- TOC entry 6727 (class 2606 OID 128726)
-- Name: national_clinic_clinic fkjg49lwpmsevgydvpd2s5ai7g0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.national_clinic_clinic
    ADD CONSTRAINT fkjg49lwpmsevgydvpd2s5ai7g0 FOREIGN KEY (national_clinic_clinics_id) REFERENCES public.national_clinic(id);


--
-- TOC entry 6758 (class 2606 OID 128731)
-- Name: sec_user_clinic_sectors fkjweos4kwl44cqhn0l2kodn59m; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sec_user_clinic_sectors
    ADD CONSTRAINT fkjweos4kwl44cqhn0l2kodn59m FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6686 (class 2606 OID 128736)
-- Name: packaged_drug_stock fkjwi1i44ojbg381jkdr7ipsdq7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packaged_drug_stock
    ADD CONSTRAINT fkjwi1i44ojbg381jkdr7ipsdq7 FOREIGN KEY (stock_id) REFERENCES public.stock(id);


--
-- TOC entry 6657 (class 2606 OID 128741)
-- Name: clinic_sector fkk1tjdieng989pt0iopkw4vwff; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic_sector
    ADD CONSTRAINT fkk1tjdieng989pt0iopkw4vwff FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6666 (class 2606 OID 128746)
-- Name: clinical_service_clinic_sectors fkk39t1ljxirrfpu8di9vgnuqdd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_clinic_sectors
    ADD CONSTRAINT fkk39t1ljxirrfpu8di9vgnuqdd FOREIGN KEY (clinical_service_id) REFERENCES public.clinical_service(id);


--
-- TOC entry 6661 (class 2606 OID 128751)
-- Name: clinical_service fkk3l1u3h7ofqoywliu9fw4lbcv; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service
    ADD CONSTRAINT fkk3l1u3h7ofqoywliu9fw4lbcv FOREIGN KEY (identifier_type_id) REFERENCES public.identifier_type(id);


--
-- TOC entry 6737 (class 2606 OID 128756)
-- Name: patient_visit_details fkk74iqc2xu98fgoohyf8976c98; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_visit_details
    ADD CONSTRAINT fkk74iqc2xu98fgoohyf8976c98 FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6660 (class 2606 OID 128761)
-- Name: clinic_sector_users fkk7krklj8v9l2gp9o6rkl0jclk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic_sector_users
    ADD CONSTRAINT fkk7krklj8v9l2gp9o6rkl0jclk FOREIGN KEY (sec_user_id) REFERENCES public.sec_user(id);


--
-- TOC entry 6766 (class 2606 OID 128766)
-- Name: stock_distributor_batch fkkn2gy5bqevvild52p6g49tvqn; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_distributor_batch
    ADD CONSTRAINT fkkn2gy5bqevvild52p6g49tvqn FOREIGN KEY (stock_id) REFERENCES public.stock(id);


--
-- TOC entry 6768 (class 2606 OID 128771)
-- Name: stock_level fkkx2ccy8ul9jvku7mon67jcc6p; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_level
    ADD CONSTRAINT fkkx2ccy8ul9jvku7mon67jcc6p FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6745 (class 2606 OID 128776)
-- Name: patient_trans_reference fkl9v142k6n5e9prq033gfo99lf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_trans_reference
    ADD CONSTRAINT fkl9v142k6n5e9prq033gfo99lf FOREIGN KEY (origin_id) REFERENCES public.clinic(id);


--
-- TOC entry 6753 (class 2606 OID 128781)
-- Name: prescription_detail fkleqhh2le9cywltglk6uy0tp3s; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_detail
    ADD CONSTRAINT fkleqhh2le9cywltglk6uy0tp3s FOREIGN KEY (spetial_prescription_motive_id) REFERENCES public.spetial_prescription_motive(id);


--
-- TOC entry 6674 (class 2606 OID 128786)
-- Name: drug fklwoxa6q7y0b6mr6c9jwe1rq7v; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drug
    ADD CONSTRAINT fklwoxa6q7y0b6mr6c9jwe1rq7v FOREIGN KEY (form_id) REFERENCES public.form(id);


--
-- TOC entry 6771 (class 2606 OID 128791)
-- Name: therapeutic_regimen_clinical_services fkmmog5ksl7dk1kkn6di1kih6ly; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.therapeutic_regimen_clinical_services
    ADD CONSTRAINT fkmmog5ksl7dk1kkn6di1kih6ly FOREIGN KEY (clinical_service_id) REFERENCES public.clinical_service(id);


--
-- TOC entry 6698 (class 2606 OID 128801)
-- Name: stock_adjustment fkmv9vbm1uhxt8w5ni7mh2thaik; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_adjustment
    ADD CONSTRAINT fkmv9vbm1uhxt8w5ni7mh2thaik FOREIGN KEY (operation_id) REFERENCES public.stock_operation_type(id);


--
-- TOC entry 6677 (class 2606 OID 128806)
-- Name: drug_distributor fkn4sfeloqfkjckm5grd4hbsv4w; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drug_distributor
    ADD CONSTRAINT fkn4sfeloqfkjckm5grd4hbsv4w FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6714 (class 2606 OID 128811)
-- Name: group_pack_header fkn9407aso88l8hv7orx9kfgrwb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_pack_header
    ADD CONSTRAINT fkn9407aso88l8hv7orx9kfgrwb FOREIGN KEY (duration_id) REFERENCES public.duration(id);


--
-- TOC entry 6716 (class 2606 OID 128816)
-- Name: interoperability_attribute fkn992e57kljvyftakf8sut39oq; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interoperability_attribute
    ADD CONSTRAINT fkn992e57kljvyftakf8sut39oq FOREIGN KEY (health_information_system_id) REFERENCES public.health_information_system(id);


--
-- TOC entry 6665 (class 2606 OID 128821)
-- Name: clinical_service_clinic_sector fkndcf18ywuqbqctlodxk0dc1af; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_clinic_sector
    ADD CONSTRAINT fkndcf18ywuqbqctlodxk0dc1af FOREIGN KEY (clinic_sector_id) REFERENCES public.clinic(id);


--
-- TOC entry 6703 (class 2606 OID 128826)
-- Name: episode fknrsu7tc3rrfuocr4qld7s04u4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.episode
    ADD CONSTRAINT fknrsu7tc3rrfuocr4qld7s04u4 FOREIGN KEY (start_stop_reason_id) REFERENCES public.start_stop_reason(id);


--
-- TOC entry 6770 (class 2606 OID 128906)
-- Name: therapeutic_regimen fknygiswlgsjxe14iu45o4wdkur; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.therapeutic_regimen
    ADD CONSTRAINT fknygiswlgsjxe14iu45o4wdkur FOREIGN KEY (clinical_service_id) REFERENCES public.clinical_service(id);


--
-- TOC entry 6655 (class 2606 OID 128911)
-- Name: clinic fkohrqd22pd0ols67rll4xa83ev; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic
    ADD CONSTRAINT fkohrqd22pd0ols67rll4xa83ev FOREIGN KEY (district_id) REFERENCES public.district(id);


--
-- TOC entry 6772 (class 2606 OID 128916)
-- Name: therapeutic_regimen_clinical_services fkokvgw59c2b0ngndnbcy9t5m3j; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.therapeutic_regimen_clinical_services
    ADD CONSTRAINT fkokvgw59c2b0ngndnbcy9t5m3j FOREIGN KEY (therapeutic_regimen_id) REFERENCES public.therapeutic_regimen(id);


--
-- TOC entry 6721 (class 2606 OID 128921)
-- Name: mmia_report_clinic fkol5mq76kf78afnjfu2hsypvmk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mmia_report_clinic
    ADD CONSTRAINT fkol5mq76kf78afnjfu2hsypvmk FOREIGN KEY (mmia_report_clinic_id) REFERENCES public.mmia_report(id);


--
-- TOC entry 6746 (class 2606 OID 128926)
-- Name: posto_administrativo fkosohhrt4gylhujd6plbof0uxf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posto_administrativo
    ADD CONSTRAINT fkosohhrt4gylhujd6plbof0uxf FOREIGN KEY (district_id) REFERENCES public.district(id);


--
-- TOC entry 6722 (class 2606 OID 128931)
-- Name: mmia_report_clinic fkouixtt3p8h00lrkge4d6csr76; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mmia_report_clinic
    ADD CONSTRAINT fkouixtt3p8h00lrkge4d6csr76 FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6691 (class 2606 OID 128936)
-- Name: stock fkpbbfgxsylaaotim0v3v9g3d76; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT fkpbbfgxsylaaotim0v3v9g3d76 FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6708 (class 2606 OID 128941)
-- Name: group_info fkpd8k2idpgu3aua7hn00cg0plo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_info
    ADD CONSTRAINT fkpd8k2idpgu3aua7hn00cg0plo FOREIGN KEY (service_id) REFERENCES public.clinical_service(id);


--
-- TOC entry 6670 (class 2606 OID 128946)
-- Name: clinical_service_therapeutic_regimens fkpp7n85sry9ohnfbtr5b8y42kq; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinical_service_therapeutic_regimens
    ADD CONSTRAINT fkpp7n85sry9ohnfbtr5b8y42kq FOREIGN KEY (therapeutic_regimen_id) REFERENCES public.therapeutic_regimen(id);


--
-- TOC entry 6692 (class 2606 OID 128951)
-- Name: stock fkps88xiot4s0776ob69x86vbpt; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT fkps88xiot4s0776ob69x86vbpt FOREIGN KEY (entrance_id) REFERENCES public.stock_entrance(id);


--
-- TOC entry 6720 (class 2606 OID 128956)
-- Name: mmia_regimen_sub_report fkpw9vcvuixtqeguq2xucib9cob; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mmia_regimen_sub_report
    ADD CONSTRAINT fkpw9vcvuixtqeguq2xucib9cob FOREIGN KEY (mmia_report_id) REFERENCES public.mmia_report(id);


--
-- TOC entry 6736 (class 2606 OID 128961)
-- Name: vital_signs_screening fkq0gmaycwed6x3dbg5dku6oijd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vital_signs_screening
    ADD CONSTRAINT fkq0gmaycwed6x3dbg5dku6oijd FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6651 (class 2606 OID 128971)
-- Name: adherence_screening fkqaboyft0k70dv1i1ws1g99ea7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adherence_screening
    ADD CONSTRAINT fkqaboyft0k70dv1i1ws1g99ea7 FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6678 (class 2606 OID 128976)
-- Name: drug_quantity_temp fkqlmqo5drj2psmxfpjowudp846; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drug_quantity_temp
    ADD CONSTRAINT fkqlmqo5drj2psmxfpjowudp846 FOREIGN KEY (arv_daily_register_report_temp_id) REFERENCES public.arv_daily_register_report_temp(id);


--
-- TOC entry 6764 (class 2606 OID 128981)
-- Name: stock_distributor fkqmeuqgnf3ofy2hcbyx2l0fqbb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_distributor
    ADD CONSTRAINT fkqmeuqgnf3ofy2hcbyx2l0fqbb FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6658 (class 2606 OID 128986)
-- Name: clinic_sector fkqob9nh5ajdxfrjecnoufoatqt; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic_sector
    ADD CONSTRAINT fkqob9nh5ajdxfrjecnoufoatqt FOREIGN KEY (clinic_sector_type_id) REFERENCES public.clinic_sector_type(id);


--
-- TOC entry 6725 (class 2606 OID 128991)
-- Name: national_clinic fkqtmhckp9emef1dim821t5ingv; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.national_clinic
    ADD CONSTRAINT fkqtmhckp9emef1dim821t5ingv FOREIGN KEY (province_id) REFERENCES public.province(id);


--
-- TOC entry 6711 (class 2606 OID 129001)
-- Name: group_member_prescription fkrbx8e7rp8y55y7eyv0svcodoh; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_member_prescription
    ADD CONSTRAINT fkrbx8e7rp8y55y7eyv0svcodoh FOREIGN KEY (member_id) REFERENCES public.group_member(id);


--
-- TOC entry 6733 (class 2606 OID 129006)
-- Name: patient fkrg813t22w4h0mx4bhgkwyvjl9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.patient
    ADD CONSTRAINT fkrg813t22w4h0mx4bhgkwyvjl9 FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6675 (class 2606 OID 129169)
-- Name: drug fkrjrrijwjfm8ii628834hyatxt; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drug
    ADD CONSTRAINT fkrjrrijwjfm8ii628834hyatxt FOREIGN KEY (clinical_service_id) REFERENCES public.clinical_service(id);


--
-- TOC entry 6656 (class 2606 OID 129174)
-- Name: clinic fkrntjxanahktkkbplc113uksfm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinic
    ADD CONSTRAINT fkrntjxanahktkkbplc113uksfm FOREIGN KEY (parent_clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6754 (class 2606 OID 129179)
-- Name: prescription_detail fkrp9pgqcmitgv5cqc8he2ucbh5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_detail
    ADD CONSTRAINT fkrp9pgqcmitgv5cqc8he2ucbh5 FOREIGN KEY (therapeutic_regimen_id) REFERENCES public.therapeutic_regimen(id);


--
-- TOC entry 6687 (class 2606 OID 129184)
-- Name: packaged_drug_stock fksfle5wr24h13gsnrff9wxwfx9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packaged_drug_stock
    ADD CONSTRAINT fksfle5wr24h13gsnrff9wxwfx9 FOREIGN KEY (drug_id) REFERENCES public.drug(id);


--
-- TOC entry 6684 (class 2606 OID 129189)
-- Name: packaged_drug fksvpa0wrfflyc1h6a1vg52rxj0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packaged_drug
    ADD CONSTRAINT fksvpa0wrfflyc1h6a1vg52rxj0 FOREIGN KEY (drug_id) REFERENCES public.drug(id);


--
-- TOC entry 6704 (class 2606 OID 129194)
-- Name: episode fkuqs3odapg10l4k57mfsdn91c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.episode
    ADD CONSTRAINT fkuqs3odapg10l4k57mfsdn91c FOREIGN KEY (clinic_id) REFERENCES public.clinic(id);


--
-- TOC entry 6734 (class 2606 OID 129274)
-- Name: patient_attribute fkxn3k71fsma396y945kkhvo4a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_attribute
    ADD CONSTRAINT fkxn3k71fsma396y945kkhvo4a FOREIGN KEY (attribute_type_id) REFERENCES public.patient_attribute_type(id);
