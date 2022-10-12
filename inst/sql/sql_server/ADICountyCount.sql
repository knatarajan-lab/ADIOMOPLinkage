SELECT
  cohort_definition_id,
  COUNTY_NAME,
  STATE_NAME,
CASE WHEN COUNT(DISTINCT person_id) > @minCellCount THEN STR(COUNT(DISTINCT person_id))
ELSE CONCAT('<=', STR(@minCellCount))
  END AS person_count
FROM @cohort_database_schema.@table_name
GROUP BY cohort_definition_id, STATE_NAME, COUNTY_NAME
