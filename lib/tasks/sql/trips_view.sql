-- Dependency view: v_Ratings_Trip
CREATE OR REPLACE VIEW "v_Ratings_Trip" AS 
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
  WHERE ratings.rateable_type::text = 'Trip'::text AND ratings.value >= 0;

--Dependency view: v_Trip_Purpose
CREATE OR REPLACE VIEW "v_Trip_Purpose" AS 
 SELECT trip_purposes.id,
    trip_purposes.name,
    trip_purposes.note,
    trip_purposes.active,
    trip_purposes.sort_order,
    trip_purposes.code,
    translations.value AS translation
   FROM translations,
    trip_purposes
  WHERE translations.key::text = trip_purposes.name::text AND translations.locale::text = 'en'::text;

-- main view: trip_parts_view
DROP VIEW IF EXISTS "trip_parts_view";
CREATE OR REPLACE VIEW "trip_parts_view" AS 
 SELECT DISTINCT trip_parts.id,
    trips.id AS trip_id,
    trips.user_id,
    (users.first_name::text || ' '::text) || users.last_name::text AS user_name,
    trip_parts.scheduled_date AS trip_date,
    "From_Trip_Places".raw_address AS from_address,
    "To_Trip_Places".raw_address AS to_address,
    "v_Trip_Purpose".translation AS trip_purpose,
    "v_Ratings_Trip".value AS trip_rating,
    providers.id AS provider_id,
    providers.name AS provider_name
   FROM trip_parts
     JOIN trips ON trips.id = trip_parts.trip_id
     JOIN "v_Trip_Purpose" ON "v_Trip_Purpose".id = trips.trip_purpose_id
     JOIN users ON users.id = trips.user_id
     JOIN itineraries ON itineraries.trip_part_id = trip_parts.id
     LEFT JOIN services ON services.id = itineraries.service_id
     LEFT JOIN providers ON providers.id = services.provider_id
     JOIN trip_places "From_Trip_Places" ON "From_Trip_Places".id = trip_parts.from_trip_place_id
     JOIN trip_places "To_Trip_Places" ON "To_Trip_Places".id = trip_parts.to_trip_place_id
     LEFT JOIN "v_Ratings_Trip" ON trips.id = "v_Ratings_Trip".rateable_id
  WHERE itineraries.selected = true
  ORDER BY trip_parts.id;

-- main view: trips_view
DROP VIEW IF EXISTS "trips_view";
CREATE OR REPLACE VIEW "trips_view" AS 
 SELECT DISTINCT trips.id,
    trips.user_id,
    (users.first_name::text || ' '::text) || users.last_name::text AS user_name,
    trips.scheduled_date as trip_date,
    "From_Trip_Places".raw_address AS from_address,
    "To_Trip_Places".raw_address AS to_address,
    "v_Trip_Purpose".translation AS trip_purpose,
    "v_Ratings_Trip".value AS trip_rating,
    trips.agency_id
   FROM trips
     JOIN "v_Trip_Purpose" ON "v_Trip_Purpose".id = trips.trip_purpose_id
     JOIN users ON users.id = trips.user_id
     JOIN trip_parts ON trip_parts.trip_id = trips.id
     JOIN trip_places "From_Trip_Places" ON "From_Trip_Places".id = trip_parts.from_trip_place_id
     JOIN trip_places "To_Trip_Places" ON "To_Trip_Places".id = trip_parts.to_trip_place_id
     LEFT JOIN "v_Ratings_Trip" ON trips.id = "v_Ratings_Trip".rateable_id
  WHERE trip_parts.sequence = 0 and trips.is_planned = true
  ORDER BY trips.id;


    