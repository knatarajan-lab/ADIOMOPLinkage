{DEFAULT @table_name = "location_geocode_bg_adi"}

IF OBJECT_ID('@target_database_schema.@table_name', 'U') IS NOT NULL
DROP TABLE @target_database_schema.@table_name;

IF OBJECT_ID('@target_database_schema.address_geocoded', 'U') IS NULL
BEGIN CREATE TABLE @target_database_schema.address_geocoded (
        location_id INT,
        FIPS_BG_ID VARCHAR(12),
        COUNTY_NAME VARCHAR(100),
        STATE_NAME VARCHAR(100)
    )
END;

--- The following query generates the address_geocoded table from GIS postgres database @geomdb using geocoding tool https://github.com/OHDSI/GIS. It needs to be loaded into @target_database_schema.address_geocoded.
/*
SELECT
  addresses_to_geocode.location_id,
  bg.bg_id AS fips_block_group_id,
  county.namelsad AS county_name,
  state.name AS state_name
FROM @geomdb.public.address_to_geocode
LEFT OUTER JOIN @geomdb.tiger.bg
  ON
    ST_WITHIN(addresses_to_geocode.the_geom, bg.the_geom)
LEFT OUTER JOIN @geomdb.tiger.county
  ON
    ST_WITHIN(addresses_to_geocode.the_geom, county.the_geom)
INNER JOIN @geomdb.tiger.state
  ON
    state.statefp = county.statefp
WHERE
  rating >= 0
AND bg.bg_id IS NOT NULL;
*/

CREATE TABLE @target_database_schema.@table_name
(
person_id INT,
location_id INT,
cohort_definition_id INT,
FIPS_BG_ID VARCHAR(12),
COUNTY_NAME VARCHAR(100),
STATE_NAME VARCHAR(100),
ADI_STATERNK VARCHAR(20),
ADI_NATRANK VARCHAR(20)
);

INSERT INTO @target_database_schema.@table_name
SELECT
  p.person_id,
  l.location_id,
  cc.cohort_definition_id,
  adi.FIPS AS FIPS_BG_ID,
  ag.COUNTY_NAME,
  ag.STATE_NAME,
  adi.ADI_STATERNK,
  adi.ADI_NATRANK
FROM
  @target_database_schema.@cohort_table AS cc
INNER JOIN
  @cdm_database_schema.person AS p
ON
  cc.subject_id = p.person_id
INNER JOIN
  @cdm_database_schema.location as l
ON
  p.location_id = l.location_id
INNER JOIN
  @target_database_schema.address_geocoded AS ag --this is the table loaded from the gis database
ON
  l.location_id = ag.location_id
INNER JOIN
  @target_database_schema.@adi_data AS adi
ON ag.FIPS = adi.FIPS;
