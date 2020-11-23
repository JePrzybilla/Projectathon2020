library(devtools)
library(dplyr)
library(xml2)
devtools::install_github("POLAR-fhiR/fhircrackr", ref="master")
#devtools::install_github("POLAR-fhiR/fhircrackr", force=TRUE, ref="data_table")
library(fhircrackr) 
#githubinstall("POLAR-fhiR/fhircrackr[small_correct]")
start_time <- proc.time() 
#fhir_search_request <- "Patient?_format=xml"
print("Starten von test7.R")
back <- getwd( )
output_directory <-"outputGlobal/ResultTest2"

if(! dir.exists( output_directory)) {
  dir.create(output_directory, recursive = T)
  setwd(back)
}else{
  #löschen der vorhandenen Dateien im outputGlobal/test1 Ordner.
  #setwd( output_directory )
  #flist <- list.files(getwd())  %>% print()
  #file.remove(flist)
  #setwd(back)
}

setwd( output_directory )
mbund <- 1000000 #maximum number of bundles

print(paste0("Testfiles zum Testen von synthea Datensätzen: ", Sys.Date()))
endpoint <- "http://localhost:8080/fhir"
#dat <- fhir_capability_statement(endpoint,verbose = 3, add_indices = T)
#write.table( dat, file = "capabilityStatement.csv" , na = "", sep = ";", dec = ".", row.names = F, quote = F )
###
# fhir.search.request ohne Endpunktangabe
###
fhir_search_request <- paste0(
  "Patient?",
  #"code=http://loinc.org|85354-9",
  #"deceased=true",
  #"code=http://loinc.org|72514-3",
  #"&_code=http://loinc.org|10230-1",
  #"&_include=Observation:subject",
  #"&_include=Observation:encounter",
  "&_format=xml")


fsq <- paste_paths(endpoint, fhir_search_request)

obs_bundles <- fhir_search(fsq, max_bundles = mbund, verbose = 2)
bundle_time <- proc.time() 
cat("Ladezeit bundles", (bundle_time -start_time)/60., " Minuten.\n")
fhir_save(obs_bundles, directory="Bundles")


design <- list(
  Patient = list(
    resource = "//Patient",       
    cols=list(
      P.PID      = "id", 
      VORNAME    = "name/given", 
      NACHNAME   = "name/family",
      GESCHLECHT = "gender", 
      GEBURTSTAG = "birthDate" 
     # Todestag = "deceasedDateTime"
    )
  )
)

list_of_tables <- fhir_crack(bundles =obs_bundles, design=design, verbose = 2)
print(names( list_of_tables ) )

for(m in names(list_of_tables)){
  
  write.table(list_of_tables[[m]], file = paste0(m, ".csv"), na = "", sep = ";", dec = ".", row.names = F, quote = F)
  print(colnames( list_of_tables[[m]] ) )
}

setwd(back)

cat("Ladezeit bundles", (bundle_time -start_time)/60., " Minuten.\n")
cat("Table Crack Time ", (proc.time() - bundle_time)/60., " Minuten.\n")
