# R Tutorium 4. Sitzung
# 17.01.2022
# Lisa Poggel

# Our first web scraper used a for-loop to control the order in which our code
# was executed: Our loop iterated over the list of suburls and each time it executed the 
# instructions from the body of the loop with another element from the list as input. 
# While for-loops and other control structures are very important in other programming 
# languages such as Python, R is not really designed for this style of programming. 
# This means that using loops is possible, but this often results in a long run time and 
# is generally considered to be a less elegant way to do things in R.
# Instead, R is made for functional programming. Functional programming is a programming 
# paradigm that relies on functions rather than sequences of statements and instructions to 
# perform tasks (see https://en.wikipedia.org/wiki/Functional_programming for a more detailed definition). 

# This script illustrates how a functional approach to scraping wikisource may look like. 
# Note that I have heavily relied on the function map() from the purrr package to replace the loop. 
# I have added explanations for each block of code. For more information on purrr and map() 
# see https://purrr.tidyverse.org/index.html
# and https://b-rodrigues.github.io/modern_R/functional-programming.html#functional-programming-with-purrr

install.packages("rvest")
install.packages("stringi")
install.packages("purrr")
library(rvest)
library(stringi)
library(purrr)

setwd("/Users/gast/Desktop/ARBEIT/EXC_Temporal_Communities/R-Tutorium/Maerchen")

url <- "https://de.wikisource.org/wiki/Kinder-_und_Hausm%C3%A4rchen"

# parse website html and extract links
suburls <- url %>%
  read_html() %>% # bracket optional
  html_nodes(xpath = "//div[1]/table[2]/tbody/tr/td[position()>1]/a") %>% 
  html_attr("href") %>%
  stri_paste("https://de.wikisource.org", .)
head(suburls)

# extract text from within paragraph tags (<p></p>)
# map() takes a list and a function as input and applies the function to each element of the list. 
# In this case, map(html_nodes, .. ), f.e., takes the list of html documents as input and returns a list of lists: 
# each list element contains a list of the <p> elements from each input html document. 
maerchentexte <- suburls %>%
  map(read_html) %>%
  map(html_nodes, xpath = "//p[not(preceding::h2)]") %>%
  map(html_text) 
typeof(maerchentexte) # output is list of lists
maerchentexte[1]

# create file names, again using the map() function
filenames <- suburls %>%
  map(basename) %>% # strip beginning of the URL
  map(URLdecode) %>% # decode URL encoding
  stri_trans_general("de-ASCII; Latin-ASCII") %>% # convert ä,ö,ü to ae, oe, ue
  stri_paste(".txt") # no need to revert the order of the input strings this time
head(filenames) 

# write each element of the maerchentexte list to a txt file and save file in working directory
# walk2 is similar to map(), but it takes two lists instead of one and a function as input. 
# It iterates over both lists parallely and applies the function write.table() to both, that is, 
# in each step it takes the elements maerchentexte[i] and filenames[i] as input. 
# Both lists thus have to have the same length.
walk2(maerchentexte, filenames, write.table, quote=F, col.names=F, row.names=F)


