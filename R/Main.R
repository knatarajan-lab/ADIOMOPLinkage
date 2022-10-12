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


#' Execute the package to load ADI into the cohort database and link data with your cohort result
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param cohortDatabaseSchema Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param cohortTable          The name of the table that hold the cohorts created from previous studies.
#'                             which will be linked with ADI data.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param loadADI              Does ADI data need to be loaded from the package into database?
#' @param geocodedLocation     Is your location data geocoded with Census Block Group FIPS available to run ADI?
#' @param geocodedLocationTable The name of the table that hold the geocoded location and Census Block Group FIPS.
#' @param createViz            Generate map visualizations through package?
#' @param minCellCount         The minimum number of subjects contributing to a count before it can be shown
#'                             on the maps.

execute -> function(connectionDetails,
                    cdmDatabaseSchema,
                    cohortDatabaseSchema,
                    cohortTable,
                    oracleTempSchema,
                    outputFolder,
                    loadADI = TRUE,
                    geocodedLocation = TRUE,
                    geocodedLocationTable,
                    createViz = TRUE,
                    minCellCount = 10) {
  connection <- DatabaseConnector::connect(connectionDetails)
  ParallelLogger::logInfo("Database connected")
  #create table for hosting ADI
  if (loadADI) {
    ParallelLogger::logInfo("Load ADI data")
    print(paste0("package: ", package))
    ParallelLogger::logInfo("Loading ADI Data")
    pathToCsv <- system.file("settings", "US_2020_ADI_Census_Block\ Group_3.2.csv", package = package)
    createAndLoadFileToTable(pathToCsv,
                             sep = ",",
                             connection,
                             cohortDatabaseSchema,
                             createTableFile = "CreateADITable.sql",
                             tableName = "adi_data",
                             targetDialect = attr(connection, "dbms"),
                             oracleTempSchema,
                             package)
  if (geocodedLocation) {
    ADICohortBuild(connection, cohortDatabaseSchema, cdmDatabaseSchema, cohortTable, outputFolder, minCellCount)
#  if (creatViz) {

#  }
  }
  }

}
