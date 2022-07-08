# R Tutorium 
# 8. Sitzung: Web Scraping und APIs
# 27.06.2022
# Lisa Poggel

# Dieses Skript extrahiert den Fließtext aller Märchen der Gebrüder Grimm von wikisource.org und 
# schreibt jedes Märchen in eine Datei im Arbeitsverzeichnis.

install.packages("rvest")
install.packages("stringi")
library(rvest)
library(stringi)

setwd("/Users/gast/tutorium")

url <- "https://de.wikisource.org/wiki/Kinder-_und_Hausm%C3%A4rchen"

# Website HTML-Baum parsen und Links der einzelnen Märchen extrahieren
suburls <- url %>%
  read_html() %>% # bracket optional
  html_nodes(xpath = "//div[1]/table[2]/tbody/tr/td[position()>1]/a") %>% # position()>1 filtert das erste <td> Element heraus
  html_attr("href") %>%
  stri_paste("https://de.wikisource.org", .) # . ist ein Platzhalter, es wird verwendet um die Reihenfolge der Funktionsargumente umzukehren 
suburls # überprüfen

# Eine andere Möglichkeit, nicht benötigte Listenelemente herauszufiltern
# suburlsNew <- suburlsNew[which(regexpr("\\d{4}", suburlsNew) >=1)] 

for(i in seq_along(suburls)) {    
  
  maerchen <- suburls[i] 
  
  # Text aus den paragraph-Elementen extrahieren (<p></p>)
  maerchentext <- maerchen %>%
    read_html() %>% 
    html_nodes(xpath = "//p[not(preceding::h2)]") %>% # Alles nach dem <h2>-Tag ausschließen
    html_text()
  
  # Dateinamen erstellen
  # URLdecode dekodiert die URLs (z.B. %C3%A4 für ä) und gibt Umlaute aus. Diese können später jedoch 
  # Probleme verursachen, wenn die Dateien eingelesen werden sollen. Es ist deswegen empfehlenswert, 
  # Umlaute in Dateinamen zu vermeiden.
  filename <- suburls[i] %>%
    basename() %>% # Anfang der URL entfernen
    URLdecode() %>% # URL dekodieren
    stri_trans_general("de-ASCII; Latin-ASCII") # ä,ö,ü zu ae, oe, ue 
  
  # Noch eine Möglichkeit, Dateinamen zu erstellen
  # filename <- substring(suburls[i], first = 32)
  
  # maerchentext in eine txt-Datei schreiben und im Arbeitsverzeichnis speichern
  write.table(maerchentext, 
              file = paste(filename, ".txt", sep=""), 
              quote=FALSE,
              col.names=FALSE,
              row.names=FALSE)
  
}
