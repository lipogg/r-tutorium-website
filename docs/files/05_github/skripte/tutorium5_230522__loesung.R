# R Tutorium 
# Lösung zur Übung: Wiederholung
# 23.05.2022
# Lisa Poggel

# Vorab: Die beiden Aufgaben waren nicht leicht und haben viel Recherche in der Dokumentation des 
# xml2 Pakets erfordert: https://cran.r-project.org/web/packages/xml2/xml2.pdf 

# Aufgabe 1
## "Ladet alle Dramen aus dem "Data" Unterverzeichnis in eine Liste. Nennt das Datenobjekt "data_1"." 
library(xml2)
library(stringr)
library(purrr)
setwd("/05_github-uebung/daten")
files <- list.files(pattern = ".xml") 
data_1 <- map(files, read_xml)
# Alternativ kann dieser Schritt auch mithilfe einer Schleife oder beispielsweise mit der Funktion as_list() 
# aus dem xml2 Paket erfolgen --> Siehe Dokumentation: https://cran.r-project.org/web/packages/xml2/xml2.pdf.

## "Ersetzt alle Vorkomnisse eines Namens durch euren eigenen Namen."
# Beispiel: Alle Vorkomnisse von "Wasili Gurcinin" in Kotzebues Graf Benjowsky durch "Lisa Gurcinin" ersetzen
# Zunächst wollen wir nur das Drama von Kotzebue aus unserer Liste in einem Datenbobjekt "kotzebue" zwischenspeichern.
# Wenn wir uns das Objekt data_1 in der Konsole anzeigen lassen, sehen wir, dass es eine geschachtelte Liste ist (Englisch: "nested list"):
data_1
# Um auf ein Element zuzugreifen, müssen wir deswegen einen doppelten Zugriffsoperator verwenden:
kotzebue <- data_1[[3]] 

# Strategie 1: XML in einen character string umwandeln, Änderungen mithilfe von Regex vornehmen und wieder 
# zurück in XML umwandeln
# Zunächst müssen wir überprüfen, was unser Obkekt kotzebue überhaupt für einen Datentyp hat
typeof(kotzebue) # kotzebue ist ein character vector
# Um den character vector kotzebue in einen character string zu konvertieren, können wir die bereits 
# bekannte Funktion paste() verwenden: 
kotzebue <- paste(kotzebue, sep="", collapse=NULL)
kotzebue # Ergebnis überprüfen
# Der resultierende String hat wiederholte Leerzeichen, die wir entfernen sollten, bevor wir weitermachen.
# Um überflüssige Leerzeichen zu entfernen, verwende ich hier die Funktion str_squish(). 
kotzebue <- str_squish(kotzebue)
kotzebue # sieht besser aus
# Jetzt können wir "Wasili" durch "Lisa" bzw. "wasili" durch "lisa" mit bereits bekannten stringr Funktionen ersetzen:
stringr::str_extract_all(kotzebue, "(W|w)asili") # alle Vorkomnisse anzeigen lassen
kotzebue <- stringr::str_replace_all(kotzebue, "Wasili", "Lisa")
kotzebue <- stringr::str_replace_all(kotzebue, "wasili", "lisa")
# Überprüfen, ob alle Instanzen ersetzt wurden: 
str_extract_all(kotzebue, "(L|l)isa")
# Diese Suche liefert 25, nicht 23 Ergebnisse! Es werden also auch Wortkombinationen wie "Elisabeth" gefunden. 
# Um diese auszuschließen, brauchen wir einen "negative lookbehind", der überprüft, dass zu Anfang des gesuchten 
# Strings kein Buchstabe steht.
str_extract_all(kotzebue, "(?<![a-zA-ZäöüßÜÖÄ])(L|l)isa") 
# Ganz korrekt wäre es natürlich, wenn auch nach "(?<![a-zA-ZäöüßÜÖÄ])wasili" gesucht würde. So könnte sicher 
# ausgeschlossen werden, dass sich der String wasili inmitten eines anderen Strings befindet.
# Zuletzt müssen wir den bearbeiteten String wieder in XML umwandeln. Dazu können wir das Objekt kotzebue 
# einfach mithilfe der read_xml Funktion als xml-Datei einlesen:
kotzebue_xml <- read_xml(kotzebue)
kotzebue_xml # Fertig! 

# Strategie 2: Aus der Dokumentation zur Funktion xml_text aus dem xml2 Paket können wir entnehmen, 
# dass die bereits aus der xml-Stunde bekannte Funktion xml_text() auch verwendet werden kann, um den 
# Text in einer xml-Datei anzupassen. Die Funktionsdefinition heißt "Extract or modify the text" (p. 25, https://cran.r-project.org/web/packages/xml2/xml2.pdf). 
# Eine kurze Recherche zu der Funktion hat mich auf diese Anleitung geführt: https://cran.r-project.org/web/packages/xml2/vignettes/modification.html 
# Wir schauen uns zuerst (zum Beispiel im Oxygen-Editor) die Struktur des XML Baums für Kotzebues 
# Stück an und suchen nach allen tags, die den Namen Kotzebue enthalten: 
# - "wasili_gurcinin" findet sich als Attribute "xml:id" und "id" im Header unter <listPerson><person>, 
#    und als Attribut "who" des Elements <sp> im Textkörper.
# - "Wasili" findet sich als Text zwischen den <speaker></speaker> und <stage></stage> tags, und im Sprechtext 
#    innerhalb der <p></p> tags.
# Wir müssen zunächst anhand des Attributs "xml:id" bzw. "who" alle Elemente extrahieren, die die Figur Wasili Gurcinin 
# referenzieren. Danach können wir Instanzen im Fließtext mithilfe von xml_text() ersetzen. Um die ids selbst zu ersetzen, 
# können wir die Funktino xml_attr() verwenden: https://cran.r-project.org/web/packages/xml2/vignettes/modification.html
# Die Instanzen in Header und Textkörper behandeln wir dabei separat:
kotzebue <- data_1[[3]] 
kotzebue_ns <- xml_ns(kotzebue) # Zuerst den Namespace zwischenspeichern, den brauchen wir später
kotzebue_stripped <- xml_ns_strip(kotzebue) # siehe xml-Sitzung: wir müssen den namespace zunächst entfernen, um die Datei parsen zu können
kotzebue_header <- xml_child(kotzebue_stripped,1) # Die Funktion xml_child erlaubt es, anhand des Indexes auf ein Unterelement zuzugreifen
kotzebue_text <- xml_child(kotzebue_stripped,2)
# Alle Instanzen im Header finden...
header_instances <- kotzebue_header %>% 
  xml_find_all("//person[@xml:id='wasili_gurcinin']") 
header_instances
# ... und ersetzen:
xml_attr(header_instances, "id") <- "lisa_gurcinin"
xml_attr(header_instances, "xml:id") <- "lisa_gurcinin"
xml_text(header_instances) <- "Lisa Gurcinin"
# Überprüfen, ob es geklappt hat
xml_find_all(kotzebue_header, "//person[@xml:id='wasili_gurcinin']") 
# Alle Instanzen im Textkörper finden... 
sp_instances <- xml_find_all(kotzebue_text, "//sp[@who='#wasili_gurcinin']") 
sp_instances
# ...und ersetzen. Für die ids: 
xml_attr(sp_instances, "who") <- "#lisa_gurcinin"
# Für die Instanzen in den <person> tags verwenden wir eine xpath-Abfrage, die nach allen Vorkomnissen 
# von "Wasili" bzw. "Wasili." im Text sucht: 
person_instances <- xml_find_all(kotzebue_text, "//*[text() ='Wasili']")
xml_text(person_instances) <- "Lisa" 
more_person_instances <- xml_find_all(kotzebue_text, "//*[text() ='Wasili.']")
xml_text(more_person_instances) <- "Lisa."
# Jetzt bleiben nur noch Instanzen im Sprechtext und in den Bühnenanweisungen:
text_instances <- xml_find_all(kotzebue_text, "//*[contains(text(),'Wasili')]")
# Die verbleibenden Stellen können wir zum Beispiel mithilfe einer Kombination aus xml_text() und regex austauschen: 
xml_text(text_instances) <- text_instances%>%
  xml_text()%>%
  paste(sep="")%>%
  str_squish()%>%
  str_replace_all("Wasili", "Lisa")
# Überprüfen
xml_find_all(kotzebue_text, "//sp[@who='#wasili_gurcinin']") 
xml_find_all(sp_instances, "person") 
xml_find_all(kotzebue_text, "//*[contains(text(),'Wasili')]") # hat geklappt!
# Zuletzt müssen wir den Namespace wieder einfügen: 
xml_attrs(kotzebue)
xml_attrs(kotzebue) <- c(xmlns=as.character(kotzebue_ns))
xml_attrs(kotzebue) # Hat geklappt!
data_1[[3]] # Überprüfen

## "Sucht nach allen Exklamationen im Sprechtext." 
# Sprechtext als ein langer character vector extrahieren, sodass der Text aus jedem paragraph-Element 
# ein Element des Vektors ist. 
# Bisher haben wir erst den namespace entfernt, bevor wir die Funktion xml_find_all verwendet haben. Aus der Dokumentation 
# zur xml_find_all Funktion lässt sich entnehmen, dass der Namespace direkt als Argument "ns" an die Funktion übergeben werden kann. 
# Eine weitere und einfachere Option ist, den xpath Ausdruck so zu ändern, dass nur nach dem Namen des Knotens ohne den 
# Namespace-Prefix gesucht wird. So muss der namespace nicht erst gelöscht werden. Siehe dazu auch: https://riptutorial.com/xpath/topic/3095/select-nodes-with-names-equal-to-or-containing-some-string
# Das ist praktisch, wenn wir später die Änderungen in eine neue xml-Datei schreiben wollen, dann müssen wir den 
# namespace nicht erst wieder hinzufügen. 
spoken_text <- data_1 %>% 
  map(xml_find_all, "//*[name()='p']") %>% 
  map(xml_text) %>%
  unlist() %>%
  paste(sep="") %>%
  str_squish() 
spoken_text

# Sprechtext nach allen Zeichen durchsuchen, die kein Satzende markieren (?, !, .), gefolgt von einem Ausrufezeichen: Zwei Möglichkeiten
str_extract_all(spoken_text, "([a-zA-ZüöäßÜÖÄ\\,\\-–]|\\s)+!")
str_extract_all(spoken_text, "[^!\\?\\.]+!")

## "Sucht mithilfe von Lookarounds und stringr-Funktionen nach allen Sätzen, die im Sprechtext auf eine Exklamation folgen." 
str_extract_all(spoken_text, "(?<=!)[^!\\?\\.]+(!|\\?|\\.)")

## Ersetzt alle <speaker></speaker> tags (oder einen beliebigen anderen Tag) durch den Tag <person></person>. 
# Aus der Dokumentation zum xml2 Paket können wir die Funktion xml_set_name entnehmen. Definition: "Modify the (tag) name of an element". 
# Als Argument nimmt die Funktion entweder ein Dokument, ein node, oder ein nodeset. Mit "nodes", also Knoten, sind die Elemente 
# des XML-Dokuments gemeint. Wenn wir eine Suchfunktion wie xml_find_all() anwenden, wird uns so ein nodeset zurückgegeben.
# Den Namespace übergeben wir wieder direkt der Funktion xml_find_all(). 
all_speakers <- data_1 %>%
  map(xml_find_all, "//*[name()='speaker']") 
all_speakers # eine Liste mit einem "xml_nodeset" zu jedem Text
# Um alle <speaker> tags umzubenennen, können wir die Funktion xml_set_name() verwenden: https://cran.r-project.org/web/packages/xml2/vignettes/modification.html
map(all_speakers, xml_set_name, "person")  
# Zuletzt stichprobenhaft überprüfen, ob die Änderungen im Objekt data_1 gespeichert wurden:
xml_find_all(data_1[[1]], "//*[name()='speaker']") # hat geklappt!
xml_find_all(data_1[[1]], "//*[name()='person']")

## "Speichert die bearbeiteten Dramen im Unterverzeichnis "Output"."
# Wenn wir nur eine einzige Datei schreiben wollen, können wir das ganz einfach mit der Funktion write_xml() machen.  
setwd("/05_github-uebung/output")
write_xml(data_1[[3]], "kotzebue_bearbeitet.xml")
# Unser bearbeitetes Datenobjekt data_1 ist aber eine Liste. Wir müssen also entweder map() oder eine Schleife 
# verwenden, um die Dateien zu speichern. Wir wollen dabei jewiels den Dateinamen um dem Zusatz "bearbeitet" ergänzen. 
# Zum Erstellen der Dateinamen können wir das Objekt "files" nehmen, das wir ganz am Anfang erstellt haben: 
files # Liste aller Dateinamen 
for(i in 1:length(data_1)){
  filename <- paste0("bearbeitet_", files[i])
  write_xml(data_1[[i]], filename)
}
# Fertig!


# Aufgabe 2
## "Ladet alle Dramen aus dem "Data" Unterverzeichnis in eine Liste. Nennt das Datenobjekt "data_2"." 
setwd("/05_github-uebung/daten")
files <- list.files(pattern = ".xml") 
data_2 <- map(files, read_xml)

## "Zählt, wieviele Akte, Szenen, Sprecher*innen und/oder Bühnenanweisungen jedes Stück hat und speichert diese Information als Dataframe." 
# Akte
no_of_acts <- data_2 %>%
  map(xml_ns_strip) %>%
  map(xml_find_all, "//div[@type='act']") %>% # liefert eine Liste mit einem "xml_nodeset" zu jedem Text
  map(length) # berechnet die Länge jedes nodesets: diese entspricht der Anzahl der Akte
no_of_acts
# verschachtelte Liste in einen einfachen Vektor umwandeln:
no_of_acts <- unlist(no_of_acts)
# Szenen
no_of_scenes <- data_2 %>%
  map(xml_ns_strip) %>%
  map(xml_find_all, "//div[@type='scene']") %>%
  map(length)
no_of_scenes <- unlist(no_of_scenes) 
# Sprecher*innen
no_of_speakers <- data_2 %>%
  map(xml_ns_strip) %>%
  map(xml_find_all, "//castItem") %>%
  map(length)
no_of_speakers <- unlist(no_of_speakers)
# Dataframe erstellen
data_2_df <- data.frame(filename=files, acts=no_of_acts, scenes=no_of_scenes, speakers=no_of_speakers)
data_2_df # überprüfen

## "Der Dataframe sollte neben den Spalten mit der Anzahl der Akte, Szenen, usw. auch eine 
## Spalte mit dem Dateinamen und Spalten mit dem Namen des Stücks, des Autors und des 
## Publikationsjahrs enthalten. Diese Informationen können aus dem TEI-Header entnommen werden." 
# Die Dateinamen haben wir im Schritt zuvor bereits hinzugefügt und aus dem "files" Vektor entnommen, 
# den wir anfangs erstellt hatten. 
# Die anderen Informationen entnehmen wir aus dem Header:
# Titel
titles <- data_2 %>%
  map(xml_find_first,"//title[@type='main']")%>%
  map(xml_text)
titles <- unlist(titles)
# Autoren
authors <- data_2 %>%
  map(xml_find_first,"//persName")%>%
  map(xml_text)
authors
# Diese Lösung ist nicht ideal, da Vor- und Nachnamen so einen einzigen String ohne Leerzeichen bilden
# Das Problem lässt sich lösen, indem zwei Listen mit Vor- und Nachnamen mit einem Leerzeichen als Separator
# zusammengefügt werden:
forenames <- data_2 %>%
  map(xml_find_first,"//forename")%>%
  map(xml_text)
surnames <- data_2 %>%
  map(xml_find_first,"//surname")%>%
  map(xml_text)
authors <- map2(forenames, surnames, paste, sep= " ")
authors <- unlist(authors)
authors # so sieht es besser aus
# Publikationsjahre
years <- data_2 %>%
  map(xml_find_first, "//date") %>%
  map(xml_attr, "when")
years <- unlist(years) 
# years Vektor in integer-Vektor umwandeln: 
years <- as.numeric(years)
# Die neuen Vektoren zum Dataframe hinzufügen
data_2_df <- cbind(data_2_df, author=authors)
data_2_df <- cbind(data_2_df, title=titles)
data_2_df <- cbind(data_2_df, year=years)
data_2_df

## "Schreibt den Dataframe zuletzt in eine csv-Datei und speichert diese im Unterverzeichnis "Output"." 
setwd("/05_github-uebung/output")
write.table(data_2_df, "corpus_data.csv", row.names=FALSE, quote=FALSE)


