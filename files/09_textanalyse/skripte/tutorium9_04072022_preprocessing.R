# R-Tutorium 9. Sitzung: Preprocessing
# Lisa Poggel
# 04.07.2022

# Pakete installieren und laden (beachtet wieder die verschiedenen Methoden)

if (!require("quanteda")) install.packages("quanteda") 
install.packages("readtext")
install.packages("udpipe")
install.packages("stringr")
install.packages("purrr")
library(readtext)
library(stringr)
library(quanteda)

setwd("09_quantitative_textanalyse/daten/dta-oekonomie")
# Backslashes für Windows:
# setwd("C:\Users\gast\Tutorium")

# Korpus mit Informationen aus den Dateinamen einlesen
dta <- readtext("*.txt", docvarsfrom = "filenames", dvsep = "_", docvarnames = c("Autor", "Titel", "Jahr"))
str(dta)

# quanteda-Korpusobkjekt erstellen
dta_cor <- corpus(dta)
summary(dta_cor, 5) 


# Preprocessing mit Default-Optionen: Wiederholung
# Korpusobjekt mit vorimplementierten Preprocessing-Optionen tokenisieren
# Funktion tokens_remove() zum entfernen der Stoppwörter verwenden 
dta_toks <- dta_cor %>% # remember: a "pipe" %>% concatenates code, the input for the following function is the output from the previous function
  tokens(remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE)# %>% 
  #tokens_tolower() %>%
  #tokens_remove(pattern = stopwords("de"))

# Print-Funktion muss für quanteda-Objekte angepasst werden: http://quanteda.io/reference/print-quanteda.html
print(dta_toks[1]) # wird nicht komplett angezeigt
print(dta_toks[1], max_ntoken = 200) # 200 Tokens anzeigen


# Custom Preprocessing: Stoppwörter

# Welche Stoppwörter entfernt die quanteda-Funktion tokens_remove(pattern = stopwords("de))? 
# https://quanteda.io/reference/stopwords.html
# http://snowball.tartarus.org/algorithms/german/stop.txt

# Eigene Stoppwortliste herunterladen, zum Beispiel: 
# https://github.com/solariz/german_stopwords
# oder https://github.com/stopwords-iso/stopwords-de/blob/master/stopwords-de.txt
# Vor dem Import kann die Liste angepasst werden, indem einfach Wörter in der 
# plaintext Datei hinzugefügt oder entfernt werden. 

# Eigene Stoppwortliste einlesen
custom_stopwords <- readLines("stopwords.txt", encoding = "UTF-8") 
custom_stopwords <- readtext("stopwords.txt") 
custom_stopwords
# Importierte Stoppwortliste and die tokens_remove()-Funktion übergeben
dta_new <- dta_toks %>% 
  tokens_remove(pattern = custom_stopwords, padding=F)
dta_new

# Stammformreduktion (Stemming) und Lemmatisierung
# Stemming mit Default-Optionen
dta_stemmatized <- tokens_wordstem(dta_new, language = quanteda_options("language_stemmer"))
dta_stemmatized
# Vergleich der Token-Anzahl vor und nach dem Stemming
summary(dfm(dta_stemmatized))
summary(dfm(dta_tokens))

# Lemmatisierung und Stemming anpassen: Code von https://tm4ss.github.io/docs/Tutorial_5_Co-occurrence.html
# Unterschied zwischen Lemmatisierung und Stemming erklärt: https://towardsdatascience.com/stemming-vs-lemmatization-2daddabcb221#:~:text=Stemming%20and%20Lemmatization%20both%20generate,words%20which%20makes%20it%20faster.
# Option 1 - für englischsprachige Texte
if (!require("lexicon")) install.packages("lexicon") 
dta_lemmatized <- tokens_replace(tokens(dta_toks), pattern = lexicon::hash_lemmas$token, replacement = lexicon::hash_lemmas$lemma)
# Option 2 - besser für deutsche und andere nicht-englische Texte
library(udpipe)
# Detusches Sprachmodell herunterladen
ud_model <- udpipe_download_model("german")
ud_model <- udpipe_load_model(ud_model)
dta_annotated <- udpipe_annotate(ud_model, dta_cor)
dta_annotated <- as.data.frame(dta_annotated)

dta_annotated[, c("token", "lemma", "upos")]

# Was ist UDPipe? 
# https://cran.r-project.org/web/packages/udpipe/vignettes/udpipe-annotation.html
# Diese Seite erklärt auch, wie man vorgeht, wenn der Text bereits Tokenisiert ist
# Was ist part-of-speech tagging? 
# https://www.freecodecamp.org/news/an-introduction-to-part-of-speech-tagging-and-the-hidden-markov-model-953d45338f24/
# ...oder Wikipedia: https://de.wikipedia.org/wiki/Part-of-speech-Tagging

# Custom preprocessing: Lemmatisierung mit importiertem Wörterbuch
# Tutorial: https://tm4ss.github.io/docs/Tutorial_3_Frequency.html
# Lemma-Wörterbuch: https://github.com/tm4ss/tm4ss.github.io/blob/master/resources/baseform_en.tsv
# Diese Methode ist jedoch nicht so leicht umzusetzen, da Lemma-Wörterbücher nicht so leicht zu 
# bekommen sind wie beispielsweise Stoppwortlisten. 
# Das angegebene Wörterbuch ist für Englisch und lässt sich somit nicht auf unser Beispielkorpus 
# anwenden. Das generelle Vorgehen wäre aber grundsätzlich wie folgt: 
lemma_data <- read.csv("downloads/baseform_en.tsv", encoding = "UTF-8")
dta_toks <- dta_cor %>% 
  tokens_replace(lemma_data$inflected_form, lemma_data$lemma, valuetype = "fixed") 


# Bisher sind alle Änderungen, die wir vorgenommen haben, nur im RStudio gespeichert, nicht 
# in den Dateien selber. Um eine Liste aller Tokens in unseren Texten zu speichern, könnten 
# wir beispielsweise wieder die Funktino walk2 in Verbindung mit einer R base Funktion wie 
# writeLines oder write.table nutzen. 
library(purrr)
docnames <- dta_toks$Titel # Dateinamen-Liste
docnames <- map(docnames, paste0, ".txt", sep="")
walk2(dta_toks, docnames, write.table, quote=FALSE, row.names = FALSE, col.names=FALSE)


# Ressourcen
# Tools für die Lemmatisierung und part-of-speech-tagging: https://www.clarin.eu/resource-families/tools-part-speech-tagging-and-lemmatization
# Tools für orthographische Normalisierung: https://www.clarin.eu/resource-families/tools-normalisation
# Tool OrthoNormal: https://exmaralda.org/de/orthonormal-de/
# Normalisierungsrichtlinien für OrthoNormal:  siehe S. 5 für Unterschied Normalisierung, Lemmatisierung, POS-Tagging
# Tutorial tip: https://tm4ss.github.io/docs/index.html
