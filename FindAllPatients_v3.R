library(fhircrackr) 
back <- getwd( )
endpoint <- "https://mii-agiop-3p.life.uni-leipzig.de/fhir/"
print(endpoint)
MaxBundle = 500

output_directory <- "./outputGlobal/FindAllPatients_v3"

if(! dir.exists(output_directory)) {
  dir.create(output_directory, recursive = T)
  setwd(back)
}else{}

fsq <- paste0( endpoint, "Patient?")

print(fsq)
bundles <- fhir_search(fsq, max_bundles=MaxBundle, verbose = 2)
bundle_time <- proc.time() 

design <- list(
  Patient = list(
    "//Patient",
    list(
      P.PID      = "id/", 
      VORNAME    = "name/given", 
      NACHNAME   = "name/family",
      GESCHLECHT = "gender", 
      GEBURTSTAG = "birthDate" 
    )
    
  )
)

list_of_tables <- fhir_crack(bundles, design, sep = " | ", verbose = 2)

setwd( output_directory )

for( n in names(list_of_tables)) {
  write.table(list_of_tables[[n]], file = paste0(n, ".csv" ), na = "", sep = ";", dec = ".", row.names = F, quote = F)
}

setwd( back )


