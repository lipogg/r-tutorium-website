# R Tutorium 
# 8. Sitzung: Web Scraping und APIs
# 27.06.2022
# Lisa Poggel

# Dieses Skript extrahiert den Fließtext aller Werke von Franz Kafka von projekt-gutenberg.org und 
# schreibt jeden Text in eine Datei im Arbeitsverzeichnis

install.packages(c("rvest", "stringi", "stringr", "purrr"))
library(rvest)
library(stringi)
library(stringr)
library(purrr)

setwd("/Users/gast/tutorium")

# 1. Startseite festlegen
# Zuerst brauchen wir eine Liste aller URLs zu Texten von Kafka auf projekt-gutenberg.org
# Diese finden wir auf der Seite "Alle Werke":
url <- "https://www.projekt-gutenberg.org/info/texte/allworka.html"

# 2. Aus der Liste aller Werke alle Texte von Kafka extrahieren
# Zum Suchen können wir XPath verwenden. Wir öffnen im Browser "Elemente untersuchen" und 
# inspizieren den XPath Pfad für uns interessierende Elemente:  
# Rechtsklick auf das Element in den Entwicklertools -> Copy -> Copy full XPath 
# XPath-Pfade für ausgewählte Werke inspizieren, um zu entscheiden, wie nach allen Stücken gesucht werden kann : 
# /html/body/dl/dt[972] - Autorname Kafka, Franz 
# /html/body/dl/dd[4828]/a   - Amerika (erstes Werk)
# /html/body/dl/dd[4829]/a - Aphorismen
# /html/body/dl/dd[4844]/a - Tagebuecher 1910-1923 (letztes Werk)
# /html/body/dl/dt[973] - Autorname Kahane, Arthur

# Strategie: Wir können entweder den Index der Elemente nutzen, also alle a-Elemente 
# extrahieren, denen ein dd-Element mit den Indexnummern zwischen 4828 und 4844 vorausgeht.
# Oder wir schreiben einen XPath Ausdruck, der alle Elementen zwischen den beiden Autornamen 
# findet. Im Forum stackoverflow finden wir diesen XPath-Pfad: 
# https://stackoverflow.com/questions/45966049/xpath-get-elements-that-are-between-2-elements-where-we-cant-use-an-id-or-text
# //a[preceding-sibling::b[1]='Account Detail' and following-sibling::b]

# Wie müssten wir den Suchpfad für unsere Suche umschreiben? 
# //dd[preceding-sibling::dt[1]='Kafka,Franz' and following-sibling::dt]/a
# Welche Vor- und Nachteile haben die beiden möglichen Strategien?  
# Wie würden wir vorgehen, wenn uns nicht die Werke von Kafka, sondern alle Werke einer 
# bestimmten Textkategorie interessieren würden? Wir könnten alle dd-Elemente extrahieren, 
# bei denen mit dem i-Element eine bestimmte Kategegorie angegeben ist. 

# HTML parsen
suburls <- url %>%
  read_html() %>% # Klammer optional
  html_nodes(xpath = "//dd[preceding-sibling::dt[1]='Kafka, Franz' and following-sibling::dt]/a") %>%
  html_attr("href") 
suburls # Links sind noch unvollständig
# Statt ../../ am Anfang müssen wir https://www.projekt-gutenberg.org/ einsetzen: 
suburls <- suburls %>%
  stri_replace_all_regex("../../", "https://www.projekt-gutenberg.org/") 
suburls # überprüfen: vollständig!


# 3. Liste von Dateinamen vorbereiten
filenames <- url %>%
  read_html() %>% # Klammer optional
  html_nodes(xpath = "//dd[preceding-sibling::dt[1]='Kafka, Franz' and following-sibling::dt]/a") %>%
  html_text %>%
  stri_trans_general("de-ASCII; Latin-ASCII") %>% # Umlaute zu ae, oe, ue, .. konvertieren
  map(str_squish) %>% # wiederholte Leerzeichen entfernen
  stri_replace_all_regex(" ", "-") %>% 
  paste("Kafka", ., sep = "_") 
filenames 

# 4. Text von den einzelnen Seiten der Werke extrahieren und in Dateien schreiben. 
# Dazu inspizieren wir zunächst wieder den Quelltext von ein oder zwei Beispielseiten: 
# Durch Klick auf den Button "Weiter" öffnet sich jeweils die nächste Seite, auf der 
# letzten Seite fehlt dieses Element. 

# Strategie: Wir können also zum Beispiel einfach von der Startseite ausgehend den Link, der als Attribut "href" 
# im a-Element mit dem Text "weiter&nbsp;>>" steht, extrahieren, dann den Text auf der Seite extrahieren, 
# mit dem Text der vorherigen Seiten zusammenfügen und dann wieder wie zuvor auf die nächste Seite wechseln. 
# Das können wir so lange machen, bis kein a-Element mit dem Text "weiter&nbsp;>>" mehr gefunden wird. 
# Alternativ könnten wir aber auch einfach die Liste aller Textseiten auf der Seite "Inhaltsverzeichnis" nutzen, 
# um direkt eine Liste aller Kapitel zu bekommen, die wir parsen können. Diese Strategie erscheint vorteilhaft. 
# Das Inhaltsverzeichnis befindet sich immer auf einer Seite mit dem Zusatz "index.html": 
# https://www.projekt-gutenberg.org/kafka/tagebuch/index.html
# https://www.projekt-gutenberg.org/kafka/amerika/index.html
# Wir können also die Liste der suburls nocheinmal bearbeiten, indem wir die URLs jeweils bis zum letzten '/'
# kürzen und "index.html" anfügen. Hierzu können wir die Funktion dirname() verwenden: 
?dirname

suburls <- suburls %>%
  dirname() %>%
  paste0("/index.html") 
suburls # überprüfen

# Jetzt können wir zum Beispiel eine Schleife konstruieren, um über die Liste der Inhaltsverzeichnis-Seiten 
# zu iterieren und für jede Seite eine Liste aller Unterseiten zu extrahieren, die wir dann parsen können. 
# Hier könnten wir zum Beispiel auch die Titelseite herauslassen, falls wir diese nicht benötigen. 
# Für unseren Anwendungsfall brauchen wir nur den reinen Fließtext und also weder Titel noch Kapitelüberschriften. 
# Der Code aus der Schleife kann zunächst an einem Beispieltext getestet werden.

for(i in seq_along(suburls)) {    
  
  werk <- suburls[i] 
  # URL bis "index.html" extrahieren
  werkdir <- dirname(werk)
  # Liste von URLs von der Seite "Inhalt" extrahieren
  inhalturls <- werk %>%
    read_html() %>% 
    html_nodes(xpath = "//html/body/ul/li[position()>=1]/a") %>% # Titelseite herausfildern: position()>1 schließt erstes Element aus
    html_attr("href") %>%
    stri_c(werkdir, "/", .) %>% # . ist ein Platzhalter für den Input und kann verwendet werden, um die Reihenfolge der zusammengefügten Strings zu ändern
    discard(is.na) # Fehler vorbeugen: im Fall eines Textes war das Inhaltsverzeichnis falsch aufgebaut, sodass ein NA-Element in der Liste war
  # Text aller Seiten in der Liste extrahieren: 
  seitentext <- inhalturls %>%
    map(read_html) %>% 
    map(html_nodes, xpath = "//p") %>% 
    map(html_text) %>%
    unlist
  # Extrahierte Texte in einen langen Text zusammenfügen
  werktext <- paste(seitentext, collapse = "\n")
  # Dateiname festlegen
  filename <- filenames[i]
  # werktext in eine txt-Datei schreiben und im Arbeitsverzeichnis speichern
  write.table(werktext, 
              file = paste(filename, ".txt", sep=""), 
              quote=FALSE,
              col.names=FALSE,
              row.names=FALSE)
  
}
