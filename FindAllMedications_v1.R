library(fhircrackr) 
back <- getwd( )
endpoint <- "https://mii-agiop-3p.life.uni-leipzig.de/fhir/"
print(endpoint)
MaxBundle = 500

output_directory <- "./outputGlobal/FindAllMedications_v1"

if(! dir.exists(output_directory)) {
  dir.create(output_directory, recursive = T)
  setwd(back)
}else{}

fsq <- paste0( endpoint, "MedicationStatement?",
               "_count=100")
print(fsq)

bundles <- fhir_search(fsq, max_bundles=MaxBundle, verbose = 2)
fhir_save(bundles, directory=output_directory)
bundle_time <- proc.time() 

design <- list(
  MedicationStatement = list(
    "//MedicationStatement"
  )
)

list_of_tables <- fhir_crack(bundles, design, sep = " | ", verbose = 2)

setwd( output_directory )

for(n in names(list_of_tables)) {
  write.table(list_of_tables[[n]], file = paste0( n, ".csv" ), na = "", sep = ";", dec = ".", row.names = F, quote = F )
}

setwd( back )


