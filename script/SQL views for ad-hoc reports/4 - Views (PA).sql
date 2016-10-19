/* Stage 6: Combined Reporting Tables */
DROP MATERIALIZED VIEW IF EXISTS "v_Itineraries_Users";
DROP MATERIALIZED VIEW IF EXISTS "v_Trips_Users";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Parts_Users";


/* Stage 5: */
DROP MATERIALIZED VIEW IF EXISTS "v_Agencies";
DROP MATERIALIZED VIEW IF EXISTS "v_Itineraries";
DROP MATERIALIZED VIEW IF EXISTS "v_Providers";
DROP MATERIALIZED VIEW IF EXISTS "v_Services";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Parts";
DROP MATERIALIZED VIEW IF EXISTS "v_Trips";
DROP MATERIALIZED VIEW IF EXISTS "v_Trips_Desired_Modes";
DROP MATERIALIZED VIEW IF EXISTS "v_Users";
DROP MATERIALIZED VIEW IF EXISTS "v_User_Last_Trip";


/* Stage 4: Deployment Specific*/
DROP MATERIALIZED VIEW IF EXISTS "v_Service_Accommodations";
DROP MATERIALIZED VIEW IF EXISTS "v_Service_Characteristics";
DROP MATERIALIZED VIEW IF EXISTS "v_Service_Trip_Purposes";
DROP MATERIALIZED VIEW IF EXISTS "v_Users_Accommodations";
DROP MATERIALIZED VIEW IF EXISTS "v_Users_Characteristics";
DROP MATERIALIZED VIEW IF EXISTS "v_Users_Desired_Modes";


/* Stage 3: Generic */
DROP MATERIALIZED VIEW IF EXISTS "v_Service_Schedule_Start";
DROP MATERIALIZED VIEW IF EXISTS "v_Service_Schedule_End";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Parts_Itinerary_Mode_Count";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Places_From";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Places_To";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Places_MinSequence";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Places_MaxSequence";


/* Stage 2: Language Tables */
DROP MATERIALIZED VIEW IF EXISTS "v_Accommodations";
DROP MATERIALIZED VIEW IF EXISTS "v_Boolean";
DROP MATERIALIZED VIEW IF EXISTS "v_Characteristics";
DROP MATERIALIZED VIEW IF EXISTS "v_Modes";
DROP MATERIALIZED VIEW IF EXISTS "v_Service_Types";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Purposes";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Statuses";

/* Stage 1: Base Tables */
DROP MATERIALIZED VIEW IF EXISTS "v_Ratings_Trip";
DROP MATERIALIZED VIEW IF EXISTS "v_Translations";


/* Stage 1: Base Tables */

-- View: "v_Translations"

CREATE MATERIALIZED VIEW "v_Translations" AS 
  SELECT ct.key,
    ct._en,
    ct._es,
    ct._ht
  FROM crosstab('SELECT translation_keys.name AS key, locales.name AS locale, translations.value
                 FROM public.translation_keys, public.translations, public.locales
                 WHERE translation_keys.id = translations.translation_key_id AND locales.id = translations.locale_id 
                 Order by 1, 2'::text) ct(key character varying(255), _en text, _es text, _ht text)
WITH DATA;


-- View: "v_Ratings_Trip"

CREATE MATERIALIZED VIEW "v_Ratings_Trip" AS 
  SELECT ratings.id,
    ratings.user_id,
    ratings.rateable_id,
    ratings.rateable_type,
    ratings.value,
    ratings.comments,
    ratings.created_at,
    ratings.updated_at,
    ratings.status
  FROM ratings
  WHERE ratings.rateable_type::text = 'Trip'::text AND ratings.value >= 0
WITH DATA;


/* Stage 2: Language Tables */

-- View: "v_Accommodations"

CREATE MATERIALIZED VIEW "v_Accommodations" AS 
  SELECT accommodations.id,
    accommodations.name,
    accommodations.note,
    accommodations.datatype,
    accommodations.active,
    accommodations.code,
     "v_Translations"._en,
    "v_Translations"._es,
    "v_Translations"._ht
  FROM accommodations, "v_Translations"
  WHERE "v_Translations".key::text = accommodations.name::text
WITH DATA;


-- View: "v_Boolean"

CREATE MATERIALIZED VIEW "v_Boolean" AS 
  SELECT boolean_lookup.id,
    boolean_lookup.name,
    boolean_lookup.note,
     "v_Translations"._en,
    "v_Translations"._es,
    "v_Translations"._ht
  FROM boolean_lookup, "v_Translations"
  WHERE "v_Translations".key::text = boolean_lookup.name::text
WITH DATA;


-- View: "v_Characteristics"

CREATE MATERIALIZED VIEW "v_Characteristics" AS 
  SELECT characteristics.id,
    characteristics.name,
    characteristics.note,
    characteristics.datatype,
    characteristics.active,
    characteristics.code,
    characteristics.characteristic_type,
    characteristics."desc",
    characteristics.sequence,
    characteristics.for_service,
    characteristics.for_traveler,
    characteristics.linked_characteristic_id,
    characteristics.link_handler,
    "v_Translations"._en,
    "v_Translations"._es,
    "v_Translations"._ht
  FROM characteristics, "v_Translations"
  WHERE "v_Translations".key::text = characteristics.name::text
WITH DATA;


-- View: "v_Modes"

CREATE MATERIALIZED VIEW "v_Modes" AS 
  SELECT modes.id,
    modes.name,
    modes.active,
    modes.code,
    modes.elig_dependent,
    modes.parent_id,
    modes.otp_mode,
    modes.results_sort_order,
    modes.logo_url,
    modes.visible,
    "v_Translations"._en,
    "v_Translations"._es,
    "v_Translations"._ht
  FROM modes, "v_Translations"
  WHERE "v_Translations".key::text = modes.name::text AND modes.active = true
WITH DATA;


-- View: "v_Service_Types"

CREATE MATERIALIZED VIEW "v_Service_Types" AS 
  SELECT service_types.id,
    service_types.name,
    service_types.note,
    service_types.code,
    "v_Translations"._en,
    "v_Translations"._es,
    "v_Translations"._ht
  FROM service_types, "v_Translations"
  WHERE "v_Translations".key::text = service_types.name::text
WITH DATA;


-- View: "v_Trip_Purposes"

CREATE MATERIALIZED VIEW "v_Trip_Purposes" AS 
 SELECT trip_purposes.id,
    trip_purposes.name,
    trip_purposes.note,
    trip_purposes.active,
    trip_purposes.sort_order,
    trip_purposes.code,
    "v_Translations"._en,
    "v_Translations"._es,
    "v_Translations"._ht
   FROM "v_Translations",
    trip_purposes
  WHERE "v_Translations".key::text = trip_purposes.name::text
WITH DATA;


-- View: "v_Trip_Statuses"

CREATE MATERIALIZED VIEW "v_Trip_Statuses" AS 
  SELECT trip_statuses.id,
    trip_statuses.name,
    trip_statuses.active,
    trip_statuses.code,
    "v_Translations"._en,
    "v_Translations"._es,
    "v_Translations"._ht
  FROM trip_statuses,
    "v_Translations"
  WHERE "v_Translations".key::text = trip_statuses.name::text
WITH DATA;


/* Stage 3: Generic */

-- View: "v_Service_Schedule_Start"

CREATE MATERIALIZED VIEW "v_Service_Schedule_Start" AS 
  SELECT ct.service_id AS sss_service_id,
    ct._sunday_name,
    ct._monday_name,
    ct._tuesday_name,
    ct._wednesday_name,
    ct._thursday_name,
    ct._friday_name,
    ct._saturday_name
  FROM crosstab('SELECT schedules.service_id, day_of_week.name, TO_CHAR((schedules.start_seconds || ''second'')::interval, ''HH24:MI'')
                 FROM public.day_of_week, public.schedules
                 WHERE day_of_week.id = schedules.day_of_week ORDER BY 1, day_of_week.id;'::text,
                 $$VALUES ('sunday_name'::text), 
                          ('monday_name'::text),
                          ('tuesday_name'::text),
                          ('wednesday_name'::text), 
                          ('thursday_name'::text),
                          ('friday_name'::text),
                          ('saturday_name'::text) $$)
   ct(service_id integer, 
      _sunday_name text, 
      _monday_name text, 
      _tuesday_name text, 
      _wednesday_name text, 
      _thursday_name text,
      _friday_name text, 
      _saturday_name text)
WITH DATA;


-- View: "v_Service_Schedule_End"

CREATE MATERIALIZED VIEW "v_Service_Schedule_End" AS 
  SELECT ct.service_id AS sse_service_id,
    ct._sunday_name,
    ct._monday_name,
    ct._tuesday_name,
    ct._wednesday_name,
    ct._thursday_name,
    ct._friday_name,
    ct._saturday_name
  FROM crosstab('SELECT schedules.service_id, day_of_week.name, TO_CHAR((schedules.end_seconds || ''second'')::interval, ''HH24:MI'')
                 FROM public.day_of_week, public.schedules
                 WHERE day_of_week.id = schedules.day_of_week ORDER BY 1, day_of_week.id;'::text,
                 $$VALUES ('sunday_name'::text), 
                          ('monday_name'::text),
                          ('tuesday_name'::text),
                          ('wednesday_name'::text), 
                          ('thursday_name'::text),
                          ('friday_name'::text),
                          ('saturday_name'::text) $$)
  ct(service_id integer, 
     _sunday_name text, 
     _monday_name text, 
     _tuesday_name text, 
     _wednesday_name text, 
     _thursday_name text, 
     _friday_name text, 
     _saturday_name text)
WITH DATA;


-- View: "v_Trip_Places_MinSequence"

CREATE MATERIALIZED VIEW "v_Trip_Places_MinSequence" AS 
  SELECT trip_places.trip_id, min(trip_places.sequence) AS min_sequence
  FROM trip_places
  WHERE trip_places.trip_id > 0
  GROUP BY trip_places.trip_id
WITH DATA;


-- View: "v_Trip_Places_MaxSequence"

CREATE MATERIALIZED VIEW "v_Trip_Places_MaxSequence" AS 
  SELECT trip_places.trip_id, max(trip_places.sequence) AS max_sequence
  FROM trip_places
  WHERE trip_places.trip_id > 0
  GROUP BY trip_places.trip_id
WITH DATA;


-- View: "v_Trip_Places_From"

CREATE MATERIALIZED VIEW "v_Trip_Places_From" AS 
  SELECT trip_places.trip_id,
    trip_places.raw_address AS from_raw_address,
    trip_places.lat AS from_lat,
    trip_places.lon AS from_lon,
    trip_places.address1 AS from_address1,
    trip_places.address2 AS from_address2,
    trip_places.city AS from_city,
    trip_places.state AS rrom_state,
    trip_places.zip AS rrom_zip
  FROM trip_places, "v_Trip_Places_MinSequence"
  WHERE trip_places.trip_id = "v_Trip_Places_MinSequence".trip_id AND trip_places.sequence = "v_Trip_Places_MinSequence".min_sequence
WITH DATA;


-- View: "v_Trip_Places_To"

CREATE MATERIALIZED VIEW "v_Trip_Places_To" AS 
  SELECT trip_places.trip_id,
    trip_places.raw_address AS to_raw_address,
    trip_places.lat AS to_lat,
    trip_places.lon AS to_lon,
    trip_places.address1 AS to_address1,
    trip_places.address2 AS to_address2,
    trip_places.city AS to_city,
    trip_places.state AS to_state,
    trip_places.zip AS to_zip
  FROM trip_places, "v_Trip_Places_MaxSequence"
  WHERE trip_places.trip_id = "v_Trip_Places_MaxSequence".trip_id AND trip_places.sequence = "v_Trip_Places_MaxSequence".max_sequence
WITH DATA;



/* Stage 4: Deployment Specific*/

/* ------------------------------------------------------------------------------------------------------------------------------------------ */
/* UTA                                                                                                                                        */
/* ------------------------------------------------------------------------------------------------------------------------------------------ */

-- View: "v_Service_Accommodations"

CREATE MATERIALIZED VIEW "v_Service_Accommodations" AS 
  SELECT ct.service_id AS sa_service_id,
    ct._curb_to_curb_name AS service_curb_to_curb_name,
    ct._folding_wheelchair_accessible_name AS service_folding_wheelchair_accessible_name,
    ct._motorized_wheelchair_accessible_name AS service_motorized_wheelchair_accessible_name
  FROM crosstab ('SELECT service_accommodations.service_id, accommodations.name, true As value FROM public.service_accommodations, public.accommodations WHERE accommodations.id = service_accommodations.accommodation_id ORDER BY 1,2'::text, 
                 $$VALUES ('curb_to_curb_name'),
                          ('folding_wheelchair_accessible_name'),
                          ('motorized_wheelchair_accessible_name') $$) 
  ct (service_id integer,
      _curb_to_curb_name boolean,
      _folding_wheelchair_accessible_name boolean,
      _motorized_wheelchair_accessible_name boolean)
WITH DATA;


-- View: "v_Service_Characteristics"

CREATE MATERIALIZED VIEW "v_Service_Characteristics" AS 
  SELECT 
    ct.service_id AS sc_service_id,
    ct._ada_eligible_name AS service_ada_eligible_name,
    ct._age_name AS service_age_name,
    ct._date_of_birth_name AS service_date_of_birth_name,
    ct._disabled_name AS service_disabled_name,
    ct._matp_name AS service_matp_name,
    ct._veteran_name AS service_veteran_name,
    ct._walk_distance_name AS service_walk_distance_name
  FROM crosstab ('SELECT service_characteristics.service_id, characteristics.name, service_characteristics.value FROM public.service_characteristics, public.characteristics WHERE characteristics.id = service_characteristics.characteristic_id ORDER BY 1,2'::text, 
                 $$VALUES ('ada_eligible_name'),
                          ('age_name'),
                          ('date_of_birth_name'),
                          ('disabled_name'),
                          ('matp_name'),
                          ('veteran_name'),
                          ('walk_distance_name') $$) 
  ct (service_id integer,
      _ada_eligible_name text,
      _age_name text,
      _date_of_birth_name text,
      _disabled_name text,
      _matp_name text,
      _veteran_name text,
      _walk_distance_name text)
WITH DATA;


-- View: "v_Service_Trip_Purposes"

CREATE MATERIALIZED VIEW "v_Service_Trip_Purposes" AS 
  SELECT ct.service_id AS stp_service_id,
    ct._adult_day_care_name AS service_adult_day_care_name,
    ct._after_school_program_name AS service_after_school_program_name,
    ct._cancer_treatment_name AS service_cancer_treatment_name,
    ct._dialysis_name AS service_dialysis_name,
    ct._education_name AS service_education_name,
    ct._general_purpose_name AS service_general_purpose_name,
    ct._grocery_name AS service_grocery_name,
    ct._medical_name AS service_medical_name,
    ct._methadone_name AS service_methadone_name,
    ct._other_name AS service_other_name,
    ct._personal_errand_name AS service_personal_errand_name,
    ct._pharmacy_name AS service_pharmacy_name,
    ct._recreation_name AS service_recreation_name,
    ct._senior_center_group_trip AS service_senior_center_group_trip,
    ct._senior_center_name AS service_senior_center_name,
    ct._shopping_name AS service_shopping_name,
    ct._social_service_name AS service_social_service_name,
    ct._training_employment_name AS service_training_employment_name,
    ct._visit_lebanon_va_medical_center_name AS service_visit_lebanon_va_medical_center_name,
    ct._volunteer_name AS service_volunteer_name,
    ct._work_name AS service_work_name
  FROM crosstab ('SELECT service_trip_purpose_maps.service_id, trip_purposes.name, true as value FROM public.service_trip_purpose_maps, public.trip_purposes WHERE trip_purposes.id = service_trip_purpose_maps.trip_purpose_id ORDER BY 1,2'::text, 
                 $$VALUES ('adult_day_care_name'),
                 ('after_school_program_name'),
                 ('cancer_treatment_name'),
                 ('dialysis_name'),
                 ('education_name'),
                 ('general_purpose_name'),
                 ('grocery_name'),
                 ('medical_name'),
                 ('methadone_name'),
                 ('other_name'),
                 ('personal_errand_name'),
                 ('pharmacy_name'),
                 ('recreation_name'),
                 ('senior_center_group_trip'),
                 ('senior_center_name'),
                 ('shopping_name'),
                 ('social_service_name'),
                 ('training_employment_name'),
                 ('visit_lebanon_va_medical_center_name'),
                 ('volunteer_name'),('work_name') $$) 
  ct (service_id integer,
      _adult_day_care_name boolean,
      _after_school_program_name boolean,
      _cancer_treatment_name boolean,
      _dialysis_name boolean,
      _education_name boolean,
      _general_purpose_name boolean,
      _grocery_name boolean,
      _medical_name boolean,
      _methadone_name boolean,
      _other_name boolean,
      _personal_errand_name boolean,
      _pharmacy_name boolean,
      _recreation_name boolean,
      _senior_center_group_trip boolean,
      _senior_center_name boolean,
      _shopping_name boolean,
      _social_service_name boolean,
      _training_employment_name boolean,
      _visit_lebanon_va_medical_center_name boolean,
      _volunteer_name boolean,
      _work_name boolean )
WITH DATA;


-- View: "v_Trip_Parts_Itinerary_Mode_Count"

CREATE MATERIALIZED VIEW "v_Trip_Parts_Itinerary_Mode_Count" AS 
  SELECT ct.trip_part_id AS tpitm_trip_part_id,
    ct._trip_part_mode_paratransit_count AS trip_mode_paratransit_count,
    ct._trip_part_mode_transit_count AS trip_mode_transit_count,
    ct._trip_part_mode_walk_count AS trip_mode_walk_count
  FROM crosstab ('SELECT trip_part_id, returned_mode_code, count(*) As mode_count from itineraries group by trip_part_id, returned_mode_code ORDER BY 1,2',
                 $$VALUES ('mode_paratransit'::text),
                          ('mode_transit'::text),
                          ('mode_walk'::text) $$) 
  ct (trip_part_id integer,
      _trip_part_mode_paratransit_count int,
      _trip_part_mode_transit_count int,
      _trip_part_mode_walk_count int );


-- View: "v_Trips_Desired_Modes"

CREATE MATERIALIZED VIEW "v_Trips_Desired_Modes" AS 
  SELECT trip_id AS tdm_trip_id,
    not _mode_paratransit_name is null as trip_desired_mode_paratransit_name,
    not _mode_transit_name is null as trip_desired_mode_transit_name
  FROM crosstab ('SELECT trips_desired_modes.trip_id, "v_Modes".name As "Name", "v_Modes"._en As "Desired_Mode" FROM public."v_Modes", public.trips_desired_modes WHERE "v_Modes".id = trips_desired_modes.desired_mode_id ORDER BY 1,2'::text, 
                 $$VALUES ('mode_paratransit'),
                          ('mode_transit_name') $$)
  ct (trip_id integer,
      _mode_paratransit_name text,
      _mode_transit_name text )
WITH DATA;



-- View: "v_Users_Accommodations"

CREATE MATERIALIZED VIEW "v_Users_Accommodations" AS 
  SELECT ct.user_profile_id AS ua_user_id,
    ct._curb_to_curb_name AS user_curb_to_curb_name,
    ct._folding_wheelchair_accessible_name AS user_folding_wheelchair_accessible_name,
    ct._motorized_wheelchair_accessible_name AS user_motorized_wheelchair_accessible_name
  FROM crosstab ('SELECT user_accommodations.user_profile_id, accommodations.name, user_accommodations.value FROM public.accommodations, public.user_accommodations WHERE accommodations.id = user_accommodations.accommodation_id ORDER BY 1,2'::text, 
                 $$VALUES ('curb_to_curb_name'),
                 ('folding_wheelchair_accessible_name'),
                 ('motorized_wheelchair_accessible_name') $$) 
  ct (user_profile_id integer,
      _curb_to_curb_name text,
      _folding_wheelchair_accessible_name text,
      _motorized_wheelchair_accessible_name text )
WITH DATA;


-- View: "v_Users_Characteristics"

CREATE MATERIALIZED VIEW "v_Users_Characteristics" AS 
  SELECT ct.user_profile_id AS uc_user_id,
    ct._ada_eligible_name AS user_ada_eligible_name,
    ct._age_name AS user_age_name,
    ct._date_of_birth_name AS user_date_of_birth_name,
    ct._disabled_name AS user_disabled_name,
    ct._matp_name AS user_matp_name,
    ct._veteran_name AS user_veteran_name,
    ct._walk_distance_name AS user_walk_distance_name
  FROM crosstab ('SELECT user_characteristics.user_profile_id, characteristics.name, user_characteristics.value FROM public.characteristics, public.user_characteristics WHERE characteristics.id = user_characteristics.characteristic_id ORDER BY 1,2'::text, 
                 $$VALUES ('ada_eligible_name'),
                          ('age_name'),
                          ('date_of_birth_name'),
                          ('disabled_name'),
                          ('matp_name'),
                          ('veteran_name'),
                          ('walk_distance_name') $$) 
  ct (user_profile_id integer,
      _ada_eligible_name text,
      _age_name text,
      _date_of_birth_name text,
      _disabled_name text,
      _matp_name text,
      _veteran_name text,
      _walk_distance_name text )
WITH DATA;


-- View: "v_Users_Desired_Modes"

CREATE MATERIALIZED VIEW "v_Users_Desired_Modes" AS 
  SELECT ct.user_id AS udm_user_id,
    ct._mode_paratransit_name AS user_desired_mode_paratransit_name,
    ct._mode_transit_name AS user_desired_mode_transit_name
  FROM crosstab('SELECT user_mode_preferences.user_id, modes.name, (user_mode_preferences.mode_id > 0) As "Mode_Desired"
		 FROM public.modes, public.user_mode_preferences
		 WHERE modes.id = user_mode_preferences.mode_id Order By 1, 2'::text,
		 $$VALUES ('mode_paratransit_name'),
			  ('mode_transit_name') $$)
  ct(user_id integer,
     _mode_paratransit_name boolean, 
     _mode_transit_name boolean)
WITH DATA;



/* Stage 5: Base Reporting Tables */

-- View: "v_Agencies"

CREATE MATERIALIZED VIEW "v_Agencies" AS 
  SELECT 
    agencies.id AS agency_id,
    agencies.name AS agency_name,
    agencies.address AS agency_address,
    agencies.city AS agency_city,
    agencies.state AS agency_state,
    agencies.zip AS agency_zip,
    agencies.url AS agency_url,
    agencies.phone AS agency_phone,
    agencies.email AS agency_email,
    agencies.internal_contact_name AS agency_internal_contact_name,
    agencies.internal_contact_title AS agency_internal_contact_title,
    agencies.internal_contact_phone AS agency_internal_contact_phone,
    agencies.internal_contact_email AS agency_internal_contact_email
  FROM agencies
WITH DATA;

    
-- View: "v_Itineraries"

CREATE MATERIALIZED VIEW "v_Itineraries" AS 
  SELECT 
    itineraries.id AS itinerary_id,
    itineraries.trip_part_id AS itinerary_trip_part_id,
    itineraries.service_id AS itinerary_service_id,
    "v_Modes"._en AS itinerary_mode,
    itineraries.start_time AS itinerary_start_time,
    itineraries.end_time AS itinerary_end_time,
    itineraries.duration AS itinerary_duration,
    itineraries.walk_time AS itinerary_walk_time,
    itineraries.transit_time AS itinerary_transit_time,
    itineraries.wait_time AS itinerary_wait_time,
    itineraries.walk_distance AS itinerary_walk_distance,
    itineraries.transfers AS itinerary_transfers,
    itineraries.count AS itinerary_leg_count,
    itineraries.cost AS itinerary_cost,
    itineraries.selected AS itinerary_selected,
    (itineraries.booking_confirmation IS NOT NULL) AS itinerary_booked,
    itineraries.booking_confirmation AS itinerary_booking_confirmation
  FROM itineraries
    LEFT JOIN "v_Modes" ON "v_Modes".code = itineraries.returned_mode_code
  ORDER BY itineraries.id
WITH DATA;


-- View: "v_Providers"

CREATE MATERIALIZED VIEW "v_Providers" AS 
  SELECT 
    providers.id AS provider_id,
    providers.name AS provider_name,
    providers.active AS provider_is_active,
    providers.address AS provider_address,
    providers.city AS provider_city,
    providers.state AS provider_state,
    providers.zip AS provider_zip,
    providers.url AS provider_url,
    providers.phone AS provider_phone,
    providers.email AS provider_email,
    providers.internal_contact_name AS provider_internal_contact_name,
    providers.internal_contact_title AS provider_internal_contact_title,
    providers.internal_contact_phone AS provider_internal_contact_phone,
    providers.internal_contact_email AS provider_internal_contact_email
  FROM providers
WITH DATA;

    
-- View: "v_Services"

CREATE MATERIALIZED VIEW "v_Services" AS 
  SELECT 
    services.id AS service_id,
    services.name AS service_name,
    services.provider_id AS service_provider_id,
    providers.name AS service_provider_name,
    services.service_type_id AS service_type_id,
    "v_Service_Types"._en AS service_type,
    services.active as service_active,
    services.advanced_notice_minutes AS service_advanced_notice_minutes,
    services.max_advanced_book_minutes AS service_max_advanced_book_minutes,
    "v_Service_Trip_Purposes".*,
    "v_Service_Accommodations".*,
    "v_Service_Characteristics".*,
    "v_Service_Schedule_Start"._sunday_name AS service_start_sunday,
    "v_Service_Schedule_End"._sunday_name AS service_end_sunday,
    "v_Service_Schedule_Start"._monday_name AS service_start_monday,
    "v_Service_Schedule_End"._monday_name AS service_end_monday,
    "v_Service_Schedule_Start"._tuesday_name AS service_start_tuesday,
    "v_Service_Schedule_End"._tuesday_name AS service_end_tuesday,
    "v_Service_Schedule_Start"._wednesday_name AS service_start_wednesday,
    "v_Service_Schedule_End"._wednesday_name AS service_end_wednesday,
    "v_Service_Schedule_Start"._thursday_name AS service_start_thursday,
    "v_Service_Schedule_End"._thursday_name AS service_end_thursday,
    "v_Service_Schedule_Start"._friday_name AS service_start_friday,
    "v_Service_Schedule_End"._friday_name AS service_end_friday,
    "v_Service_Schedule_Start"._saturday_name AS service_start_saturday,
    "v_Service_Schedule_End"._saturday_name AS service_end_saturday
  FROM services
    LEFT JOIN "v_Service_Accommodations" ON "v_Service_Accommodations".sa_service_id = services.id
    LEFT JOIN "v_Service_Characteristics" ON "v_Service_Characteristics".sc_service_id = services.id
    LEFT JOIN "v_Service_Schedule_End" ON "v_Service_Schedule_End".sse_service_id = services.id
    LEFT JOIN "v_Service_Schedule_Start" ON "v_Service_Schedule_Start".sss_service_id = services.id
    LEFT JOIN "v_Service_Trip_Purposes" ON "v_Service_Trip_Purposes".stp_service_id = services.id
    JOIN providers ON services.provider_id = providers.id
    JOIN "v_Service_Types" ON "v_Service_Types".id = services.service_type_id
WITH DATA;

    
-- View: "v_Trips"

CREATE MATERIALIZED VIEW "v_Trips" AS 
  SELECT trips.id AS trip_id,
    trips.user_id as trip_user_id,
    date_trunc('second', trips.updated_at) As trip_creation_datetime,
    date_trunc('day', trips.scheduled_date) As trip_requested_date,
    to_char(trips.scheduled_time, 'HH24:MI') As trip_requested_time,
    "From_Trip_Places".raw_address AS trip_from_address,
    "From_Trip_Places".lat AS trip_from_lat,
    "From_Trip_Places".lon AS trip_from_lon,
    "To_Trip_Places".raw_address AS trip_to_address,
    "To_Trip_Places".lat AS trip_to_lat,
    "To_Trip_Places".lon AS trip_to_lon,
    trips.trip_purpose_id AS trip_purpose_id,
    "v_Trip_Purposes"._en AS trip_purpose,
    "v_Trips_Desired_Modes".*,
    trips.is_planned AS trip_is_planned,
    trips.taken AS trip_is_taken,
    "v_Ratings_Trip".value AS trip_rating,
    CASE WHEN trips.user_id <> trips.creator_id THEN trips.creator_id
         ELSE NULL
    END AS buddy_id,
    CASE WHEN trips.user_id <> trips.creator_id THEN (users.first_name || ' ' || users.last_name)
         ELSE NULL
    END AS buddy,
    trips.agency_id As agency_id,
    agencies.name AS agency_name,
    CASE WHEN trips.agency_id IS NOT NULL THEN trips.creator_id
         ELSE NULL
    END AS agency_agent_id,
    CASE WHEN trips.agency_id IS NOT NULL THEN (users.first_name || ' ' || users.last_name)
         ELSE NULL
    END AS agency_agent,
    trips.ui_mode AS trip_ui_mode
  FROM trips
    LEFT JOIN "v_Trip_Purposes" ON "v_Trip_Purposes".id = trips.trip_purpose_id
    JOIN trip_parts ON trip_parts.trip_id = trips.id
    JOIN trip_places "From_Trip_Places" ON "From_Trip_Places".id = trip_parts.from_trip_place_id
    JOIN trip_places "To_Trip_Places" ON "To_Trip_Places".id = trip_parts.to_trip_place_id
    LEFT JOIN "v_Trips_Desired_Modes" ON "v_Trips_Desired_Modes".tdm_trip_id = trips.id
    LEFT JOIN "v_Ratings_Trip" ON trips.id = "v_Ratings_Trip".rateable_id
    LEFT JOIN agencies ON trips.agency_id = agencies.id
    LEFT JOIN users ON trips.creator_id = users.id
  WHERE trip_parts.sequence = 0
WITH DATA;


-- View: "v_Trip_Parts"

CREATE MATERIALIZED VIEW "v_Trip_Parts" AS 
 SELECT
    trip_parts.id as trip_part_id,
    trip_parts.trip_id AS trip_id,
    trips.user_id as trip_user_id,
    date_trunc('second', trip_parts.updated_at) As trip_creation_datetime,
    trip_parts.is_depart AS trip_depart_by,
    date_trunc('day', trip_parts.scheduled_date) As trip_requested_date,
    to_char(trip_parts.scheduled_time, 'HH24:MI') As trip_requested_time,
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_From".from_raw_address
            ELSE "v_Trip_Places_To".to_raw_address
        END AS trip_from_address,
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_From".from_lat
            ELSE "v_Trip_Places_To".to_lat
        END AS trip_from_lat,
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_From".from_lon
            ELSE "v_Trip_Places_To".to_lon
        END AS trip_from_lon,
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_To".to_raw_address
            ELSE "v_Trip_Places_From".from_raw_address
        END AS trip_to_address,
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_To".to_lat
            ELSE "v_Trip_Places_From".from_lat
        END AS trip_to_lat,
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_To".to_lon
            ELSE "v_Trip_Places_From".from_lon
        END AS trip_to_lon,
    trips.trip_purpose_id AS trip_purpose_id,
    "v_Trip_Purposes"._en AS trip_purpose,
    "v_Trips_Desired_Modes".*,
    "v_Trip_Parts_Itinerary_Mode_Count".*,
    trip_parts.is_return_trip AS trip_is_return_trip,
    trips.is_planned AS trip_is_planned,
    trips.taken AS trip_is_taken,
    "v_Ratings_Trip".value AS trip_rating,
    CASE WHEN trips.user_id <> trips.creator_id THEN trips.creator_id
         ELSE NULL
    END AS buddy_id,
    CASE WHEN trips.user_id <> trips.creator_id THEN (users.first_name || ' ' || users.last_name)
         ELSE NULL
    END AS buddy,
    trips.agency_id As agency_id,
    agencies.name AS agency_name,
    CASE WHEN trips.agency_id IS NOT NULL THEN trips.creator_id
         ELSE NULL
    END AS agency_agent_id,
    CASE WHEN trips.agency_id IS NOT NULL THEN (users.first_name || ' ' || users.last_name)
         ELSE NULL
    END AS agency_agent,
    trips.ui_mode AS trip_ui_mode
  FROM trip_parts
    JOIN trips ON trips.id = trip_parts.trip_id
    JOIN "v_Trip_Places_From" ON "v_Trip_Places_From".trip_id = trip_parts.trip_id
    JOIN "v_Trip_Places_To" ON "v_Trip_Places_To".trip_id = trip_parts.trip_id
    LEFT JOIN "v_Trip_Purposes" ON "v_Trip_Purposes".id = trips.trip_purpose_id
    LEFT JOIN "v_Trips_Desired_Modes" ON "v_Trips_Desired_Modes".tdm_trip_id = trips.id
    LEFT JOIN "v_Trip_Parts_Itinerary_Mode_Count" ON "v_Trip_Parts_Itinerary_Mode_Count".tpitm_trip_part_id = trip_parts.id
    LEFT JOIN "v_Ratings_Trip" ON trips.id = "v_Ratings_Trip".rateable_id
    LEFT JOIN agencies ON trips.agency_id = agencies.id
    LEFT JOIN users ON trips.creator_id = users.id
WITH DATA;


-- View: "v_User_Last_Trip"

CREATE MATERIALIZED VIEW "v_User_Last_Trip" AS 
  SELECT trips.user_id as user_id,
    MAX(date_trunc('second', trips.updated_at)) AS last_trip_datetime
  FROM trips
  GROUP BY trips.user_id
WITH DATA;


-- View: "v_Users"

CREATE MATERIALIZED VIEW "v_Users" AS 
  SELECT users.id AS user_id,
    users.title,
    users.prefix,
    users.first_name,
    users.last_name,
    users.suffix,
    users.nickname,
    users.phone,
    users.email,
    users.sign_in_count,
    users.last_sign_in_at,
    "v_User_Last_Trip".last_trip_datetime,    
    users.preferred_locale,
    walking_speeds.value AS walking_speed_mph,
    walking_maximum_distances.value AS walking_maximum_distance_miles,
    users.maximum_wait_time,
    "v_Users_Accommodations".*,
    "v_Users_Characteristics".*
  FROM users
    LEFT JOIN "v_Users_Accommodations" ON "v_Users_Accommodations".ua_user_id = users.id
    LEFT JOIN "v_Users_Characteristics" ON "v_Users_Characteristics".uc_user_id = users.id
    LEFT JOIN walking_speeds ON walking_speeds.id = users.walking_speed_id
    LEFT JOIN walking_maximum_distances ON walking_maximum_distances.id = users.walking_maximum_distance_id
    LEFT JOIN "v_User_Last_Trip" ON "v_User_Last_Trip".user_id = users.id
  WHERE users.id in (SELECT user_id FROM trips) OR users.sign_in_count > 0
WITH DATA;


/* Stage 6: Combined Reporting Tables 

-- View: "v_Trip_Details"

CREATE MATERIALIZED VIEW "v_Trips_Details" AS 
  SELECT 
    "v_Trips".trip_id,
    "v_Trips".trip_creation_datetime,
    "v_Users".first_name,
    "v_Users".last_name,
    "v_Trips".trip_from_address,
    "v_Trips".trip_to_address,
    "v_Trips".trip_purpose,
    "v_Trips_Desired_Modes".trip_desired_modes
  FROM "v_Trips"
    JOIN "v_Users" ON "v_Users".user_id = "v_Trips".trip_user_id
    JOIN "v_Trips_Desired_Modes" ON "v_Trips_Desired_Modes".tdm_trip_id = "v_Trips".trip_id
WITH DATA;
*/

-- View: "v_Trips_Users"

CREATE MATERIALIZED VIEW "v_Trips_Users" AS 
  SELECT "v_Trips".*,
    "v_Users".*
  FROM "v_Trips"
    JOIN "v_Users" ON "v_Users".user_id = "v_Trips".trip_user_id
WITH DATA;


-- View: "v_Trip_Parts_Users"

CREATE MATERIALIZED VIEW "v_Trip_Parts_Users" AS
  SELECT "v_Trip_Parts".*,
    "v_Users".*
  FROM "v_Trip_Parts"
    JOIN "v_Users" ON "v_Users".user_id = "v_Trip_Parts".trip_user_id
WITH DATA;


-- View: "v_Itineraries_Users"

CREATE MATERIALIZED VIEW "v_Itineraries_Users" AS
SELECT 
  "v_Trip_Parts".*,
  "v_Itineraries".*,
  "v_Services".*,
  "v_Users".*
FROM 
  public."v_Itineraries" 
  JOIN "v_Trip_Parts" ON "v_Trip_Parts".trip_part_id = "v_Itineraries".itinerary_trip_part_id
  JOIN "v_Users" ON "v_Users".user_id = "v_Trip_Parts".trip_user_id
  LEFT JOIN public."v_Services" ON "v_Services".service_id = "v_Itineraries".itinerary_service_id
WITH DATA;


-- Refresh Materialized Views
Select RefreshAllMaterializedViews();


/* 
-- Update Reporting tables

DELETE FROM reporting_filter_fields WHERE reporting_filter_group_id in (2, 8, 9, 10);


-- Traveler Accommodations Group

INSERT INTO reporting_filter_fields (id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
SELECT
  ID+1000 As "id",
  8 As "reporting_filter_group_id",
  CASE
    WHEN datatype = 'date' THEN 29
    WHEN datatype = 'bool' THEN 30
    WHEN datatype = 'integer' THEN 29
    WHEN datatype = 'double' THEN 29
    ELSE 11
  END As "reporting_filter_type_id",
  CASE
    WHEN datatype = 'bool' THEN 9
  END AS "report_lookup_table_id",
  'user_' || name As "name",
  _en As "title",
  now() as "created_at",
  now() as "updated_at",
  row_number() OVER () as "sort_order",
  '' as "value_type"
from "v_Accommodations"
where "v_Accommodations".active = true;


-- Traveler Eligibility

INSERT INTO reporting_filter_fields (id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
SELECT
  ID+2000 As "id",
  2 As "reporting_filter_group_id",
  CASE
    WHEN datatype = 'date' THEN 29
    WHEN datatype = 'bool' THEN 30
    WHEN datatype = 'integer' THEN 29
    WHEN datatype = 'double' THEN 29
    ELSE 11
  END As "reporting_filter_type_id",
  CASE
    WHEN datatype = 'bool' THEN 9
  END AS "report_lookup_table_id",
  'user_' || name As "name",
  _en As "title",
  now() as "created_at",
  now() as "updated_at",
  row_number() OVER () AS "sort_order",
  '' as "value_type"
from "v_Characteristics"
where "v_Characteristics".for_traveler = TRUE AND "v_Characteristics".active = true;


-- Trip Desired Modes Group

INSERT INTO reporting_filter_fields (id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
SELECT
  ID+3000 AS "id",
  9 AS "reporting_filter_group_id",
  30 AS "reporting_filter_type_id",
  9 AS "report_lookup_table_id",
  'trip_desired_' || name As "name",
  _en As "title",
  now() as "created_at",
  now() as "updated_at",
  row_number() OVER () AS "sort_order",
  '' as "value_type"
from "v_Modes"
where "v_Modes".visible = TRUE AND "v_Modes".visible = TRUE;


-- User Desired Modes Group

INSERT INTO reporting_filter_fields (id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
SELECT
  ID+4000 AS "id",
  10 AS "reporting_filter_group_id",
  30 AS "reporting_filter_type_id",
  9 AS "report_lookup_table_id",
  'user_desired_' || name As "name",
  _en As "title",
  now() as "created_at",
  now() as "updated_at",
  row_number() OVER () AS "sort_order",
  '' as "value_type"
from "v_Modes"
where "v_Modes".visible = TRUE AND "v_Modes".visible = TRUE; */