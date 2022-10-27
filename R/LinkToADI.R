# @file LinkToADI.R
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


LinkToADI <- function(subject_sp_table,
                      package,
                      sep) {
  pathToADI <- system.file("settings", "US_2020_ADI_Census_Block_Group_v3.2.csv", package = package)
  ADI_data <- read.csv(file = pathToADI, sep = sep, colClasses=c("FIPS"="character"))
  subject_with_ADI <- merge(x = subject_sp_table, y = ADI_data,
                            by.x = c("GEOID"),
                            by.y = c("FIPS"),
                            all.x = TRUE)
  return(subject_with_ADI)
}



MedianADICounty <- function(subject_with_ADI,
                            ADI_RANK_LEVEL) {
  if(ADI_RANK_LEVEL == 'ADI_NATRANK'){
    subject_with_ADI_num <- subject_with_ADI[!is.na(as.numeric(as.character(subject_with_ADI$ADI_NATRANK))),]
    subject_with_ADI_num$ADI_NATRANK <- as.numeric(subject_with_ADI_num$ADI_NATRANK)
    median_adi_county_data <- subject_with_ADI_num %>%
      group_by(COUNTYFP) %>%
      summarise(MEDIAN_ADI_RANK = median(ADI_NATRANK))
  }
  else if(ADI_RANK_LEVEL == 'ADI_STATERNK'){
    subject_with_ADI_num <- subject_with_ADI[!is.na(as.numeric(as.character(subject_with_ADI$ADI_STATERNK))),]
    subject_with_ADI_num$ADI_STATERNK <- as.numeric(subject_with_ADI_num$ADI_STATERNK)
    median_adi_county_data <- subject_with_ADI_num %>%
      group_by(COUNTYFP) %>%
      summarise(MEDIAN_ADI_RANK = median(ADI_STATERNK))
  }
  return(median_adi_county_data)
}
