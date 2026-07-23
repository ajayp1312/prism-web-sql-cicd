--
-- PostgreSQL database dump
--

-- Dumped from database version 14.12
-- Dumped by pg_dump version 14.12

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
-- Name: focus; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA focus;


ALTER SCHEMA focus OWNER TO postgres;

--
-- Name: archive_recommendation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.archive_recommendation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Archive old record before update
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO public.genai_dbx_reccomendation_history (
            original_id, account_id, workspace_id, job_id, job_name, sku_name,
            category, reason, recommendation, estimated_cost_savings,
            estimated_savings_percent, calculation_logic, inserted_at,
            archived_at, archive_reason
        ) VALUES (
            OLD.id, OLD.account_id, OLD.workspace_id, OLD.job_id, OLD.job_name, OLD.sku_name,
            OLD.category, OLD.reason, OLD.recommendation, OLD.estimated_cost_savings,
            OLD.estimated_savings_percent, OLD.calculation_logic, OLD.inserted_at,
            CURRENT_TIMESTAMP, 'Updated'
        );
    END IF;

    -- Archive record before delete
    IF TG_OP = 'DELETE' THEN
        INSERT INTO public.genai_dbx_reccomendation_history (
            original_id, account_id, workspace_id, job_id, job_name, sku_name,
            category, reason, recommendation, estimated_cost_savings,
            estimated_savings_percent, calculation_logic, inserted_at,
            archived_at, archive_reason
        ) VALUES (
            OLD.id, OLD.account_id, OLD.workspace_id, OLD.job_id, OLD.job_name, OLD.sku_name,
            OLD.category, OLD.reason, OLD.recommendation, OLD.estimated_cost_savings,
            OLD.estimated_savings_percent, OLD.calculation_logic, OLD.inserted_at,
            CURRENT_TIMESTAMP, 'Deleted'
        );
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.archive_recommendation() OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aws_focus_cost_data; Type: TABLE; Schema: focus; Owner: postgres
--

CREATE TABLE focus.aws_focus_cost_data (
    billingaccountid text,
    subaccountid text,
    regionid text,
    servicename text,
    servicecategory text,
    skumeter text,
    resourceid text,
    month integer,
    year integer,
    x_operation text,
    instance_type text NOT NULL,
    instance_series text NOT NULL,
    resource_tags_user_name text NOT NULL,
    chargecategory text,
    tenant_id text NOT NULL,
    chargeperiodstart date,
    chargeperiodend date,
    billingperiodstart timestamp without time zone,
    billingperiodend timestamp without time zone,
    billedcost numeric(30,6),
    consumedquantity numeric(30,6),
    contractedcost numeric(30,6),
    contractedunitprice numeric(30,6),
    effectivecost numeric(30,6),
    listcost numeric(30,6),
    listunitprice numeric(30,6),
    pricingcurrencycontractedunitprice numeric(30,6),
    pricingcurrencyeffectivecost numeric(30,6),
    pricingcurrencylistunitprice numeric(30,6),
    pricingquantity numeric(30,6),
    pseudo_primary_key text NOT NULL,
    pricingunit text,
    load_ts timestamp without time zone NOT NULL
);


ALTER TABLE focus.aws_focus_cost_data OWNER TO postgres;





--
-- Name: aws_s3_recommendation_data; Type: TABLE; Schema: focus; Owner: postgres
--

CREATE TABLE focus.aws_s3_recommendation_data (
    version_number text,
    configuration_id text,
    report_date text,
    aws_account_number text,
    aws_region text,
    storage_class text,
    record_type text,
    record_value text,
    bucket_name text,
    metric_name text,
    metric_value bigint,
    metric_value_gb double precision,
    metric_value_tb double precision
);


ALTER TABLE focus.aws_s3_recommendation_data OWNER TO postgres;

--
-- Name: schema_metadata; Type: TABLE; Schema: focus; Owner: postgres
--

CREATE TABLE focus.schema_metadata (
    id integer NOT NULL,
    schema_name character varying(255) NOT NULL,
    table_name character varying(255) NOT NULL,
    column_name character varying(255),
    metadata_type character varying(50) NOT NULL,
    description text NOT NULL,
    purpose text,
    data_characteristics text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(100) DEFAULT 'schema_discovery_agent'::character varying
);


ALTER TABLE focus.schema_metadata OWNER TO postgres;

--
-- Name: schema_metadata_id_seq; Type: SEQUENCE; Schema: focus; Owner: postgres
--

CREATE SEQUENCE focus.schema_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE focus.schema_metadata_id_seq OWNER TO postgres;

--
-- Name: schema_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: focus; Owner: postgres
--

ALTER SEQUENCE focus.schema_metadata_id_seq OWNED BY focus.schema_metadata.id;


--
-- Name: agent_feedback; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agent_feedback (
    id uuid NOT NULL,
    query_id character varying(255) NOT NULL,
    session_id character varying(255),
    response_id character varying(255),
    user_id character varying(255) NOT NULL,
    tenant_id character varying(255) NOT NULL,
    "like" boolean NOT NULL,
    "timestamp" character varying(255) NOT NULL,
    feedback_text text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.agent_feedback OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    customer_id integer,
    agent_id integer,
    order_date date NOT NULL,
    ship_date date,
    delivery_date date,
    order_status character varying(50) DEFAULT 'Pending'::character varying,
    payment_method character varying(50),
    payment_status character varying(50) DEFAULT 'Pending'::character varying,
    shipping_cost numeric(10,2) DEFAULT 0.00,
    tax_amount numeric(10,2) DEFAULT 0.00,
    discount_amount numeric(10,2) DEFAULT 0.00,
    total_amount numeric(12,2) NOT NULL,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: TABLE orders; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.orders IS 'Sales orders with payment and shipping details';


--
-- Name: regions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.regions (
    region_id integer NOT NULL,
    region_name character varying(100) NOT NULL,
    country character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.regions OWNER TO postgres;

--
-- Name: TABLE regions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.regions IS 'Geographic regions for sales territories';


--
-- Name: sales_agents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_agents (
    agent_id integer NOT NULL,
    agent_name character varying(200) NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(20),
    region_id integer,
    hire_date date NOT NULL,
    commission_rate numeric(5,2) DEFAULT 5.00,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sales_agents OWNER TO postgres;

--
-- Name: TABLE sales_agents; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.sales_agents IS 'Sales representatives managing customer orders';


--
-- Name: agent_performance; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.agent_performance AS
 SELECT sa.agent_id,
    sa.agent_name,
    r.region_name,
    count(DISTINCT o.order_id) AS total_orders,
    sum(o.total_amount) AS total_sales,
    avg(o.total_amount) AS avg_order_value,
    sum(((o.total_amount * sa.commission_rate) / (100)::numeric)) AS total_commission
   FROM ((public.sales_agents sa
     JOIN public.regions r ON ((sa.region_id = r.region_id)))
     LEFT JOIN public.orders o ON ((sa.agent_id = o.agent_id)))
  WHERE (sa.is_active = true)
  GROUP BY sa.agent_id, sa.agent_name, r.region_name, sa.commission_rate;


ALTER TABLE public.agent_performance OWNER TO postgres;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO "prism-web";

--
-- Name: athena_query_recommendation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.athena_query_recommendation (
    submission_time date NOT NULL,
    execution_id character varying NOT NULL,
    database_name character varying NOT NULL,
    table_name character varying NOT NULL,
    data_scanned_gb double precision NOT NULL,
    estimated_cost double precision NOT NULL,
    execution_time_sec bigint NOT NULL,
    query_text text NOT NULL,
    recommendation text NOT NULL,
    potential_saving double precision
);


ALTER TABLE public.athena_query_recommendation OWNER TO postgres;

--
-- Name: athena_recommendation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.athena_recommendation (
    database_name character varying NOT NULL,
    table_name character varying NOT NULL,
    recommendation character varying NOT NULL
);


ALTER TABLE public.athena_recommendation OWNER TO postgres;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.audit_logs (
    id uuid NOT NULL,
    tenant_id character varying(255) NOT NULL,
    action character varying NOT NULL,
    resource_type character varying,
    resource_id character varying,
    event_metadata json,
    ip character varying,
    environment_details character varying,
    created_at timestamp with time zone NOT NULL,
    error_details character varying
);


ALTER TABLE public.audit_logs OWNER TO "prism-web";

--
-- Name: auth_sessions; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.auth_sessions (
    id uuid NOT NULL,
    tenant_id character varying(120) NOT NULL,
    user_id uuid NOT NULL,
    refresh_token_hash character varying(128) NOT NULL,
    ip character varying,
    user_agent character varying,
    device_name character varying(120),
    revoked boolean NOT NULL,
    created_at timestamp with time zone NOT NULL,
    last_seen_at timestamp with time zone NOT NULL
);


ALTER TABLE public.auth_sessions OWNER TO "prism-web";

--
-- Name: aws_anomaly; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aws_anomaly (
    anomaly_date date,
    service_name text,
    region text,
    actual_cost numeric(18,6),
    lower_limit numeric(18,6),
    upper_limit numeric(18,6),
    anomaly_type text,
    reason text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    account character varying,
    resource_name text,
    risk_level text,
    CONSTRAINT aws_cost_anomaly_limits_chk CHECK (((lower_limit IS NULL) OR (upper_limit IS NULL) OR (lower_limit <= upper_limit)))
);


ALTER TABLE public.aws_anomaly OWNER TO postgres;

--
-- Name: aws_cis_python_dst; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.aws_cis_python_dst (
    account_id character varying,
    control_id character varying,
    date_time date,
    description character varying,
    offenders character varying,
    result character varying,
    scored_control boolean,
    fail_reason character varying,
    tenant_id character varying,
    pseudo_primary_key character varying,
    cloud_provider character varying
);


ALTER TABLE public.aws_cis_python_dst OWNER TO "prism-web";

--
-- Name: aws_cloudwatch_observations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aws_cloudwatch_observations (
    account_id text,
    region text,
    usagetype text NOT NULL,
    operation text,
    resourceidlist text NOT NULL,
    totalspend double precision,
    usagequantity numeric(26,8),
    load_ts timestamp without time zone NOT NULL,
    recommendation text
);


ALTER TABLE public.aws_cloudwatch_observations OWNER TO postgres;

--
-- Name: aws_focus_cost_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aws_focus_cost_data (
    billingaccountid text,
    subaccountid text,
    regionid text,
    servicename text,
    servicecategory text,
    skumeter text,
    resourceid text,
    month integer,
    year integer,
    x_operation text,
    instance_type text NOT NULL,
    instance_series text NOT NULL,
    resource_tags_user_name text NOT NULL,
    chargecategory text,
    tenant_id text NOT NULL,
    chargeperiodstart date,
    chargeperiodend date,
    billingperiodstart timestamp without time zone,
    billingperiodend timestamp without time zone,
    billedcost numeric(30,6),
    consumedquantity numeric(30,6),
    contractedcost numeric(30,6),
    contractedunitprice numeric(30,6),
    effectivecost numeric(30,6),
    listcost numeric(30,6),
    listunitprice numeric(30,6),
    pricingcurrencycontractedunitprice numeric(30,6),
    pricingcurrencyeffectivecost numeric(30,6),
    pricingcurrencylistunitprice numeric(30,6),
    pricingquantity numeric(30,6),
    pseudo_primary_key text NOT NULL,
    pricingunit text,
    load_ts timestamp without time zone,
    x_servicecode text,
    tags text
);


ALTER TABLE public.aws_focus_cost_data OWNER TO postgres;

--
-- Name: aws_cost_20260902; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.aws_cost_20260902 AS
 SELECT aws_focus_cost_data.servicename,
    sum(aws_focus_cost_data.billedcost) AS total_billedcost,
    sum(aws_focus_cost_data.consumedquantity) AS total_consumedquantity,
    aws_focus_cost_data.chargeperiodstart,
    aws_focus_cost_data.chargeperiodend,
    aws_focus_cost_data.resourceid,
    aws_focus_cost_data.skumeter,
    aws_focus_cost_data.x_operation,
    aws_focus_cost_data.billingaccountid,
    aws_focus_cost_data.subaccountid,
    aws_focus_cost_data.regionid,
    aws_focus_cost_data.servicecategory,
    aws_focus_cost_data.month,
    aws_focus_cost_data.year,
    aws_focus_cost_data.instance_type,
    aws_focus_cost_data.instance_series,
    aws_focus_cost_data.resource_tags_user_name,
    aws_focus_cost_data.chargecategory,
    aws_focus_cost_data.tenant_id
   FROM public.aws_focus_cost_data
  WHERE ((aws_focus_cost_data.chargeperiodstart = '2026-02-09'::date) AND (aws_focus_cost_data.billedcost > '0'::numeric))
  GROUP BY aws_focus_cost_data.chargeperiodstart, aws_focus_cost_data.resourceid, aws_focus_cost_data.servicename, aws_focus_cost_data.skumeter, aws_focus_cost_data.chargeperiodend, aws_focus_cost_data.x_operation, aws_focus_cost_data.billingaccountid, aws_focus_cost_data.subaccountid, aws_focus_cost_data.regionid, aws_focus_cost_data.servicecategory, aws_focus_cost_data.month, aws_focus_cost_data.year, aws_focus_cost_data.instance_type, aws_focus_cost_data.instance_series, aws_focus_cost_data.resource_tags_user_name, aws_focus_cost_data.chargecategory, aws_focus_cost_data.tenant_id
  ORDER BY (sum(aws_focus_cost_data.billedcost)) DESC;


ALTER TABLE public.aws_cost_20260902 OWNER TO postgres;

--
-- Name: aws_cost_20261002; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.aws_cost_20261002 AS
 SELECT aws_focus_cost_data.servicename,
    sum(aws_focus_cost_data.billedcost) AS total_billedcost,
    sum(aws_focus_cost_data.consumedquantity) AS total_consumedquantity,
    aws_focus_cost_data.chargeperiodstart,
    aws_focus_cost_data.chargeperiodend,
    aws_focus_cost_data.resourceid,
    aws_focus_cost_data.skumeter,
    aws_focus_cost_data.x_operation,
    aws_focus_cost_data.billingaccountid,
    aws_focus_cost_data.subaccountid,
    aws_focus_cost_data.regionid,
    aws_focus_cost_data.servicecategory,
    aws_focus_cost_data.month,
    aws_focus_cost_data.year,
    aws_focus_cost_data.instance_type,
    aws_focus_cost_data.instance_series,
    aws_focus_cost_data.resource_tags_user_name,
    aws_focus_cost_data.chargecategory,
    aws_focus_cost_data.tenant_id
   FROM public.aws_focus_cost_data
  WHERE ((aws_focus_cost_data.chargeperiodstart = '2026-02-10'::date) AND (aws_focus_cost_data.billedcost > '0'::numeric))
  GROUP BY aws_focus_cost_data.chargeperiodstart, aws_focus_cost_data.resourceid, aws_focus_cost_data.servicename, aws_focus_cost_data.skumeter, aws_focus_cost_data.chargeperiodend, aws_focus_cost_data.x_operation, aws_focus_cost_data.billingaccountid, aws_focus_cost_data.subaccountid, aws_focus_cost_data.regionid, aws_focus_cost_data.servicecategory, aws_focus_cost_data.month, aws_focus_cost_data.year, aws_focus_cost_data.instance_type, aws_focus_cost_data.instance_series, aws_focus_cost_data.resource_tags_user_name, aws_focus_cost_data.chargecategory, aws_focus_cost_data.tenant_id
  ORDER BY (sum(aws_focus_cost_data.billedcost)) DESC;


ALTER TABLE public.aws_cost_20261002 OWNER TO postgres;

--
-- Name: aws_cost_focus_historical_data; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.aws_cost_focus_historical_data AS
 SELECT daily_costs.servicename,
    daily_costs.billingaccountid,
    daily_costs.subaccountid,
    daily_costs.tenant_id,
    daily_costs.skumeter,
    daily_costs.resourceid,
    daily_costs.x_operation,
    daily_costs.regionid,
    daily_costs.servicecategory,
    daily_costs.instance_type,
    daily_costs.instance_series,
    daily_costs.chargecategory,
    avg(daily_costs.daily_billedcost) AS avg_daily_billedcost,
    percentile_cont((0.5)::double precision) WITHIN GROUP (ORDER BY ((daily_costs.daily_billedcost)::double precision)) AS median_daily_billedcost,
    mode() WITHIN GROUP (ORDER BY daily_costs.daily_billedcost) AS mode_daily_billedcost,
    stddev(daily_costs.daily_billedcost) AS stddev_daily_billedcost,
    min(daily_costs.daily_billedcost) AS min_daily_billedcost,
    max(daily_costs.daily_billedcost) AS max_daily_billedcost,
    avg(daily_costs.daily_consumedquantity) AS avg_daily_consumedquantity,
    min(daily_costs.daily_consumedquantity) AS min_daily_consumedquantity,
    max(daily_costs.daily_consumedquantity) AS max_daily_consumedquantity,
    min(daily_costs.charge_date) AS historical_period_start,
    max(daily_costs.charge_date) AS historical_period_end,
    count(DISTINCT daily_costs.charge_date) AS days_in_period
   FROM ( SELECT aws_focus_cost_data.servicename,
            aws_focus_cost_data.billingaccountid,
            aws_focus_cost_data.subaccountid,
            aws_focus_cost_data.tenant_id,
            aws_focus_cost_data.skumeter,
            aws_focus_cost_data.resourceid,
            aws_focus_cost_data.x_operation,
            aws_focus_cost_data.regionid,
            aws_focus_cost_data.servicecategory,
            aws_focus_cost_data.instance_type,
            aws_focus_cost_data.instance_series,
            aws_focus_cost_data.chargecategory,
            aws_focus_cost_data.chargeperiodstart AS charge_date,
            sum(aws_focus_cost_data.billedcost) AS daily_billedcost,
            sum(aws_focus_cost_data.consumedquantity) AS daily_consumedquantity
           FROM public.aws_focus_cost_data
          WHERE ((aws_focus_cost_data.billedcost > (0)::numeric) AND (aws_focus_cost_data.chargeperiodstart >= (( SELECT max(aws_focus_cost_data_1.chargeperiodstart) AS max
                   FROM public.aws_focus_cost_data aws_focus_cost_data_1) - '30 days'::interval)) AND (aws_focus_cost_data.chargeperiodstart < ( SELECT max(aws_focus_cost_data_1.chargeperiodstart) AS max
                   FROM public.aws_focus_cost_data aws_focus_cost_data_1)))
          GROUP BY aws_focus_cost_data.chargeperiodstart, aws_focus_cost_data.servicename, aws_focus_cost_data.billingaccountid, aws_focus_cost_data.subaccountid, aws_focus_cost_data.tenant_id, aws_focus_cost_data.skumeter, aws_focus_cost_data.resourceid, aws_focus_cost_data.x_operation, aws_focus_cost_data.regionid, aws_focus_cost_data.servicecategory, aws_focus_cost_data.instance_type, aws_focus_cost_data.instance_series, aws_focus_cost_data.chargecategory) daily_costs
  GROUP BY daily_costs.servicename, daily_costs.billingaccountid, daily_costs.subaccountid, daily_costs.tenant_id, daily_costs.skumeter, daily_costs.resourceid, daily_costs.x_operation, daily_costs.regionid, daily_costs.servicecategory, daily_costs.instance_type, daily_costs.instance_series, daily_costs.chargecategory;


ALTER TABLE public.aws_cost_focus_historical_data OWNER TO postgres;

--
-- Name: aws_focus_cost_current; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.aws_focus_cost_current AS
 SELECT aws_focus_cost_data.servicename,
    sum(aws_focus_cost_data.billedcost) AS current_day_total_billedcost,
    sum(aws_focus_cost_data.consumedquantity) AS current_day_total_consumedquantity,
    aws_focus_cost_data.chargeperiodstart,
    aws_focus_cost_data.chargeperiodend,
    aws_focus_cost_data.resourceid,
    aws_focus_cost_data.skumeter,
    aws_focus_cost_data.x_operation,
    aws_focus_cost_data.billingaccountid,
    aws_focus_cost_data.subaccountid,
    aws_focus_cost_data.regionid,
    aws_focus_cost_data.servicecategory,
    aws_focus_cost_data.month,
    aws_focus_cost_data.year,
    aws_focus_cost_data.instance_type,
    aws_focus_cost_data.instance_series,
    aws_focus_cost_data.chargecategory,
    aws_focus_cost_data.tenant_id
   FROM public.aws_focus_cost_data
  WHERE ((aws_focus_cost_data.chargeperiodstart = ( SELECT max(aws_focus_cost_data_1.chargeperiodstart) AS max
           FROM public.aws_focus_cost_data aws_focus_cost_data_1)) AND (aws_focus_cost_data.billedcost > (0)::numeric))
  GROUP BY aws_focus_cost_data.chargeperiodstart, aws_focus_cost_data.chargeperiodend, aws_focus_cost_data.resourceid, aws_focus_cost_data.servicename, aws_focus_cost_data.skumeter, aws_focus_cost_data.x_operation, aws_focus_cost_data.billingaccountid, aws_focus_cost_data.subaccountid, aws_focus_cost_data.regionid, aws_focus_cost_data.servicecategory, aws_focus_cost_data.month, aws_focus_cost_data.year, aws_focus_cost_data.instance_type, aws_focus_cost_data.instance_series, aws_focus_cost_data.chargecategory, aws_focus_cost_data.tenant_id
  ORDER BY (sum(aws_focus_cost_data.billedcost)) DESC;


ALTER TABLE public.aws_focus_cost_current OWNER TO postgres;

--
-- Name: aws_cost_analysis_current_historical; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.aws_cost_analysis_current_historical AS
 SELECT h.servicename,
    h.avg_daily_billedcost AS billedcost_historical_avg,
    h.median_daily_billedcost AS billedcost_historical_median,
    h.mode_daily_billedcost AS billedcost_historical_mode,
    h.stddev_daily_billedcost AS billedcost_historical_stddev,
    h.min_daily_billedcost AS billedcost_historical_min,
    h.max_daily_billedcost AS billedcost_historical_max,
    c.current_day_total_billedcost AS billedcost_current,
    (((c.current_day_total_billedcost - h.avg_daily_billedcost) / h.avg_daily_billedcost) * (100)::numeric) AS percentage_deviation,
    (c.current_day_total_billedcost - h.avg_daily_billedcost) AS difference,
        CASE
            WHEN (h.stddev_daily_billedcost > (0)::numeric) THEN ((c.current_day_total_billedcost - h.avg_daily_billedcost) / h.stddev_daily_billedcost)
            ELSE NULL::numeric
        END AS z_score,
    h.resourceid,
    h.skumeter,
    h.avg_daily_consumedquantity AS historical_avg_consumedquantity,
    h.min_daily_consumedquantity AS historical_min_consumedquantity,
    h.max_daily_consumedquantity AS historical_max_consumedquantity,
    c.current_day_total_consumedquantity AS current_day_consumedquantity,
    c.chargeperiodstart,
    c.chargeperiodend,
    h.x_operation,
    h.billingaccountid,
    h.subaccountid,
    h.regionid,
    h.servicecategory,
    h.instance_type,
    h.instance_series,
    h.chargecategory,
    h.tenant_id,
    h.days_in_period,
    h.historical_period_start,
    h.historical_period_end
   FROM (public.aws_cost_focus_historical_data h
     JOIN public.aws_focus_cost_current c ON (((h.resourceid = c.resourceid) AND (h.skumeter = c.skumeter) AND (h.tenant_id = c.tenant_id) AND (h.subaccountid = c.subaccountid) AND (h.billingaccountid = c.billingaccountid) AND (h.x_operation = c.x_operation))))
  ORDER BY
        CASE
            WHEN (h.stddev_daily_billedcost > (0)::numeric) THEN ((c.current_day_total_billedcost - h.avg_daily_billedcost) / h.stddev_daily_billedcost)
            ELSE NULL::numeric
        END DESC NULLS LAST;


ALTER TABLE public.aws_cost_analysis_current_historical OWNER TO postgres;

--
-- Name: aws_cost_analysis_current_historical_1; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.aws_cost_analysis_current_historical_1 AS
 SELECT h.servicename,
    h.avg_daily_billedcost AS billedcost_historical_avg,
    h.median_daily_billedcost AS billedcost_historical_median,
    h.mode_daily_billedcost AS billedcost_historical_mode,
    h.stddev_daily_billedcost AS billedcost_historical_stddev,
    h.min_daily_billedcost AS billedcost_historical_min,
    h.max_daily_billedcost AS billedcost_historical_max,
    c.current_day_total_billedcost AS billedcost_current,
    (((c.current_day_total_billedcost - h.avg_daily_billedcost) / h.avg_daily_billedcost) * (100)::numeric) AS percentage_deviation,
    (c.current_day_total_billedcost - h.avg_daily_billedcost) AS difference,
        CASE
            WHEN (h.stddev_daily_billedcost > (0)::numeric) THEN ((c.current_day_total_billedcost - h.avg_daily_billedcost) / h.stddev_daily_billedcost)
            ELSE NULL::numeric
        END AS z_score,
    h.resourceid,
    h.skumeter,
    h.avg_daily_consumedquantity AS historical_avg_consumedquantity,
    h.min_daily_consumedquantity AS historical_min_consumedquantity,
    h.max_daily_consumedquantity AS historical_max_consumedquantity,
    c.current_day_total_consumedquantity AS current_day_consumedquantity,
    c.chargeperiodstart,
    c.chargeperiodend,
    h.x_operation,
    h.billingaccountid,
    h.subaccountid,
    h.regionid,
    h.servicecategory,
    h.instance_type,
    h.instance_series,
    h.chargecategory,
    h.tenant_id,
    h.days_in_period,
    h.historical_period_start,
    h.historical_period_end
   FROM (public.aws_cost_focus_historical_data h
     JOIN public.aws_focus_cost_current c ON (((h.resourceid = c.resourceid) AND (h.skumeter = c.skumeter) AND (h.tenant_id = c.tenant_id) AND (h.subaccountid = c.subaccountid) AND (h.billingaccountid = c.billingaccountid))))
  WHERE ((h.avg_daily_billedcost > (0)::numeric) AND ((((c.current_day_total_billedcost - h.avg_daily_billedcost) / h.avg_daily_billedcost) * (100)::numeric) > (15)::numeric))
  ORDER BY
        CASE
            WHEN (h.stddev_daily_billedcost > (0)::numeric) THEN ((c.current_day_total_billedcost - h.avg_daily_billedcost) / h.stddev_daily_billedcost)
            ELSE NULL::numeric
        END DESC NULLS LAST;


ALTER TABLE public.aws_cost_analysis_current_historical_1 OWNER TO postgres;

--
-- Name: aws_focus_cost_previous; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.aws_focus_cost_previous AS
 SELECT aws_focus_cost_data.servicename,
    sum(aws_focus_cost_data.billedcost) AS previous_day_total_billedcost,
    sum(aws_focus_cost_data.consumedquantity) AS previous_day_total_consumedquantity,
    aws_focus_cost_data.chargeperiodstart,
    aws_focus_cost_data.chargeperiodend,
    aws_focus_cost_data.resourceid,
    aws_focus_cost_data.skumeter,
    aws_focus_cost_data.x_operation,
    aws_focus_cost_data.billingaccountid,
    aws_focus_cost_data.subaccountid,
    aws_focus_cost_data.regionid,
    aws_focus_cost_data.servicecategory,
    aws_focus_cost_data.month,
    aws_focus_cost_data.year,
    aws_focus_cost_data.instance_type,
    aws_focus_cost_data.instance_series,
    aws_focus_cost_data.chargecategory,
    aws_focus_cost_data.tenant_id
   FROM public.aws_focus_cost_data
  WHERE ((aws_focus_cost_data.chargeperiodstart = ( SELECT max(aws_focus_cost_data_1.chargeperiodstart) AS max
           FROM public.aws_focus_cost_data aws_focus_cost_data_1
          WHERE (aws_focus_cost_data_1.chargeperiodstart < ( SELECT max(aws_focus_cost_data_2.chargeperiodstart) AS max
                   FROM public.aws_focus_cost_data aws_focus_cost_data_2)))) AND (aws_focus_cost_data.billedcost > (0)::numeric))
  GROUP BY aws_focus_cost_data.chargeperiodstart, aws_focus_cost_data.chargeperiodend, aws_focus_cost_data.resourceid, aws_focus_cost_data.servicename, aws_focus_cost_data.skumeter, aws_focus_cost_data.x_operation, aws_focus_cost_data.billingaccountid, aws_focus_cost_data.subaccountid, aws_focus_cost_data.regionid, aws_focus_cost_data.servicecategory, aws_focus_cost_data.month, aws_focus_cost_data.year, aws_focus_cost_data.instance_type, aws_focus_cost_data.instance_series, aws_focus_cost_data.chargecategory, aws_focus_cost_data.tenant_id, (date(aws_focus_cost_data.load_ts))
  ORDER BY (sum(aws_focus_cost_data.billedcost)) DESC;


ALTER TABLE public.aws_focus_cost_previous OWNER TO postgres;

--
-- Name: aws_cost_analysis_current_previous; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.aws_cost_analysis_current_previous AS
 SELECT aws_focus_cost_previous.servicename,
    aws_focus_cost_previous.previous_day_total_billedcost AS billedcost_previous,
    aws_focus_cost_current.current_day_total_billedcost AS billedcost_current,
    (((aws_focus_cost_current.current_day_total_billedcost - aws_focus_cost_previous.previous_day_total_billedcost) / aws_focus_cost_previous.previous_day_total_billedcost) * (100)::numeric) AS percentage,
    (aws_focus_cost_current.current_day_total_billedcost - aws_focus_cost_previous.previous_day_total_billedcost) AS difference,
    aws_focus_cost_previous.resourceid,
    aws_focus_cost_previous.skumeter,
    aws_focus_cost_previous.previous_day_total_consumedquantity AS previous_day_consumedquantity,
    aws_focus_cost_current.current_day_total_consumedquantity AS current_day_consumedquantity,
    aws_focus_cost_previous.chargeperiodstart,
    aws_focus_cost_previous.chargeperiodend,
    aws_focus_cost_previous.x_operation,
    aws_focus_cost_previous.billingaccountid,
    aws_focus_cost_previous.subaccountid,
    aws_focus_cost_previous.regionid,
    aws_focus_cost_previous.servicecategory,
    aws_focus_cost_previous.instance_type,
    aws_focus_cost_previous.instance_series,
    aws_focus_cost_previous.chargecategory,
    aws_focus_cost_previous.tenant_id
   FROM (public.aws_focus_cost_previous
     JOIN public.aws_focus_cost_current ON (((aws_focus_cost_previous.resourceid = aws_focus_cost_current.resourceid) AND (aws_focus_cost_previous.skumeter = aws_focus_cost_current.skumeter) AND (aws_focus_cost_previous.tenant_id = aws_focus_cost_current.tenant_id) AND (aws_focus_cost_previous.subaccountid = aws_focus_cost_current.subaccountid) AND (aws_focus_cost_previous.billingaccountid = aws_focus_cost_current.billingaccountid))))
  ORDER BY (aws_focus_cost_current.current_day_total_billedcost - aws_focus_cost_previous.previous_day_total_billedcost) DESC;


ALTER TABLE public.aws_cost_analysis_current_previous OWNER TO postgres;

--
-- Name: aws_cost_anomaly_agent_output; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aws_cost_anomaly_agent_output (
    id integer NOT NULL,
    agent_type character varying(100) NOT NULL,
    ingestion_date timestamp without time zone NOT NULL,
    service_name character varying(255) NOT NULL,
    service_cost character varying(255) NOT NULL,
    resource text NOT NULL,
    billing_account_id character varying(50) NOT NULL,
    sub_account_id character varying(50) NOT NULL,
    region character varying(50) NOT NULL,
    skumeter character varying(255) NOT NULL,
    consumed_quantity character varying(255) NOT NULL,
    charge_category character varying(100) NOT NULL,
    severity character varying(20) NOT NULL,
    root_cause_hypothesis text NOT NULL,
    recommendation text NOT NULL,
    summary text NOT NULL,
    tenant_id character varying,
    cost_category character varying(50) DEFAULT 'Unknown'::character varying NOT NULL,
    run_date date
);


ALTER TABLE public.aws_cost_anomaly_agent_output OWNER TO postgres;

--
-- Name: aws_cost_anomaly_agent_output_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aws_cost_anomaly_agent_output_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aws_cost_anomaly_agent_output_id_seq OWNER TO postgres;

--
-- Name: aws_cost_anomaly_agent_output_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aws_cost_anomaly_agent_output_id_seq OWNED BY public.aws_cost_anomaly_agent_output.id;


--
-- Name: aws_focus_cost_current_mock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aws_focus_cost_current_mock (
    id integer NOT NULL,
    servicename character varying(255),
    current_day_total_billedcost numeric(12,6),
    current_day_total_consumedquantity numeric(20,6),
    chargeperiodstart date,
    chargeperiodend date,
    resourceid character varying(512),
    skumeter character varying(255),
    x_operation character varying(255),
    billingaccountid character varying(20),
    subaccountid character varying(20),
    regionid character varying(50),
    servicecategory character varying(100),
    month integer,
    year integer,
    instance_type character varying(100),
    instance_series character varying(100),
    chargecategory character varying(100),
    tenant_id character varying(255),
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.aws_focus_cost_current_mock OWNER TO postgres;

--
-- Name: aws_focus_cost_current_mock_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aws_focus_cost_current_mock_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aws_focus_cost_current_mock_id_seq OWNER TO postgres;

--
-- Name: aws_focus_cost_current_mock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aws_focus_cost_current_mock_id_seq OWNED BY public.aws_focus_cost_current_mock.id;


--
-- Name: aws_forecasting_python_dst; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.aws_forecasting_python_dst (
    account character varying,
    forecasted_values numeric,
    month character varying,
    row_id character varying,
    tenant_id character varying,
    pseudo_primary_key character varying NOT NULL,
    date date,
    type character varying
);


ALTER TABLE public.aws_forecasting_python_dst OWNER TO "prism-web";

--
-- Name: aws_obp_python_dst; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.aws_obp_python_dst (
    account_id character varying,
    control_id character varying,
    date_time date,
    primary_key character varying,
    category character varying,
    compliance_type character varying,
    description character varying,
    offenders character varying,
    result boolean,
    risk_level character varying,
    fail_reason character varying,
    resource_type character varying,
    tenant_id character varying,
    pseudo_primary_key character varying,
    cloud_provider character varying
);


ALTER TABLE public.aws_obp_python_dst OWNER TO "prism-web";

--
-- Name: aws_recommendation_consolidate; Type: TABLE; Schema: public; Owner: finops
--

CREATE TABLE public.aws_recommendation_consolidate (
    id bigint NOT NULL,
    type text,
    account text,
    region text,
    resource_name text,
    resource_id text,
    service text,
    sub_service text,
    recommendation_category text,
    description text,
    potential numeric(18,4),
    actual_cost numeric(18,4),
    target_cost numeric(18,4),
    current_configuration text,
    expected_configuration text,
    justifications text,
    tags_json jsonb,
    actionable boolean,
    risk_level text,
    impact text
);


ALTER TABLE public.aws_recommendation_consolidate OWNER TO finops;

--
-- Name: aws_recommendation_consolidate_id_seq; Type: SEQUENCE; Schema: public; Owner: finops
--

CREATE SEQUENCE public.aws_recommendation_consolidate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aws_recommendation_consolidate_id_seq OWNER TO finops;

--
-- Name: aws_recommendation_consolidate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: finops
--

ALTER SEQUENCE public.aws_recommendation_consolidate_id_seq OWNED BY public.aws_recommendation_consolidate.id;


--
-- Name: aws_recommendations_python_dst; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.aws_recommendations_python_dst (
    category character varying,
    cost_savings numeric,
    current_cost numeric,
    effective_cost numeric,
    description character varying,
    id character varying,
    metadata character varying,
    profile character varying,
    recommendation_reason character varying,
    recommendation character varying,
    region character varying,
    risk_level character varying,
    row_id character varying,
    savings_percent numeric,
    service_name character varying,
    source character varying,
    tenant_id character varying,
    pseudo_primary_key character varying NOT NULL
);


ALTER TABLE public.aws_recommendations_python_dst OWNER TO "prism-web";

--
-- Name: aws_resource_changes; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.aws_resource_changes (
    resource character varying,
    product_product_name character varying,
    line_item_usage_account_id character varying,
    product_region character varying,
    month character varying,
    year character varying,
    unblended_cost numeric,
    pseudo_primary_key character varying NOT NULL,
    tenant_id character varying
);


ALTER TABLE public.aws_resource_changes OWNER TO "prism-web";

--
-- Name: aws_s3_data_insights; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aws_s3_data_insights (
    id integer NOT NULL,
    bucket_name character varying(255) NOT NULL,
    resource_arn character varying(512),
    region character varying(50) NOT NULL,
    billing_account_id character varying(20),
    subaccount_id character varying(20),
    total_size_bytes bigint,
    total_size_gb numeric(12,4),
    total_object_count bigint,
    average_object_size_bytes bigint,
    size_by_storage_class_json jsonb,
    last_modified_oldest timestamp without time zone,
    last_modified_newest timestamp without time zone,
    noncurrent_version_count integer,
    noncurrent_version_size_bytes bigint,
    noncurrent_version_size_gb numeric(12,4),
    delete_marker_count integer,
    incomplete_multipart_count integer,
    incomplete_multipart_oldest timestamp without time zone,
    incomplete_multipart_newest timestamp without time zone,
    lifecycle_rules_count integer,
    lifecycle_rules_json jsonb,
    versioning_status character varying(20),
    versioning_mfa_delete character varying(20),
    replication_enabled boolean,
    replication_destinations_json jsonb,
    warnings_json jsonb,
    last_updated timestamp without time zone DEFAULT now(),
    data_collection_status character varying(20) DEFAULT 'success'::character varying
);


ALTER TABLE public.aws_s3_data_insights OWNER TO postgres;

--
-- Name: aws_s3_data_insights_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aws_s3_data_insights_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aws_s3_data_insights_id_seq OWNER TO postgres;

--
-- Name: aws_s3_data_insights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aws_s3_data_insights_id_seq OWNED BY public.aws_s3_data_insights.id;


--
-- Name: aws_s3_data_insights_mock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aws_s3_data_insights_mock (
    id integer NOT NULL,
    bucket_name character varying(255) NOT NULL,
    resource_arn character varying(512),
    region character varying(50) NOT NULL,
    billing_account_id character varying(20),
    subaccount_id character varying(20),
    total_size_bytes bigint,
    total_size_gb numeric(12,4),
    total_object_count bigint,
    average_object_size_bytes bigint,
    size_by_storage_class_json jsonb,
    last_modified_oldest timestamp without time zone,
    last_modified_newest timestamp without time zone,
    noncurrent_version_count integer,
    noncurrent_version_size_bytes bigint,
    noncurrent_version_size_gb numeric(12,4),
    delete_marker_count integer,
    incomplete_multipart_count integer,
    incomplete_multipart_oldest timestamp without time zone,
    incomplete_multipart_newest timestamp without time zone,
    lifecycle_rules_count integer,
    lifecycle_rules_json jsonb,
    versioning_status character varying(20),
    versioning_mfa_delete boolean,
    replication_enabled boolean,
    replication_destinations_json jsonb,
    warnings_json jsonb,
    last_updated timestamp without time zone DEFAULT now(),
    data_collection_status character varying(20) DEFAULT 'ENABLED'::character varying
);


ALTER TABLE public.aws_s3_data_insights_mock OWNER TO postgres;

--
-- Name: aws_s3_data_insights_mock_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aws_s3_data_insights_mock_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aws_s3_data_insights_mock_id_seq OWNER TO postgres;

--
-- Name: aws_s3_data_insights_mock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aws_s3_data_insights_mock_id_seq OWNED BY public.aws_s3_data_insights_mock.id;


--
-- Name: aws_s3_observations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aws_s3_observations (
    version_number text,
    configuration_id text,
    account_id text NOT NULL,
    report_date date,
    aws_region text,
    storage_class text,
    record_type text,
    record_value text,
    bucket_name text,
    metric_name text,
    metric_value bigint,
    metric_value_gb double precision,
    metric_value_tb double precision,
    load_ts timestamp without time zone NOT NULL
);


ALTER TABLE public.aws_s3_observations OWNER TO postgres;

--
-- Name: awscostdetails_current_month; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.awscostdetails_current_month (
    bill_payer_account_id character varying,
    line_item_usage_account_id character varying,
    product_region character varying,
    product_product_name character varying,
    product_servicename character varying,
    line_item_usage_type character varying,
    line_item_resource_id character varying,
    line_item_unblended_cost numeric,
    line_item_usage_amount numeric,
    month character varying,
    year character varying,
    line_item_operation character varying,
    product_instance_type character varying,
    product_instance_family character varying,
    product_current_generation character varying,
    resource_tags_user_name character varying,
    line_item_line_item_type character varying,
    pseudo_primary_key character varying NOT NULL,
    tenant_id character varying,
    line_item_usage_start_date date,
    line_item_usage_end_date date
);


ALTER TABLE public.awscostdetails_current_month OWNER TO "prism-web";

--
-- Name: awscostdetails_previous_month; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.awscostdetails_previous_month (
    bill_payer_account_id character varying,
    line_item_usage_account_id character varying,
    product_region character varying,
    product_product_name character varying,
    product_servicename character varying,
    line_item_usage_type character varying,
    line_item_resource_id character varying,
    line_item_unblended_cost numeric,
    line_item_usage_amount numeric,
    month character varying,
    year character varying,
    line_item_operation character varying,
    product_instance_type character varying,
    product_instance_family character varying,
    product_current_generation character varying,
    resource_tags_user_name character varying,
    line_item_line_item_type character varying,
    pseudo_primary_key character varying NOT NULL,
    tenant_id character varying
);


ALTER TABLE public.awscostdetails_previous_month OWNER TO "prism-web";

--
-- Name: azure_focus_cost_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.azure_focus_cost_data (
    x_billingaccountid text,
    subaccountid text,
    subaccountname text,
    regionid text,
    chargedescription text,
    servicecategory text,
    resourceid text,
    resourcename text,
    billedcost double precision,
    year integer,
    tags text,
    chargecategory text,
    x_pricingunitdescription text,
    x_billedunitprice numeric(38,18),
    x_skuiscrediteligible boolean,
    billingcurrency text,
    x_resourcegroupname text,
    x_accountname text,
    x_accountownerid text,
    billingaccountname text,
    x_costcenter text,
    x_billingprofilename text,
    consumedquantity double precision,
    chargeperiodend date,
    chargeperiodstart date,
    x_billingprofileid text,
    billingperiodstart timestamp without time zone,
    billingperiodend timestamp without time zone,
    pseudo_primary_key text NOT NULL,
    tenant_id text NOT NULL,
    load_ts timestamp without time zone NOT NULL
);


ALTER TABLE public.azure_focus_cost_data OWNER TO postgres;

--
-- Name: best_practices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.best_practices (
    id integer NOT NULL,
    db_type character varying(50),
    priority character varying(2),
    best_practice text NOT NULL
);


ALTER TABLE public.best_practices OWNER TO postgres;

--
-- Name: best_practices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.best_practices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.best_practices_id_seq OWNER TO postgres;

--
-- Name: best_practices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.best_practices_id_seq OWNED BY public.best_practices.id;


--
-- Name: byod_batch_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.byod_batch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.byod_batch_seq OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    category_id integer NOT NULL,
    category_name character varying(100) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: TABLE categories; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.categories IS 'Product categories for classification';


--
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_category_id_seq OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;


--
-- Name: ce_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ce_logs (
    trace_id text,
    span_id text,
    level text NOT NULL,
    message text NOT NULL,
    logger_name text NOT NULL,
    attributes text NOT NULL,
    service_name text NOT NULL,
    insertion_time timestamp without time zone NOT NULL,
    "timestamp" timestamp without time zone NOT NULL
);


ALTER TABLE public.ce_logs OWNER TO postgres;

--
-- Name: ce_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ce_metrics (
    metric_name text NOT NULL,
    metric_type text NOT NULL,
    value double precision NOT NULL,
    trace_id text,
    span_id text,
    tags text NOT NULL,
    tool_name text,
    service_name text NOT NULL,
    insertion_time timestamp without time zone NOT NULL,
    "timestamp" timestamp without time zone NOT NULL
);


ALTER TABLE public.ce_metrics OWNER TO postgres;

--
-- Name: ce_traces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ce_traces (
    trace_id text NOT NULL,
    span_id text NOT NULL,
    parent_span_id text,
    name text NOT NULL,
    kind smallint NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    duration_ms real NOT NULL,
    status text NOT NULL,
    error_message text,
    service_name text NOT NULL,
    environment text NOT NULL,
    attributes text NOT NULL,
    request_id text,
    session_id text,
    insertion_time timestamp without time zone NOT NULL
);


ALTER TABLE public.ce_traces OWNER TO postgres;

--
-- Name: conversation_memory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversation_memory (
    id integer NOT NULL,
    thread_id character varying(255) NOT NULL,
    user_id character varying(255) NOT NULL,
    session_id character varying(255) NOT NULL,
    tenant_id character varying(255),
    user_message text NOT NULL,
    bot_response text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.conversation_memory OWNER TO postgres;

--
-- Name: conversation_memory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conversation_memory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.conversation_memory_id_seq OWNER TO postgres;

--
-- Name: conversation_memory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conversation_memory_id_seq OWNED BY public.conversation_memory.id;


--
-- Name: cost_analysis_0910; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.cost_analysis_0910 AS
 SELECT aws_cost_20260902.servicename,
    aws_cost_20260902.total_billedcost AS billedcost_09,
    aws_cost_20261002.total_billedcost AS billedcost_10,
    (((aws_cost_20261002.total_billedcost - aws_cost_20260902.total_billedcost) / aws_cost_20260902.total_billedcost) * (100)::numeric) AS percentage,
    (aws_cost_20261002.total_billedcost - aws_cost_20260902.total_billedcost) AS difference,
    aws_cost_20260902.resourceid,
    aws_cost_20260902.skumeter,
    aws_cost_20260902.total_consumedquantity AS previous_day_consumedquantity,
    aws_cost_20261002.total_consumedquantity AS current_day_consumedquantity,
    aws_cost_20260902.chargeperiodstart,
    aws_cost_20260902.chargeperiodend,
    aws_cost_20260902.x_operation,
    aws_cost_20260902.billingaccountid,
    aws_cost_20260902.subaccountid,
    aws_cost_20260902.regionid,
    aws_cost_20260902.servicecategory,
    aws_cost_20260902.instance_type,
    aws_cost_20260902.instance_series,
    aws_cost_20260902.resource_tags_user_name,
    aws_cost_20260902.chargecategory,
    aws_cost_20260902.tenant_id
   FROM (public.aws_cost_20260902
     JOIN public.aws_cost_20261002 ON (((aws_cost_20260902.resourceid = aws_cost_20261002.resourceid) AND (aws_cost_20260902.skumeter = aws_cost_20261002.skumeter) AND (aws_cost_20260902.tenant_id = aws_cost_20261002.tenant_id) AND (aws_cost_20260902.subaccountid = aws_cost_20261002.subaccountid) AND (aws_cost_20260902.billingaccountid = aws_cost_20261002.billingaccountid))))
  ORDER BY (aws_cost_20261002.total_billedcost - aws_cost_20260902.total_billedcost) DESC;


ALTER TABLE public.cost_analysis_0910 OWNER TO postgres;

--
-- Name: cronjob_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cronjob_config (
    job_name text NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    frequency text NOT NULL,
    run_time_utc time without time zone,
    cron_expression text,
    time_zone text DEFAULT 'UTC'::text NOT NULL,
    container_image text NOT NULL,
    command text NOT NULL,
    args text,
    env_secret_name text,
    aws_auth_mode text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cronjob_config_frequency_chk CHECK ((frequency = ANY (ARRAY['hourly'::text, 'daily'::text, 'weekly'::text, 'monthly'::text, 'custom'::text])))
);


ALTER TABLE public.cronjob_config OWNER TO postgres;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    customer_id integer NOT NULL,
    customer_name character varying(200) NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(20),
    address text,
    city character varying(100),
    state character varying(100),
    postal_code character varying(20),
    country character varying(100),
    region_id integer,
    customer_type character varying(50) DEFAULT 'Retail'::character varying,
    registration_date date NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: TABLE customers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.customers IS 'Customer master data';


--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customers_customer_id_seq OWNER TO postgres;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_customer_id_seq OWNED BY public.customers.customer_id;


--
-- Name: databricks_cloud_cost; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_cloud_cost (
    tenant_id character varying(255),
    cluster_id character varying(255),
    cluster_name character varying(500),
    instance_id character varying(255),
    usage_date timestamp without time zone,
    billedcost numeric(30,6),
    total_billed_cost numeric(30,6),
    etl_load_timestamp timestamp without time zone,
    source_system character varying(50)
);


ALTER TABLE public.databricks_cloud_cost OWNER TO postgres;

--
-- Name: databricks_cluster_cost; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_cluster_cost (
    account_id character varying(255),
    cluster_id character varying(255),
    cluster_name character varying(500),
    owned_by character varying(255),
    instance_type character varying(100),
    tags text,
    sku_name character varying(255),
    workspace_id character varying(255),
    workspace_name character varying(500),
    usage_start_time timestamp without time zone,
    usage_end_time timestamp without time zone,
    usage_quantity numeric(18,6),
    per_dbu_cost numeric(18,6),
    cost numeric(18,6),
    total_cluster_cost numeric(18,6),
    etl_load_timestamp timestamp without time zone,
    source_system character varying(50),
    tenant_id character varying(255),
    cloud_cost numeric(30,6),
    total_cost numeric(30,6)
);


ALTER TABLE public.databricks_cluster_cost OWNER TO postgres;

--
-- Name: databricks_cluster_cost_current; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_cluster_cost_current AS
 SELECT databricks_cluster_cost.account_id,
    databricks_cluster_cost.cluster_id,
    databricks_cluster_cost.cluster_name,
    databricks_cluster_cost.owned_by,
    databricks_cluster_cost.workspace_id,
    databricks_cluster_cost.workspace_name,
    databricks_cluster_cost.instance_type,
    databricks_cluster_cost.sku_name,
    databricks_cluster_cost.tags,
    sum(databricks_cluster_cost.cost) AS current_day_dbu_cost,
    sum(databricks_cluster_cost.cloud_cost) AS current_day_cloud_cost,
    sum(databricks_cluster_cost.total_cost) AS current_day_total_cost,
    sum(databricks_cluster_cost.usage_quantity) AS current_day_usage_quantity,
    avg(databricks_cluster_cost.per_dbu_cost) AS avg_per_dbu_cost,
    max(databricks_cluster_cost.usage_end_time) AS latest_usage_time,
    databricks_cluster_cost.tenant_id,
    databricks_cluster_cost.source_system
   FROM public.databricks_cluster_cost
  WHERE ((date(databricks_cluster_cost.usage_start_time) = ( SELECT max(date(databricks_cluster_cost_1.usage_start_time)) AS max
           FROM public.databricks_cluster_cost databricks_cluster_cost_1)) AND (databricks_cluster_cost.total_cost > (0)::numeric))
  GROUP BY databricks_cluster_cost.account_id, databricks_cluster_cost.cluster_id, databricks_cluster_cost.cluster_name, databricks_cluster_cost.owned_by, databricks_cluster_cost.workspace_id, databricks_cluster_cost.workspace_name, databricks_cluster_cost.instance_type, databricks_cluster_cost.sku_name, databricks_cluster_cost.tags, databricks_cluster_cost.tenant_id, databricks_cluster_cost.source_system
  ORDER BY (sum(databricks_cluster_cost.total_cost)) DESC;


ALTER TABLE public.databricks_cluster_cost_current OWNER TO postgres;

--
-- Name: databricks_cluster_cost_previous; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_cluster_cost_previous AS
 SELECT databricks_cluster_cost.account_id,
    databricks_cluster_cost.cluster_id,
    databricks_cluster_cost.cluster_name,
    databricks_cluster_cost.owned_by,
    databricks_cluster_cost.workspace_id,
    databricks_cluster_cost.workspace_name,
    databricks_cluster_cost.instance_type,
    databricks_cluster_cost.sku_name,
    databricks_cluster_cost.tags,
    sum(databricks_cluster_cost.cost) AS previous_day_dbu_cost,
    sum(databricks_cluster_cost.cloud_cost) AS previous_day_cloud_cost,
    sum(databricks_cluster_cost.total_cost) AS previous_day_total_cost,
    sum(databricks_cluster_cost.usage_quantity) AS previous_day_usage_quantity,
    avg(databricks_cluster_cost.per_dbu_cost) AS avg_per_dbu_cost,
    max(databricks_cluster_cost.usage_end_time) AS latest_usage_time,
    databricks_cluster_cost.tenant_id,
    databricks_cluster_cost.source_system
   FROM public.databricks_cluster_cost
  WHERE ((date(databricks_cluster_cost.usage_start_time) = ( SELECT max(date(databricks_cluster_cost_1.usage_start_time)) AS max
           FROM public.databricks_cluster_cost databricks_cluster_cost_1
          WHERE (date(databricks_cluster_cost_1.usage_start_time) < ( SELECT max(date(databricks_cluster_cost_2.usage_start_time)) AS max
                   FROM public.databricks_cluster_cost databricks_cluster_cost_2)))) AND (databricks_cluster_cost.total_cost > (0)::numeric))
  GROUP BY databricks_cluster_cost.account_id, databricks_cluster_cost.cluster_id, databricks_cluster_cost.cluster_name, databricks_cluster_cost.owned_by, databricks_cluster_cost.workspace_id, databricks_cluster_cost.workspace_name, databricks_cluster_cost.instance_type, databricks_cluster_cost.sku_name, databricks_cluster_cost.tags, databricks_cluster_cost.tenant_id, databricks_cluster_cost.source_system
  ORDER BY (sum(databricks_cluster_cost.total_cost)) DESC;


ALTER TABLE public.databricks_cluster_cost_previous OWNER TO postgres;

--
-- Name: databricks_cluster_cost_comparison; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_cluster_cost_comparison AS
 SELECT COALESCE(curr.account_id, prev.account_id) AS account_id,
    COALESCE(curr.cluster_id, prev.cluster_id) AS cluster_id,
    COALESCE(curr.cluster_name, prev.cluster_name) AS cluster_name,
    COALESCE(curr.owned_by, prev.owned_by) AS owned_by,
    COALESCE(curr.workspace_id, prev.workspace_id) AS workspace_id,
    COALESCE(curr.workspace_name, prev.workspace_name) AS workspace_name,
    COALESCE(curr.instance_type, prev.instance_type) AS instance_type,
    COALESCE(curr.sku_name, prev.sku_name) AS sku_name,
    COALESCE(curr.tags, prev.tags) AS tags,
    COALESCE(prev.previous_day_dbu_cost, (0)::numeric) AS previous_day_dbu_cost,
    COALESCE(prev.previous_day_cloud_cost, (0)::numeric) AS previous_day_cloud_cost,
    COALESCE(prev.previous_day_total_cost, (0)::numeric) AS previous_day_total_cost,
    COALESCE(prev.previous_day_usage_quantity, (0)::numeric) AS previous_day_usage_quantity,
    COALESCE(curr.current_day_dbu_cost, (0)::numeric) AS current_day_dbu_cost,
    COALESCE(curr.current_day_cloud_cost, (0)::numeric) AS current_day_cloud_cost,
    COALESCE(curr.current_day_total_cost, (0)::numeric) AS current_day_total_cost,
    COALESCE(curr.current_day_usage_quantity, (0)::numeric) AS current_day_usage_quantity,
    (COALESCE(curr.current_day_total_cost, (0)::numeric) - COALESCE(prev.previous_day_total_cost, (0)::numeric)) AS cost_difference,
    (COALESCE(curr.current_day_usage_quantity, (0)::numeric) - COALESCE(prev.previous_day_usage_quantity, (0)::numeric)) AS usage_quantity_difference,
        CASE
            WHEN (COALESCE(prev.previous_day_total_cost, (0)::numeric) > (0)::numeric) THEN (((COALESCE(curr.current_day_total_cost, (0)::numeric) - COALESCE(prev.previous_day_total_cost, (0)::numeric)) / prev.previous_day_total_cost) * (100)::numeric)
            ELSE NULL::numeric
        END AS cost_percentage_change,
    COALESCE(curr.tenant_id, prev.tenant_id) AS tenant_id,
    COALESCE(curr.source_system, prev.source_system) AS source_system
   FROM (public.databricks_cluster_cost_current curr
     FULL JOIN public.databricks_cluster_cost_previous prev ON ((((curr.cluster_id)::text = (prev.cluster_id)::text) AND ((curr.workspace_id)::text = (prev.workspace_id)::text) AND ((curr.tenant_id)::text = (prev.tenant_id)::text) AND ((curr.account_id)::text = (prev.account_id)::text))))
  WHERE ((COALESCE(curr.current_day_total_cost, (0)::numeric) - COALESCE(prev.previous_day_total_cost, (0)::numeric)) <> (0)::numeric)
  ORDER BY (abs((COALESCE(curr.current_day_total_cost, (0)::numeric) - COALESCE(prev.previous_day_total_cost, (0)::numeric)))) DESC;


ALTER TABLE public.databricks_cluster_cost_comparison OWNER TO postgres;

--
-- Name: databricks_cluster_idle_time; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_cluster_idle_time (
    cluster_id character varying,
    inactive_seconds numeric,
    active_seconds numeric,
    etl_load_timestamp timestamp without time zone,
    source_system character varying(50),
    tenant_id character varying(255),
    usage_date date
);


ALTER TABLE public.databricks_cluster_idle_time OWNER TO postgres;

--
-- Name: databricks_cluster_optimization_recommendation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_cluster_optimization_recommendation (
    cluster_id character varying,
    cluster_name character varying,
    cluster_source character varying,
    auto_termination_minutes numeric,
    min_workers numeric,
    max_workers numeric,
    dbr numeric,
    workspace_name character varying,
    recommendation character varying,
    etl_load_timestamp timestamp without time zone,
    source_system character varying(50),
    node_type character varying,
    tenant_id character varying,
    account_id character varying
);


ALTER TABLE public.databricks_cluster_optimization_recommendation OWNER TO postgres;

--
-- Name: databricks_cluster_performance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_cluster_performance (
    tenant_id character varying(255),
    account_id character varying(255),
    workspace_id character varying(255),
    cluster_id character varying(255),
    instance_id character varying(255),
    node_type character varying(100),
    driver boolean,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    cpu_user_percent numeric(18,6),
    cpu_system_percent numeric(18,6),
    cpu_wait_percent numeric(18,6),
    mem_used_percent numeric(18,6),
    mem_swap_percent numeric(18,6),
    network_sent_bytes bigint,
    network_received_bytes bigint,
    instance_type character varying(100),
    private_ip character varying(100),
    cluster_name character varying(500),
    workspace_name character varying(500),
    etl_load_timestamp timestamp without time zone,
    source_system character varying(50),
    disk_free_bytes_per_mount_point text
);


ALTER TABLE public.databricks_cluster_performance OWNER TO postgres;

--
-- Name: databricks_cluster_resize_recommendation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_cluster_resize_recommendation (
    year integer,
    month integer,
    cluster_id character varying(255),
    cluster_name character varying(500),
    avg_cpu numeric(18,6),
    avg_mem numeric(18,6),
    worker_count integer,
    etl_load_timestamp timestamp without time zone,
    source_system character varying(50),
    potential_saving numeric,
    recommendation character varying,
    node_type character varying,
    tenant_id character varying,
    account_id character varying,
    workspace_name character varying
);


ALTER TABLE public.databricks_cluster_resize_recommendation OWNER TO postgres;

--
-- Name: databricks_generated_optimized_queries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_generated_optimized_queries (
    user_email character varying(255),
    query_id character varying(50),
    original_query text NOT NULL,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    duration integer,
    database_name text,
    schema_name text,
    bot_response text,
    query_understanding text,
    query_issues text,
    explain_plan_understanding text,
    metadata_understanding text,
    optimizations_recommendations text,
    optimized_query text,
    optimization_explanation text,
    ingestion_time timestamp without time zone NOT NULL
);


ALTER TABLE public.databricks_generated_optimized_queries OWNER TO postgres;

--
-- Name: databricks_job_anomaly; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_job_anomaly (
    job_id numeric,
    job_name character varying,
    anomaly_type character varying,
    anomaly_detected character varying,
    expected_duration numeric,
    actual_duration numeric,
    scheduled_start character varying,
    actual_start character varying,
    expected_network character varying,
    actual_network character varying,
    date date,
    workspace_name character varying,
    tenant_id character varying,
    result_state character varying,
    executor character varying,
    account_id character varying
);


ALTER TABLE public.databricks_job_anomaly OWNER TO postgres;

--
-- Name: databricks_job_cost; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_job_cost (
    workspace_id character varying(255),
    job_id character varying(255),
    run_id character varying(255),
    period_start_time timestamp without time zone,
    period_end_time timestamp without time zone,
    task_key character varying(255),
    result_state character varying(50),
    job_run_id character varying(255),
    execution_duration_seconds numeric,
    setup_duration_seconds numeric,
    compute_id character varying(255),
    name character varying(500),
    run_as character varying(255),
    run_as_user_name character varying(255),
    etl_load_timestamp timestamp without time zone,
    source_system character varying(50),
    job_duration numeric,
    job_cost numeric(20,6),
    tenant_id character varying(255),
    account_id character varying,
    tags character varying,
    workspace_name character varying
);


ALTER TABLE public.databricks_job_cost OWNER TO postgres;

--
-- Name: databricks_job_cost_current; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_job_cost_current AS
 SELECT databricks_job_cost.account_id,
    databricks_job_cost.workspace_id,
    databricks_job_cost.workspace_name,
    databricks_job_cost.job_id,
    databricks_job_cost.name AS job_name,
    databricks_job_cost.compute_id,
    databricks_job_cost.run_as,
    databricks_job_cost.run_as_user_name,
    databricks_job_cost.tags,
    sum(databricks_job_cost.job_cost) AS current_day_job_cost,
    sum(databricks_job_cost.job_duration) AS current_day_job_duration,
    count(DISTINCT databricks_job_cost.run_id) AS current_day_run_count,
    avg(databricks_job_cost.execution_duration_seconds) AS avg_execution_duration,
    avg(databricks_job_cost.setup_duration_seconds) AS avg_setup_duration,
    sum(
        CASE
            WHEN ((databricks_job_cost.result_state)::text = 'SUCCESS'::text) THEN 1
            ELSE 0
        END) AS success_count,
    sum(
        CASE
            WHEN ((databricks_job_cost.result_state)::text = 'FAILED'::text) THEN 1
            ELSE 0
        END) AS failed_count,
    sum(
        CASE
            WHEN ((databricks_job_cost.result_state)::text = 'CANCELLED'::text) THEN 1
            ELSE 0
        END) AS cancelled_count,
    databricks_job_cost.tenant_id,
    databricks_job_cost.source_system
   FROM public.databricks_job_cost
  WHERE ((date(databricks_job_cost.period_start_time) = ( SELECT max(date(databricks_job_cost_1.period_start_time)) AS max
           FROM public.databricks_job_cost databricks_job_cost_1)) AND (databricks_job_cost.job_cost > (0)::numeric))
  GROUP BY databricks_job_cost.account_id, databricks_job_cost.workspace_id, databricks_job_cost.workspace_name, databricks_job_cost.job_id, databricks_job_cost.name, databricks_job_cost.compute_id, databricks_job_cost.run_as, databricks_job_cost.run_as_user_name, databricks_job_cost.tags, databricks_job_cost.tenant_id, databricks_job_cost.source_system
  ORDER BY (sum(databricks_job_cost.job_cost)) DESC;


ALTER TABLE public.databricks_job_cost_current OWNER TO postgres;

--
-- Name: databricks_job_cost_previous; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_job_cost_previous AS
 SELECT databricks_job_cost.account_id,
    databricks_job_cost.workspace_id,
    databricks_job_cost.workspace_name,
    databricks_job_cost.job_id,
    databricks_job_cost.name AS job_name,
    databricks_job_cost.compute_id,
    databricks_job_cost.run_as,
    databricks_job_cost.run_as_user_name,
    databricks_job_cost.tags,
    sum(databricks_job_cost.job_cost) AS previous_day_job_cost,
    sum(databricks_job_cost.job_duration) AS previous_day_job_duration,
    count(DISTINCT databricks_job_cost.run_id) AS previous_day_run_count,
    avg(databricks_job_cost.execution_duration_seconds) AS avg_execution_duration,
    avg(databricks_job_cost.setup_duration_seconds) AS avg_setup_duration,
    sum(
        CASE
            WHEN ((databricks_job_cost.result_state)::text = 'SUCCESS'::text) THEN 1
            ELSE 0
        END) AS success_count,
    sum(
        CASE
            WHEN ((databricks_job_cost.result_state)::text = 'FAILED'::text) THEN 1
            ELSE 0
        END) AS failed_count,
    sum(
        CASE
            WHEN ((databricks_job_cost.result_state)::text = 'CANCELLED'::text) THEN 1
            ELSE 0
        END) AS cancelled_count,
    databricks_job_cost.tenant_id,
    databricks_job_cost.source_system
   FROM public.databricks_job_cost
  WHERE ((date(databricks_job_cost.period_start_time) = ( SELECT max(date(databricks_job_cost_1.period_start_time)) AS max
           FROM public.databricks_job_cost databricks_job_cost_1
          WHERE (date(databricks_job_cost_1.period_start_time) < ( SELECT max(date(databricks_job_cost_2.period_start_time)) AS max
                   FROM public.databricks_job_cost databricks_job_cost_2)))) AND (databricks_job_cost.job_cost > (0)::numeric))
  GROUP BY databricks_job_cost.account_id, databricks_job_cost.workspace_id, databricks_job_cost.workspace_name, databricks_job_cost.job_id, databricks_job_cost.name, databricks_job_cost.compute_id, databricks_job_cost.run_as, databricks_job_cost.run_as_user_name, databricks_job_cost.tags, databricks_job_cost.tenant_id, databricks_job_cost.source_system
  ORDER BY (sum(databricks_job_cost.job_cost)) DESC;


ALTER TABLE public.databricks_job_cost_previous OWNER TO postgres;

--
-- Name: databricks_job_cost_comparison; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_job_cost_comparison AS
 SELECT COALESCE(curr.account_id, prev.account_id) AS account_id,
    COALESCE(curr.workspace_id, prev.workspace_id) AS workspace_id,
    COALESCE(curr.workspace_name, prev.workspace_name) AS workspace_name,
    COALESCE(curr.job_id, prev.job_id) AS job_id,
    COALESCE(curr.job_name, prev.job_name) AS job_name,
    COALESCE(curr.compute_id, prev.compute_id) AS compute_id,
    COALESCE(curr.run_as, prev.run_as) AS run_as,
    COALESCE(curr.run_as_user_name, prev.run_as_user_name) AS run_as_user_name,
    COALESCE(curr.tags, prev.tags) AS tags,
    COALESCE(prev.previous_day_job_cost, (0)::numeric) AS previous_day_job_cost,
    COALESCE(prev.previous_day_job_duration, (0)::numeric) AS previous_day_job_duration,
    COALESCE(prev.previous_day_run_count, (0)::bigint) AS previous_day_run_count,
    COALESCE(prev.avg_execution_duration, (0)::numeric) AS prev_avg_execution_duration,
    COALESCE(prev.success_count, (0)::bigint) AS prev_success_count,
    COALESCE(prev.failed_count, (0)::bigint) AS prev_failed_count,
    COALESCE(prev.cancelled_count, (0)::bigint) AS prev_cancelled_count,
    COALESCE(curr.current_day_job_cost, (0)::numeric) AS current_day_job_cost,
    COALESCE(curr.current_day_job_duration, (0)::numeric) AS current_day_job_duration,
    COALESCE(curr.current_day_run_count, (0)::bigint) AS current_day_run_count,
    COALESCE(curr.avg_execution_duration, (0)::numeric) AS curr_avg_execution_duration,
    COALESCE(curr.success_count, (0)::bigint) AS curr_success_count,
    COALESCE(curr.failed_count, (0)::bigint) AS curr_failed_count,
    COALESCE(curr.cancelled_count, (0)::bigint) AS curr_cancelled_count,
    (curr.current_day_job_cost - prev.previous_day_job_cost) AS cost_difference,
    (((curr.current_day_job_cost - prev.previous_day_job_cost) / NULLIF(prev.previous_day_job_cost, (0)::numeric)) * (100)::numeric) AS cost_percentage,
    (curr.current_day_run_count - prev.previous_day_run_count) AS run_count_difference,
    (curr.current_day_job_duration - prev.previous_day_job_duration) AS duration_difference,
    prev.tenant_id,
    prev.source_system
   FROM (public.databricks_job_cost_previous prev
     JOIN public.databricks_job_cost_current curr ON ((((prev.job_id)::text = (curr.job_id)::text) AND ((prev.workspace_id)::text = (curr.workspace_id)::text) AND ((prev.tenant_id)::text = (curr.tenant_id)::text) AND ((prev.account_id)::text = (curr.account_id)::text))))
  ORDER BY (curr.current_day_job_cost - prev.previous_day_job_cost) DESC;


ALTER TABLE public.databricks_job_cost_comparison OWNER TO postgres;

--
-- Name: databricks_job_recommendation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_job_recommendation (
    workspace_id character varying(255),
    workspace_name character varying(500),
    job_id character varying(255),
    job_name character varying(500),
    cluster_id character varying(255),
    p90_cpu_utilization numeric(18,6),
    p90_mem_swap_percent numeric(18,6),
    p90_disk_free_bytes numeric(18,2),
    p90_cpu_wait_percent numeric(18,6),
    p90_mem_used_percent numeric(18,6),
    cluster_name character varying(500),
    driver_node_type character varying(100),
    recommendations text,
    etl_load_timestamp timestamp without time zone,
    source_system character varying(50),
    potential_saving numeric,
    run_id character varying,
    period_start_time timestamp without time zone,
    period_end_time timestamp without time zone,
    account_id character varying
);


ALTER TABLE public.databricks_job_recommendation OWNER TO postgres;

--
-- Name: databricks_query_cost; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_query_cost (
    workspace_id character varying(255),
    workspace_name character varying(500),
    query_source_type character varying(50),
    dashboard_id character varying(255),
    executed_by character varying(255),
    statement_id character varying(255),
    warehouse_id character varying(255),
    warehouse_name character varying(500),
    warehouse_type character varying(50),
    statement_text text,
    queryruntimeseconds numeric(18,6),
    cputotalexecutiontime numeric(18,6),
    executionquerytime numeric(18,6),
    compilationquerytime numeric(18,6),
    queuequerytime numeric(18,6),
    computestartuptime numeric(18,6),
    totalresourcetimeusedforallocation numeric(18,6),
    total_warehouse_period_dollars numeric(18,6),
    proportionofwarehousetimeusedbyquery numeric(18,10),
    allocatedquerycostbytime numeric(18,6),
    etl_load_timestamp timestamp without time zone,
    source_system character varying(50),
    account_id character varying(255),
    start_time timestamp without time zone,
    total_query_cost numeric(18,6),
    tenant_id character varying(255),
    recommendation text
);


ALTER TABLE public.databricks_query_cost OWNER TO postgres;

--
-- Name: databricks_query_cost_current; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_query_cost_current AS
 SELECT databricks_query_cost.account_id,
    databricks_query_cost.workspace_id,
    databricks_query_cost.workspace_name,
    databricks_query_cost.warehouse_id,
    databricks_query_cost.warehouse_name,
    databricks_query_cost.warehouse_type,
    databricks_query_cost.executed_by,
    databricks_query_cost.query_source_type,
    count(DISTINCT databricks_query_cost.statement_id) AS query_count,
    sum(databricks_query_cost.total_query_cost) AS current_day_query_cost,
    sum(databricks_query_cost.queryruntimeseconds) AS total_runtime_seconds,
    sum(databricks_query_cost.executionquerytime) AS total_execution_time,
    sum(databricks_query_cost.compilationquerytime) AS total_compilation_time,
    sum(databricks_query_cost.queuequerytime) AS total_queue_time,
    avg(databricks_query_cost.queryruntimeseconds) AS avg_query_runtime,
    avg(databricks_query_cost.executionquerytime) AS avg_execution_time,
    avg(databricks_query_cost.queuequerytime) AS avg_queue_time,
    max(databricks_query_cost.queryruntimeseconds) AS max_query_runtime,
    avg(databricks_query_cost.allocatedquerycostbytime) AS avg_query_cost,
    max(databricks_query_cost.allocatedquerycostbytime) AS max_query_cost,
    databricks_query_cost.tenant_id,
    databricks_query_cost.source_system
   FROM public.databricks_query_cost
  WHERE ((date(databricks_query_cost.start_time) = ( SELECT max(date(databricks_query_cost_1.start_time)) AS max
           FROM public.databricks_query_cost databricks_query_cost_1)) AND (databricks_query_cost.total_query_cost > (0)::numeric))
  GROUP BY databricks_query_cost.account_id, databricks_query_cost.workspace_id, databricks_query_cost.workspace_name, databricks_query_cost.warehouse_id, databricks_query_cost.warehouse_name, databricks_query_cost.warehouse_type, databricks_query_cost.executed_by, databricks_query_cost.query_source_type, databricks_query_cost.tenant_id, databricks_query_cost.source_system
  ORDER BY (sum(databricks_query_cost.total_query_cost)) DESC;


ALTER TABLE public.databricks_query_cost_current OWNER TO postgres;

--
-- Name: databricks_query_cost_previous; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_query_cost_previous AS
 SELECT databricks_query_cost.account_id,
    databricks_query_cost.workspace_id,
    databricks_query_cost.workspace_name,
    databricks_query_cost.warehouse_id,
    databricks_query_cost.warehouse_name,
    databricks_query_cost.warehouse_type,
    databricks_query_cost.executed_by,
    databricks_query_cost.query_source_type,
    count(DISTINCT databricks_query_cost.statement_id) AS query_count,
    sum(databricks_query_cost.total_query_cost) AS previous_day_query_cost,
    sum(databricks_query_cost.queryruntimeseconds) AS total_runtime_seconds,
    sum(databricks_query_cost.executionquerytime) AS total_execution_time,
    sum(databricks_query_cost.compilationquerytime) AS total_compilation_time,
    sum(databricks_query_cost.queuequerytime) AS total_queue_time,
    avg(databricks_query_cost.queryruntimeseconds) AS avg_query_runtime,
    avg(databricks_query_cost.executionquerytime) AS avg_execution_time,
    avg(databricks_query_cost.queuequerytime) AS avg_queue_time,
    max(databricks_query_cost.queryruntimeseconds) AS max_query_runtime,
    avg(databricks_query_cost.allocatedquerycostbytime) AS avg_query_cost,
    max(databricks_query_cost.allocatedquerycostbytime) AS max_query_cost,
    databricks_query_cost.tenant_id,
    databricks_query_cost.source_system
   FROM public.databricks_query_cost
  WHERE ((date(databricks_query_cost.start_time) = ( SELECT max(date(databricks_query_cost_1.start_time)) AS max
           FROM public.databricks_query_cost databricks_query_cost_1
          WHERE (date(databricks_query_cost_1.start_time) < ( SELECT max(date(databricks_query_cost_2.start_time)) AS max
                   FROM public.databricks_query_cost databricks_query_cost_2)))) AND (databricks_query_cost.total_query_cost > (0)::numeric))
  GROUP BY databricks_query_cost.account_id, databricks_query_cost.workspace_id, databricks_query_cost.workspace_name, databricks_query_cost.warehouse_id, databricks_query_cost.warehouse_name, databricks_query_cost.warehouse_type, databricks_query_cost.executed_by, databricks_query_cost.query_source_type, databricks_query_cost.tenant_id, databricks_query_cost.source_system
  ORDER BY (sum(databricks_query_cost.total_query_cost)) DESC;


ALTER TABLE public.databricks_query_cost_previous OWNER TO postgres;

--
-- Name: databricks_query_cost_comparison; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_query_cost_comparison AS
 SELECT prev.account_id,
    prev.workspace_id,
    prev.workspace_name,
    prev.warehouse_id,
    prev.warehouse_name,
    prev.warehouse_type,
    prev.executed_by,
    prev.query_source_type,
    prev.query_count AS prev_query_count,
    prev.previous_day_query_cost,
    prev.avg_query_runtime AS prev_avg_runtime,
    prev.avg_queue_time AS prev_avg_queue_time,
    prev.avg_query_cost AS prev_avg_query_cost,
    curr.query_count AS curr_query_count,
    curr.current_day_query_cost,
    curr.avg_query_runtime AS curr_avg_runtime,
    curr.avg_queue_time AS curr_avg_queue_time,
    curr.avg_query_cost AS curr_avg_query_cost,
    (curr.current_day_query_cost - prev.previous_day_query_cost) AS cost_difference,
    (((curr.current_day_query_cost - prev.previous_day_query_cost) / NULLIF(prev.previous_day_query_cost, (0)::numeric)) * (100)::numeric) AS cost_percentage,
    (curr.query_count - prev.query_count) AS query_count_difference,
    (curr.avg_query_runtime - prev.avg_query_runtime) AS avg_runtime_difference,
    (curr.avg_queue_time - prev.avg_queue_time) AS avg_queue_time_difference,
    prev.tenant_id,
    prev.source_system
   FROM (public.databricks_query_cost_previous prev
     JOIN public.databricks_query_cost_current curr ON ((((prev.warehouse_id)::text = (curr.warehouse_id)::text) AND ((prev.workspace_id)::text = (curr.workspace_id)::text) AND ((prev.executed_by)::text = (curr.executed_by)::text) AND ((prev.query_source_type)::text = (curr.query_source_type)::text) AND ((prev.tenant_id)::text = (curr.tenant_id)::text) AND ((prev.account_id)::text = (curr.account_id)::text))))
  ORDER BY (curr.current_day_query_cost - prev.previous_day_query_cost) DESC;


ALTER TABLE public.databricks_query_cost_comparison OWNER TO postgres;

--
-- Name: databricks_query_issues; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_query_issues AS
 WITH raw_lines AS (
         SELECT databricks_generated_optimized_queries.query_id,
            regexp_split_to_table(databricks_generated_optimized_queries.query_issues, '\n'::text) AS raw_line
           FROM public.databricks_generated_optimized_queries
        ), tagged_lines AS (
         SELECT sub.query_id,
                CASE
                    WHEN (sub.raw_line ~~ '-%'::text) THEN regexp_replace(sub.raw_line, '^-\\s*'::text, ''::text)
                    ELSE NULL::text
                END AS new_issue,
                CASE
                    WHEN (sub.raw_line !~~ '-%'::text) THEN sub.raw_line
                    ELSE NULL::text
                END AS continuation,
            row_number() OVER (PARTITION BY sub.query_id ORDER BY sub.ordinal) AS line_num
           FROM ( SELECT raw_lines.query_id,
                    raw_lines.raw_line,
                    row_number() OVER (PARTITION BY raw_lines.query_id ORDER BY raw_lines.query_id) AS ordinal
                   FROM raw_lines) sub
        ), issue_blocks AS (
         SELECT tagged_lines.query_id,
            COALESCE(tagged_lines.new_issue, lag(tagged_lines.new_issue) OVER (PARTITION BY tagged_lines.query_id ORDER BY tagged_lines.line_num)) AS issue_id,
            COALESCE(tagged_lines.new_issue, tagged_lines.continuation) AS line
           FROM tagged_lines
        ), grouped_issues AS (
         SELECT issue_blocks.query_id,
            issue_blocks.issue_id AS problem,
                CASE
                    WHEN (issue_blocks.issue_id ~~* '%join%'::text) THEN 'Join Issues'::text
                    WHEN (issue_blocks.issue_id ~~* '%filter%'::text) THEN 'Filtering Issues'::text
                    WHEN ((issue_blocks.issue_id ~~* '%aggregation%'::text) OR (issue_blocks.issue_id ~~* '%group by%'::text)) THEN 'Aggregation Issues'::text
                    WHEN (issue_blocks.issue_id ~~* '%cte%'::text) THEN 'CTE/Materialization'::text
                    WHEN (issue_blocks.issue_id ~~* '%union%'::text) THEN 'Union/Repeated Logic'::text
                    WHEN ((issue_blocks.issue_id ~~* '%cast%'::text) OR (issue_blocks.issue_id ~~* '%expression%'::text)) THEN 'Expression/Computation'::text
                    WHEN ((issue_blocks.issue_id ~~* '%sort key%'::text) OR (issue_blocks.issue_id ~~* '%distribution key%'::text)) THEN 'Physical Design'::text
                    WHEN (issue_blocks.issue_id ~~* '%encoding%'::text) THEN 'Storage Optimization'::text
                    WHEN (issue_blocks.issue_id ~~* '%partition%'::text) THEN 'Partitioning'::text
                    WHEN (issue_blocks.issue_id ~~* '%null%'::text) THEN 'Data Quality'::text
                    WHEN (issue_blocks.issue_id ~~* '%select%'::text) THEN 'Column Selection'::text
                    ELSE 'Other'::text
                END AS category
           FROM issue_blocks
          WHERE (issue_blocks.issue_id IS NOT NULL)
        )
 SELECT grouped_issues.query_id,
    grouped_issues.problem,
    grouped_issues.category
   FROM grouped_issues
  ORDER BY grouped_issues.query_id, grouped_issues.category;


ALTER TABLE public.databricks_query_issues OWNER TO postgres;

--
-- Name: databricks_query_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_query_metadata (
    query_id character varying(255),
    final_state character varying(50),
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    total_duration bigint,
    database_name character varying(100),
    query_text text NOT NULL,
    user_id character varying(50),
    query_type character varying(50),
    statement_text text NOT NULL,
    query_execution_time bigint,
    compilation_duration_ms bigint,
    query_cpu_time bigint,
    result_fetch_duration_ms bigint,
    update_time timestamp without time zone,
    read_partitions bigint,
    pruned_files bigint,
    read_files bigint,
    scanned_rows bigint,
    produced_rows bigint,
    query_blocks_read bigint,
    read_io_cache_percent numeric(5,2),
    written_bytes bigint,
    written_rows bigint,
    written_files bigint,
    catalog_name character varying(100),
    table_name character varying(100),
    scanned_table_id character varying(100),
    table_size bigint,
    table_rows numeric(38,0),
    query_cpu_usage_percent numeric(5,2),
    plan_node text,
    info text
);


ALTER TABLE public.databricks_query_metadata OWNER TO postgres;

--
-- Name: databricks_query_optimization_recommendations; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_query_optimization_recommendations AS
 WITH raw_lines AS (
         SELECT databricks_generated_optimized_queries.query_id,
            regexp_split_to_table(databricks_generated_optimized_queries.optimizations_recommendations, '\n'::text) AS raw_line
           FROM public.databricks_generated_optimized_queries
        ), normalized_recs AS (
         SELECT raw_lines.query_id,
            TRIM(BOTH FROM
                CASE
                    WHEN (raw_lines.raw_line ~~ '-%'::text) THEN regexp_replace(raw_lines.raw_line, '^-\\s*'::text, ''::text)
                    ELSE raw_lines.raw_line
                END) AS recommendation
           FROM raw_lines
          WHERE ((length(raw_lines.raw_line) - length(replace(raw_lines.raw_line, '|'::text, ''::text))) < 3)
        ), deduplicated AS (
         SELECT DISTINCT normalized_recs.query_id,
            normalized_recs.recommendation
           FROM normalized_recs
          WHERE ((normalized_recs.recommendation IS NOT NULL) AND (normalized_recs.recommendation <> ''::text))
        ), categorized AS (
         SELECT deduplicated.query_id,
            deduplicated.recommendation,
                CASE
                    WHEN (deduplicated.recommendation ~~* '%column-level storage optimization recommendations%'::text) THEN 'Column-level Storage Optimization'::text
                    WHEN (deduplicated.recommendation ~~* '%recommend column encodings%'::text) THEN 'Column-level Storage Optimization'::text
                    WHEN (deduplicated.recommendation ~~* '%explicitly list only needed columns%'::text) THEN 'Column Selection'::text
                    WHEN (deduplicated.recommendation ~~* '%use distkey%'::text) THEN 'Distribution/Clustering/Sort Keys'::text
                    WHEN (deduplicated.recommendation ~~* '%use sortkey%'::text) THEN 'Distribution/Clustering/Sort Keys'::text
                    WHEN (deduplicated.recommendation ~~* '%partition tables%'::text) THEN 'Distribution/Clustering/Sort Keys'::text
                    WHEN (deduplicated.recommendation ~~* '%use inner joins%'::text) THEN 'Query Structure'::text
                    WHEN (deduplicated.recommendation ~~* '%filter%'::text) THEN 'Query Structure'::text
                    WHEN (deduplicated.recommendation ~~* '%aggregate%'::text) THEN 'Query Structure'::text
                    WHEN (deduplicated.recommendation ~~* '%cte%'::text) THEN 'Query Structure'::text
                    WHEN (deduplicated.recommendation ~~* '%subquery%'::text) THEN 'Query Structure'::text
                    ELSE 'Other'::text
                END AS category
           FROM deduplicated
        )
 SELECT categorized.query_id,
    categorized.recommendation,
    categorized.category
   FROM categorized
  ORDER BY categorized.query_id, categorized.category;


ALTER TABLE public.databricks_query_optimization_recommendations OWNER TO postgres;

--
-- Name: databricks_warehouse_usage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_warehouse_usage (
    warehouse_id character varying(255),
    warehouse_name character varying(500),
    workspace_id character varying(255),
    workspace_name character varying(500),
    key_value_tags text,
    usage_date date,
    warehouse_type character varying(50),
    price_per_unit numeric(18,6),
    sku_name character varying(255),
    dbus numeric(18,6),
    day_dollars numeric(18,6),
    etl_load_timestamp timestamp without time zone,
    source_system character varying(50),
    account_id character varying(255),
    total_dollars numeric(18,6),
    tenant_id character varying(255)
);


ALTER TABLE public.databricks_warehouse_usage OWNER TO postgres;

--
-- Name: databricks_query_warehouse_current; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_query_warehouse_current AS
 SELECT dqc.workspace_name,
    dqc.workspace_id,
    dqc.warehouse_id,
    dqc.warehouse_name,
    dwu.warehouse_type,
    dwu.sku_name,
    dqc.query_source_type,
    dqc.dashboard_id,
    dqc.executed_by,
    dqc.statement_id,
    dqc.queryruntimeseconds AS current_query_runtime,
    dqc.queuequerytime AS current_queue_time,
    dqc.compilationquerytime AS current_compilation_time,
    dqc.executionquerytime AS current_execution_time,
    dqc.total_query_cost AS current_query_cost,
    dwu.total_dollars AS current_warehouse_cost,
    dwu.dbus AS current_dbus,
    dqc.recommendation,
    dqc.statement_text,
    dqc.account_id,
    dqc.tenant_id,
    date(dqc.start_time) AS query_date
   FROM (public.databricks_query_cost dqc
     JOIN public.databricks_warehouse_usage dwu ON ((((dqc.warehouse_id)::text = (dwu.warehouse_id)::text) AND (date(dqc.start_time) = dwu.usage_date))))
  WHERE ((date(dqc.start_time) = ( SELECT max(date(databricks_query_cost.start_time)) AS max
           FROM public.databricks_query_cost)) AND (dqc.total_query_cost > (0)::numeric));


ALTER TABLE public.databricks_query_warehouse_current OWNER TO postgres;

--
-- Name: databricks_query_warehouse_previous; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_query_warehouse_previous AS
 SELECT dqc.workspace_name,
    dqc.workspace_id,
    dqc.warehouse_id,
    dqc.warehouse_name,
    dwu.warehouse_type,
    dwu.sku_name,
    dqc.query_source_type,
    dqc.dashboard_id,
    dqc.executed_by,
    dqc.statement_id,
    dqc.queryruntimeseconds AS previous_query_runtime,
    dqc.queuequerytime AS previous_queue_time,
    dqc.compilationquerytime AS previous_compilation_time,
    dqc.executionquerytime AS previous_execution_time,
    dqc.total_query_cost AS previous_query_cost,
    dwu.total_dollars AS previous_warehouse_cost,
    dwu.dbus AS previous_dbus,
    dqc.recommendation,
    dqc.account_id,
    dqc.tenant_id,
    date(dqc.start_time) AS query_date
   FROM (public.databricks_query_cost dqc
     JOIN public.databricks_warehouse_usage dwu ON ((((dqc.warehouse_id)::text = (dwu.warehouse_id)::text) AND (date(dqc.start_time) = dwu.usage_date))))
  WHERE ((date(dqc.start_time) = ( SELECT max(date(databricks_query_cost.start_time)) AS max
           FROM public.databricks_query_cost
          WHERE (date(databricks_query_cost.start_time) < ( SELECT max(date(databricks_query_cost_1.start_time)) AS max
                   FROM public.databricks_query_cost databricks_query_cost_1)))) AND (dqc.total_query_cost > (0)::numeric));


ALTER TABLE public.databricks_query_warehouse_previous OWNER TO postgres;

--
-- Name: databricks_query_warehouse_comparison; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_query_warehouse_comparison AS
 SELECT COALESCE(curr.workspace_name, prev.workspace_name) AS workspace_name,
    COALESCE(curr.workspace_id, prev.workspace_id) AS workspace_id,
    COALESCE(curr.warehouse_id, prev.warehouse_id) AS warehouse_id,
    COALESCE(curr.warehouse_name, prev.warehouse_name) AS warehouse_name,
    COALESCE(curr.warehouse_type, prev.warehouse_type) AS warehouse_type,
    COALESCE(curr.sku_name, prev.sku_name) AS sku_name,
    COALESCE(curr.query_source_type, prev.query_source_type) AS query_source_type,
    COALESCE(curr.executed_by, prev.executed_by) AS executed_by,
    COALESCE(curr.current_query_cost, (0)::numeric) AS current_query_cost,
    COALESCE(curr.current_warehouse_cost, (0)::numeric) AS current_warehouse_cost,
    COALESCE(curr.current_query_runtime, (0)::numeric) AS current_query_runtime,
    COALESCE(curr.current_queue_time, (0)::numeric) AS current_queue_time,
    COALESCE(curr.current_dbus, (0)::numeric) AS current_dbus,
    COALESCE(prev.previous_query_cost, (0)::numeric) AS previous_query_cost,
    COALESCE(prev.previous_warehouse_cost, (0)::numeric) AS previous_warehouse_cost,
    COALESCE(prev.previous_query_runtime, (0)::numeric) AS previous_query_runtime,
    COALESCE(prev.previous_queue_time, (0)::numeric) AS previous_queue_time,
    COALESCE(prev.previous_dbus, (0)::numeric) AS previous_dbus,
    (COALESCE(curr.current_query_cost, (0)::numeric) - COALESCE(prev.previous_query_cost, (0)::numeric)) AS query_cost_difference,
    (COALESCE(curr.current_warehouse_cost, (0)::numeric) - COALESCE(prev.previous_warehouse_cost, (0)::numeric)) AS warehouse_cost_difference,
    (COALESCE(curr.current_query_runtime, (0)::numeric) - COALESCE(prev.previous_query_runtime, (0)::numeric)) AS runtime_difference,
    (COALESCE(curr.current_queue_time, (0)::numeric) - COALESCE(prev.previous_queue_time, (0)::numeric)) AS queue_time_difference,
        CASE
            WHEN (COALESCE(prev.previous_query_cost, (0)::numeric) > (0)::numeric) THEN (((COALESCE(curr.current_query_cost, (0)::numeric) - COALESCE(prev.previous_query_cost, (0)::numeric)) / prev.previous_query_cost) * (100)::numeric)
            ELSE NULL::numeric
        END AS query_cost_percentage_change,
        CASE
            WHEN (COALESCE(prev.previous_query_runtime, (0)::numeric) > (0)::numeric) THEN (((COALESCE(curr.current_query_runtime, (0)::numeric) - COALESCE(prev.previous_query_runtime, (0)::numeric)) / prev.previous_query_runtime) * (100)::numeric)
            ELSE NULL::numeric
        END AS runtime_percentage_change,
    curr.recommendation,
    COALESCE(curr.account_id, prev.account_id) AS account_id,
    COALESCE(curr.tenant_id, prev.tenant_id) AS tenant_id
   FROM (public.databricks_query_warehouse_current curr
     FULL JOIN public.databricks_query_warehouse_previous prev ON ((((curr.warehouse_id)::text = (prev.warehouse_id)::text) AND ((curr.executed_by)::text = (prev.executed_by)::text) AND ((curr.query_source_type)::text = (prev.query_source_type)::text))))
  WHERE (((COALESCE(curr.current_query_cost, (0)::numeric) - COALESCE(prev.previous_query_cost, (0)::numeric)) <> (0)::numeric) OR ((COALESCE(curr.current_query_runtime, (0)::numeric) - COALESCE(prev.previous_query_runtime, (0)::numeric)) <> (0)::numeric))
  ORDER BY (abs((COALESCE(curr.current_query_cost, (0)::numeric) - COALESCE(prev.previous_query_cost, (0)::numeric)))) DESC;


ALTER TABLE public.databricks_query_warehouse_comparison OWNER TO postgres;

--
-- Name: databricks_table_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databricks_table_metadata (
    table_id character varying(50),
    table_name text NOT NULL,
    table_ddl text
);


ALTER TABLE public.databricks_table_metadata OWNER TO postgres;

--
-- Name: databricks_warehouse_cost_current; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_warehouse_cost_current AS
 SELECT databricks_warehouse_usage.account_id,
    databricks_warehouse_usage.warehouse_id,
    databricks_warehouse_usage.warehouse_name,
    databricks_warehouse_usage.workspace_id,
    databricks_warehouse_usage.workspace_name,
    databricks_warehouse_usage.warehouse_type,
    databricks_warehouse_usage.sku_name,
    databricks_warehouse_usage.key_value_tags AS tags,
    sum(databricks_warehouse_usage.day_dollars) AS current_day_cost,
    sum(databricks_warehouse_usage.dbus) AS current_day_dbus,
    avg(databricks_warehouse_usage.price_per_unit) AS avg_price_per_unit,
    databricks_warehouse_usage.tenant_id,
    databricks_warehouse_usage.source_system
   FROM public.databricks_warehouse_usage
  WHERE ((databricks_warehouse_usage.usage_date = ( SELECT max(databricks_warehouse_usage_1.usage_date) AS max
           FROM public.databricks_warehouse_usage databricks_warehouse_usage_1)) AND (databricks_warehouse_usage.day_dollars > (0)::numeric))
  GROUP BY databricks_warehouse_usage.account_id, databricks_warehouse_usage.warehouse_id, databricks_warehouse_usage.warehouse_name, databricks_warehouse_usage.workspace_id, databricks_warehouse_usage.workspace_name, databricks_warehouse_usage.warehouse_type, databricks_warehouse_usage.sku_name, databricks_warehouse_usage.key_value_tags, databricks_warehouse_usage.tenant_id, databricks_warehouse_usage.source_system
  ORDER BY (sum(databricks_warehouse_usage.day_dollars)) DESC;


ALTER TABLE public.databricks_warehouse_cost_current OWNER TO postgres;

--
-- Name: databricks_unified_cost_current; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_unified_cost_current AS
 SELECT 'CLUSTER'::text AS resource_type,
    databricks_cluster_cost_current.account_id,
    databricks_cluster_cost_current.workspace_id,
    databricks_cluster_cost_current.workspace_name,
    databricks_cluster_cost_current.cluster_id AS resource_id,
    databricks_cluster_cost_current.cluster_name AS resource_name,
    databricks_cluster_cost_current.owned_by AS owner,
    databricks_cluster_cost_current.sku_name,
    databricks_cluster_cost_current.current_day_total_cost AS current_day_cost,
    databricks_cluster_cost_current.current_day_usage_quantity AS usage_metric,
    databricks_cluster_cost_current.tenant_id
   FROM public.databricks_cluster_cost_current
UNION ALL
 SELECT 'JOB'::text AS resource_type,
    databricks_job_cost_current.account_id,
    databricks_job_cost_current.workspace_id,
    databricks_job_cost_current.workspace_name,
    databricks_job_cost_current.job_id AS resource_id,
    databricks_job_cost_current.job_name AS resource_name,
    databricks_job_cost_current.run_as_user_name AS owner,
    'JOB_COMPUTE'::character varying AS sku_name,
    databricks_job_cost_current.current_day_job_cost AS current_day_cost,
    databricks_job_cost_current.current_day_run_count AS usage_metric,
    databricks_job_cost_current.tenant_id
   FROM public.databricks_job_cost_current
UNION ALL
 SELECT 'WAREHOUSE'::text AS resource_type,
    databricks_warehouse_cost_current.account_id,
    databricks_warehouse_cost_current.workspace_id,
    databricks_warehouse_cost_current.workspace_name,
    databricks_warehouse_cost_current.warehouse_id AS resource_id,
    databricks_warehouse_cost_current.warehouse_name AS resource_name,
    NULL::character varying AS owner,
    databricks_warehouse_cost_current.sku_name,
    databricks_warehouse_cost_current.current_day_cost,
    databricks_warehouse_cost_current.current_day_dbus AS usage_metric,
    databricks_warehouse_cost_current.tenant_id
   FROM public.databricks_warehouse_cost_current
  ORDER BY 9 DESC;


ALTER TABLE public.databricks_unified_cost_current OWNER TO postgres;

--
-- Name: databricks_warehouse_cost_previous; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_warehouse_cost_previous AS
 SELECT databricks_warehouse_usage.account_id,
    databricks_warehouse_usage.warehouse_id,
    databricks_warehouse_usage.warehouse_name,
    databricks_warehouse_usage.workspace_id,
    databricks_warehouse_usage.workspace_name,
    databricks_warehouse_usage.warehouse_type,
    databricks_warehouse_usage.sku_name,
    databricks_warehouse_usage.key_value_tags AS tags,
    sum(databricks_warehouse_usage.day_dollars) AS previous_day_cost,
    sum(databricks_warehouse_usage.dbus) AS previous_day_dbus,
    avg(databricks_warehouse_usage.price_per_unit) AS avg_price_per_unit,
    databricks_warehouse_usage.tenant_id,
    databricks_warehouse_usage.source_system
   FROM public.databricks_warehouse_usage
  WHERE ((databricks_warehouse_usage.usage_date = ( SELECT max(databricks_warehouse_usage_1.usage_date) AS max
           FROM public.databricks_warehouse_usage databricks_warehouse_usage_1
          WHERE (databricks_warehouse_usage_1.usage_date < ( SELECT max(databricks_warehouse_usage_2.usage_date) AS max
                   FROM public.databricks_warehouse_usage databricks_warehouse_usage_2)))) AND (databricks_warehouse_usage.day_dollars > (0)::numeric))
  GROUP BY databricks_warehouse_usage.account_id, databricks_warehouse_usage.warehouse_id, databricks_warehouse_usage.warehouse_name, databricks_warehouse_usage.workspace_id, databricks_warehouse_usage.workspace_name, databricks_warehouse_usage.warehouse_type, databricks_warehouse_usage.sku_name, databricks_warehouse_usage.key_value_tags, databricks_warehouse_usage.tenant_id, databricks_warehouse_usage.source_system
  ORDER BY (sum(databricks_warehouse_usage.day_dollars)) DESC;


ALTER TABLE public.databricks_warehouse_cost_previous OWNER TO postgres;

--
-- Name: databricks_warehouse_cost_comparison; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.databricks_warehouse_cost_comparison AS
 SELECT prev.account_id,
    prev.warehouse_id,
    prev.warehouse_name,
    prev.workspace_id,
    prev.workspace_name,
    prev.warehouse_type,
    prev.sku_name,
    prev.tags,
    prev.previous_day_cost,
    prev.previous_day_dbus,
    prev.avg_price_per_unit AS prev_avg_price_per_unit,
    curr.current_day_cost,
    curr.current_day_dbus,
    curr.avg_price_per_unit AS curr_avg_price_per_unit,
    (curr.current_day_cost - prev.previous_day_cost) AS cost_difference,
    (((curr.current_day_cost - prev.previous_day_cost) / NULLIF(prev.previous_day_cost, (0)::numeric)) * (100)::numeric) AS cost_percentage,
    (curr.current_day_dbus - prev.previous_day_dbus) AS dbus_difference,
    prev.tenant_id,
    prev.source_system
   FROM (public.databricks_warehouse_cost_previous prev
     JOIN public.databricks_warehouse_cost_current curr ON ((((prev.warehouse_id)::text = (curr.warehouse_id)::text) AND ((prev.workspace_id)::text = (curr.workspace_id)::text) AND ((prev.tenant_id)::text = (curr.tenant_id)::text) AND ((prev.account_id)::text = (curr.account_id)::text))))
  ORDER BY (curr.current_day_cost - prev.previous_day_cost) DESC;


ALTER TABLE public.databricks_warehouse_cost_comparison OWNER TO postgres;

--
-- Name: email_verification_tokens; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.email_verification_tokens (
    id uuid NOT NULL,
    tenant_id character varying(120) NOT NULL,
    user_id uuid NOT NULL,
    token character varying(128) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used boolean NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.email_verification_tokens OWNER TO "prism-web";

--
-- Name: environment_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.environment_details (
    id integer NOT NULL,
    db_type character varying(50),
    priority character varying(2),
    env_detail text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.environment_details OWNER TO postgres;

--
-- Name: environment_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.environment_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.environment_details_id_seq OWNER TO postgres;

--
-- Name: environment_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.environment_details_id_seq OWNED BY public.environment_details.id;


--
-- Name: eqa_jira_attachments; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.eqa_jira_attachments (
    id integer NOT NULL,
    execution_id character varying(36) NOT NULL,
    issue_key character varying(50) NOT NULL,
    attachment_id character varying(50),
    filename character varying(255) NOT NULL,
    content_type character varying(100),
    size integer,
    extracted_content text,
    extracted_type character varying(50),
    extract_error text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.eqa_jira_attachments OWNER TO "prism-web";

--
-- Name: eqa_jira_generated_stories; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.eqa_jira_generated_stories (
    id integer NOT NULL,
    execution_id character varying(36) NOT NULL,
    issue_key character varying(50) NOT NULL,
    title text,
    executive_summary text,
    context_background text,
    user_story text,
    business_goal_kpis text,
    functional_requirements text,
    acceptance_criteria text,
    non_functional_requirements text,
    ui_ux_requirements text,
    assumptions text,
    risks_open_questions text,
    definition_of_ready text,
    definition_of_done text,
    test_notes text,
    technical_details text,
    traceability text,
    model_used character varying(100),
    prompt_tokens integer,
    completion_tokens integer,
    generated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    attachments json
);


ALTER TABLE public.eqa_jira_generated_stories OWNER TO "prism-web";

--
-- Name: eqa_jira_scrape_results; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.eqa_jira_scrape_results (
    id integer NOT NULL,
    execution_id character varying(36) NOT NULL,
    issue_key character varying(50) NOT NULL,
    status character varying(20) NOT NULL,
    scraped_data json,
    error_message text,
    scraped_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.eqa_jira_scrape_results OWNER TO "prism-web";

--
-- Name: eqa_story_analysis_results; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.eqa_story_analysis_results (
    id integer NOT NULL,
    execution_id character varying(255) NOT NULL,
    issue_key character varying(100) NOT NULL,
    story_record_id integer,
    status character varying(50) NOT NULL,
    can_proceed boolean NOT NULL,
    required_gaps_count integer,
    advisory_gaps_count integer,
    required_gaps json,
    advisory_gaps json,
    summary text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);


ALTER TABLE public.eqa_story_analysis_results OWNER TO "prism-web";

--
-- Name: eqa_test_cases; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.eqa_test_cases (
    id integer NOT NULL,
    execution_id character varying(255) NOT NULL,
    jira_id character varying(50) NOT NULL,
    tc_id character varying(100) NOT NULL,
    title character varying(255) NOT NULL,
    module character varying(255),
    test_data text,
    actual_result text,
    severity character varying(20),
    priority character varying(20),
    test_environment character varying(50),
    executed_by character varying(100),
    execution_date timestamp with time zone,
    comments text,
    type character varying(50) NOT NULL,
    test_type_detail character varying(50),
    preconditions json,
    test_steps text,
    expected_result text,
    expected_status_code integer,
    result character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.eqa_test_cases OWNER TO "prism-web";

--
-- Name: eqa_test_type_classifications; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.eqa_test_type_classifications (
    id integer NOT NULL,
    execution_id character varying(255) NOT NULL,
    jira_id character varying(50) NOT NULL,
    api_tests boolean NOT NULL,
    ui_tests boolean NOT NULL,
    security_tests boolean NOT NULL,
    performance_tests boolean NOT NULL,
    regression_tests boolean NOT NULL,
    integration_tests boolean NOT NULL,
    database_tests boolean NOT NULL,
    end_to_end_tests boolean NOT NULL,
    reasoning json,
    confidence_score double precision NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.eqa_test_type_classifications OWNER TO "prism-web";

--
-- Name: eqa_user_test_type_selections; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.eqa_user_test_type_selections (
    id integer NOT NULL,
    execution_id character varying(255) NOT NULL,
    jira_id character varying(50) NOT NULL,
    api_tests boolean NOT NULL,
    ui_tests boolean NOT NULL,
    security_tests boolean NOT NULL,
    performance_tests boolean NOT NULL,
    regression_tests boolean NOT NULL,
    integration_tests boolean NOT NULL,
    database_tests boolean NOT NULL,
    end_to_end_tests boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.eqa_user_test_type_selections OWNER TO "prism-web";

--
-- Name: focus_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.focus_metadata (
    id integer NOT NULL,
    column_number integer,
    field character varying(255) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.focus_metadata OWNER TO postgres;

--
-- Name: focus_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.focus_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.focus_metadata_id_seq OWNER TO postgres;

--
-- Name: focus_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.focus_metadata_id_seq OWNED BY public.focus_metadata.id;


--
-- Name: gen_ai_api_byod_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gen_ai_api_byod_data (
    batch_id bigint,
    username text,
    user_email text,
    job_id text,
    job_name text,
    created_by numeric(38,0),
    run_as_id numeric(38,0),
    tags text,
    account_id text,
    workspace_id character varying,
    cluster_type text,
    worker_count numeric(38,0),
    worker_node_type text,
    driver_node_type text,
    min_autoscale_workers numeric(18,6),
    max_autoscale_workers numeric(18,6),
    auto_termination_minutes numeric(18,6),
    cpu_user_percent numeric(18,6),
    cpu_system_percent numeric(18,6),
    cpu_wait_percent numeric(18,6),
    mem_used_percent numeric(18,6),
    mem_swap_percent numeric(18,6),
    disk_free_bytes_per_mount_point numeric(38,0),
    dbu_usage numeric(18,6),
    cloud text,
    currency_code text,
    pricing_default numeric(18,6),
    created_at timestamp with time zone DEFAULT now(),
    cluster_id character varying,
    dbr_version character varying,
    sku_name character varying,
    job_type character varying
);


ALTER TABLE public.gen_ai_api_byod_data OWNER TO postgres;

--
-- Name: gen_ai_api_byod_dbx_reccomendation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gen_ai_api_byod_dbx_reccomendation (
    account_id character varying,
    workspace_id character varying,
    job_id character varying,
    job_name character varying,
    sku_name character varying,
    category character varying,
    reason text,
    recommendation character varying,
    estimated_cost_savings numeric,
    estimated_savings_percent numeric,
    calculation_logic text,
    username character varying,
    user_email character varying,
    batch_id bigint,
    inserted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    total_cost numeric,
    cluster_id character varying,
    cluster_type character varying,
    cpu_user_percent_90percentile real,
    cpu_system_percent_90percentile real,
    cpu_wait_percent_90percentile real,
    memory_used_percent_90percentile real,
    memory_swap_percent_90percentile real,
    disk_free_bytes_per_mount_point_90percentile real,
    driver_node_type character varying,
    worker_node_type character varying,
    worker_count real,
    dbu_total_cost numeric(10,2),
    raw_llm_response text
);


ALTER TABLE public.gen_ai_api_byod_dbx_reccomendation OWNER TO postgres;

--
-- Name: genai_dbx_raw_preprocessed; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.genai_dbx_raw_preprocessed (
    cluster_id character varying(500),
    cluster_type character varying(500),
    worker_count character varying(500),
    worker_node_type character varying(500),
    driver_node_type character varying(500),
    dbr_version character varying(500),
    min_autoscale_workers character varying(500),
    max_autoscale_workers character varying(500),
    auto_termination_minutes character varying(500),
    usage_metadata_job_id character varying(500),
    cpu_user_90percentile double precision,
    cpu_system_90percentile double precision,
    mem_used_90percentile double precision,
    cpu_wait_90percentile double precision,
    avg_usage_quantity double precision,
    insert_timestamp timestamp with time zone
);


ALTER TABLE public.genai_dbx_raw_preprocessed OWNER TO postgres;

--
-- Name: genai_dbx_raw_preprocessed_aggregated; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.genai_dbx_raw_preprocessed_aggregated (
    job_id character varying NOT NULL,
    account_id character varying,
    workspace_id character varying,
    cluster_id character varying,
    cpu_user_percentile_90 real,
    cpu_system_percentile_90 real,
    cpu_wait_percentile_90 real,
    mem_used_percentile_90 real,
    mem_swap_percentile_90 real,
    disk_free_bytes_per_mount_point_percentile_90 real,
    driver_node_type character varying,
    worker_node_type character varying,
    worker_count real,
    min_autoscale_workers real,
    max_autoscale_workers real,
    auto_termination_minutes bigint,
    cluster_type character varying,
    dbr_version character varying,
    job_name character varying(256),
    job_type character varying,
    total_dbus double precision,
    avg_dbu_usage double precision,
    total_cost numeric(38,18),
    cloud character varying(16),
    currency_code character varying(8),
    price_per_dbu numeric(38,18),
    sku_name character varying,
    record_inserted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.genai_dbx_raw_preprocessed_aggregated OWNER TO postgres;

--
-- Name: TABLE genai_dbx_raw_preprocessed_aggregated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.genai_dbx_raw_preprocessed_aggregated IS 'Preprocessed and aggregated Databricks job data with performance metrics and cost information';


--
-- Name: COLUMN genai_dbx_raw_preprocessed_aggregated.job_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.genai_dbx_raw_preprocessed_aggregated.job_id IS 'Unique identifier for the Databricks job';


--
-- Name: COLUMN genai_dbx_raw_preprocessed_aggregated.account_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.genai_dbx_raw_preprocessed_aggregated.account_id IS 'Databricks account identifier';


--
-- Name: COLUMN genai_dbx_raw_preprocessed_aggregated.workspace_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.genai_dbx_raw_preprocessed_aggregated.workspace_id IS 'Databricks workspace identifier';


--
-- Name: COLUMN genai_dbx_raw_preprocessed_aggregated.cluster_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.genai_dbx_raw_preprocessed_aggregated.cluster_id IS 'Databricks cluster identifier';


--
-- Name: COLUMN genai_dbx_raw_preprocessed_aggregated.total_cost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.genai_dbx_raw_preprocessed_aggregated.total_cost IS 'Total cost for the job execution';


--
-- Name: COLUMN genai_dbx_raw_preprocessed_aggregated.record_inserted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.genai_dbx_raw_preprocessed_aggregated.record_inserted_at IS 'Timestamp when the record was inserted into the table';


--
-- Name: genai_dbx_reccomendation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.genai_dbx_reccomendation (
    account_id character varying,
    workspace_id character varying,
    job_id character varying,
    job_name character varying,
    sku_name character varying,
    category character varying,
    reason text,
    recommendation character varying,
    estimated_cost_savings numeric,
    estimated_savings_percent numeric,
    calculation_logic text,
    inserted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.genai_dbx_reccomendation OWNER TO postgres;

--
-- Name: genai_dbx_reccomendation_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.genai_dbx_reccomendation_history (
    id integer NOT NULL,
    original_id integer,
    account_id character varying,
    workspace_id character varying,
    job_id character varying,
    job_name character varying,
    sku_name character varying,
    category character varying,
    reason text,
    recommendation text,
    estimated_cost_savings numeric(15,2),
    estimated_savings_percent numeric(5,2),
    calculation_logic text,
    inserted_at timestamp without time zone,
    archived_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    archive_reason character varying(100) DEFAULT 'Updated'::character varying
);


ALTER TABLE public.genai_dbx_reccomendation_history OWNER TO postgres;

--
-- Name: TABLE genai_dbx_reccomendation_history; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.genai_dbx_reccomendation_history IS 'Historical archive of GenAI-based Databricks recommendations for audit and trend analysis';


--
-- Name: genai_dbx_reccomendation_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.genai_dbx_reccomendation_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.genai_dbx_reccomendation_history_id_seq OWNER TO postgres;

--
-- Name: genai_dbx_reccomendation_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.genai_dbx_reccomendation_history_id_seq OWNED BY public.genai_dbx_reccomendation_history.id;


--
-- Name: generated_optimized_queries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.generated_optimized_queries (
    user_email character varying(255),
    query_id integer NOT NULL,
    original_query text,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    duration integer,
    database_name text,
    schema_name text,
    bot_response text,
    query_understanding text,
    query_issues text,
    explain_plan_understanding text,
    metadata_understanding text,
    optimizations_recommendations text,
    optimized_query text,
    optimization_explanation text
);


ALTER TABLE public.generated_optimized_queries OWNER TO postgres;

--
-- Name: glue_recommendations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.glue_recommendations (
    autosacling boolean,
    completed_on timestamp without time zone,
    dpuhours numeric,
    dpu_seconds numeric,
    drivercpusystemload numeric,
    driverworkerutilization numeric,
    executionclass character varying,
    executiontime numeric,
    jobbookmark character varying,
    jobname character varying,
    jobrunid character varying,
    jobrunstate character varying,
    jobtype character varying,
    lastmodified timestamp without time zone,
    memoryusedpct numeric,
    numberofdpuallocated numeric,
    numberofworkers numeric,
    recommendation character varying,
    startedon timestamp without time zone,
    workertype character varying,
    potentialsaving numeric,
    suggestedworkertype character varying,
    recommendationcategory character varying,
    job_cost numeric
);


ALTER TABLE public.glue_recommendations OWNER TO postgres;

--
-- Name: jira_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: prism-web
--

CREATE SEQUENCE public.jira_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jira_attachments_id_seq OWNER TO "prism-web";

--
-- Name: jira_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prism-web
--

ALTER SEQUENCE public.jira_attachments_id_seq OWNED BY public.eqa_jira_attachments.id;


--
-- Name: jira_generated_stories_id_seq; Type: SEQUENCE; Schema: public; Owner: prism-web
--

CREATE SEQUENCE public.jira_generated_stories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jira_generated_stories_id_seq OWNER TO "prism-web";

--
-- Name: jira_generated_stories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prism-web
--

ALTER SEQUENCE public.jira_generated_stories_id_seq OWNED BY public.eqa_jira_generated_stories.id;


--
-- Name: jira_scrape_results_id_seq; Type: SEQUENCE; Schema: public; Owner: prism-web
--

CREATE SEQUENCE public.jira_scrape_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jira_scrape_results_id_seq OWNER TO "prism-web";

--
-- Name: jira_scrape_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prism-web
--

ALTER SEQUENCE public.jira_scrape_results_id_seq OWNED BY public.eqa_jira_scrape_results.id;


--
-- Name: monthly_sales_trend; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.monthly_sales_trend AS
 SELECT date_trunc('month'::text, (o.order_date)::timestamp with time zone) AS month,
    count(DISTINCT o.order_id) AS total_orders,
    count(DISTINCT o.customer_id) AS unique_customers,
    sum(o.total_amount) AS total_revenue,
    avg(o.total_amount) AS avg_order_value
   FROM public.orders o
  WHERE ((o.order_status)::text <> 'Cancelled'::text)
  GROUP BY (date_trunc('month'::text, (o.order_date)::timestamp with time zone))
  ORDER BY (date_trunc('month'::text, (o.order_date)::timestamp with time zone)) DESC;


ALTER TABLE public.monthly_sales_trend OWNER TO postgres;

--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    order_item_id integer NOT NULL,
    order_id integer,
    product_id integer,
    quantity integer NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    discount_percent numeric(5,2) DEFAULT 0.00,
    line_total numeric(12,2) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: TABLE order_items; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.order_items IS 'Line items for each order';


--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_items_order_item_id_seq OWNER TO postgres;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_order_item_id_seq OWNED BY public.order_items.order_item_id;


--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_order_id_seq OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.password_reset_tokens (
    id uuid NOT NULL,
    tenant_id character varying(120) NOT NULL,
    user_id uuid NOT NULL,
    token character varying(128) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used boolean NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.password_reset_tokens OWNER TO "prism-web";

--
-- Name: performance_metrics; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.performance_metrics (
    id integer NOT NULL,
    run_id character varying(64) NOT NULL,
    total_requests integer NOT NULL,
    failures integer NOT NULL,
    failure_rate double precision NOT NULL,
    avg_response_time_ms double precision NOT NULL,
    min_response_time_ms double precision NOT NULL,
    max_response_time_ms double precision NOT NULL,
    p95_response_time_ms double precision NOT NULL,
    p99_response_time_ms double precision NOT NULL,
    requests_per_sec double precision NOT NULL
);


ALTER TABLE public.performance_metrics OWNER TO "prism-web";

--
-- Name: performance_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: prism-web
--

CREATE SEQUENCE public.performance_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.performance_metrics_id_seq OWNER TO "prism-web";

--
-- Name: performance_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prism-web
--

ALTER SEQUENCE public.performance_metrics_id_seq OWNED BY public.performance_metrics.id;


--
-- Name: performance_test_runs; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.performance_test_runs (
    id integer NOT NULL,
    run_id character varying(64) NOT NULL,
    test_name character varying(255) NOT NULL,
    environment character varying(255) NOT NULL,
    endpoint character varying(1000) NOT NULL,
    method character varying(20) NOT NULL,
    users integer NOT NULL,
    spawn_rate integer NOT NULL,
    duration_sec integer NOT NULL,
    execution_time timestamp with time zone DEFAULT now() NOT NULL,
    status character varying(20) NOT NULL
);


ALTER TABLE public.performance_test_runs OWNER TO "prism-web";

--
-- Name: performance_test_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: prism-web
--

CREATE SEQUENCE public.performance_test_runs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.performance_test_runs_id_seq OWNER TO "prism-web";

--
-- Name: performance_test_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prism-web
--

ALTER SEQUENCE public.performance_test_runs_id_seq OWNED BY public.performance_test_runs.id;


--
-- Name: platform_config_json; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.platform_config_json (
    id integer NOT NULL,
    platform_name character varying(50) NOT NULL,
    config jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.platform_config_json OWNER TO postgres;

--
-- Name: platform_config_json_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.platform_config_json_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.platform_config_json_id_seq OWNER TO postgres;

--
-- Name: platform_config_json_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.platform_config_json_id_seq OWNED BY public.platform_config_json.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id integer NOT NULL,
    product_name character varying(255) NOT NULL,
    category_id integer,
    unit_price numeric(10,2) NOT NULL,
    cost_price numeric(10,2) NOT NULL,
    stock_quantity integer DEFAULT 0,
    reorder_level integer DEFAULT 10,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: TABLE products; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.products IS 'Product catalog with pricing and inventory';


--
-- Name: product_sales_performance; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.product_sales_performance AS
 SELECT p.product_id,
    p.product_name,
    cat.category_name,
    count(DISTINCT oi.order_id) AS total_orders,
    sum(oi.quantity) AS total_quantity_sold,
    sum(oi.line_total) AS total_revenue,
    avg(oi.unit_price) AS avg_selling_price,
    p.unit_price AS current_price,
    p.stock_quantity
   FROM ((public.products p
     JOIN public.categories cat ON ((p.category_id = cat.category_id)))
     LEFT JOIN public.order_items oi ON ((p.product_id = oi.product_id)))
  GROUP BY p.product_id, p.product_name, cat.category_name, p.unit_price, p.stock_quantity;


ALTER TABLE public.product_sales_performance OWNER TO postgres;

--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_product_id_seq OWNER TO postgres;

--
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_product_id_seq OWNED BY public.products.product_id;


--
-- Name: query_issues; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.query_issues AS
 WITH raw_lines AS (
         SELECT generated_optimized_queries.query_id,
            regexp_split_to_table(generated_optimized_queries.query_issues, '\n'::text) AS raw_line
           FROM public.generated_optimized_queries
        ), tagged_lines AS (
         SELECT sub.query_id,
                CASE
                    WHEN (sub.raw_line ~~ '-%'::text) THEN regexp_replace(sub.raw_line, '^-\\s*'::text, ''::text)
                    ELSE NULL::text
                END AS new_issue,
                CASE
                    WHEN (sub.raw_line !~~ '-%'::text) THEN sub.raw_line
                    ELSE NULL::text
                END AS continuation,
            row_number() OVER (PARTITION BY sub.query_id ORDER BY sub.ordinal) AS line_num
           FROM ( SELECT raw_lines.query_id,
                    raw_lines.raw_line,
                    row_number() OVER (PARTITION BY raw_lines.query_id ORDER BY raw_lines.query_id) AS ordinal
                   FROM raw_lines) sub
        ), issue_blocks AS (
         SELECT tagged_lines.query_id,
            COALESCE(tagged_lines.new_issue, lag(tagged_lines.new_issue) OVER (PARTITION BY tagged_lines.query_id ORDER BY tagged_lines.line_num)) AS issue_id,
            COALESCE(tagged_lines.new_issue, tagged_lines.continuation) AS line
           FROM tagged_lines
        ), grouped_issues AS (
         SELECT issue_blocks.query_id,
            issue_blocks.issue_id AS problem,
                CASE
                    WHEN (issue_blocks.issue_id ~~* '%join%'::text) THEN 'Join Issues'::text
                    WHEN (issue_blocks.issue_id ~~* '%filter%'::text) THEN 'Filtering Issues'::text
                    WHEN ((issue_blocks.issue_id ~~* '%aggregation%'::text) OR (issue_blocks.issue_id ~~* '%group by%'::text)) THEN 'Aggregation Issues'::text
                    WHEN (issue_blocks.issue_id ~~* '%cte%'::text) THEN 'CTE/Materialization'::text
                    WHEN (issue_blocks.issue_id ~~* '%union%'::text) THEN 'Union/Repeated Logic'::text
                    WHEN ((issue_blocks.issue_id ~~* '%cast%'::text) OR (issue_blocks.issue_id ~~* '%expression%'::text)) THEN 'Expression/Computation'::text
                    WHEN ((issue_blocks.issue_id ~~* '%sort key%'::text) OR (issue_blocks.issue_id ~~* '%distribution key%'::text)) THEN 'Physical Design'::text
                    WHEN (issue_blocks.issue_id ~~* '%encoding%'::text) THEN 'Storage Optimization'::text
                    WHEN (issue_blocks.issue_id ~~* '%partition%'::text) THEN 'Partitioning'::text
                    WHEN (issue_blocks.issue_id ~~* '%null%'::text) THEN 'Data Quality'::text
                    WHEN (issue_blocks.issue_id ~~* '%select%'::text) THEN 'Column Selection'::text
                    ELSE 'Other'::text
                END AS category
           FROM issue_blocks
          WHERE (issue_blocks.issue_id IS NOT NULL)
        )
 SELECT grouped_issues.query_id,
    grouped_issues.problem,
    grouped_issues.category
   FROM grouped_issues
  ORDER BY grouped_issues.query_id, grouped_issues.category;


ALTER TABLE public.query_issues OWNER TO postgres;

--
-- Name: query_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.query_metadata (
    query_id integer NOT NULL,
    user_id integer,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    duration integer,
    db_name text,
    query_text text,
    aborted integer,
    query_type character varying(10),
    statement_text text,
    plan_node text,
    info text,
    task text,
    service_class integer,
    slot_count integer,
    total_exec_time bigint,
    final_state character(16),
    query_cpu_time bigint,
    query_blocks_read bigint,
    query_execution_time bigint,
    query_cpu_usage_percent numeric(38,2),
    scanned_table_id integer,
    scanned_rows bigint,
    slice integer,
    segment integer,
    task_num integer,
    schema_name text,
    table_name text,
    table_size bigint,
    table_rows numeric(38,0)
);


ALTER TABLE public.query_metadata OWNER TO postgres;

--
-- Name: query_optimization_recommendations; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.query_optimization_recommendations AS
 WITH raw_lines AS (
         SELECT generated_optimized_queries.query_id,
            regexp_split_to_table(generated_optimized_queries.optimizations_recommendations, '\n'::text) AS raw_line
           FROM public.generated_optimized_queries
        ), normalized_recs AS (
         SELECT raw_lines.query_id,
            TRIM(BOTH FROM
                CASE
                    WHEN (raw_lines.raw_line ~~ '-%'::text) THEN regexp_replace(raw_lines.raw_line, '^-\\s*'::text, ''::text)
                    ELSE raw_lines.raw_line
                END) AS recommendation
           FROM raw_lines
          WHERE ((length(raw_lines.raw_line) - length(replace(raw_lines.raw_line, '|'::text, ''::text))) < 3)
        ), deduplicated AS (
         SELECT DISTINCT normalized_recs.query_id,
            normalized_recs.recommendation
           FROM normalized_recs
          WHERE ((normalized_recs.recommendation IS NOT NULL) AND (normalized_recs.recommendation <> ''::text))
        ), categorized AS (
         SELECT deduplicated.query_id,
            deduplicated.recommendation,
                CASE
                    WHEN (deduplicated.recommendation ~~* '%column-level storage optimization recommendations%'::text) THEN 'Column-level Storage Optimization'::text
                    WHEN (deduplicated.recommendation ~~* '%recommend column encodings%'::text) THEN 'Column-level Storage Optimization'::text
                    WHEN (deduplicated.recommendation ~~* '%explicitly list only needed columns%'::text) THEN 'Column Selection'::text
                    WHEN (deduplicated.recommendation ~~* '%use distkey%'::text) THEN 'Distribution/Clustering/Sort Keys'::text
                    WHEN (deduplicated.recommendation ~~* '%use sortkey%'::text) THEN 'Distribution/Clustering/Sort Keys'::text
                    WHEN (deduplicated.recommendation ~~* '%partition tables%'::text) THEN 'Distribution/Clustering/Sort Keys'::text
                    WHEN (deduplicated.recommendation ~~* '%use inner joins%'::text) THEN 'Query Structure'::text
                    WHEN (deduplicated.recommendation ~~* '%filter%'::text) THEN 'Query Structure'::text
                    WHEN (deduplicated.recommendation ~~* '%aggregate%'::text) THEN 'Query Structure'::text
                    WHEN (deduplicated.recommendation ~~* '%cte%'::text) THEN 'Query Structure'::text
                    WHEN (deduplicated.recommendation ~~* '%subquery%'::text) THEN 'Query Structure'::text
                    ELSE 'Other'::text
                END AS category
           FROM deduplicated
        )
 SELECT categorized.query_id,
    categorized.recommendation,
    categorized.category
   FROM categorized
  ORDER BY categorized.query_id, categorized.category;


ALTER TABLE public.query_optimization_recommendations OWNER TO postgres;

--
-- Name: redshift_cluster_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.redshift_cluster_metrics (
    cluster_id text,
    node_type text,
    num_nodes integer,
    cluster_status text,
    cpu_avg numeric(10,2),
    query_throughput_sum numeric(18,2),
    storage_total_gb numeric(18,2),
    storage_used_gb numeric(18,2),
    start timestamp with time zone,
    "end" timestamp with time zone
);


ALTER TABLE public.redshift_cluster_metrics OWNER TO postgres;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.refresh_tokens (
    id uuid NOT NULL,
    tenant_id character varying(120) NOT NULL,
    user_id uuid NOT NULL,
    token_hash character varying(128) NOT NULL,
    revoked boolean NOT NULL,
    created_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL
);


ALTER TABLE public.refresh_tokens OWNER TO "prism-web";

--
-- Name: regions_region_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.regions_region_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.regions_region_id_seq OWNER TO postgres;

--
-- Name: regions_region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.regions_region_id_seq OWNED BY public.regions.region_id;


--
-- Name: sage_maker_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sage_maker_data (
    notebook_name text,
    status text,
    instance_type text,
    creation_date timestamp with time zone,
    last_updated timestamp with time zone,
    life_cycle_configuration text,
    volume text,
    recommendation text
);


ALTER TABLE public.sage_maker_data OWNER TO postgres;

--
-- Name: sales_agents_agent_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sales_agents_agent_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sales_agents_agent_id_seq OWNER TO postgres;

--
-- Name: sales_agents_agent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sales_agents_agent_id_seq OWNED BY public.sales_agents.agent_id;


--
-- Name: sales_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.sales_summary AS
 SELECT o.order_id,
    o.order_date,
    c.customer_name,
    c.customer_type,
    sa.agent_name,
    r.region_name,
    o.order_status,
    o.payment_status,
    o.total_amount,
    o.discount_amount,
    o.tax_amount,
    o.shipping_cost,
    (((o.total_amount - o.discount_amount) + o.tax_amount) + o.shipping_cost) AS net_amount
   FROM (((public.orders o
     JOIN public.customers c ON ((o.customer_id = c.customer_id)))
     JOIN public.sales_agents sa ON ((o.agent_id = sa.agent_id)))
     JOIN public.regions r ON ((sa.region_id = r.region_id)));


ALTER TABLE public.sales_summary OWNER TO postgres;

--
-- Name: schema_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_metadata (
    id integer NOT NULL,
    schema_name character varying(255) NOT NULL,
    table_name character varying(255) NOT NULL,
    column_name character varying(255),
    metadata_type character varying(50) NOT NULL,
    description text NOT NULL,
    purpose text,
    data_characteristics text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(100) DEFAULT 'schema_discovery_agent'::character varying
);


ALTER TABLE public.schema_metadata OWNER TO postgres;

--
-- Name: schema_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schema_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schema_metadata_id_seq OWNER TO postgres;

--
-- Name: schema_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schema_metadata_id_seq OWNED BY public.schema_metadata.id;


--
-- Name: skumeter_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skumeter_metadata (
    id integer NOT NULL,
    skumeter character varying(500),
    description text
);


ALTER TABLE public.skumeter_metadata OWNER TO postgres;

--
-- Name: skumeter_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.skumeter_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.skumeter_metadata_id_seq OWNER TO postgres;

--
-- Name: skumeter_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.skumeter_metadata_id_seq OWNED BY public.skumeter_metadata.id;


--
-- Name: story_analysis_results_id_seq; Type: SEQUENCE; Schema: public; Owner: prism-web
--

CREATE SEQUENCE public.story_analysis_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.story_analysis_results_id_seq OWNER TO "prism-web";

--
-- Name: story_analysis_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prism-web
--

ALTER SEQUENCE public.story_analysis_results_id_seq OWNED BY public.eqa_story_analysis_results.id;


--
-- Name: table_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.table_metadata (
    table_id integer NOT NULL,
    table_name text NOT NULL,
    table_ddl text
);


ALTER TABLE public.table_metadata OWNER TO postgres;

--
-- Name: temp_databricks_query_warehouse_current; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.temp_databricks_query_warehouse_current AS
 SELECT dqc.warehouse_id,
    dqc.warehouse_name,
    dqc.workspace_id,
    dqc.workspace_name,
    dqc.statement_text,
    dqc.statement_id,
    dqc.total_query_cost,
    date(dqc.start_time) AS query_date,
    dwu.usage_date AS warehouse_usage_date,
    dwu.warehouse_type,
    dwu.dbus,
    dwu.day_dollars,
    dwu.total_dollars
   FROM (public.databricks_query_cost dqc
     JOIN public.databricks_warehouse_usage dwu ON ((((dqc.warehouse_id)::text = (dwu.warehouse_id)::text) AND ((dqc.workspace_id)::text = (dwu.workspace_id)::text) AND (date(dqc.start_time) = dwu.usage_date))))
  WHERE (date(dqc.start_time) = ( SELECT max(date(databricks_query_cost.start_time)) AS max
           FROM public.databricks_query_cost));


ALTER TABLE public.temp_databricks_query_warehouse_current OWNER TO postgres;

--
-- Name: tenants; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.tenants (
    id uuid NOT NULL,
    domain character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp with time zone NOT NULL,
    tenant_id character varying(120)
);



-- ======================================================
-- 3. LOAD TENANTS DATA
-- ======================================================

INSERT INTO tenants (
    id,
    domain,
    is_active,
    created_at,
    tenant_id
)
VALUES
(
    '946a91a6-dfd3-41c5-a64b-f041a610be74',
    'defaultOrgId',
    TRUE,
    '2026-01-15 17:37:50.339348+05:30',
    'defaultOrgId_946a91a6-dfd3-41c5-a64b-f041a610be74'
),
(
    'cbb746a6-8ddc-4f03-8c54-480de95de593',
    'impetus',
    TRUE,
    '2026-02-01 21:04:26.124468+05:30',
    'impetus_cbb746a6-8ddc-4f03-8c54-480de95de593'
),
(
    '46c1e89e-28e8-47dd-976e-09198fb52ca1',
    'test',
    TRUE,
    '2026-02-02 13:01:23.447028+05:30',
    'test_46c1e89e-28e8-47dd-976e-09198fb52ca1'
),
(
    '511097b6-de52-4d6f-9414-235292e29300',
    'prism',
    TRUE,
    '2026-03-27 17:30:44.427063+05:30',
    'prism_511097b6-de52-4d6f-9414-235292e29300'
)
ON CONFLICT (id) DO NOTHING;

ALTER TABLE public.tenants OWNER TO "prism-web";

--
-- Name: test_cases_id_seq; Type: SEQUENCE; Schema: public; Owner: prism-web
--

CREATE SEQUENCE public.test_cases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.test_cases_id_seq OWNER TO "prism-web";

--
-- Name: test_cases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prism-web
--

ALTER SEQUENCE public.test_cases_id_seq OWNED BY public.eqa_test_cases.id;


--
-- Name: test_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_results (
    id integer NOT NULL,
    user_query text NOT NULL,
    test_type character varying(20) NOT NULL,
    parent_question text,
    bot_response text,
    rating_out_of_5 numeric(3,1),
    problems text,
    possible_solutions text,
    sql_generated text,
    semantic_match boolean
);


ALTER TABLE public.test_results OWNER TO postgres;

--
-- Name: test_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.test_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.test_results_id_seq OWNER TO postgres;

--
-- Name: test_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.test_results_id_seq OWNED BY public.test_results.id;


--
-- Name: test_type_classifications_id_seq; Type: SEQUENCE; Schema: public; Owner: prism-web
--

CREATE SEQUENCE public.test_type_classifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.test_type_classifications_id_seq OWNER TO "prism-web";

--
-- Name: test_type_classifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prism-web
--

ALTER SEQUENCE public.test_type_classifications_id_seq OWNED BY public.eqa_test_type_classifications.id;


--
-- Name: user_test_type_selections_id_seq; Type: SEQUENCE; Schema: public; Owner: prism-web
--

CREATE SEQUENCE public.user_test_type_selections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_test_type_selections_id_seq OWNER TO "prism-web";

--
-- Name: user_test_type_selections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prism-web
--

ALTER SEQUENCE public.user_test_type_selections_id_seq OWNED BY public.eqa_user_test_type_selections.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: prism-web
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    tenant_id character varying(120) NOT NULL,
    user_id character varying(64) NOT NULL,
    user_name character varying(120) NOT NULL,
    email character varying(320),
    password_hash character varying(255) NOT NULL,
    creation_date timestamp with time zone NOT NULL,
    activation_date timestamp with time zone,
    expiration_date timestamp with time zone,
    last_modification_date timestamp with time zone NOT NULL,
    password_reset boolean NOT NULL,
    login_time timestamp with time zone,
    last_logined_date timestamp with time zone,
    role character varying(32) NOT NULL,
    is_active boolean NOT NULL,
    deleted_at timestamp with time zone,
    created_by uuid,
    modify_by uuid,
    deleted_by uuid
);



-- ======================================================
-- 4. LOAD USERS DATA
-- ======================================================

INSERT INTO users (
    id,
    tenant_id,
    user_id,
    user_name,
    email,
    password_hash,
    creation_date,
    activation_date,
    expiration_date,
    last_modification_date,
    password_reset,
    login_time,
    last_logined_date,
    role,
    is_active,
    deleted_at,
    created_by,
    modify_by,
    deleted_by
)
VALUES
(
    '4a785f0e-0c72-420d-9499-dfe5326a0207',
    'impetus_cbb746a6-8ddc-4f03-8c54-480de95de593',
    'USR1769945560',
    'admin',
    'admin@impetus.com',
    '$2b$12$GiC7DO2ZD47OS1EpC.kRPOka5tNY0csIbf2OGGK3JPh1OHaqppnaW',
    '2026-02-01 17:02:40.855682+05:30',
    NULL,
    NULL,
    '2026-02-01 17:03:04.169252+05:30',
    FALSE,
    NULL,
    '2026-02-01 17:03:04.169235+05:30',
    'admin',
    TRUE,
    NULL,
    'admin',
    NULL,
    NULL
),
(
    'd3ee3c66-d216-41f5-aff6-27029c4b480a',
    'defaultOrgId_946a91a6-dfd3-41c5-a64b-f041a610be74',
    'USR1770204005',
    'admin',
    'admin@defaultOrgId.com',
    '$2b$12$FIuycW2BNOhCGaw0HBwabOzEb9uXTPe2fouVl2UOD47fpHvlFhVku',
    '2026-02-04 16:50:05.965441+05:30',
    NULL,
    NULL,
    '2026-02-04 16:50:05.965441+05:30',
    FALSE,
    NULL,
    NULL,
    'admin',
    TRUE,
    NULL,
    'admin',
    NULL,
    NULL
)
ON CONFLICT (id) DO NOTHING;


ALTER TABLE public.users OWNER TO "prism-web";

--
-- Name: v_databricks_current_day_cost; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_databricks_current_day_cost AS
 WITH daily_clusters AS (
         SELECT databricks_cluster_cost.cluster_id,
            databricks_cluster_cost.workspace_id,
            databricks_cluster_cost.sku_name,
            databricks_cluster_cost.instance_type,
            sum(databricks_cluster_cost.usage_quantity) AS total_dbus,
            sum(databricks_cluster_cost.cost) AS databricks_cost,
            sum(databricks_cluster_cost.cloud_cost) AS provider_cost,
            sum(databricks_cluster_cost.total_cost) AS total_combined_cost
           FROM public.databricks_cluster_cost
          WHERE ((databricks_cluster_cost.usage_start_time)::date = CURRENT_DATE)
          GROUP BY databricks_cluster_cost.cluster_id, databricks_cluster_cost.workspace_id, databricks_cluster_cost.sku_name, databricks_cluster_cost.instance_type
        ), daily_jobs AS (
         SELECT databricks_job_cost.job_id,
            databricks_job_cost.run_id,
            databricks_job_cost.compute_id,
            databricks_job_cost.name AS job_name,
            databricks_job_cost.task_key,
            databricks_job_cost.result_state,
            databricks_job_cost.execution_duration_seconds,
            databricks_job_cost.setup_duration_seconds,
            databricks_job_cost.period_start_time,
            databricks_job_cost.run_as_user_name,
            databricks_job_cost.workspace_name,
            databricks_job_cost.workspace_id,
            databricks_job_cost.job_cost
           FROM public.databricks_job_cost
          WHERE ((databricks_job_cost.period_start_time)::date = CURRENT_DATE)
        )
 SELECT j.workspace_name,
    j.job_name,
    j.task_key,
    j.run_id,
    j.result_state,
    j.run_as_user_name,
    j.period_start_time,
    j.execution_duration_seconds,
    j.setup_duration_seconds,
    c.sku_name,
    c.instance_type,
    c.total_dbus,
    c.databricks_cost,
    c.provider_cost,
    c.total_combined_cost,
    j.job_cost,
        CASE
            WHEN (j.execution_duration_seconds > (0)::numeric) THEN (c.total_combined_cost / j.execution_duration_seconds)
            ELSE (0)::numeric
        END AS cost_per_sec
   FROM (daily_jobs j
     LEFT JOIN daily_clusters c ON ((((j.compute_id)::text = (c.cluster_id)::text) AND ((j.workspace_id)::text = (c.workspace_id)::text))))
  ORDER BY j.period_start_time DESC;


ALTER TABLE public.v_databricks_current_day_cost OWNER TO postgres;

--
-- Name: v_databricks_current_day_cost_insights; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_databricks_current_day_cost_insights AS
 WITH daily_cluster_spend AS (
         SELECT databricks_cluster_cost.cluster_id,
            databricks_cluster_cost.workspace_id,
            databricks_cluster_cost.instance_type,
            databricks_cluster_cost.sku_name,
            sum(databricks_cluster_cost.usage_quantity) AS total_dbus,
            sum(databricks_cluster_cost.cost) AS dbu_cost,
            sum(databricks_cluster_cost.cloud_cost) AS infra_cost,
            sum(databricks_cluster_cost.total_cost) AS combined_cost
           FROM public.databricks_cluster_cost
          WHERE ((databricks_cluster_cost.usage_start_time)::date = CURRENT_DATE)
          GROUP BY databricks_cluster_cost.cluster_id, databricks_cluster_cost.workspace_id, databricks_cluster_cost.instance_type, databricks_cluster_cost.sku_name
        ), daily_job_executions AS (
         SELECT databricks_job_cost.workspace_id,
            databricks_job_cost.workspace_name,
            databricks_job_cost.job_id,
            databricks_job_cost.name AS job_name,
            databricks_job_cost.run_id,
            databricks_job_cost.job_run_id,
            databricks_job_cost.task_key,
            databricks_job_cost.compute_id,
            databricks_job_cost.period_start_time,
            databricks_job_cost.period_end_time,
            databricks_job_cost.execution_duration_seconds,
            databricks_job_cost.setup_duration_seconds,
            databricks_job_cost.job_duration,
            databricks_job_cost.result_state,
            databricks_job_cost.run_as_user_name,
            databricks_job_cost.job_cost,
            databricks_job_cost.tags AS job_tags
           FROM public.databricks_job_cost
          WHERE ((databricks_job_cost.period_start_time)::date = CURRENT_DATE)
        )
 SELECT j.workspace_name,
    j.job_name,
    j.task_key,
    j.run_id,
    j.result_state,
    j.period_start_time,
    j.execution_duration_seconds,
    j.setup_duration_seconds,
    j.job_duration,
    c.instance_type,
    c.sku_name,
    j.job_cost AS recorded_job_cost,
    c.infra_cost AS cloud_infrastructure_cost,
    c.combined_cost AS total_run_cost,
        CASE
            WHEN (j.execution_duration_seconds > (0)::numeric) THEN (c.combined_cost / j.execution_duration_seconds)
            ELSE (0)::numeric
        END AS cost_per_execution_second,
    j.run_as_user_name,
    j.job_tags
   FROM (daily_job_executions j
     LEFT JOIN daily_cluster_spend c ON ((((j.compute_id)::text = (c.cluster_id)::text) AND ((j.workspace_id)::text = (c.workspace_id)::text))))
  ORDER BY j.period_start_time DESC;


ALTER TABLE public.v_databricks_current_day_cost_insights OWNER TO postgres;

--
-- Name: schema_metadata id; Type: DEFAULT; Schema: focus; Owner: postgres
--

ALTER TABLE ONLY focus.schema_metadata ALTER COLUMN id SET DEFAULT nextval('focus.schema_metadata_id_seq'::regclass);


--
-- Name: aws_cost_anomaly_agent_output id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aws_cost_anomaly_agent_output ALTER COLUMN id SET DEFAULT nextval('public.aws_cost_anomaly_agent_output_id_seq'::regclass);


--
-- Name: aws_focus_cost_current_mock id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aws_focus_cost_current_mock ALTER COLUMN id SET DEFAULT nextval('public.aws_focus_cost_current_mock_id_seq'::regclass);


--
-- Name: aws_recommendation_consolidate id; Type: DEFAULT; Schema: public; Owner: finops
--

ALTER TABLE ONLY public.aws_recommendation_consolidate ALTER COLUMN id SET DEFAULT nextval('public.aws_recommendation_consolidate_id_seq'::regclass);


--
-- Name: aws_s3_data_insights id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aws_s3_data_insights ALTER COLUMN id SET DEFAULT nextval('public.aws_s3_data_insights_id_seq'::regclass);


--
-- Name: aws_s3_data_insights_mock id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aws_s3_data_insights_mock ALTER COLUMN id SET DEFAULT nextval('public.aws_s3_data_insights_mock_id_seq'::regclass);


--
-- Name: best_practices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.best_practices ALTER COLUMN id SET DEFAULT nextval('public.best_practices_id_seq'::regclass);


--
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.categories_category_id_seq'::regclass);


--
-- Name: conversation_memory id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_memory ALTER COLUMN id SET DEFAULT nextval('public.conversation_memory_id_seq'::regclass);


--
-- Name: customers customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN customer_id SET DEFAULT nextval('public.customers_customer_id_seq'::regclass);


--
-- Name: environment_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.environment_details ALTER COLUMN id SET DEFAULT nextval('public.environment_details_id_seq'::regclass);


--
-- Name: eqa_jira_attachments id; Type: DEFAULT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_jira_attachments ALTER COLUMN id SET DEFAULT nextval('public.jira_attachments_id_seq'::regclass);


--
-- Name: eqa_jira_generated_stories id; Type: DEFAULT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_jira_generated_stories ALTER COLUMN id SET DEFAULT nextval('public.jira_generated_stories_id_seq'::regclass);


--
-- Name: eqa_jira_scrape_results id; Type: DEFAULT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_jira_scrape_results ALTER COLUMN id SET DEFAULT nextval('public.jira_scrape_results_id_seq'::regclass);


--
-- Name: eqa_story_analysis_results id; Type: DEFAULT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_story_analysis_results ALTER COLUMN id SET DEFAULT nextval('public.story_analysis_results_id_seq'::regclass);


--
-- Name: eqa_test_cases id; Type: DEFAULT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_test_cases ALTER COLUMN id SET DEFAULT nextval('public.test_cases_id_seq'::regclass);


--
-- Name: eqa_test_type_classifications id; Type: DEFAULT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_test_type_classifications ALTER COLUMN id SET DEFAULT nextval('public.test_type_classifications_id_seq'::regclass);


--
-- Name: eqa_user_test_type_selections id; Type: DEFAULT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_user_test_type_selections ALTER COLUMN id SET DEFAULT nextval('public.user_test_type_selections_id_seq'::regclass);


--
-- Name: focus_metadata id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.focus_metadata ALTER COLUMN id SET DEFAULT nextval('public.focus_metadata_id_seq'::regclass);


--
-- Name: genai_dbx_reccomendation_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genai_dbx_reccomendation_history ALTER COLUMN id SET DEFAULT nextval('public.genai_dbx_reccomendation_history_id_seq'::regclass);


--
-- Name: order_items order_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_items_order_item_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Name: performance_metrics id; Type: DEFAULT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.performance_metrics ALTER COLUMN id SET DEFAULT nextval('public.performance_metrics_id_seq'::regclass);


--
-- Name: performance_test_runs id; Type: DEFAULT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.performance_test_runs ALTER COLUMN id SET DEFAULT nextval('public.performance_test_runs_id_seq'::regclass);


--
-- Name: platform_config_json id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_config_json ALTER COLUMN id SET DEFAULT nextval('public.platform_config_json_id_seq'::regclass);


--
-- Name: products product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN product_id SET DEFAULT nextval('public.products_product_id_seq'::regclass);


--
-- Name: regions region_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regions ALTER COLUMN region_id SET DEFAULT nextval('public.regions_region_id_seq'::regclass);


--
-- Name: sales_agents agent_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_agents ALTER COLUMN agent_id SET DEFAULT nextval('public.sales_agents_agent_id_seq'::regclass);


--
-- Name: schema_metadata id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_metadata ALTER COLUMN id SET DEFAULT nextval('public.schema_metadata_id_seq'::regclass);


--
-- Name: skumeter_metadata id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skumeter_metadata ALTER COLUMN id SET DEFAULT nextval('public.skumeter_metadata_id_seq'::regclass);


--
-- Name: test_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_results ALTER COLUMN id SET DEFAULT nextval('public.test_results_id_seq'::regclass);


--
-- Name: schema_metadata schema_metadata_pkey; Type: CONSTRAINT; Schema: focus; Owner: postgres
--

ALTER TABLE ONLY focus.schema_metadata
    ADD CONSTRAINT schema_metadata_pkey PRIMARY KEY (id);


--
-- Name: schema_metadata unique_metadata; Type: CONSTRAINT; Schema: focus; Owner: postgres
--

ALTER TABLE ONLY focus.schema_metadata
    ADD CONSTRAINT unique_metadata UNIQUE (schema_name, table_name, column_name, metadata_type);


--
-- Name: agent_feedback agent_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agent_feedback
    ADD CONSTRAINT agent_feedback_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: athena_query_recommendation athena_query_recommendation_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.athena_query_recommendation
    ADD CONSTRAINT athena_query_recommendation_unique UNIQUE (execution_id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: auth_sessions auth_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_pkey PRIMARY KEY (id);


--
-- Name: aws_cost_anomaly_agent_output aws_cost_anomaly_agent_output_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aws_cost_anomaly_agent_output
    ADD CONSTRAINT aws_cost_anomaly_agent_output_pkey PRIMARY KEY (id);


--
-- Name: aws_focus_cost_current_mock aws_focus_cost_current_mock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aws_focus_cost_current_mock
    ADD CONSTRAINT aws_focus_cost_current_mock_pkey PRIMARY KEY (id);


--
-- Name: aws_recommendation_consolidate aws_recommendation_consolidate_pkey; Type: CONSTRAINT; Schema: public; Owner: finops
--

ALTER TABLE ONLY public.aws_recommendation_consolidate
    ADD CONSTRAINT aws_recommendation_consolidate_pkey PRIMARY KEY (id);


--
-- Name: aws_s3_data_insights_mock aws_s3_data_insights_mock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aws_s3_data_insights_mock
    ADD CONSTRAINT aws_s3_data_insights_mock_pkey PRIMARY KEY (id);


--
-- Name: aws_s3_data_insights aws_s3_data_insights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aws_s3_data_insights
    ADD CONSTRAINT aws_s3_data_insights_pkey PRIMARY KEY (id);


--
-- Name: categories categories_category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_category_name_key UNIQUE (category_name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: conversation_memory conversation_memory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_memory
    ADD CONSTRAINT conversation_memory_pkey PRIMARY KEY (id);


--
-- Name: cronjob_config cronjob_config_job_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cronjob_config
    ADD CONSTRAINT cronjob_config_job_name_key UNIQUE (job_name);


--
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: email_verification_tokens email_verification_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_pkey PRIMARY KEY (id);


--
-- Name: focus_metadata focus_metadata_field_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.focus_metadata
    ADD CONSTRAINT focus_metadata_field_key UNIQUE (field);


--
-- Name: focus_metadata focus_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.focus_metadata
    ADD CONSTRAINT focus_metadata_pkey PRIMARY KEY (id);


--
-- Name: genai_dbx_raw_preprocessed_aggregated genai_dbx_raw_preprocessed_aggregated_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genai_dbx_raw_preprocessed_aggregated
    ADD CONSTRAINT genai_dbx_raw_preprocessed_aggregated_pkey PRIMARY KEY (job_id);


--
-- Name: genai_dbx_reccomendation_history genai_dbx_reccomendation_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genai_dbx_reccomendation_history
    ADD CONSTRAINT genai_dbx_reccomendation_history_pkey PRIMARY KEY (id);


--
-- Name: eqa_jira_attachments jira_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_jira_attachments
    ADD CONSTRAINT jira_attachments_pkey PRIMARY KEY (id);


--
-- Name: eqa_jira_generated_stories jira_generated_stories_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_jira_generated_stories
    ADD CONSTRAINT jira_generated_stories_pkey PRIMARY KEY (id);


--
-- Name: eqa_jira_scrape_results jira_scrape_results_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_jira_scrape_results
    ADD CONSTRAINT jira_scrape_results_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- Name: performance_metrics performance_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.performance_metrics
    ADD CONSTRAINT performance_metrics_pkey PRIMARY KEY (id);


--
-- Name: performance_test_runs performance_test_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.performance_test_runs
    ADD CONSTRAINT performance_test_runs_pkey PRIMARY KEY (id);


--
-- Name: platform_config_json platform_config_json_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_config_json
    ADD CONSTRAINT platform_config_json_pkey PRIMARY KEY (id);


--
-- Name: platform_config_json platform_config_json_platform_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_config_json
    ADD CONSTRAINT platform_config_json_platform_name_key UNIQUE (platform_name);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (region_id);


--
-- Name: regions regions_region_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_region_name_key UNIQUE (region_name);


--
-- Name: sales_agents sales_agents_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_agents
    ADD CONSTRAINT sales_agents_email_key UNIQUE (email);


--
-- Name: sales_agents sales_agents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_agents
    ADD CONSTRAINT sales_agents_pkey PRIMARY KEY (agent_id);


--
-- Name: schema_metadata schema_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_metadata
    ADD CONSTRAINT schema_metadata_pkey PRIMARY KEY (id);


--
-- Name: skumeter_metadata skumeter_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skumeter_metadata
    ADD CONSTRAINT skumeter_metadata_pkey PRIMARY KEY (id);


--
-- Name: skumeter_metadata skumeter_metadata_skumeter_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skumeter_metadata
    ADD CONSTRAINT skumeter_metadata_skumeter_key UNIQUE (skumeter);


--
-- Name: eqa_story_analysis_results story_analysis_results_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_story_analysis_results
    ADD CONSTRAINT story_analysis_results_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: eqa_test_cases test_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_test_cases
    ADD CONSTRAINT test_cases_pkey PRIMARY KEY (id);


--
-- Name: test_results test_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_results
    ADD CONSTRAINT test_results_pkey PRIMARY KEY (id);


--
-- Name: eqa_test_type_classifications test_type_classifications_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_test_type_classifications
    ADD CONSTRAINT test_type_classifications_pkey PRIMARY KEY (id);


--
-- Name: aws_s3_data_insights unique_bucket_region_account; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aws_s3_data_insights
    ADD CONSTRAINT unique_bucket_region_account UNIQUE (bucket_name, region, subaccount_id);


--
-- Name: schema_metadata unique_metadata; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_metadata
    ADD CONSTRAINT unique_metadata UNIQUE (schema_name, table_name, column_name, metadata_type);


--
-- Name: performance_metrics uq_performance_metrics_run_id; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.performance_metrics
    ADD CONSTRAINT uq_performance_metrics_run_id UNIQUE (run_id);


--
-- Name: performance_test_runs uq_performance_test_runs_run_id; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.performance_test_runs
    ADD CONSTRAINT uq_performance_test_runs_run_id UNIQUE (run_id);


--
-- Name: eqa_test_cases uq_test_cases_execution_tc; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_test_cases
    ADD CONSTRAINT uq_test_cases_execution_tc UNIQUE (execution_id, tc_id);


--
-- Name: eqa_test_type_classifications uq_test_type_classifications_exec_jira; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_test_type_classifications
    ADD CONSTRAINT uq_test_type_classifications_exec_jira UNIQUE (execution_id, jira_id);


--
-- Name: eqa_user_test_type_selections uq_user_test_type_selections_exec_jira; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_user_test_type_selections
    ADD CONSTRAINT uq_user_test_type_selections_exec_jira UNIQUE (execution_id, jira_id);


--
-- Name: users uq_users_tenant_email; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_users_tenant_email UNIQUE (tenant_id, email);


--
-- Name: users uq_users_tenant_user_id; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_users_tenant_user_id UNIQUE (tenant_id, user_id);


--
-- Name: users uq_users_tenant_user_name; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_users_tenant_user_name UNIQUE (tenant_id, user_name);


--
-- Name: eqa_user_test_type_selections user_test_type_selections_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.eqa_user_test_type_selections
    ADD CONSTRAINT user_test_type_selections_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_schema_metadata_column; Type: INDEX; Schema: focus; Owner: postgres
--

CREATE INDEX idx_schema_metadata_column ON focus.schema_metadata USING btree (schema_name, table_name, column_name);


--
-- Name: idx_schema_metadata_table; Type: INDEX; Schema: focus; Owner: postgres
--

CREATE INDEX idx_schema_metadata_table ON focus.schema_metadata USING btree (schema_name, table_name);


--
-- Name: aws_anomaly_account_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX aws_anomaly_account_date_idx ON public.aws_anomaly USING btree (account, anomaly_date);


--
-- Name: aws_anomaly_account_service_region_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX aws_anomaly_account_service_region_date_idx ON public.aws_anomaly USING btree (account, service_name, region, anomaly_date);


--
-- Name: aws_cost_anomaly_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX aws_cost_anomaly_date_idx ON public.aws_anomaly USING btree (anomaly_date);


--
-- Name: aws_cost_anomaly_service_region_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX aws_cost_anomaly_service_region_date_idx ON public.aws_anomaly USING btree (service_name, region, anomaly_date);


--
-- Name: aws_cost_anomaly_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX aws_cost_anomaly_type_idx ON public.aws_anomaly USING btree (anomaly_type);


--
-- Name: idx_agent_feedback_query_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_agent_feedback_query_id ON public.agent_feedback USING btree (query_id);


--
-- Name: idx_agent_feedback_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_agent_feedback_session_id ON public.agent_feedback USING btree (session_id);


--
-- Name: idx_agent_feedback_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_agent_feedback_tenant_id ON public.agent_feedback USING btree (tenant_id);


--
-- Name: idx_agent_feedback_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_agent_feedback_user_id ON public.agent_feedback USING btree (user_id);


--
-- Name: idx_aws_cost_anomaly_agent_output_agent_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_aws_cost_anomaly_agent_output_agent_type ON public.aws_cost_anomaly_agent_output USING btree (agent_type);


--
-- Name: idx_aws_cost_anomaly_agent_output_run_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_aws_cost_anomaly_agent_output_run_date ON public.aws_cost_anomaly_agent_output USING btree (ingestion_date);


--
-- Name: idx_aws_cost_anomaly_agent_output_service_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_aws_cost_anomaly_agent_output_service_name ON public.aws_cost_anomaly_agent_output USING btree (service_name);


--
-- Name: idx_aws_cost_anomaly_agent_output_severity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_aws_cost_anomaly_agent_output_severity ON public.aws_cost_anomaly_agent_output USING btree (severity);


--
-- Name: idx_bucket_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bucket_name ON public.aws_s3_data_insights USING btree (bucket_name);


--
-- Name: idx_bucket_region; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bucket_region ON public.aws_s3_data_insights USING btree (bucket_name, region);


--
-- Name: idx_cluster_resize_cluster_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cluster_resize_cluster_id ON public.databricks_cluster_resize_recommendation USING btree (cluster_id);


--
-- Name: idx_cluster_resize_year_month; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cluster_resize_year_month ON public.databricks_cluster_resize_recommendation USING btree (year, month);


--
-- Name: idx_conversation_session_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_conversation_session_user ON public.conversation_memory USING btree (session_id, user_id);


--
-- Name: idx_conversation_thread; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_conversation_thread ON public.conversation_memory USING btree (thread_id);


--
-- Name: idx_customers_region_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customers_region_id ON public.customers USING btree (region_id);


--
-- Name: idx_databricks_cluster_cost_cluster_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_cluster_cost_cluster_id ON public.databricks_cluster_cost USING btree (cluster_id);


--
-- Name: idx_databricks_cluster_cost_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_cluster_cost_tenant_id ON public.databricks_cluster_cost USING btree (tenant_id);


--
-- Name: idx_databricks_cluster_cost_usage_start; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_cluster_cost_usage_start ON public.databricks_cluster_cost USING btree (usage_start_time);


--
-- Name: idx_databricks_cluster_cost_workspace_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_cluster_cost_workspace_id ON public.databricks_cluster_cost USING btree (workspace_id);


--
-- Name: idx_databricks_job_cost_job_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_job_cost_job_id ON public.databricks_job_cost USING btree (job_id);


--
-- Name: idx_databricks_job_cost_period_start; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_job_cost_period_start ON public.databricks_job_cost USING btree (period_start_time);


--
-- Name: idx_databricks_job_cost_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_job_cost_tenant_id ON public.databricks_job_cost USING btree (tenant_id);


--
-- Name: idx_databricks_job_cost_workspace_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_job_cost_workspace_id ON public.databricks_job_cost USING btree (workspace_id);


--
-- Name: idx_databricks_query_cost_executed_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_query_cost_executed_by ON public.databricks_query_cost USING btree (executed_by);


--
-- Name: idx_databricks_query_cost_start_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_query_cost_start_time ON public.databricks_query_cost USING btree (start_time);


--
-- Name: idx_databricks_query_cost_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_query_cost_tenant_id ON public.databricks_query_cost USING btree (tenant_id);


--
-- Name: idx_databricks_query_cost_warehouse_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_query_cost_warehouse_id ON public.databricks_query_cost USING btree (warehouse_id);


--
-- Name: idx_databricks_query_cost_workspace_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_query_cost_workspace_id ON public.databricks_query_cost USING btree (workspace_id);


--
-- Name: idx_databricks_warehouse_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_warehouse_tenant_id ON public.databricks_warehouse_usage USING btree (tenant_id);


--
-- Name: idx_databricks_warehouse_usage_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_warehouse_usage_date ON public.databricks_warehouse_usage USING btree (usage_date);


--
-- Name: idx_databricks_warehouse_warehouse_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_warehouse_warehouse_id ON public.databricks_warehouse_usage USING btree (warehouse_id);


--
-- Name: idx_databricks_warehouse_workspace_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_databricks_warehouse_workspace_id ON public.databricks_warehouse_usage USING btree (workspace_id);


--
-- Name: idx_gen_ai_api_byod_data_username_batch; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_gen_ai_api_byod_data_username_batch ON public.gen_ai_api_byod_data USING btree (username, batch_id);


--
-- Name: idx_genai_dbx_raw_preprocessed_aggregated_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_genai_dbx_raw_preprocessed_aggregated_account_id ON public.genai_dbx_raw_preprocessed_aggregated USING btree (account_id);


--
-- Name: idx_genai_dbx_raw_preprocessed_aggregated_cluster_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_genai_dbx_raw_preprocessed_aggregated_cluster_id ON public.genai_dbx_raw_preprocessed_aggregated USING btree (cluster_id);


--
-- Name: idx_genai_dbx_raw_preprocessed_aggregated_record_inserted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_genai_dbx_raw_preprocessed_aggregated_record_inserted_at ON public.genai_dbx_raw_preprocessed_aggregated USING btree (record_inserted_at);


--
-- Name: idx_genai_dbx_raw_preprocessed_aggregated_workspace_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_genai_dbx_raw_preprocessed_aggregated_workspace_id ON public.genai_dbx_raw_preprocessed_aggregated USING btree (workspace_id);


--
-- Name: idx_genai_dbx_reccomendation_history_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_genai_dbx_reccomendation_history_account_id ON public.genai_dbx_reccomendation_history USING btree (account_id);


--
-- Name: idx_genai_dbx_reccomendation_history_archived_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_genai_dbx_reccomendation_history_archived_at ON public.genai_dbx_reccomendation_history USING btree (archived_at);


--
-- Name: idx_genai_dbx_reccomendation_history_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_genai_dbx_reccomendation_history_category ON public.genai_dbx_reccomendation_history USING btree (category);


--
-- Name: idx_genai_dbx_reccomendation_history_inserted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_genai_dbx_reccomendation_history_inserted_at ON public.genai_dbx_reccomendation_history USING btree (inserted_at);


--
-- Name: idx_genai_dbx_reccomendation_history_job_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_genai_dbx_reccomendation_history_job_id ON public.genai_dbx_reccomendation_history USING btree (job_id);


--
-- Name: idx_genai_dbx_reccomendation_history_original_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_genai_dbx_reccomendation_history_original_id ON public.genai_dbx_reccomendation_history USING btree (original_id);


--
-- Name: idx_genai_dbx_reccomendation_history_workspace_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_genai_dbx_reccomendation_history_workspace_id ON public.genai_dbx_reccomendation_history USING btree (workspace_id);


--
-- Name: idx_job_recommendation_cluster_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_job_recommendation_cluster_id ON public.databricks_job_recommendation USING btree (cluster_id);


--
-- Name: idx_job_recommendation_job_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_job_recommendation_job_id ON public.databricks_job_recommendation USING btree (job_id);


--
-- Name: idx_job_recommendation_workspace_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_job_recommendation_workspace_id ON public.databricks_job_recommendation USING btree (workspace_id);


--
-- Name: idx_last_updated; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_last_updated ON public.aws_s3_data_insights USING btree (last_updated);


--
-- Name: idx_order_items_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);


--
-- Name: idx_order_items_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_product_id ON public.order_items USING btree (product_id);


--
-- Name: idx_orders_agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_agent_id ON public.orders USING btree (agent_id);


--
-- Name: idx_orders_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_customer_id ON public.orders USING btree (customer_id);


--
-- Name: idx_orders_order_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_order_date ON public.orders USING btree (order_date);


--
-- Name: idx_orders_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_status ON public.orders USING btree (order_status);


--
-- Name: idx_products_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_category_id ON public.products USING btree (category_id);


--
-- Name: idx_region; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_region ON public.aws_s3_data_insights USING btree (region);


--
-- Name: idx_sales_agents_region_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sales_agents_region_id ON public.sales_agents USING btree (region_id);


--
-- Name: idx_schema_metadata_column; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_schema_metadata_column ON public.schema_metadata USING btree (schema_name, table_name, column_name);


--
-- Name: idx_schema_metadata_table; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_schema_metadata_table ON public.schema_metadata USING btree (schema_name, table_name);


--
-- Name: idx_subaccount_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subaccount_id ON public.aws_s3_data_insights USING btree (subaccount_id);


--
-- Name: idx_user_email; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX idx_user_email ON public.users USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: ix_agent_feedback_query_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agent_feedback_query_id ON public.agent_feedback USING btree (query_id);


--
-- Name: ix_agent_feedback_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agent_feedback_session_id ON public.agent_feedback USING btree (session_id);


--
-- Name: ix_agent_feedback_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agent_feedback_tenant_id ON public.agent_feedback USING btree (tenant_id);


--
-- Name: ix_agent_feedback_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_agent_feedback_user_id ON public.agent_feedback USING btree (user_id);


--
-- Name: ix_auth_sessions_refresh_token_hash; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE UNIQUE INDEX ix_auth_sessions_refresh_token_hash ON public.auth_sessions USING btree (refresh_token_hash);


--
-- Name: ix_email_verification_tokens_token; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE UNIQUE INDEX ix_email_verification_tokens_token ON public.email_verification_tokens USING btree (token);


--
-- Name: ix_password_reset_tokens_token; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE UNIQUE INDEX ix_password_reset_tokens_token ON public.password_reset_tokens USING btree (token);


--
-- Name: ix_public_jira_attachments_execution_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_jira_attachments_execution_id ON public.eqa_jira_attachments USING btree (execution_id);


--
-- Name: ix_public_jira_attachments_issue_key; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_jira_attachments_issue_key ON public.eqa_jira_attachments USING btree (issue_key);


--
-- Name: ix_public_jira_generated_stories_execution_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_jira_generated_stories_execution_id ON public.eqa_jira_generated_stories USING btree (execution_id);


--
-- Name: ix_public_jira_generated_stories_issue_key; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_jira_generated_stories_issue_key ON public.eqa_jira_generated_stories USING btree (issue_key);


--
-- Name: ix_public_jira_scrape_results_execution_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_jira_scrape_results_execution_id ON public.eqa_jira_scrape_results USING btree (execution_id);


--
-- Name: ix_public_jira_scrape_results_issue_key; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_jira_scrape_results_issue_key ON public.eqa_jira_scrape_results USING btree (issue_key);


--
-- Name: ix_public_performance_metrics_run_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_performance_metrics_run_id ON public.performance_metrics USING btree (run_id);


--
-- Name: ix_public_performance_test_runs_run_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_performance_test_runs_run_id ON public.performance_test_runs USING btree (run_id);


--
-- Name: ix_public_story_analysis_results_execution_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_story_analysis_results_execution_id ON public.eqa_story_analysis_results USING btree (execution_id);


--
-- Name: ix_public_story_analysis_results_issue_key; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_story_analysis_results_issue_key ON public.eqa_story_analysis_results USING btree (issue_key);


--
-- Name: ix_public_story_analysis_results_story_record_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_story_analysis_results_story_record_id ON public.eqa_story_analysis_results USING btree (story_record_id);


--
-- Name: ix_public_test_cases_execution_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_test_cases_execution_id ON public.eqa_test_cases USING btree (execution_id);


--
-- Name: ix_public_test_cases_jira_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_test_cases_jira_id ON public.eqa_test_cases USING btree (jira_id);


--
-- Name: ix_public_test_cases_tc_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_test_cases_tc_id ON public.eqa_test_cases USING btree (tc_id);


--
-- Name: ix_public_test_type_classifications_execution_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_test_type_classifications_execution_id ON public.eqa_test_type_classifications USING btree (execution_id);


--
-- Name: ix_public_test_type_classifications_jira_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_test_type_classifications_jira_id ON public.eqa_test_type_classifications USING btree (jira_id);


--
-- Name: ix_public_user_test_type_selections_execution_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_user_test_type_selections_execution_id ON public.eqa_user_test_type_selections USING btree (execution_id);


--
-- Name: ix_public_user_test_type_selections_jira_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_public_user_test_type_selections_jira_id ON public.eqa_user_test_type_selections USING btree (jira_id);


--
-- Name: ix_refresh_tokens_token_hash; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE UNIQUE INDEX ix_refresh_tokens_token_hash ON public.refresh_tokens USING btree (token_hash);


--
-- Name: ix_tenants_domain; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE UNIQUE INDEX ix_tenants_domain ON public.tenants USING btree (domain);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_tenant_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_users_tenant_id ON public.users USING btree (tenant_id);


--
-- Name: ix_users_user_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_users_user_id ON public.users USING btree (user_id);


--
-- Name: ix_users_user_name; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE INDEX ix_users_user_name ON public.users USING btree (user_name);


--
-- Name: uq_athena_reco; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_athena_reco ON public.athena_recommendation USING btree (database_name, table_name, recommendation);


--
-- Name: ux_tenants_tenant_id; Type: INDEX; Schema: public; Owner: prism-web
--

CREATE UNIQUE INDEX ux_tenants_tenant_id ON public.tenants USING btree (tenant_id);


--
-- Name: genai_dbx_reccomendation trigger_archive_recommendation_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_archive_recommendation_delete BEFORE DELETE ON public.genai_dbx_reccomendation FOR EACH ROW EXECUTE FUNCTION public.archive_recommendation();


--
-- Name: genai_dbx_reccomendation trigger_archive_recommendation_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_archive_recommendation_update BEFORE UPDATE ON public.genai_dbx_reccomendation FOR EACH ROW EXECUTE FUNCTION public.archive_recommendation();


--
-- Name: genai_dbx_reccomendation trigger_update_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_updated_at BEFORE UPDATE ON public.genai_dbx_reccomendation FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: auth_sessions auth_sessions_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);


--
-- Name: customers customers_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(region_id);


--
-- Name: email_verification_tokens email_verification_tokens_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: orders orders_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.sales_agents(agent_id);


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- Name: password_reset_tokens password_reset_tokens_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id);


--
-- Name: refresh_tokens refresh_tokens_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);


--
-- Name: sales_agents sales_agents_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_agents
    ADD CONSTRAINT sales_agents_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(region_id);


--
-- Name: users users_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prism-web
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA public TO finops;
GRANT USAGE ON SCHEMA public TO "prism-DI";


--
-- Name: TABLE aws_s3_recommendation_data; Type: ACL; Schema: focus; Owner: postgres
--

GRANT SELECT ON TABLE focus.aws_s3_recommendation_data TO "prism-DI";


--
-- Name: TABLE schema_metadata; Type: ACL; Schema: focus; Owner: postgres
--

GRANT SELECT ON TABLE focus.schema_metadata TO "prism-DI";


--
-- Name: TABLE agent_feedback; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.agent_feedback TO "prism-DI";
GRANT ALL ON TABLE public.agent_feedback TO "prism-web";


--
-- Name: TABLE orders; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.orders TO "prism-web";
GRANT SELECT ON TABLE public.orders TO "prism-DI";


--
-- Name: TABLE regions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.regions TO "prism-web";
GRANT SELECT ON TABLE public.regions TO "prism-DI";


--
-- Name: TABLE sales_agents; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.sales_agents TO "prism-web";
GRANT SELECT ON TABLE public.sales_agents TO "prism-DI";


--
-- Name: TABLE agent_performance; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.agent_performance TO "prism-web";
GRANT SELECT ON TABLE public.agent_performance TO "prism-DI";


--
-- Name: TABLE alembic_version; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.alembic_version TO "prism-DI";


--
-- Name: TABLE athena_query_recommendation; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.athena_query_recommendation TO finops;
GRANT SELECT,REFERENCES,TRIGGER ON TABLE public.athena_query_recommendation TO "prism-web";
GRANT SELECT ON TABLE public.athena_query_recommendation TO "prism-DI";


--
-- Name: TABLE athena_recommendation; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.athena_recommendation TO finops;
GRANT SELECT,REFERENCES,TRIGGER ON TABLE public.athena_recommendation TO "prism-web";
GRANT SELECT ON TABLE public.athena_recommendation TO "prism-DI";


--
-- Name: TABLE audit_logs; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.audit_logs TO "prism-DI";


--
-- Name: TABLE auth_sessions; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.auth_sessions TO "prism-DI";


--
-- Name: TABLE aws_anomaly; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.aws_anomaly TO finops;
GRANT SELECT,REFERENCES,TRIGGER ON TABLE public.aws_anomaly TO "prism-web";
GRANT SELECT ON TABLE public.aws_anomaly TO "prism-DI";


--
-- Name: TABLE aws_cis_python_dst; Type: ACL; Schema: public; Owner: prism-web
--

GRANT ALL ON TABLE public.aws_cis_python_dst TO finops;
GRANT SELECT ON TABLE public.aws_cis_python_dst TO "prism-DI";


--
-- Name: TABLE aws_cloudwatch_observations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.aws_cloudwatch_observations TO "prism-DI";
GRANT SELECT ON TABLE public.aws_cloudwatch_observations TO "prism-web";


--
-- Name: TABLE aws_focus_cost_data; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_focus_cost_data TO "prism-web";
GRANT SELECT ON TABLE public.aws_focus_cost_data TO "prism-DI";
GRANT ALL ON TABLE public.aws_focus_cost_data TO finops;


--
-- Name: TABLE aws_cost_20260902; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_cost_20260902 TO "prism-web";
GRANT SELECT ON TABLE public.aws_cost_20260902 TO "prism-DI";


--
-- Name: TABLE aws_cost_20261002; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_cost_20261002 TO "prism-web";
GRANT SELECT ON TABLE public.aws_cost_20261002 TO "prism-DI";


--
-- Name: TABLE aws_cost_focus_historical_data; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_cost_focus_historical_data TO "prism-web";
GRANT SELECT ON TABLE public.aws_cost_focus_historical_data TO "prism-DI";


--
-- Name: TABLE aws_focus_cost_current; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_focus_cost_current TO "prism-web";
GRANT SELECT ON TABLE public.aws_focus_cost_current TO "prism-DI";


--
-- Name: TABLE aws_cost_analysis_current_historical; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_cost_analysis_current_historical TO "prism-web";
GRANT SELECT ON TABLE public.aws_cost_analysis_current_historical TO "prism-DI";


--
-- Name: TABLE aws_cost_analysis_current_historical_1; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_cost_analysis_current_historical_1 TO "prism-web";
GRANT SELECT ON TABLE public.aws_cost_analysis_current_historical_1 TO "prism-DI";


--
-- Name: TABLE aws_focus_cost_previous; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_focus_cost_previous TO "prism-web";
GRANT SELECT ON TABLE public.aws_focus_cost_previous TO "prism-DI";


--
-- Name: TABLE aws_cost_analysis_current_previous; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_cost_analysis_current_previous TO "prism-web";
GRANT SELECT ON TABLE public.aws_cost_analysis_current_previous TO "prism-DI";


--
-- Name: TABLE aws_cost_anomaly_agent_output; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_cost_anomaly_agent_output TO "prism-web";
GRANT SELECT ON TABLE public.aws_cost_anomaly_agent_output TO "prism-DI";


--
-- Name: TABLE aws_focus_cost_current_mock; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_focus_cost_current_mock TO "prism-web";
GRANT SELECT ON TABLE public.aws_focus_cost_current_mock TO "prism-DI";


--
-- Name: TABLE aws_forecasting_python_dst; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.aws_forecasting_python_dst TO "prism-DI";
GRANT ALL ON TABLE public.aws_forecasting_python_dst TO finops;


--
-- Name: TABLE aws_obp_python_dst; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT,INSERT,DELETE,TRUNCATE,UPDATE ON TABLE public.aws_obp_python_dst TO finops;
GRANT SELECT ON TABLE public.aws_obp_python_dst TO "prism-DI";


--
-- Name: TABLE aws_recommendation_consolidate; Type: ACL; Schema: public; Owner: finops
--

GRANT SELECT,REFERENCES,TRIGGER ON TABLE public.aws_recommendation_consolidate TO "prism-web";
GRANT SELECT ON TABLE public.aws_recommendation_consolidate TO "prism-DI";


--
-- Name: TABLE aws_recommendations_python_dst; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.aws_recommendations_python_dst TO "prism-DI";


--
-- Name: TABLE aws_resource_changes; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.aws_resource_changes TO "prism-DI";


--
-- Name: TABLE aws_s3_data_insights; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_s3_data_insights TO "prism-web";
GRANT SELECT ON TABLE public.aws_s3_data_insights TO "prism-DI";


--
-- Name: TABLE aws_s3_data_insights_mock; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.aws_s3_data_insights_mock TO "prism-web";
GRANT SELECT ON TABLE public.aws_s3_data_insights_mock TO "prism-DI";


--
-- Name: TABLE aws_s3_observations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.aws_s3_observations TO "prism-DI";
GRANT SELECT ON TABLE public.aws_s3_observations TO "prism-web";


--
-- Name: TABLE awscostdetails_current_month; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.awscostdetails_current_month TO "prism-DI";


--
-- Name: TABLE awscostdetails_previous_month; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.awscostdetails_previous_month TO "prism-DI";


--
-- Name: TABLE azure_focus_cost_data; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.azure_focus_cost_data TO "prism-web";
GRANT SELECT ON TABLE public.azure_focus_cost_data TO "prism-DI";


--
-- Name: TABLE best_practices; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.best_practices TO "prism-web";
GRANT SELECT ON TABLE public.best_practices TO "prism-DI";


--
-- Name: TABLE categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.categories TO "prism-web";
GRANT SELECT ON TABLE public.categories TO "prism-DI";


--
-- Name: TABLE ce_logs; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.ce_logs TO "prism-web";
GRANT SELECT ON TABLE public.ce_logs TO "prism-DI";


--
-- Name: TABLE ce_metrics; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.ce_metrics TO "prism-web";
GRANT SELECT ON TABLE public.ce_metrics TO "prism-DI";


--
-- Name: TABLE ce_traces; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.ce_traces TO "prism-web";
GRANT SELECT ON TABLE public.ce_traces TO "prism-DI";


--
-- Name: TABLE conversation_memory; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.conversation_memory TO "prism-DI";
GRANT SELECT ON TABLE public.conversation_memory TO "prism-web";


--
-- Name: TABLE cost_analysis_0910; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.cost_analysis_0910 TO "prism-web";
GRANT SELECT ON TABLE public.cost_analysis_0910 TO "prism-DI";


--
-- Name: TABLE cronjob_config; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.cronjob_config TO finops;
GRANT SELECT ON TABLE public.cronjob_config TO "prism-DI";
GRANT SELECT ON TABLE public.cronjob_config TO "prism-web";


--
-- Name: TABLE customers; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.customers TO "prism-web";
GRANT SELECT ON TABLE public.customers TO "prism-DI";


--
-- Name: TABLE databricks_cloud_cost; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_cloud_cost TO "prism-web";
GRANT SELECT ON TABLE public.databricks_cloud_cost TO "prism-DI";


--
-- Name: TABLE databricks_cluster_cost; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.databricks_cluster_cost TO "prism-DI";
GRANT ALL ON TABLE public.databricks_cluster_cost TO "prism-web";


--
-- Name: TABLE databricks_cluster_cost_current; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_cluster_cost_current TO "prism-web";
GRANT SELECT ON TABLE public.databricks_cluster_cost_current TO "prism-DI";


--
-- Name: TABLE databricks_cluster_cost_previous; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_cluster_cost_previous TO "prism-web";
GRANT SELECT ON TABLE public.databricks_cluster_cost_previous TO "prism-DI";


--
-- Name: TABLE databricks_cluster_cost_comparison; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_cluster_cost_comparison TO "prism-web";
GRANT SELECT ON TABLE public.databricks_cluster_cost_comparison TO "prism-DI";


--
-- Name: TABLE databricks_cluster_idle_time; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.databricks_cluster_idle_time TO "prism-DI";
GRANT ALL ON TABLE public.databricks_cluster_idle_time TO "prism-web";


--
-- Name: TABLE databricks_cluster_optimization_recommendation; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.databricks_cluster_optimization_recommendation TO "prism-DI";
GRANT ALL ON TABLE public.databricks_cluster_optimization_recommendation TO "prism-web";


--
-- Name: TABLE databricks_cluster_performance; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.databricks_cluster_performance TO "prism-DI";
GRANT ALL ON TABLE public.databricks_cluster_performance TO "prism-web";


--
-- Name: TABLE databricks_cluster_resize_recommendation; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.databricks_cluster_resize_recommendation TO "prism-DI";
GRANT ALL ON TABLE public.databricks_cluster_resize_recommendation TO "prism-web";


--
-- Name: TABLE databricks_generated_optimized_queries; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_generated_optimized_queries TO "prism-web";
GRANT SELECT ON TABLE public.databricks_generated_optimized_queries TO "prism-DI";


--
-- Name: TABLE databricks_job_anomaly; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_job_anomaly TO "prism-web";
GRANT SELECT ON TABLE public.databricks_job_anomaly TO "prism-DI";


--
-- Name: TABLE databricks_job_cost; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.databricks_job_cost TO "prism-DI";
GRANT ALL ON TABLE public.databricks_job_cost TO "prism-web";


--
-- Name: TABLE databricks_job_cost_current; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_job_cost_current TO "prism-web";
GRANT SELECT ON TABLE public.databricks_job_cost_current TO "prism-DI";


--
-- Name: TABLE databricks_job_cost_previous; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_job_cost_previous TO "prism-web";
GRANT SELECT ON TABLE public.databricks_job_cost_previous TO "prism-DI";


--
-- Name: TABLE databricks_job_cost_comparison; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_job_cost_comparison TO "prism-web";
GRANT SELECT ON TABLE public.databricks_job_cost_comparison TO "prism-DI";


--
-- Name: TABLE databricks_job_recommendation; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.databricks_job_recommendation TO "prism-DI";
GRANT ALL ON TABLE public.databricks_job_recommendation TO "prism-web";


--
-- Name: TABLE databricks_query_cost; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.databricks_query_cost TO "prism-DI";
GRANT ALL ON TABLE public.databricks_query_cost TO "prism-web";


--
-- Name: TABLE databricks_query_cost_current; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_query_cost_current TO "prism-web";
GRANT SELECT ON TABLE public.databricks_query_cost_current TO "prism-DI";


--
-- Name: TABLE databricks_query_cost_previous; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_query_cost_previous TO "prism-web";
GRANT SELECT ON TABLE public.databricks_query_cost_previous TO "prism-DI";


--
-- Name: TABLE databricks_query_cost_comparison; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_query_cost_comparison TO "prism-web";
GRANT SELECT ON TABLE public.databricks_query_cost_comparison TO "prism-DI";


--
-- Name: TABLE databricks_query_issues; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_query_issues TO "prism-web";
GRANT SELECT ON TABLE public.databricks_query_issues TO "prism-DI";


--
-- Name: TABLE databricks_query_metadata; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_query_metadata TO "prism-web";
GRANT SELECT ON TABLE public.databricks_query_metadata TO "prism-DI";


--
-- Name: TABLE databricks_query_optimization_recommendations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_query_optimization_recommendations TO "prism-web";
GRANT SELECT ON TABLE public.databricks_query_optimization_recommendations TO "prism-DI";


--
-- Name: TABLE databricks_warehouse_usage; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.databricks_warehouse_usage TO "prism-DI";
GRANT ALL ON TABLE public.databricks_warehouse_usage TO "prism-web";


--
-- Name: TABLE databricks_query_warehouse_current; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_query_warehouse_current TO "prism-web";
GRANT SELECT ON TABLE public.databricks_query_warehouse_current TO "prism-DI";


--
-- Name: TABLE databricks_query_warehouse_previous; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_query_warehouse_previous TO "prism-web";
GRANT SELECT ON TABLE public.databricks_query_warehouse_previous TO "prism-DI";


--
-- Name: TABLE databricks_query_warehouse_comparison; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_query_warehouse_comparison TO "prism-web";
GRANT SELECT ON TABLE public.databricks_query_warehouse_comparison TO "prism-DI";


--
-- Name: TABLE databricks_table_metadata; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_table_metadata TO "prism-web";
GRANT SELECT ON TABLE public.databricks_table_metadata TO "prism-DI";


--
-- Name: TABLE databricks_warehouse_cost_current; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_warehouse_cost_current TO "prism-web";
GRANT SELECT ON TABLE public.databricks_warehouse_cost_current TO "prism-DI";


--
-- Name: TABLE databricks_unified_cost_current; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_unified_cost_current TO "prism-web";
GRANT SELECT ON TABLE public.databricks_unified_cost_current TO "prism-DI";


--
-- Name: TABLE databricks_warehouse_cost_previous; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_warehouse_cost_previous TO "prism-web";
GRANT SELECT ON TABLE public.databricks_warehouse_cost_previous TO "prism-DI";


--
-- Name: TABLE databricks_warehouse_cost_comparison; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.databricks_warehouse_cost_comparison TO "prism-web";
GRANT SELECT ON TABLE public.databricks_warehouse_cost_comparison TO "prism-DI";


--
-- Name: TABLE email_verification_tokens; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.email_verification_tokens TO "prism-DI";


--
-- Name: TABLE environment_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.environment_details TO "prism-web";
GRANT SELECT ON TABLE public.environment_details TO "prism-DI";


--
-- Name: TABLE focus_metadata; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.focus_metadata TO "prism-web";
GRANT SELECT ON TABLE public.focus_metadata TO "prism-DI";


--
-- Name: TABLE gen_ai_api_byod_data; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.gen_ai_api_byod_data TO "prism-web";
GRANT SELECT ON TABLE public.gen_ai_api_byod_data TO "prism-DI";


--
-- Name: TABLE gen_ai_api_byod_dbx_reccomendation; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.gen_ai_api_byod_dbx_reccomendation TO "prism-web";
GRANT SELECT ON TABLE public.gen_ai_api_byod_dbx_reccomendation TO "prism-DI";


--
-- Name: TABLE genai_dbx_raw_preprocessed; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.genai_dbx_raw_preprocessed TO "prism-web";
GRANT SELECT ON TABLE public.genai_dbx_raw_preprocessed TO "prism-DI";


--
-- Name: TABLE genai_dbx_raw_preprocessed_aggregated; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.genai_dbx_raw_preprocessed_aggregated TO "prism-web";
GRANT SELECT ON TABLE public.genai_dbx_raw_preprocessed_aggregated TO "prism-DI";


--
-- Name: TABLE genai_dbx_reccomendation; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.genai_dbx_reccomendation TO "prism-web";
GRANT SELECT ON TABLE public.genai_dbx_reccomendation TO "prism-DI";


--
-- Name: TABLE genai_dbx_reccomendation_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.genai_dbx_reccomendation_history TO "prism-web";
GRANT SELECT ON TABLE public.genai_dbx_reccomendation_history TO "prism-DI";


--
-- Name: TABLE generated_optimized_queries; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.generated_optimized_queries TO "prism-DI";
GRANT SELECT ON TABLE public.generated_optimized_queries TO "prism-web";


--
-- Name: TABLE glue_recommendations; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.glue_recommendations TO finops;
GRANT SELECT,REFERENCES,TRIGGER ON TABLE public.glue_recommendations TO "prism-web";
GRANT SELECT ON TABLE public.glue_recommendations TO "prism-DI";


--
-- Name: TABLE monthly_sales_trend; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.monthly_sales_trend TO "prism-web";
GRANT SELECT ON TABLE public.monthly_sales_trend TO "prism-DI";


--
-- Name: TABLE order_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.order_items TO "prism-web";
GRANT SELECT ON TABLE public.order_items TO "prism-DI";


--
-- Name: TABLE password_reset_tokens; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.password_reset_tokens TO "prism-DI";


--
-- Name: TABLE platform_config_json; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.platform_config_json TO "prism-web";
GRANT ALL ON TABLE public.platform_config_json TO finops;
GRANT SELECT ON TABLE public.platform_config_json TO "prism-DI";


--
-- Name: SEQUENCE platform_config_json_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.platform_config_json_id_seq TO finops;


--
-- Name: TABLE products; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.products TO "prism-web";
GRANT SELECT ON TABLE public.products TO "prism-DI";


--
-- Name: TABLE product_sales_performance; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.product_sales_performance TO "prism-web";
GRANT SELECT ON TABLE public.product_sales_performance TO "prism-DI";


--
-- Name: TABLE query_issues; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.query_issues TO "prism-DI";
GRANT SELECT ON TABLE public.query_issues TO "prism-web";


--
-- Name: TABLE query_metadata; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.query_metadata TO "prism-web";
GRANT SELECT ON TABLE public.query_metadata TO "prism-DI";


--
-- Name: TABLE query_optimization_recommendations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.query_optimization_recommendations TO "prism-DI";
GRANT SELECT ON TABLE public.query_optimization_recommendations TO "prism-web";


--
-- Name: TABLE redshift_cluster_metrics; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.redshift_cluster_metrics TO finops;
GRANT SELECT,REFERENCES,TRIGGER ON TABLE public.redshift_cluster_metrics TO "prism-web";
GRANT SELECT ON TABLE public.redshift_cluster_metrics TO "prism-DI";


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.refresh_tokens TO "prism-DI";


--
-- Name: TABLE sage_maker_data; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.sage_maker_data TO "prism-web";
GRANT SELECT ON TABLE public.sage_maker_data TO "prism-DI";
GRANT ALL ON TABLE public.sage_maker_data TO finops;


--
-- Name: TABLE sales_summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.sales_summary TO "prism-web";
GRANT SELECT ON TABLE public.sales_summary TO "prism-DI";


--
-- Name: TABLE schema_metadata; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.schema_metadata TO "prism-DI";
GRANT SELECT ON TABLE public.schema_metadata TO "prism-web";


--
-- Name: TABLE skumeter_metadata; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.skumeter_metadata TO "prism-web";
GRANT SELECT ON TABLE public.skumeter_metadata TO "prism-DI";


--
-- Name: TABLE table_metadata; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.table_metadata TO "prism-web";
GRANT SELECT ON TABLE public.table_metadata TO "prism-DI";


--
-- Name: TABLE temp_databricks_query_warehouse_current; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.temp_databricks_query_warehouse_current TO "prism-web";
GRANT SELECT ON TABLE public.temp_databricks_query_warehouse_current TO "prism-DI";


--
-- Name: TABLE tenants; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.tenants TO "prism-DI";


--
-- Name: TABLE test_results; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.test_results TO "prism-DI";
GRANT SELECT ON TABLE public.test_results TO "prism-web";


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: prism-web
--

GRANT SELECT ON TABLE public.users TO "prism-DI";


--
-- Name: TABLE v_databricks_current_day_cost; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.v_databricks_current_day_cost TO "prism-web";
GRANT SELECT ON TABLE public.v_databricks_current_day_cost TO "prism-DI";


--
-- Name: TABLE v_databricks_current_day_cost_insights; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.v_databricks_current_day_cost_insights TO "prism-web";
GRANT SELECT ON TABLE public.v_databricks_current_day_cost_insights TO "prism-DI";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES  TO "prism-DI";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT SELECT,INSERT,UPDATE ON TABLES  TO "prism-web";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT SELECT ON TABLES  TO "prism-DI";


--
-- PostgreSQL database dump complete
--
-- public.ce_llm_calls definition

-- Drop table

-- DROP TABLE public.ce_llm_calls;

CREATE TABLE public.ce_llm_calls (
	call_id text NOT NULL,
	trace_id text NULL,
	span_id text NULL,
	request_id text NULL,
	session_id text NULL,
	iteration int4 DEFAULT 1 NOT NULL,
	service_name text DEFAULT ''::text NOT NULL,
	tool_name text DEFAULT ''::text NOT NULL,
	caller_type text DEFAULT ''::text NOT NULL,
	model text DEFAULT ''::text NOT NULL,
	temperature float4 DEFAULT 0 NOT NULL,
	max_tokens int8 DEFAULT 0 NOT NULL,
	call_timestamp timestamptz NULL,
	latency_ms float4 NULL,
	prompt_tokens int8 DEFAULT 0 NOT NULL,
	completion_tokens int8 DEFAULT 0 NOT NULL,
	total_tokens int8 DEFAULT 0 NOT NULL,
	cost_usd float8 DEFAULT 0 NOT NULL,
	cost_per_1k_prompt_usd float8 DEFAULT 0 NOT NULL,
	cost_per_1k_completion_usd float8 DEFAULT 0 NOT NULL,
	finish_reason text DEFAULT ''::text NOT NULL,
	status text DEFAULT 'OK'::text NOT NULL,
	error_message text NULL,
	retry_attempt int2 DEFAULT 1 NOT NULL,
	retry_reason text NULL,
	environment text DEFAULT ''::text NOT NULL,
	insertion_time timestamptz DEFAULT now() NOT NULL,
	application varchar NULL,
	CONSTRAINT test_ce_llm_calls_pkey PRIMARY KEY (call_id)
);


-- public.ce_traces definition

-- Drop table

-- DROP TABLE public.ce_traces;

CREATE TABLE public.ce_traces (
	trace_id text NOT NULL,
	span_id text NOT NULL,
	parent_span_id text NULL,
	"name" text DEFAULT ''::text NOT NULL,
	kind int2 DEFAULT 0 NOT NULL,
	start_time timestamptz NULL,
	end_time timestamptz NULL,
	duration_ms float4 NULL,
	status text DEFAULT 'OK'::text NOT NULL,
	error_message text NULL,
	service_name text DEFAULT ''::text NOT NULL,
	environment text DEFAULT ''::text NOT NULL,
	"attributes" text DEFAULT '{}'::text NOT NULL,
	request_id text NULL,
	session_id text NULL,
	insertion_time timestamptz DEFAULT now() NOT NULL,
	"user" text DEFAULT 'system'::text NOT NULL,
	tags _text DEFAULT '{}'::text[] NOT NULL,
	"output" text NULL,
	application varchar NULL,
	CONSTRAINT test_ce_traces_pkey PRIMARY KEY (span_id)
);


-- DROP FUNCTION public.get_llm_session_summary(text, timestamptz, timestamptz, _text, _text, _text, _text);

CREATE OR REPLACE FUNCTION public.get_llm_session_summary(time_range text, from_ts timestamp with time zone DEFAULT NULL::timestamp with time zone, to_ts timestamp with time zone DEFAULT NULL::timestamp with time zone, providers text[] DEFAULT NULL::text[], models text[] DEFAULT NULL::text[], applications text[] DEFAULT NULL::text[], components text[] DEFAULT NULL::text[])
 RETURNS jsonb
 LANGUAGE sql
AS $function$
WITH p AS (
  SELECT
    lower(coalesce(time_range, 'last_3_months')) AS time_range,
    from_ts AS from_ts,
    to_ts   AS to_ts,
    coalesce(providers,    ARRAY[]::text[]) AS providers,
    coalesce(models,       ARRAY[]::text[]) AS models,
    coalesce(applications, ARRAY[]::text[]) AS applications,
    coalesce(components,   ARRAY[]::text[]) AS components
),
b AS (
  SELECT
    CASE p.time_range
      WHEN 'last_week'     THEN now() - interval '7 days'
      WHEN 'last_month'    THEN date_trunc('month', now()) - interval '1 month'
      WHEN 'last_3_months' THEN now() - interval '90 days'
      WHEN 'last_6_months' THEN now() - interval '180 days'
      WHEN 'custom'        THEN p.from_ts
      ELSE now() - interval '90 days'
    END AS start_ts,

    CASE p.time_range
      WHEN 'last_month' THEN date_trunc('month', now())
      WHEN 'custom'     THEN p.to_ts
      ELSE now()
    END AS end_ts,

    p.time_range,
    p.providers,
    p.models,
    p.applications,
    p.components
  FROM p
),
rows_enriched AS (
  SELECT
    c.session_id,
    c.trace_id,
    c.span_id,
    c.model,
    c.service_name,
    c.tool_name,
    lower((regexp_match(coalesce(c.model, ''), '^([a-zA-Z]+)'))[1]) AS provider_key
  FROM public.ce_llm_calls c
  CROSS JOIN b
  WHERE c.insertion_time IS NOT NULL
    AND (b.time_range <> 'custom' OR (b.start_ts IS NOT NULL AND b.end_ts IS NOT NULL))
    AND c.insertion_time >= (b.start_ts AT TIME ZONE 'UTC')
    AND c.insertion_time <  (b.end_ts   AT TIME ZONE 'UTC')
),
filtered AS (
  SELECT r.*
  FROM rows_enriched r
  CROSS JOIN b
  WHERE
    (cardinality(b.providers) = 0 OR r.provider_key = ANY(b.providers))
    AND (cardinality(b.models) = 0 OR r.model = ANY(b.models))
    AND (cardinality(b.applications) = 0 OR r.service_name = ANY(b.applications))
    AND (cardinality(b.components) = 0 OR r.tool_name = ANY(b.components))
),
totals AS (
  SELECT
    COUNT(DISTINCT session_id) FILTER (WHERE session_id IS NOT NULL) AS total_sessions,
    COUNT(DISTINCT trace_id)   FILTER (WHERE trace_id   IS NOT NULL) AS total_traces,
    COUNT(DISTINCT span_id)    FILTER (WHERE span_id    IS NOT NULL) AS total_span_ids
  FROM filtered
),
by_tool AS (
  SELECT
    coalesce(tool_name, 'Unknown') AS tool_name,
    COUNT(DISTINCT session_id) FILTER (WHERE session_id IS NOT NULL) AS sessions,
    COUNT(DISTINCT trace_id)   FILTER (WHERE trace_id   IS NOT NULL) AS traces,
    COUNT(DISTINCT span_id)    FILTER (WHERE span_id    IS NOT NULL) AS spans
  FROM filtered
  GROUP BY 1
  ORDER BY sessions DESC
)
SELECT jsonb_build_object(
  'totals', (SELECT to_jsonb(totals) FROM totals),
  'by_tool', COALESCE((SELECT jsonb_agg(to_jsonb(by_tool)) FROM by_tool), '[]'::jsonb)
);
$function$
;

-- DROP FUNCTION public.get_llm_session_trend(text, text, timestamptz, timestamptz, _text, _text, _text, _text);

CREATE OR REPLACE FUNCTION public.get_llm_session_trend(bucket_type text, time_range text, from_ts timestamp with time zone DEFAULT NULL::timestamp with time zone, to_ts timestamp with time zone DEFAULT NULL::timestamp with time zone, providers text[] DEFAULT NULL::text[], models text[] DEFAULT NULL::text[], applications text[] DEFAULT NULL::text[], components text[] DEFAULT NULL::text[])
 RETURNS TABLE(bucket_date date, unique_sessions bigint, unique_traces bigint, unique_span_ids bigint)
 LANGUAGE sql
AS $function$
WITH p AS (
  SELECT
    lower(coalesce(bucket_type, 'daily')) AS bucket_type,
    lower(coalesce(time_range, 'last_3_months')) AS time_range,
    from_ts AS from_ts,
    to_ts   AS to_ts,
    coalesce(providers,    ARRAY[]::text[]) AS providers,
    coalesce(models,       ARRAY[]::text[]) AS models,
    coalesce(applications, ARRAY[]::text[]) AS applications,
    coalesce(components,   ARRAY[]::text[]) AS components
),
b AS (
  SELECT
    -- Time window selection
    CASE p.time_range
      WHEN 'last_week' THEN now() - interval '7 days'

      -- ✅ calendar previous month: [start_prev_month, start_this_month)
      WHEN 'last_month' THEN date_trunc('month', now()) - interval '1 month'

      -- rolling windows (keep like your earlier logic)
      WHEN 'last_3_months' THEN now() - interval '90 days'
      WHEN 'last_6_months' THEN now() - interval '180 days'

      WHEN 'custom' THEN p.from_ts
      ELSE now() - interval '90 days'
    END AS start_ts,

    CASE p.time_range
      WHEN 'last_month' THEN date_trunc('month', now())
      WHEN 'custom' THEN p.to_ts
      ELSE now()
    END AS end_ts,

    p.bucket_type,
    p.time_range,
    p.providers,
    p.models,
    p.applications,
    p.components
  FROM p
),
rows_enriched AS (
  SELECT
    -- bucket by type
    CASE
      WHEN b.bucket_type = 'daily'   THEN DATE(c.insertion_time)
      WHEN b.bucket_type = 'weekly'  THEN DATE(date_trunc('week',  c.insertion_time))
      WHEN b.bucket_type = 'monthly' THEN DATE(date_trunc('month', c.insertion_time))
      ELSE DATE(c.insertion_time)
    END AS bucket_date,

    c.session_id,
    c.trace_id,
    c.span_id,
    c.model,
    c.service_name,
    c.tool_name,

    -- ✅ provider via regex: leading alphabetic token
    -- examples:
    --   "openai/gpt-..." -> openai
    --   "bedrock/amazon..." -> bedrock
    --   "bedrock:apac:anthropic..." -> bedrock
    lower((regexp_match(coalesce(c.model, ''), '^([a-zA-Z]+)'))[1]) AS provider_key

  FROM public.ce_llm_calls c
  CROSS JOIN b
  WHERE c.insertion_time IS NOT NULL

    -- custom must have both bounds
    AND (b.time_range <> 'custom' OR (b.start_ts IS NOT NULL AND b.end_ts IS NOT NULL))

    -- time filter (timestamp WITHOUT tz column assumption)
    AND c.insertion_time >= (b.start_ts AT TIME ZONE 'UTC')
    AND c.insertion_time <  (b.end_ts   AT TIME ZONE 'UTC')   -- half-open boundary
),
filtered AS (
  SELECT r.*
  FROM rows_enriched r
  CROSS JOIN b
  WHERE
    -- providers filter
    (cardinality(b.providers) = 0 OR r.provider_key = ANY(b.providers))

    -- models filter
    AND (cardinality(b.models) = 0 OR r.model = ANY(b.models))

    -- applications -> service_name
    AND (cardinality(b.applications) = 0 OR r.service_name = ANY(b.applications))

    -- components -> tool_name
    AND (cardinality(b.components) = 0 OR r.tool_name = ANY(b.components))
)
SELECT
  bucket_date,
  COUNT(DISTINCT session_id) FILTER (WHERE session_id IS NOT NULL) AS unique_sessions,
  COUNT(DISTINCT trace_id)   FILTER (WHERE trace_id   IS NOT NULL) AS unique_traces,
  COUNT(DISTINCT span_id)    FILTER (WHERE span_id    IS NOT NULL) AS unique_span_ids
FROM filtered
GROUP BY bucket_date
ORDER BY bucket_date;
$function$
;

-- DROP FUNCTION public.get_llm_session_trend(text, text, timestamptz, timestamptz, _text, _text);

CREATE OR REPLACE FUNCTION public.get_llm_session_trend(p_bucket_type text, p_time_range text, p_from_date timestamp with time zone, p_to_date timestamp with time zone, p_providers text[] DEFAULT NULL::text[], p_models text[] DEFAULT NULL::text[])
 RETURNS TABLE(bucket_start timestamp with time zone, tool text, application text, component text, session_count bigint)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_from_ts timestamptz;
  v_to_ts   timestamptz;
BEGIN
  -- Validate bucket type
  IF lower(p_bucket_type) NOT IN ('daily','weekly','monthly') THEN
    RAISE EXCEPTION 'Invalid bucket type: %. Expected daily|weekly|monthly', p_bucket_type;
  END IF;

  -- Resolve time bounds
  IF lower(p_time_range) = 'custom' THEN
    IF p_from_date IS NULL OR p_to_date IS NULL THEN
      RAISE EXCEPTION 'For time_range=custom, from_date and to_date must be provided';
    END IF;
    v_from_ts := p_from_date;
    v_to_ts   := p_to_date;
  ELSIF lower(p_time_range) = 'last_week' THEN
    v_from_ts := now() - interval '7 days';
    v_to_ts   := now();
  ELSIF lower(p_time_range) = 'last_month' THEN
    v_from_ts := now() - interval '1 month';
    v_to_ts   := now();
  ELSIF lower(p_time_range) = 'last_3_months' THEN
    v_from_ts := now() - interval '3 months';
    v_to_ts   := now();
  ELSIF lower(p_time_range) = 'last_6_months' THEN
    v_from_ts := now() - interval '6 months';
    v_to_ts   := now();
  ELSE
    RAISE EXCEPTION 'Invalid time_range: %. Expected last_week|last_month|last_3_months|last_6_months|custom', p_time_range;
  END IF;

  RETURN QUERY
  WITH
  base AS (
    SELECT
      lc.session_id,
      lc.tool,
      lc.application,
      lc.component,
      lc.model,
      lc.event_time
    FROM public.llm_calls lc
    WHERE lc.event_time BETWEEN v_from_ts AND v_to_ts
  ),
  enriched AS (
    SELECT
      b.*,

      -- provider derived from model:
      -- openai.gpt-...  -> openai
      -- bedrock/apac... -> bedrock
      CASE
        WHEN b.model LIKE '%/%' THEN split_part(b.model, '/', 1)
        ELSE split_part(b.model, '.', 1)
      END AS provider,

      -- model without provider prefix:
      -- openai.gpt-oss-120b-1:0 -> gpt-oss-120b-1:0
      regexp_replace(b.model, '^[^./]+[./]', '') AS model_short
    FROM base b
  ),
  filtered AS (
    SELECT e.*
    FROM enriched e
    WHERE
      (p_providers IS NULL OR cardinality(p_providers)=0 OR e.provider = ANY(p_providers))
      AND
      (
        p_models IS NULL OR cardinality(p_models)=0
        OR e.model_short = ANY(p_models)      -- expects models without provider, like gpt-oss-120b-1:0
        OR e.model       = ANY(p_models)      -- also allows full model string if you pass it
      )
  ),
  bucketed AS (
    SELECT
      CASE lower(p_bucket_type)
        WHEN 'weekly'  THEN date_trunc('week',  event_time)
        WHEN 'monthly' THEN date_trunc('month', event_time)
        ELSE                date_trunc('day',   event_time)
      END AS bucket_start,
      session_id,
      tool,
      application,
      component
    FROM filtered
  )
  SELECT
    b.bucket_start,
    CASE WHEN GROUPING(b.tool)=1        THEN '__OVERALL__' ELSE b.tool END        AS tool,
    CASE WHEN GROUPING(b.application)=1 THEN '__OVERALL__' ELSE b.application END AS application,
    CASE WHEN GROUPING(b.component)=1   THEN '__OVERALL__' ELSE b.component END   AS component,
    COUNT(DISTINCT b.session_id) AS session_count
  FROM bucketed b
  GROUP BY GROUPING SETS
  (
    (b.bucket_start),                             -- overall per bucket
    (b.bucket_start, b.tool),                     -- per tool per bucket
    (b.bucket_start, b.tool, b.application, b.component)  -- drilldown per tool+app+component
  )
  ORDER BY bucket_start, tool, application, component;

END;
$function$
;

-- DROP FUNCTION public.get_llm_session_trend_series(text, text, timestamptz, timestamptz, _text, _text, _text, _text);

CREATE OR REPLACE FUNCTION public.get_llm_session_trend_series(bucket_type text, time_range text, from_ts timestamp with time zone DEFAULT NULL::timestamp with time zone, to_ts timestamp with time zone DEFAULT NULL::timestamp with time zone, providers text[] DEFAULT NULL::text[], models text[] DEFAULT NULL::text[], applications text[] DEFAULT NULL::text[], components text[] DEFAULT NULL::text[])
 RETURNS TABLE(bucket_date date, series_name text, unique_sessions bigint, unique_traces bigint, unique_span_ids bigint)
 LANGUAGE sql
AS $function$
WITH p AS (
  SELECT
    lower(coalesce(bucket_type, 'daily')) AS bucket_type,
    lower(coalesce(time_range, 'last_3_months')) AS time_range,
    from_ts AS from_ts,
    to_ts   AS to_ts,
    coalesce(providers,    ARRAY[]::text[]) AS providers,
    coalesce(models,       ARRAY[]::text[]) AS models,
    coalesce(applications, ARRAY[]::text[]) AS applications,
    coalesce(components,   ARRAY[]::text[]) AS components
),
b AS (
  SELECT
    CASE p.time_range
      WHEN 'last_week'     THEN now() - interval '7 days'
      WHEN 'last_month'    THEN date_trunc('month', now()) - interval '1 month'
      WHEN 'last_3_months' THEN now() - interval '90 days'
      WHEN 'last_6_months' THEN now() - interval '180 days'
      WHEN 'custom'        THEN p.from_ts
      ELSE now() - interval '90 days'
    END AS start_ts,

    CASE p.time_range
      WHEN 'last_month' THEN date_trunc('month', now())
      WHEN 'custom'     THEN p.to_ts
      ELSE now()
    END AS end_ts,

    p.bucket_type,
    p.time_range,
    p.providers,
    p.models,
    p.applications,
    p.components
  FROM p
),
rows_enriched AS (
  SELECT
    CASE
      WHEN b.bucket_type = 'daily'   THEN DATE(c.insertion_time)
      WHEN b.bucket_type = 'weekly'  THEN DATE(date_trunc('week',  c.insertion_time))
      WHEN b.bucket_type = 'monthly' THEN DATE(date_trunc('month', c.insertion_time))
      ELSE DATE(c.insertion_time)
    END AS bucket_date,

    c.session_id,
    c.trace_id,
    c.span_id,
    c.model,
    c.service_name,
    c.tool_name,

    lower((regexp_match(coalesce(c.model, ''), '^([a-zA-Z]+)'))[1]) AS provider_key

  FROM public.ce_llm_calls c
  CROSS JOIN b
  WHERE c.insertion_time IS NOT NULL
    AND (b.time_range <> 'custom' OR (b.start_ts IS NOT NULL AND b.end_ts IS NOT NULL))

    -- If insertion_time is timestamp WITHOUT time zone, keep AT TIME ZONE
    AND c.insertion_time >= (b.start_ts AT TIME ZONE 'UTC')
    AND c.insertion_time <  (b.end_ts   AT TIME ZONE 'UTC')
),
filtered AS (
  SELECT r.*
  FROM rows_enriched r
  CROSS JOIN b
  WHERE
    (cardinality(b.providers) = 0 OR r.provider_key = ANY(b.providers))
    AND (cardinality(b.models) = 0 OR r.model = ANY(b.models))
    AND (cardinality(b.applications) = 0 OR r.service_name = ANY(b.applications))
    AND (cardinality(b.components) = 0 OR r.tool_name = ANY(b.components))
),
unioned AS (
  -- ✅ Overall per bucket
  SELECT
    bucket_date,
    'Overall'::text AS series_name,
    COUNT(DISTINCT session_id) FILTER (WHERE session_id IS NOT NULL) AS unique_sessions,
    COUNT(DISTINCT trace_id)   FILTER (WHERE trace_id   IS NOT NULL) AS unique_traces,
    COUNT(DISTINCT span_id)    FILTER (WHERE span_id    IS NOT NULL) AS unique_span_ids,
    0 AS sort_key
  FROM filtered
  GROUP BY bucket_date

  UNION ALL

  -- ✅ Tool-wise per bucket
  SELECT
    bucket_date,
    coalesce(tool_name, 'Unknown') AS series_name,
    COUNT(DISTINCT session_id) FILTER (WHERE session_id IS NOT NULL) AS unique_sessions,
    COUNT(DISTINCT trace_id)   FILTER (WHERE trace_id   IS NOT NULL) AS unique_traces,
    COUNT(DISTINCT span_id)    FILTER (WHERE span_id    IS NOT NULL) AS unique_span_ids,
    1 AS sort_key
  FROM filtered
  GROUP BY bucket_date, coalesce(tool_name, 'Unknown')
)
SELECT
  bucket_date,
  series_name,
  unique_sessions,
  unique_traces,
  unique_span_ids
FROM unioned
ORDER BY bucket_date, sort_key, series_name;
$function$
;

-- DROP FUNCTION public.get_tool_call_counts(text, text, timestamptz, timestamptz, _text, _text);

CREATE OR REPLACE FUNCTION public.get_tool_call_counts(bucket_type text, time_range text, from_ts timestamp with time zone DEFAULT NULL::timestamp with time zone, to_ts timestamp with time zone DEFAULT NULL::timestamp with time zone, services text[] DEFAULT NULL::text[], tools text[] DEFAULT NULL::text[])
 RETURNS TABLE(span_date date, tool_name text, span_count bigint)
 LANGUAGE sql
AS $function$
WITH p AS (
  SELECT
    lower(coalesce(bucket_type,'daily')) AS bucket_type,
    lower(coalesce(time_range,'last_6_months')) AS time_range,
    from_ts AS from_ts,
    to_ts   AS to_ts,
    coalesce(services, ARRAY[]::text[]) AS services,
    coalesce(tools,    ARRAY[]::text[]) AS tools
),
b AS (
  SELECT
    CASE p.time_range
      WHEN 'last_week'     THEN now() - interval '7 days'
      WHEN 'last_month'    THEN now() - interval '30 days'
      WHEN 'last_3_months' THEN now() - interval '90 days'
      WHEN 'last_6_months' THEN now() - interval '180 days'
      WHEN 'custom'        THEN p.from_ts
      ELSE now() - interval '180 days'
    END AS start_ts,
    CASE p.time_range
      WHEN 'custom' THEN p.to_ts
      ELSE now()
    END AS end_ts,
    p.bucket_type,
    p.services,
    p.tools
  FROM p
)
SELECT
  CASE
    WHEN b.bucket_type = 'daily'   THEN DATE(ct.start_time)
    WHEN b.bucket_type = 'weekly'  THEN DATE(date_trunc('week', ct.start_time))
    WHEN b.bucket_type = 'monthly' THEN DATE(date_trunc('month', ct.start_time))
    ELSE DATE(ct.start_time)
  END AS span_date,
  ct.name AS tool_name,
  COUNT(*) AS span_count
FROM public.ce_traces ct
CROSS JOIN b
WHERE ct.kind = 0
  -- time range
  AND ct.start_time >= (b.start_ts AT TIME ZONE 'UTC')
  AND ct.start_time <= (b.end_ts   AT TIME ZONE 'UTC')

  -- filters (apply only when arrays non-empty)
  AND (cardinality(b.services) = 0 OR ct.service_name = ANY(b.services))
  AND (cardinality(b.tools)    = 0 OR ct.name = ANY(b.tools))
GROUP BY 1, 2
ORDER BY span_date, tool_name;
$function$
;
-- Hii
--Hiiii