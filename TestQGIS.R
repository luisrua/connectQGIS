##### TEST HOW TO USE QGIS TOOLS DIRECTLY FROM R ####
# Luis de la Rua == Jan 2024


# LIBRARIES WE NEED ----

# install.packages("remotes")
# remotes::install_github("paleolimbot/qgisprocess")
library(qgisprocess) # Use QGIS from R
library(sf) 
library(httr) # to unzip
# remotes::install_github("dickoa/rhdx")
library(rhdx)
library(tidyverse)


# ---- LIBRARY qgisprocess ----

# qgis_path() path to access QGIS API.
# qgis_version() QGIS version.
# qgis_providers() list of providers and number of algorithms available
# qgis_algorithms() info about the algorithms avaialable

# In case R does not detect access path to API - example
# options(qgisprocess.path = "/Applications/QGIS-LTR.app/Contents/MacOS/bin/qgis_process")

# Smart search for algorithms - containing a word. 
tools <- qgis_algorithms()
grep("buffer", tools$algorithm, value=T)

# Check help from QGIS algorithm 
qgis_show_help("native:buffer")


# ---- LOAD RANDOM DATA FROM HDX ----
# Use rdhx library to explore and download data info in "https://dickoa.gitlab.io/rhdx/"

# The first step is usually to connect to HDX using the set_rhdx_config function and check the config using get_rhdx_config
set_rhdx_config(hdx_site = "prod")
get_rhdx_config()

# Make some search using tags
search_datasets("Fiji Health OSM") %>% 
  pluck(5) %>% ## select the index of the dataset we are looking for
  get_resource(1) %>% ## pick the first resource
  read_resource() ## read this HXLated data into R

# Pull dataset from HDX now that we know the name of the specific dataset we are looking for
hf <- pull_dataset("hotosm_fji_west_health_facilities") %>% 
      get_resource(1) %>% 
      read_resource()

plot(hf)
# CRS of this dataset
st_crs(hf)
# Reproject to projected CRS
hf <- st_transform(hf, 3460)

# ---- GENERATE BUFFER AROUND HEALTH FACILITIES ----
# USING NATIVE FUNCTION ----
# Output path
temp <- file.path(tempdir(),"hf_bf100.gpkg")

# Execute algorithm
qgis_run_algorithm(
  algorithm = "native:buffer",
  INPUT = hf,
  DISTANCE = 100,
  OUTPUT = temp
)

# Read output
hf_buff <- st_read(temp)
plot(hf_buff)

# USING NO NATIVE ALGORITHM
qgis_show_help("gdal:buffervectors")

temp2 <- file.path(tempdir(),"hf_bf100_2.gpkg")

# Execute algorithm
qgis_run_algorithm(
  algorithm = "gdal:buffervectors",
  INPUT = hf,
  GEOMETRY = "geometry",
  DISTANCE = 100,
  OUTPUT = temp2
)
