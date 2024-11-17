#!/usr/bin/env Rscript

library(pdftools)
library(stringr)
library(tm)

# import PDFs
files <- list.files(
  "data/denise",
  pattern = "*.pdf$",
  recursive = TRUE,
  full.names = TRUE
)

# Convert to text
textlist <- unlist(lapply(files, pdf_text))

# Prune the dataset
textlist <- sapply(textlist, function(x){
  # words in line breaks
  x <- gsub("-\n", "", x)
  x <- gsub("\n", " ", x)

  # any none letter or digit character
  x <- gsub("[^0-9A-Za-z///' ]", " " , x, ignore.case = TRUE)
  #x <- gsub("[^0-9A-Za-z///' ]", " " , x)

  # remove whitespace at start, end, middle of string
  x <- str_squish(x)

  return(x)
})
textlist <- unname(textlist)

# Convert to frequency matrix
#doc <- TermDocumentMatrix(textlist, control = list(tolower = FALSE))
doc <- TermDocumentMatrix(textlist, control = list(tolower = TRUE))
mat <- as.matrix(doc)
mat <- sort(rowSums(mat), decreasing = TRUE)
dat <- data.frame(word = names(mat), freq = mat)

# Remove common english words, also capitalised
dat <- subset(dat, !word %in% stopwords("english"))
dat <- subset(dat, !word %in% str_to_title(stopwords("english")))

# Remove words occurring in reference lists
weirdwords <- c(
  "doi", 
  "http", 
  "/",
  "^[0-9]"
)
rows <- sapply(weirdwords, grep, dat$word)
rows <- unique(unlist(rows))
dat <- dat[-rows, ]

# Remove random words
badwords <- c(
  "using", "use", "found",
  "based", "can",
  "also", "non", "van", "paper",
  "figure", "fig", "table", "page",
  
  # specific words (occurs in Reference list)
  "toxicol", "biol", "sci", "vargas", "kortenkamp", "zimmer", "verhaegen", "som", "pierozan", "lundgren", "sweden", "strand", "environ", "karlsson", "usa", "stockholm", "martin"
)

dat <- subset(dat, !word %in% badwords)

# Only keep words above 13 in frequency
dat <- subset(dat, freq > 13)

dat$word <- sub("h295r", "H295R", dat$word)
dat$word <- sub("pops", "POPs", dat$word)
dat$word <- sub("pfas", "PFAS", dat$word)
dat$word <- sub("^pop$", "POP", dat$word)
dat$word <- sub("dmso", "DMSO", dat$word)
dat$word <- sub("pc1", "PC1", dat$word)
dat$word <- sub("pc2", "PC2", dat$word)
dat$word <- sub("pcbs", "PCBs", dat$word)
dat$word <- sub("vm7luc4e2", "VM7Luc4E2", dat$word)
dat$word <- sub("oecd", "OCED", dat$word)
dat$word <- sub("pcb", "PCB", dat$word)
dat$word <- sub("ddt", "DDT", dat$word)

#highlightWords <- c("DBP", "gut", "microbiota", "toxicology")
#out$freq[out$word %in% highlightWords] <- round(max(out$freq) * 3, 0)
dat <- dat[order(dat$freq, decreasing = TRUE), ]

dat <- data.frame(weight = dat$freq, word = dat$word)
write.csv(dat, file = "data/wordcloud.csv", row.names = FALSE, quote = FALSE)

cat(paste0(
  "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n",
  "./bin/frequency-table.R complete\n",
  "./data/wordcloud.csv generated",
  "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n"
))


#1. go to https://www.wordclouds.com/
#2. click on "Word list" and choose "Import from CSV” 
#3. play around with settings under “Color”, “Mask”, “Font”, “Shape”
#4. to save, click on “File”, choose “Save as image HD” and pick PDF (exact)
