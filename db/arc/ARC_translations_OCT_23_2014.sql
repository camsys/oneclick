--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: temp_translations; Type: TABLE; Schema: public; Owner: u7qjm5l77mo5p9; Tablespace: 
--

CREATE TABLE temp_translations (
    id integer,
    key character varying(255),
    interpolations text,
    is_proc boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    locale character varying(255),
    value text,
    is_html boolean,
    complete boolean,
    is_list boolean
);


-- ALTER TABLE public.temp_translations OWNER TO u7qjm5l77mo5p9;

--
-- Data for Name: temp_translations; Type: TABLE DATA; Schema: public; Owner: u7qjm5l77mo5p9
--

COPY temp_translations (id, key, interpolations, is_proc, created_at, updated_at, locale, value, is_html, complete, is_list) FROM stdin;
14	mode_transit_name	\N	f	2014-07-09 21:57:32.07608	2014-09-30 02:18:34.799731	es	Transporte Público	f	f	f
46	mode_car_name	\N	f	2014-07-09 21:57:32.801183	2014-10-23 01:59:02.443816	es	Conduciendo	f	f	f
62	date_option_all_name	\N	f	2014-07-09 21:57:33.452858	2014-09-26 17:08:15.764491	es	Todos	f	f	f
66	date_option_future_name	\N	f	2014-07-09 21:57:33.536672	2014-09-26 17:08:56.424451	es	Futuro	f	f	f
72	date_option_last_30_days_name	\N	f	2014-07-09 21:57:33.671826	2014-09-26 17:10:14.187649	es	Últimos 30 Días	f	f	f
68	date_option_last_7_days_name	\N	f	2014-07-09 21:57:33.600129	2014-09-26 17:10:50.05925	es	Últimos 7 Días	f	f	f
74	date_option_next_30_days_name	\N	f	2014-07-09 21:57:33.707865	2014-09-26 17:12:46.912915	es	Los próximos 30 días	f	f	f
70	date_option_next_7_days_name	\N	f	2014-07-09 21:57:33.635294	2014-09-26 17:13:21.862713	es	Los próximos 7 días	f	f	f
64	date_option_past_name	\N	f	2014-07-09 21:57:33.500263	2014-09-26 17:15:16.635194	es	Pasado	f	f	f
42	mode_bicycle_name	\N	f	2014-07-09 21:57:32.706307	2014-09-30 01:12:25.243972	es	Bicicleta	f	f	f
6	InvalidTripsReport	\N	f	2014-07-09 21:57:31.492837	2014-09-30 00:46:16.834695	es	Informe de Viajes Invalidos	f	f	f
60	mode_bike_transit_name	\N	f	2014-07-09 21:57:33.209732	2014-09-30 01:17:56.371653	es	Bicicleta & Transporte	f	f	f
44	mode_bikeshare_name	\N	f	2014-07-09 21:57:32.747267	2014-09-30 01:18:54.903278	es	Compartir la Bicicleta	f	f	f
50	mode_bus_name	\N	f	2014-07-09 21:57:32.966782	2014-09-30 01:56:50.910479	es	Autobus	f	f	f
48	mode_walk_name	\N	f	2014-07-09 21:57:32.86716	2014-10-23 01:40:06.806359	es	Caminando	f	f	f
36	mode_paratransit_name	\N	f	2014-07-09 21:57:32.587214	2014-09-30 02:08:57.510572	es	Servicios Especializados	f	f	f
58	mode_park_transit_name	\N	f	2014-07-09 21:57:33.148746	2014-09-30 02:09:48.106201	es	Estacione y Viaje	f	f	f
52	mode_rail_name	\N	f	2014-07-09 21:57:33.008595	2014-09-30 02:10:17.555074	es	Tren	f	f	f
38	mode_taxi_name	\N	f	2014-07-09 21:57:32.628532	2014-09-30 02:14:40.617741	es	Vehículo para contratar	f	f	f
8	RejectedTripsReport	\N	f	2014-07-09 21:57:31.53371	2014-10-01 17:09:36.728614	es	Informe de Viajes Rechazados	f	f	f
34	relationship_status_hidden_name	\N	f	2014-07-09 21:57:32.552641	2014-10-01 17:14:16.962981	es	Oculto	f	f	f
28	relationship_status_confirmed_name	\N	f	2014-07-09 21:57:32.408659	2014-10-01 17:17:21.715124	es	Confirmado	f	f	f
30	relationship_status_denied_name	\N	f	2014-07-09 21:57:32.464206	2014-10-01 17:18:14.144373	es	Rechazado	f	f	f
26	relationship_status_pending_name	\N	f	2014-07-09 21:57:32.373353	2014-10-01 17:18:52.265974	es	Pendiente	f	f	f
24	relationship_status_requested_name	\N	f	2014-07-09 21:57:32.327649	2014-10-01 17:19:47.01782	es	Solicitado	f	f	f
20	trip_status_completed_name	\N	f	2014-07-09 21:57:32.206492	2014-10-04 02:27:48.13392	es	Terminado	f	f	f
32	relationship_status_revoked_name	\N	f	2014-07-09 21:57:32.498924	2014-10-01 17:24:04.037595	es	Revocar	f	f	f
22	trip_status_errored_name	\N	f	2014-07-09 21:57:32.280882	2014-10-04 02:57:17.881019	es	Con Error	f	f	f
18	trip_status_in_progress_name	\N	f	2014-07-09 21:57:32.172204	2014-10-04 02:58:24.67048	es	En Curso	f	f	f
16	trip_status_new_name	\N	f	2014-07-09 21:57:32.132201	2014-10-04 02:59:07.78279	es	Nuevo	f	f	f
10	TripsBreakdownReport	\N	f	2014-07-09 21:57:31.584065	2014-10-04 03:10:26.796268	es	Informe de Viajes Planeados	f	f	f
2	TripsCreatedByDayReport	\N	f	2014-07-09 21:57:31.384774	2014-10-04 03:11:15.250812	es	Informe de Viajes Creados	f	f	f
12	TripsDetailsReport	\N	f	2014-07-09 21:57:31.619378	2014-10-04 03:13:21.596914	es	Informe de los Detalles del Viaje	f	f	f
4	TripsScheduledByDayReport	\N	f	2014-07-09 21:57:31.438184	2014-10-04 03:15:20.338322	es	Informe del Horario de Viajes	f	f	f
56	mode_car_transit_name	\N	f	2014-07-09 21:57:33.107166	2014-10-05 01:01:09.240935	es	Un Beso y Viajo	f	f	f
138	driver_assistance_available_name	\N	f	2014-07-09 21:57:35.231993	2014-09-26 20:25:54.0442	es	Asistencia disponible del conductor.	f	f	f
134	curb_to_curb_name	\N	f	2014-07-09 21:57:35.091191	2014-09-26 16:54:06.390362	es	De acera a acera	f	f	f
108	age_name	\N	f	2014-07-09 21:57:34.499801	2014-09-26 12:57:18.984329	es	La edad es	f	f	f
130	door_to_door_name	\N	f	2014-07-09 21:57:35.008663	2014-10-04 23:58:07.730454	es	Puerta a Puerta	f	f	f
110	age_note	\N	f	2014-07-09 21:57:34.544147	2014-09-26 12:57:30.713503	es	¿Cuál es su año de nacimiento?	f	f	f
112	age_desc	\N	f	2014-07-09 21:57:34.568072	2014-09-26 12:59:03.098518	es	Usted debe tener 65 años o más para utilizar este servicio. Por favor, confirme su año de nacimiento.	f	f	f
94	ada_eligible_note	\N	f	2014-07-09 21:57:34.26813	2014-10-04 22:54:35.17647	es	¿Es elegible para ADA Servicios Especiales?	f	f	f
104	date_of_birth_name	\N	f	2014-07-09 21:57:34.441413	2014-09-26 17:06:54.213853	es	Año de nacimiento	f	f	f
106	date_of_birth_note	\N	f	2014-07-09 21:57:34.465631	2014-09-26 17:07:48.05103	es	¿Cuál es su año de nacimiento?	f	f	f
76	date_option_last_month_name	\N	f	2014-07-09 21:57:33.757559	2014-09-26 17:11:45.612663	es	Último mes	f	f	f
80	disabled_name	\N	f	2014-07-09 21:57:33.883165	2014-09-26 19:57:23.993575	es	Es Discapacitado	f	f	f
78	date_option_next_month_name	\N	f	2014-07-09 21:57:33.794882	2014-09-26 17:14:46.155818	es	Próximo mes	f	f	f
82	disabled_note	\N	f	2014-07-09 21:57:34.009688	2014-09-26 20:00:04.179233	es	¿Tiene una discapacidad permanente o temporal?	f	f	f
114	walk_distance_name	\N	f	2014-07-09 21:57:34.625553	2014-10-23 02:45:48.947865	es	Distancia caminando	f	f	f
132	door_to_door_note	\N	f	2014-07-09 21:57:35.056442	2014-09-26 20:15:51.45099	es	¿Necesita ayuda hasta su puerta?	f	f	f
140	driver_assistance_available_note	\N	f	2014-07-09 21:57:35.479152	2014-09-26 20:27:34.229084	es	¿Necesita asistencia personal del conductor?	f	f	f
118	folding_wheelchair_accessible_name	\N	f	2014-07-09 21:57:34.726651	2014-09-29 03:39:17.345211	es	Silla de ruedas plegable accesible.	f	f	f
120	folding_wheelchair_accessible_note	\N	f	2014-07-09 21:57:34.781301	2014-09-29 03:40:36.777011	es	¿Necesita un vehículo que dispone de espacio para una silla de ruedas plegable?	f	f	f
126	lift_equipped_name	\N	f	2014-07-09 21:57:34.88878	2014-09-30 01:00:11.1153	es	Vehículo Equipado con ascensor para silla de ruedas.	f	f	f
128	lift_equipped_note	\N	f	2014-07-09 21:57:34.914562	2014-09-30 01:01:04.506049	es	¿Necesita un vehículo con un ascensor?	f	f	f
100	low_income_name	\N	f	2014-07-09 21:57:34.381382	2014-09-30 01:33:51.697475	es	Es de bajos ingresos	f	f	f
102	low_income_note	\N	f	2014-07-09 21:57:34.406018	2014-09-30 01:37:03.945198	es	¿Usted recibe bajos ingresos?	f	f	f
122	motorized_wheelchair_accessible_name	\N	f	2014-07-09 21:57:34.826857	2014-09-30 02:27:49.274946	es	Accesible para una silla de ruedas motorizada.	f	f	f
124	motorized_wheelchair_accessible_note	\N	f	2014-07-09 21:57:34.852367	2014-09-30 02:32:08.478443	es	¿Necesita un vehículo que disponga de espacio para una silla de ruedas motorizada?	f	f	f
88	nemt_eligible_name	\N	f	2014-07-09 21:57:34.144323	2014-09-30 02:40:32.679175	es	Tiene Medicaid	f	f	f
90	nemt_eligible_note	\N	f	2014-07-09 21:57:34.168518	2014-09-30 02:43:30.958879	es	¿Es elegible para Medicaid?	f	f	f
84	no_trans_name	\N	f	2014-07-09 21:57:34.057089	2014-09-30 16:52:53.874964	es	No Tiene Medios de Transporte	f	f	f
86	no_trans_note	\N	f	2014-07-09 21:57:34.110582	2014-09-30 16:55:00.53597	es	¿Usted posee o tiene acceso a un vehículo personal?	f	f	f
96	veteran_name	\N	f	2014-07-09 21:57:34.302449	2014-10-04 03:55:00.984624	es	Es un Veterano	f	f	f
98	veteran_note	\N	f	2014-07-09 21:57:34.327485	2014-10-04 03:56:24.923087	es	¿Es usted un veterano militar?	f	f	f
116	walk_distance_note	\N	f	2014-07-09 21:57:34.678651	2014-10-04 04:08:47.151401	es	¿Es capaz de caminar cómodamente durante 5, 10, 15, 20, 25, 30 minutos?	f	f	f
92	ada_eligible_name	\N	f	2014-07-09 21:57:34.203042	2014-10-04 22:53:25.537263	es	¿Tiene un ADA para Servicios Especiales?	f	f	f
166	taxi_name	\N	f	2014-07-09 21:57:35.94685	2014-10-03 04:21:31.596844	es	Taxi	f	f	f
148	companion_allowed_note	\N	f	2014-07-09 21:57:35.600623	2014-10-04 23:46:30.738284	es	¿Usted viaja con un acompañante?	f	f	f
146	companion_allowed_name	\N	f	2014-07-09 21:57:35.575792	2014-10-04 23:45:34.157866	es	Compañero de Viaje Permitido	f	f	f
190	cancer_name	\N	f	2014-07-09 21:57:36.700307	2014-09-26 13:02:00.1816	es	Tratamiento del Cáncer	f	f	f
184	medical_note	\N	f	2014-07-09 21:57:36.534068	2014-10-05 00:58:31.820189	es	Viaje a un médico general	f	f	f
186	dialysis_name	\N	f	2014-07-09 21:57:36.632241	2014-09-26 19:35:44.811221	es	Diálisis	f	f	f
188	dialysis_note	\N	f	2014-07-09 21:57:36.657985	2014-09-26 19:37:50.131067	es	Cita de diálisis.	f	f	f
198	general_name	\N	f	2014-07-09 21:57:36.867228	2014-09-29 23:42:20.727752	es	Propósito General	f	f	f
200	general_note	\N	f	2014-07-09 21:57:36.890921	2014-09-29 23:44:02.729733	es	Propósito general/objetivo no especificado.	f	f	f
206	grocery_name	\N	f	2014-07-09 21:57:36.991614	2014-09-29 23:50:13.918237	es	Viaje al supermercado	f	f	f
208	grocery_note	\N	f	2014-07-09 21:57:37.018927	2014-09-29 23:51:29.822857	es	Viaje de compras al supermercado	f	f	f
182	medical_name	\N	f	2014-07-09 21:57:36.508038	2014-09-30 01:44:38.851036	es	Médico	f	f	f
150	paratransit_name	\N	f	2014-07-09 21:57:35.648923	2014-10-05 01:23:19.508694	es	Servicios Especializados	f	f	f
158	nemt_name	\N	f	2014-07-09 21:57:35.810408	2014-09-30 02:44:34.453928	es	Servicio médico no de emergencia	f	f	f
160	nemt_note	\N	f	2014-07-09 21:57:35.835645	2014-09-30 02:47:19.535493	es	Este es un servicio de transporte sólo para ser utilizado para los viajes médicos.	f	f	f
168	taxi_note	\N	f	2014-07-09 21:57:35.974801	2014-10-06 00:11:24.401208	es	Servicios de Taxi.	f	f	f
170	rideshare_name	\N	f	2014-07-09 21:57:36.140456	2014-10-01 17:54:02.998614	es	Viaje compartido	f	f	f
194	personal_name	\N	f	2014-07-09 21:57:36.782252	2014-09-30 18:12:29.33391	es	Encargo Personal	f	f	f
196	personal_note	\N	f	2014-07-09 21:57:36.807854	2014-09-30 18:14:13.362304	es	Encargo personal/viaje de compras.	f	f	f
152	paratransit_note	\N	f	2014-07-09 21:57:35.67407	2014-09-30 18:49:44.334635	es	Este es un servicio con un propósito Especializado 	f	f	f
172	rideshare_note	\N	f	2014-07-09 21:57:36.197265	2014-10-01 17:54:57.569208	es	Servicios de viajes compartidos	f	f	f
202	senior_name	\N	f	2014-07-09 21:57:36.926915	2014-10-03 02:51:58.27043	es	Visitar Centro de Personas Mayores	f	f	f
204	senior_note	\N	f	2014-07-09 21:57:36.951212	2014-10-03 02:54:30.675622	es	Viaje para visitar el Centro de Personas Mayores	f	f	f
142	stretcher_accessible_name	\N	f	2014-07-09 21:57:35.516456	2014-10-03 04:09:03.340854	es	Camilla accesible.	f	f	f
144	stretcher_accessible_note	\N	f	2014-07-09 21:57:35.54128	2014-10-03 04:10:22.602317	es	¿Necesita un vehículo que se adapte a una camilla?	f	f	f
178	training_name	\N	f	2014-07-09 21:57:36.364503	2014-10-04 01:18:08.518379	es	Capacitación/Empleo	f	f	f
180	training_note	\N	f	2014-07-09 21:57:36.389578	2014-10-04 01:19:19.13258	es	Empleo o viaje de entrenamiento.	f	f	f
164	transit_note	\N	f	2014-07-09 21:57:35.913365	2014-10-04 01:30:20.587644	es	Este es un servicio de transporte público.	f	f	f
162	transit_name	\N	f	2014-07-09 21:57:35.889133	2014-10-04 01:27:19.484864	es	Transporte Público en un ruta fija	f	f	f
154	volunteer_name	\N	f	2014-07-09 21:57:35.750574	2014-10-04 04:03:30.815705	es	Voluntario	f	f	f
156	volunteer_note	\N	f	2014-07-09 21:57:35.775947	2014-10-04 04:04:21.589475	es	Este es un servicio voluntario	f	f	f
174	work_name	\N	f	2014-07-09 21:57:36.245593	2014-10-04 04:13:34.844277	es	Trabajo	f	f	f
176	work_note	\N	f	2014-07-09 21:57:36.286471	2014-10-04 04:14:53.439332	es	Viaje relacionado con el trabajo.	f	f	f
192	cancer_note	\N	f	2014-07-09 21:57:36.72523	2014-10-04 23:27:38.962498	es	Viaje para recibir tratamiento contra el cáncer.	f	f	f
218	average	\N	f	2014-09-19 17:13:41.437983	2014-09-26 20:39:29.263935	es	Promedio	f	f	f
219	fast	\N	f	2014-09-19 17:13:41.440631	2014-09-29 03:13:38.404771	es	Rápido	f	f	f
225	remove_logo	\N	f	2014-09-19 17:13:41.578528	2014-10-01 17:26:56.401052	es	Retire el Logo	f	f	f
217	slow	\N	f	2014-09-19 17:13:41.435354	2014-10-03 03:40:50.615699	es	Lento	f	f	f
226	upload_logo	\N	f	2014-09-19 17:13:41.581225	2014-10-04 03:35:15.467998	es	Subir el Logo	f	f	f
1680	errors.messages.expired	\N	f	2014-09-19 17:14:47.253941	2014-09-19 17:14:47.253941	es	ha expirado, por favor pida uno nuevo	f	f	f
1683	errors.messages.not_locked	\N	f	2014-09-19 17:14:47.30273	2014-09-19 17:14:47.30273	es	no está bloqueada	f	f	f
1685	errors.messages.not_saved.other	\N	f	2014-09-19 17:14:47.341394	2014-09-19 17:14:47.341394	es	%{count} errores evitaron que este %{resource} fuera guardado:	f	f	f
1686	devise.failure.already_authenticated	\N	f	2014-09-19 17:14:47.356686	2014-09-19 17:14:47.356686	es	Ya estás dentro del sistema.	f	f	f
1691	devise.failure.invalid_token	\N	f	2014-09-19 17:14:47.451455	2014-09-19 17:14:47.451455	es	Ficha de autenticación invalida.	f	f	f
1694	devise.sessions.signed_in	\N	f	2014-09-19 17:14:47.501438	2014-09-19 17:14:47.501438	es	Ingreso exitoso.	f	f	f
1695	devise.sessions.signed_out	\N	f	2014-09-19 17:14:47.521495	2014-09-19 17:14:47.521495	es	Has salido del sistema.	f	f	f
1700	devise.confirmations.send_instructions	\N	f	2014-09-19 17:14:47.640324	2014-09-19 17:14:47.640324	es	Recibirás un correo electrónico con instrucciones sobre cómo confirmar tu cuenta en unos minutos.	f	f	f
1703	devise.registrations.signed_up	\N	f	2014-09-19 17:14:47.738372	2014-09-19 17:14:47.738372	es	¡Bienvenido! Has ingresado al sistema exitosamente.	f	f	f
1690	devise.failure.invalid	\N	f	2014-09-19 17:14:47.438106	2014-09-26 18:53:50.319673	es	Su correo o contraseña es inválida.	f	f	f
1681	errors.messages.not_found	\N	f	2014-09-19 17:14:47.26678	2014-09-29 02:57:26.665723	es	no se ha encontrado	f	f	f
1684	errors.messages.not_saved.one	\N	f	2014-09-19 17:14:47.319487	2014-09-29 02:58:15.700366	es	un error evitó que este %{resource} fuera guardado:	f	f	f
1774	select_agency	\N	f	2014-09-19 17:14:49.588118	2014-10-01 18:22:49.412083	es	Seleccione la Agencia	f	f	f
1693	devise.failure.inactive	\N	f	2014-09-19 17:14:47.487516	2014-10-05 00:05:17.956132	es	Su cuenta no está activa.	f	f	f
1689	devise.failure.locked	\N	f	2014-09-19 17:14:47.412937	2014-10-05 00:05:55.239456	es	Su cuenta está bloqueada.	f	f	f
1692	devise.failure.timeout	\N	f	2014-09-19 17:14:47.468602	2014-10-05 00:06:40.312383	es	Su sesión ha expirado, por favor ingrese nuevamente para continuar.	f	f	f
1687	devise.failure.unauthenticated	\N	f	2014-09-19 17:14:47.374648	2014-10-05 00:07:49.126232	es	Necesita ingresar o registrarse para continuar.	f	f	f
1688	devise.failure.unconfirmed	\N	f	2014-09-19 17:14:47.391502	2014-10-05 00:08:31.643797	es	Debe confirmar su cuenta para continuar.	f	f	f
1696	devise.passwords.send_instructions	\N	f	2014-09-19 17:14:47.53848	2014-10-05 00:10:41.430156	es	Recibirá un correo electrónico con instrucciones sobre cómo reiniciar su contraseña en unos minutos.	f	f	f
1699	devise.passwords.send_paranoid_instructions	\N	f	2014-09-19 17:14:47.611542	2014-10-05 00:11:44.111818	es	Si su correo electrónico existe en nuestra base de datos, recibirá un enlace para reiniciar su contraseña en unos minutos.	f	f	f
1697	devise.passwords.updated	\N	f	2014-09-19 17:14:47.562681	2014-10-05 00:12:45.497756	es	Su contraseña fue cambiada exitosamente y ha sido ingresada al sistema.	f	f	f
1698	devise.passwords.updated_not_active	\N	f	2014-09-19 17:14:47.58476	2014-10-05 00:13:31.210081	es	Su contraseña se cambió exitosamente.	f	f	f
1704	devise.registrations.inactive_signed_up	\N	f	2014-09-19 17:14:47.772128	2014-10-05 00:16:14.883273	es	Se has registrado exitosamente; sin embargo, no lo hemos podido ingresar debido a que su cuenta está %{reason}.	f	f	f
1705	devise.registrations.updated	\N	f	2014-09-19 17:14:47.807467	2014-10-05 00:17:57.860472	es	Actualizó su cuenta exitosamente.	f	f	f
1682	errors.messages.already_confirmed	\N	f	2014-09-19 17:14:47.280658	2014-10-05 00:36:23.712372	es	ya está confirmado, por favor intente ingresar	f	f	f
1707	devise.registrations.reasons.inactive	\N	f	2014-09-19 17:14:47.875351	2014-09-19 17:14:47.875351	es	inactiva	f	f	f
1708	devise.registrations.reasons.unconfirmed	\N	f	2014-09-19 17:14:47.909697	2014-09-19 17:14:47.909697	es	sin confirmar	f	f	f
1709	devise.registrations.reasons.locked	\N	f	2014-09-19 17:14:47.934627	2014-09-19 17:14:47.934627	es	bloqueada	f	f	f
1713	devise.omniauth_callbacks.success	\N	f	2014-09-19 17:14:48.153389	2014-09-19 17:14:48.153389	es	Exitosamente autorizado desde la cuenta %{kind}.	f	f	f
1715	devise.mailer.confirmation_instructions.subject	\N	f	2014-09-19 17:14:48.244166	2014-09-19 17:14:48.244166	es	Instrucciones de Confirmación	f	f	f
1716	devise.mailer.reset_password_instructions.subject	\N	f	2014-09-19 17:14:48.2722	2014-09-19 17:14:48.2722	es	Instrucciones de reinicio de contraseña	f	f	f
1718	simple_form.yes	\N	f	2014-09-19 17:14:48.380761	2014-09-19 17:14:48.380761	es	Si	f	f	f
1719	simple_form.no	\N	f	2014-09-19 17:14:48.40235	2014-09-19 17:14:48.40235	es	No	f	f	f
1721	simple_form.required.mark	\N	f	2014-09-19 17:14:48.462008	2014-09-19 17:14:48.462008	es	*	f	f	f
1732	one_click_trip_planner	\N	f	2014-09-19 17:14:48.667986	2014-09-19 17:14:48.667986	es	1-Click Planificador de Viajes	f	f	f
1733	plan_a_trip	\N	f	2014-09-19 17:14:48.681456	2014-09-19 17:14:48.681456	es	Planear un Viaje	f	f	f
1734	plan_a_new_trip	\N	f	2014-09-19 17:14:48.696164	2014-09-19 17:14:48.696164	es	Planear un Viaje Nuevo	f	f	f
1735	identify_places	\N	f	2014-09-19 17:14:48.717229	2014-09-19 17:14:48.717229	es	Identificar los Lugares	f	f	f
1736	change_my_settings	\N	f	2014-09-19 17:14:48.732328	2014-09-19 17:14:48.732328	es	Cambiar mi Configuración	f	f	f
1738	create_an_account	\N	f	2014-09-19 17:14:48.764988	2014-09-19 17:14:48.764988	es	Crear una Cuenta	f	f	f
1739	travel_profile	\N	f	2014-09-19 17:14:48.777868	2014-09-19 17:14:48.777868	es	Perfil del Viaje	f	f	f
1742	my_trips	\N	f	2014-09-19 17:14:48.833802	2014-09-19 17:14:48.833802	es	Mis Viajes	f	f	f
1750	find_traveler	\N	f	2014-09-19 17:14:49.058227	2014-09-19 17:14:49.058227	es	Encontrar al Viajero	f	f	f
1751	create_traveler	\N	f	2014-09-19 17:14:49.081852	2014-09-19 17:14:49.081852	es	Crear un Viajero	f	f	f
1766	my_agencies	\N	f	2014-09-19 17:14:49.439972	2014-09-30 02:32:50.214279	es	Mis Agencias	f	f	f
1756	add_new_agency	\N	f	2014-09-19 17:14:49.21551	2014-09-26 12:53:50.109259	es	Añadir una nueva Agencia	f	f	f
1757	agency_added	\N	f	2014-09-19 17:14:49.235379	2014-09-26 12:55:26.610945	es	Agencia añadida	f	f	f
1753	agency	\N	f	2014-09-19 17:14:49.149186	2014-09-26 12:57:55.270824	es	Agencia	f	f	f
1755	all_agencies	\N	f	2014-09-19 17:14:49.195909	2014-09-26 13:23:31.199998	es	Todas las Agencias	f	f	f
1769	agency_now_assisting	\N	f	2014-09-19 17:14:49.497921	2014-09-26 12:55:59.272839	es	%{agency} ahora ayudando	f	f	f
1762	agency_profile	\N	f	2014-09-19 17:14:49.348087	2014-09-26 12:56:14.647985	es	Perfil de la Agencia	f	f	f
1754	agencies	\N	f	2014-09-19 17:14:49.178055	2014-09-26 12:57:43.652543	es	Agencias	f	f	f
1743	my_places	\N	f	2014-09-19 17:14:48.851549	2014-09-26 13:26:42.341711	es	Mis Lugares	f	f	f
1725	base_rate	\N	f	2014-09-19 17:14:48.547229	2014-09-25 17:38:56.598821	es	Tarifa Basica	f	f	f
1761	add_agency	\N	f	2014-09-19 17:14:49.323711	2014-09-26 12:52:50.306123	es	Añadir Agencia	f	f	f
1745	places	\N	f	2014-09-19 17:14:48.903336	2014-09-26 13:27:17.039807	es	Lugares	f	f	f
1760	create_agency	\N	f	2014-09-19 17:14:49.302179	2014-09-26 16:48:44.376192	es	Crear Agencia	f	f	f
1710	devise.unlocks.send_instructions	\N	f	2014-09-19 17:14:47.984822	2014-10-05 00:18:48.19058	es	Recibirá un correo electrónico con instrucciones sobre cómo desbloquear su cuenta en unos minutos.	f	f	f
1763	edit_agency_name	\N	f	2014-09-19 17:14:49.371829	2014-09-26 20:28:37.237588	es	Editar %{name}	f	f	f
1737	help_and_support	\N	f	2014-09-19 17:14:48.748328	2014-09-29 23:54:04.817842	es	Ayuda y Apoyo	f	f	f
1752	feedback	\N	f	2014-09-19 17:14:49.107876	2014-09-29 03:21:36.695994	es	Comentario	f	f	f
1726	mileage_rate	\N	f	2014-09-19 17:14:48.564939	2014-09-30 01:48:30.512554	es	Tarifa por distancia\r\n	f	f	f
1747	my_home_chkbox_label	\N	f	2014-09-19 17:14:48.949608	2014-09-30 02:35:21.985814	es	Esta es mi casa	f	f	f
1740	my_travel_profile	\N	f	2014-09-19 17:14:48.789967	2014-09-30 02:36:41.175022	es	Mi Perfil del Viaje	f	f	f
1773	new_agency	\N	f	2014-09-19 17:14:49.571457	2014-09-30 02:48:24.83578	es	Nueva Agencia	f	f	f
1741	my_travelers	\N	f	2014-09-19 17:14:48.808097	2014-09-30 02:42:26.234679	es	Mis Viajeros	f	f	f
1768	no_agency_selected	\N	f	2014-09-19 17:14:49.478358	2014-09-30 03:09:10.417317	es	Debe entrar el nombre de la agencia que desee le ayude.	f	f	f
1767	not_any_agencies	\N	f	2014-09-19 17:14:49.459427	2014-09-30 17:03:18.438999	es	Usted no ha aprobado ninguna agencia para ayudarle	f	f	f
1723	only_agency_can_see	\N	f	2014-09-19 17:14:48.504811	2014-09-30 17:30:51.142693	es	Solamente el personal de %{agency} puede ver esta nota.	f	f	f
1748	more_about_this_initiative	\N	f	2014-09-19 17:14:48.998401	2014-10-23 03:04:47.382681	es	Acerca de Simply Get There	f	f	f
1770	parent_agency	\N	f	2014-09-19 17:14:49.512348	2014-09-30 18:10:41.634871	es	Agencia Principal	f	f	f
1744	place	\N	f	2014-09-19 17:14:48.872118	2014-09-30 18:15:48.03992	es	Lugar	f	f	f
1729	private_comments	\N	f	2014-09-19 17:14:48.610979	2014-10-01 16:15:54.146628	es	Comentarios Privados	f	f	f
1727	trip_planned_assistance	\N	f	2014-09-19 17:14:48.580956	2014-10-06 00:17:31.470381	es	Viaje planificado con la ayuda de 	f	f	f
1728	public_comments	\N	f	2014-09-19 17:14:48.596348	2014-10-01 16:27:39.161985	es	Comentarios del Público	f	f	f
1730	public_comments_message	\N	f	2014-09-19 17:14:48.62897	2014-10-01 16:28:38.435897	es	Deje sus comentarios para los viajeros acerca de este servicio.	f	f	f
1765	remove_agency	\N	f	2014-09-19 17:14:49.423525	2014-10-01 17:25:10.858994	es	Retire la Agencia	f	f	f
1722	simple_form.error_notification.default_message	\N	f	2014-09-19 17:14:48.475341	2014-10-03 03:37:58.126632	es	Por favor, corrija los problemas a continuación.	f	f	f
1720	simple_form.required.text	\N	f	2014-09-19 17:14:48.438023	2014-10-03 03:39:05.189159	es	requerido	f	f	f
1758	specific_agency_added	\N	f	2014-09-19 17:14:49.264778	2014-10-03 03:46:27.201231	es	{agency} añadido	f	f	f
1772	subagencies	\N	f	2014-09-19 17:14:49.552687	2014-10-03 04:11:19.452209	es	Sub-agencias	f	f	f
1724	traveler_notes	\N	f	2014-09-19 17:14:48.5292	2014-10-04 02:09:19.379805	es	Notas del Viajero	f	f	f
1771	parent	\N	f	2014-09-19 17:14:49.534629	2014-10-23 03:02:42.641788	es	Agencias	f	f	f
1746	type	\N	f	2014-09-19 17:14:48.930988	2014-10-04 03:16:26.096585	es	Escriba	f	f	f
1764	update_agency	\N	f	2014-09-19 17:14:49.398509	2014-10-04 03:32:07.281503	es	Actualice la Agencia	f	f	f
1759	user_created_and_added_to_agency	\N	f	2014-09-19 17:14:49.280002	2014-10-04 03:43:56.3734	es	Usuario %{user} creado y añadido a la agencia %{agency}	f	f	f
1717	devise.mailer.unlock_instructions.subject	\N	f	2014-09-19 17:14:48.294235	2014-10-04 23:55:02.319646	es	Instrucciones de como desbloquear	f	f	f
1714	devise.omniauth_callbacks.failure	\N	f	2014-09-19 17:14:48.213254	2014-10-05 00:09:49.246453	es	No le pudimos autorizar en %{kind} debido a "%{reason}".	f	f	f
1712	devise.unlocks.send_paranoid_instructions	\N	f	2014-09-19 17:14:48.084816	2014-10-05 00:19:32.685715	es	Si su cuenta existe, recibirá un correo electrónico con instrucciones sobre cómo desbloquear su cuenta en unos minutos.	f	f	f
1711	devise.unlocks.unlocked	\N	f	2014-09-19 17:14:48.020874	2014-10-05 00:20:24.37673	es	Su cuenta fue desbloqueada con éxito, ha sido ingresada al sistema.	f	f	f
1731	private_comments_message	\N	f	2014-09-19 17:14:48.650919	2014-10-05 23:56:57.921121	es	Deje sus comentarios para los agentes acerca de este servicio.	f	f	f
1783	editing_org	\N	f	2014-09-19 17:14:49.785849	2014-09-19 17:14:49.785849	es	[es30]Editing organization[/es]	f	f	f
1798	reports	\N	f	2014-09-19 17:14:50.030723	2014-09-19 17:14:50.030723	es	Reportes	f	f	f
1818	send_by_email	\N	f	2014-09-19 17:14:50.287001	2014-09-19 17:14:50.287001	es	Enviar por correo electrónico	f	f	f
1830	version	\N	f	2014-09-19 17:14:50.445761	2014-09-19 17:14:50.445761	es	Versión	f	f	f
1831	home	\N	f	2014-09-19 17:14:50.467296	2014-09-19 17:14:50.467296	es	Inicio	f	f	f
1832	log_in	\N	f	2014-09-19 17:14:50.482118	2014-09-19 17:14:50.482118	es	Entrar	f	f	f
1833	sign_up	\N	f	2014-09-19 17:14:50.513959	2014-09-19 17:14:50.513959	es	Registrarse	f	f	f
1835	welcome	\N	f	2014-09-19 17:14:50.539714	2014-09-19 17:14:50.539714	es	Bienvenido	f	f	f
1836	first_name	\N	f	2014-09-19 17:14:50.55144	2014-09-19 17:14:50.55144	es	Nombre	f	f	f
1837	last_name	\N	f	2014-09-19 17:14:50.562363	2014-09-19 17:14:50.562363	es	Apellido	f	f	f
1838	email	\N	f	2014-09-19 17:14:50.572959	2014-09-19 17:14:50.572959	es	Correo electrónico	f	f	f
1843	password	\N	f	2014-09-19 17:14:50.628594	2014-09-19 17:14:50.628594	es	Contraseña	f	f	f
1845	current_password	\N	f	2014-09-19 17:14:50.653574	2014-09-19 17:14:50.653574	es	Contraseña actual	f	f	f
1846	forgot_your_password	\N	f	2014-09-19 17:14:50.664229	2014-09-19 17:14:50.664229	es	¿Olvidó su contraseña?	f	f	f
1848	logout	\N	f	2014-09-19 17:14:50.695146	2014-09-19 17:14:50.695146	es	Salir	f	f	f
1849	edit_account	\N	f	2014-09-19 17:14:50.705345	2014-09-19 17:14:50.705345	es	Editar la cuenta	f	f	f
1842	remember_me	\N	f	2014-09-19 17:14:50.617509	2014-09-26 13:27:54.434574	es	Acuérdate de mí	f	f	f
1813	admin_actions	\N	f	2014-09-19 17:14:50.230632	2014-09-26 12:49:03.973358	es	Administración	f	f	f
1808	administrators	\N	f	2014-09-19 17:14:50.171305	2014-09-26 12:49:19.421754	es	Administradores	f	f	f
1807	agents	\N	f	2014-09-19 17:14:50.153237	2014-09-26 12:58:09.057945	es	Agentes	f	f	f
1841	address	\N	f	2014-09-19 17:14:50.607395	2014-09-26 12:58:46.962205	es	Dirección	f	f	f
1805	export	\N	f	2014-09-19 17:14:50.121817	2014-09-29 03:01:27.380813	es	Exportar	f	f	f
1792	agents_agencies	\N	f	2014-09-19 17:14:49.950082	2014-09-25 16:44:15.82247	es	Agencias, Proveedores, Usuarios	f	f	f
1812	admin	\N	f	2014-09-19 17:14:50.219621	2014-09-26 12:48:49.712085	es	Administración	f	f	f
1793	confirm_msg	\N	f	2014-09-19 17:14:49.965195	2014-10-04 23:48:36.57248	es	¿Está seguro?	f	f	f
1817	key	\N	f	2014-09-19 17:14:50.276001	2014-10-05 00:54:08.11774	es	Llave	f	f	f
1816	create_translation	\N	f	2014-09-19 17:14:50.265051	2014-09-26 16:49:36.283549	es	Crear Traducción	f	f	f
1809	create_user	\N	f	2014-09-19 17:14:50.184693	2014-09-26 16:50:27.056695	es	Crear Usuario	f	f	f
1800	date_range	\N	f	2014-09-19 17:14:50.058367	2014-09-26 17:30:22.969758	es	Intervalo de fechas	f	f	f
1795	delete_user	\N	f	2014-09-19 17:14:49.990518	2014-09-26 17:34:12.667334	es	Eliminar el usuario	f	f	f
1802	display_type	\N	f	2014-09-19 17:14:50.08343	2014-09-26 20:02:31.416256	es	Mostrar tipo	f	f	f
1828	do_you_participate	\N	f	2014-09-19 17:14:50.418233	2014-09-26 20:07:00.000139	es	¿Participa actualmente en alguno de estos programas?	f	f	f
1819	email_sent_to	\N	f	2014-09-19 17:14:50.298464	2014-09-26 20:35:29.77714	es	Un correo electrónico fue enviado a %{email_sent_to}	f	f	f
1782	back_to_providers	\N	f	2014-09-19 17:14:49.762483	2014-09-26 20:41:03.823802	es	Volver a los Proveedores	f	f	f
1844	password_confirmation	\N	f	2014-09-19 17:14:50.640644	2014-10-05 01:24:16.709075	es	Confirmación de la contraseña	f	f	f
1784	listing_orgs	\N	f	2014-09-19 17:14:49.802169	2014-09-30 01:11:32.904185	es	Lista de Organizaciones 	f	f	f
1788	new_organization	\N	f	2014-09-19 17:14:49.890267	2014-09-30 02:56:16.749633	es	Nueva Organización 	f	f	f
1776	new_provider	\N	f	2014-09-19 17:14:49.621338	2014-09-30 02:57:03.283938	es	Nuevo Proveedor	f	f	f
1786	new_provider_org	\N	f	2014-09-19 17:14:49.84488	2014-09-30 02:58:57.914345	es	Nueva Organización de Proveedores	f	f	f
1820	no_email_found	\N	f	2014-09-19 17:14:50.310021	2014-09-30 03:18:34.485696	es	No se encontró el correo electrónico	f	f	f
1787	org_type	\N	f	2014-09-19 17:14:49.862666	2014-09-30 17:34:16.039509	es	Tipo de Org	f	f	f
1839	preferred_locale	\N	f	2014-09-19 17:14:50.583754	2014-09-30 18:35:45.785284	es	Idioma preferido	f	f	f
1840	preferred_modes	\N	f	2014-09-19 17:14:50.596506	2014-09-30 18:36:37.037214	es	Modos preferidos	f	f	f
1829	programs	\N	f	2014-09-19 17:14:50.433969	2014-10-01 16:19:14.275001	es	Programas	f	f	f
1791	provided_by	\N	f	2014-09-19 17:14:49.934107	2014-10-01 16:20:15.608686	es	Proporcionado por	f	f	f
1775	provider	\N	f	2014-09-19 17:14:49.60409	2014-10-01 16:21:26.176211	es	Proveedor	f	f	f
1790	provider_info	\N	f	2014-09-19 17:14:49.920883	2014-10-01 16:22:31.710059	es	Información del Proveedor	f	f	f
1789	provider_name	\N	f	2014-09-19 17:14:49.904787	2014-10-01 16:23:21.032377	es	Nombre del Proveedor	f	f	f
1785	provider_orgs	\N	f	2014-09-19 17:14:49.821471	2014-10-01 16:24:51.076359	es	 Organización del Proveedor	f	f	f
1779	provider_profile	\N	f	2014-09-19 17:14:49.687254	2014-10-01 16:25:36.731961	es	Perfil del Provider	f	f	f
1780	providers	\N	f	2014-09-19 17:14:49.716334	2014-10-01 16:26:30.249423	es	Proveedores	f	f	f
1777	remove_provider	\N	f	2014-09-19 17:14:49.641762	2014-10-01 17:30:11.76633	es	Elimine el Proveedor	f	f	f
1799	report_name	\N	f	2014-09-19 17:14:50.046152	2014-10-01 17:32:28.335212	es	Nombre del informe	f	f	f
1847	retype_your_password	\N	f	2014-09-19 17:14:50.674786	2014-10-01 17:51:58.363008	es	Vuelva a escribir su contraseña 	f	f	f
1804	run	\N	f	2014-09-19 17:14:50.108029	2014-10-01 17:59:42.189101	es	Corre	f	f	f
1781	select_provider	\N	f	2014-09-19 17:14:49.736084	2014-10-01 18:27:10.387853	es	Seleccione un Proveedor	f	f	f
1821	send_itinerary_by_email	\N	f	2014-09-19 17:14:50.322468	2014-10-03 02:36:13.357334	es	Enviar el itinerario por correo electrónico	f	f	f
1822	send_trip_by_email	\N	f	2014-09-19 17:14:50.336518	2014-10-03 02:41:20.107626	es	Enviar plan de viaje por correo electrónico	f	f	f
1823	send_follow_up_email	\N	f	2014-09-19 17:14:50.349274	2014-10-03 02:35:33.63361	es	Enviar un correo electrónico de Seguimiento	f	f	f
1824	sidewalk_obstructions	\N	f	2014-09-19 17:14:50.364854	2014-10-03 03:29:53.339314	es	Obstrucciones en las Aceras	f	f	f
1826	sidewalk_obstructions_update.other	\N	f	2014-09-19 17:14:50.391056	2014-10-03 03:33:33.798334	es	La obstrucciones en las aceras se han modernizado	f	f	f
1825	sidewalk_obstructions_update.one	\N	f	2014-09-19 17:14:50.378896	2014-10-03 03:32:04.775588	es	La obstrucción en la acera se ha modernizado	f	f	f
1834	sign_up_and_plan	\N	f	2014-09-19 17:14:50.52719	2014-10-03 03:36:41.420025	es	Registrarme y planificar mi viaje	f	f	f
1814	staff_actions	\N	f	2014-09-19 17:14:50.242275	2014-10-03 04:01:14.753096	es	Personal	f	f	f
1803	summary_type	\N	f	2014-09-19 17:14:50.095902	2014-10-03 04:16:32.769327	es	Tipo de Resumen	f	f	f
1815	translations	\N	f	2014-09-19 17:14:50.253706	2014-10-04 01:35:27.92695	es	Traducciones y Contenido	f	f	f
1801	traveler_type	\N	f	2014-09-19 17:14:50.07005	2014-10-04 01:43:17.767344	es	Tipo de Viajero	f	f	f
1810	user_created	\N	f	2014-09-19 17:14:50.197864	2014-10-04 03:42:58.472969	es	Se ha creado un usuario	f	f	f
1811	user_deleted	\N	f	2014-09-19 17:14:50.208799	2014-10-04 03:46:29.738578	es	Usuario eliminado	f	f	f
1806	users	\N	f	2014-09-19 17:14:50.139252	2014-10-04 03:48:24.759855	es	Usuarios	f	f	f
1797	walking_maximum_distance	\N	f	2014-09-19 17:14:50.016561	2014-10-04 04:11:10.02331	es	Distancia Máxima a Pie	f	f	f
1796	walking_speed	\N	f	2014-09-19 17:14:50.003937	2014-10-04 04:12:15.179473	es	Velocidad del recorrido	f	f	f
1794	change_role	\N	f	2014-09-19 17:14:49.978008	2014-10-04 23:36:01.769956	es	Cambiar el papel	f	f	f
1850	update_my_profile	\N	f	2014-09-19 17:14:50.715343	2014-09-19 17:14:50.715343	es	Actualizar mi perfil	f	f	f
1851	current_password_hint	\N	f	2014-09-19 17:14:50.725439	2014-09-19 17:14:50.725439	es	Introduce tu contraseña actual para guardar los cambios.	f	f	f
1853	my_information	\N	f	2014-09-19 17:14:50.745399	2014-09-19 17:14:50.745399	es	Mi información	f	f	f
1855	buddies	\N	f	2014-09-19 17:14:50.765695	2014-09-19 17:14:50.765695	es	Amigos	f	f	f
1856	travelers	\N	f	2014-09-19 17:14:50.775988	2014-09-19 17:14:50.775988	es	Viajeros	f	f	f
1857	traveler	\N	f	2014-09-19 17:14:50.786079	2014-09-19 17:14:50.786079	es	Viajero	f	f	f
1861	send_buddy_request	\N	f	2014-09-19 17:14:50.827118	2014-09-19 17:14:50.827118	es	Enviar solicitud de amigo	f	f	f
1862	buddys_email_address	\N	f	2014-09-19 17:14:50.837124	2014-09-19 17:14:50.837124	es	Correo electrónico del amigo	f	f	f
1869	accept	\N	f	2014-09-19 17:14:50.909751	2014-09-19 17:14:50.909751	es	Aceptar	f	f	f
1870	decline	\N	f	2014-09-19 17:14:50.920231	2014-09-19 17:14:50.920231	es	Rechazar	f	f	f
1871	assist	\N	f	2014-09-19 17:14:50.930704	2014-09-19 17:14:50.930704	es	Asistir	f	f	f
1875	retract	\N	f	2014-09-19 17:14:50.973766	2014-09-19 17:14:50.973766	es	Retraer	f	f	f
1876	revoke	\N	f	2014-09-19 17:14:50.984973	2014-09-19 17:14:50.984973	es	Revocar	f	f	f
1888	buddy_request_sent	\N	f	2014-09-19 17:14:51.124846	2014-09-19 17:14:51.124846	es	¡Solicitud de amigo enviada!	f	f	f
1893	no_user_with_email_address	\N	f	2014-09-19 17:14:51.191525	2014-09-19 17:14:51.191525	es	No podemos encontrar un usuario registrado con '%{email}' como su dirección de correo electrónico.	f	f	f
1894	something_went_wrong	\N	f	2014-09-19 17:14:51.202627	2014-09-19 17:14:51.202627	es	Ooops! Algo salió mal. No hemos podido procesar la solicitud. Por favor, inténtelo de nuevo.	f	f	f
1895	request_processed	\N	f	2014-09-19 17:14:51.213337	2014-09-19 17:14:51.213337	es	Su solicitud ha sido procesada.	f	f	f
1896	spanish	\N	f	2014-09-19 17:14:51.224652	2014-09-19 17:14:51.224652	es	En Español	f	f	f
1897	error_not_implemented	\N	f	2014-09-19 17:14:51.236718	2014-09-19 17:14:51.236718	es	Lo sentimos, pero esta funcionalidad aún no se ha implementado.	f	f	f
1898	error_404	\N	f	2014-09-19 17:14:51.248017	2014-09-19 17:14:51.248017	es	La página que estás buscando no existe.	f	f	f
1859	authorized_travelers	\N	f	2014-09-19 17:14:50.80727	2014-09-26 20:38:51.595346	es	Los Viajeros Autorizados	f	f	f
1902	error_couldnt_plan	\N	f	2014-09-19 17:14:51.296718	2014-09-29 02:55:56.814777	es	No se pudo crear su plan de viaje. Esto es probablemente debido a un error del sistema, y nuestro personal ha sido notificado. Por favor, ingrese los datos de su viaje una vez mas.	f	f	f
1866	buddy_request_email_step_2	\N	f	2014-09-19 17:14:50.876947	2014-10-04 23:13:50.412198	es	2 - Mostrar su Perfil de Viajero (Menu de Bienvenida -> Perfil del Viajero)	f	f	f
1865	buddy_request_email_step_1	\N	f	2014-09-19 17:14:50.866873	2014-10-04 23:12:36.968571	es	1 - Inicie sesión	f	f	f
1868	buddy_request_email_step_4	\N	f	2014-09-19 17:14:50.899595	2014-10-04 23:15:24.043538	es	4 - En la sección de Amigos "Aceptar" la solicitud de %{name}	f	f	f
1867	buddy_request_email_step_3	\N	f	2014-09-19 17:14:50.887793	2014-10-04 23:14:42.34805	es	3 - Edite su perfil	f	f	f
1899	error_404_mistyped	\N	f	2014-09-19 17:14:51.258843	2014-10-05 00:33:36.572717	es	Es posible que haya escrito mal la dirección o la página puede haber cambiado.	f	f	f
1874	can_assist_me	\N	f	2014-09-19 17:14:50.962497	2014-10-04 23:24:46.506348	es	Me podrían ayudar	f	f	f
1904	actions	\N	f	2014-09-19 17:14:51.319565	2014-09-26 12:50:41.924652	es	Acciones	f	f	f
1905	filter	\N	f	2014-09-19 17:14:51.33016	2014-09-26 13:26:17.992391	es	Filtrar	f	f	f
1909	rating_submitted_for_approval.one	\N	f	2014-09-19 17:14:51.372205	2014-10-01 16:39:03.676895	es	Su %{rateable} calificación se ha presentado para su aprobación	f	f	f
1877	visitor	\N	f	2014-09-19 17:14:50.995712	2014-09-26 13:29:28.286605	es	Visitante	f	f	f
1872	assisted_by	\N	f	2014-09-19 17:14:50.94167	2014-09-26 13:30:16.488372	es	Ayudado Por	f	f	f
1883	follow_up_questions	\N	f	2014-09-19 17:14:51.067258	2014-09-29 23:36:12.940536	es	Algunas Preguntas de Seguimiento	f	f	f
1873	i_can_assist	\N	f	2014-09-19 17:14:50.952236	2014-10-05 00:49:12.686555	es	Le Podría Ayudar	f	f	f
1878	include_visitors	\N	f	2014-09-19 17:14:51.006646	2014-10-05 00:51:11.783215	es	Incluye Visitantes	f	f	f
1852	leave_password_blank	\N	f	2014-09-19 17:14:50.735372	2014-10-05 00:55:44.83575	es	Deje ambas casillas en blanco si no quiere cambiar su contraseña.	f	f	f
1880	invalid_dob	\N	f	2014-09-19 17:14:51.033072	2014-09-30 00:42:03.573096	es	Invalida fecha de nacimiento *33*	f	f	f
1885	next_step	\N	f	2014-09-19 17:14:51.090299	2014-09-30 02:59:46.182516	es	Siguiente Paso	f	f	f
1858	matching_travelers	\N	f	2014-09-19 17:14:50.796253	2014-09-30 01:41:53.0894	es	Viajero a tono	f	f	f
1889	no_buddy_email_address	\N	f	2014-09-19 17:14:51.139324	2014-09-30 03:13:21.65401	es	Debe introducir la dirección de correo electrónico de su amigo.	f	f	f
1907	no_rating	\N	f	2014-09-19 17:14:51.351188	2014-09-30 16:44:00.237014	es	Sin Clasificar	f	f	f
1908	no_ratings_yet	\N	f	2014-09-19 17:14:51.361813	2014-09-30 16:48:27.251871	es	No se ha aprobado una clasificación	f	f	f
1881	plan_with_you_in_mind	\N	f	2014-09-19 17:14:51.043479	2014-09-30 18:24:20.353896	es	Nos gustaría planear un viaje con sus necesidades en mente.	f	f	f
1879	questions	\N	f	2014-09-19 17:14:51.02274	2014-10-01 16:29:07.880139	es	Preguntas	f	f	f
1910	rating_submitted_for_approval.other	\N	f	2014-09-19 17:14:51.382664	2014-10-01 16:42:44.706527	es	Sus %{rateable} calificaciones han sido presentadas para su aprobación	f	f	f
1903	rating	\N	f	2014-09-19 17:14:51.307817	2014-10-01 16:39:51.111356	es	Calificación	f	f	f
1913	rating_targets	\N	f	2014-09-19 17:14:51.414011	2014-10-01 16:43:35.779606	es	Viaje / Agencia / Servicio	f	f	f
1911	rating_update.one	\N	f	2014-09-19 17:14:51.393446	2014-10-01 16:58:49.705149	es	La calificación ha sido actualizada	f	f	f
1912	rating_update.other	\N	f	2014-09-19 17:14:51.403591	2014-10-01 17:00:03.633825	es	Las calificaciones han sido actualizadas	f	f	f
1906	ratings	\N	f	2014-09-19 17:14:51.340809	2014-10-01 17:00:58.542195	es	Calificaciones	f	f	f
1890	register	\N	f	2014-09-19 17:14:51.154501	2014-10-01 17:02:57.518306	es	Registrarse	f	f	f
1891	registered	\N	f	2014-09-19 17:14:51.16733	2014-10-01 17:07:11.396434	es	Registrado	f	f	f
1887	skip_this_step	\N	f	2014-09-19 17:14:51.112582	2014-10-03 03:40:10.183322	es	Saltar este paso	f	f	f
1886	step_one_of	\N	f	2014-09-19 17:14:51.101249	2014-10-03 04:06:57.273479	es	Paso 1 de	f	f	f
1882	to_see_best_options	\N	f	2014-09-19 17:14:51.053535	2014-10-04 01:16:44.660396	es	Para ver las mejores opciones, cuéntenos acerca de usted.	f	f	f
1854	user_information	\N	f	2014-09-19 17:14:50.755409	2014-10-04 03:47:10.586825	es	Información del usuario	f	f	f
1864	buddy_request_email_step_0	\N	f	2014-09-19 17:14:50.856831	2014-10-04 23:11:01.200615	es	Para aceptar la solicitud:	f	f	f
1900	error_422	\N	f	2014-09-19 17:14:51.272982	2014-10-05 00:34:27.606599	es	El cambio que solicita fue rechazado.	f	f	f
1901	error_422_detail	\N	f	2014-09-19 17:14:51.284546	2014-10-05 00:35:17.85664	es	Tal vez trató de cambiar algo al que no tiene acceso.	f	f	f
1892	have_an_account_question	\N	f	2014-09-19 17:14:51.179691	2014-10-05 00:43:29.452726	es	¿Tiene una cuenta?	f	f	f
1924	plan_trip	\N	f	2014-09-19 17:14:51.531566	2014-09-19 17:14:51.531566	es	Continuar la planificación de este viaje *44*	f	f	f
1930	select_or_enter_address	\N	f	2014-09-19 17:14:51.6088	2014-09-19 17:14:51.6088	es	Selecciona o introduce la dirección 	f	f	f
1931	select	\N	f	2014-09-19 17:14:51.621696	2014-09-19 17:14:51.621696	es	Seleccionar	f	f	f
1933	depart_at	\N	f	2014-09-19 17:14:51.646443	2014-09-19 17:14:51.646443	es	Salir a las	f	f	f
1934	arrive_by	\N	f	2014-09-19 17:14:51.661663	2014-09-19 17:14:51.661663	es	Llegar a las	f	f	f
1935	arrive_at	\N	f	2014-09-19 17:14:51.677637	2014-09-19 17:14:51.677637	es	Llegar a	f	f	f
1940	trip_time	\N	f	2014-09-19 17:14:51.758066	2014-09-19 17:14:51.758066	es	Hora	f	f	f
1944	cancel	\N	f	2014-09-19 17:14:51.83038	2014-09-19 17:14:51.83038	es	Cancelar	f	f	f
1945	plan_it	\N	f	2014-09-19 17:14:51.845881	2014-09-19 17:14:51.845881	es	Planear el viaje	f	f	f
1951	from	\N	f	2014-09-19 17:14:51.928799	2014-09-19 17:14:51.928799	es	De	f	f	f
1956	to	\N	f	2014-09-19 17:14:51.98474	2014-09-19 17:14:51.98474	es	A	f	f	f
1961	at_time	\N	f	2014-09-19 17:14:52.038045	2014-09-19 17:14:52.038045	es	en	f	f	f
1979	taxi	\N	f	2014-09-19 17:14:52.237762	2014-09-19 17:14:52.237762	es	Taxi	f	f	f
1980	transit	\N	f	2014-09-19 17:14:52.250184	2014-09-19 17:14:52.250184	es	Transporte Público	f	f	f
1981	details	\N	f	2014-09-19 17:14:52.261287	2014-09-19 17:14:52.261287	es	Detalles	f	f	f
1984	rideshare	\N	f	2014-09-19 17:14:52.303398	2014-09-19 17:14:52.303398	es	Para Compartir el Viaje	f	f	f
1985	walk	\N	f	2014-09-19 17:14:52.31451	2014-09-19 17:14:52.31451	es	Caminar	f	f	f
1962	arrive_depart	\N	f	2014-09-19 17:14:52.047885	2014-09-26 13:24:54.785045	es	Llegada/Salida	f	f	f
1943	apply	\N	f	2014-09-19 17:14:51.816893	2014-09-26 13:23:00.158005	es	Aplicar	f	f	f
1972	departure_time	\N	f	2014-09-19 17:14:52.160123	2014-09-26 17:35:08.879716	es	Hora de salida	f	f	f
1969	departing_at	\N	f	2014-09-19 17:14:52.123384	2014-09-26 13:25:38.827102	es	Con salida a las	f	f	f
1916	feedback_comments	\N	f	2014-09-19 17:14:51.445717	2014-09-29 03:21:06.170185	es	Por favor, ingrese cualquier comentario que le gustaría compartir	f	f	f
1971	arrival_time	\N	f	2014-09-19 17:14:52.148278	2014-09-26 12:52:34.496282	es	Hora de Llegada	f	f	f
1970	arriving_by	\N	f	2014-09-19 17:14:52.135292	2014-09-26 13:25:08.421007	es	Llegando en	f	f	f
1919	edit_trip	\N	f	2014-09-19 17:14:51.477066	2014-09-26 13:26:05.654556	es	Editar este viaje	f	f	f
1948	review	\N	f	2014-09-19 17:14:51.893032	2014-10-01 17:53:12.270987	es	Revisión	f	f	f
1921	remove_trip	\N	f	2014-09-19 17:14:51.498121	2014-09-26 13:28:07.165071	es	Eliminar este viaje	f	f	f
1920	repeat_trip	\N	f	2014-09-19 17:14:51.4877	2014-09-26 13:28:22.318758	es	Repita este viaje	f	f	f
1967	trip_purpose	\N	f	2014-09-19 17:14:52.101049	2014-09-26 13:28:37.178528	es	Proposito	f	f	f
1936	arrive_in	\N	f	2014-09-19 17:14:51.698857	2014-09-26 13:29:47.260471	es	Llegada a	f	f	f
1915	did_not_take_feedback_prompt	\N	f	2014-09-19 17:14:51.435409	2014-09-26 19:40:03.182595	es	Lamentamos saber que no tomaste tu viaje. ¿Puede decirnos que salió mal?	f	f	f
1976	disability_explanation_str	\N	f	2014-09-19 17:14:52.203095	2014-09-26 19:53:04.964819	es	Nos dimos cuenta de que usted menciona una discapacidad y/o dificultad para caminar durante determinados períodos de tiempo. ¿Podría por favor darnos más detalles de qué tipo de ayuda necesita para su viaje?	f	f	f
1988	bike	\N	f	2014-09-19 17:14:52.347991	2014-09-26 20:42:42.176294	es	Bicicleta	f	f	f
1987	drive	\N	f	2014-09-19 17:14:52.336539	2014-09-26 20:20:38.909627	es	Maneja	f	f	f
1917	feedback_rating	\N	f	2014-09-19 17:14:51.455609	2014-09-29 03:23:57.908145	es	Clasificación (1-peor, 5-mejor)	f	f	f
1939	finish_trip_planning_options	\N	f	2014-09-19 17:14:51.740432	2014-09-29 03:27:22.526091	es	Ahora puede hacer una o más de las siguientes para terminar la planificación de su viaje.	f	f	f
1953	from_lon	\N	f	2014-09-19 17:14:51.952124	2014-09-29 23:41:11.329056	es	De Lon	f	f	f
1965	going_to	\N	f	2014-09-19 17:14:52.079638	2014-10-05 00:42:27.805796	es	Llegando a	f	f	f
1960	in_datetime	\N	f	2014-09-19 17:14:52.027292	2014-09-30 00:33:20.970483	es	Fecha de entrada	f	f	f
1963	leaving_from	\N	f	2014-09-19 17:14:52.057837	2014-09-30 00:56:23.381482	es	Saliendo desde	f	f	f
1927	location	\N	f	2014-09-19 17:14:51.570448	2014-09-30 01:25:10.642499	es	Ubicación	f	f	f
1925	max_notes	\N	f	2014-09-19 17:14:51.5423	2014-09-30 01:43:48.419911	es	Notas Máximas 	f	f	f
1942	modes	\N	f	2014-09-19 17:14:51.80387	2014-09-30 02:20:11.967702	es	Modos	f	f	f
1975	no_thanks_just_plan_it	\N	f	2014-09-19 17:14:52.191543	2014-09-30 16:51:23.786554	es	No gracias, solo planear mi viaje	f	f	f
1941	number_of_transfers	\N	f	2014-09-19 17:14:51.779091	2014-09-30 17:14:03.722826	es	Numero de Transferencias	f	f	f
1947	options	\N	f	2014-09-19 17:14:51.878551	2014-09-30 17:33:00.841745	es	Opciones	f	f	f
1954	out_arrive_or_depart	\N	f	2014-09-19 17:14:51.963008	2014-09-30 17:37:14.494052	es	Salidas  Llega  Sale	f	f	f
1955	out_datetime	\N	f	2014-09-19 17:14:51.973778	2014-09-30 17:39:35.359575	es	Fecha de salida	f	f	f
1923	rate_recent	\N	f	2014-09-19 17:14:51.51999	2014-10-01 16:33:37.955719	es	Comentarios sobre su reciente viaje	f	f	f
1922	rate_trip	\N	f	2014-09-19 17:14:51.508923	2014-10-01 16:35:29.001552	es	Calificar este viaje	f	f	f
1937	save_and_plan_trip	\N	f	2014-09-19 17:14:51.712531	2014-10-01 18:00:44.579907	es	Guardar y planificar mi viaje	f	f	f
1914	submit_review	\N	f	2014-09-19 17:14:51.424462	2014-10-03 04:13:11.073606	es	Presentar sus Comentarios	f	f	f
1982	summary	\N	f	2014-09-19 17:14:52.272344	2014-10-03 04:15:40.508953	es	Resumen	f	f	f
1957	to_lat	\N	f	2014-09-19 17:14:51.995639	2014-10-04 01:15:06.737259	es	A Lat	f	f	f
1958	to_lon	\N	f	2014-09-19 17:14:52.006575	2014-10-04 01:15:42.505342	es	A Lon	f	f	f
1978	transit_trip	\N	f	2014-09-19 17:14:52.226628	2014-10-04 01:34:12.205858	es	Viaje de Transporte Público	f	f	f
1973	travel_time	\N	f	2014-09-19 17:14:52.170569	2014-10-04 01:36:53.589915	es	Tiempo del Viaje	f	f	f
1946	trip	\N	f	2014-09-19 17:14:51.863094	2014-10-04 01:45:09.022795	es	Viaje	f	f	f
1932	trip_date	\N	f	2014-09-19 17:14:51.633569	2014-10-04 01:53:56.30876	es	Fecha del viaje	f	f	f
1977	trip_options	\N	f	2014-09-19 17:14:52.214956	2014-10-04 02:10:25.603366	es	Opciones del Viaje	f	f	f
1983	trip_details	\N	f	2014-09-19 17:14:52.288917	2014-10-04 01:55:24.212047	es	Detalles del Viaje	f	f	f
1938	trip_planned_and_saved	\N	f	2014-09-19 17:14:51.725635	2014-10-04 02:19:08.18603	es	Viaje planificado y guardado	f	f	f
1968	trip_purposes	\N	f	2014-09-19 17:14:52.11242	2014-10-04 02:23:05.472389	es	Proposito del viaje	f	f	f
1950	trip_restrictions	\N	f	2014-09-19 17:14:51.917338	2014-10-04 02:25:30.510024	es	Restricciones del viaje 	f	f	f
1964	type_from_address	\N	f	2014-09-19 17:14:52.069126	2014-10-04 03:17:20.32103	es	Escriba la dirección de	f	f	f
1966	type_to_address	\N	f	2014-09-19 17:14:52.090299	2014-10-04 03:19:05.679995	es	Escriba la dirección a donde va	f	f	f
1918	untaken_trip	\N	f	2014-09-19 17:14:51.466527	2014-10-04 03:30:49.871572	es	Viaje que no ha tomado	f	f	f
1986	bus	\N	f	2014-09-19 17:14:52.325661	2014-10-04 23:16:12.973048	es	Autobus	f	f	f
1926	enter_address	\N	f	2014-09-19 17:14:51.555887	2014-10-05 00:27:24.361398	es	Introduzca la dirección	f	f	f
1928	enter_to	\N	f	2014-09-19 17:14:51.582089	2014-10-05 00:32:56.791827	es	Pulse para entrar el lugar de destino	f	f	f
1952	from_lat	\N	f	2014-09-19 17:14:51.940985	2014-10-05 00:38:09.072231	es	Desde Lat	f	f	f
1929	enter_from	\N	f	2014-09-19 17:14:51.595845	2014-10-05 00:30:59.77291	es	Pulse para introducir una ubicación de inicio	f	f	f
1959	in_arrive_or_depart	\N	f	2014-09-19 17:14:52.017371	2014-10-05 00:39:13.352618	es	Entrada   Llega   Sale	f	f	f
2006	view	\N	f	2014-09-19 17:14:52.575254	2014-09-19 17:14:52.575254	es	Mostrar	f	f	f
2007	remove	\N	f	2014-09-19 17:14:52.586606	2014-09-19 17:14:52.586606	es	Eliminar	f	f	f
2008	reload	\N	f	2014-09-19 17:14:52.5994	2014-09-19 17:14:52.5994	es	Recargar	f	f	f
2015	paratransit	\N	f	2014-09-19 17:14:52.673648	2014-09-19 17:14:52.673648	es	Transporte Público para Discapacitados	f	f	f
2016	mode	\N	f	2014-09-19 17:14:52.68458	2014-09-19 17:14:52.68458	es	Medio de Transporte	f	f	f
2021	duration	\N	f	2014-09-19 17:14:52.7374	2014-09-19 17:14:52.7374	es	Duración	f	f	f
2022	walking	\N	f	2014-09-19 17:14:52.757576	2014-09-19 17:14:52.757576	es	 caminando	f	f	f
2023	depart	\N	f	2014-09-19 17:14:52.768049	2014-09-19 17:14:52.768049	es	Salida	f	f	f
2025	cost	\N	f	2014-09-19 17:14:52.790364	2014-09-19 17:14:52.790364	es	Costo	f	f	f
2026	print	\N	f	2014-09-19 17:14:52.801104	2014-09-19 17:14:52.801104	es	Imprimir	f	f	f
2027	chat	\N	f	2014-09-19 17:14:52.811584	2014-09-19 17:14:52.811584	es	Charlar en línea	f	f	f
2028	e_mail	\N	f	2014-09-19 17:14:52.822271	2014-09-19 17:14:52.822271	es	 Correo electrónico	f	f	f
2032	trip_was_successfully_created	\N	f	2014-09-19 17:14:52.867007	2014-09-19 17:14:52.867007	es	El viaje fue creado exitosamente.	f	f	f
2036	hour.one	\N	f	2014-09-19 17:14:52.912263	2014-09-19 17:14:52.912263	es	%{count} h	f	f	f
2037	hour.other	\N	f	2014-09-19 17:14:52.925394	2014-09-19 17:14:52.925394	es	%{count} h	f	f	f
2044	less_than_one_minute	\N	f	2014-09-19 17:14:53.025035	2014-09-19 17:14:53.025035	es	Menos de 1 min	f	f	f
2047	date_wrong_format	\N	f	2014-09-19 17:14:53.080818	2014-09-19 17:14:53.080818	es	La fecha debe estar en el formato MM/DD/AAAA.	f	f	f
2048	time_wrong_format	\N	f	2014-09-19 17:14:53.094849	2014-09-19 17:14:53.094849	es	La hora debe estar en el formato hh:mm am/pm.	f	f	f
2050	trips_cannot_be_entered_for_times	\N	f	2014-09-19 17:14:53.120606	2014-09-19 17:14:53.120606	es	 No se pueden introducir viajes para horas pasadas.	f	f	f
2054	possible_rideshares	\N	f	2014-09-19 17:14:53.186311	2014-09-19 17:14:53.186311	es	%{count} opciones para compartir el viaje en vehículo.	f	f	f
2056	possible_rideshares1	\N	f	2014-09-19 17:14:53.218261	2014-09-19 17:14:53.218261	es	%{count} opciones	f	f	f
2057	possible_rideshares2	\N	f	2014-09-19 17:14:53.232687	2014-09-19 17:14:53.232687	es	para compartir el viaje en vehículo.	f	f	f
2058	view_details1	\N	f	2014-09-19 17:14:53.260652	2014-09-19 17:14:53.260652	es	Mostrar detalles	f	f	f
2059	view_details2	\N	f	2014-09-19 17:14:53.304512	2014-09-19 17:14:53.304512	es	para más.	f	f	f
2060	confirm_remove_trip	\N	f	2014-09-19 17:14:53.31735	2014-09-19 17:14:53.31735	es	¿Está seguro que desea eliminar este viaje? *23*	f	f	f
2024	arrive	\N	f	2014-09-19 17:14:52.779282	2014-09-25 17:12:01.040809	es	LLEGA: 	f	f	f
2029	create	\N	f	2014-09-19 17:14:52.833084	2014-09-26 16:45:56.582965	es	Crear	f	f	f
2030	created	\N	f	2014-09-19 17:14:52.844752	2014-09-26 16:51:02.051994	es	Creado	f	f	f
2031	created_at	\N	f	2014-09-19 17:14:52.855305	2014-09-26 16:52:05.453672	es	Creado el	f	f	f
2001	failed_to_update_profile	\N	f	2014-09-19 17:14:52.509793	2014-09-29 03:03:40.701942	es	Se cometió un error al actualizar su perfil de usuario	f	f	f
1990	drive_and_transit	\N	f	2014-09-19 17:14:52.375	2014-10-05 00:22:15.572189	es	Manejar y Transporte Publico 	f	f	f
2019	device	\N	f	2014-09-19 17:14:52.716605	2014-09-26 18:40:45.877269	es	Dispositivo	f	f	f
2017	direction_short	\N	f	2014-09-19 17:14:52.696013	2014-09-26 19:47:39.398116	es	Dir	f	f	f
2038	hour_long.one	\N	f	2014-09-19 17:14:52.936796	2014-10-05 00:45:10.095689	es	%{count} hora	f	f	f
2042	day.one	\N	f	2014-09-19 17:14:52.993091	2014-09-26 20:37:43.269703	es	%{count} día	f	f	f
2020	hidden	\N	f	2014-09-19 17:14:52.726888	2014-09-29 23:59:57.863177	es	Escondido	f	f	f
2045	invalid_address	\N	f	2014-09-19 17:14:53.037739	2014-10-05 00:52:04.230527	es	Dirección Invalida.	f	f	f
2039	hour_long.other	\N	f	2014-09-19 17:14:52.949586	2014-09-30 00:11:00.787925	es	%{count} horas	f	f	f
2053	link_to_georgia_commute_options.other	\N	f	2014-09-19 17:14:53.170962	2014-09-30 01:06:55.398593	es	Visita %{url} para ver %{count} opciones para compartir el viaje en el vehículo.	f	f	f
1997	mode_transfer	\N	f	2014-09-19 17:14:52.458423	2014-09-30 02:16:41.944693	es	Transferencia	f	f	f
1999	no_itineraries_found	\N	f	2014-09-19 17:14:52.485526	2014-09-30 03:20:59.01704	es	No se encontraron itinerarios	f	f	f
2040	minute.one	\N	f	2014-09-19 17:14:52.961022	2014-09-30 03:33:54.828409	es	%{count} minuto	f	f	f
2041	minute.other	\N	f	2014-09-19 17:14:52.972364	2014-09-30 03:34:16.589872	es	%{count} minutos	f	f	f
2012	outbound	\N	f	2014-09-19 17:14:52.641071	2014-09-30 17:41:15.123415	es	Salida	f	f	f
2013	outbound_itinerary_count	\N	f	2014-09-19 17:14:52.651144	2014-09-30 17:48:31.838234	es	Cuenta del Itinerario de Salida	f	f	f
2014	outbound_itinerary_modes	\N	f	2014-09-19 17:14:52.661341	2014-09-30 17:49:52.419862	es	Modos de Itinerario de salida	f	f	f
1991	rail	\N	f	2014-09-19 17:14:52.386948	2014-10-01 16:30:32.046519	es	Tren	f	f	f
1992	rail_and_bus	\N	f	2014-09-19 17:14:52.398804	2014-10-01 16:31:23.887705	es	Tren y Autobus	f	f	f
2009	return	\N	f	2014-09-19 17:14:52.610064	2014-10-01 17:35:09.313186	es	Regresar	f	f	f
2010	return_itinerary_count	\N	f	2014-09-19 17:14:52.620632	2014-10-01 17:40:12.021624	es	Cuenta del Itinerario de Regreso	f	f	f
2011	return_itinerary_modes	\N	f	2014-09-19 17:14:52.630917	2014-10-01 17:43:01.878836	es	Modos de Itinerario de Regreso	f	f	f
2051	return_trip_time_before_start	\N	f	2014-09-19 17:14:53.134106	2014-10-01 17:48:53.811239	es	Los viajes no pueden regresar antes de que se inicien.	f	f	f
2002	route	\N	f	2014-09-19 17:14:52.522495	2014-10-01 17:59:08.913187	es	Rutas	f	f	f
1998	select_a_plan_each_trip_part	\N	f	2014-09-19 17:14:52.473601	2014-10-01 18:22:10.235649	es	Por favor, seleccione un itinerario para cada parte del viaje	f	f	f
2000	service_error	\N	f	2014-09-19 17:14:52.497319	2014-10-03 03:11:21.057464	es	Hubo un error al planificar su viaje. Por favor, inténtelo de nuevo.	f	f	f
2018	status	\N	f	2014-09-19 17:14:52.706326	2014-10-03 04:06:02.583929	es	Estado	f	f	f
1993	subway	\N	f	2014-09-19 17:14:52.410916	2014-10-03 04:13:55.241655	es	Metro	f	f	f
1994	tram	\N	f	2014-09-19 17:14:52.422446	2014-10-04 01:20:27.998254	es	Tranvía	f	f	f
2003	transfer.one	\N	f	2014-09-19 17:14:52.535745	2014-10-04 01:22:28.951971	es	%{count} transferencia	f	f	f
2004	transfer.other	\N	f	2014-09-19 17:14:52.550768	2014-10-04 01:24:04.800894	es	%{count} transferencias	f	f	f
2005	transfers	\N	f	2014-09-19 17:14:52.563275	2014-10-04 01:24:43.51394	es	Transferencias	f	f	f
2034	trip_created_no_valid_options	\N	f	2014-09-19 17:14:52.889455	2014-10-04 01:52:18.74759	es	El viaje fue creado, pero no se encontraron opciones válidas para el viaje.\r\n	f	f	f
2049	trips_cannot_be_entered_for_days	\N	f	2014-09-19 17:14:53.107721	2014-10-04 03:07:05.99152	es	No se pueden introducir viajes para los días	f	f	f
2033	trip_was_successfully_removed	\N	f	2014-09-19 17:14:52.878162	2014-10-04 03:03:40.805231	es	El viaje fue eliminado exitosamente. *25*	f	f	f
1995	vehicle	\N	f	2014-09-19 17:14:52.434191	2014-10-04 03:54:20.958969	es	Vehículo	f	f	f
1996	wait	\N	f	2014-09-19 17:14:52.446223	2014-10-04 04:04:54.423932	es	Espere	f	f	f
2055	view_details	\N	f	2014-09-19 17:14:53.204728	2014-10-04 03:58:26.302406	es	Mostrar detalles para más.	f	f	f
2035	was_successfully_updated	\N	f	2014-09-19 17:14:52.900966	2014-10-04 04:13:06.661588	es	fue actualizado correctamente.	f	f	f
2043	day.other	\N	f	2014-09-19 17:14:53.008072	2014-10-04 23:53:41.422996	es	%{count} días	f	f	f
2046	invalid_location	\N	f	2014-09-19 17:14:53.059439	2014-10-05 00:52:45.478466	es	Localización invalida.	f	f	f
2076	cannot_change_time_to_past	\N	f	2014-09-19 17:14:53.496692	2014-09-19 17:14:53.496692	es	[es]Cannot change trip part time to a past time[/es]	f	f	f
2078	cannot_change_time_to_before_prev_trip_part	\N	f	2014-09-19 17:14:53.518061	2014-09-19 17:14:53.518061	es	[es]Cannot change trip part time to be before previous trip part[/es]	f	f	f
2087	found_x_places.one	\N	f	2014-09-19 17:14:53.610197	2014-09-19 17:14:53.610197	es	Encontrados %{count} sitios en la libreta de direcciones. *13*	f	f	f
2088	found_x_places.other	\N	f	2014-09-19 17:14:53.620403	2014-09-19 17:14:53.620403	es	Encontrados %{count} lugar en su libreta de direcciones. *13*	f	f	f
2089	found_x_matches.one	\N	f	2014-09-19 17:14:53.631415	2014-09-19 17:14:53.631415	es	Se encontro %{count} coincudencia de lugar. *18*	f	f	f
2090	found_x_matches.other	\N	f	2014-09-19 17:14:53.64204	2014-09-19 17:14:53.64204	es	Se encontraron %{count} lugares coincidentes. *18*	f	f	f
2096	place_added	\N	f	2014-09-19 17:14:53.709202	2014-09-19 17:14:53.709202	es	%{place_name} ha sido agregado a tu libreta de direcciones. *19*	f	f	f
2100	profile_updated	\N	f	2014-09-19 17:14:53.753662	2014-09-19 17:14:53.753662	es	Su perfil ha sido actualizado. *37*	f	f	f
2098	address_book_updated	\N	f	2014-09-19 17:14:53.73123	2014-09-25 16:20:40.048996	es	Su libreta de direcciones se ha actualizado. *21*	f	f	f
2081	center_my_location	\N	f	2014-09-19 17:14:53.548324	2014-10-04 23:33:38.38661	es	Centrar mi ubicación	f	f	f
2083	street_view	\N	f	2014-09-19 17:14:53.569617	2014-10-03 04:08:06.106576	es	Vista de la calle	f	f	f
2066	one_way	\N	f	2014-09-19 17:14:53.386653	2014-10-05 01:21:18.229385	es	Viaje sencillo de ida	f	f	f
2094	nothing_found	\N	f	2014-09-19 17:14:53.686978	2014-09-30 17:11:16.929073	es	No se ha encontrado nada en esa dirección. Por favor, intentelo de nuevo. *17*	f	f	f
2118	please_wait	\N	f	2014-09-19 17:14:54.048195	2014-09-30 18:33:51.952937	es	Por favor, espere	f	f	f
2101	updated	\N	f	2014-09-19 17:14:53.765509	2014-10-04 03:33:35.096033	es	Actualizado	f	f	f
2095	update	\N	f	2014-09-19 17:14:53.698248	2014-09-26 13:29:16.875106	es	Actualizar	f	f	f
2070	at	\N	f	2014-09-19 17:14:53.432961	2014-09-26 13:31:08.92558	es	en	f	f	f
2121	confirmation	\N	f	2014-09-19 17:14:54.083311	2014-10-04 23:47:15.743952	es	confirmación	f	f	f
2107	endpoints	\N	f	2014-09-19 17:14:53.911486	2014-10-05 00:26:40.270347	es	Punto Final	f	f	f
2099	confirm_remove_message	\N	f	2014-09-19 17:14:53.742348	2014-09-26 16:08:05.260157	es	¿Esta seguro que desea eliminar? 	f	f	f
2109	coverage_area_edit_instruction	\N	f	2014-09-19 17:14:53.935882	2014-09-26 16:33:26.966291	es	Puedes subir ya sea un archivo de formas o seleccionar una de las áreas de servicio abajo.	f	f	f
2106	coverage_area	\N	f	2014-09-19 17:14:53.898482	2014-09-26 16:28:17.561037	es	Punto final de la zona	f	f	f
2108	coverages	\N	f	2014-09-19 17:14:53.923698	2014-09-26 16:45:13.818604	es	Área de cobertura	f	f	f
2082	display_street_view	\N	f	2014-09-19 17:14:53.559381	2014-09-26 20:01:17.454986	es	Mostrar vista de la calle	f	f	f
2105	endpoint_area	\N	f	2014-09-19 17:14:53.883744	2014-09-29 02:45:34.947365	es	Área de cobertura	f	f	f
2112	geometry_defined_by_shapefile	\N	f	2014-09-19 17:14:53.972422	2014-10-05 00:41:41.353781	es	La geometría se define por el archivo que subió el usuario	f	f	f
2092	enter_address_or_place	\N	f	2014-09-19 17:14:53.66444	2014-09-29 02:49:12.388451	es	Introduzca una direccion o nombre de un lugar... *14*	f	f	f
2072	fare	\N	f	2014-09-19 17:14:53.454403	2014-09-29 03:12:06.699409	es	Tarifa	f	f	f
2073	flat_fare_unavailable	\N	f	2014-09-19 17:14:53.464611	2014-09-29 03:29:18.380687	es	Tarifa basica no está disponible	f	f	f
2123	for_assistance	\N	f	2014-09-19 17:14:54.105632	2014-09-29 23:37:56.293383	es	para asistencia	f	f	f
2075	four_digit_year	\N	f	2014-09-19 17:14:53.485806	2014-09-29 23:40:12.88127	es	El año debe tener cuatro dígitos	f	f	f
2063	hide	\N	f	2014-09-19 17:14:53.35476	2014-10-05 00:44:05.08209	es	Ocultado	f	f	f
2124	if_no_client_id	\N	f	2014-09-19 17:14:54.116148	2014-09-30 00:24:18.121199	es	Si usted no tiene un ID de cliente, por favor llame	f	f	f
2102	logo	\N	f	2014-09-19 17:14:53.777422	2014-09-30 01:27:09.312634	es	Logotipo	f	f	f
2120	more_info_call	\N	f	2014-09-19 17:14:54.072056	2014-09-30 02:25:49.459722	es	Para obtener más información, llame al	f	f	f
2093	new_name	\N	f	2014-09-19 17:14:53.675902	2014-09-30 02:54:12.837577	es	Introduzca un nuevo nombre para este luga *15*	f	f	f
2113	no_polygon_geometry_parsed	\N	f	2014-09-19 17:14:53.983803	2014-09-30 03:27:56.049245	es	Ninguna geometría de polígono se ha analizado en el archivo subido por %{area_type}	f	f	f
2062	no_matching_trips_found	\N	f	2014-09-19 17:14:53.342276	2014-09-30 03:40:28.816434	es	Usted no tiene viajes coincidentes. *27*	f	f	f
2061	no_trips_found	\N	f	2014-09-19 17:14:53.328697	2014-09-30 16:57:51.309242	es	No tiene viajes.	f	f	f
2116	outbound_error_occurred	\N	f	2014-09-19 17:14:54.023036	2014-09-30 17:43:15.368562	es	Se produjo un error al tratar de reservar su viaje de salida.	f	f	f
2125	outbound_is_eligible	\N	f	2014-09-19 17:14:54.126311	2014-09-30 17:45:47.430755	es	La porción de salida de su viaje es elegible para la reserva automática.	f	f	f
2091	place_name	\N	f	2014-09-19 17:14:53.652782	2014-09-30 18:27:08.716221	es	Nombre del Lugar	f	f	f
2074	rate	\N	f	2014-09-19 17:14:53.475041	2014-10-01 16:32:11.836846	es	Precio	f	f	f
2097	error_updating_addresses	\N	f	2014-09-19 17:14:53.720255	2014-10-01 17:11:19.44364	es	Se produjo un error al acutalizar la libreta de direcciones. *20*	f	f	f
2086	remove_by	\N	f	2014-09-19 17:14:53.600175	2014-10-01 17:25:58.396968	es	Retirado por	f	f	f
2069	return_after	\N	f	2014-09-19 17:14:53.420827	2014-10-01 17:35:48.09786	es	Volver después de	f	f	f
2117	return_error_occurred	\N	f	2014-09-19 17:14:54.036522	2014-10-01 17:36:44.27302	es	Se produjo un error al tratar de reservar su viaje de regreso.	f	f	f
2126	return_is_eligible	\N	f	2014-09-19 17:14:54.137561	2014-10-01 17:37:55.005003	es	La parte del retorno de su viaje es elegible para una reservación automática.	f	f	f
2068	returning	\N	f	2014-09-19 17:14:53.410569	2014-10-01 17:49:38.309145	es	regresando	f	f	f
2067	returning_at	\N	f	2014-09-19 17:14:53.397663	2014-10-01 17:50:08.167122	es	regresando a	f	f	f
2122	returning_by	\N	f	2014-09-19 17:14:54.094739	2014-10-01 17:50:52.24964	es	Regresando por	f	f	f
2065	round_trip	\N	f	2014-09-19 17:14:53.375932	2014-10-01 17:58:08.994688	es	Ida y vuelta	f	f	f
2084	select_location_on_map	\N	f	2014-09-19 17:14:53.58007	2014-10-01 18:24:34.055175	es	Elegir un lugar en el mapa	f	f	f
2114	cap_returning_at	\N	f	2014-09-19 17:14:53.995727	2014-10-04 23:29:51.352533	es	Regresando a	f	f	f
2115	traveler_not_registered	\N	f	2014-09-19 17:14:54.010671	2014-10-04 01:39:08.166682	es	El viajero no está registrado para reservar un viaje con Un-Clic.	f	f	f
2064	unhide_all	\N	f	2014-09-19 17:14:53.365513	2014-10-04 03:26:55.67394	es	Volver a mostrar todo	f	f	f
2110	upload_shapefile	\N	f	2014-09-19 17:14:53.948119	2014-10-04 03:39:53.643391	es	Subir un zipped shapefile (*.zip)[/es]	f	f	f
2111	upload_zip_alert	\N	f	2014-09-19 17:14:53.960604	2014-10-04 03:38:45.011227	es	Por favor suba un zipped shapefile (*.zip)[/es]	f	f	f
2071	wait_at	\N	f	2014-09-19 17:14:53.443555	2014-10-04 04:05:56.030095	es	Espere en	f	f	f
2079	zoom_in	\N	f	2014-09-19 17:14:53.528256	2014-10-04 04:20:37.000113	es	Acercar la imagen	f	f	f
2080	zoom_out	\N	f	2014-09-19 17:14:53.538164	2014-10-04 04:21:03.155918	es	Alejar la imagen	f	f	f
2119	book_a_trip	\N	f	2014-09-19 17:14:54.060045	2014-10-04 23:04:33.344487	es	¿Le gustaría reservar este viaje con           ?	f	f	f
2169	advance_notice_required	\N	f	2014-09-19 17:14:54.71712	2014-09-26 12:58:21.82584	es	Aviso Anticipado Requerido	f	f	f
2146	all_services	\N	f	2014-09-19 17:14:54.358777	2014-09-26 13:24:01.419966	es	Todos los Servicios	f	f	f
2184	click_for_details	\N	f	2014-09-19 17:14:54.901331	2014-10-04 23:40:45.962147	es	Haga clic para obtener más información	f	f	f
2139	inactive	\N	f	2014-09-19 17:14:54.27761	2014-09-30 00:36:02.837149	es	Inactivo	f	f	f
2167	book_ahead	\N	f	2014-09-19 17:14:54.691978	2014-10-01 18:34:06.859116	es	Reserve con anticipación	f	f	f
2129	book_your_trip	\N	f	2014-09-19 17:14:54.170272	2014-10-01 18:34:41.11664	es	Reserve su viaje	f	f	f
2137	booked	\N	f	2014-09-19 17:14:54.253658	2014-10-01 18:35:02.791774	es	Reservado	f	f	f
2133	booking_information	\N	f	2014-09-19 17:14:54.211759	2014-10-01 18:35:36.411756	es	Información de Reserva	f	f	f
2142	booking_service_code	\N	f	2014-09-19 17:14:54.311679	2014-10-01 18:35:57.385487	es	Código de Reserva	f	f	f
2144	service	\N	f	2014-09-19 17:14:54.334233	2014-10-03 02:57:02.175429	es	Servicio	f	f	f
2138	bookings	\N	f	2014-09-19 17:14:54.266231	2014-10-01 18:36:16.374969	es	Reservas	f	f	f
2148	add_service	\N	f	2014-09-19 17:14:54.388036	2014-09-26 12:54:14.839815	es	Añadir servicio	f	f	f
2135	client_id	\N	f	2014-09-19 17:14:54.233019	2014-10-04 23:41:32.200397	es	ID del cliente	f	f	f
2163	close	\N	f	2014-09-19 17:14:54.631146	2014-10-04 23:42:14.7353	es	Cerrar	f	f	f
2159	contact	\N	f	2014-09-19 17:14:54.544973	2014-10-04 23:49:28.231244	es	Contacto	f	f	f
2196	coverage_areas	\N	f	2014-09-19 17:14:55.081962	2014-09-26 16:34:29.856623	es	Áreas de cobertura	f	f	f
2189	cost_estimated	\N	f	2014-09-19 17:14:54.969061	2014-09-26 16:26:32.37132	es	Costo estimado	f	f	f
2156	destinations	\N	f	2014-09-19 17:14:54.496756	2014-09-26 18:38:54.215722	es	Destinos	f	f	f
2131	dob	\N	f	2014-09-19 17:14:54.191659	2014-09-26 20:08:57.547508	es	Fecha de Nacimiento	f	f	f
2132	dob_notice	\N	f	2014-09-19 17:14:54.201643	2014-09-26 20:11:40.456783	es	La fecha de nacimiento podría ser utilizada para confirmar la identidad de el cliente con un servicio. No se guardará.	f	f	f
2193	email_trip_details	\N	f	2014-09-19 17:14:55.035509	2014-09-26 20:36:45.027267	es	Enviar su plan de viaje	f	f	f
2143	back_to_services	\N	f	2014-09-19 17:14:54.322863	2014-09-26 20:41:40.787066	es	Volver a Servicios	f	f	f
2177	more_information_required	\N	f	2014-09-19 17:14:54.813602	2014-09-30 02:26:44.477688	es	Se necesita más información.	f	f	f
2164	name	\N	f	2014-09-19 17:14:54.644704	2014-09-30 02:37:31.015478	es	Nombre	f	f	f
2190	no_charge	\N	f	2014-09-19 17:14:54.990871	2014-09-30 03:15:34.239389	es	Sin cargo	f	f	f
2180	no_cost_for_service	\N	f	2014-09-19 17:14:54.854459	2014-09-30 03:16:57.574344	es	No hay costo por este servicio	f	f	f
2158	no_restriction	\N	f	2014-09-19 17:14:54.528366	2014-09-30 16:49:44.422018	es	Sin restricción	f	f	f
2168	note	\N	f	2014-09-19 17:14:54.705127	2014-09-30 17:08:38.088971	es	Nota	f	f	f
2155	origins	\N	f	2014-09-19 17:14:54.484821	2014-09-30 17:35:19.594309	es	Orígenes	f	f	f
2161	phone	\N	f	2014-09-19 17:14:54.594947	2014-09-30 18:15:10.769919	es	Teléfono	f	f	f
2186	press_space_for_details	\N	f	2014-09-19 17:14:54.931605	2014-09-30 18:38:49.656437	es	Presione la barra de ESPACIO para obtener más información	f	f	f
2187	press_space_or_click_to_select	\N	f	2014-09-19 17:14:54.943165	2014-09-30 18:40:28.248962	es	Presione la barra de ESPACIO o haga clic para seleccionar	f	f	f
2194	print_trip_details	\N	f	2014-09-19 17:14:55.051991	2014-10-01 16:15:03.016962	es	Imprima los detalles de su viaje.	f	f	f
2185	press_space_or_dblclick_for_details	\N	f	2014-09-19 17:14:54.916969	2014-10-01 16:13:29.175168	es	Presione la barra de ESPACIO o haga doble clic para mas detalles	f	f	f
2149	remove_service	\N	f	2014-09-19 17:14:54.405266	2014-10-01 17:31:26.949048	es	Elimine el Servicio	f	f	f
2157	residences	\N	f	2014-09-19 17:14:54.509606	2014-10-01 17:34:14.841375	es	La Residencia	f	f	f
2166	schedule	\N	f	2014-09-19 17:14:54.678405	2014-10-01 18:07:15.742993	es	Horario	f	f	f
2191	see_below	\N	f	2014-09-19 17:14:55.010504	2014-10-01 18:09:16.168848	es	Vea abajo	f	f	f
2188	see_details_for_cost	\N	f	2014-09-19 17:14:54.956164	2014-10-01 18:10:33.715895	es	Ver detalles del costo	f	f	f
2150	select_service	\N	f	2014-09-19 17:14:54.417187	2014-10-01 18:28:03.360961	es	Seleccione un Servicio	f	f	f
2165	send	\N	f	2014-09-19 17:14:54.663028	2014-10-01 18:29:31.320565	es	Enviar	f	f	f
2136	book	\N	f	2014-09-19 17:14:54.242928	2014-10-01 18:32:07.323918	es	Reservar	f	f	f
2152	service_contact	\N	f	2014-09-19 17:14:54.442709	2014-10-03 03:10:18.550446	es	Información de Contacto del Servicio	f	f	f
2140	service_id	\N	f	2014-09-19 17:14:54.288806	2014-10-03 03:12:38.664099	es	Identificación de Servicio	f	f	f
2172	service_intended_for	\N	f	2014-09-19 17:14:54.756618	2014-10-03 03:13:58.266032	es	Este servicio está destinado para	f	f	f
2151	service_is_inactive	\N	f	2014-09-19 17:14:54.428704	2014-10-03 03:15:13.01579	es	Este servicio está inactivo	f	f	f
2134	service_name	\N	f	2014-09-19 17:14:54.222783	2014-10-03 03:16:22.566917	es	Nombre del Servicio	f	f	f
2179	service_notice_not_required	\N	f	2014-09-19 17:14:54.843413	2014-10-03 03:18:05.298044	es	Este servicio no requiere aviso previo para reservar un viaje	f	f	f
2170	service_notice_required	\N	f	2014-09-19 17:14:54.730433	2014-10-03 03:19:41.330131	es	Este servicio requiere	f	f	f
2171	service_notice_str	\N	f	2014-09-19 17:14:54.743357	2014-10-03 03:22:06.586978	es	de antelación antes de reservar un viaje	f	f	f
2141	service_type	\N	f	2014-09-19 17:14:54.299923	2014-10-03 03:24:26.78191	es	Tipo de Servicio	f	f	f
2145	services	\N	f	2014-09-19 17:14:54.346442	2014-10-03 03:25:12.493565	es	Servicios	f	f	f
2153	specialized_services	\N	f	2014-09-19 17:14:54.455048	2014-10-03 03:45:22.121437	es	Servicios Especializados	f	f	f
2160	title	\N	f	2014-09-19 17:14:54.567249	2014-10-04 01:14:06.972732	es	Titulo	f	f	f
2130	trip_booked	\N	f	2014-09-19 17:14:54.18125	2014-10-04 01:46:39.664176	es	¡Viaje Reservado!	f	f	f
2128	trip_booked_2	\N	f	2014-09-19 17:14:54.158858	2014-10-04 01:47:33.214992	es	Su viaje ha sido reservado.	f	f	f
2175	trip_insufficient_notice_a	\N	f	2014-09-19 17:14:54.793003	2014-10-04 01:56:27.171107	es	Este viaje debe reservarse '	f	f	f
2176	trip_insufficient_notice_b	\N	f	2014-09-19 17:14:54.803489	2014-10-04 01:57:30.287909	es	por adelantado.	f	f	f
2127	trip_is_eligible	\N	f	2014-09-19 17:14:54.147822	2014-10-04 01:59:06.622855	es	Su viaje tiene derecho a la reserva automatizada.	f	f	f
2178	trip_needs_more_accommodations	\N	f	2014-09-19 17:14:54.830379	2014-10-04 02:06:46.612186	es	Estas adaptaciones no están disponibles por este servicio	f	f	f
2173	trip_not_possible_as_schedule	\N	f	2014-09-19 17:14:54.76742	2014-10-04 02:08:28.545835	es	Este viaje no es posible en la fecha prevista	f	f	f
2174	trip_outside_service_hours	\N	f	2014-09-19 17:14:54.781059	2014-10-04 02:17:09.401927	es	Este viaje tiene lugar fuera de las horas normales para este servicio.	f	f	f
2162	url	\N	f	2014-09-19 17:14:54.615109	2014-10-04 03:40:25.053161	es	URL	f	f	f
2195	view_planned_trips	\N	f	2014-09-19 17:14:55.068145	2014-10-04 03:59:54.356073	es	He terminado, favor mostrar todos mis viajes planificados.	f	f	f
2154	view_services	\N	f	2014-09-19 17:14:54.467519	2014-10-04 04:00:58.50436	es	Ver Servicios	f	f	f
2192	view_trip_details	\N	f	2014-09-19 17:14:55.022968	2014-10-04 04:02:11.080297	es	Ver la información del viaje de modo que usted puede llamar al proveedor.	f	f	f
2183	click_for_cost_details	\N	f	2014-09-19 17:14:54.887974	2014-10-04 23:39:55.87264	es	Haga clic para obtener información del costo	f	f	f
2222	buddy_removed	\N	f	2014-09-19 17:14:55.378592	2014-09-19 17:14:55.378592	es	Amigo eliminado.	f	f	f
2228	unable_to_remove_itinerary	\N	f	2014-09-19 17:14:55.441102	2014-09-19 17:14:55.441102	es	No se puede eliminar el itinerario.	f	f	f
2234	not_authorized_as_an_administrator	\N	f	2014-09-19 17:14:55.509052	2014-09-19 17:14:55.509052	es	No está autorizado como un administrador.	f	f	f
2235	n_a	\N	f	2014-09-19 17:14:55.520305	2014-09-19 17:14:55.520305	es	n/a	f	f	f
2247	twof_miles	\N	f	2014-09-19 17:14:55.728081	2014-09-19 17:14:55.728081	es	%.2f millas	f	f	f
2253	you_can_t_be_your_own_buddy	\N	f	2014-09-19 17:14:55.864783	2014-09-19 17:14:55.864783	es	No puedes ser tu propio amigo.	f	f	f
2262	last_30_days	\N	f	2014-09-19 17:14:56.056594	2014-09-19 17:14:56.056594	es	Últimos 30 días	f	f	f
2263	last_7_days	\N	f	2014-09-19 17:14:56.076163	2014-09-19 17:14:56.076163	es	Últimos 7 días	f	f	f
2264	last_month	\N	f	2014-09-19 17:14:56.093796	2014-09-19 17:14:56.093796	es	El mes pasado	f	f	f
2245	about_2_blocks	\N	f	2014-09-19 17:14:55.677194	2014-09-25 15:56:38.610353	es	Aproximadamente 2 cuadras	f	f	f
2246	about_4_blocks	\N	f	2014-09-19 17:14:55.69783	2014-09-25 15:57:03.310085	es	Aproximadamente 4 cuadras	f	f	f
2260	all_trips	\N	f	2014-09-19 17:14:56.019881	2014-09-26 13:23:15.114022	es	Todos los viajes	f	f	f
2259	address_is_required	\N	f	2014-09-19 17:14:56.002941	2014-09-25 16:21:37.295172	es	Se requiere una dirección	f	f	f
2220	car_service	\N	f	2014-09-19 17:14:55.358067	2014-10-04 23:32:36.861441	es	Servicio de un Carro Privado	f	f	f
2213	age_is	\N	f	2014-09-19 17:14:55.277248	2014-09-26 12:59:23.86598	es	Age is	f	f	f
2202	additional_emails	\N	f	2014-09-19 17:14:55.152766	2014-09-26 12:59:50.224143	es	Correos electrónicos adicionales	f	f	f
2236	unknown	\N	f	2014-09-19 17:14:55.531993	2014-10-04 03:27:44.977919	es	Desconocido	f	f	f
2207	comments	\N	f	2014-09-19 17:14:55.202437	2014-10-04 23:42:57.14592	es	Comentarios	f	f	f
2208	comments_sent	\N	f	2014-09-19 17:14:55.213248	2014-10-04 23:43:53.184848	es	Comentarios enviados.	f	f	f
2205	comments_updated	\N	f	2014-09-19 17:14:55.182407	2014-10-04 23:44:40.802729	es	Comentarios actualizados.	f	f	f
2223	http_404_not_found	\N	f	2014-09-19 17:14:55.388907	2014-10-05 00:46:13.1379	es	404 No Fue Encontrado	f	f	f
2211	eligibility	\N	f	2014-09-19 17:14:55.255221	2014-09-26 20:29:41.099219	es	Elegibilidad	f	f	f
2212	eligibility_rules_descr	\N	f	2014-09-19 17:14:55.265654	2014-09-26 20:31:32.853839	es	Si ALGUNA de las siguientes reglas se cumplen, el viajero podría ser elegible para utilizar este servicio.	f	f	f
2201	email_hint	\N	f	2014-09-19 17:14:55.14239	2014-09-26 20:34:19.052669	es	Utilice una coma para separar cada dirección de correo electrónico.	f	f	f
2238	filters	\N	f	2014-09-19 17:14:55.556462	2014-09-29 03:25:01.342695	es	Filtros	f	f	f
2225	http_501_not_implemented	\N	f	2014-09-19 17:14:55.409638	2014-10-05 00:48:27.89777	es	501 No se ha implementado	f	f	f
2224	http_422_unprocessable_entity	\N	f	2014-09-19 17:14:55.399448	2014-10-05 00:47:25.057037	es	422 Entidad no puede ser procesada	f	f	f
2209	leave_comments	\N	f	2014-09-19 17:14:55.233032	2014-10-05 00:55:05.066323	es	Deje comentarios sobre este viaje.	f	f	f
2244	less_than_1_block	\N	f	2014-09-19 17:14:55.65113	2014-10-05 00:56:33.170757	es	a menos de una cuadra	f	f	f
2239	legends	\N	f	2014-09-19 17:14:55.571317	2014-09-30 00:58:02.919497	es	Leyendas	f	f	f
2243	miles	\N	f	2014-09-19 17:14:55.634905	2014-09-30 01:49:26.677493	es	millas	f	f	f
2241	minutes	\N	f	2014-09-19 17:14:55.60302	2014-09-30 01:50:35.893645	es	minutos	f	f	f
2215	missing_accommodations	\N	f	2014-09-19 17:14:55.299876	2014-09-30 01:55:29.395909	es	Algunos arreglos no están disponibles	f	f	f
2233	return_selected	\N	f	2014-09-19 17:14:55.497973	2014-10-06 00:05:42.213232	es	La Opción de Regreso fue Seleccionada 	f	f	f
2216	no_accommodations	\N	f	2014-09-19 17:14:55.311974	2014-09-30 03:04:33.35591	es	No se han prestado servicios	f	f	f
2256	not_any_buddies	\N	f	2014-09-19 17:14:55.94266	2014-09-30 17:04:34.581797	es	Usted no tiene amigos.	f	f	f
2258	no_buddies	\N	f	2014-09-19 17:14:55.987568	2014-09-30 03:12:11.240001	es	Usted no tiene ningún viajero que haya solicitado ser su compañero de viaje.	f	f	f
2255	my_buddies	\N	f	2014-09-19 17:14:55.916193	2014-09-30 03:35:54.86146	es	%{owner} Amigos	f	f	f
2237	not_available	\N	f	2014-09-19 17:14:55.543928	2014-09-30 17:06:53.786602	es	No está disponible	f	f	f
2250	one_click_traveler_confirmation_from_from_email	\N	f	2014-09-19 17:14:55.801499	2014-09-30 17:22:22.431395	es	1- Haga clic en la confirmación de amigos por %{by}[/es]	f	f	f
2251	one_click_traveler_decline_by_from_email	\N	f	2014-09-19 17:14:55.820727	2014-09-30 17:27:08.397741	es	1- Clic solicitud de viajero rechazado por %{by}[/es]	f	f	f
2248	one_click_buddy_request_from_from_email	\N	f	2014-09-19 17:14:55.749013	2014-09-30 17:19:58.054512	es	1- Haga click solicitud de amigo de %{from}[/es]	f	f	f
2249	one_click_buddy_revoke_from_from_email	\N	f	2014-09-19 17:14:55.780957	2014-09-30 17:20:51.216293	es	1- Haga clic amigo revocado por %{by}[/es]	f	f	f
2252	one_click_traveler_revoke_by_from_email	\N	f	2014-09-19 17:14:55.848131	2014-09-30 17:28:19.51511	es	1-Clic viajero revocada por %{by}[/es]	f	f	f
2231	outbound_selected	\N	f	2014-09-19 17:14:55.475021	2014-09-30 17:51:39.028999	es	Opción de salida seleccionada, ahora seleccione su opción del regreso.	f	f	f
2232	outbound_selected_short	\N	f	2014-09-19 17:14:55.486344	2014-09-30 17:56:14.10589	es	Opción de salida seleccionado.	f	f	f
2230	outbound_trip_options	\N	f	2014-09-19 17:14:55.46346	2014-09-30 17:57:06.210835	es	Opciones para su viaje de salida	f	f	f
2257	please_save_buddies	\N	f	2014-09-19 17:14:55.961408	2014-09-30 18:32:12.417735	es	Por favor, guarde los cambios para pedir que %{name} sea su amigo.	f	f	f
2204	please_tell_us	\N	f	2014-09-19 17:14:55.172571	2014-09-30 18:33:22.392955	es	Por favor, cuéntenos sobre su reciente viaje.	f	f	f
2229	return_trip_options	\N	f	2014-09-19 17:14:55.451983	2014-10-01 17:47:22.763716	es	Opciones para el Viaje de Regreso	f	f	f
2200	send_email_to	\N	f	2014-09-19 17:14:55.131617	2014-10-03 02:30:03.265809	es	Envíe un correo electrónico a	f	f	f
2197	served_areas	\N	f	2014-09-19 17:14:55.09722	2014-10-03 02:56:25.184889	es	servido	f	f	f
2198	service_area_map	\N	f	2014-09-19 17:14:55.109703	2014-10-03 02:58:05.207118	es	Mapa del Area de Servicio	f	f	f
2217	service_provides_the_following	\N	f	2014-09-19 17:14:55.325854	2014-10-03 03:23:38.104516	es	Este servicio ofrece los siguientes beneficios	f	f	f
2242	sort_by	\N	f	2014-09-19 17:14:55.618005	2014-10-03 03:44:32.50638	es	Ordenar por	f	f	f
2210	submit	\N	f	2014-09-19 17:14:55.24458	2014-10-03 04:12:29.054523	es	Presentar	f	f	f
2203	taken	\N	f	2014-09-19 17:14:55.162789	2014-10-03 04:20:56.455143	es	¿Tomó el viaje?	f	f	f
2199	trip_request_from	\N	f	2014-09-19 17:14:55.120924	2014-10-04 02:24:19.11005	es	Solicitud de viaje de	f	f	f
2206	trips	\N	f	2014-09-19 17:14:55.192589	2014-10-04 03:04:24.525869	es	Viajes	f	f	f
2261	trips_coming_up	\N	f	2014-09-19 17:14:56.035156	2014-10-04 03:09:08.964903	es	Futuros viajes	f	f	f
2218	volunteer	\N	f	2014-09-19 17:14:55.336999	2014-10-04 04:03:04.81313	es	Servicio Voluntario	f	f	f
2254	you_ve_already_asked_them_to_be_a_buddy	\N	f	2014-09-19 17:14:55.891403	2014-10-04 04:17:11.735742	es	Ya le ha pedido que sea su amigo.	f	f	f
2221	buddy	\N	f	2014-09-19 17:14:55.368276	2014-10-04 23:09:40.820535	es	Amigo	f	f	f
2226	arc_oneclick_trip_itinerary	\N	f	2014-09-19 17:14:55.420021	2014-10-04 22:59:11.768546	es	ARC 1-Clic Itinerario del Viaje	f	f	f
2240	minute_abbr	\N	f	2014-09-19 17:14:55.587	2014-10-05 00:59:24.056646	es	min	f	f	f
2219	nemt	\N	f	2014-09-19 17:14:55.347689	2014-10-05 01:02:48.026962	es	No es una Emergencia Médica.	f	f	f
2265	this_month	\N	f	2014-09-19 17:14:56.113362	2014-09-19 17:14:56.113362	es	Este mes	f	f	f
2266	today	\N	f	2014-09-19 17:14:56.129633	2014-09-19 17:14:56.129633	es	Hoy	f	f	f
2267	yesterday	\N	f	2014-09-19 17:14:56.146974	2014-09-19 17:14:56.146974	es	Ayer	f	f	f
2268	ago	\N	f	2014-09-19 17:14:56.164632	2014-09-19 17:14:56.164632	es	 hace	f	f	f
2275	assisting_assisted_user_email	\N	f	2014-09-19 17:14:56.262499	2014-09-19 17:14:56.262499	es	Asistiendo a %{assisted_user}	f	f	f
2276	_menu__object_plural_per_page	\N	f	2014-09-19 17:14:56.274067	2014-09-19 17:14:56.274067	es	_MENU_ %{object} per page	f	f	f
2279	anonymous	\N	f	2014-09-19 17:14:56.312133	2014-09-19 17:14:56.312133	es	anónimo	f	f	f
2280	no_address	\N	f	2014-09-19 17:14:56.323884	2014-09-19 17:14:56.323884	es	no hay dirección	f	f	f
2281	trip_options_hidden.one	\N	f	2014-09-19 17:14:56.335405	2014-09-19 17:14:56.335405	es	%{count} opción escondida.	f	f	f
2282	trip_options_hidden.other	\N	f	2014-09-19 17:14:56.346397	2014-09-19 17:14:56.346397	es	%{count} opciones escondidas.	f	f	f
2283	send_to_traveler	\N	f	2014-09-19 17:14:56.358215	2014-09-19 17:14:56.358215	es	Enviar al viajero	f	f	f
2285	from_address	\N	f	2014-09-19 17:14:56.38555	2014-09-19 17:14:56.38555	es	De la dirección	f	f	f
2286	email_addresses	\N	f	2014-09-19 17:14:56.406656	2014-09-19 17:14:56.406656	es	Correos electrónicos	f	f	f
2295	true	\N	f	2014-09-19 17:14:56.531066	2014-09-19 17:14:56.531066	es	 en 	f	f	f
2296	est	\N	f	2014-09-19 17:14:56.543272	2014-09-19 17:14:56.543272	es	 (est.)	f	f	f
2297	myself	\N	f	2014-09-19 17:14:56.555928	2014-09-19 17:14:56.555928	es	yo mismo	f	f	f
2298	assisted_user_first_name_s_places	\N	f	2014-09-19 17:14:56.567433	2014-09-19 17:14:56.567433	es	Lugares de %{name}	f	f	f
2301	stop_assisting	\N	f	2014-09-19 17:14:56.607633	2014-09-19 17:14:56.607633	es	Detener la asistencia	f	f	f
2310	hello	\N	f	2014-09-19 17:14:56.795765	2014-09-19 17:14:56.795765	es	Hola	f	f	f
2316	yes_str	\N	f	2014-09-19 17:14:56.878175	2014-09-19 17:14:56.878175	es	Sí	f	f	f
2321	ok	\N	f	2014-09-19 17:14:56.961228	2014-09-19 17:14:56.961228	es	Ok	f	f	f
2341	approve	\N	f	2014-09-19 17:14:57.331643	2014-09-26 13:24:17.266564	es	Autorizar	f	f	f
2324	delete	\N	f	2014-09-19 17:14:57.025467	2014-09-26 13:25:24.82251	es	Borrar	f	f	f
2290	end_time	\N	f	2014-09-19 17:14:56.465911	2014-09-29 02:44:28.818354	es	Hora que finaliza	f	f	f
2302	assisting_turned_off	\N	f	2014-09-19 17:14:56.621633	2014-09-26 13:30:32.008555	es	Ayuda ha sido desactivada	f	f	f
2340	contact_info	\N	f	2014-09-19 17:14:57.315959	2014-10-04 23:50:30.176914	es	Información del Contacto	f	f	f
2303	assisting_turned_on	\N	f	2014-09-19 17:14:56.64296	2014-09-26 13:30:56.863657	es	Ayuda ha sido activada	f	f	f
2326	save	\N	f	2014-09-19 17:14:57.076974	2014-09-26 12:50:28.336719	es	Guardar	f	f	f
2327	and	\N	f	2014-09-19 17:14:57.092119	2014-09-26 13:22:44.039607	es	y	f	f	f
2323	edit	\N	f	2014-09-19 17:14:57.005415	2014-09-26 13:25:49.633575	es	Editar	f	f	f
2329	clear	\N	f	2014-09-19 17:14:57.122233	2014-10-04 23:39:09.787669	es	Limpio	f	f	f
2272	didn_t_receive_confirmation_instructions	\N	f	2014-09-19 17:14:56.22254	2014-10-05 00:24:43.36606	es	¿No recibió instrucciones de confirmación?	f	f	f
2300	create_account	\N	f	2014-09-19 17:14:56.593526	2014-09-26 16:47:26.798701	es	Debe crear una cuenta para guardar la información	f	f	f
2339	count	\N	f	2014-09-19 17:14:57.29718	2014-09-26 16:27:20.350696	es	Cuenta	f	f	f
2315	creator	\N	f	2014-09-19 17:14:56.862176	2014-09-26 16:53:18.161517	es	Creador	f	f	f
2306	desktop	\N	f	2014-09-19 17:14:56.705276	2014-09-26 18:37:34.369639	es	Desktop	f	f	f
2322	done	\N	f	2014-09-19 17:14:56.978872	2014-09-26 20:12:44.187666	es	Terminado	f	f	f
2338	back	\N	f	2014-09-19 17:14:57.280985	2014-09-26 20:40:12.142757	es	Volver	f	f	f
2311	id	\N	f	2014-09-19 17:14:56.807937	2014-09-30 00:17:35.446543	es	ID	f	f	f
2332	in_str	\N	f	2014-09-19 17:14:57.169937	2014-09-30 00:34:59.661635	es	En	f	f	f
2331	itineraries	\N	f	2014-09-19 17:14:57.156886	2014-09-30 00:48:01.107254	es	Itinerarios	f	f	f
2330	itinerary	\N	f	2014-09-19 17:14:57.139751	2014-09-30 00:48:38.131208	es	Itinerario	f	f	f
2307	kiosk	\N	f	2014-09-19 17:14:56.72519	2014-09-30 00:52:58.164955	es	Quiosco	f	f	f
2328	new	\N	f	2014-09-19 17:14:57.105114	2014-09-30 02:47:46.865128	es	Nuevo	f	f	f
2270	thanks_for_the_feedback	\N	f	2014-09-19 17:14:56.198395	2014-10-06 00:12:02.921822	es	¡Gracias por sus comentarios!	f	f	f
2318	no_answer_str	\N	f	2014-09-19 17:14:56.912755	2014-09-30 03:10:21.201585	es	No respondió	f	f	f
2317	no_str	\N	f	2014-09-19 17:14:56.8968	2014-09-30 16:50:28.880798	es	No	f	f	f
2320	not_sure_str	\N	f	2014-09-19 17:14:56.948	2014-09-30 17:08:01.415461	es	No estoy seguro	f	f	f
2271	optional_comments_descr	\N	f	2014-09-19 17:14:56.210543	2014-09-30 17:32:03.487949	es	Si desea proporcionar comentarios opcionales o una calificación para su viaje, usted puede hacerlo a continuación.	f	f	f
2333	out_str	\N	f	2014-09-19 17:14:57.18239	2014-09-30 17:40:44.396372	es	Salir	f	f	f
2334	role	\N	f	2014-09-19 17:14:57.205295	2014-10-01 17:56:36.765627	es	Oficio	f	f	f
2335	roles	\N	f	2014-09-19 17:14:57.22212	2014-10-01 17:57:12.822288	es	Oficios	f	f	f
2336	select_users	\N	f	2014-09-19 17:14:57.245582	2014-10-01 18:29:01.341624	es	Seleccione los usuarios	f	f	f
2284	send_request_to_provider	\N	f	2014-09-19 17:14:56.371123	2014-10-03 02:37:38.178081	es	Enviar una solicitud al proveedor	f	f	f
2278	showing__start__to__end__of__total__object_plural	\N	f	2014-09-19 17:14:56.298219	2014-10-03 03:28:30.138888	es	COMIENZO_ al _FINAL_ de _TOTAL_ %{object}	f	f	f
2274	sign_in_with_provider_to_s_titleize	\N	f	2014-09-19 17:14:56.246204	2014-10-03 03:34:50.562963	es	Iniciar sesión con %{provider}	f	f	f
2308	tablet	\N	f	2014-09-19 17:14:56.745022	2014-10-03 04:19:47.419995	es	Tableta	f	f	f
2288	start_time	\N	f	2014-09-19 17:14:56.436633	2014-10-03 04:03:44.109176	es	Hora de Inicio	f	f	f
2287	start	\N	f	2014-09-19 17:14:56.421829	2014-10-03 04:04:18.106774	es	INICIO: 	f	f	f
2309	user_agent	\N	f	2014-09-19 17:14:56.780672	2014-10-06 00:20:33.491647	es	agente-usuario	f	f	f
2289	times	\N	f	2014-09-19 17:14:56.451772	2014-10-04 01:13:34.903606	es	Hora	f	f	f
2292	transit_time	\N	f	2014-09-19 17:14:56.49497	2014-10-04 01:32:12.216927	es	Tiempo de transporte público.	f	f	f
2299	trip_options_information_from_from	\N	f	2014-09-19 17:14:56.57904	2014-10-04 02:11:38.022759	es	Información de opciones del viaje de #{@from}	f	f	f
2305	ui_mode	\N	f	2014-09-19 17:14:56.685388	2014-10-04 03:19:44.517551	es	Modo UI	f	f	f
2313	username	\N	f	2014-09-19 17:14:56.838942	2014-10-04 03:47:50.382167	es	Nombre de usuario	f	f	f
2314	undo	\N	f	2014-09-19 17:14:56.850154	2014-10-04 03:25:41.220836	es	Deshacer	f	f	f
2319	unsure_str	\N	f	2014-09-19 17:14:56.932346	2014-10-04 03:29:20.978655	es	Indeciso	f	f	f
2312	user	\N	f	2014-09-19 17:14:56.827628	2014-10-04 03:41:06.367295	es	Usuario	f	f	f
2294	walk_distance_short	\N	f	2014-09-19 17:14:56.519039	2014-10-23 02:46:37.362668	es	Distancia caminando	f	f	f
2325	undelete	\N	f	2014-09-19 17:14:57.052714	2014-10-04 03:45:34.268799	es	Recuperar	f	f	f
2293	wait_time	\N	f	2014-09-19 17:14:56.507498	2014-10-04 04:06:45.431637	es	Tiempo de espera	f	f	f
2291	walk_time	\N	f	2014-09-19 17:14:56.478072	2014-10-23 02:47:02.665629	es	Tiempo caminando	f	f	f
2277	_menu__records_per_page	\N	f	2014-09-19 17:14:56.28524	2014-10-04 22:50:42.466819	es	_MENU_ Registros por página	f	f	f
2304	ask_age	\N	f	2014-09-19 17:14:56.668094	2014-10-04 23:00:30.431284	es	¿Tiene usted %{age} años de edad o más?	f	f	f
2273	didn_t_receive_unlock_instructions	\N	f	2014-09-19 17:14:56.235221	2014-10-05 00:25:42.079845	es	¿No recibió instrucciones de cómo desbloquear?	f	f	f
2269	new_esp_successfully_uploaded	\N	f	2014-09-19 17:14:56.179669	2014-10-05 01:03:53.450814	es	Nuevo Archivo de ESP se subió con éxito	f	f	f
2365	all	\N	f	2014-09-19 17:14:57.816686	2014-09-19 17:14:57.816686	es	Todos	f	f	f
2377	locales.es	\N	f	2014-09-19 17:14:58.088576	2014-09-19 17:14:58.088576	es	En Español	f	f	f
2378	locales.ht	\N	f	2014-09-19 17:14:58.106017	2014-09-19 17:14:58.106017	es	Creole	f	f	f
2379	arc.logotext	\N	f	2014-09-19 17:14:58.127242	2014-09-19 17:14:58.127242	es		f	f	f
2382	pa.logotext	\N	f	2014-09-19 17:14:58.183389	2014-09-19 17:14:58.183389	es		f	f	f
2385	broward.logotext	\N	f	2014-09-19 17:14:58.255951	2014-09-19 17:14:58.255951	es		f	f	f
2386	broward.site_title	\N	f	2014-09-19 17:14:58.284843	2014-09-19 17:14:58.284843	es	Broward 1-Click	f	f	f
2387	broward.site_description	\N	f	2014-09-19 17:14:58.30749	2014-09-19 17:14:58.30749	es	Aplicación Broward 1-Click	f	f	f
2388	jta.logotext	\N	f	2014-09-19 17:14:58.336463	2014-09-19 17:14:58.336463	es		f	f	f
2392	ieuw.logotext	\N	f	2014-09-19 17:14:58.398601	2014-09-19 17:14:58.398601	es		f	f	f
2393	ieuw.site_title	\N	f	2014-09-19 17:14:58.412074	2014-09-19 17:14:58.412074	es	VetLink	f	f	f
2396	simple_form.labels.defaults.first_name	\N	f	2014-09-19 17:14:58.451979	2014-09-19 17:14:58.451979	es	Nombre	f	f	f
2397	simple_form.labels.defaults.last_name	\N	f	2014-09-19 17:14:58.467644	2014-09-19 17:14:58.467644	es	Apellido	f	f	f
2398	simple_form.labels.defaults.email	\N	f	2014-09-19 17:14:58.485813	2014-09-19 17:14:58.485813	es	Correo electrónico	f	f	f
2399	simple_form.labels.defaults.password	\N	f	2014-09-19 17:14:58.505397	2014-09-19 17:14:58.505397	es	Contraseña	f	f	f
2400	simple_form.labels.defaults.remember_me	\N	f	2014-09-19 17:14:58.523461	2014-09-19 17:14:58.523461	es	 Acuérdate de mí 	f	f	f
2401	simple_form.labels.defaults.retype_your_password	\N	f	2014-09-19 17:14:58.550922	2014-09-19 17:14:58.550922	es	Vuelve a escribir tu contraseña'	f	f	f
2402	simple_form.labels.user.first_name	\N	f	2014-09-19 17:14:58.569026	2014-09-19 17:14:58.569026	es	Nombre	f	f	f
2406	date.formats.default	\N	f	2014-09-19 17:14:58.630781	2014-09-19 17:14:58.630781	es	%d/%m/%Y	f	f	f
2407	date.formats.long	\N	f	2014-09-19 17:14:58.649923	2014-09-19 17:14:58.649923	es	%d de %B de %Y	f	f	f
2408	date.formats.short	\N	f	2014-09-19 17:14:58.668006	2014-09-19 17:14:58.668006	es	%d de %b	f	f	f
2409	date.formats.oneclick_long	\N	f	2014-09-19 17:14:58.686235	2014-09-19 17:14:58.686235	es	%A, %B %-d %Y	f	f	f
2410	date.formats.oneclick_short	\N	f	2014-09-19 17:14:58.707636	2014-09-19 17:14:58.707636	es	%A, %B %-d	f	f	f
2380	arc.site_title	\N	f	2014-09-19 17:14:58.145679	2014-10-04 22:57:43.381844	es	ARC 1-Clic	f	f	f
2353	here	\N	f	2014-09-19 17:14:57.555615	2014-09-29 23:54:50.512214	es	aquí	f	f	f
2390	jta.site_description	\N	f	2014-09-19 17:14:58.369996	2014-10-05 00:53:26.800924	es	JTA 1-Haga Clic en la Aplicación	f	f	f
2403	date.abbr_day_names	\N	f	2014-09-19 17:14:58.584988	2014-09-26 16:59:16.440986	es	Dom, Lun, Mar, Mié, Jue, Vie, Sáb	f	f	t
2411	date.month_names	\N	f	2014-09-19 17:14:58.720797	2014-09-26 17:03:34.441788	es	Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre	f	f	t
2344	do_not_reply	\N	f	2014-09-19 17:14:57.381492	2014-09-26 20:05:48.384257	es	Este correo electrónico es enviado desde una dirección de correo electrónico que no es monitoreado. Por favor, no responda a este mensaje.	f	f	f
2375	before_msg	\N	f	2014-09-19 17:14:58.028291	2014-09-26 20:42:06.857926	es	debe ser antes	f	f	f
2391	ieuw.home	\N	f	2014-09-19 17:14:58.385855	2014-09-30 00:22:40.568619	es	Inicio VetLink	f	f	f
2395	ieuw.next	\N	f	2014-09-19 17:14:58.43763	2014-09-30 00:27:39.920086	es	Siguiente	f	f	f
2394	ieuw.site_description	\N	f	2014-09-19 17:14:58.425294	2014-09-30 00:28:49.936075	es	VetLink 1-Haga Clic en Aplicación	f	f	f
2360	information	\N	f	2014-09-19 17:14:57.705067	2014-09-30 00:39:42.263232	es	Información	f	f	f
2361	internal_contact	\N	f	2014-09-19 17:14:57.724913	2014-09-30 00:41:08.555465	es	Contacto interno	f	f	f
2389	jta.site_title	\N	f	2014-09-19 17:14:58.354102	2014-09-30 00:50:26.376336	es	JTA 1-Clic	f	f	f
2359	list	\N	f	2014-09-19 17:14:57.65704	2014-09-30 01:07:39.015184	es	Lista	f	f	f
2376	locales.en	\N	f	2014-09-19 17:14:58.056682	2014-09-30 01:24:08.183416	es	Ingles	f	f	f
2354	more_feedback_link	\N	f	2014-09-19 17:14:57.580857	2014-09-30 02:23:59.081394	es	Haga clic AQUÍ si desea proporcionar más información, o si las cosas no funcionaron como estaba previsto.	f	f	f
2343	no_good_options	\N	f	2014-09-19 17:14:57.36068	2014-09-30 03:20:00.650826	es	No hay buenas opciones aquí	f	f	f
2351	no_trip_taken_feedback_link	\N	f	2014-09-19 17:14:57.51829	2014-09-30 16:56:33.372932	es	Si decide no hacer este viaje,	f	f	f
2357	none	\N	f	2014-09-19 17:14:57.62165	2014-09-30 16:59:35.511172	es	Ninguno	f	f	f
2345	nothing_found_sorry	\N	f	2014-09-19 17:14:57.398201	2014-09-30 17:12:44.148378	es	Lo sentimos - No se ha encontrado nada	f	f	f
2384	pa.site_description	\N	f	2014-09-19 17:14:58.240918	2014-09-30 17:57:57.070931	es	1-Clic Aplicación PA	f	f	f
2383	pa.site_title	\N	f	2014-09-19 17:14:58.209187	2014-09-30 17:58:35.382677	es	1-Clic PA	f	f	f
2352	please_click	\N	f	2014-09-19 17:14:57.541785	2014-09-30 18:29:53.637456	es	Por favor, haga clic en	f	f	f
2374	presence_msg	\N	f	2014-09-19 17:14:57.998351	2014-09-30 18:37:24.591823	es	no puede estar en blanco	f	f	f
2342	reject	\N	f	2014-09-19 17:14:57.345062	2014-10-01 17:08:16.336488	es	Rechazar	f	f	f
2369	relationship_status.relationship_status_confirmed	\N	f	2014-09-19 17:14:57.872713	2014-10-01 17:10:10.23218	es	Confirmados	f	f	f
2370	relationship_status.relationship_status_denied	\N	f	2014-09-19 17:14:57.897128	2014-10-01 17:12:32.793965	es	Rechazado	f	f	f
2372	relationship_status.relationship_status_hidden	\N	f	2014-09-19 17:14:57.943374	2014-10-01 17:13:12.292288	es	Oculto	f	f	f
2368	relationship_status.relationship_status_pending	\N	f	2014-09-19 17:14:57.857697	2014-10-01 17:15:08.345424	es	Pendiente	f	f	f
2367	relationship_status.relationship_status_requested	\N	f	2014-09-19 17:14:57.844511	2014-10-01 17:16:03.408251	es	Solicitado	f	f	f
2371	relationship_status.relationship_status_revoked	\N	f	2014-09-19 17:14:57.929668	2014-10-01 17:16:46.616386	es	Revocado	f	f	f
2355	search	\N	f	2014-09-19 17:14:57.595835	2014-10-01 18:08:15.09477	es	Búsqueda	f	f	f
2358	show	\N	f	2014-09-19 17:14:57.635569	2014-10-03 03:26:09.423897	es	Mostrar	f	f	f
2346	solicit_feedback	\N	f	2014-09-19 17:14:57.412637	2014-10-03 03:41:54.331118	es	Por favor, danos algunos comentarios:	f	f	f
2363	state	\N	f	2014-09-19 17:14:57.754828	2014-10-03 04:05:01.742274	es	Estado	f	f	f
2350	success_feedback_link	\N	f	2014-09-19 17:14:57.496561	2014-10-03 04:14:51.133985	es	para proporcionar información sobre su viaje	f	f	f
2366	system_usage	\N	f	2014-09-19 17:14:57.829138	2014-10-03 04:17:23.574339	es	Uso del Sistema	f	f	f
2347	thanks_for_feedback	\N	f	2014-09-19 17:14:57.438027	2014-10-04 01:09:21.1369	es	Gracias de antemano por sus comentarios!	f	f	f
2349	thanks_for_responding	\N	f	2014-09-19 17:14:57.470975	2014-10-04 01:10:39.051695	es	Gracias por tomarse el tiempo para responder.	f	f	f
2364	zip	\N	f	2014-09-19 17:14:57.795598	2014-10-04 04:18:13.454292	es	Código postal	f	f	f
2373	valid_time_msg	\N	f	2014-09-19 17:14:57.970429	2014-10-04 03:49:54.274924	es	Debe ser una hora válida 	f	f	f
2381	arc.site_description	\N	f	2014-09-19 17:14:58.161979	2014-10-04 22:57:04.988597	es	ARC 1-Clic para Aplicar	f	f	f
2405	date.day_names	\N	f	2014-09-19 17:14:58.616973	2014-10-04 23:06:52.70783	es	Domingo, Lunes, Martes, Miércoles, Jueves, Viernes, Sábado	f	f	t
2362	city	\N	f	2014-09-19 17:14:57.738008	2014-10-04 23:37:32.297367	es	Ciudad	f	f	f
2413	time.am	\N	f	2014-09-19 17:14:58.745957	2014-09-19 17:14:58.745957	es	am	f	f	f
2414	time.formats.default	\N	f	2014-09-19 17:14:58.759479	2014-09-19 17:14:58.759479	es	%A, %d de %B de %Y %H:%M:%S %z	f	f	f
2415	time.formats.long	\N	f	2014-09-19 17:14:58.770917	2014-09-19 17:14:58.770917	es	%d de %B de %Y %H:%M	f	f	f
2416	time.formats.short	\N	f	2014-09-19 17:14:58.788175	2014-09-19 17:14:58.788175	es	%d de %b %H:%M	f	f	f
2417	time.formats.isoish	\N	f	2014-09-19 17:14:58.801378	2014-09-19 17:14:58.801378	es	%Y-%m-%d %l:%M %p	f	f	f
2418	time.formats.oneclick_short	\N	f	2014-09-19 17:14:58.813053	2014-09-19 17:14:58.813053	es	%-I:%M %p	f	f	f
2419	time.pm	\N	f	2014-09-19 17:14:58.831899	2014-09-19 17:14:58.831899	es	pm	f	f	f
2420	datetime.distance_in_words.about_x_hours.one	\N	f	2014-09-19 17:14:58.845564	2014-09-19 17:14:58.845564	es	[es]about 1 hour	f	f	f
2421	datetime.distance_in_words.about_x_hours.other	\N	f	2014-09-19 17:14:58.866722	2014-09-19 17:14:58.866722	es	[es]%{count} hours[/es]	f	f	f
2422	datetime.distance_in_words.x_days.one	\N	f	2014-09-19 17:14:58.891976	2014-09-19 17:14:58.891976	es	1 minuto	f	f	f
2423	datetime.distance_in_words.x_days.other	\N	f	2014-09-19 17:14:58.908231	2014-09-19 17:14:58.908231	es	%{count} dias	f	f	f
2424	datetime.distance_in_words.x_hours.one	\N	f	2014-09-19 17:14:58.921889	2014-09-19 17:14:58.921889	es	1 hora	f	f	f
2425	datetime.distance_in_words.x_hours.other	\N	f	2014-09-19 17:14:58.935859	2014-09-19 17:14:58.935859	es	%{count} horas	f	f	f
2426	datetime.distance_in_words.less_than_x_minutes.one	\N	f	2014-09-19 17:14:58.952563	2014-09-19 17:14:58.952563	es	[es]less than 1 minute[/es]	f	f	f
2427	datetime.distance_in_words.less_than_x_minutes.other	\N	f	2014-09-19 17:14:58.974746	2014-09-19 17:14:58.974746	es	[es]less than %{count} minutes[/es]	f	f	f
2428	datetime.distance_in_words.x_minutes.one	\N	f	2014-09-19 17:14:58.994195	2014-09-19 17:14:58.994195	es	1 minuto	f	f	f
2429	datetime.distance_in_words.x_minutes.other	\N	f	2014-09-19 17:14:59.018762	2014-09-19 17:14:59.018762	es	%{count} minutos	f	f	f
2430	datetime.prompts.day	\N	f	2014-09-19 17:14:59.040726	2014-09-19 17:14:59.040726	es	Día	f	f	f
2431	datetime.prompts.hour	\N	f	2014-09-19 17:14:59.055757	2014-09-19 17:14:59.055757	es	Hora	f	f	f
2432	datetime.prompts.minute	\N	f	2014-09-19 17:14:59.074536	2014-09-19 17:14:59.074536	es	Minutos	f	f	f
2433	datetime.prompts.month	\N	f	2014-09-19 17:14:59.09819	2014-09-19 17:14:59.09819	es	Mes	f	f	f
2434	datetime.prompts.second	\N	f	2014-09-19 17:14:59.111419	2014-09-19 17:14:59.111419	es	Segundos	f	f	f
2435	datetime.prompts.year	\N	f	2014-09-19 17:14:59.127119	2014-09-19 17:14:59.127119	es	Año	f	f	f
2437	activerecord.errors.models.user.attributes.first_name.blank	\N	f	2014-09-19 17:14:59.152594	2014-09-19 17:14:59.152594	es	no puede estar en blanco	f	f	f
2438	activerecord.errors.models.user.attributes.last_name.blank	\N	f	2014-09-19 17:14:59.164218	2014-09-19 17:14:59.164218	es	no puede estar en blanco	f	f	f
2439	activerecord.errors.models.user.attributes.email.blank	\N	f	2014-09-19 17:14:59.181313	2014-09-19 17:14:59.181313	es	no puede estar en blanco	f	f	f
2440	activerecord.errors.models.user.attributes.email.invalid	\N	f	2014-09-19 17:14:59.205281	2014-09-19 17:14:59.205281	es	no es válido	f	f	f
2441	activerecord.errors.models.user.attributes.password.blank	\N	f	2014-09-19 17:14:59.226249	2014-09-19 17:14:59.226249	es	no puede estar en blanco	f	f	f
2442	activerecord.errors.models.user.attributes.password.confirmation	\N	f	2014-09-19 17:14:59.243534	2014-09-19 17:14:59.243534	es	no coincide con la confirmación	f	f	f
2443	activerecord.errors.models.user.attributes.password_confirmation.confirmation	\N	f	2014-09-19 17:14:59.265194	2014-09-19 17:14:59.265194	es	no coincide con la confirmación	f	f	f
2444	activerecord.errors.models.user.attributes.current_password.blank	\N	f	2014-09-19 17:14:59.284814	2014-09-19 17:14:59.284814	es	no puede estar en blanco	f	f	f
2445	activemodel.errors.models.place_proxy.attributes.name.blank	\N	f	2014-09-19 17:14:59.311003	2014-09-19 17:14:59.311003	es	no puede estar en blanco	f	f	f
2446	activemodel.errors.models.place_proxy.attributes.raw_address.blank	\N	f	2014-09-19 17:14:59.331362	2014-09-19 17:14:59.331362	es	no puede estar en blanco	f	f	f
2447	activemodel.errors.models.trip_proxy.attributes.from_place.blank	\N	f	2014-09-19 17:14:59.354772	2014-09-19 17:14:59.354772	es	no puede estar en blanco	f	f	f
2448	activemodel.errors.models.trip_proxy.attributes.to_place.blank	\N	f	2014-09-19 17:14:59.373047	2014-09-19 17:14:59.373047	es	no puede estar en blanco	f	f	f
2104	next	\N	f	2014-09-19 17:14:53.868176	2014-09-30 03:29:12.932748	es	SIGUIENTE	f	f	f
136	curb_to_curb_note	\N	f	2014-07-09 21:57:35.114996	2014-09-26 16:55:34.198565	es	¿Necesita asistencia a la acera en frente de su casa?	f	f	f
2412	date.order	\N	f	2014-09-19 17:14:58.733926	2014-09-26 17:05:09.025026	es	día, mes, año	f	f	t
40	mode_rideshare_name	\N	f	2014-07-09 21:57:32.67013	2014-09-30 02:10:48.781133	es	Viaje compartido	f	f	f
1949	plan	\N	f	2014-09-19 17:14:51.905535	2014-09-30 18:17:22.777274	es	Plan	f	f	f
1749	send_your_feedback	\N	f	2014-09-19 17:14:49.029145	2014-10-03 02:49:55.167445	es	Comentarios	f	f	f
2455	SystemUsageReport	\N	f	2014-09-19 17:23:30.382874	2014-10-03 04:18:42.23356	es	Informe del Uso del Sistema	f	f	f
2457	TripsDatatable	\N	f	2014-09-19 17:23:30.433821	2014-10-04 03:12:31.526066	es	Informe de los Detalles del Viaje	f	f	f
2436	unauthorized.default	\N	f	2014-09-19 17:14:59.140313	2014-10-04 03:21:24.232552	es	No tiene permisos para acceder a esa página.	f	f	f
212	splash	\N	f	2014-07-17 19:26:57.942665	2014-10-03 03:59:59.559241	es	Bienvenido a Simply Get There, un centro virtual de recursos de transporte financiado por la <a href="http://www.fta.dot.gov/">Federal Transit Administration</a> (FTA) y auspiciado por <a href="http://www.atlantaregional.com/">Atlanta Regional Commission</a> (ARC). Este proyecto es un esfuerzo en conjunto con los proveedores de transportación, funcionarios electos, personas que elaboran políticas a seguir, expertos en planificación, representantes de agencias de financiación y organismos que apoyan a las personas desfavorecidas de el sistema de transporte, incluyendo a los veteranos y familiares de los militares.	f	f	f
2103	logo_format_alert	\N	f	2014-09-19 17:14:53.853298	2014-09-30 01:32:01.164309	es	Sólo se apoyan formatos de imagenes de logotipos: %{logo_formats}	f	f	f
1827	about_you	\N	f	2014-09-19 17:14:50.402678	2014-09-25 15:41:07.621186	es	Acerca de Usted	f	f	f
1989	bikeshare	\N	f	2014-09-19 17:14:52.362748	2014-10-01 18:31:38.886567	es	Compartir Bicicleta	f	f	f
2227	an_email_was_sent_to_email_addresses_join	\N	f	2014-09-19 17:14:55.430338	2014-09-25 17:02:22.947681	es	Se envió un correo electrónico a %{addresses}.	f	f	f
2337	add	\N	f	2014-09-19 17:14:57.265192	2014-09-26 12:50:14.403991	es	Añadir	f	f	f
2147	active	\N	f	2014-09-19 17:14:54.373192	2014-09-26 12:51:13.39099	es	Activo	f	f	f
2214	accommodations	\N	f	2014-09-19 17:14:55.288423	2014-09-26 12:51:27.219332	es	Capacidad	f	f	f
1860	add_user	\N	f	2014-09-19 17:14:50.817302	2014-09-26 12:51:49.826834	es	Añadir usuario	f	f	f
2182	addl_cost_details	\N	f	2014-09-19 17:14:54.87582	2014-09-26 12:58:34.9361	es	Detalles adicionales de costos	f	f	f
2085	add_sidewalk_feedback_on_map	\N	f	2014-09-19 17:14:53.590212	2014-09-26 12:59:37.709023	es	Reportar obstrucción en una acera	f	f	f
2356	aid_user	\N	f	2014-09-19 17:14:57.608405	2014-09-26 13:00:14.429122	es	Ayuda al usuario	f	f	f
1778	all_providers	\N	f	2014-09-19 17:14:49.659343	2014-09-26 13:23:47.071951	es	Todos los Proveedores	f	f	f
1974	correct_errors_to_create_a_trip	\N	f	2014-09-19 17:14:52.180868	2014-09-26 16:12:41.506823	es	Por favor, corrija los errores señalados para crear un viaje.	f	f	f
2181	cost_details	\N	f	2014-09-19 17:14:54.865315	2014-09-26 16:25:40.60623	es	Detalles del costo	f	f	f
2404	date.abbr_month_names	\N	f	2014-09-19 17:14:58.599515	2014-09-26 17:02:23.195964	es	Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic	f	f	t
2348	follow_up_email_template	\N	f	2014-09-19 17:14:57.453103	2014-09-29 03:58:23.300177	es	En %{trip_created_date}, usaste %{product_name} para planificar un viaje para %{trip_date} de %{trip_from_address} a %{trip_to_address}	f	f	f
1884	follow_up_question_descr	\N	f	2014-09-19 17:14:51.079674	2014-09-29 04:02:15.130576	es	Teniendo en cuenta sus respuestas, tenemos una última página de preguntas de seguimiento. Conteste todas las preguntas que usted se sienta cómodo proporcionando una respuesta. Si no desea responder a una pregunta, seleccione "No estoy seguro". <br> <br> Toque "Siguiente Paso" cuando haya terminado con estas preguntas.	f	f	f
2052	link_to_georgia_commute_options.one	\N	f	2014-09-19 17:14:53.155199	2014-09-30 01:05:59.477988	es	Visita %{url} para ver una opción para compartir el viaje en el vehículo.	f	f	f
1863	buddy_request_email_intro	\N	f	2014-09-19 17:14:50.846935	2014-10-04 23:10:19.407118	es	El viajero %{name} ha solicitado su ayuda para planificar sus viajes utilizando %{site_title}.	f	f	f
1702	devise.confirmations.confirmed	\N	f	2014-09-19 17:14:47.695359	2014-10-05 00:03:55.984765	es	Su cuenta fue confirmada exitosamente, has sido añadido al sistema.	f	f	f
1701	devise.confirmations.send_paranoid_instructions	\N	f	2014-09-19 17:14:47.664568	2014-10-05 00:04:49.107813	es	Si su correo electrónico existe en nuestra base de datos, recibirás un correo con instrucciones sobre cómo confirmar su cuenta en unos minutos.	f	f	f
1706	devise.registrations.destroyed	\N	f	2014-09-19 17:14:47.842601	2014-10-05 00:14:26.094975	es	¡Hasta luego! Su cuenta fue cancelada exitosamente, esperamos verle de nuevo muy pronto. Gracias.	f	f	f
54	mode_bike_park_transit_name	\N	f	2014-07-09 21:57:33.043569	2014-10-05 01:13:05.404075	es	Viaje en Bicicleta y en Transporte	f	f	f
2477	trip_header_comment	\N	f	2014-10-10 21:23:41.198366	2014-10-10 21:23:41.198366	es		f	f	f
2478	trip_footer_comment	\N	f	2014-10-10 21:23:41.203275	2014-10-10 21:23:41.203275	es		f	f	f
2479	options_header_comment	\N	f	2014-10-10 21:23:41.207795	2014-10-10 21:23:41.207795	es		f	f	f
2480	options_footer_comment	\N	f	2014-10-10 21:23:41.21299	2014-10-10 21:23:41.21299	es		f	f	f
2481	grid_header_comment	\N	f	2014-10-10 21:23:41.217743	2014-10-10 21:23:41.217743	es		f	f	f
2482	grid_footer_comment	\N	f	2014-10-10 21:23:41.222368	2014-10-10 21:23:41.222368	es		f	f	f
2483	review_header_comment	\N	f	2014-10-10 21:23:41.22726	2014-10-10 21:23:41.22726	es		f	f	f
2484	review_footer_comment	\N	f	2014-10-10 21:23:41.232606	2014-10-10 21:23:41.232606	es		f	f	f
2485	plan_header_comment	\N	f	2014-10-10 21:23:41.242644	2014-10-10 21:23:41.242644	es		f	f	f
2486	plan_footer_comment	\N	f	2014-10-10 21:23:41.247237	2014-10-10 21:23:41.247237	es		f	f	f
2461	multi_od_trip	\N	f	2014-10-10 21:23:41.05143	2014-10-23 02:17:25.172969	es	Viaje Multiple Origen-Destino	f	f	f
2462	routes	\N	f	2014-10-10 21:23:41.05445	2014-10-23 02:40:25.374346	es	Rutas	f	f	f
2463	grid	\N	f	2014-10-10 21:23:41.057581	2014-10-23 03:23:43.488142	es	Revisión	f	f	f
2544	multi_od_trip_header_comment	\N	f	2014-10-10 21:26:07.831678	2014-10-10 21:26:07.831678	es		f	f	f
2545	multi_od_trip_footer_comment	\N	f	2014-10-10 21:26:07.843814	2014-10-10 21:26:07.843814	es		f	f	f
2549	trip_dir	\N	f	2014-10-10 21:26:13.52006	2014-10-13 18:04:25.177181	es	Viaje	f	f	f
2546	trip_parameters	\N	f	2014-10-10 21:26:10.604172	2014-10-13 18:04:43.584212	es		f	f	f
2548	splash_title	\N	f	2014-10-10 21:26:10.676314	2014-10-13 18:05:36.689084	es		f	f	f
2540	you_ve_already_added_this_agent	\N	f	2014-10-10 21:25:59.363837	2014-10-23 01:34:08.382968	es	Usted ha agregado este agente.	f	f	f
2552	legend	\N	f	2014-10-10 21:26:21.467232	2014-10-23 01:44:32.690899	es	Leyendas	f	f	f
2542	agency_info	\N	f	2014-10-10 21:26:00.216949	2014-10-23 01:47:36.279677	es	Información de la Agencia	f	f	f
2537	agency_was_successfully_created	\N	f	2014-10-10 21:25:59.303676	2014-10-23 01:49:04.462429	es	La Agencia se ha creado correctamente.	f	f	f
2535	comment	\N	f	2014-10-10 21:25:58.503785	2014-10-23 02:04:35.501095	es	Comentario	f	f	f
2551	clear_?	\N	f	2014-10-10 21:26:19.41386	2014-10-23 02:03:59.910238	es	Limpiar?	f	f	f
2550	cut_off_time	\N	f	2014-10-10 21:26:19.391222	2014-10-23 02:06:51.704351	es	Tiempo de Recorte	f	f	f
2554	date_option_custom_name	\N	f	2014-10-10 21:28:02.826761	2014-10-23 02:08:26.542677	es	Costumbre	f	f	f
2547	eligibility_accommodation_questions	\N	f	2014-10-10 21:26:10.629656	2014-10-23 02:09:58.002384	es	Elegibilidad/Alojamiento Preguntas	f	f	f
2538	find_agent	\N	f	2014-10-10 21:25:59.323923	2014-10-23 02:10:56.506616	es	Encuentre Agente	f	f	f
2539	no_agent_with_email_address	\N	f	2014-10-10 21:25:59.341021	2014-10-23 02:25:33.099503	es	No podemos encontrar un agente con este correo electrónico '%{email}'.	f	f	f
2536	no_comments	\N	f	2014-10-10 21:25:58.548618	2014-10-23 02:26:19.27956	es	Sin comentarios	f	f	f
2541	please_save_agents	\N	f	2014-10-10 21:25:59.375427	2014-10-23 02:33:37.207807	es	Por favor, guarde los agentes.	f	f	f
2543	walk_distance	\N	f	2014-10-10 21:26:01.477505	2014-10-23 02:45:11.768546	es	Distancia caminando	f	f	f
2582	options_page_splash	\N	f	2014-10-17 17:59:59.321923	2014-10-17 17:59:59.321923	es		f	f	f
2595	email_footer	\N	f	2014-10-23 02:16:33.032926	2014-10-23 02:18:57.08372	es	Enviado por Cambridge Systematics, 100 Cambridge Park Dr, Cambridge MA 02140 en nombre de %{application_name}	f	f	f
2077	cannot_change_time_to_after_next_trip_part	\N	f	2014-09-19 17:14:53.507406	2014-10-23 01:54:04.694314	es	[es]Cannot change trip part time to be after next trip part, NOTE: This sentence is hard to translate. Does not make sense!!!! Need to see the final version or where is going to be used[/es]\r\nNo se puede cambiar el viaje a tiempo parcial hasta después que el viaje haya comenzado	f	f	f
2577	find_staff	\N	f	2014-10-17 17:59:54.854327	2014-10-23 02:11:48.777838	es	Encuentre personal	f	f	f
2586	map	\N	f	2014-10-17 18:00:02.931923	2014-10-23 02:14:37.997978	es	Mapa	f	f	f
2597	rating_in_stars	\N	f	2014-10-23 02:16:35.423608	2014-10-23 02:16:35.423608	es	Clasificacion *7*	f	f	f
2596	email_thank_you	\N	f	2014-10-23 02:16:33.043665	2014-10-23 02:20:01.088334	es	Gracias por usar el Software %{application_name}.	f	f	f
2599	fare_filter	\N	f	2014-10-23 02:16:44.723132	2014-10-23 02:20:29.388348	es	Tarifa	f	f	f
2598	modes_filter	\N	f	2014-10-23 02:16:44.709233	2014-10-23 02:23:00.905797	es	Modos	f	f	f
2578	no_staff_with_email_address	\N	f	2014-10-17 17:59:54.881748	2014-10-23 02:27:37.834113	es	No podemos encontrar un empleado con este correo electrónico '%{email}'.	f	f	f
2600	number_of_transfers_filter	\N	f	2014-10-23 02:16:44.73522	2014-10-23 02:28:32.84542	es	Numero de Transferencias	f	f	f
2583	options_page_splash_title	\N	f	2014-10-17 17:59:59.337179	2014-10-23 02:32:45.792819	es	Esparcirse	f	f	f
2579	please_save_staffs	\N	f	2014-10-17 17:59:54.895291	2014-10-23 02:34:51.19192	es	Por favor, guarde empleado.	f	f	f
2584	plus	\N	f	2014-10-17 18:00:01.402889	2014-10-23 02:35:20.937603	es	más	f	f	f
2587	preparing_maps	\N	f	2014-10-17 18:00:03.15283	2014-10-23 02:37:22.865308	es	Preparando mapas...	f	f	f
2612	RatingsReport	\N	f	2014-10-23 02:19:19.661111	2014-10-23 02:38:56.253937	es	Reporte de Comentarios	f	f	f
2580	remove_sidewalk_obstructions	\N	f	2014-10-17 17:59:55.804448	2014-10-23 02:39:59.497642	es	Elimine las obstrucciones de la acera	f	f	f
2581	trip_summaries	\N	f	2014-10-17 17:59:59.171849	2014-10-23 02:42:24.377626	es	Resúmenes de Viajes	f	f	f
2601	trip_time_filter	\N	f	2014-10-23 02:16:44.746822	2014-10-23 02:43:07.364313	es	Tiempo	f	f	f
2585	unknown_cost	\N	f	2014-10-17 18:00:01.422114	2014-10-23 02:43:44.451425	es	costo desconocido	f	f	f
2602	walk_distance_filter	\N	f	2014-10-23 02:16:44.758159	2014-10-23 02:44:37.526022	es	Distancia Caminando	f	f	f
\.


--
-- PostgreSQL database dump complete
--

