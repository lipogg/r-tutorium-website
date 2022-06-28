# Lösung zur Übungsaufgabe 1

# 1
setwd("/Users/gast/Desktop/")

# 2
install.packages("readtext")
library(readtext)
maerchen <- readtext("Maerchen/*.txt")

# 3
maerchen
?readtext

# 4
maerchen_dateinamen <- maerchen$doc_id
maerchen_dateinamen

# 5
aschenputtel <- maerchen$text[1]
print(aschenputtel)

# 6
colnames(maerchen)
colnames(maerchen)[1] <- "dateiname"
maerchen

# 7
write.table(maerchen, "maerchen.csv", sep = ",", row.names = F)

# 8
maerchen_df <- read.csv("maerchen.csv")
View(maerchen_df) #View ist eine weitere Möglichkeit, sich den Output anzeigen zu lassen

