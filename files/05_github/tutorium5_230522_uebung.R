# R Tutorium 
# Übung: Wiederholung
# 23.05.2022
# Lisa Poggel

# Ladet zunächst die XML-TEI Version zu jeweils drei Dramen des deutschsprachigen Dramenkorpus von
# https://dracor.org/ herunter und speichert sie im lokalen Verzeichnis "Data" in eurem Repository 
# r-tutorium. "Pusht" die Änderungen über das RStudio in Remote Repository auf GitHub. 
# Wenn alle Teilnehmer:innen diesen Arbeitsschritt durchgeführt haben, "pullt" die aktuelle Version 
# des r-tutorium Repositories. 

# Achtung: Da wir ja ein RProject erstellt haben, müssen für diese Aufgaben keine absoluten 
# Dateipfade mit dem "setwd" Befehl mehr angegeben werden. Es reichen die relativen Pfade. 

# Aufgabe 1: Ladet alle Dramen aus dem "Data" Unterverzeichnis in eine Liste.
# Nennt das Datenobjekt "data_1". Ersetzt alle Vorkomnisse eines Namens durch euren 
# eigenen Namen. Sucht nach allen Exklamationen im Sprechtext. Sucht mithilfe von Look-
# arounds und stringr-Funktionen nach allen Sätzen, die im Sprechtext auf eine Exklamation
# folgen. Ersetzt alle <speaker></speaker> tags (oder einen beliebigen anderen Tag) durch
# den Tag <person></person>. Speichert die bearbeiteten Dramen im Unterverzeichnis "Output".
# Pusht eure Änderungen in das GitHub repository. 
# Hinweis: Wenn es nicht explizit dabei steht,müsst ihr selbst entscheiden, ob sich 
# jeweils regex oder xpath besser zur Lösung eignen. 

# Aufgabe 2: Ladet alle Dramen aus dem "Data" Unterverzeichnis in eine Liste.
# Nennt das Datenobjekt "data_2". Zählt, wieviele Akte, Szenen, Sprecher*innen und/oder
# Bühnenanweisungen jedes Stück hat und speichert diese Information als Dataframe. 
# Der Dataframe sollte neben den Spalten mit der Anzahl der Akte, Szenen, usw. auch eine 
# Spalte mit dem Dateinamen und Spalten mit dem Namen des Stücks, des Autors und des 
# Publikationsjahrs enthalten. Diese Informationen können aus dem TEI-Header entnommen 
# werden. Schreibt den Dataframe zuletzt in eine csv-Datei und speichert diese im 
# Unterverzeichnis "Output". Pusht eure Änderungen in das GitHub repository. 



