# Last Change: at 27.11.2020
# Thomas Peschel and Jens Przybilla
# Counts and plots a histogram of the resources of the FHIR server
library(fhircrackr)
library(dplyr)
library(ggplot2)

print(system('hostname'))
back <- getwd()
start_time <- proc.time() 
(time_string <- gsub('[^0-9]*', '', Sys.time()))
output_directory <- "./outputGlobal/ResultCount"

if(! dir.exists(output_directory)) {
  dir.create(output_directory, recursive = T)
  setwd(back)
}else{}

#Change the endpoint here if you want to use another endpoint
all_endpoints <- list(hapiOpen = "https://mii-agiop-3p.life.uni-leipzig.de/fhir")

all_endpoints <- list(hapiOpen = "https://mii-agiop-3p.life.uni-leipzig.de/fhir")
sel_endpoints_names <- "hapiOpen"
endpoints <- all_endpoints[sel_endpoints_names]
print(endpoints)

caps_list <- lapply(endpoints, function(e) {
  s <- try(fhir_capability_statement(e), silent = FALSE)
  s <- if (class(s)[1] != 'try-error') s else NULL
  s
})

ncl <- as.list(names(caps_list)[! sapply(caps_list, is.null)])
names(ncl) <- ncl
all_resources_counts <- lapply(ncl, function(name_server) {
  
  print(name_server)
  caps <- caps_list[[name_server]]
  df <- caps[['REST']]
  
  if ('type' %in% names(df)) {
    sapply(df[['type']], function(resource) {
      fsr <- paste0(paste_paths(endpoints[[name_server]], resource), '?_summary=count')
      bundles <- fhir_search(fsr, verbose = 0)
      tot <- fhir_crack(bundles, list(Tot=list('//Bundle',list(total='//total'))), verbose = 0)
      i <- as.integer(tot$Tot$total)
      print(paste0(name_server, ' contains ', tot$Tot$total, " ", resource, 's.'))
      i
    })
  }
})

n <- unique(unlist(sapply(all_resources_counts, names)))

df <- data.frame(lapply(all_resources_counts,function (i) rep_len(NaN, length(n))), row.names=n)

for (cn in names(all_resources_counts)) {
  a <- all_resources_counts[[cn]]
  for (rn in names(a)) {
    df[rn, cn] <- a[[rn]]
  }
}

df$Resource <- rownames(df)

df <- df[ , c('Resource', setdiff(names(df), 'Resource'))]
head(df)


setwd(output_directory)
write.table( df, file = paste0("count_all_resources_", time_string, ".csv"), na = "", sep = ";", dec = ".", row.names = F, quote = F )

dfm <- reshape2::melt(df, 'Resource')
names(dfm) <- c('resource', 'server', 'count')[match(names(dfm), c('Resource', 'variable', 'value'))]
dfm$`count [log10]` <- log10(1 + dfm$count)

#Plot a histogram of the ressources
g <- ggplot(dfm) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.position = 'none') +
  geom_col(
    aes(
      x = resource,
      y = `count [log10]`,
      fill = server
    )
  ) +
  geom_text(
    aes(
      x = resource,
      y = `count [log10]` / 2,
      label = count
    ),
    col = 'black',
    angle = 90
  ) +
  #scale_color_discrete(h=c(120,240)) +
  scale_fill_discrete(h=c(120,240)) +
  facet_grid(server ~ .)

#Save the histogram of the FHIR ressources
ggsave(paste0("HapiTestData_CountAllServerResources_", time_string, ".png"), g, dpi = 300 , width = 24, height = 12)
ti <- (proc.time() - start_time)/60.
write.table(t(data.matrix(ti)), file = "RunningTime_Min.dat",row.names = F, quote = F )
cat("Running Time: ", ti, " minutes.\n")
setwd(back)




