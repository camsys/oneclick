DELETE FROM reporting_specific_filter_groups;
DELETE FROM reporting_filter_fields;
DELETE FROM reporting_lookup_tables;
DELETE FROM reporting_filter_groups;
DELETE FROM reporting_reports;
DELETE FROM reporting_filter_types;

/* Filter Types */

INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (1,'eq','2015-04-13 17:28:37.384943','2015-04-13 17:28:37.384943');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (2,'not_eq','2015-04-13 17:28:37.405095','2015-04-13 17:28:37.405095');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (3,'matches','2015-04-13 17:28:37.416817','2015-04-13 17:28:37.416817');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (4,'does_not_match','2015-04-13 17:28:37.424459','2015-04-13 17:28:37.424459');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (5,'lt','2015-04-13 17:28:37.432057','2015-04-13 17:28:37.432057');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (6,'gt','2015-04-13 17:28:37.439388','2015-04-13 17:28:37.439388');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (7,'lteq','2015-04-13 17:28:37.446655','2015-04-13 17:28:37.446655');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (8,'gteq','2015-04-13 17:28:37.453886','2015-04-13 17:28:37.453886');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (9,'in','2015-04-13 17:28:37.481271','2015-04-13 17:28:37.481271');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (10,'not_in','2015-04-13 17:28:37.511522','2015-04-13 17:28:37.511522');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (11,'cont','2015-04-13 17:28:37.519203','2015-04-13 17:28:37.519203');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (12,'not_cont','2015-04-13 17:28:37.528661','2015-04-13 17:28:37.528661');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (13,'cont_any','2015-04-13 17:28:37.682564','2015-04-13 17:28:37.682564');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (14,'not_cont_any','2015-04-13 17:28:37.696098','2015-04-13 17:28:37.696098');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (15,'i_cont','2015-04-13 17:28:37.70544','2015-04-13 17:28:37.70544');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (16,'i_not_cont','2015-04-13 17:28:37.912595','2015-04-13 17:28:37.912595');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (17,'start','2015-04-13 17:28:38.037964','2015-04-13 17:28:38.037964');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (18,'not_start','2015-04-13 17:28:38.049409','2015-04-13 17:28:38.049409');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (19,'end','2015-04-13 17:28:38.057445','2015-04-13 17:28:38.057445');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (20,'not_end','2015-04-13 17:28:38.065433','2015-04-13 17:28:38.065433');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (21,'true','2015-04-13 17:28:38.073134','2015-04-13 17:28:38.073134');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (22,'not_true','2015-04-13 17:28:38.200882','2015-04-13 17:28:38.200882');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (23,'false','2015-04-13 17:28:38.442326','2015-04-13 17:28:38.442326');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (24,'not_false','2015-04-13 17:28:38.687183','2015-04-13 17:28:38.687183');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (25,'present','2015-04-13 17:28:38.709074','2015-04-13 17:28:38.709074');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (26,'blank','2015-04-13 17:28:38.719708','2015-04-13 17:28:38.719708');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (27,'null','2015-04-13 17:28:38.738208','2015-04-13 17:28:38.738208');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (28,'not_null','2015-04-13 17:28:38.889793','2015-04-13 17:28:38.889793');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (29,'range','2015-04-13 17:28:38.902127','2015-04-13 17:28:38.902127');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (30,'select','2015-04-13 17:28:38.918461','2015-04-13 17:28:38.918461');
INSERT INTO reporting_filter_types(id, name, created_at, updated_at)
    VALUES (31,'multi_select','2015-04-13 17:28:38.931624','2015-04-13 17:28:38.931624');


/* Lookup Tables */

INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (1,'v_Service_Types','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id',NULL);
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (2,'providers','name','2015-01-01 00:00:00','2015-04-17 14:36:10.112449','id','provider');
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (3,'v_Characteristics','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id',NULL);
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (4,'v_Accommodations','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id',NULL);
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (5,'v_Trip_Purposes','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id',NULL);
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (6,'v_Trip_Statuses','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id',NULL);
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (7,'v_Modes','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id',NULL);
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (8,'services','name','2015-01-01 00:00:00','2015-04-17 16:19:29.127294','id','service');
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (9,'v_Boolean','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id',NULL);
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (10,'agencies','name','2015-01-01 00:00:00','2015-01-01 00:00:00','id','agency');
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (11,'v_Feedback_Types','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id',NULL);
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (12,'v_Feedback_Statuses','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id',NULL);


/* Reports */

INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (1,'Services','Defined Services','v_Services','2015-01-01 00:00:00','2015-01-01 00:00:00',TRUE,TRUE,FALSE,FALSE,'service_id');
INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (2,'Users','All Users','v_Users','2015-04-13 19:43:49.036979','2015-04-13 20:21:41.785259',TRUE,FALSE,FALSE,FALSE,'user_id');
INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (3,'Trip - Travelers','Trip Travelers','v_Trips_Users','2015-01-01 00:00:00','2015-04-15 16:15:21.475268',TRUE,FALSE,TRUE,TRUE,'trip_id');
INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (4,'Trip - Travelers (By Itinerary)','Itineraries displayed to Travelers ','v_Itineraries_Users','2015-01-01 00:00:00','2015-01-01 00:00:00',TRUE,TRUE,TRUE,TRUE,'itinerary_id');
INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (5,'Trip - Travelers (By Direction)','Trip Parts Travelers','v_Trip_Parts_Users','2015-01-01 00:00:00','2015-01-01 00:00:00',TRUE,FALSE,TRUE,TRUE,'trip_part_id');
INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (6,'Providers','Providers','v_Providers','2015-01-01 00:00:00','2015-01-01 00:00:00',TRUE,FALSE,TRUE,TRUE,'provider_id');
INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (7,'Agencies','Agencies','v_Agencies','2015-01-01 00:00:00','2015-01-01 00:00:00',TRUE,FALSE,TRUE,TRUE,'agency_id');
INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (8,'Feedback','Feedback','v_Feedback_Trips_Users','2015-01-01 00:00:00','2015-01-01 00:00:00',TRUE,FALSE,FALSE,FALSE,'feedback_id');


/* Filter Groups */

INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (1,'Services','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (2,'Traveler Eligibility','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (3,'Travelers','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (4,'Trips','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (5,'Itineraries','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (6,'Providers','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (7,'Agencies','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (8,'Traveler Accommodations','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (9,'Trip Desired Modes','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (10,'Traveler Desired Modes','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (11,'Feedback','2015-01-01 00:00:00','2015-01-01 00:00:00');


/* Reporting Specific Filter Groups */
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (1,3,4,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (2,3,9,2,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (3,4,5,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (4,4,3,4,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (5,4,1,5,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (6,5,4,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (7,5,9,2,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (8,2,3,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (9,1,1,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (12,3,3,3,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (13,4,7,6,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (14,5,3,3,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (15,2,2,2,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (16,2,8,3,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (17,3,2,4,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (18,3,8,5,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (19,4,2,7,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (20,4,8,8,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (21,5,2,4,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (22,5,8,5,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (23,3,7,7,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (24,5,7,6,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (25,4,4,2,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (26,4,9,3,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (27,6,6,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (28,7,7,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (29,8,11,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (30,8,4,2,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (31,8,3,3,'2015-01-01 00:00:00','2015-01-01 00:00:00');



/* Reporting Filter Fields */

INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (1,1,31,1,'service_type_id','Service Types','2015-01-01 00:00:00','2015-01-01 00:00:00',2,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (2,1,31,2,'service_provider_id','Provider','2105-01-01 00:00:00','2015-01-01 00:00:00',1,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (3,3,11,NULL,'first_name','First Name','2015-01-01 00:00:00','2015-01-01 00:00:00',2,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (4,3,11,NULL,'last_name','Last Name','2015-01-01 00:00:00','2015-01-01 00:00:00',3,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (5,3,11,NULL,'email','Email Address','2015-01-01 00:00:00','2015-01-01 00:00:00',4,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (6,3,29,NULL,'user_id','User ID','2015-01-01 00:00:00','2015-01-01 00:00:00',1,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (7,1,31,8,'service_id','Service','2015-01-01 00:00:00','2015-04-14 21:46:49.488477',3,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (8,5,29,NULL,'itinerary_id','Itinerary ID','2015-01-01 00:00:00','2015-01-01 00:00:00',1,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (10,4,29,NULL,'trip_id','Trip ID','2015-01-01 00:00:00','2015-01-01 00:00:00',1,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (11,4,11,NULL,'trip_from_address','From Address','2015-01-01 00:00:00','2015-01-01 00:00:00',5,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (12,4,11,NULL,'trip_to_address','To Address','2015-01-01 00:00:00','2015-01-01 00:00:00',6,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (13,4,31,5,'trip_purpose_id','Trip Purpose','2015-01-01 00:00:00','2015-01-01 00:00:00',7,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (17,4,29,NULL,'trip_creation_datetime','Creation Date','2015-01-01 00:00:00','2015-01-01 00:00:00',2,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (18,4,29,NULL,'trip_requested_date','Requested Date','2015-01-01 00:00:00','2015-01-01 00:00:00',3,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (19,4,29,NULL,'trip_requested_time','Requested Time (HH:MM)','2015-01-01 00:00:00','2015-04-15 21:39:08.794507',4,'time');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (24,3,29,NULL,'user_age','Age (##)','2015-01-01 00:00:00','2015-01-01 00:00:00',5,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (25,5,30,9,'itinerary_selected','Itinerary Selected?','2015-01-01 00:00:00','2015-01-01 00:00:00',10,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (28,7,31,10,'agency_id','Agency','2015-01-01 00:00:00','2015-01-01 00:00:00',1,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (29,1,30,9,'service_active','Is Active?','2015-01-01 00:00:00','2015-01-01 00:00:00',4,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (30,6,31,2,'provider_id','Provider','2015-01-01 00:00:00','2015-01-01 00:00:00',1,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (31,11,11,NULL,'feedback_user_email','Email','2015-01-01 00:00:00','2015-01-01 00:00:00',1,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (32,11,31,11,'feedback_type_id','Feedback Type','2015-01-01 00:00:00','2015-01-01 00:00:00',2,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (33,11,31,12,'feedback_status_id','Feedback Status','2015-01-01 00:00:00','2015-01-01 00:00:00',3,NULL);
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (34,11,11,NULL,'feedback_comment','Comment','2015-01-01 00:00:00','2015-01-01 00:00:00',4,NULL);
