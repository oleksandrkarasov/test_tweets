
#install.packages("fastText")
#install.packages("ISOcodes")
#install.packages("dplyr")

#Libraries
library(fastText)
library(ISOcodes)
library(dplyr)

#Arranging language codes
fasttext_supported_languages = c('af', 'als', 'am', 'an', 'ar', 'arz', 'as', 'ast', 'av', 
                                 'az', 'azb', 'ba', 'bar', 'bcl', 'be', 'bg', 'bh', 'bn',
                                 'bo', 'bpy', 'br', 'bs', 'bxr', 'ca', 'cbk', 'ce', 'ceb',
                                 'ckb', 'co', 'cs', 'cv', 'cy', 'da', 'de', 'diq', 'dsb',
                                 'dty', 'dv', 'el', 'eml', 'en', 'eo', 'es', 'et', 'eu', 
                                 'fa', 'fi', 'fr', 'frr', 'fy', 'ga', 'gd', 'gl', 'gn', 
                                 'gom', 'gu', 'gv', 'he', 'hi', 'hif', 'hr', 'hsb', 'ht',
                                 'hu', 'hy', 'ia', 'id', 'ie', 'ilo', 'io', 'is', 'it',
                                 'ja', 'jbo', 'jv', 'ka', 'kk', 'km', 'kn', 'ko', 'krc',
                                 'ku', 'kv', 'kw', 'ky', 'la', 'lb', 'lez', 'li', 'lmo',
                                 'lo', 'lrc', 'lt', 'lv', 'mai', 'mg', 'mhr', 'min', 'mk',
                                 'ml', 'mn', 'mr', 'mrj', 'ms', 'mt', 'mwl', 'my', 'myv',
                                 'mzn', 'nah', 'nap', 'nds', 'ne', 'new', 'nl', 'nn', 'no',
                                 'oc', 'or', 'os', 'pa', 'pam', 'pfl', 'pl', 'pms', 'pnb', 
                                 'ps', 'pt', 'qu', 'rm', 'ro', 'ru', 'rue', 'sa', 'sah', 
                                 'sc', 'scn', 'sco', 'sd', 'sh', 'si', 'sk', 'sl', 'so',
                                 'sq', 'sr', 'su', 'sv', 'sw', 'ta', 'te', 'tg', 'th', 'tk',
                                 'tl', 'tr', 'tt', 'tyv', 'ug', 'uk', 'ur', 'uz', 'vec', 
                                 'vep', 'vi', 'vls', 'vo', 'wa', 'war', 'wuu', 'xal', 'xmf',
                                 'yi', 'yo', 'yue', 'zh')
isocodes = ISOcodes::ISO_639_2
comp_cases = complete.cases(isocodes$Alpha_2)
isocodes_fasttext = isocodes[comp_cases, ]
# dim(isocodes_fasttext)
idx_keep_fasttext = which(isocodes_fasttext$Alpha_2 %in% fasttext_supported_languages)
isocodes_fasttext = isocodes_fasttext[idx_keep_fasttext, ]
isocodes_fasttext = data.table::data.table(isocodes_fasttext)
# isocodes_fasttext
lower_nams = tolower(isocodes_fasttext$Name)
lower_nams = trimws(as.vector(unlist(lapply(strsplit(lower_nams, "[;, ]"), function(x) x[1]))), which = 'both')   # remove second or third naming of the country name
isocodes_fasttext$Name_tolower = lower_nams
isocodes_fasttext

# Applying language detection model (both model  and tweets are in the same folder)
getwd()
file_bin = file.path('lid.176.bin')
file_tweets = file.path('Tweets.csv')
df = read.csv('Tweets.csv')

# Language detection
lang_detect = fastText::language_identification(input_obj = file_tweets,
                                                pre_trained_language_model_path = file_bin,
                                                k = 1,
                                                th = 0.0,
                                                threads = 1,
                                                verbose = TRUE)
# Removing the first row as it is a column name
lang_detect = lang_detect[-1,]

# Saving the result
write.csv(lang_detect,"Tweets_lang.csv", row.names = TRUE)

# Open initial full file
df_full = read.csv('Tweets_full.csv')

# Merging full tweets with language detection results by row id
tweets_merge <- merge(df_full, lang_detect,
                          by = 'row.names', all = TRUE)


# Saving language detecting results
write.csv(tweets_merge,"Tweets_merge.csv", row.names = FALSE)

# Select only tweets in English
tweets_en<-filter(tweets_merge, iso_lang_1=="en")

# Select only tweets with a confidence score > 0.5
tweets_merge<-filter(tweets_merge, prob_1>0.7)
tweets_en<-filter(tweets_en, prob_1>0.7)

# Saving language detecting results
write.csv(tweets_en,"Tweets_en.csv", row.names = FALSE)
write.csv(tweets_merge,"Tweets_merge_prob70.csv", row.names = FALSE)

