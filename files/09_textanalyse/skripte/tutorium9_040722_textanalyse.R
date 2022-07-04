# R Tutorium SoSe 2022
# Sitzung 9: Quantitative Textanalyse
# Lisa Poggel


## 0. Install and load packages (note the different ways to do it)

if (!require("quanteda")) install.packages("quanteda")
install.packages("quanteda.textplots")
install.packages("quanteda.textstats")
install.packages("readtext")
library(readtext)

# Set working directory 
setwd("09_quantitative_textanalyse/daten/dta-oekonomie")

## 1. Repetition from last week: read data, create a corpus object, preliminary information
# read corpus
dta <- readtext("*.txt", docvarsfrom = "filenames", dvsep = "_", docvarnames = c("Name", "Titel", "Jahr"))
dta
# Create a corpus object
dta_cor <- corpus(dta)

# Preliminary information about the corpus
tokenInfo <- summary(dta_cor, 109)
tokenInfo 

#Do you remember what these functions do?
range(tokenInfo$Jahr) 
range(tokenInfo$Tokens) 
length(unique(tokenInfo$Name)) 
sum(tokenInfo$Tokens) 

# Wie könnte man sich den Namen des Textes mit den meisten Tokens ausgeben lassen?
tokenInfo$Titel[tokenInfo$Tokens == max(tokenInfo$Tokens)]
tokenInfo$Name[tokenInfo$Tokens == max(tokenInfo$Tokens)]

## 2. Preprocessing 

# We will not use stemmatization and lemmatization for our analyses; conducting the same 
# analyses with different preprocessing options will be one of the tasks for next week. 
# Preprocessing steps will be conducted when they are needed; first we will work with the 
# "raw" corpus object.

## 3. Sample analysis using a quanteda corpus object

# Construct a sub-sample of Marx texts
length(which(dta$Name=="marx"))
which(dta$Name=="marx") # gibt aus: 12 13 14 15
dta$doc_id[12:15] # using the original vector "alltexts" (! you can't address docid_ in "corpus"!)
# Construct a sub-sample of marx texts: the quanteda way 
marx_corpus <- corpus_subset(dta_cor, Name == "marx")

# Construct a sub-corpus and summarize corpus information in one step
marx_summary <- summary(corpus_subset(dta_cor, Name == "marx"))
View(marx_summary) #View opens the summary in the R data environment 
# How many texts does the marx subcorpus comprise? 

# Visualization: no. of tokens by text 
# There are many base R functions for data visualization, such as plot(), hist(), boxplot(). 
# However, customization can be tricky, especially when we have mixed scales (numeric/categorical)
# For this reason, in this example, we will use ggplot2 package to create a scatterplot of the number of tokens per text
options(scipen=999)
require(ggplot2)
marx_summary_plot <- ggplot(data=marx_summary, aes(x=Titel, y=Tokens, group=1))+geom_point()+theme_bw()
marx_summary_plot + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle("Streudiagramm Anzahl Tokens/Text")
marx_summary_plot
max(marx_summary$Tokens) # longest text (N tokens)
# What information do the table marx_summary and the scatterplot marx_summary_plot provide?
# --> Table and plot report on the length of marx's texts by no. of tokens. 
# They show that there are three novels (Das Schloss, Amerika, Der Prozess, which comprise between 87,000 and 133,000 tokens), five longer stories (between 12,000 and 22,000 tokens), and three short narrations (1,000 - 7,000 tokens).

## 4. Sample analyses using a quanteda tokens object

# create a quanteda tokens object, without preprocessing
marx_tokens <- tokens(marx_corpus)

# 4.1 Keywords in Context (KWIC)
# https://tutorials.quanteda.io/basic-operations/tokens/kwic/
# head() prints the first six results returned by the kwic() function
head(kwic(marx_tokens, pattern="entfremdung", window = 3, case_insensitive = TRUE))
head(kwic(marx_tokens, pattern="entfremdung", window = 6, case_insensitive = TRUE))

# KWIC for multiword combinations (phrases, also called "compound tokens")
#https://tutorials.quanteda.io/basic-operations/tokens/tokens_compound/
kwic(marx_tokens, phrase("produktive Arbeit"))
marx_keywords <- kwic(marx_tokens, pattern = c("börse*", "finanz*"))
typeof(marx_keywords)
View(marx_keywords)
nrow(marx_keywords)

# Visualization of occurrence of keywords across Marx texts
marx_keywords_plot <- ggplot(data=marx_keywords, aes(x=docname, y=keyword, group=1))+geom_point()+theme_bw()
marx_keywords_plot + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle("Occurrence of Keywords across marx Corpus")

# 4.2 Token Co-Occurrence Lists: Unigrams, Bigrams and Ngrams
# N-grams are sequences of tokens of length n. The function tokens_ngrams merely splits up the text into 
# sequences of length n, but does not calculate their frequency.
# Unigrams
toks_unigram <- tokens_ngrams(marx_tokens, n = 1)
head(toks_unigram[[1]], 30) 
# Bigrams
toks_bigram <- tokens_ngrams(marx_tokens, n = 2)
head(toks_bigram[[1]], 30) # print first 30 bigrams in the first text
View(toks_bigram) # view bigrams in all texts
# Your turn: Change the value for n in the code below 
toks_ngram <- tokens_ngrams(marx_tokens, n = 3)
head(toks_ngram[[1]], 30) 

# Um hier sinnvolle Ergebnisse zu bekommen, müssen wir preprocessing vornehmen: 
marx_toks_pr <- marx_corpus %>%
  tokens(remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE) %>% 
  tokens_remove(pattern = stopwords("de")) %>%
  tokens_tolower() 
toks_bigram <- tokens_ngrams(marx_toks_pr, n = 2)
head(toks_bigram[[1]], 30) 
toks_ngram <- tokens_ngrams(marx_toks_pr, n = 3)
head(toks_ngram[[1]], 30) 

# Selective ngrams
# You can also look for token sequences containing a certain token, f.e. "nicht"
toks_neg_bigram <- tokens_compound(marx_tokens, pattern = phrase("finanziell* *"))
toks_neg_bigram_select <- tokens_select(toks_neg_bigram, pattern = phrase("finanziell*_*"))
head(toks_neg_bigram_select[[1]], 30)

# nur zwei Ergebnisse? Wie könnten wir überprüfen, ob das stimmen kann? 

toks_neg_bigram <- tokens_compound(marx_tokens, pattern = phrase("ökonomisch* *"))
toks_neg_bigram_select <- tokens_select(toks_neg_bigram, pattern = phrase("ökonomisch*_*"))
head(toks_neg_bigram_select[[1]], 30)

# These lists can be used to calculate frequency. Do you have ideas how we can do it? 
# In quanteda, there is a simpler way: We will get to know it in chapter 7.4. First, 
# we need to get to know document-feature matrices. 

## 5. Sample analyses using a quanteda dfm object
# To conduct most types of analysis, a document-feature-matrix (dfm) is needed.
# A dfm is a matrix, in which columns represent features and rows documents. 

# create a dfm
marx_dfm <- dfm(marx_tokens)
# Note that some preprocessing steps can also be conducted when creating the dfm, for instance stopword and punctuation removal. 
marx_dfm_rm <- dfm(marx_tokens, remove = stopwords("german"), remove_punct = TRUE) 
# A simple base R function to look at the distribution of all words in the subcorpus
plot(marx_dfm)
# What do you observe? What shape does the plot have? 
# Add labels for the x and y axis by adding the arguments ylab = "..." and xlab = "...". 
# Add a title for the plot by adding main = "..."

# The function dfm_trim can be used to remove words by frequency; here: all words with a frequency of less than 5
marx_dfm_trimmed <- dfm_trim(marx_dfm, min_termfreq = 5, verbose = FALSE)
plot(marx_dfm_trimmed)

# 5.1 Wordcloud
library("quanteda.textplots")
set.seed(100)
textplot_wordcloud(marx_dfm_rm,  #note that we are using the dfm without stopwords and punctuation
                   min_count = 6, 
                   random_order = FALSE, 
                   rotation = .25,
                   color = RColorBrewer::brewer.pal(8,"Dark2"))
# Look at the code above: What does our wordcloud visualize? 

# 5.2 Keyness Analysis (Relative Frequency Analysis)
# https://tutorials.quanteda.io/statistical-analysis/keyness/
# The function textplot_keyness computes which tokens in a subcorpus are used significantly more often than could be 
# assumed on the basis of chance compared to the rest of the corpus. We use the measure "Log-likelihood" (LL).
# In this analysis we compare all marx texts with the rest of the corpus. This means the marx texts are 
# our "target corpus" (Zielkorpus) while the rest of the corpus functions as our "reference corpus" (Referenzkorpus). 
# Log-Likelihood compares which tokens occur in the target corpus over randomly often/seldom.
# See for an in-depth discussion of the measure: http://ucrel.lancs.ac.uk/llwizard.html
# or run ?textstat_keyness to bring up the official R documentation.

# Preprocessing: für das gesamte Korpus 
dta_toks <- dta_cor %>%
  tokens(remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE) %>% 
  tokens_remove(pattern = stopwords("de")) %>%
  tokens_tolower() 

# construct a dfm
dta_dfm <- dfm(dta_toks)
author_dfm <- dfm_group(dta_dfm, groups = Name)
# Print dta_dfm and author_dfm in the console. What difference do you see?

# All in one: Combine preprocessing and creation of a dfm object using pipes
author_dfm <- tokens(dta, remove_punct = TRUE) %>% 
  tokens_remove(pattern = stopwords("de")) %>%
  tokens_group(groups = Name) %>%
  dfm()
# Add the preprocessing step tokens_tolower() to the above code - Where does it go?
  
library("quanteda.textstats")
# calculate keyness
keyness_marx <- textstat_keyness(author_dfm, target = "marx", measure = "lr", sort = TRUE) 

write.csv(keyness_marx, paste0(getwd(), ".csv"))

# plot keyness
textplot_keyness(keyness_marx, n=50L, labelsize = 2)
#?textplot_keyness # check for function parameters

# 5.3 Token Frequency Analysis using a dfm

# Absolute Frequency of selected keywords across the marx corpus
marx_keyword_toks <- marx_tokens %>% 
  tokens_keep(pattern = c("arbeit", "wert", "ware", "zirkulation", "geld", "profit")) # wie sieht das ganze mit "kapital*", "arbeit*", "ware*" aus?
dfmat_marx_keywords <- dfm(marx_keyword_toks)

# Display occurences: frequency table
#https://tutorials.quanteda.io/statistical-analysis/frequency/
marx_keyword_freq <- textstat_frequency(dfmat_marx_keywords)
head(marx_keyword_freq, 20)

#marx_keyword_freq <- textstat_frequency(dfmat_marx_keywords, groups = c("amerika", "betrachtung", "hungerkünstler", "landarzt", "prozess", "schloss", "strafkolonie", "verwandlung"))

# Simple plot of absolute frequencies of each keyword across the marx corpus
dfmat_marx_keywords %>% 
  textstat_frequency(n = 15) %>% 
  ggplot(aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() +
  coord_flip() +
  labs(x = NULL, y = "Frequency") +
  theme_minimal()
 
# Barchart of absolute frequencies per text
# group frequencies by text 
marx_keyword_freq <- textstat_frequency(dfmat_marx_keywords, groups = docid(dfmat_marx_keywords))
head(marx_keyword_freq, 20)

# create barchart
marx_keywords_hist <- ggplot()+    
  geom_bar(data=marx_keyword_freq,aes(x=group, y=frequency, fill=feature),stat='identity',position='dodge')+ 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle("Barchart of absolute frequencies")
marx_keywords_hist


# same thing with different keywords
marx_keyword_toks_2 <- marx_tokens %>% 
  tokens_keep(pattern = c("finanz*", "börse*"))
dfmat_marx_keywords_2 <- dfm(marx_keyword_toks_2)

marx_keyword_freq_2 <- textstat_frequency(dfmat_marx_keywords_2, groups = docid(dfmat_marx_keywords))
head(marx_keyword_freq_2, 20)

# barchart no 2
marx_keywords_hist_2 <- ggplot()+    
  geom_bar(data=marx_keyword_freq_2,aes(x=group, y=frequency, fill=feature),stat='identity',position='dodge')+ 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle("Barchart of absolute frequencies")
marx_keywords_hist_2

# Note: There are two types of bar charts: geom_bar() and geom_col(). geom_bar() makes the height of the bar proportional to the number of cases in each group (or if the weight aesthetic is supplied, the sum of the weights). If you want the heights of the bars to represent values in the data, use geom_col() instead.
# geom_bar() uses stat_count() by default: it counts the number of cases at each x position.
# in effect, geom_col(…) is geom_bar(stat = “identity”)
# See https://mzuer.github.io/blog/2020/05/30/r-geom_bar-and-geom_col

# 5.4 Co-Occurrence Analysis (Tokens)
# https://tutorials.quanteda.io/basic-operations/fcm/
# In quanteda, a dfm can be used to create a feature co-occurrence matrix (fcm). 
# A fcm is used to store the co-occurrence of features (tokens) across a corpus

# Top features across the marx subcorpus
topfeatures(marx_dfm)
# Look at the result. How does it relate to the unigrams of marx tokens that we calculated in ch. 6.2?

# construct fcm
marx_fcmat <- fcm(marx_dfm)
marx_fcmat

# return most frequently co-occuring tokens
topfeatures(marx_fcmat)

#Co-occurrence table: Feature co-occurrence matrix
#https://www.rdocumentation.org/packages/quanteda/versions/1.5.0/topics/fcm
marx_fcmat <- fcm(marx_dfm, context = "document", count = "boolean") #count = "frequency", window = 2
marx_fcmat

# 5.5 Co-Occurrence Analysis (Types)
# The methods of analysis introduced thus far are all based on tokens. But we can also look at types, f.e.: 
topfeatures(author_dfm, n= 20, decreasing = TRUE, scheme = "count", groups = "Name")


# 6. Collocations
# https://tutorials.quanteda.io/statistical-analysis/collocation/
# "Collocations are terms that co-occur (significantly) more often together thatn would be expected 
# by chance." Examples: Merry Christmas, Frohes Neues, ... 
marx_cols <- textstat_collocations(marx_tokens, min_count = 100)
head(marx_cols, 20)

# 7. Lexical Diversity 
# The Type/Token Ratio (TTR) is a simple measure of lexical diversity, which however depends on text length (by default, longer texts tend to be more lexically diverse). 
# An alternative is the Mean-Segmental TTR (MSTTR), which calculates TTRs for segments of text, and then finds the mean of those TTRs (Lu, 2014, p. 82). A smaller TTR indicates less varied lexis.
# MSTTR can be computed by the quanteda package for R: https://quanteda.io/reference/textstat_lexdiv.html

# Tutorial: https://tutorials.quanteda.io/statistical-analysis/lexdiv/

# 8. Readability Index (Lesbarkeitsindex)
# Funktion textstat_readability(): https://quanteda.io/reference/textstat_readability.html
