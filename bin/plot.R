#!/usr/bin/env Rscript

#library(RColorBrewer)
library(webshot)
#webshot::install_phantomjs()
library(htmlwidgets)
library(wordcloud2)

words <- read.csv("data/wordcloud.csv")

colnames(words) <- c("freq", "word")
words <- words[, c("word", "freq")]

# remove mixture & cells
rows <- words$word %in% c("mixture", "cells")
words <- words[!rows, ]

set.seed(13337)

fig <- wordcloud2(
	data = words,
	size = 1.4,
	#shape = 'diamond', # square
	backgroundColor = "transparent",
	#fontFamily = 
	color = "random-dark"
)

# export
saveWidget(fig, "tmp/fig.html", selfcontained = TRUE)
# and in png or pdf
webshot("tmp/fig.html", "img/fig.pdf", delay = 5, vwidth = 2000, vheight = 700)
webshot("tmp/fig.html", "img/fig.png", delay = 5, vwidth = 2000, vheight = 700)

cat(paste0(
  "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n",
  "./bin/plot.R complete\n",
  "./fig.pdf & ./fig.png generated",
  "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n"
))