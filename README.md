# ADIOMOPLinkage

## Introduction

ADIOMOPLinkage is an R package for building the linkage between Area Deprivation Index data and OMOP Common Data Model.

2020 ADI data is downloaded from [Neighborhood Atlas](https://www.neighborhoodatlas.medicine.wisc.edu/) with block group FIPS code as primary key.

## Workflow

![ADIOMOPLinkage Workflow](images/ADI_architecture.svg)

## System Requirements

-   A location table with Latitude and Longitude data. [ArcGIS Pro](https://pro.arcgis.com/en/pro-app/latest/get-started/introducing-arcgis-pro.htm), [DeGAUSS](https://degauss.org/) and [OHDSI GIS](https://github.com/OHDSI/GIS) can be used to geocode the location table on-prem. Please note ArcGIS Pro requires license purchased.

-   A database in [Common Data Model version 5](https://ohdsi.github.io/CommonDataModel/cdm53.html) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, Google BigQuery, or Microsoft APS.

-   R version 4.2.1 or newer. R environment set up could follow [OHDSI HADES Guide](https://ohdsi.github.io/Hades/rSetup.html).

-   A cohort table could be provided to run the ADI linkage and visualizations.

## Getting Started

1.  Install and load the package dependencies in `R`

    ``` r
    install.packages("devtools")
    library(devtools)
    install_github("ohdsi/SqlRender")
    install_github("ohdsi/DatabaseConnector")
    install.packages("dplyr")
    install.packages("readr")
    install.packages("sqldf")
    install.packages("tidyr")
    install.packages("sf")
    install.packages("tigris")
    install.packages("tidyverse")
    install.packages("mapview")

    library("dplyr")
    library("readr")
    library("sqldf")
    library("tidyr")
    library("sf")
    library("tigris")
    library("tidyverse")
    library("mapview")
    ```

2.  Download the database jdbc driver

    ``` r
    Sys.setenv("DATABASECONNECTOR_JAR_FOLDER" = "c:/temp/jdbcDrivers")
    DatabaseConnector::downloadJdbcDrivers("sql server")
    ```

3.  Use `devtools` to install and load OMOPADILinkage package

    ``` r
    devtools::install_github("https://github.com/knatarajan-lab/ADIOMOPLinkage.git")
    library(ADIOMOPLinkage)
    ```

4.  Execute the study by tailoring the code and modifying the parameters

    ``` r
    # absolute path to this study
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
    db <- "2022q2r1"
    cdmDatabaseSchema <- paste0(db,".dbo") # schema for your CDM instance -- e.g. full_201911_omop_v5
    resultsDatabaseSchema <- paste0(db,".results") # schema with write privileges
    vocabularyDatabaseSchema <- paste0(db,".dbo") #schema where your CDM vocabulary is located
    geo_db <- "2022q2r1"
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
    ```

5.  The map visualization will show up in the Viewer tab

## Support

Please feel free to create an issue in the github page and the author will respond to you.

## Reference

1.Kind AJH, Buckingham W. Making Neighborhood Disadvantage Metrics Accessible: The Neighborhood Atlas. New England Journal of Medicine, 2018. 378: 2456-2458. DOI: 10.1056/NEJMp1802313. PMCID: PMC6051533.

2.University of Wisconsin School of Medicine and Public Health. {2020} Area Deprivation Index {v3.2}. Downloaded from <https://www.neighborhoodatlas.medicine.wisc.edu/> Nov 4, 2022

3\. <https://walker-data.com/census-r/census-geographic-data-and-applications-in-r.html>

## License

OMOPADILinkage is licensed under Apache License 2.0

## Development

OMOPADILinkage is being developed in R Studio.
