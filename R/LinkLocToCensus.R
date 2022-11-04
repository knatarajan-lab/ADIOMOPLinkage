# @file LinkLocToCensus.R
# Copyright 2022 Observational Health Data Sciences and Informatics
#
# This file is part of ADIOMOPLinkage
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


LinkLocToCensusBG <- function(connectionDetails,
                         cdmDatabaseSchema,
                         cohortDatabaseSchema,
                         cohortTable,
                         geocodedLocationSchema){
  connection <- DatabaseConnector::connect(connectionDetails)
  query <- "SELECT ct.subject_id, ct.cohort_definition_id, l.latitude, l.longitude
            FROM @cohortDatabaseSchema.@cohortTable ct
            JOIN @cdmDatabaseSchema.person p
            ON ct.subject_id = p.person_id
            JOIN @geocodedLocationSchema.location_geocoded l
            ON p.location_id = l.location_id"
  query <- SqlRender::render(sql = query,
                                     cohortDatabaseSchema = cohortDatabaseSchema,
                                     cohortTable = cohortTable,
                                     cdmDatabaseSchema = cdmDatabaseSchema,
                                     geocodedLocationSchema = geocodedLocationSchema
                                     )
  subject_table <- DatabaseConnector::querySql(connection, query)
  subject_sf <- subject_table %>%
    drop_na() %>%
    st_as_sf(coords = c("LONGITUDE", "LATITUDE"), crs = 4269)
  bg_data <- tigris::block_groups(cb = TRUE)
  subject_sp_join <- sf::st_join(subject_sf, bg_data, left = TRUE, join = st_within)
  return(subject_sp_join)
}

