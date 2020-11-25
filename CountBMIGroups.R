### How many Patients are there stratified by BMI?###

#Install and load fhircrackr
#install.packages("fhircrackr") #do this only once
library(fhircrackr)
library(dplyr)

#check out vignette for how to use package
vignette(topic = "fhircrackr", package="fhircrackr")


#Download Observations coding for body height
search_request_height <- paste0("https://mii-agiop-3p.life.uni-leipzig.de/fhir/Observation?code=8302-2") #define search request
height_bundles <- fhir_search(search_request_height) #download bundles

#Download Observations coding for body weight
search_request_weight <- paste0("https://mii-agiop-3p.life.uni-leipzig.de/fhir/Observation?code=29463-7") #define search request
weight_bundles <- fhir_search(search_request_weight) #download bundles

#data frame design
design_height <- list(
  Observation = list(
    resource = "//Observation",
    cols = list(
      patient = "subject/reference",
      height = "valueQuantity/value",
      height_unit = "valueQuantity/code"
    )
  )
)

design_weight <- list(
  Observation = list(
    resource = "//Observation",
    cols = list(
      patient = "subject/reference",
      weight = "valueQuantity/value",
      weight_unit = "valueQuantity/code"
    )
  )
)

#flatten resources
dfs_height <- fhir_crack(height_bundles, design_height)
heights <- dfs_height$Observation

dfs_weight <- fhir_crack(weight_bundles, design_weight)
weights <- dfs_weight$Observation

#check that all values have the same unit
unique(heights$height_unit) #one unit is kg, there seems to be a mistake 
heights[heights$height_unit=="kg",] #check which one is wrong
heights <- heights[heights$height_unit=="cm",]#only keep valid heights

unique(weights$unit)#everything is finde


#merge data
data <- full_join(heights, weights, by="patient")

#convert to correct data type
data$height <- as.numeric(data$height)
data$weight <- as.numeric(data$weight)

#compute BMI and weight classes
data$BMI <- data$weight/((data$height/100))^2
data$BMI_class <- cut(data$BMI, 
                      breaks = c(0, 18.5, 25, 30, 35, 40, Inf),
                      labels = c("Underweight", "Normal weight", "Overweight", "Obesity Class 1", "Obesity Class 2", "Obesity Class 3"),
                      right = FALSE)

#display in numbers and plot
table(data$BMI_class)
plot(data$BMI_class)
