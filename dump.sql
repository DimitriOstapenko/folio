--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1
-- Dumped by pg_dump version 12.1

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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: folio
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO folio;

--
-- Name: quotes; Type: TABLE; Schema: public; Owner: folio
--

CREATE TABLE public.quotes (
    id bigint NOT NULL,
    symbol character varying,
    exchange character varying,
    name character varying,
    latest_price double precision,
    prev_close double precision,
    volume double precision,
    prev_volume double precision,
    latest_update timestamp without time zone,
    week52high double precision,
    week52low double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ytd_change double precision,
    change double precision,
    change_percent double precision,
    change_percent_s character varying,
    exch character varying,
    high double precision,
    low double precision,
    market_cap double precision,
    pe_ratio double precision
);


ALTER TABLE public.quotes OWNER TO folio;

--
-- Name: quotes_id_seq; Type: SEQUENCE; Schema: public; Owner: folio
--

CREATE SEQUENCE public.quotes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quotes_id_seq OWNER TO folio;

--
-- Name: quotes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: folio
--

ALTER SEQUENCE public.quotes_id_seq OWNED BY public.quotes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: folio
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO folio;

--
-- Name: users; Type: TABLE; Schema: public; Owner: folio
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO folio;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: folio
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO folio;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: folio
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: quotes id; Type: DEFAULT; Schema: public; Owner: folio
--

ALTER TABLE ONLY public.quotes ALTER COLUMN id SET DEFAULT nextval('public.quotes_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: folio
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: folio
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2020-07-18 14:14:33.732679	2020-07-18 14:16:59.584446
\.


--
-- Data for Name: quotes; Type: TABLE DATA; Schema: public; Owner: folio
--

COPY public.quotes (id, symbol, exchange, name, latest_price, prev_close, volume, prev_volume, latest_update, week52high, week52low, created_at, updated_at, ytd_change, change, change_percent, change_percent_s, exch, high, low, market_cap, pe_ratio) FROM stdin;
6	ABX	Toronto Stock Exchange	Barrick Gold Corp.	38.71	38.04	0	\N	2020-07-31 16:00:00	40.41	17.52	2020-07-18 18:55:45.911539	2020-08-02 15:18:39.897738	60.931000000000004	0.67	0.01761	+1.76%	-CT	39.98	22.45	0	0
15	CM	Toronto Stock Exchange	Canadian Imperial Bank of Commerce	93.38	93.71	0	\N	2020-07-24 16:00:00	115.95	67.52	2020-07-19 02:01:52.321833	2020-07-25 13:26:07.139717	-14.072799999999999	-0.33	-0.00352	-0.35%	-CT	\N	\N	\N	\N
49	GOLD	Toronto Stock Exchange	GoldMining, Inc.	2.28	2.26	0	\N	2020-07-24 16:00:00	2.48	0.85	2020-07-26 11:53:04.589875	2020-07-26 11:53:04.589875	66.1024	0.02	0.00885	+0.88%	-CT	\N	\N	\N	\N
54	BCE	Toronto Stock Exchange	BCE, Inc.	56.16	56.57	0	\N	2020-07-31 16:00:00	65.45	46.03	2020-07-26 12:24:53.543712	2020-08-02 12:19:33.873235	-6.591600000000001	-0.41	-0.00725	-0.72%	-CT	\N	\N	\N	\N
18	FVI	Toronto Stock Exchange	Fortuna Silver Mines, Inc.	8.75	8.6	0	\N	2020-07-24 16:00:00	9.17	2.05	2020-07-22 13:35:40.041414	2020-07-25 12:58:49.59101	68.4107	0.15	0.01744	+1.74%	-CT	\N	\N	\N	\N
67	DCOILWTICO	\N	\N	40.83	0	\N	\N	2020-08-08 13:11:05.534123	0	0	2020-08-08 13:08:15.657284	2020-08-08 13:11:05.53513	0	0	\N	\N	comm	0	0	\N	0
13	TRP	Toronto Stock Exchange	TC Energy Corp.	61.05	61.23	0	\N	2020-07-31 16:00:00	76.58	47.05	2020-07-19 01:57:13.353681	2020-08-02 13:25:28.738006	-11.1048	-0.18	-0.00294	-0.29%	-CT	\N	\N	\N	\N
57	ENB	Toronto Stock Exchange	Enbridge, Inc.	42.87	43.38	0	\N	2020-07-31 16:00:00	57.32	33.06	2020-07-26 17:06:57.430101	2020-08-02 13:26:17.343754	-18.0302	-0.51	-0.01176	-1.18%	-CT	\N	\N	\N	\N
46	RY	Toronto Stock Exchange	Royal Bank of Canada	92.4	93.24	0	\N	2020-07-31 16:00:00	109.68	72	2020-07-26 11:39:19.488438	2020-08-02 13:26:31.172376	-11.6687	-0.84	-0.00901	-0.90%	-CT	\N	\N	\N	\N
64	USDCAD	\N	USD/CAD Exchange Rate	1.33838	0	\N	\N	2020-08-08 13:17:46.792013	0	0	2020-08-08 12:51:42.961135	2020-08-08 13:17:46.792916	0	0	\N	\N	fx	0	0	\N	0
10	K	Toronto Stock Exchange	Kinross Gold Corp.	11.3	11.02	0	\N	2020-07-24 16:00:00	11.57	4	2020-07-18 18:56:53.853646	2020-07-25 13:03:54.313701	85.0935	0.28	0.02541	+2.54%	-CT	\N	\N	\N	\N
65	EURCAD	\N	EUR/CAD Exchange Rate	1.57764	0	\N	\N	2020-08-08 13:20:53.547612	0	0	2020-08-08 12:55:36.384921	2020-08-08 13:20:53.548468	0	0	\N	\N	fx	0	0	\N	0
48	NGT	Toronto Stock Exchange	Newmont Corp.	89.23	87.81	0	\N	2020-07-24 16:00:00	96.45	44	2020-07-26 11:52:44.401874	2020-07-26 11:52:44.401874	60.5589	1.42	0.01617	+1.62%	-CT	\N	\N	\N	\N
52	BMO	Toronto Stock Exchange	Bank of Montreal	73.73	74.24	0	\N	2020-07-24 16:00:00	104.75	55.76	2020-07-26 12:23:09.860942	2020-07-26 12:23:09.860942	-27.5784	-0.51	-0.00687	-0.69%	-CT	\N	\N	\N	\N
55	TD	Toronto Stock Exchange	The Toronto-Dominion Bank	60.58	61.23	0	\N	2020-07-24 16:00:00	77.91	49.01	2020-07-26 17:02:52.760014	2020-07-26 17:02:52.760014	-18.5504	-0.65	-0.01062	-1.06%	-CT	\N	\N	\N	\N
61	ALA	Toronto Stock Exchange	AltaGas Ltd.	16.78	16.91	0	\N	2020-07-31 16:00:00	22.74	8.71	2020-08-02 13:28:25.850645	2020-08-02 13:28:25.850645	-15.4614	-0.13	-0.00769	-0.77%	-CT	\N	\N	\N	\N
9	BNS	Toronto Stock Exchange	The Bank of Nova Scotia	55.01	55.78	0	\N	2020-07-31 16:00:00	76.75	46.38	2020-07-18 18:56:41.055558	2020-08-03 10:15:14.155161	-26.699	-0.77	-0.0138	-1.38%	-CT	74.63	46.72	0	0
47	GOOG	NASDAQ	Alphabet, Inc.	1468.76	1482.96	582091	\N	2020-08-03 10:15:32	1586.99	1013.54	2020-07-26 11:52:33.315469	2020-08-03 10:15:53.947723	7.4955	-14.2	-0.00958	-0.96%		1490.48	1467	1002449262640	32.03
62	IPL	Toronto Stock Exchange	Inter Pipeline Ltd.	12.55	12.94	0	\N	2020-07-31 16:00:00	25.42	5.35	2020-08-02 13:28:30.815488	2020-08-02 13:28:30.815488	-47.3105	-0.39	-0.03014	-3.01%	-CT	\N	\N	\N	\N
63	REI-UN	Toronto Stock Exchange	RioCan Real Estate Investment Trust	14.96	15.38	0	\N	2020-07-31 16:00:00	27.92	12.41	2020-08-02 13:29:28.054886	2020-08-02 13:29:28.054886	-45.6971	-0.42	-0.02731	-2.73%	-CT	\N	\N	\N	\N
58	CPX	Toronto Stock Exchange	Capital Power Corp.	26.98	27.48	0	\N	2020-07-24 16:00:00	38.88	20.23	2020-07-27 14:00:17.817118	2020-07-27 14:00:17.817118	-22.7925	-0.5	-0.0182	-1.82%	-CT	\N	\N	\N	\N
24	AMZN	NASDAQ	Amazon.com, Inc.	3167.46	3225	3936127	\N	2020-08-07 16:00:00	3344.29	1626.03	2020-07-23 19:26:29.779363	2020-08-08 13:29:30.064371	65.0992	-57.54	-0.01784	-1.78%		3240.81	3140.673	1586549039400	119.63
8	PAAS	Toronto Stock Exchange	Pan American Silver Corp.	49.09	51.06	0	\N	2020-08-07 16:00:00	53.3	14.22	2020-07-18 18:56:06.027111	2020-08-08 13:30:02.869655	57.19840000000001	-1.97	-0.03858	-3.86%	-CT	51.96	17.43	0	0
19	IBM	New York Stock Exchange	International Business Machines Corp.	125.505	126.21	2317525	\N	2020-07-28 14:57:38	158.75	90.56	2020-07-22 13:52:43.383579	2020-07-28 14:58:12.631602	-7.6701999999999995	-0.705	-0.00559	-0.56%		\N	\N	\N	\N
22	TSLA	NASDAQ	Tesla, Inc.	1430.76	1487.49	12246960	\N	2020-07-31 16:00:00	1794.99	211	2020-07-22 18:15:55.324068	2020-08-02 13:35:03.482346	228.71980000000002	-56.73	-0.03814	-3.81%		\N	\N	\N	\N
59	GOLD	New York Stock Exchange	Barrick Gold Corp.	28.4	28.91	4346674	\N	2020-08-03 10:43:06	30.2	12.65	2020-07-27 14:17:38.089826	2020-08-03 10:43:12.739623	54.59080000000001	-0.51	-0.01764	-1.76%		28.86	28.18	50496336000	11.77
60	AAPL	NASDAQ	Apple, Inc.	444.45	455.61	49511403	\N	2020-08-07 16:00:00	457.65	199.15	2020-07-27 14:25:20.968655	2020-08-08 10:53:08.525477	45.5284	-11.16	-0.02449	-2.45%		454.7	441.17	1900303753500	33.48
51	BTE	Toronto Stock Exchange	Baytex Energy Corp.	0.69	0.68	0	\N	2020-08-07 16:00:00	2.36	0.2675	2020-07-26 11:53:37.327916	2020-08-08 13:31:48.283077	-61.826899999999995	0.01	0.01471	+1.47%	-CT	1.49	0.295	0	0
66	EURUSD	\N	\N	1.17881	0	\N	\N	\N	0	0	2020-08-08 12:55:48.353558	2020-08-08 12:55:48.353558	0	0	\N	\N	fx	0	0	\N	0
25	CAT	New York Stock Exchange	Caterpillar, Inc.	134.92	134.39	2223882	\N	2020-08-07 16:00:01	150.55	87.5	2020-07-23 15:38:02.486334	2020-08-08 13:32:03.573116	-9.976	0.53	0.00394	+0.39%		135.11	132.516	73060124440	17.93
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: folio
--

COPY public.schema_migrations (version) FROM stdin;
20200717225904
20200718141110
20200719021231
20200722135550
20200723191811
20200728194336
20200802190504
20200802191220
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: folio
--

COPY public.users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, confirmation_token, confirmed_at, confirmation_sent_at, unconfirmed_email, created_at, updated_at) FROM stdin;
1	dosta@me.com	$2a$12$9PePyY8.EYOlYEoVKnYsSuue5werPY2De/TzHyu61eNrIh2NmC5VC	\N	\N	\N	14	2020-08-09 15:16:19.225904	2020-08-08 12:41:57.277204	::1	::1	nXyz3gosCxBYjxfXzKtR	2020-07-28 20:26:07.690786	2020-07-28 20:25:47.910074	\N	2020-07-28 20:25:47.909939	2020-08-09 15:16:19.226623
\.


--
-- Name: quotes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: folio
--

SELECT pg_catalog.setval('public.quotes_id_seq', 67, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: folio
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: folio
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: quotes quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: folio
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT quotes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: folio
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: folio
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: folio
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: folio
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- PostgreSQL database dump complete
--

