# Title     : read_blood_pressure_ex1.R
# Objective : reads blood pressure data
# authors: Thomas Peschel and Jens Przybilla 
# Created by: Jens Przybilla 
# Created on: 25.08.2020
# Last Change by: Jens Przybilla on 30.09.2020

library( fhircrackr )
library(dplyr)
library(xml2)

MaxBundle = 500
print("Start of read_blood_pressure_ex1.R")
back <- getwd( )
output_directory <- "./outputGlobal/FindAllObservations_vx"

if( ! dir.exists( output_directory ) ) {
  dir.create( output_directory, recursive = T )
  setwd(back)
}else{
  #löschen der vorhandenen Dateien im outputGlobal/test1 Ordner.
  #setwd( output_directory )
  #flist <- list.files(getwd())  %>% print()
  #file.remove(flist)
  #setwd(back)
}


setwd( output_directory )
mbund <- 100000 #maximum number of bundles
print(paste0("Test data: ", Sys.Date()))
endpoint <- "https://mii-agiop-3p.life.uni-leipzig.de/fhir/"

###
# fhir.search.request ohne Endpunktangabe
###

fhir_search_request <- paste0(
  "Observation?",
  "code=http://loinc.org%7C85354-9",
  "&_include=Observation:patient")

fsq <- paste_paths(endpoint, fhir_search_request)
print(fsq)

bundles <- fhir_search(fsq, max_bundles = MaxBundle, verbose = 2, log_errors = 2)

fhir_save(bundles, directory="Bundles")

design <- list(
  Observation = list(
    entry   = "//Observation",
    items = list( 
      O.OID  = "id",
      O.PID  = "subject/reference",
      O.EID  = "encounter/reference",
      DIA    = "component[code/coding/code/@value='8462-4']/valueQuantity/value", 
      SYS    = "component[code/coding/code/@value='8480-6']/valueQuantity/value",
      #MBP    = "component[code/coding/code/@value='8478-0']/valueQuantity/value/@value",#muss abders gesucht werden.
      DATE   = "effectiveDateTime"
    )
  ),
  Patient = list(
    "//Patient",
    list(
      P.PID      = "id", 
      VORNAME    = "name/given", 
      NACHNAME   = "name/family",
      GESCHLECHT = "gender", 
      GEBURTSTAG = "birthDate" 
    )
  )
)

list_of_tables <- fhir_crack(bundles, design, sep = " | ", verbose = 2)
print(names(list_of_tables))

for( m in names( list_of_tables ) ) {
  
  write.table(list_of_tables[[m]], file = paste0(m, ".csv"), na = "", sep = ";", dec = ".", row.names = F, quote = F)
}

setwd(back)

cat("end of read_blood_pressure_ex1.R")


