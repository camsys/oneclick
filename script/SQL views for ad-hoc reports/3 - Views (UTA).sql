/* Stage 6: Combined Reporting Tables */
DROP MATERIALIZED VIEW IF EXISTS "v_Itineraries_Users";
DROP MATERIALIZED VIEW IF EXISTS "v_Trips_Users";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Parts_Users";

/* Stage 5: */
DROP MATERIALIZED VIEW IF EXISTS "v_Itineraries";
DROP MATERIALIZED VIEW IF EXISTS "v_Services";
DROP MATERIALIZED VIEW IF EXISTS "v_Trips";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Parts";
DROP MATERIALIZED VIEW IF EXISTS "v_Users";

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
DROP MATERIALIZED VIEW IF EXISTS "v_Translations_Locale";
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
  SELECT ct.service_id AS "SSS_ID",
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
  SELECT ct.service_id AS "SSE_ID",
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
    trip_places.raw_address AS "From_Raw_Address",
    trip_places.lat AS "From_Lat",
    trip_places.lon AS "From_Lon",
    trip_places.address1 AS "From_Address1",
    trip_places.address2 AS "From_Address2",
    trip_places.city AS "From_City",
    trip_places.state AS "From_State",
    trip_places.zip AS "From_Zip"
  FROM trip_places, "v_Trip_Places_MinSequence"
  WHERE trip_places.trip_id = "v_Trip_Places_MinSequence".trip_id AND trip_places.sequence = "v_Trip_Places_MinSequence".min_sequence
WITH DATA;


-- View: "v_Trip_Places_To"

CREATE MATERIALIZED VIEW "v_Trip_Places_To" AS 
  SELECT trip_places.trip_id,
    trip_places.raw_address AS "To_Raw_Address",
    trip_places.lat AS "To_Lat",
    trip_places.lon AS "To_Lon",
    trip_places.address1 AS "To_Address1",
    trip_places.address2 AS "To_Address2",
    trip_places.city AS "To_City",
    trip_places.state AS "To_State",
    trip_places.zip AS "To_Zip"
  FROM trip_places, "v_Trip_Places_MaxSequence"
  WHERE trip_places.trip_id = "v_Trip_Places_MaxSequence".trip_id AND trip_places.sequence = "v_Trip_Places_MaxSequence".max_sequence
WITH DATA;


/* Stage 4: Deployment Specific*/

/* ------------------------------------------------------------------------------------------------------------------------------------------ */
/* UTA                                                                                                                                        */
/* ------------------------------------------------------------------------------------------------------------------------------------------ */

-- View: "v_Service_Accommodations"

CREATE MATERIALIZED VIEW "v_Service_Accommodations" AS 
  SELECT ct.service_id AS "SA_ID",
    ct._curb_to_curb_name AS "service_curb_to_curb_name",
    ct._door_through_door_name AS "service_door_through_door_name",
    ct._door_to_door_name AS "service_door_to_door_name",
    ct._driver_assistance_name AS "service_driver_assistance_name",
    ct._folding_wheelchair_accessible_name AS "service_folding_wheelchair_accessible_name",
    ct._motorized_wheelchair_accessible_name AS "service_motorized_wheelchair_accessible_name",
    ct._wheelchair_lift_equipped_name AS "service_wheelchair_lift_equipped_name"
  FROM crosstab ( 'SELECT service_accommodations.service_id, accommodations.name, true As value FROM public.service_accommodations, public.accommodations WHERE accommodations.id = service_accommodations.accommodation_id ORDER BY 1,2'::text, $$VALUES ('curb_to_curb_name'),('door_through_door_name'),('door_to_door_name'),('driver_assistance_name'),('folding_wheelchair_accessible_name'),('motorized_wheelchair_accessible_name'),('wheelchair_lift_equipped_name') $$) 
ct (service_id integer,
    _curb_to_curb_name boolean,
    _door_through_door_name boolean,
    _door_to_door_name boolean,
    _driver_assistance_name boolean,
    _folding_wheelchair_accessible_name boolean,
    _motorized_wheelchair_accessible_name boolean,
    _wheelchair_lift_equipped_name boolean )
WITH DATA;


-- View: "v_Service_Characteristics"

CREATE MATERIALIZED VIEW "v_Service_Characteristics" AS 
SELECT 
    ct.service_id AS "SC_ID",
    ct._age_name,
    ct._date_of_birth_name,
    ct._developmentally_disabled_name,
    ct._disabled_non_elderly_name,
    ct._nemt_eligible_name,
    ct._physically_disabled_name,
    ct._veteran_name,
    ct._wheelchair_dependent_name
   FROM crosstab ( 'SELECT service_characteristics.service_id, characteristics.name, service_characteristics.value FROM public.service_characteristics, public.characteristics WHERE characteristics.id = service_characteristics.characteristic_id ORDER BY 1,2'::text, 
                  $$VALUES ('age_name'),
                           ('date_of_birth_name'),
                           ('developmentally_disabled_name'),
                           ('disabled_non_elderly_name'),
                           ('nemt_eligible_name'),
                           ('physically_disabled_name'),
                           ('veteran_name'),
                           ('wheelchair_dependent_name') $$) 
   ct (service_id integer,
       _age_name text,
       _date_of_birth_name text,
       _developmentally_disabled_name text,
       _disabled_non_elderly_name text,
       _nemt_eligible_name text,
       _physically_disabled_name text,
       _veteran_name text,
       _wheelchair_dependent_name text )
WITH DATA;


-- View: "v_Service_Trip_Purposes"

CREATE MATERIALIZED VIEW "v_Service_Trip_Purposes" AS 
  SELECT ct.service_id AS "STP_ID",
    ct._cancer_treatment_name AS "service_cancer_treatment_name",
    ct._dental_purpose_name AS "service_dental_purpose_name",
    ct._dialysis_purpose_name AS "service_dialysis_purpose_name",
    ct._general_medical_name AS "service_general_medical_name",
    ct._general_purpose_name AS "service_general_purpose_name",
    ct._grocery_name AS "service_grocery_name",
    ct._hair_purpose_name AS "service_hair_purpose_name",
    ct._pharmacy_purpose_name AS "service_pharmacy_purpose_name",
    ct._senior_center_purpose_name AS "service_senior_center_purpose_name",
    ct._therapy_purpose_name AS "service_therapy_purpose_name",
    ct._visit_spouse_purpose_name AS "service_visit_spouse_purpose_name"
  FROM crosstab ('SELECT service_trip_purpose_maps.service_id, trip_purposes.name, true as value FROM public.service_trip_purpose_maps, public.trip_purposes WHERE trip_purposes.id = service_trip_purpose_maps.trip_purpose_id ORDER BY 1,2'::text, 
                 $$VALUES ('cancer_treatment_name'),
                          ('dental_purpose_name'),
                          ('dialysis_purpose_name'),
                          ('general_medical_name'),
                          ('general_purpose_name'),
                          ('grocery_name'),
                          ('hair_purpose_name'),
                          ('pharmacy_purpose_name'),
                          ('senior_center_purpose_name'),
                          ('therapy_purpose_name'),
                          ('visit_spouse_purpose_name') $$) 
  ct (service_id integer,
      _cancer_treatment_name boolean,
      _dental_purpose_name boolean,
      _dialysis_purpose_name boolean,
      _general_medical_name boolean,
      _general_purpose_name boolean,
      _grocery_name boolean,
      _hair_purpose_name boolean,
      _pharmacy_purpose_name boolean,
      _senior_center_purpose_name boolean,
      _therapy_purpose_name boolean,
      _visit_spouse_purpose_name boolean )
WITH DATA;


-- View: "v_Users_Accommodations"

CREATE MATERIALIZED VIEW "v_Users_Accommodations" AS 
  SELECT ct.user_profile_id AS "UA_ID",
    ct._curb_to_curb_name AS "user_curb_to_curb_name",
    ct._door_through_door_name AS "user_door_through_door_name",
    ct._door_to_door_name AS "user_door_to_door_name",
    ct._driver_assistance_name AS "user_driver_driver_assistance_name",
    ct._folding_wheelchair_accessible_name AS "user_folding_wheelchair_accessible_name",
    ct._motorized_wheelchair_accessible_name AS "user_motorized_wheelchair_accessible_name",
    ct._wheelchair_lift_equipped_name AS "user_wheelchair_lift_equipped_name"
  FROM crosstab ('SELECT user_accommodations.user_profile_id, accommodations.name, user_accommodations.value FROM public.accommodations, public.user_accommodations WHERE accommodations.id = user_accommodations.accommodation_id ORDER BY 1,2'::text, 
                 $$VALUES ('curb_to_curb_name'),
                          ('door_through_door_name'),
                          ('door_to_door_name'),
                          ('driver_assistance_name'),
                          ('folding_wheelchair_accessible_name'),
                          ('motorized_wheelchair_accessible_name'),
                          ('wheelchair_lift_equipped_name') $$) 
  ct (user_profile_id integer,
      _curb_to_curb_name text,
      _door_through_door_name text,
      _door_to_door_name text,
      _driver_assistance_name text,
      _folding_wheelchair_accessible_name text,
      _motorized_wheelchair_accessible_name text,
      _wheelchair_lift_equipped_name text )
WITH DATA;


-- View: "v_Users_Characteristics"

CREATE MATERIALIZED VIEW "v_Users_Characteristics" AS 
  SELECT ct.user_profile_id AS "UC_ID",
    ct._age_name AS "user_age_name",
    ct._date_of_birth_name AS "user_date_of_birth_name",
    ct._developmentally_disabled_name AS "user_developmentally_disabled_name",
    ct._disabled_non_elderly_name AS "user_disabled_non_elderly_name",
    ct._nemt_eligible_name AS "user_nemt_eligible_name",
    ct._physically_disabled_name AS "user_physically_disabled_name",
    ct._veteran_name AS "user_veteran_name",
    ct._wheelchair_dependent_name AS "user_wheelchair_dependent_name"
  FROM crosstab ('SELECT user_characteristics.user_profile_id, characteristics.name, user_characteristics.value FROM public.characteristics, public.user_characteristics WHERE characteristics.id = user_characteristics.characteristic_id ORDER BY 1,2'::text, 
                 $$VALUES ('age_name'),
                          ('date_of_birth_name'),
                          ('developmentally_disabled_name'),
                          ('disabled_non_elderly_name'),
                          ('nemt_eligible_name'),
                          ('physically_disabled_name'),
                          ('veteran_name'),
                          ('wheelchair_dependent_name') $$) 
  ct (user_profile_id integer,
      _age_name text,
      _date_of_birth_name text,
      _developmentally_disabled_name text,
      _disabled_non_elderly_name text,
      _nemt_eligible_name text,
      _physically_disabled_name text,
      _veteran_name text,
      _wheelchair_dependent_name text )
WITH DATA;


-- View: "v_Users_Desired_Modes"

CREATE MATERIALIZED VIEW "v_Users_Desired_Modes" AS 
  SELECT ct.user_id AS "UDM_ID",
    ct._mode_bus_name AS "user_mode_bus_name",
    ct._mode_paratransit_name AS "user_mode_paratransit_name",
    ct._mode_rail_name AS "user_mode_rail_name",
    ct._mode_taxi_name AS "user_mode_taxi_name",
    ct._mode_transit_name AS "user_mode_transit_name"
  FROM crosstab ('SELECT user_mode_preferences.user_id, modes.name, (user_mode_preferences.mode_id > 0) As "Mode_Desired" FROM public.modes, public.user_mode_preferences WHERE modes.id = user_mode_preferences.mode_id AND modes.visible = true ORDER BY 1,2'::text, 
                 $$VALUES ('mode_bus_name'),
                          ('mode_paratransit_name'),
                          ('mode_rail_name'),
                          ('mode_taxi_name'),
                          ('mode_transit_name') $$) 
  ct (user_id integer,
      _mode_bus_name boolean,
      _mode_paratransit_name boolean,
      _mode_rail_name boolean,
      _mode_taxi_name boolean,
      _mode_transit_name boolean )
WITH DATA;


/* Stage 5: Base Reporting Tables */

-- View: "v_Itineraries"

CREATE MATERIALIZED VIEW "v_Itineraries" AS 
  SELECT 
    itineraries.id AS "Itinerary_ID",
    trips.id AS "Trip_ID",
    trips.user_id AS "IU_ID",
    trips.trip_purpose_id AS "Trip_Purpose_ID",
    "v_Trip_Purposes"._en AS "Trip_Purpose",
    itineraries.service_id AS "IS_ID",
    trip_parts.is_return_trip,
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_From"."From_Raw_Address"
            ELSE "v_Trip_Places_To"."To_Raw_Address"
        END AS "From_Address",
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_From"."From_Lat"
            ELSE "v_Trip_Places_To"."To_Lat"
        END AS "From_Lat",
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_From"."From_Lon"
            ELSE "v_Trip_Places_To"."To_Lon"
        END AS "From_Lon",
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_To"."To_Raw_Address"
            ELSE "v_Trip_Places_From"."From_Raw_Address"
        END AS "To_Address",
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_To"."To_Lat"
            ELSE "v_Trip_Places_From"."From_Lat"
        END AS "To_Lat",
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_To"."To_Lon"
            ELSE "v_Trip_Places_From"."From_Lon"
        END AS "To_Lon",
    trips.updated_at As "Creation_DateTime",
    trip_parts.scheduled_date As "Requested_Date",
    to_char(trip_parts.scheduled_time, 'HH24:MI') As "Requested_Time",
    "v_Modes"._en AS "Itinerary_Mode",
    itineraries.start_time,
    itineraries.end_time,
    itineraries.duration,
    itineraries.walk_time,
    itineraries.transit_time,
    itineraries.wait_time,
    itineraries.walk_distance,
    itineraries.transfers,
    itineraries.count,
    itineraries.cost,
    itineraries.selected,
    trips.agency_id As "agency_id",
    agencies.name AS "Agency_Name"
  FROM trips
    JOIN trip_parts ON trips.id = trip_parts.trip_id
    JOIN "v_Trip_Purposes" ON "v_Trip_Purposes".id = trips.trip_purpose_id
    JOIN "v_Trip_Places_From" ON "v_Trip_Places_From".trip_id = trip_parts.trip_id
    JOIN "v_Trip_Places_To" ON "v_Trip_Places_To".trip_id = trip_parts.trip_id
    JOIN itineraries ON itineraries.trip_part_id = trip_parts.id
    LEFT JOIN "v_Modes" ON "v_Modes".code = itineraries.returned_mode_code
    LEFT JOIN agencies ON trips.agency_id = agencies.id
  ORDER BY trips.id, itineraries.id, trip_parts.is_return_trip
WITH DATA;


-- View: "v_Services"

CREATE MATERIALIZED VIEW "v_Services" AS 
  SELECT 
    services.id AS "Service_ID",
    services.name AS "Service_Name",
    services.provider_id,
    providers.name AS "Provider_Name",
    services.service_type_id AS "Service_Type_ID",
    "v_Service_Types"._en AS "Service_Type",
    services.active,
    services.advanced_notice_minutes,
    services.max_advanced_book_minutes,
    "v_Service_Trip_Purposes".*,
    "v_Service_Accommodations".*,
    "v_Service_Characteristics".*,
    "v_Service_Schedule_Start"._sunday_name AS start_sunday_name,
    "v_Service_Schedule_End"._sunday_name AS end_sunday_name,
    "v_Service_Schedule_Start"._monday_name AS start_monday_name,
    "v_Service_Schedule_End"._monday_name AS end_monday_name,
    "v_Service_Schedule_Start"._tuesday_name AS start_tuesday_name,
    "v_Service_Schedule_End"._tuesday_name AS end_tuesday_name,
    "v_Service_Schedule_Start"._wednesday_name AS start_wednesday_name,
    "v_Service_Schedule_End"._wednesday_name AS end_wednesday_name,
    "v_Service_Schedule_Start"._thursday_name AS start_thursday_name,
    "v_Service_Schedule_End"._thursday_name AS end_thursday_name,
    "v_Service_Schedule_Start"._friday_name AS start_friday_name,
    "v_Service_Schedule_End"._friday_name AS end_friday_name,
    "v_Service_Schedule_Start"._saturday_name AS start_saturday_name,
    "v_Service_Schedule_End"._saturday_name AS end_saturday_name
  FROM services
    LEFT JOIN "v_Service_Accommodations" ON "v_Service_Accommodations"."SA_ID" = services.id
    LEFT JOIN "v_Service_Characteristics" ON "v_Service_Characteristics"."SC_ID" = services.id
    LEFT JOIN "v_Service_Schedule_End" ON "v_Service_Schedule_End"."SSE_ID" = services.id
    LEFT JOIN "v_Service_Schedule_Start" ON "v_Service_Schedule_Start"."SSS_ID" = services.id
    LEFT JOIN "v_Service_Trip_Purposes" ON "v_Service_Trip_Purposes"."STP_ID" = services.id
    JOIN providers ON services.provider_id = providers.id
    JOIN "v_Service_Types" ON "v_Service_Types".id = services.service_type_id
WITH DATA;

    
-- View: "v_Trips"

CREATE MATERIALIZED VIEW "v_Trips" AS 
  SELECT trips.id AS "Trip_ID",
    trips.user_id,
    date_trunc('second', trips.updated_at) As "Creation_DateTime",
    date_trunc('day', trips.scheduled_date) As "Requested_Date",
    to_char(trips.scheduled_time, 'HH24:MI') As "Requested_Time",
    "From_Trip_Places".raw_address AS "From_Address",
    "To_Trip_Places".raw_address AS "To_Address",
    trips.trip_purpose_id AS "Trip_Purpose_ID",
    "v_Trip_Purposes"._en AS "Trip_Purpose",
    "v_Ratings_Trip".value AS "Trip_Rating",
    trips.is_planned,
    trips.agency_id As "agency_id",
    agencies.name AS "Agency_Name"
  FROM trips
    JOIN "v_Trip_Purposes" ON "v_Trip_Purposes".id = trips.trip_purpose_id
    JOIN trip_parts ON trip_parts.trip_id = trips.id
    JOIN trip_places "From_Trip_Places" ON "From_Trip_Places".id = trip_parts.from_trip_place_id
    JOIN trip_places "To_Trip_Places" ON "To_Trip_Places".id = trip_parts.to_trip_place_id
    LEFT JOIN "v_Ratings_Trip" ON trips.id = "v_Ratings_Trip".rateable_id
    LEFT JOIN agencies ON trips.agency_id = agencies.id
  WHERE trip_parts.sequence = 0
WITH DATA;


-- View: "v_Trip_Parts"

CREATE MATERIALIZED VIEW "v_Trip_Parts" AS 
 SELECT
    trip_parts.id,
    trip_parts.trip_id AS "Trip_ID",
    trips.user_id As "TPU_ID",
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_From"."From_Raw_Address"
            ELSE "v_Trip_Places_To"."To_Raw_Address"
        END AS "From_Address",
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_From"."From_Lat"
            ELSE "v_Trip_Places_To"."To_Lat"
        END AS "From_Lat",
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_From"."From_Lon"
            ELSE "v_Trip_Places_To"."To_Lon"
        END AS "From_Lon",
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_To"."To_Raw_Address"
            ELSE "v_Trip_Places_From"."From_Raw_Address"
        END AS "To_Address",
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_To"."To_Lat"
            ELSE "v_Trip_Places_From"."From_Lat"
        END AS "To_Lat",
        CASE
            WHEN NOT trip_parts.is_return_trip THEN "v_Trip_Places_To"."To_Lon"
            ELSE "v_Trip_Places_From"."From_Lon"
        END AS "To_Lon",
    trip_parts.is_return_trip,
    date_trunc('second', trip_parts.updated_at) As "Creation_DateTime",
    trip_parts.is_depart AS "Depart_By",
    date_trunc('day', trip_parts.scheduled_date) As "Requested_Date",
    to_char(trip_parts.scheduled_time, 'HH24:MI') As "Requested_Time",
    trips.trip_purpose_id AS "Trip_Purpose_ID",
    "v_Trip_Purposes"._en AS "Trip_Purpose",
    "v_Ratings_Trip".value AS "Trip_Rating",
    trips.is_planned,
    trips.agency_id As "agency_id",
    agencies.name AS "Agency_Name"
   FROM trip_parts
     JOIN trips ON trip_parts.trip_id = trips.id
     JOIN "v_Trip_Places_From" ON "v_Trip_Places_From".trip_id = trip_parts.trip_id
     JOIN "v_Trip_Places_To" ON "v_Trip_Places_To".trip_id = trip_parts.trip_id
    JOIN "v_Trip_Purposes" ON "v_Trip_Purposes".id = trips.trip_purpose_id
    LEFT JOIN "v_Ratings_Trip" ON trips.id = "v_Ratings_Trip".rateable_id
    LEFT JOIN agencies ON trips.agency_id = agencies.id
WITH DATA;


-- View: "v_Users"

CREATE MATERIALIZED VIEW "v_Users" AS 
  SELECT users.id AS "User_ID",
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
    users.preferred_locale,
    walking_speeds.value AS "Walking_Speed_mph",
    walking_maximum_distances.value AS "Walking_Maximum_Distance_Miles",
    users.maximum_wait_time,
    "v_Users_Accommodations".*,
    "v_Users_Characteristics".*,
    "v_Users_Desired_Modes".*
  FROM users
    LEFT JOIN "v_Users_Accommodations" ON "v_Users_Accommodations"."UA_ID" = users.id
    LEFT JOIN "v_Users_Characteristics" ON "v_Users_Characteristics"."UC_ID" = users.id
    LEFT JOIN "v_Users_Desired_Modes" ON "v_Users_Desired_Modes"."UDM_ID" = users.id
    LEFT JOIN walking_speeds ON walking_speeds.id = users.walking_speed_id
    LEFT JOIN walking_maximum_distances ON walking_maximum_distances.id = users.walking_maximum_distance_id
WITH DATA;


/* Stage 6: Combined Reporting Tables */

-- View: "v_Trips_Users"

CREATE MATERIALIZED VIEW "v_Trips_Users" AS 
  SELECT "v_Trips".*,
    "v_Users".*
  FROM "v_Trips"
    JOIN "v_Users" ON "v_Users"."User_ID" = "v_Trips".user_id
WITH DATA;


-- View: "v_Trip_Parts_Users"

CREATE MATERIALIZED VIEW "v_Trip_Parts_Users" AS 
  SELECT "v_Trip_Parts".*,
    "v_Users".*
  FROM "v_Trip_Parts"
    JOIN "v_Users" ON "v_Users"."User_ID" = "v_Trip_Parts"."TPU_ID"
WITH DATA;


-- View: "v_Itineraries_Users"

CREATE MATERIALIZED VIEW "v_Itineraries_Users" AS 
SELECT 
  "v_Itineraries".*, 
  "v_Services".*, 
  "v_Users".*
FROM 
  public."v_Itineraries" 
  JOIN public."v_Users" ON "v_Users"."User_ID" = "v_Itineraries"."IU_ID"
  LEFT JOIN public."v_Services" ON "v_Services"."Service_ID" = "v_Itineraries"."IS_ID"
WITH DATA;


--Refresh
Select RefreshAllMaterializedViews();

/*
--Stage 1: Base Tables

REFRESH MATERIALIZED VIEW "v_Ratings_Trip";
REFRESH MATERIALIZED VIEW "v_Translations";
REFRESH MATERIALIZED VIEW "v_Translations_Locale";

--Stage 2: Language Tables
REFRESH MATERIALIZED VIEW "v_Accommodations";
REFRESH MATERIALIZED VIEW "v_Characteristics";
REFRESH MATERIALIZED VIEW "v_Modes";
REFRESH MATERIALIZED VIEW "v_Service_Types";
REFRESH MATERIALIZED VIEW "v_Trip_Purposes";
REFRESH MATERIALIZED VIEW "v_Trip_Statuses";

--Stage 3: Generic
REFRESH MATERIALIZED VIEW "v_Trip_Places_MinSequence";
REFRESH MATERIALIZED VIEW "v_Trip_Places_MaxSequence";
REFRESH MATERIALIZED VIEW "v_Trip_Places_From";
REFRESH MATERIALIZED VIEW "v_Trip_Places_To";
REFRESH MATERIALIZED VIEW "v_Service_Schedule_Start";
REFRESH MATERIALIZED VIEW "v_Service_Schedule_End";

--Stage 4: Deployment Specific
REFRESH MATERIALIZED VIEW "v_Service_Accommodations";
REFRESH MATERIALIZED VIEW "v_Service_Characteristics";
REFRESH MATERIALIZED VIEW "v_Service_Trip_Purposes";
REFRESH MATERIALIZED VIEW "v_Users_Accommodations";
REFRESH MATERIALIZED VIEW "v_Users_Characteristics";
REFRESH MATERIALIZED VIEW "v_Users_Desired_Modes";

--Stage 5:
REFRESH MATERIALIZED VIEW "v_Trips";
REFRESH MATERIALIZED VIEW "v_Itineraries";
REFRESH MATERIALIZED VIEW "v_Services";
REFRESH MATERIALIZED VIEW "v_Users";

--Stage 6: Combined Reporting Tables
REFRESH MATERIALIZED VIEW "v_Trips_Users";
 */