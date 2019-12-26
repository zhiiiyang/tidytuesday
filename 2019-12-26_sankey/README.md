---
title: "Sankey diagram and Word-cloud for hashtags"
author: "Zhi Yang"
date: "12/24/2019"
output: 
  html_document:
    keep_md: true
---
  

```r
library(rtweet)
library(lubridate)
```

```
## 
## Attaching package: 'lubridate'
```

```
## The following object is masked from 'package:base':
## 
##     date
```

```r
suppressMessages(library(dplyr))
library(networkD3)
library(wordcloud2)

token <- get_tokens()
```

## Get my timeline

```r
targeted_user <- "zhiiiyang"
tweet_list <- get_timeline(targeted_user,n = 3000)
fav_list <- get_favorites(targeted_user, n = 3000)
dim(tweet_list)
```

```
## [1] 1269   90
```

```r
dim(fav_list)
```

```
## [1] 1578   91
```

## clean hashtags

```r
tweet_hash <- unlist(tweet_list$hashtags)
tweet_hash <- tweet_hash[!is.na(tweet_hash)]
fav_hash <- unlist(fav_list$hashtags)
fav_hash <- fav_hash[!is.na(fav_hash)]

length(tweet_hash)
```

```
## [1] 393
```

```r
length(fav_hash)
```

```
## [1] 1226
```

## not include hashtags less than 10 counts


```r
dat <- data.frame(source = c(rep("Tweets", length(tweet_hash)),
                             rep("Likes", length(fav_hash))),
                  target = paste0("#",
                                  c(tolower(tweet_hash), tolower(fav_hash))))

dat_sum <- dat %>% group_by(source, target) %>% 
           summarise(value = n()) %>%
           filter(value > 10) %>%
           arrange(desc(value))


nodes <- data.frame(name=c(as.character(dat_sum$source), 
                           as.character(dat_sum$target)) %>% unique())

dat_sum$IDsource=match(dat_sum$source, nodes$name)-1 
dat_sum$IDtarget=match(dat_sum$target, nodes$name)-1
```


## Make the Network

```r
sankeyNetwork(Links = dat_sum, Nodes = nodes,
                      Source = "IDsource", Target = "IDtarget",
                      Value = "value", NodeID = "name", 
                      sinksRight=FALSE, 
              nodeWidth=10, fontSize=18, nodePadding=15)
```

```
## Links is a tbl_df. Converting to a plain data frame.
```

<!--html_preserve--><div id="htmlwidget-d9a733fea98955ad4fcf" style="width:672px;height:480px;" class="sankeyNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-d9a733fea98955ad4fcf">{"x":{"links":{"source":[0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,1],"target":[2,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,8,6,17,11,18],"value":[334,109,34,27,24,22,21,19,18,17,17,16,16,15,15,14,14,14,13,12,12]},"nodes":{"name":["Likes","Tweets","#rstats","#datascience","#rladies","#dataviz","#phdchat","#phdlife","#blogdown","#academictwitter","#academicchatter","#tidytuesday","#ggplot2","#shiny","#rmarkdown","#rstudioconf","#python","#epitwitter","#xaringan"],"group":["Likes","Tweets","#rstats","#datascience","#rladies","#dataviz","#phdchat","#phdlife","#blogdown","#academictwitter","#academicchatter","#tidytuesday","#ggplot2","#shiny","#rmarkdown","#rstudioconf","#python","#epitwitter","#xaringan"]},"options":{"NodeID":"name","NodeGroup":"name","LinkGroup":null,"colourScale":"d3.scaleOrdinal(d3.schemeCategory20);","fontSize":18,"fontFamily":null,"nodeWidth":10,"nodePadding":15,"units":"","margin":{"top":null,"right":null,"bottom":null,"left":null},"iterations":32,"sinksRight":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->



```r
figPath = system.file("examples/t.png",package = "wordcloud2")
Freq <- dat %>% group_by(target) %>% 
        summarise(value = as.numeric(n())) %>% 
        mutate(value = if_else(value>100, round(value/8), value)) %>%
        arrange(desc(value))
colnames(Freq) <- c("word", "freq")
Freq$word <- stringr::str_remove(Freq$word, "#")
wordcloud2(Freq, figPath = figPath, size = 1.5, color = "skyblue")
```

![](twitter.png)
