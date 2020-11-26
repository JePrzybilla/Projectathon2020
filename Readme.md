---
title: "Testanfragen mit fhircrackr zum Projectathon 2020"
author: "Thomas Peschel, Julia Gantner und Jens Przybilla"
date: "23 11 2020"
---

## Einleitung

Mit den hier abgelegten R-Skripten kann man auf dem bereitgestellten Testdatensatz unter dem Endpunkt   
"https://mii-agiop-3p.life.uni-leipzig.de/fhir/"   
Anfragen mit Hilfe des R-packages fhircrackr und dazu bereitgestellten Abfrageskripten stellen. Als Ergebnis erhält man .csv Tabellen zur weiteren Auswertung. Einige der Fragen sind schon bei den Anfragen mit FHIR-search formuliert worden. Im Folgenden wird der Server-Endpunkt mit base bezeichnet.


## Test der R-Skripte auf eigenem Server
Die Skripte sind getestet und sollten auf dem für den Projectathon benutzten Server mit Testdaten
sinnvolle Resultate erzielen. 

endpoint <- "https://mii-agiop-3p.life.uni-leipzig.de/fhir/"

Sollen die R-Skripte auf dem eigenen Server getestet werden, dann muss in den einzelnen R-Skripten die Zeile in der der Endpunkt steht durch den gewünschten lokalen Server ersetzt werden.

## Starten der R-Skripte
Starten Sie das gewünschte R-Skript im R-Studio oder auf der Kommandozeile mit dem Befehl  
Rscript --vanilla Skriptname.R  
oder im RStudio.

## Die einzelen Beispielskripte
Die folgenden Skripte stellen FHIR search Anfragen an verschiedene Ressourcen des Testdatensatzes.
Sie werden während des Projetathons vorgeführt und erklärt. Diese können dann auch auf eigenen Daten  getestet werden. Man kann die Skripte in der angegbenen Reihenfolge durcharbeiten, aber auch eine andere Reihenfolge wählen.

#### 1. Skript: CountAllServerResources.R

Mit diesem Skript fragt man den im endpoint eingetragenen FHIR-Server nach allen vorhandenen
Ressourcen (Metadaten) ab und bekommt diese dann in einer Grafik mit der Anzahl der Ressourcen dargestellt. Damit kann man sich einen guten Überblich über alle auf dem Server vorhandenen Ressourcen verschaffen.

#### 2. Skript: FindAllPatients_v1.R

Mit diesem Skript fragt man den im endpoint eingetragenen FHIR-Server nach allen Patienten und ihren zugehörigen Daten, wie Geburtsdatum, etc. ab und leitet diese in eine Tabelle Patient.csv aus.  
Die zugehörige FHIR search Anfrage lautet:  

base/Patient?

#### 3. Skript: FindAllPatients_v2.R
Hier werden nur die männlichen Patienten erfragt. 
Die zugehörige FHIR search Anfrage lautet:  

base/Patient?gender=male

#### 4. Skript: FindAllPatients_v3.R

Hier ist die FHIR search Anfrage genau wie im 2. Skript. Es wird aber im R-Skript noch ein "design" angegeben, dass die Spalten der csv-Tabelle definiert.  
Die zugehörige FHIR search Anfrage lautet wieder:  

/base/Patient?

#### 5.Skript: FindAllObservations_v1.R

Mit diesem Skript fragen wir alle Observations des Servers ab und schreiben Sie in eine csv-Tabelle.
Wir haben hier den Parameter _count=100 hinzugefügt. Dieser erhöht die Anzahl der Observations pro bundle.
Es ist mitunter so (und auf dem Testserver auch), dass nur eine bestimmte Zahl bundles pro Anfrage gestellt werden darf. Das ist eine Server Einstellung. Die FHIR search Voreinstellung ist hier _count=20. Das macht hier bei über 4000 Observations mehr als 200 bundles und dann gibt es den Fehler HTTP code 429.
Die zugehörige FHIR search Anfrage lautet:

base/Observation?_count=100

#### 6.Skript: FindAllMedicationStatements_v1.R

Dieses Skript ist analog zm 5. Skript und benötigt auch eine Setzung des _count=100.
Die zugehörige FHIR search Anfrage lautet:

base/MedicationStatement?_count=100

#### 7.Skript: FindAllMedications_v1.R

Dieses Skript sucht alle Patienten Ressourcen und die zugehörigen Daten heraus, die Aspirin als Medikament erhalten haben. Dieser wird über den ATC code: N06AA09 gesucht. In der Regel gibt man das Codesystem noch an mit http://fhir.de/CodeSystem/dimdi/atc. Momentan funktioniert das leider nur bedingt auf dem HAPI Server.  
Die zugehörige FHIR search Anfrage lautet:

base/Patient?_has:MedicationStatement:patient:medication.code=N06AA09

#### 8.Skript: CountBMIGroups.R

Mit diesem Skript werden mit 2 FHIR search Anfragen die Körpergröße und das Gewicht der Patienten vom Server geladen und mit beiden Größen der Body Maß Index (BMI) berechnet und in 6 verschiedenen Gruppen 
grafisch dargestellt.  
Die zugehörigen 2 FHIR search Anfragen lauten:  

für die Körpergröße:  

base/Observation?code=8302-2

und für das Gewicht:


base/Observation?code=29463-7


#### 9.Skript: CountCovidPatients.R

Mit diesem Skript werden die Patienten IDs ausgelesen und in einer csv-Tabelle dargestellt, die eine Covid19 Diagnose anhand des loinc.code=94500-6 für SARS-CoV-2 RNA Probe haben.  
Die zugehörige FHIR search Anfrage lautet: 


base/Observation?code=94500-6

#### 10.Skript: CovidAgeCohorts.R

Mit diesem Skript werden diejenigen Patienten IDs ausgelesen und in einer csv-Tabelle dargestellt, d1ie eine Covid19 Diagnose anhand des loinc.code=94500-6 für SARS-CoV-2 RNA Proben haben.
Die zugehörige FHIR search Anfrage lautet:


base/Observation?code=94500-6&_include=Observation:patient





