--DROP TABLE day_of_week;
/*
CREATE TABLE day_of_week
(
  id serial NOT NULL,
  name character varying(16),
  note character varying(16),
  CONSTRAINT day_of_week_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);


INSERT INTO day_of_week(id, name, note) VALUES (0, 'sunday_name', 'sunday_note');
INSERT INTO day_of_week(id, name, note) VALUES (1, 'monday_name', 'monday_note');
INSERT INTO day_of_week(id, name, note) VALUES (2, 'tuesday_name', 'tuesday_note');
INSERT INTO day_of_week(id, name, note) VALUES (3, 'wednesday_name', 'wednesday_note');
INSERT INTO day_of_week(id, name, note) VALUES (4, 'thursday_name', 'thursday_note');
INSERT INTO day_of_week(id, name, note) VALUES (5, 'friday_name', 'friday_note');
INSERT INTO day_of_week(id, name, note) VALUES (6, 'saturday_name', 'saturday_note');


*/

--DROP TABLE boolean_lookup;

CREATE TABLE boolean_lookup
(
  id serial NOT NULL,
  name character varying(16),
  note character varying(16),
  CONSTRAINT boolean_lookup_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);


INSERT INTO boolean_lookup(id, name, note) VALUES (0, 'false_name', 'false_note');
INSERT INTO boolean_lookup(id, name, note) VALUES (1, 'true_name', 'true_note');
