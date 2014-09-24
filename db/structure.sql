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
-- Name: bonus_levels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bonus_levels (
    bonus_id integer NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    amounts numeric(5,5)[] DEFAULT '{}'::numeric[] NOT NULL
);


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
    pay_period_id character varying(255) NOT NULL,
    bonus_id integer NOT NULL,
    user_id integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    status integer DEFAULT 1 NOT NULL,
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
    name character varying(255) NOT NULL,
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
-- Name: bonus_sales_requirements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bonus_sales_requirements (
    bonus_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    source boolean DEFAULT true NOT NULL
);


--
-- Name: bonuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bonuses (
    id integer NOT NULL,
    bonus_plan_id integer NOT NULL,
    type character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    schedule integer DEFAULT 2 NOT NULL,
    use_rank_at integer DEFAULT 2 NOT NULL,
    achieved_rank_id integer,
    max_user_rank_id integer,
    min_upline_rank_id integer,
    compress boolean DEFAULT false NOT NULL,
    flat_amount numeric(10,2) DEFAULT 0.0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email character varying(255),
    phone character varying(255),
    address character varying(255),
    city character varying(255),
    state character varying(255),
    zip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: invites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE invites (
    id character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    phone character varying(255),
    expires timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sponsor_id integer NOT NULL,
    user_id integer
);


--
-- Name: order_totals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE order_totals (
    id integer NOT NULL,
    pay_period_id character varying(255) NOT NULL,
    user_id integer NOT NULL,
    product_id integer NOT NULL,
    personal integer DEFAULT 0 NOT NULL,
    "group" integer NOT NULL,
    personal_lifetime integer DEFAULT 0 NOT NULL,
    group_lifetime integer NOT NULL
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
    id character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    calculated_at timestamp without time zone
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE products (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    bonus_volume integer NOT NULL,
    commission_percentage integer DEFAULT 100 NOT NULL,
    quote_data character varying(255)[] DEFAULT '{}'::character varying[],
    distributor_only boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    type character varying(255) NOT NULL,
    path character varying(255) DEFAULT 'default'::character varying NOT NULL,
    time_period integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    max_leg_percent integer,
    rank_id integer,
    product_id integer NOT NULL
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
-- Name: quotes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quotes (
    id integer NOT NULL,
    url_slug character varying(255) NOT NULL,
    data hstore DEFAULT ''::hstore NOT NULL,
    customer_id integer NOT NULL,
    product_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    pay_period_id character varying(255),
    user_id integer NOT NULL,
    rank_id integer NOT NULL,
    path character varying(255) NOT NULL,
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
-- Name: ranks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ranks (
    id integer NOT NULL,
    title character varying(255) NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    var character varying(255) NOT NULL,
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
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    encrypted_password character varying(255) NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    contact hstore DEFAULT ''::hstore,
    url_slug character varying(255),
    reset_token character varying(255),
    reset_sent_at timestamp without time zone,
    roles character varying(255)[] DEFAULT '{}'::character varying[],
    upline integer[] DEFAULT '{}'::integer[],
    lifetime_rank integer,
    organic_rank integer,
    rank_path character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sponsor_id integer,
    utilities hstore,
    profile hstore
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

ALTER TABLE ONLY order_totals ALTER COLUMN id SET DEFAULT nextval('order_totals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders ALTER COLUMN id SET DEFAULT nextval('orders_id_seq'::regclass);


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

ALTER TABLE ONLY quotes ALTER COLUMN id SET DEFAULT nextval('quotes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_achievements ALTER COLUMN id SET DEFAULT nextval('rank_achievements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: bonus_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bonus_levels
    ADD CONSTRAINT bonus_levels_pkey PRIMARY KEY (bonus_id, level);


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
-- Name: bonus_sales_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bonus_sales_requirements
    ADD CONSTRAINT bonus_sales_requirements_pkey PRIMARY KEY (bonus_id, product_id);


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
-- Name: invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


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
-- Name: ranks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ranks
    ADD CONSTRAINT ranks_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_order_totals_composite_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_order_totals_composite_key ON order_totals USING btree (pay_period_id, user_id, product_id);


--
-- Name: index_bonus_plans_on_start_year_and_start_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_bonus_plans_on_start_year_and_start_month ON bonus_plans USING btree (start_year, start_month);


--
-- Name: index_orders_on_quote_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orders_on_quote_id ON orders USING btree (quote_id);


--
-- Name: index_qualifications_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_qualifications_on_product_id ON qualifications USING btree (product_id);


--
-- Name: index_qualifications_on_rank_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_qualifications_on_rank_id ON qualifications USING btree (rank_id);


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

CREATE UNIQUE INDEX rank_achievements_comp_key_with_pp ON rank_achievements USING btree (pay_period_id, user_id, rank_id, path) WHERE (pay_period_id IS NOT NULL);


--
-- Name: rank_achievements_comp_key_without_pp; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX rank_achievements_comp_key_without_pp ON rank_achievements USING btree (user_id DESC, rank_id, path) WHERE (pay_period_id IS NULL);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: bonus_levels_bonus_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_levels
    ADD CONSTRAINT bonus_levels_bonus_id_fk FOREIGN KEY (bonus_id) REFERENCES bonuses(id);


--
-- Name: bonus_payment_orders_bonus_payment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_payment_orders
    ADD CONSTRAINT bonus_payment_orders_bonus_payment_id_fk FOREIGN KEY (bonus_payment_id) REFERENCES bonus_payments(id);


--
-- Name: bonus_payment_orders_order_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_payment_orders
    ADD CONSTRAINT bonus_payment_orders_order_id_fk FOREIGN KEY (order_id) REFERENCES orders(id);


--
-- Name: bonus_payments_bonus_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_payments
    ADD CONSTRAINT bonus_payments_bonus_id_fk FOREIGN KEY (bonus_id) REFERENCES bonuses(id);


--
-- Name: bonus_payments_pay_period_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_payments
    ADD CONSTRAINT bonus_payments_pay_period_id_fk FOREIGN KEY (pay_period_id) REFERENCES pay_periods(id);


--
-- Name: bonus_payments_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_payments
    ADD CONSTRAINT bonus_payments_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: bonus_sales_requirements_bonus_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_sales_requirements
    ADD CONSTRAINT bonus_sales_requirements_bonus_id_fk FOREIGN KEY (bonus_id) REFERENCES bonuses(id);


--
-- Name: bonus_sales_requirements_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonus_sales_requirements
    ADD CONSTRAINT bonus_sales_requirements_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: bonuses_achieved_rank_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonuses
    ADD CONSTRAINT bonuses_achieved_rank_id_fk FOREIGN KEY (achieved_rank_id) REFERENCES ranks(id);


--
-- Name: bonuses_bonus_plan_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonuses
    ADD CONSTRAINT bonuses_bonus_plan_id_fk FOREIGN KEY (bonus_plan_id) REFERENCES bonus_plans(id);


--
-- Name: bonuses_max_user_rank_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonuses
    ADD CONSTRAINT bonuses_max_user_rank_id_fk FOREIGN KEY (max_user_rank_id) REFERENCES ranks(id);


--
-- Name: bonuses_min_upline_rank_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bonuses
    ADD CONSTRAINT bonuses_min_upline_rank_id_fk FOREIGN KEY (min_upline_rank_id) REFERENCES ranks(id);


--
-- Name: invites_sponsor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_sponsor_id_fk FOREIGN KEY (sponsor_id) REFERENCES users(id);


--
-- Name: invites_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: order_totals_pay_period_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_totals
    ADD CONSTRAINT order_totals_pay_period_id_fk FOREIGN KEY (pay_period_id) REFERENCES pay_periods(id);


--
-- Name: order_totals_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_totals
    ADD CONSTRAINT order_totals_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: order_totals_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_totals
    ADD CONSTRAINT order_totals_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: orders_customer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_customer_id_fk FOREIGN KEY (customer_id) REFERENCES customers(id);


--
-- Name: orders_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: orders_quote_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_quote_id_fk FOREIGN KEY (quote_id) REFERENCES quotes(id);


--
-- Name: orders_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: qualifications_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY qualifications
    ADD CONSTRAINT qualifications_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: qualifications_rank_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY qualifications
    ADD CONSTRAINT qualifications_rank_id_fk FOREIGN KEY (rank_id) REFERENCES ranks(id);


--
-- Name: quotes_customer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quotes
    ADD CONSTRAINT quotes_customer_id_fk FOREIGN KEY (customer_id) REFERENCES customers(id);


--
-- Name: quotes_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quotes
    ADD CONSTRAINT quotes_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: quotes_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quotes
    ADD CONSTRAINT quotes_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: rank_achievements_pay_period_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_achievements
    ADD CONSTRAINT rank_achievements_pay_period_id_fk FOREIGN KEY (pay_period_id) REFERENCES pay_periods(id);


--
-- Name: rank_achievements_rank_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_achievements
    ADD CONSTRAINT rank_achievements_rank_id_fk FOREIGN KEY (rank_id) REFERENCES ranks(id);


--
-- Name: rank_achievements_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_achievements
    ADD CONSTRAINT rank_achievements_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: users_lifetime_rank_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_lifetime_rank_fk FOREIGN KEY (lifetime_rank) REFERENCES ranks(id);


--
-- Name: users_organic_rank_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_organic_rank_fk FOREIGN KEY (organic_rank) REFERENCES ranks(id);


--
-- Name: users_sponsor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_sponsor_id_fk FOREIGN KEY (sponsor_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140514044342');

INSERT INTO schema_migrations (version) VALUES ('20140515033329');

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

