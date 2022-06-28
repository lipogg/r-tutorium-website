# Lösung zum 2. Übungszettel 

# Wichtig: Für jede der Aufgaben gibt es mehrere Lösungsmöglichkeiten, diese Lösung ist also nur 
# eine von vielen. Grundsätzlich gilt: Wenn euer Skript das macht, was es soll, ist die Lösung 
# richtig. Ob es eine gute Lösung ist, hängt davon ab, welche Fehler wir vermeiden wollen, ob 
# Effizienz wichtig ist und was wir mit den gewonnenen Daten im nächsten Schritt machen wollen. 

# 1 - siehe R Skript aus der letzten Woche 

# 2

setwd("/Users/gast/Desktop/Tutorium")
library(readtext)
maerchen_df <- readtext("*.txt", docvarsfrom = "filenames", dvsep = "_", docvarnames = c("Titel", "Jahr"))

grepl("Droßelbart", maerchen_df$text) 
grep("Droßelbart", maerchen_df$text)
maerchen_df[4,3] 


# 3 
regmatches(maerchen_df$text, gregexpr("[^ ]*[tT][oö]chter", maerchen_df$text))
regmatches(maerchen_df$text, gregexpr("[^ ]*T[oö]chter", maerchen_df$text, ignore.case=TRUE))


# 4
aschenputtel <- maerchen_df$text[1]
regmatches(aschenputtel, gregexpr("[Ee]in( |e|en|es|er|em)", aschenputtel))
aschenputtel_bearb <- gsub("ein|ein(e|en|es|er|em)", "", aschenputtel)
regmatches(aschenputtel_bearb, gregexpr("Ein|Ein(e|en|es|er|em)", aschenputtel_bearb))
# Groß- und Kleinschreibung beachten!
aschenputtel_bearb <- gsub("ein|ein(e|en|es|er|em)", "", aschenputtel, ignore.case=TRUE)
regmatches(aschenputtel_bearb, gregexpr("Ein|Ein(e|en|es|er|em)", aschenputtel_bearb))
# Anstelle der Veroderung ein | ein(e|en|...) wäre es doch besser, 
# wenn wir einfach nach ein(Leerzeichen|e|en|...) suchen könnten. 
aschenputtel_bearb <- gsub("ein( |e|en|es|er|em)", "", aschenputtel, ignore.case=TRUE)


# 5
gregexpr("Aschenputtel", aschenputtel_bearb)
aschenputtel_bearb <- sub("Aschenputtel", "", aschenputtel_bearb)
gregexpr("Aschenputtel", aschenputtel_bearb)
writeLines(aschenputtel_bearb, "aschenputtel_bearbeitet.txt")


# 6
# Lösung 1: Alle Märchen nacheinander bearbeiten
maerchen_df$text[1]
maerchen_df$text[1] <- gsub("\\[[0-9]{0,5}\\]", "", maerchen_df$text[1])
maerchen_df$text[1]
aschenputtel2 <- gsub("\\[[0-9]{1,4}\\]", "", aschenputtel)
# Alle aufeinmal
maerchen_df$text <- gsub("\\[[0-9]{0,5}\\]", "", maerchen_df$text)
# Lösung 2: Schleife, die über die Spalte "text" iteriert
for(i in seq_along(maerchen_df$text)){
  maerchen_df$text[i] <- gsub("\\[[0-9]{0,5}\\]", "", maerchen_df$text[i])
}
for(i in 1:length(maerchen_df$text)){
  maerchen_df$text[i] <- gsub("\\[[0-9]{0,5}\\]", "", maerchen_df$text[i])
}
?seq_along
# Lösung 3: Mithilfe der Funktionen lapply oder map (--> "funktionale Programmierung", dazu später mehr)
# Diese Lösung ist jedoch etwas komplexer. Insbesondere zeigt sich, dass gsub() und andere R base Funktionen 
# nicht immer gut mit Funktionen wie lapply() oder map() verwendet werden können: 
# lapply() Function: https://www.guru99.com/r-apply-sapply-tapply.html
lapply(maerchen_df$text, gsub, '\\[[0-9]{0,5}\\]','') # wirft einen Fehler
?lapply
# map Function: ?map ?map_chr
install.packages("purrr")
library(purrr)
map_chr(maerchen_df, gsub, '\\[[0-9]{0,5}\\]','') # wirft einen Fehler
map_chr(maerchen_df$text, ~gsub('\\[[0-9]{0,5}\\]','', .)) # nur so geht es
?map_chr
# Das Paket stringr, mit dem wir uns in Aufgabe 7 befassen, produziert hier weniger Schwieirigkeiten. 

# Ergebnisse speichern: Als erstes Arbeitsverzeichnis neu setzen
unlink("corpus_cleaned", recursive = T) # falls bereits ein Ordner "corpus" existiert" wird dieser gelöscht
dir.create("corpus_cleaned")
cwd <- getwd()
new_wd <- paste(cwd, "/corpus_cleaned", sep="")
setwd(new_wd)
getwd()
# Lösung 1: Alle Märchen nacheinander speichern
maerchen_df$doc_id
writeLines(maerchen_df$text[1], maerchen_df$doc_id[1])
# Lösung 2: Schleife
for(i in seq_along(maerchen_df$text)){
  writeLines(maerchen_df$text[i], maerchen_df$doc_id[i])
}
# Lösung 3: Mithilfe der Funktion walk2
walk2(maerchen_df$text, maerchen_df$doc_id, writeLines) 
?walk2

# 7
# https://stringr.tidyverse.org/
# zu 1 
install.packages("stringr")
library(stringr)

str_extract(maerchen_df$text, "Droßelbart") 
str_extract_all(maerchen_df$text, "Droßelbart")

str_match(maerchen_df$text, "Droßelbart")
str_subset(maerchen_df$text, "Droßelbart")
str_count(maerchen_df$text, "Droßelbart")
str_locate(maerchen_df$text, "[^ ]*[tT][oö]chter")

str_replace(maerchen_df$text[1], "Aschenputtel", "")
str_replace_all(maerchen_df$text[1], "Aschenputtel", "")
