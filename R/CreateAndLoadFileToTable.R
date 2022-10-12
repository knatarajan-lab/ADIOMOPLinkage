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
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.

createAndLoadFileToTable <- function(pathToCsv,
                                     sep = ",",
                                     connection,
                                     cohortDatabaseSchema,
                                     createTableFile,
                                     tableName,
                                     targetDialect = "sql server",
                                     oracleTempSchema,
                                     package) {
  #Create table to load data
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = createTableFile,
                                           packageName = package,
                                           dbms = attr(connection, "dbms"),
                                           tempEmulationSchema = oracleTempSchema,
                                           target_database_schema = cohortDatabaseSchema,
                                           tableName = tableName)
  DatabaseConnector::executeSql(connection, sql, progressBar = FALSE, reportOverallTime = FALSE)
  #Load data from csv file
  data <- read.csv(file = pathToCsv, sep = sep)
  #Construct the values to insert
  # paste0(apply(head(data), 1, function(x) paste0("('", paste0(x, collapse = "', '"), "')")), collapse = ", ")
  #batch load the rows
  chunk <- 1000
  n <- nrow(data)
  r <- rep(1:ceilling(n / chunk), each = chunk)[1:n]
  d <- split(data, r)

  for (i in d) {
    values <- paste0("(", apply(apply(i, 1, function(x) paste0("'", x, "'")), 2, function(x) paste0(x, collapse = ", ")), ")", collapse=",")
    sql <- paste0("INSERT INTO @target_database_schema.@table_name VALUES ", values, ";")
    renderedSql <- SqlRender::render(sql = sql, target_database_schema = cohortDatabaseSchema, table_name = tableName)
    insertSql <- SqlRender::translate(renderedSql, targetDialect = targetDialect)
    DatabaseConnector::executeSql(connection, insertSql)
    }
  }
