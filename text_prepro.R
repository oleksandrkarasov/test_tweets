# Remove all files in memory
rm(list = ls())
.rs.restartR()

#install.packages("tm")

# Open library
library(dplyr)
library(tidyverse)
library(tm)


# Open file
df = read.csv('Rand_sample_database_UTF8.csv')
df <- tibble::rowid_to_column(df, "rowid")

# Removing URLs and emoji, nicknames, whitespaces, hashtags.
# Punctuation remains at the moment
df$text2 <- df$text1 %>% 
  str_remove_all("#.*")%>%
  str_remove_all("https.*")%>%
  str_remove_all("http.*")%>%
  str_remove_all("@.*")%>%
  str_remove_all("<U+[[:alnum:]].*")%>%
  str_remove_all("[[:emoji:]]")%>%
  tm::stripWhitespace()


# Exploring the data
str(df)
summary(df)
head(df$text2)

# In column text1 replace empty rows with NAN values
df$text2[df$text2 == ""] <- NA
head(df$text2) # check do you still have "" rows?

# Data preparation
## Select columns and remove rows where text1 is NAN
df <- df %>% 
  select(rowid,lat2,lon2,user_id,text1,text2,retweeted,lang,id,created_at) %>%
  drop_na(text2)
head(df$text2) # check do you still have empty rows?

# Estimating number of characters in 
df$noChar <- nchar(df$text2)

# Filtering out too short tweets
df<-filter(df, noChar>=10)

head (df)
df2 <- df %>% select(text2)



# Save data
write.csv(df,"Tweets_full.csv", row.names = FALSE)
write.csv(df2,"Tweets.csv", row.names = FALSE)
