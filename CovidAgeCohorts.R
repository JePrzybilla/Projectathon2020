#Install and load fhircrackr
#install.packages("fhircrackr") #do this only once
library(fhircrackr)
library(dplyr)

#check out vignette for how to use package
vignette(topic = "fhircrackr", package="fhircrackr")



####How many Covid Patients are there stratified by 10-year age cohorts?####

#Download Observations coding SARS-Cov-2 RNA Presence in respiratory specimen and include Patient resources
search_request <- paste0("https://mii-agiop-3p.life.uni-leipzig.de/fhir/Observation?code=94500-6",
                         "&_include=Observation:patient") #define search request

bundles <- fhir_search(search_request) #download bundles

#extract attributes
design <- list(
  
  Observations = list(
    resource = "//Observation",
    cols = list(
      subject = "subject/reference",
      result = "valueCodeableConcept/coding/code",
      time = "effectiveDateTime"
    )
  ),
  
  Patients = list(
    resource = "//Patient", 
    cols = list(
      id = "id", 
      birthDate = "birthDate"
    )
  )
)

dfs <- fhir_crack(bundles, design)

#find patients with positive test result 
tests <- dfs$Observations
tests <- tests[tests$result=="260373001",] #only positive tests

tests$pat_id <- sub(pattern = "Patient/", replacement = "", tests$subject) #remove Patient/ prefix from patient references

#convert time to dateTime object
tests$time <- as.POSIXct(tests$time, format = "%Y-%m-%dT%H:%M:%S")

#remove duplicated Covid tests for every patient, only keep first test
tests <- tests[order(tests$time),] #sort by date
tests <- tests[!duplicated(tests$subject),]# remove all duplicated tests

#keep only patients with positive test result in patient data frame
patients <- dfs$Patients
patients <- patients[patients$id %in% tests$pat_id,]

#compute age at first positive covid test:
full <- left_join(patients, tests, by= c("id"= "pat_id"))
age <- round(as.numeric((as.Date(full$time) - as.Date(full$birthDate)))/365.25,0)

#compute and tabulate/plot age groups
age_groups <- cut(age, breaks = seq(0,110,by=10))
table(age_groups)

hist(age, breaks = seq(0,110,by=10))


