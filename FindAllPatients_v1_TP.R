#FindAllPatients_v1.R search for all patient Ressources output is a Patient.csv
rm(list = ls())

library(fhircrackr) 

start_time <- proc.time() 

###############################################################################################################
output_directory_bundles <- "./outputGlobal/FindAllPatients_v1/bundles"
output_directory_tables <- "./outputGlobal/FindAllPatients_v1/tables"

if(! dir.exists(output_directory_bundles)) dir.create(output_directory_bundles, recursive = T)
if(! dir.exists(output_directory_tables)) dir.create(output_directory_tables, recursive = T)
###############################################################################################################

endpoint <- "https://mii-agiop-3p.life.uni-leipzig.de/fhir/"

fsq <- paste0(endpoint, "Patient?_count=500")
print(fsq)

bundles_patients <- fhir_search(fsq, verbose = 2)
fhir_save(bundles_patients, directory=output_directory_bundles)

cat("Download Time:\n")
dt <- proc.time()
print(dt - start_time)

design_patients <- list(
  Patient = list(
    resource = "//Patient"
  )
)

lot <- fhir_crack(bundles_patients, design_patients, sep = " | ", verbose = 2)

for(n in names(lot)) {
  write.table(
    x = lot[[ n ]], 
    file = paste0( output_directory_tables, "/", n, ".csv" ),
    na = "", sep = ";", dec = ".", row.names = F, quote = F )
}

cat("Crack Time:\n")
print(proc.time() - dt)

cat("Total Time:\n")
print(proc.time() - start_time)
