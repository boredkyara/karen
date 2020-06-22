library(dplyr)

years = c(1918:2018)
data <- data.frame(matrix(nrow=101, ncol=2))
names(data) <- c("year", "count")
i = 1
for(y in years){
  fileName = paste0("names/yob", y, ".txt")
  df <- read.table(fileName, header = FALSE, sep=",")
  data[i,] <- c(y ,df[df$V1 == "Karen",]$V3)
  i = i + 1
}

birth_rate_US = read.csv("NCHS_-_Births_and_General_Fertility_Rates__United_States.csv")
birth_rate_US = birth_rate_US %>% filter(Year >= 1918)

data$normalized_count = (data$count/birth_rate_US$Birth.Number)*100

write.csv(data, "karen1918-2018.csv")
