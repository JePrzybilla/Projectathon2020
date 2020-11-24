#Install and load fhircrackr
#install.packages("fhircrackr") #do this only once
library(fhircrackr)
library(dplyr)

#check out vignette for how to use package
vignette(topic = "fhircrackr", package="fhircrackr")


#!!! At the moment this doesnt make much sense because all PCR tests have same dates
#working on getting the test data to have different dates for breakout session on friday

####How many Covid patients per calender week?####

#Download Observations coding SARS-Cov-2 RNA Presence in respiratory specimen
search_request <- "https://mii-agiop-3p.life.uni-leipzig.de/fhir/Observation?code=94500-6" #define search request
bundles <- fhir_search(search_request) #download bundles

#extract attributes
design <- list(
  Observations = list(
    resource = "//Observation",
    cols = list(
      subject = "subject/reference",
      time = "effectiveDateTime",
      result = "valueCodeableConcept/coding/code"
    )
  )
)

dfs <- fhir_crack(bundles, design)

#only keep positive test results
tests <- dfs$Observations
tests <- tests[tests$result =="260373001", ]

#convert time to dateTime object
tests$time <- as.POSIXct(tests$time, format = "%Y-%m-%dT%H:%M:%S")

#remove duplicated Covid tests for every patient, only keep first test
tests <- tests[order(tests$time),] #sort by date
tests <- tests[!duplicated(tests$subject),]# remove all duplicated tests

#build weeks
tests$week <- strftime(tests$time, format = "%V")#convert date to calender week (ISO 8601)

#plot tests per week
library(ggplot2)
p <- ggplot(data=tests, aes(x=week))

p + stat_count(geom="bar") + 
  xlab("Calendar week") + 
  ylab("Number of Covid-19 positive patients")
