# Make sure to install all dependencies (not needed if already done):
# install.packages("devtools")
# library(devtools)
# install_github("ohdsi/SqlRender")
# install_github("ohdsi/DatabaseConnector")
# install.packages("dplyr")
# install.packages("readr")
# install.packages("sqldf")
# install.packages("tidyr")
# install.packages("sf")
# install.packages("tigris")
# install.packages("tidyverse")
# install.packages("mapview")

# Sys.setenv("DATABASECONNECTOR_JAR_FOLDER" = "c:/temp/jdbcDrivers")
# DatabaseConnector::downloadJdbcDrivers("sql server")

# Load the package
library(ADIOMOPLinkage)

path <- ''

# Minimum cell count when exporting data:
minCellCount <- 10

# Details for connecting to the server:
conn <- DatabaseConnector::connect(
  dbms = "sql server",
  server = ""
  )

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "sql server",
  server = "",
  port = 1433)


# Details specific to the database:
db <- "ohdsi_cumc_2021q2r1"
cdmDatabaseSchema <- paste0(db,".dbo") # schema for your CDM instance -- e.g. full_201911_omop_v5
resultsDatabaseSchema <- paste0(db,".results") # schema with write privileges
vocabularyDatabaseSchema <- paste0(db,".dbo") #schema where your CDM vocabulary is located
geo_db <- "ohdsi_cumc_2022q2r1"
geocodedLocationSchema <- paste0(geo_db, ".dbo")
cohortTable <- "cancer_cohorts"
cohortDatabaseSchema <- paste0(db,".results")

# Use this to run the study package. To view the results, one can go to the specified output folder.
# There you will see a folder for each cancer (breast, prostate, lung and multiple myeloma).
# Within each folder, there is a data and plots folder. The data folder contains aggregate counts
# that were used to generate the plots.

# Pre-configuration for tigris library to look for the downloaded shapefiles in cache folder to avoid duplicate downloading
# Set the tiger shapefiles year to 2021
options(tigris_use_cache = TRUE)
options(tigris_year = 2021)
ADI_RANK_LEVEL = "ADI_NATRANK"


subject_table <- LinkLocToCensusBG(connectionDetails = connectionDetails,
             cdmDatabaseSchema = cdmDatabaseSchema,
             cohortDatabaseSchema = resultsDatabaseSchema,
             cohortTable = cohortTable,
             geocodedLocationSchema = geocodedLocationSchema
             )

subject_with_ADI <- LinkToADI(subject_table,
                              "ADIOMOPLinkage",
                              ",")
median_adi_data <- MedianADICounty(subject_with_ADI = subject_with_ADI,
                                   ADI_RANK_LEVEL = ADI_RANK_LEVEL)
CreateViz(median_adi_data,
          county_level_agg = TRUE,
          ADI_RANK_LEVEL = ADI_RANK_LEVEL)




