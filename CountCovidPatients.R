#Install and load fhircrackr
#install.packages("fhircrackr") #do this only once
library(fhircrackr)
library(dplyr)

#check out vignette for how to use package
vignette(topic = "fhircrackr", package="fhircrackr")



####How many Covid-19 patients?####

#Download Observations coding SARS-Cov-2 RNA Presence in respiratory specimen
search_request <- "https://mii-agiop-3p.life.uni-leipzig.de/fhir/Observation?code=94500-6" #define search request
bundles <- fhir_search(search_request) #download bundles

#extract all attributes if you need an overview
design1 <- list(
  Observations = list(
    
    resource = "//Observation", #define resource type
    
    style = list( #define style for dealing with multiple entries
      sep = " | ",
      brackets = c("[", "]")
    )
  )
)

dfs1 <- fhir_crack(bundles, design1)
View(dfs1$Observations)

#Alternative: extract only attributes ones we need
design2 <- list(
  Observations = list(
    
    resource = "//Observation", #define resource type
    
    cols = list( #only extract certain attributes
      subject = "subject/reference",
      result = "valueCodeableConcept/coding/code"
    )
    
  )
)

dfs2 <- fhir_crack(bundles, design2)
View(dfs2$Observations)

#only keep positive results
tests <- dfs2$Observations
tests <- tests[tests$result=="260373001",]

#count the unique Patient references in this set
length(unique(tests$subject))




