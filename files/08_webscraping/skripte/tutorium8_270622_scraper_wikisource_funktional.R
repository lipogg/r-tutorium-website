# R Tutorium 
# 8. Sitzung: Web Scraping und APIs
# 27.06.2022
# Lisa Poggel

# In unserem ersten Wikisource-Scraper haben wir eine for-Schleife verwendet, um die Ausführung
# von unserem Code zu kontrollieren: Unsere Schleife ist über eine Liste von suburls iteriert 
# und jedes Mal wurden Befehle aus dem Schleifenkörper ausgeführt. Während for-loops und andere 
# Kontrollstrukturen in Programmiersprachen wie Python sehr wichtig sind, ist R eigentlich nicht 
# für diesen Programmierstil konzipiert. Das bedeutet, dass Schleifen zwar verwendet werden 
# können, aber das resultiert oft in einer längeren Laufzeit und wird allgemein als eine weniger 
# elegante Lösung angesehen. R ist stattdessen für die sogenannte funktionale Programmierung 
# optimiert. Funktionale Programmierung ist ein Programmierparadigma, das auf Funktionen anstelle 
# einer Abfolge von Befehlen setzt, um Aufgaben auszuführen. Siehe auch: https://en.wikipedia.org/wiki/Functional_programming 

# Dieses Skript illustriert, wie ein funktionaler Ansatz für einen Wikisource-scraper aussehen könnte. 
# Dazu wird mehrfach die Funktion map() aus dem purrr Paket verwendet, um die Schleife zu ersetzen. 
# Für mehr Informationen zu purrr und map() siehe auch https://purrr.tidyverse.org/index.html und 
# https://b-rodrigues.github.io/modern_R/functional-programming.html#functional-programming-with-purrr

install.packages("rvest")
install.packages("stringi")
install.packages("purrr")
library(rvest)
library(stringi)
library(purrr)

setwd("/Users/gast/tutorium")

url <- "https://de.wikisource.org/wiki/Kinder-_und_Hausm%C3%A4rchen"

# HTML parsen und Links extrahieren
suburls <- url %>%
  read_html() %>% # Klammer optional
  html_nodes(xpath = "//div[1]/table[2]/tbody/tr/td[position()>1]/a") %>% 
  html_attr("href") %>%
  stri_paste("https://de.wikisource.org", .)
head(suburls)

# Text zwischen paragraph-tags (<p></p>) extrahieren
# map() nimmt eine Liste und eine Funktion als Input und wendet die Funktion auf jedes Listenelement
# an. In diesem Fall nimmt beispielsweise map(html_nodes, .. ) eine Liste HTML-Dokumente als Input 
# und gitb eine Liste zurück, bei der jedes Element wiederum eine Liste von <p>-Elementen aus dem 
# Input-HTML-Dokument enhält. 
maerchentexte <- suburls %>%
  map(read_html) %>%
  map(html_nodes, xpath = "//p[not(preceding::h2)]") %>%
  map(html_text) 
typeof(maerchentexte) # output ist Liste von Listen
maerchentexte[1]

# Dateinamen erstellen, wieder mithilfe der map()-Funktion
filenames <- suburls %>%
  map(basename) %>% # Anfang der URL entfernen
  map(URLdecode) %>% # URL dekodieren
  stri_trans_general("de-ASCII; Latin-ASCII") %>% # ä,ö,ü zu ae, oe, ue konvertieren
  stri_paste(".txt") 
head(filenames) 


# Jedes Element der maerchentexte-Liste in eine txt-Datei schreiben und im Arbeitsverzeichnis 
# speichern. Die Funktion walk2() ist ähnlich wie map(), aber nimmt zwei Elemente anstatt nur 
# einem sowie eine Funktion als Input. Sie greift parallel auf beide Listen zu und wendet die 
# Funktion, in diesem Fall write.table() auf beide Listen an. Das heißt, dass in jedem Schritt
# ein Element maerchentexte[i] und ein Element filenames[i] an die Funktion übergeben wird. 
# Beide Listen müssen deswegen dieselbe Länge haben. 
walk2(maerchentexte, filenames, write.table, quote=F, col.names=F, row.names=F)


