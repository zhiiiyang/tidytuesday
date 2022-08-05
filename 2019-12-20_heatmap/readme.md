---
title: "Heatmap for My Twitter Activity Tracking"
author: "Zhi Yang"
date: "12/20/2019"
output: 
  html_document:
    keep_md: true
---
  

```r
library(rtweet)
suppressMessages(library(lubridate))
suppressMessages(library(dplyr))
source("https://raw.githubusercontent.com/iascchen/VisHealth/master/R/calendarHeat.R")
```



```r
token <- create_token(
  app = "rtweet_token_zy",
  consumer_key = Sys.getenv("consumer_key"),
  consumer_secret = Sys.getenv("consumer_secret"))
```


## Get my timeline

```r
targeted_user <- "zhiiiyang"
tweet_list <- get_timeline(targeted_user,n = 3000)
```

## Explore the tweets list 

```r
head(tweet_list)
```

```
## # A tibble: 6 × 43
##   created_at               id id_str        full_text truncated display_text_ra…
##   <dttm>                <dbl> <chr>         <chr>     <lgl>                <dbl>
## 1 2022-08-05 13:04:29 1.56e18 155564593935… @Bertran… FALSE                   95
## 2 2022-08-05 11:49:32 1.56e18 155562707761… @nmancus… FALSE                   47
## 3 2022-08-05 10:41:18 1.56e18 155560990619… @JinXunG… FALSE                   54
## 4 2022-08-05 08:25:45 1.56e18 155557579747… @JinXunG… FALSE                  171
## 5 2022-08-04 23:24:18 1.56e18 155543953476… @JeevunS… FALSE                  256
## 6 2022-08-04 23:19:06 1.56e18 155543822856… By the a… FALSE                  129
## # … with 37 more variables: entities <list>, source <chr>,
## #   in_reply_to_status_id <dbl>, in_reply_to_status_id_str <chr>,
## #   in_reply_to_user_id <dbl>, in_reply_to_user_id_str <chr>,
## #   in_reply_to_screen_name <chr>, geo <list>, coordinates <list>,
## #   place <list>, contributors <lgl>, is_quote_status <lgl>,
## #   retweet_count <int>, favorite_count <int>, favorited <lgl>,
## #   retweeted <lgl>, possibly_sensitive <lgl>, lang <chr>, …
```

#### retweet lists

```r
tweet_list <- tweet_list %>% 
  mutate(created_at = with_tz(created_at, tzone = "America/Los_Angeles"),
         week = week(created_at),
         weekday = wday(created_at, label = TRUE),
         year = year(created_at), 
         month = month(created_at, label = TRUE),
         date = date(created_at)) %>% 
  group_by(year, month) %>% 
  mutate(monthweek = week - min(week) + 1) %>% 
  group_by(date) %>% 
  mutate(activity = n(),
         original = if_else(is.na(in_reply_to_status_id)==TRUE &
                              retweeted==FALSE, TRUE, FALSE),
         likes = sum(favorite_count[original==TRUE]),
         retweets = sum(retweet_count[original==TRUE]))
```



```r
calendarHeat(tweet_list$date, tweet_list$activity, 
             ncolors = 99, color = "g2r", varname="My Tweets & Replies Activitiy")
```

![](README_files/figure-html/unnamed-chunk-6-1.png)<!-- -->
