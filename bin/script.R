# 221021
# wordcloud

library(pdftools)
library(stringr)
library(tm)

# import pdf, each page is element in the list
path <- "data"
files <- list.files(path, pattern = "*.pdf$")
list <- lapply(file.path(path, files), pdf_text)

# remove special characters: () [] : ; \n /
foo <- function(list){
  # iterate over papers
  for (i in seq_along(list[[1]])){
    page <- list[[1]][i]

    page <- gsub("\n", " ", page)
    page <- gsub("[,]", "", page)
    page <- gsub("[.]", "", page)
    page <- gsub("[:]", "", page)
    page <- gsub("[0-9]", "", page)
    page <- gsub("[]", "", page, fixed = TRUE)
    page <- gsub("(", "", page, fixed = TRUE)
    page <- gsub(")", "", page, fixed = TRUE)
    page <- gsub("https//", "", page)
    page <- gsub("doiorg//", "", page)
    page <- gsub("\"", "", page)
    #page <- tolower(page)
    page <- str_squish(page)
      
    list[[1]][i] <- page
  }
  
  doc <- TermDocumentMatrix(list)
  m <- as.matrix(doc)
  v <- sort(rowSums(m), decreasing = T)
  d <- data.frame(word = names(v), freq = v)
  
  return(d)
}

d <- foo(list)

words <- c(
  "the", "and", "for", "was", "with", "were", "that", "are", "from",
  "after", "100", "[crossref]", "this", "one", "all", "also", 
  "five", "usa)", "used", "which", "sci", "can", "500", "followed",
  "not", "per", "than", "our", "int", "follows:", "their",
  "three", "environ", "between", "only", "min", "more", "2022", 
  "mg/kg", "(figure", "(a)", "(b)", "other", "however", "could", "then",
  "but", "each", "had", "before", "2016", "(c)", "have", "how", "its",
  "been", "both", "usa", "abcam" ,"first", "al.,", "[pubmed]", "has", "\"figure", "your", "using")

d <- subset(d, !word %in% words)
rows <- grepl("<", d$word)
d <- d[!rows, ]
out <- subset(d, freq > 13)

out$word <- sub("dbp", "DBP", out$word)
highlightWords <- c("DBP", "gut", "microbiota", "toxicology")
out$freq[out$word %in% highlightWords] <- round(max(out$freq) * 3, 0)
out <- out[order(out$freq, decreasing = T), ]

out <- data.frame(weight = out$freq, word = out$word)
write.csv(out, file = "data/wordcloud.csv", row.names = F, quote = F)


#1. go to https://www.wordclouds.com/
#2. click on "Word list" and choose "Import from CSV” 
#3. play around with settings under “Color”, “Mask”, “Font”, “Shape”
#4. to save, click on “File”, choose “Save as image HD” and pick PDF (exact)
