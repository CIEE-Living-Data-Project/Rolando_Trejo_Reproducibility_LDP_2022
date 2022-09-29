
# PRODUCTIVITY AND REPRODUCIBILITY IN ECOLOGY AND EVOLUTION ####
# Proyect: Reproducibility mini project: Alberta trees
# Rolando Trejo Pérez
# Institut de recherche en biologie végétale, Université de Montréal

### 1. CREATING DIRECTORIES AND INSTALLING R PACKAGES ###

RequiredPackages <- c("dataverse","tibble","dplyr","ggplot2","mgcv","cowplot")
for (i in RequiredPackages) { #Installs packages if not yet installed
  if (!require(i, character.only = TRUE)) install.packages(i)}

library("dataverse") # To access to data from dataverse repository
library("tibble") # To see data frames in tidyverse-form
library("dplyr") # To solve the most common data manipulation challenges
library("ggplot2") # To data visualization
library("mgcv") # To estimate penalized Generalized Linear models including 
                #Generalized Additive Models and Generalized Additive Mixed Models
library("cowplot") # To creat publication-quality figures

# 1.1 Check for directory path

getwd()

# 1.2 Create directories

dir.create("data/")
dir.create("scripts/")
dir.create("manuscripts/")
dir.create("images/")

##############################

### 2. DOWNLOAD DATA FROM DATAVERSE (download in 2022-15-09): ###

# Two databases were downloaded from the Seasonal and annual dynamics of western 
# Canadian boreal forest plant communities: a legacy dataset spanning four decades:

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

# It saves data in folder called data. However, main manipulation will be done using 
# the online data.
# If you want to save the data in your local computer, run this code in your 
# computer establishing your path as directory.

# FROM HERE
# path <- "/Users/rolandotrejoperez/Documents/GitHub/Rolando_Trejo_Reproducibility_LDP_2022/data"
    
#    write.csv(Hondo_VascularCover_1980_2015, 
#              file.path(path, "Hondo_VascularCover_2010.csv"), 
#              row.names=FALSE)
#    write.csv(Hondo_SoilTemp_1980_2010, 
#              file.path(path, "Hondo_SoilTemp_1980_2010.csv"), 
#              row.names=FALSE)
# TO HERE

##### MANUSCRIPT ################################################################################

### 3. INTRODUCTION ###
    
# This mini reproducibility project was built using rescued data by Amelia Hesketh, Jenna Loesberg, 
# Ellen Bledsoe, Justine Karst,and Ellen Macdonald in 2021 from an Alberta legacy dataset 
# spanning four decades (1980-2015). 
# Dataset is available in [Borealis](https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP3/PZCAVE).
    
# A very simple model is explored in this reproducible project: Does species richness varies 
# along the soil temperature?
# For this purpose i only use 2010 data.
    
# This mini project was created with the open-source software R. Packages used were 
# dataverse,tibble,dplyr,ggplot2, and mgcv.

### 4. DATA MANIPULATION ###
    
# 4.1. Generate a subset of data considering only 2010 data to simplify the statistical analyses.
    
    Hondo_VascularCover_2010 <- subset(Hondo_VascularCover_1980_2015,
                                  year== "2010" )          # Selecting from one category in rows
    Hondo_SoilTemp_2010 <- subset(Hondo_SoilTemp_1980_2010,
                                  year== "2010" )
# 4.2. Merge Vascular cover and Soil temperature datasets by month, year, stand and quad 
   
    df=inner_join(Hondo_VascularCover_2010, Hondo_SoilTemp_2010, by = c("month","year","stand", "quad"))

# 4.3 It creates a subset ob non-binary data

df_non_binary <- subset(df,select = c(stand, month,year,date,quad,temp_C))

#  It creates a subset of binary data: abundances needs to be transformed into 0 and 1 
# in order to count the species richness in each row.

df_species <- subset(df,select = c(-stand, -month,-year,-date,-temp_C))

# It transforms abundances into 0 and 1

df_binary <- data.frame(df_species[1], (df_species[-1] > 0) * 1)

# It merges the non binary data, soil temperature, and species abundances transformed into 0 and 1.

df_trans <- data.frame(df_non_binary,df_binary)

# It sums the number of species in each row

df_trans$species_no <- rowSums( df_trans[,8:221] )

# It create the final table version: it includes only the species richness and soil temperature

Species_Temp <- subset(df_trans,select = c(species_no,temp_C))

### 5. DATA ANALYSIS ###

# Species richness as function of soil temperature (C)

M1 <- lm(species_no ~ temp_C,data = Species_Temp) 

# Residuals and coefficients of the model

(summ_M1 <- summary(M1)) #

# Linear model or not?

library(mgcv)

# The following code provides a linear and non-linear model approach:

linear_model <- gam(species_no  ~ temp_C, data = Species_Temp)
smooth_model <- gam(species_no  ~ s(temp_C), data = Species_Temp)

# AIC can be used to compare the linear and non-linear model. We must choose the lowest value.

AIC(linear_model, smooth_model)

# Visualization

library(ggplot2)

# It graphs the linear model (species richness vs soil temperature) using ggplot2

Linear<-ggplot(Species_Temp, aes(x = temp_C, y = species_no )) +
  geom_point() +
  geom_line(colour = "red", size = 1.2,
            aes(y = fitted(linear_model))) +
  xlab("Soil temperature (C)") +
  ylab("Species richness") +
  labs(title = "A) Linear model line")+
  theme_bw()

Linear

# It graphs the non-linear model (species richness vs soil temperature) using ggplot2

Non_linear<-ggplot(Species_Temp, aes(x = temp_C, y = species_no )) +
  geom_point() +
  xlab("Soil temperature (C)") +
  ylab("Species richness") +
  labs(title = "B) Smooth model curve")+
  geom_line(colour = "blue", size = 1.2,
            aes(y = fitted(smooth_model))) +
  theme_bw()

Non_linear

library(cowplot)
plot_grid(Linear,Non_linear, labels = "") #"AUTO"

### 6. RESULTS ###

# A higher species richness is linked to a lower soil temperature according to this 
#simple linear model. We can also see that linearity is supported by these data. 
# However, this is just a model considering soil temperature as the only predictor. 
# Other variables must be considered to search if it is a real observed trend. 
# See more detail in the 
# [Living Data Tutorials](https://living-data-tutorials.github.io/website/)

### 7. CONCLUSION ###

# The code used here in this mini reproducibility project can be used as guide through 
#the creation and management of a fully reproducible manuscript using RMarkdown and Rstudio.

### 8. REFERENCES ###

# Hesketh, A., Loesberg, J., Bledsoe, E., Karst, J., & Macdonald, E. (2021). Seasonal and 
# annual dynamics of western Canadian boreal forest plant communities: A legacy dataset 
# spanning four decades [Data set]. Scholars Portal Dataverse. 
# https://doi.org/10.5683/SP3/PZCAVE