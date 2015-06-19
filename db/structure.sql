--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: api_clients; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE api_clients (
    id character varying NOT NULL,
    secret character varying NOT NULL
);


--
-- Name: api_tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE api_tokens (
    id character varying NOT NULL,
    access_token character varying NOT NULL,
    client_id character varying NOT NULL,
    user_id integer,
    expires_at timestamp without time zone NOT NULL
);


--
-- Name: application_agreements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE application_agreements (
    id integer NOT NULL,
    version character varying,
    document_path character varying,
    published_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    message text
);


--
-- Name: application_agreements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE application_agreements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: application_agreements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE application_agreements_id_seq OWNED BY application_agreements.id;


--
-- Name: bonus_amounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bonus_amounts (
    id integer NOT NULL,
    bonus_id integer NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    rank_path_id integer,
    amounts numeric(10,2)[] DEFAULT '{}'::numeric[] NOT NULL
);


--
-- Name: bonus_amounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bonus_amounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bonus_amounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bonus_amounts_id_seq OWNED BY bonus_amounts.id;


--
-- Name: bonus_payment_orders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bonus_payment_orders (
    bonus_payment_id integer NOT NULL,
    order_id integer NOT NULL
);


--
-- Name: bonus_payments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bonus_payments (
    id integer NOT NULL,
    pay_period_id character varying NOT NULL,
    bonus_id integer NOT NULL,
    user_id integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    pay_as_rank integer NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: bonus_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bonus_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bonus_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bonus_payments_id_seq OWNED BY bonus_payments.id;


--
-- Name: bonus_plans; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bonus_plans (
    id integer NOT NULL,
    name character varying NOT NULL,
    start_year integer,
    start_month integer
);


--
-- Name: bonus_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bonus_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bonus_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bonus_plans_id_seq OWNED BY bonus_plans.id;


--
-- Name: bonuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bonuses (
    id integer NOT NULL,
    bonus_plan_id integer NOT NULL,
    type character varying DEFAULT 'Bonus'::character varying NOT NULL,
    name character varying NOT NULL,
    schedule integer DEFAULT 2 NOT NULL,
    meta_data hstore DEFAULT ''::hstore,
    compress boolean DEFAULT false NOT NULL,
    flat_amount numeric(10,2) DEFAULT 0.0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    product_id integer
);


--
-- Name: bonuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bonuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bonuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bonuses_id_seq OWNED BY bonuses.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE customers (
    id integer NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    email character varying,
    phone character varying,
    address character varying,
    city character varying,
    state character varying,
    zip character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    notes character varying
);


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE customers_id_seq OWNED BY customers.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: distributions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE distributions (
    id integer NOT NULL,
    pay_period_id character varying NOT NULL,
    user_id integer NOT NULL,
    amount numeric(10,2) NOT NULL
);


--
-- Name: distributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE distributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: distributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE distributions_id_seq OWNED BY distributions.id;


--
-- Name: invites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE invites (
    id character varying NOT NULL,
    email character varying NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    phone character varying,
    expires timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sponsor_id integer NOT NULL,
    user_id integer
);


--
-- Name: lead_updates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lead_updates (
    id integer NOT NULL,
    quote_id integer NOT NULL,
    provider_uid character varying NOT NULL,
    status character varying NOT NULL,
    contact hstore DEFAULT ''::hstore,
    order_status hstore DEFAULT ''::hstore,
    consultation timestamp without time zone,
    contract timestamp without time zone,
    installation timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    data hstore DEFAULT ''::hstore,
    updated_at timestamp without time zone NOT NULL,
    lead_status character varying,
    opportunity_stage character varying
);


--
-- Name: lead_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lead_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lead_updates_id_seq OWNED BY lead_updates.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    content text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: order_totals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE order_totals (
    id integer NOT NULL,
    pay_period_id character varying NOT NULL,
    user_id integer NOT NULL,
    product_id integer NOT NULL,
    personal integer DEFAULT 0 NOT NULL,
    "group" integer DEFAULT 0 NOT NULL,
    personal_lifetime integer DEFAULT 0 NOT NULL,
    group_lifetime integer DEFAULT 0 NOT NULL
);


--
-- Name: order_totals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE order_totals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_totals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE order_totals_id_seq OWNED BY order_totals.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orders (
    id integer NOT NULL,
    product_id integer NOT NULL,
    user_id integer NOT NULL,
    customer_id integer NOT NULL,
    quote_id integer,
    quantity integer DEFAULT 1,
    order_date timestamp without time zone NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orders_id_seq OWNED BY orders.id;


--
-- Name: pay_periods; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pay_periods (
    id character varying NOT NULL,
    type character varying NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    calculate_queued timestamp without time zone,
    calculate_started timestamp without time zone,
    calculated_at timestamp without time zone,
    distribute_queued timestamp without time zone,
    distribute_started timestamp without time zone,
    disbursed_at timestamp without time zone,
    total_volume numeric(10,2),
    total_bonus numeric(10,2),
    total_breakage numeric(10,2)
);


--
-- Name: product_enrollments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE product_enrollments (
    id integer NOT NULL,
    product_id integer,
    user_id integer,
    state character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: product_enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_enrollments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE product_enrollments_id_seq OWNED BY product_enrollments.id;


--
-- Name: product_receipts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE product_receipts (
    id integer NOT NULL,
    product_id integer NOT NULL,
    user_id integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    transaction_id character varying NOT NULL,
    order_id character varying NOT NULL,
    auth_code character varying
);


--
-- Name: product_receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_receipts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE product_receipts_id_seq OWNED BY product_receipts.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE products (
    id integer NOT NULL,
    name character varying NOT NULL,
    bonus_volume integer,
    commission_percentage integer DEFAULT 100 NOT NULL,
    distributor_only boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sku character varying,
    description text,
    is_university_class boolean DEFAULT false,
    image_original_path character varying,
    smarteru_module_id character varying(50),
    is_required_class boolean DEFAULT false,
    "position" integer,
    long_description text
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE products_id_seq OWNED BY products.id;


--
-- Name: qualifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE qualifications (
    id integer NOT NULL,
    type character varying NOT NULL,
    time_period integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    max_leg_percent integer,
    rank_id integer,
    product_id integer NOT NULL,
    rank_path_id integer
);


--
-- Name: qualifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE qualifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qualifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE qualifications_id_seq OWNED BY qualifications.id;


--
-- Name: quote_field_lookups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quote_field_lookups (
    id integer NOT NULL,
    quote_field_id integer NOT NULL,
    value character varying NOT NULL,
    identifier character varying NOT NULL,
    "group" character varying
);


--
-- Name: quote_field_lookups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quote_field_lookups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quote_field_lookups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quote_field_lookups_id_seq OWNED BY quote_field_lookups.id;


--
-- Name: quote_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quote_fields (
    id integer NOT NULL,
    product_id integer NOT NULL,
    name character varying NOT NULL,
    data_type integer DEFAULT 1 NOT NULL,
    required boolean DEFAULT false NOT NULL
);


--
-- Name: quote_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quote_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quote_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quote_fields_id_seq OWNED BY quote_fields.id;


--
-- Name: quotes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quotes (
    id integer NOT NULL,
    url_slug character varying NOT NULL,
    data hstore DEFAULT ''::hstore NOT NULL,
    customer_id integer NOT NULL,
    product_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    submitted_at timestamp without time zone,
    provider_uid character varying,
    status integer DEFAULT 0 NOT NULL
);


--
-- Name: quotes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quotes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quotes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quotes_id_seq OWNED BY quotes.id;


--
-- Name: rank_achievements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rank_achievements (
    id integer NOT NULL,
    pay_period_id character varying,
    user_id integer NOT NULL,
    rank_id integer NOT NULL,
    rank_path_id integer,
    achieved_at timestamp without time zone NOT NULL
);


--
-- Name: rank_achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rank_achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rank_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rank_achievements_id_seq OWNED BY rank_achievements.id;


--
-- Name: rank_paths; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rank_paths (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    precedence integer DEFAULT 1 NOT NULL
);


--
-- Name: rank_paths_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rank_paths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rank_paths_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rank_paths_id_seq OWNED BY rank_paths.id;


--
-- Name: ranks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ranks (
    id integer NOT NULL,
    title character varying NOT NULL,
    welcome_message text
);


--
-- Name: ranks_user_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ranks_user_groups (
    rank_id integer NOT NULL,
    user_group_id character varying NOT NULL
);


--
-- Name: resources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE resources (
    id integer NOT NULL,
    user_id integer,
    title character varying,
    description text,
    file_original_path character varying,
    file_type character varying(60),
    image_original_path character varying,
    is_public boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    youtube_id character varying
);


--
-- Name: resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE resources_id_seq OWNED BY resources.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    var character varying NOT NULL,
    value text,
    thing_id integer,
    thing_type character varying(30),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: social_media_posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE social_media_posts (
    id integer NOT NULL,
    content character varying,
    publish boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: social_media_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE social_media_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: social_media_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE social_media_posts_id_seq OWNED BY social_media_posts.id;


--
-- Name: user_activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_activities (
    id integer NOT NULL,
    user_id integer,
    event_time timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    event character varying
);


--
-- Name: user_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_activities_id_seq OWNED BY user_activities.id;


--
-- Name: user_group_requirements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_group_requirements (
    id integer NOT NULL,
    user_group_id character varying NOT NULL,
    product_id integer NOT NULL,
    event_type integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    time_span integer,
    max_leg integer
);


--
-- Name: user_group_requirements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_group_requirements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_group_requirements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_group_requirements_id_seq OWNED BY user_group_requirements.id;


--
-- Name: user_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_groups (
    id character varying NOT NULL,
    title character varying NOT NULL,
    description character varying
);


--
-- Name: user_overrides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_overrides (
    id integer NOT NULL,
    user_id integer NOT NULL,
    kind integer NOT NULL,
    data hstore DEFAULT ''::hstore,
    start_date date,
    end_date date
);


--
-- Name: user_overrides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_overrides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_overrides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_overrides_id_seq OWNED BY user_overrides.id;


--
-- Name: user_user_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_user_groups (
    user_id integer NOT NULL,
    user_group_id character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying NOT NULL,
    encrypted_password character varying NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    contact hstore DEFAULT ''::hstore,
    url_slug character varying,
    reset_token character varying,
    reset_sent_at timestamp without time zone,
    roles character varying[] DEFAULT '{}'::character varying[],
    upline integer[] DEFAULT '{}'::integer[],
    lifetime_rank integer,
    organic_rank integer,
    rank_path_id integer,
    sponsor_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    profile hstore,
    avatar_file_name character varying,
    avatar_content_type character varying,
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    smarteru_employee_id character varying,
    moved boolean,
    image_original_path character varying,
    tos character varying(5)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: zipcodes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zipcodes (
    id integer NOT NULL,
    zip character varying
);


--
-- Name: zipcodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE zipcodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: zipcodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE zipcodes_id_seq OWNED BY zipcodes.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY application_agreements ALTER COLUMN id SET DEFAULT nextval('application_agreements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_amounts ALTER COLUMN id SET DEFAULT nextval('bonus_amounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_payments ALTER COLUMN id SET DEFAULT nextval('bonus_payments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_plans ALTER COLUMN id SET DEFAULT nextval('bonus_plans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonuses ALTER COLUMN id SET DEFAULT nextval('bonuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers ALTER COLUMN id SET DEFAULT nextval('customers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributions ALTER COLUMN id SET DEFAULT nextval('distributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lead_updates ALTER COLUMN id SET DEFAULT nextval('lead_updates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_totals ALTER COLUMN id SET DEFAULT nextval('order_totals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders ALTER COLUMN id SET DEFAULT nextval('orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_enrollments ALTER COLUMN id SET DEFAULT nextval('product_enrollments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_receipts ALTER COLUMN id SET DEFAULT nextval('product_receipts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY qualifications ALTER COLUMN id SET DEFAULT nextval('qualifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quote_field_lookups ALTER COLUMN id SET DEFAULT nextval('quote_field_lookups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quote_fields ALTER COLUMN id SET DEFAULT nextval('quote_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quotes ALTER COLUMN id SET DEFAULT nextval('quotes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_achievements ALTER COLUMN id SET DEFAULT nextval('rank_achievements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_paths ALTER COLUMN id SET DEFAULT nextval('rank_paths_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY resources ALTER COLUMN id SET DEFAULT nextval('resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY social_media_posts ALTER COLUMN id SET DEFAULT nextval('social_media_posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_activities ALTER COLUMN id SET DEFAULT nextval('user_activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_group_requirements ALTER COLUMN id SET DEFAULT nextval('user_group_requirements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_overrides ALTER COLUMN id SET DEFAULT nextval('user_overrides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY zipcodes ALTER COLUMN id SET DEFAULT nextval('zipcodes_id_seq'::regclass);


--
-- Name: api_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_clients
    ADD CONSTRAINT api_clients_pkey PRIMARY KEY (id);


--
-- Name: api_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_tokens
    ADD CONSTRAINT api_tokens_pkey PRIMARY KEY (id);


--
-- Name: application_agreements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY application_agreements
    ADD CONSTRAINT application_agreements_pkey PRIMARY KEY (id);


--
-- Name: bonus_amounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bonus_amounts
    ADD CONSTRAINT bonus_amounts_pkey PRIMARY KEY (id);


--
-- Name: bonus_payment_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bonus_payment_orders
    ADD CONSTRAINT bonus_payment_orders_pkey PRIMARY KEY (bonus_payment_id, order_id);


--
-- Name: bonus_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bonus_payments
    ADD CONSTRAINT bonus_payments_pkey PRIMARY KEY (id);


--
-- Name: bonus_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bonus_plans
    ADD CONSTRAINT bonus_plans_pkey PRIMARY KEY (id);


--
-- Name: bonuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bonuses
    ADD CONSTRAINT bonuses_pkey PRIMARY KEY (id);


--
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: distributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT distributions_pkey PRIMARY KEY (id);


--
-- Name: invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: lead_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lead_updates
    ADD CONSTRAINT lead_updates_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: order_totals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY order_totals
    ADD CONSTRAINT order_totals_pkey PRIMARY KEY (id);


--
-- Name: orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: pay_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pay_periods
    ADD CONSTRAINT pay_periods_pkey PRIMARY KEY (id);


--
-- Name: product_enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY product_enrollments
    ADD CONSTRAINT product_enrollments_pkey PRIMARY KEY (id);


--
-- Name: product_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY product_receipts
    ADD CONSTRAINT product_receipts_pkey PRIMARY KEY (id);


--
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: qualifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY qualifications
    ADD CONSTRAINT qualifications_pkey PRIMARY KEY (id);


--
-- Name: quote_field_lookups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quote_field_lookups
    ADD CONSTRAINT quote_field_lookups_pkey PRIMARY KEY (id);


--
-- Name: quote_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quote_fields
    ADD CONSTRAINT quote_fields_pkey PRIMARY KEY (id);


--
-- Name: quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quotes
    ADD CONSTRAINT quotes_pkey PRIMARY KEY (id);


--
-- Name: rank_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rank_achievements
    ADD CONSTRAINT rank_achievements_pkey PRIMARY KEY (id);


--
-- Name: rank_paths_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rank_paths
    ADD CONSTRAINT rank_paths_pkey PRIMARY KEY (id);


--
-- Name: ranks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ranks
    ADD CONSTRAINT ranks_pkey PRIMARY KEY (id);


--
-- Name: resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: social_media_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY social_media_posts
    ADD CONSTRAINT social_media_posts_pkey PRIMARY KEY (id);


--
-- Name: user_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_activities
    ADD CONSTRAINT user_activities_pkey PRIMARY KEY (id);


--
-- Name: user_group_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_group_requirements
    ADD CONSTRAINT user_group_requirements_pkey PRIMARY KEY (id);


--
-- Name: user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (id);


--
-- Name: user_overrides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_overrides
    ADD CONSTRAINT user_overrides_pkey PRIMARY KEY (id);


--
-- Name: user_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_user_groups
    ADD CONSTRAINT user_user_groups_pkey PRIMARY KEY (user_id, user_group_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: zipcodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zipcodes
    ADD CONSTRAINT zipcodes_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: idx_order_totals_composite_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_order_totals_composite_key ON order_totals USING btree (pay_period_id, user_id, product_id);


--
-- Name: index_api_tokens_on_access_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_api_tokens_on_access_token ON api_tokens USING btree (access_token);


--
-- Name: index_bonus_amounts_on_bonus_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bonus_amounts_on_bonus_id ON bonus_amounts USING btree (bonus_id);


--
-- Name: index_bonus_plans_on_start_year_and_start_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_bonus_plans_on_start_year_and_start_month ON bonus_plans USING btree (start_year, start_month);


--
-- Name: index_distributions_on_pay_period_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_distributions_on_pay_period_id_and_user_id ON distributions USING btree (pay_period_id, user_id);


--
-- Name: index_orders_on_quote_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orders_on_quote_id ON orders USING btree (quote_id);


--
-- Name: index_product_enrollments_on_user_id_and_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_product_enrollments_on_user_id_and_product_id ON product_enrollments USING btree (user_id, product_id);


--
-- Name: index_products_on_is_university_class; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_products_on_is_university_class ON products USING btree (is_university_class);


--
-- Name: index_qualifications_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_qualifications_on_product_id ON qualifications USING btree (product_id);


--
-- Name: index_qualifications_on_rank_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_qualifications_on_rank_id ON qualifications USING btree (rank_id);


--
-- Name: index_quote_field_lookups_on_quote_field_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quote_field_lookups_on_quote_field_id ON quote_field_lookups USING btree (quote_field_id);


--
-- Name: index_quote_fields_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quote_fields_on_product_id ON quote_fields USING btree (product_id);


--
-- Name: index_quotes_on_customer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quotes_on_customer_id ON quotes USING btree (customer_id);


--
-- Name: index_quotes_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quotes_on_product_id ON quotes USING btree (product_id);


--
-- Name: index_quotes_on_url_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_quotes_on_url_slug ON quotes USING btree (url_slug);


--
-- Name: index_quotes_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quotes_on_user_id ON quotes USING btree (user_id);


--
-- Name: index_rank_paths_on_precedence; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rank_paths_on_precedence ON rank_paths USING btree (precedence);


--
-- Name: index_resources_on_file_type_and_is_public; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resources_on_file_type_and_is_public ON resources USING btree (file_type, is_public);


--
-- Name: index_settings_on_thing_type_and_thing_id_and_var; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_thing_type_and_thing_id_and_var ON settings USING btree (thing_type, thing_id, var);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_sponsor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_sponsor_id ON users USING btree (sponsor_id);


--
-- Name: index_users_on_upline; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_upline ON users USING gin (upline);


--
-- Name: index_users_on_url_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_url_slug ON users USING btree (url_slug);


--
-- Name: rank_achievements_comp_key_with_pp; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX rank_achievements_comp_key_with_pp ON rank_achievements USING btree (pay_period_id, user_id, rank_id, rank_path_id) WHERE (pay_period_id IS NOT NULL);


--
-- Name: rank_achievements_comp_key_without_pp; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX rank_achievements_comp_key_without_pp ON rank_achievements USING btree (user_id DESC, rank_id, rank_path_id) WHERE (pay_period_id IS NULL);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_02b555fb4d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quotes
    ADD CONSTRAINT fk_rails_02b555fb4d FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_03632e5c21; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_payments
    ADD CONSTRAINT fk_rails_03632e5c21 FOREIGN KEY (pay_period_id) REFERENCES pay_periods(id);


--
-- Name: fk_rails_0383942516; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quote_field_lookups
    ADD CONSTRAINT fk_rails_0383942516 FOREIGN KEY (quote_field_id) REFERENCES quote_fields(id);


--
-- Name: fk_rails_0a1404ebe0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_group_requirements
    ADD CONSTRAINT fk_rails_0a1404ebe0 FOREIGN KEY (user_group_id) REFERENCES user_groups(id);


--
-- Name: fk_rails_0ac5f355df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT fk_rails_0ac5f355df FOREIGN KEY (pay_period_id) REFERENCES pay_periods(id);


--
-- Name: fk_rails_0be6ab5d96; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_0be6ab5d96 FOREIGN KEY (rank_path_id) REFERENCES rank_paths(id);


--
-- Name: fk_rails_0d33b17199; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY qualifications
    ADD CONSTRAINT fk_rails_0d33b17199 FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: fk_rails_12dec8bf06; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quotes
    ADD CONSTRAINT fk_rails_12dec8bf06 FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: fk_rails_17101d1bf2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_achievements
    ADD CONSTRAINT fk_rails_17101d1bf2 FOREIGN KEY (rank_path_id) REFERENCES rank_paths(id);


--
-- Name: fk_rails_1ac6520b51; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_totals
    ADD CONSTRAINT fk_rails_1ac6520b51 FOREIGN KEY (pay_period_id) REFERENCES pay_periods(id);


--
-- Name: fk_rails_27f9662e04; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT fk_rails_27f9662e04 FOREIGN KEY (quote_id) REFERENCES quotes(id);


--
-- Name: fk_rails_2df50738a4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_payments
    ADD CONSTRAINT fk_rails_2df50738a4 FOREIGN KEY (pay_as_rank) REFERENCES ranks(id);


--
-- Name: fk_rails_3437827c68; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_payments
    ADD CONSTRAINT fk_rails_3437827c68 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_35f0faa1fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_amounts
    ADD CONSTRAINT fk_rails_35f0faa1fa FOREIGN KEY (rank_path_id) REFERENCES rank_paths(id);


--
-- Name: fk_rails_3dad120da9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT fk_rails_3dad120da9 FOREIGN KEY (customer_id) REFERENCES customers(id);


--
-- Name: fk_rails_3f4c8aa477; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_payment_orders
    ADD CONSTRAINT fk_rails_3f4c8aa477 FOREIGN KEY (bonus_payment_id) REFERENCES bonus_payments(id);


--
-- Name: fk_rails_47ad3f1496; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_group_requirements
    ADD CONSTRAINT fk_rails_47ad3f1496 FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: fk_rails_4d65aace9f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quote_fields
    ADD CONSTRAINT fk_rails_4d65aace9f FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: fk_rails_54f92f658f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ranks_user_groups
    ADD CONSTRAINT fk_rails_54f92f658f FOREIGN KEY (rank_id) REFERENCES ranks(id);


--
-- Name: fk_rails_61e62e2a41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ranks_user_groups
    ADD CONSTRAINT fk_rails_61e62e2a41 FOREIGN KEY (user_group_id) REFERENCES user_groups(id);


--
-- Name: fk_rails_67cab9fdb2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_achievements
    ADD CONSTRAINT fk_rails_67cab9fdb2 FOREIGN KEY (rank_id) REFERENCES ranks(id);


--
-- Name: fk_rails_68b7bf654f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_achievements
    ADD CONSTRAINT fk_rails_68b7bf654f FOREIGN KEY (pay_period_id) REFERENCES pay_periods(id);


--
-- Name: fk_rails_69318c246b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_receipts
    ADD CONSTRAINT fk_rails_69318c246b FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: fk_rails_70967dd465; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_achievements
    ADD CONSTRAINT fk_rails_70967dd465 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_81b70497bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT fk_rails_81b70497bd FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_86cf0924a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_user_groups
    ADD CONSTRAINT fk_rails_86cf0924a6 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_8f72336587; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_receipts
    ADD CONSTRAINT fk_rails_8f72336587 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_94f655be82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_94f655be82 FOREIGN KEY (sponsor_id) REFERENCES users(id);


--
-- Name: fk_rails_9b304eaecd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_totals
    ADD CONSTRAINT fk_rails_9b304eaecd FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_a1ab65f1f7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quotes
    ADD CONSTRAINT fk_rails_a1ab65f1f7 FOREIGN KEY (customer_id) REFERENCES customers(id);


--
-- Name: fk_rails_b080b36796; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonuses
    ADD CONSTRAINT fk_rails_b080b36796 FOREIGN KEY (bonus_plan_id) REFERENCES bonus_plans(id);


--
-- Name: fk_rails_b152dd356e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_amounts
    ADD CONSTRAINT fk_rails_b152dd356e FOREIGN KEY (bonus_id) REFERENCES bonuses(id);


--
-- Name: fk_rails_c2e3e2bfb1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_c2e3e2bfb1 FOREIGN KEY (organic_rank) REFERENCES ranks(id);


--
-- Name: fk_rails_c41dc2a789; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY qualifications
    ADD CONSTRAINT fk_rails_c41dc2a789 FOREIGN KEY (rank_path_id) REFERENCES rank_paths(id);


--
-- Name: fk_rails_cb98ac3193; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_totals
    ADD CONSTRAINT fk_rails_cb98ac3193 FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: fk_rails_ccd9c98a42; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonuses
    ADD CONSTRAINT fk_rails_ccd9c98a42 FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: fk_rails_cd92ab11e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lead_updates
    ADD CONSTRAINT fk_rails_cd92ab11e9 FOREIGN KEY (quote_id) REFERENCES quotes(id);


--
-- Name: fk_rails_d44438dd14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_tokens
    ADD CONSTRAINT fk_rails_d44438dd14 FOREIGN KEY (client_id) REFERENCES api_clients(id);


--
-- Name: fk_rails_dfb33b2de0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT fk_rails_dfb33b2de0 FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: fk_rails_e1fa9da540; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_payment_orders
    ADD CONSTRAINT fk_rails_e1fa9da540 FOREIGN KEY (order_id) REFERENCES orders(id);


--
-- Name: fk_rails_e59aa7c1c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY qualifications
    ADD CONSTRAINT fk_rails_e59aa7c1c9 FOREIGN KEY (rank_id) REFERENCES ranks(id);


--
-- Name: fk_rails_ed1f417296; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_user_groups
    ADD CONSTRAINT fk_rails_ed1f417296 FOREIGN KEY (user_group_id) REFERENCES user_groups(id);


--
-- Name: fk_rails_eddfc85f73; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_payments
    ADD CONSTRAINT fk_rails_eddfc85f73 FOREIGN KEY (bonus_id) REFERENCES bonuses(id);


--
-- Name: fk_rails_f16b5e0447; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_tokens
    ADD CONSTRAINT fk_rails_f16b5e0447 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_f868b47f6a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT fk_rails_f868b47f6a FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_fc7e11f976; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_overrides
    ADD CONSTRAINT fk_rails_fc7e11f976 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_ff69dbb2ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT fk_rails_ff69dbb2ac FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140514044342');

INSERT INTO schema_migrations (version) VALUES ('20140515033329');

INSERT INTO schema_migrations (version) VALUES ('20140515150333');

INSERT INTO schema_migrations (version) VALUES ('20140515201745');

INSERT INTO schema_migrations (version) VALUES ('20140516075244');

INSERT INTO schema_migrations (version) VALUES ('20140516164014');

INSERT INTO schema_migrations (version) VALUES ('20140604062729');

INSERT INTO schema_migrations (version) VALUES ('20140614053236');

INSERT INTO schema_migrations (version) VALUES ('20140615034123');

INSERT INTO schema_migrations (version) VALUES ('20140625072238');

INSERT INTO schema_migrations (version) VALUES ('20140709083435');

INSERT INTO schema_migrations (version) VALUES ('20140804061544');

INSERT INTO schema_migrations (version) VALUES ('20140820042927');

INSERT INTO schema_migrations (version) VALUES ('20140919222256');

INSERT INTO schema_migrations (version) VALUES ('20140920001013');

INSERT INTO schema_migrations (version) VALUES ('20140922174140');

INSERT INTO schema_migrations (version) VALUES ('20141006002457');

INSERT INTO schema_migrations (version) VALUES ('20141014205547');

INSERT INTO schema_migrations (version) VALUES ('20141017215917');

INSERT INTO schema_migrations (version) VALUES ('20141017220604');

INSERT INTO schema_migrations (version) VALUES ('20141023090103');

INSERT INTO schema_migrations (version) VALUES ('20141023092335');

INSERT INTO schema_migrations (version) VALUES ('20141106012152');

INSERT INTO schema_migrations (version) VALUES ('20141108221107');

INSERT INTO schema_migrations (version) VALUES ('20141108221116');

INSERT INTO schema_migrations (version) VALUES ('20141125215349');

INSERT INTO schema_migrations (version) VALUES ('20141126112350');

INSERT INTO schema_migrations (version) VALUES ('20141204005149');

INSERT INTO schema_migrations (version) VALUES ('20141205231913');

INSERT INTO schema_migrations (version) VALUES ('20141208233620');

INSERT INTO schema_migrations (version) VALUES ('20141212003512');

INSERT INTO schema_migrations (version) VALUES ('20141217193712');

INSERT INTO schema_migrations (version) VALUES ('20150112233624');

INSERT INTO schema_migrations (version) VALUES ('20150126211538');

INSERT INTO schema_migrations (version) VALUES ('20150127022344');

INSERT INTO schema_migrations (version) VALUES ('20150127195532');

INSERT INTO schema_migrations (version) VALUES ('20150209185127');

INSERT INTO schema_migrations (version) VALUES ('20150209200417');

INSERT INTO schema_migrations (version) VALUES ('20150225110000');

INSERT INTO schema_migrations (version) VALUES ('20150303172651');

INSERT INTO schema_migrations (version) VALUES ('20150309071743');

INSERT INTO schema_migrations (version) VALUES ('20150311194138');

INSERT INTO schema_migrations (version) VALUES ('20150330202824');

INSERT INTO schema_migrations (version) VALUES ('20150414031954');

INSERT INTO schema_migrations (version) VALUES ('20150414230447');

INSERT INTO schema_migrations (version) VALUES ('20150415072216');

INSERT INTO schema_migrations (version) VALUES ('20150421165254');

INSERT INTO schema_migrations (version) VALUES ('20150421171527');

INSERT INTO schema_migrations (version) VALUES ('20150423170131');

INSERT INTO schema_migrations (version) VALUES ('20150504180127');

INSERT INTO schema_migrations (version) VALUES ('20150504234010');

INSERT INTO schema_migrations (version) VALUES ('20150514171532');

INSERT INTO schema_migrations (version) VALUES ('20150519215441');

INSERT INTO schema_migrations (version) VALUES ('20150521051136');

INSERT INTO schema_migrations (version) VALUES ('20150521071301');

INSERT INTO schema_migrations (version) VALUES ('20150523153423');

INSERT INTO schema_migrations (version) VALUES ('20150525043450');

INSERT INTO schema_migrations (version) VALUES ('20150526030947');

INSERT INTO schema_migrations (version) VALUES ('20150528032314');

INSERT INTO schema_migrations (version) VALUES ('20150601202227');

INSERT INTO schema_migrations (version) VALUES ('20150601211613');

INSERT INTO schema_migrations (version) VALUES ('20150603213402');

INSERT INTO schema_migrations (version) VALUES ('20150611215105');

INSERT INTO schema_migrations (version) VALUES ('20150615190918');

INSERT INTO schema_migrations (version) VALUES ('20150617172905');

INSERT INTO schema_migrations (version) VALUES ('20150618213922');

