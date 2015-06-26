DELETE FROM reporting_specific_filter_groups;
DELETE FROM reporting_filter_fields;
DELETE FROM reporting_lookup_tables;
DELETE FROM reporting_filter_groups;
DELETE FROM reporting_reports;
DELETE FROM reporting_filter_types;


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



INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (1,'v_Service_Types','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id','');
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (2,'providers','name','2015-01-01 00:00:00','2015-04-17 14:36:10.112449','id','provider');
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (3,'v_Characteristics','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id','');
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (4,'v_Accommodations','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id','');
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (5,'v_Trip_Purposes','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id','');
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (6,'v_Trip_Statuses','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id','');
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (7,'v_Modes','_en','2015-01-01 00:00:00','2015-01-01 00:00:00','id','');
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (8,'services','name','2015-01-01 00:00:00','2015-04-17 16:19:29.127294','id','service');
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (9,'boolean_lookup','name','2015-01-01 00:00:00','2015-01-01 00:00:00','id','');
INSERT INTO reporting_lookup_tables(id, name, display_field_name, created_at, updated_at, id_field_name, data_access_type)
    VALUES (10,'agencies','name','2015-01-01 00:00:00','2015-01-01 00:00:00','id','agency');



INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (1,'Services','Defined Services','v_Services','2015-01-01 00:00:00','2015-01-01 00:00:00',TRUE,TRUE,FALSE,FALSE,'Service_ID');
INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (2,'Users','All Users','v_Users','2015-04-13 19:43:49.036979','2015-04-13 20:21:41.785259',TRUE,FALSE,FALSE,FALSE,'User_ID');
INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (3,'Trip-Travelers','Trip Travelers','v_Trips_Users','2015-01-01 00:00:00','2015-04-15 16:15:21.475268',TRUE,FALSE,TRUE,TRUE,'Trip_ID');
INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (4,'Itineraries-Travelers','Itineraries displayed to Travelers ','v_Itineraries_Users','2015-01-01 00:00:00','2015-01-01 00:00:00',TRUE,TRUE,TRUE,TRUE,'Itinerary_ID');
INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (5,'Trip Parts-Travelers','Trip Parts Travelers','v_Trip_Parts_Users','2015-01-01 00:00:00','2015-01-01 00:00:00',TRUE,FALSE,TRUE,TRUE,'id');
INSERT INTO reporting_reports(id, name, description, data_source, created_at, updated_at, is_sys_admin, is_provider_staff, is_agency_admin, is_agent, primary_key)
    VALUES (7,'Trip Surveys','Trip Surveys','v_Trip_Surveys','2015-01-01 00:00:00','2015-01-01 00:00:00',TRUE,FALSE,FALSE,FALSE,'id');



INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (1,'Provider and Services','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (2,'Eligibility and Accommodations','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (3,'Travelers','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (4,'Trips','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (5,'Itineraries','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (6,'Trip Parts','2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_filter_groups(id, name, created_at, updated_at)
    VALUES (7,'Agencies','2015-01-01 00:00:00','2015-01-01 00:00:00');



INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (1,1,31,1,'Service_Type_ID','Service Types','2015-01-01 00:00:00','2015-01-01 00:00:00',2,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (2,1,31,2,'provider_id','Provider','2105-01-01 00:00:00','2015-01-01 00:00:00',1,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (3,3,11,NULL,'first_name','First Name','2015-01-01 00:00:00','2015-01-01 00:00:00',2,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (4,3,11,NULL,'last_name','Last Name','2015-01-01 00:00:00','2015-01-01 00:00:00',3,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (5,3,11,NULL,'email','Email Address','2015-01-01 00:00:00','2015-01-01 00:00:00',4,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (6,3,29,NULL,'User_ID','User ID','2015-01-01 00:00:00','2015-01-01 00:00:00',1,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (7,1,31,8,'Service_ID','Service','2015-01-01 00:00:00','2015-04-14 21:46:49.488477',3,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (8,5,29,NULL,'Itinerary_ID','Itinerary ID','2015-01-01 00:00:00','2015-01-01 00:00:00',1,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (10,4,29,NULL,'Trip_ID','Trip ID','2015-01-01 00:00:00','2015-01-01 00:00:00',1,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (11,4,11,NULL,'From_Address','From Address','2015-01-01 00:00:00','2015-01-01 00:00:00',5,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (12,4,11,NULL,'To_Address','To Address','2015-01-01 00:00:00','2015-01-01 00:00:00',6,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (13,4,31,5,'Trip_Purpose_ID','Trip Purpose','2015-01-01 00:00:00','2015-01-01 00:00:00',7,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (14,5,11,NULL,'From_Address','From Address','2015-01-01 00:00:00','2015-01-01 00:00:00',6,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (15,5,11,NULL,'To_Address','To Address','2015-01-01 00:00:00','2015-01-01 00:00:00',7,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (16,5,30,9,'is_return_trip','Is Return Trip?','2015-01-01 00:00:00','2015-01-01 00:00:00',8,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (17,4,29,NULL,'Creation_DateTime','Creation Date','2015-01-01 00:00:00','2015-01-01 00:00:00',2,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (18,4,29,NULL,'Requested_Date','Requested Date','2015-01-01 00:00:00','2015-01-01 00:00:00',3,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (19,4,29,NULL,'Requested_Time','Requested Time (HH:MM)','2015-01-01 00:00:00','2015-04-15 21:39:08.794507',4,'time');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (20,5,29,NULL,'Creation_DateTime','Creation Date','2015-01-01 00:00:00','2015-01-01 00:00:00',3,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (21,5,29,NULL,'Requested_Date','Requested Date','2015-01-01 00:00:00','2015-01-01 00:00:00',4,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (22,5,29,NULL,'Requested_Time','Requested Time (HH:MM)','2015-01-01 00:00:00','2015-01-01 00:00:00',5,'time');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (24,3,29,NULL,'user_age_name','Age (##)','2015-01-01 00:00:00','2015-01-01 00:00:00',5,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (25,5,30,9,'selected','Itinerary Selected?','2015-01-01 00:00:00','2015-01-01 00:00:00',10,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (26,6,29,NULL,'Trip_ID','Trip ID','2015-01-01 00:00:00','2015-01-01 00:00:00',1,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (27,5,29,NULL,'Trip_ID','Trip ID','2015-01-01 00:00:00','2015-01-01 00:00:00',2,'');
INSERT INTO reporting_filter_fields(id, reporting_filter_group_id, reporting_filter_type_id, reporting_lookup_table_id, name, title, created_at, updated_at, sort_order, value_type)
    VALUES (28,7,31,10,'agency_id','Agency','2015-01-01 00:00:00','2015-01-01 00:00:00',1,'');



INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (1,3,4,1,'2015-04-14 21:29:39.247797','2015-04-14 21:41:09.669575');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (2,3,3,2,'2015-04-14 21:29:39.27586','2015-04-14 21:29:39.27586');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (3,4,5,1,'2015-04-14 21:29:39.27935','2015-04-14 21:29:39.27935');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (4,4,3,2,'2015-04-14 21:29:39.287619','2015-04-14 21:29:39.287619');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (5,4,1,3,'2015-04-14 21:29:39.295299','2015-04-14 21:29:39.295299');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (6,5,4,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (7,5,3,2,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (8,2,3,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (9,1,1,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (10,6,4,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (11,6,3,2,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (12,3,7,3,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (13,4,7,4,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (15,5,7,5,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (16,7,3,1,'2015-01-01 00:00:00','2015-01-01 00:00:00');
INSERT INTO reporting_specific_filter_groups(id, reporting_report_id, reporting_filter_group_id, sort_order, created_at, updated_at)
    VALUES (17,7,4,2,'2015-01-01 00:00:00','2015-01-01 00:00:00');
