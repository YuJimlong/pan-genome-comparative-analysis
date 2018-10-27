library(stringr)
library(rvest)

## first you should download the full table from the website https://www.ncbi.nlm.nih.gov/genome/genomes/154  
## save it as 'genome_tables.csv' 

## read the csv file into R  
genome_tables<- read.csv("genome_tables.csv")

## select the sample ID
genome_tables<- genome_tables[,4]

## scrape all of the html code from the NCBI website
## NOTE: this process may take 3-5 hours depands on yout internet condition.  
for (i in genome_tables) {
  a<-paste("https://www.ncbi.nlm.nih.gov/biosample/",i, sep = "")
  a<- str_trim(a)
  htmlcode<- read_html(a)
  write_html(htmlcode, paste(i, ".html", sep = "_htmlcode"))
}



## Generate two tables for indication of bundary.  
table1<- read_html("https://www.ncbi.nlm.nih.gov/biosample/SAMEA3138186") %>% html_table()
table1<- table1[[1]]
table1<- table1[1,]
table1[1,1]<- "sss"
table1[1,2]<- "sss"
table2<-table1


## Extract the strain attributes from the html files.  
## And combine it into one table.  
htmlfiles<- dir()
for (i in htmlfiles) {
  inames<- str_extract(i, "[A-Z|0-9]+")
  codeline1 <- paste(inames, "<- read_html(i) %>% html_table()", sep = " ")
  eval(parse(text = codeline1))
  codeline2 <- paste("length(", inames, ")", "== 0" ,sep = "")
  
  ## test if attributes are empty.  
  condition1<- eval(parse(text=codeline2))
  if (condition1){
    next
  }
  else{
    codeline3<- paste(inames , " <- ", inames,"[[1]]", sep = "")
    eval(parse(text = codeline3))
    codeline4<- paste("table1 <- rbind(table1,", inames, ",table2)")
    eval(parse(text = codeline4))
    codeline5<- paste("rm(", inames,")", sep = "")
    eval(parse(text = codeline5))
    
    ## we have to remove the environment objects timely otherwise your R will breakdown.  
    rm(inames)
  }
}

write.csv(table1, "s_aureus_genome_info.csv")
