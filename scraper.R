library(rvest)
library(dplyr)

years = c(1918:2018)
data_jongens = list()
data_meisjes = list()

## Scrape Dutch Birth Rate by Year
geboorte_cijfers = 'https://nl.wikipedia.org/wiki/Bevolking_van_Nederland' %>% html() %>% html_nodes(xpath='//*[@id="mw-content-text"]/div/table[3]') %>% html_table(fill=TRUE)
geboorte_cijfers = geboorte_cijfers[[1]][,c(1,3)]
names(geboorte_cijfers) = c("year", "birth_rate")
geboorte_cijfers$birth_rate = geboorte_cijfers$birth_rate * 1000
geboorte_cijfers = geboorte_cijfers %>% filter(year >= 1918)

## Scrape baby names
i = 1
for(y in years){
  url = paste0("https://www.meertens.knaw.nl/nvb/topnamen/land/Nederland/", y)
  birth_rate = geboorte_cijfers[geboorte_cijfers$year==y,]$birth_rate
  jongens = url %>% html() %>% html_nodes(xpath='//*[@id="topnamen-jongens"]') %>% html_table(fill=TRUE)
  jongens = jongens[[1]]
  names(jongens) = c("id", "name", "count")
  jongens$year = y
  jongens$normalized_count = (jongens$count/birth_rate)*100
  
  meisjes = url %>% html() %>% html_nodes(xpath='//*[@id="topnamen-meisjes"]') %>% html_table(fill=TRUE)
  meisjes = meisjes[[1]]
  names(meisjes) = c("id", "name", "count")
  meisjes$y = y
  meisjes$normalized_count = (meisjes$count/birth_rate)*100
  
  data_jongens[[i]] = jongens
  data_meisjes[[i]] = meisjes
  i = i + 1
  print(i)
}

df_female = bind_rows(data_meisjes)

names = unique(df_female$name)
nr_names = length(unique(df_female$name))
cor_to_karen = data.frame(matrix(nrow=nr_names, ncol=2))
names(cor_to_karen) = c("name", "cor")

j = 1
for(i in 1:nr_names){
  dutch_name = names[i]
  series = df_female %>% filter(name==dutch_name)
  karen_series = data %>% filter(year %in% series$y)
  if(nrow(karen_series)>=50){
  corr = cor(karen_series$normalized_count, series$normalized_count)
  cor_to_karen[j,] = c(dutch_name, corr)
  print(j)
  j = j + 1
  }
}

cor_to_karen = cor_to_karen[order(cor_to_karen$cor, decreasing = TRUE),]


test = df_female %>% filter(name=="Carolina")

plot(data$year, data$normalized_count, type="l", col="red")
lines(test$y,test$normalized_count, type="l")
