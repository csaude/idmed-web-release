--
-- PostgreSQL database dump
--

-- Dumped from database version 15.6 (Debian 15.6-1.pgdg110+2)
-- Dumped by pg_dump version 16.4 (Ubuntu 16.4-1.pgdg22.04+1)

-- Started on 2025-01-29 11:01:06 CAT

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 567 (class 1259 OID 153350)
-- Name: external_patient_visit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.external_patient_visit (
    id character varying(255) NOT NULL,
    version bigint NOT NULL,
    source_clinic_id character varying(255),
    source_province_name character varying(255),
    date_created timestamp without time zone NOT NULL,
    target_clinic_name character varying(255),
    patient_cellphone character varying(255),
    "json_object" text,
    nid character varying(255) NOT NULL,
    target_province_name character varying(255),
    patient_date_of_birth timestamp without time zone,
    source_clinic_name character varying(255),
    target_clinic_id character varying(255),
    target_province_id character varying(255),
    patient_name character varying(255),
    sync_status character(1),
    source_province_id character varying(255) NOT NULL,
    source_district_name character varying(255),
    source_district_id character varying(255),
    patientid character varying(255) NOT NULL,
    target_district_id character varying(255),
    target_district_name character varying(255),
    patient_gender character varying(255)
);


ALTER TABLE public.external_patient_visit OWNER TO postgres;

--
-- TOC entry 4241 (class 2606 OID 153356)
-- Name: external_patient_visit external_patient_visit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.external_patient_visit
    ADD CONSTRAINT external_patient_visit_pkey PRIMARY KEY (id);


--
-- TOC entry 4242 (class 1259 OID 153358)
-- Name: index_nid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_nid_idx ON public.external_patient_visit USING btree (nid);


--
-- TOC entry 4243 (class 1259 OID 153359)
-- Name: index_patient_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_patient_id_idx ON public.external_patient_visit USING btree (patientid);


--
-- TOC entry 4244 (class 1259 OID 153357)
-- Name: pk_external_pv_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pk_external_pv_idx ON public.external_patient_visit USING btree (id);


-- Completed on 2025-01-29 11:01:12 CAT

--
-- PostgreSQL database dump complete
--

