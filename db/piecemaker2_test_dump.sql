--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: event_fields; Type: TABLE; Schema: public; Owner: mattes; Tablespace: 
--

CREATE TABLE event_fields (
    event_id integer NOT NULL,
    id character varying(50) NOT NULL,
    value text
);


ALTER TABLE public.event_fields OWNER TO mattes;

--
-- Name: event_groups; Type: TABLE; Schema: public; Owner: mattes; Tablespace: 
--

CREATE TABLE event_groups (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    text text,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.event_groups OWNER TO mattes;

--
-- Name: event_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: mattes
--

CREATE SEQUENCE event_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_groups_id_seq OWNER TO mattes;

--
-- Name: event_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mattes
--

ALTER SEQUENCE event_groups_id_seq OWNED BY event_groups.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: mattes; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    event_group_id integer NOT NULL,
    created_by_user_id integer,
    utc_timestamp double precision NOT NULL,
    duration double precision,
    type character varying(50) NOT NULL
);


ALTER TABLE public.events OWNER TO mattes;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: mattes
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_id_seq OWNER TO mattes;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mattes
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: mattes; Tablespace: 
--

CREATE TABLE role_permissions (
    user_role_id character varying(50) NOT NULL,
    permission character varying(50) NOT NULL,
    entity character varying(50) NOT NULL
);


ALTER TABLE public.role_permissions OWNER TO mattes;

--
-- Name: schema_info; Type: TABLE; Schema: public; Owner: mattes; Tablespace: 
--

CREATE TABLE schema_info (
    version integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.schema_info OWNER TO mattes;

--
-- Name: user_has_event_groups; Type: TABLE; Schema: public; Owner: mattes; Tablespace: 
--

CREATE TABLE user_has_event_groups (
    user_id integer NOT NULL,
    event_group_id integer NOT NULL,
    user_role_id character varying(50)
);


ALTER TABLE public.user_has_event_groups OWNER TO mattes;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: mattes; Tablespace: 
--

CREATE TABLE user_roles (
    id character varying(50) NOT NULL,
    description character varying(50)
);


ALTER TABLE public.user_roles OWNER TO mattes;

--
-- Name: users; Type: TABLE; Schema: public; Owner: mattes; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying(45) NOT NULL,
    email character varying(45),
    password character varying(45) NOT NULL,
    api_access_key character varying(45),
    is_admin boolean DEFAULT false NOT NULL,
    is_disabled boolean DEFAULT false NOT NULL
);


ALTER TABLE public.users OWNER TO mattes;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: mattes
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO mattes;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mattes
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: mattes
--

ALTER TABLE ONLY event_groups ALTER COLUMN id SET DEFAULT nextval('event_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: mattes
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: mattes
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: event_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: mattes; Tablespace: 
--

ALTER TABLE ONLY event_fields
    ADD CONSTRAINT event_fields_pkey PRIMARY KEY (event_id, id);


--
-- Name: event_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: mattes; Tablespace: 
--

ALTER TABLE ONLY event_groups
    ADD CONSTRAINT event_groups_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: mattes; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: mattes; Tablespace: 
--

ALTER TABLE ONLY role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (user_role_id, entity);


--
-- Name: user_has_event_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: mattes; Tablespace: 
--

ALTER TABLE ONLY user_has_event_groups
    ADD CONSTRAINT user_has_event_groups_pkey PRIMARY KEY (user_id, event_group_id);


--
-- Name: user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: mattes; Tablespace: 
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: users_email_key; Type: CONSTRAINT; Schema: public; Owner: mattes; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: mattes; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: event_fields_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mattes
--

ALTER TABLE ONLY event_fields
    ADD CONSTRAINT event_fields_event_id_fkey FOREIGN KEY (event_id) REFERENCES events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: events_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mattes
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: events_event_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mattes
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_event_group_id_fkey FOREIGN KEY (event_group_id) REFERENCES event_groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: role_permissions_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mattes
--

ALTER TABLE ONLY role_permissions
    ADD CONSTRAINT role_permissions_user_role_id_fkey FOREIGN KEY (user_role_id) REFERENCES user_roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_has_event_groups_event_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mattes
--

ALTER TABLE ONLY user_has_event_groups
    ADD CONSTRAINT user_has_event_groups_event_group_id_fkey FOREIGN KEY (event_group_id) REFERENCES event_groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_has_event_groups_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mattes
--

ALTER TABLE ONLY user_has_event_groups
    ADD CONSTRAINT user_has_event_groups_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_has_event_groups_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mattes
--

ALTER TABLE ONLY user_has_event_groups
    ADD CONSTRAINT user_has_event_groups_user_role_id_fkey FOREIGN KEY (user_role_id) REFERENCES user_roles(id) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: public; Type: ACL; Schema: -; Owner: mattes
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM mattes;
GRANT ALL ON SCHEMA public TO mattes;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

