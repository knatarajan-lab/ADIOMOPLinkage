{DEFAULT @table_name = "adi_data"}

IF OBJECT_ID('@target_database_schema.@table_name', 'U') IS NOT NULL
DROP TABLE @target_database_schema.@table_name;

CREATE TABLE @target_database_schema.@table_name
( OBJECTID int,
	GISJOIN varchar(15),
	ADI_NATRANK varchar(10),
	ADI_STATERNK varchar(10),
	FIPS varchar(12)
)
