# R Tutorium 4. Sitzung
# 17.01.2022
# Lisa Poggel

install.packages("rvest")
install.packages("stringi")
library(rvest)
library(stringi)

setwd("/Users/gast/tutorium")

url <- "https://de.wikisource.org/wiki/Kinder-_und_Hausm%C3%A4rchen"

# parse website html and extract links
suburls <- url %>%
  read_html() %>% # bracket optional
  html_nodes(xpath = "//div[1]/table[2]/tbody/tr/td[position()>1]/a") %>% # position()>1 filters first <td> element
  html_attr("href") %>%
  stri_paste("https://de.wikisource.org", .) # . is a placeholder, it is used to change the input position/order of the result of the previous function
suburls #check output

# another way to filter unwanted list elements:
# suburlsNew <- suburlsNew[which(regexpr("\\d{4}", suburlsNew) >=1)] 

for(i in seq_along(suburls)) {    
  
  maerchen <- suburls[i] 
  
  # extract text from within paragraph tags (<p></p>)
  maerchentext <- maerchen %>%
    read_html() %>% 
    html_nodes(xpath = "//p[not(preceding::h2)]") %>% # exclude everything after <h2> tag
    html_text()
  
  # create file name
  # URLdecode decodes URL encoding (f.e. %C3%A4 for ä) and returns Umlaute. This can later cause problems 
  # when these files are imported for analysis. It is therefore recommended to avoid Umlaute in filenames.
  filename <- suburls[i] %>%
    basename() %>% # strip beginning of the URL
    URLdecode() %>% # decode URL encoding
    stri_trans_general("de-ASCII; Latin-ASCII") # convert ä,ö,ü to ae, oe, ue
  
  # another way to create filenames
  # filename <- substring(suburls[i], first = 32)
  
  # write maerchentext to txt file, save file in working directory
  write.table(maerchentext, 
              file = paste(filename, ".txt", sep=""), 
              quote=FALSE,
              col.names=FALSE,
              row.names=FALSE)
  
}
