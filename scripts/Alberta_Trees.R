
# PRODUCTIVITY AND REPRODUCIBILITY IN ECOLOGY AND EVOLUTION ####
# Rolando Trejo Pérez

### 1. CREATING DIRECTORIES AND INSTALLING R PACKAGES ###

RequiredPackages <- c("dataverse","tibble","dplyr")
for (i in RequiredPackages) { #Installs packages if not yet installed
  if (!require(i, character.only = TRUE)) install.packages(i)}

library("dataverse") # to access to data from dataverse repository
library("tibble") # to see dataframes in tidyverse-form
library("dplyr") 

# 1.1 Check for directory path
getwd()

# 1.2 Create directories
dir.create("data/")
dir.create("scripts/")
dir.create("manuscripts/")

##############################

### 2. DOWNLOAD DATA FROM DATAVERSE (download in 2022-15-09): ###

# Two databases were download from the Seasonal and annual dynamics of western Canadian boreal 
# forest plant communities: a legacy dataset spanning four decades:

# [https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP3/PZCAVE]

# 2.1 Vascular cover from 1980 to 2015

Hondo_VascularCover_1980_2015 <- get_dataframe_by_name(
  filename = "Hondo_VascularCover_1980_2015.tab",
  dataset = "10.5683/SP3/PZCAVE", 
  server = "https://borealisdata.ca/dataverse/ubc")

# 2.2 Soil temperature from 1980 to 2010 

Hondo_SoilTemp_1980_2010 <- get_dataframe_by_name(
  filename = "Hondo_SoilTemp_1980_2010.tab",
  dataset = "10.5683/SP3/PZCAVE", 
  server = "https://borealisdata.ca/dataverse/ubc")

# Save data in folder called data. However, main manipulation will be done using the online data.

path <- "/Users/rolandotrejoperez/Documents/GitHub/Rolando_Trejo_Reproducibility_LDP_2022/data"
    
    write.csv(Hondo_VascularCover_1980_2015, 
              file.path(path, "Hondo_VascularCover_2010.csv"), 
              row.names=FALSE)
    write.csv(Hondo_SoilTemp_1980_2010, 
              file.path(path, "Hondo_SoilTemp_1980_2010.csv"), 
              row.names=FALSE)


##### UNDER CONSTRUCTION ################################################################################

### 3. QUESTION ###
    
    # Does species richness varies along the soil temperature?
          # Let's explore one point over the time. For this purpose we can use 2010 data.
    
### 4. DATA MANIPULATION ###
    
# 3.1. Generate a subset of data considering only 2010 data to simplify the statistical analyses.
    
    Hondo_VascularCover_2010 <- subset(Hondo_VascularCover_1980_2015,
                                  year== "2010" )          # Selecting from one category in rows
    Hondo_SoilTemp_2010 <- subset(Hondo_SoilTemp_1980_2010,
                                  year== "2010" )
# 3.2. Merge Vascular cover and Soil temperature datasets by month, year, stand and quad 
   
    df=inner_join(Hondo_VascularCover_2010, Hondo_SoilTemp_2010, by = c("month","year","stand", "quad"))
View(df)

### 5. MODEL AND GRAPHICS ###

### 6. RESULTS ###

### 7. CONCLUSION ###




