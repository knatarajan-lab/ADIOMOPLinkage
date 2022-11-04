# @file CreateViz.R
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


CreateViz <- function(median_adi_data,
                      county_level_agg,
                      ADI_RANK_LEVEL){
  if(county_level_agg){
    county_data <- tigris::counties(cb = TRUE)
    data <- sf::st_join(county_data, median_adi_data, left = TRUE)
  }
  mapview::mapview(data,
                   zcol = "MEDIAN_ADI_RANK",
                   layer.name = paste0("MEDIAN_", ADI_RANK_LEVEL)
                   )

}

