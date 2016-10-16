/* Stage 6: Combined Reporting Tables */
DROP MATERIALIZED VIEW IF EXISTS "v_Itineraries_Users";
DROP MATERIALIZED VIEW IF EXISTS "v_Feedback_Trips_Users";
DROP MATERIALIZED VIEW IF EXISTS "v_Trips_Users";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Parts_Users";


/* Stage 5: */
DROP MATERIALIZED VIEW IF EXISTS "v_Agencies";
DROP MATERIALIZED VIEW IF EXISTS "v_Feedbacks";
DROP MATERIALIZED VIEW IF EXISTS "v_Providers";
DROP MATERIALIZED VIEW IF EXISTS "v_Itineraries";
DROP MATERIALIZED VIEW IF EXISTS "v_Services";
DROP MATERIALIZED VIEW IF EXISTS "v_Trip_Parts";
DROP MATERIALIZED VIEW IF EXISTS "v_Trips";
DROP MATERIALIZED VIEW IF EXISTS "v_Trips_Desired_Modes";
DROP MATERIALIZED VIEW IF EXISTS "v_Users";


/* Stage 4: Deployment Specific*/
DROP MATERIALIZED VIEW IF EXISTS "v_Feedback_Issues";
DROP MATERIALIZED VIEW IF EXISTS "v_Feedback_Ratings";
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
DROP MATERIALIZED VIEW IF EXISTS "v_Feedback_Statuses";
DROP MATERIALIZED VIEW IF EXISTS "v_Feedback_Types";
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


-- View: "v_Feedback_Statuses"

CREATE MATERIALIZED VIEW "v_Feedback_Statuses" AS 
  SELECT feedback_statuses.id,
    feedback_statuses.name,
    CASE WHEN "v_Translations"._en IS NULL THEN
      feedback_statuses.name
    ELSE
      "v_Translations"._en
    END AS _en,
    CASE WHEN "v_Translations"._es IS NULL THEN
      feedback_statuses.name
    ELSE
      "v_Translations"._es
    END AS _es,
    CASE WHEN "v_Translations"._ht IS NULL THEN
      feedback_statuses.name
    ELSE
      "v_Translations"._ht
    END AS _ht
  FROM feedback_statuses
    LEFT JOIN "v_Translations" ON "v_Translations".key = feedback_statuses.name
WITH DATA;


-- View: "v_Feedback_Types"

CREATE MATERIALIZED VIEW "v_Feedback_Types" AS 
  SELECT feedback_types.id,
    feedback_types.name,
    "v_Translations"._en,
    "v_Translations"._es,
    "v_Translations"._ht
  FROM feedback_types, "v_Translations"
  WHERE "v_Translations".key::text = feedback_types.name::text
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
/* JTA                                                                                                                                        */
/* ------------------------------------------------------------------------------------------------------------------------------------------ */

-- View: "v_Feedback_Issues"

CREATE MATERIALIZED VIEW "v_Feedback_Issues" AS 
  SELECT ct.feedback_id AS feedback_issues_feedback_id,
    ct._confusing_information AS feedback_issue_application_confusing_information,
    ct._invalid_data AS feedback_issue_application_invalid_data,
    ct._base_fare AS feedback_issue_unmet_need_base_fare,
    ct._number_of_transfers AS feedback_issue_unmet_need_number_of_transfers,
    ct._travel_time AS feedback_issue_unmet_need_travel_time,
    ct._walking_distance AS feedback_issue_unmet_need_walking_distance,
    ct._incorrect_info AS feedback_issue_unmet_need_incorrect_info,
    ct._not_enough_options AS feedback_issue_unmet_need_not_enough_options
  FROM crosstab ('SELECT feedback_issues_feedbacks.feedback_id, feedback_issues.name, feedback_issues_feedbacks.value
                  FROM feedback_issues_feedbacks
                    JOIN feedback_issues_feedback_types ON feedback_issues_feedback_types.feedback_issue_id = feedback_issues_feedbacks.feedback_issue_id
                    JOIN feedback_issues ON feedback_issues_feedbacks.feedback_issue_id = feedback_issues.id
                  ORDER BY 1,2'::text, 
                  $$VALUES ('confusing_info'),('invalid_data'),('base_fare'),('number_of_transfers'),('travel_time'),('walking_distance'),('incorrect_info'),('not_enough_options') $$) 
ct (feedback_id integer,
    _confusing_information boolean,
    _invalid_data boolean,
    _base_fare boolean,
    _number_of_transfers boolean,
    _travel_time boolean,
    _walking_distance boolean,
    _incorrect_info boolean,
    _not_enough_options boolean)
WITH DATA;


-- View: "v_Feedback_Ratings"

CREATE MATERIALIZED VIEW "v_Feedback_Ratings" AS 
  SELECT ct.feedback_id AS feedback_ratings_feedback_id,
    CASE WHEN 0 = ct._color_scheme THEN
      NULL
    ELSE
      ct._color_scheme
    END AS feedback_rating_application_color_scheme,
    CASE WHEN 0 = ct._ease_of_use THEN
      NULL
    ELSE
      ct._ease_of_use
    END AS feedback_rating_application_ease_of_use,
    CASE WHEN 0 = ct._quality_of_services THEN
      NULL
    ELSE
      ct._quality_of_services
    END AS feedback_rating_unmet_need_quality_of_services,
    CASE WHEN 0 = ct._number_of_services THEN
      NULL
    ELSE
      ct._number_of_services
    END AS feedback_rating_unmet_need_number_of_services,
    CASE WHEN 0 = ct._cleanliness THEN
      NULL
    ELSE
      ct._cleanliness
    END AS feedback_rating_trip_cleanliness,
    CASE WHEN 0 = ct._courtesy THEN
      NULL
    ELSE
      ct._courtesy
    END AS feedback_rating_trip_courtesy,
    CASE WHEN 0 = ct._safety THEN
      NULL
    ELSE
      ct._safety
    END AS feedback_rating_trip_safety,
    CASE WHEN 0 = ct._timeliness THEN
      NULL
    ELSE
      ct._timeliness
    END AS feedback_rating_trip_timeliness
  FROM crosstab ('SELECT feedback_ratings_feedbacks.feedback_id, feedback_ratings.name, feedback_ratings_feedbacks.value
                  FROM feedback_ratings_feedbacks
                    JOIN feedback_ratings_feedback_types ON feedback_ratings_feedback_types.feedback_rating_id = feedback_ratings_feedbacks.feedback_rating_id
                    JOIN feedback_ratings ON feedback_ratings_feedbacks.feedback_rating_id = feedback_ratings.id
                  ORDER BY 1,2'::text, 
                  $$VALUES ('color_scheme'),('ease_of_use'),('quality_of_services'),('number_of_services'),('cleanliness'),('courtesy'),('safety'),('timeliness') $$) 
ct (feedback_id integer,
    _color_scheme integer,
    _ease_of_use integer,
    _quality_of_services integer,
    _number_of_services integer,
    _cleanliness integer,
    _courtesy integer,
    _safety integer,
    _timeliness integer)
WITH DATA;


-- View: "v_Service_Accommodations"

CREATE MATERIALIZED VIEW "v_Service_Accommodations" AS 
  SELECT ct.service_id AS sa_service_id,
    ct._curb_to_curb_name AS service_curb_to_curb,
    ct._door_through_door_name AS service_door_through_door,
    ct._door_to_door_name AS service_door_to_door,
    ct._driver_assistance_name AS service_driver_assistance,
    ct._folding_wheelchair_accessible_name AS service_folding_wheelchair_accessible,
    ct._motorized_wheelchair_accessible_name AS service_motorized_wheelchair_accessible,
    ct._wheelchair_lift_equipped_name AS service_wheelchair_lift_equipped
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
    ct.service_id AS sc_service_id,
    ct._age_name AS service_characteristic_age,
    ct._date_of_birth_name AS service_characteristic_date_of_birth,
    ct._developmentally_disabled_name As service_characteristic_developmentally_disabled,
    ct._disabled_non_elderly_name As service_characteristic_diabled_non_elderly,
    ct._nemt_eligible_name As service_characteristic_nemt_eligible,
    ct._physically_disabled_name As service_characteristic_physically_disabled,
    ct._veteran_name As service_characteristic_veteran,
    ct._wheelchair_dependent_name As service_characteristic_wheelchair_Dependent
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
  SELECT ct.service_id AS stp_service_id,
    ct._cancer_treatment_name AS service_trip_purpose_cancer_treatment,
    ct._general_medical_name AS service_trip_purpose_general_medical,
    ct._general_purpose_name AS service_trip_purpose_general_purpose,
    ct._grocery_name AS service_trip_purpose_grocery_name
  FROM crosstab ('SELECT service_trip_purpose_maps.service_id, trip_purposes.name, true as value FROM public.service_trip_purpose_maps, public.trip_purposes WHERE trip_purposes.id = service_trip_purpose_maps.trip_purpose_id ORDER BY 1,2'::text, 
                 $$VALUES ('cancer_treatment_name'),
                          ('general_medical_name'),
                          ('general_purpose_name'),
                          ('grocery_name') $$) 
  ct (service_id integer,
      _cancer_treatment_name boolean,
      _general_medical_name boolean,
      _general_purpose_name boolean,
      _grocery_name boolean )
WITH DATA;


-- View: "v_Trip_Parts_Itinerary_Mode_Count"

CREATE MATERIALIZED VIEW "v_Trip_Parts_Itinerary_Mode_Count" AS 
  SELECT ct.trip_part_id AS tpitm_trip_part_id,
    ct._trip_part_mode_bicycle_count AS trip_mode_bicycle_count,
    ct._trip_part_mode_car_count AS trip_mode_car_count,
    ct._trip_part_mode_paratransit_count AS trip_mode_paratransit_count,
    ct._trip_part_mode_taxi_count AS trip_mode_taxi_count,
    ct._trip_part_mode_transit_count AS trip_mode_transit_count
  FROM crosstab ('SELECT trip_part_id, returned_mode_code, count(*) As mode_count from itineraries group by trip_part_id, returned_mode_code ORDER BY 1,2',
                 $$VALUES ('mode_bicycle'::text),
                          ('mode_car'::text),
                          ('mode_paratransit'::text),
                          ('mode_taxi'::text),
                          ('mode_transit'::text) $$) 
  ct (trip_part_id integer,
      _trip_part_mode_bicycle_count int,
      _trip_part_mode_car_count int,
      _trip_part_mode_paratransit_count int,
      _trip_part_mode_taxi_count int,
      _trip_part_mode_transit_count int );


-- View: "v_Trips_Desired_Modes"

CREATE MATERIALIZED VIEW "v_Trips_Desired_Modes" AS 
  SELECT trip_id AS tdm_trip_id,
    not _mode_bicycle_name is null as trip_desired_mode_bicycle,
    not _mode_bus_name is null as trip_desired_mode_bus,
    not _mode_car_name is null as trip_desired_mode_car,
    not _mode_paratransit_name is null as trip_desired_mode_paratransit,
    not _mode_rail_name is null as trip_desired_mode_rail,
    not _mode_taxi_name is null as trip_desired_mode_taxi,
    not _mode_transit_name is null as trip_desired_mode_transit  --,
--    trim(both '|' from
--        (( CASE WHEN NOT _mode_bicycle_name IS NULL THEN '|' || _mode_bicycle_name ELSE '' END ) || 
--         ( CASE WHEN NOT _mode_bus_name IS NULL THEN '|' || _mode_bus_name ELSE '' END ) || 
--         ( CASE WHEN NOT _mode_car_name IS NULL THEN '|' || _mode_car_name ELSE '' END ) || 
--         ( CASE WHEN NOT _mode_paratransit_name IS NULL THEN '|' || _mode_paratransit_name ELSE '' END ) || 
--         ( CASE WHEN NOT _mode_rail_name IS NULL THEN '|' || _mode_rail_name ELSE '' END ) || 
--         ( CASE WHEN NOT _mode_taxi_name IS NULL THEN '|' || _mode_taxi_name ELSE '' END ) || 
--         ( CASE WHEN NOT _mode_transit_name IS NULL THEN '|' || _mode_transit_name ELSE '' END ))) As trip_desired_modes
  FROM crosstab ('SELECT trips_desired_modes.trip_id, "v_Modes".name As "Name", "v_Modes"._en As "Desired_Mode" FROM public."v_Modes", public.trips_desired_modes WHERE "v_Modes".id = trips_desired_modes.desired_mode_id ORDER BY 1,2'::text, 
                 $$VALUES ('mode_bicycle_name'),
                          ('mode_bus_name'),
                          ('mode_car_name'),
                          ('mode_paratransit'),
                          ('mode_rail_name'),
                          ('mode_taxi_name'),
                          ('mode_transit_name') $$)
  ct (trip_id integer,
      _mode_bicycle_name text,
      _mode_bus_name text,
      _mode_car_name text,
      _mode_paratransit_name text,
      _mode_rail_name text,
      _mode_taxi_name text,
      _mode_transit_name text )
WITH DATA;


-- View: "v_Users_Accommodations"

CREATE MATERIALIZED VIEW "v_Users_Accommodations" AS 
  SELECT ct.user_profile_id AS ua_user_id,
    cast(ct._curb_to_curb_name AS boolean) AS user_curb_to_curb,
    cast(ct._door_through_door_name AS boolean) AS user_door_through_door,
    cast(ct._door_to_door_name AS boolean) AS user_door_to_door,
    cast(ct._driver_assistance_name AS boolean) AS user_driver_assistance,
    cast(ct._folding_wheelchair_accessible_name AS boolean) AS user_folding_wheelchair_accessible,
    cast(ct._motorized_wheelchair_accessible_name AS boolean) AS user_motorized_wheelchair_accessible,
    cast(ct._wheelchair_lift_equipped_name AS boolean) AS user_wheelchair_lift_equipped
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
  SELECT ct.user_profile_id AS uc_user_id,
    cast(ct._age_name AS integer) AS user_age,
    ct._date_of_birth_name AS user_date_of_birth,
    cast(ct._developmentally_disabled_name AS boolean) AS user_developmentally_disabled,
    cast(ct._disabled_non_elderly_name AS boolean) AS user_disabled_non_elderly,
    cast(ct._nemt_eligible_name AS boolean) AS user_nemt_eligible,
    cast(ct._physically_disabled_name AS boolean) AS user_physically_disabled,
    cast(ct._veteran_name AS boolean) AS user_veteran,
    cast(ct._wheelchair_dependent_name AS boolean) AS user_wheelchair_dependent
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
  SELECT ct.user_id AS udm_user_id,
    ct._mode_bicycle_name AS user_desired_mode_bicycle,
    ct._mode_bus_name AS user_desired_mode_bus,
    ct._mode_car_name AS user_desired_mode_car,
    ct._mode_paratransit_name AS user_desired_mode_paratransit,
    ct._mode_rail_name AS user_desired_mode_rail,
    ct._mode_taxi_name AS user_desired_mode_taxi,
    ct._mode_transit_name AS user_desired_mode_transit
  FROM crosstab ('SELECT user_mode_preferences.user_id, modes.name, (user_mode_preferences.mode_id > 0) As "Mode_Desired" FROM public.modes, public.user_mode_preferences WHERE modes.id = user_mode_preferences.mode_id AND modes.visible = true ORDER BY 1,2'::text, 
                 $$VALUES ('mode_bicycle_name'),
                          ('mode_bus_name'),
                          ('mode_car_name'),
                          ('mode_paratransit_name'),
                          ('mode_rail_name'),
                          ('mode_taxi_name'),
                          ('mode_transit_name') $$) 
  ct (user_id integer,
      _mode_bicycle_name boolean,
      _mode_bus_name boolean,
      _mode_car_name boolean,
      _mode_paratransit_name boolean,
      _mode_rail_name boolean,
      _mode_taxi_name boolean,
      _mode_transit_name boolean )
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

    
-- View: "v_Feedbacks"

CREATE MATERIALIZED VIEW "v_Feedbacks" AS 
  SELECT 
    feedbacks.id AS feedback_id,
    feedbacks.user_email AS feedback_user_email,
    feedbacks.user_id AS feedback_user_id,
    feedbacks.trip_id AS feedback_trip_id,
    feedbacks.comment AS feedback_comment,
    CASE WHEN 0 = feedbacks.average_rating THEN
      NULL
    ELSE
      feedbacks.average_rating
    END AS feedback_average_rating,
    feedbacks.feedback_type_id AS feedback_type_id,
    "v_Feedback_Types"._en AS feedback_type,
    feedbacks.feedback_status_id AS feedback_status_id,
    "v_Feedback_Statuses"._en AS feedback_status,
    "v_Feedback_Issues".*,
    "v_Feedback_Ratings".*
  FROM feedbacks
    JOIN "v_Feedback_Types" ON "v_Feedback_Types".id = feedbacks.feedback_type_id
    LEFT JOIN "v_Feedback_Statuses" ON "v_Feedback_Statuses".id = feedbacks.feedback_status_id
    LEFT JOIN "v_Feedback_Issues" ON "v_Feedback_Issues".feedback_issues_feedback_id = feedbacks.id
    LEFT JOIN "v_Feedback_Ratings" ON "v_Feedback_Ratings".feedback_ratings_feedback_id = feedbacks.id
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
    itineraries.selected AS itinerary_selected
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
    JOIN "v_Trip_Purposes" ON "v_Trip_Purposes".id = trips.trip_purpose_id
    JOIN trip_parts ON trip_parts.trip_id = trips.id
    JOIN trip_places "From_Trip_Places" ON "From_Trip_Places".id = trip_parts.from_trip_place_id
    JOIN trip_places "To_Trip_Places" ON "To_Trip_Places".id = trip_parts.to_trip_place_id
    JOIN "v_Trips_Desired_Modes" ON "v_Trips_Desired_Modes".tdm_trip_id = trips.id
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
    JOIN "v_Trip_Purposes" ON "v_Trip_Purposes".id = trips.trip_purpose_id
    JOIN "v_Trips_Desired_Modes" ON "v_Trips_Desired_Modes".tdm_trip_id = trips.id
    LEFT JOIN "v_Trip_Parts_Itinerary_Mode_Count" ON "v_Trip_Parts_Itinerary_Mode_Count".tpitm_trip_part_id = trip_parts.id
    LEFT JOIN "v_Ratings_Trip" ON trips.id = "v_Ratings_Trip".rateable_id
    LEFT JOIN agencies ON trips.agency_id = agencies.id
    LEFT JOIN users ON trips.creator_id = users.id
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

-- View: "v_Feedback_Trips_Users"

CREATE MATERIALIZED VIEW "v_Feedback_Trips_Users" AS 
  SELECT 
    "v_Feedbacks".*,
    "v_Trips".*,
    "v_Users".*
  FROM 
    "v_Feedbacks"
    LEFT JOIN "v_Trips" ON "v_Trips".trip_id = "v_Feedbacks".feedback_trip_id
    LEFT JOIN "v_Users" ON "v_Users".user_id = "v_Feedbacks".feedback_user_id
WITH DATA;


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
  'user_' || replace(name, '_name', '') As "name",
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
  'user_' || replace(name, '_name', '') As "name",
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
  'trip_desired_' || replace(name, '_name', '') As "name",
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
  'user_desired_' || replace(name, '_name', '') As "name",
  _en As "title",
  now() as "created_at",
  now() as "updated_at",
  row_number() OVER () AS "sort_order",
  '' as "value_type"
from "v_Modes"
where "v_Modes".visible = TRUE AND "v_Modes".visible = TRUE;