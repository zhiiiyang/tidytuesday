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
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:lubridate':
## 
##     intersect, setdiff, union
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
source("https://raw.githubusercontent.com/iascchen/VisHealth/master/R/calendarHeat.R")
```



```r
token <- create_token(
  app = "xxx",
  consumer_key = "xxx",
  consumer_secret = "xxx")
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
## # A tibble: 6 x 90
##   user_id status_id created_at          screen_name text  source
##   <chr>   <chr>     <dttm>              <chr>       <chr> <chr> 
## 1 345609~ 12080702~ 2019-12-20 17:02:56 zhiiiyang   @R_b~ Twitt~
## 2 345609~ 12075771~ 2019-12-19 08:23:23 zhiiiyang   "@ja~ Twitt~
## 3 345609~ 12075711~ 2019-12-19 07:59:20 zhiiiyang   "If ~ Twitt~
## 4 345609~ 12075426~ 2019-12-19 06:06:21 zhiiiyang   @Tim~ Twitt~
## 5 345609~ 12075395~ 2019-12-19 05:53:50 zhiiiyang   @gua~ Twitt~
## 6 345609~ 12075328~ 2019-12-19 05:27:22 zhiiiyang   "@sk~ Twitt~
## # ... with 84 more variables: display_text_width <dbl>,
## #   reply_to_status_id <chr>, reply_to_user_id <chr>,
## #   reply_to_screen_name <chr>, is_quote <lgl>, is_retweet <lgl>,
## #   favorite_count <int>, retweet_count <int>, quote_count <int>,
## #   reply_count <int>, hashtags <list>, symbols <list>, urls_url <list>,
## #   urls_t.co <list>, urls_expanded_url <list>, media_url <list>,
## #   media_t.co <list>, media_expanded_url <list>, media_type <list>,
## #   ext_media_url <list>, ext_media_t.co <list>,
## #   ext_media_expanded_url <list>, ext_media_type <chr>,
## #   mentions_user_id <list>, mentions_screen_name <list>, lang <chr>,
## #   quoted_status_id <chr>, quoted_text <chr>, quoted_created_at <dttm>,
## #   quoted_source <chr>, quoted_favorite_count <int>,
## #   quoted_retweet_count <int>, quoted_user_id <chr>,
## #   quoted_screen_name <chr>, quoted_name <chr>,
## #   quoted_followers_count <int>, quoted_friends_count <int>,
## #   quoted_statuses_count <int>, quoted_location <chr>,
## #   quoted_description <chr>, quoted_verified <lgl>,
## #   retweet_status_id <chr>, retweet_text <chr>,
## #   retweet_created_at <dttm>, retweet_source <chr>,
## #   retweet_favorite_count <int>, retweet_retweet_count <int>,
## #   retweet_user_id <chr>, retweet_screen_name <chr>, retweet_name <chr>,
## #   retweet_followers_count <int>, retweet_friends_count <int>,
## #   retweet_statuses_count <int>, retweet_location <chr>,
## #   retweet_description <chr>, retweet_verified <lgl>, place_url <chr>,
## #   place_name <chr>, place_full_name <chr>, place_type <chr>,
## #   country <chr>, country_code <chr>, geo_coords <list>,
## #   coords_coords <list>, bbox_coords <list>, status_url <chr>,
## #   name <chr>, location <chr>, description <chr>, url <chr>,
## #   protected <lgl>, followers_count <int>, friends_count <int>,
## #   listed_count <int>, statuses_count <int>, favourites_count <int>,
## #   account_created_at <dttm>, verified <lgl>, profile_url <chr>,
## #   profile_expanded_url <chr>, account_lang <lgl>,
## #   profile_banner_url <chr>, profile_background_url <chr>,
## #   profile_image_url <chr>
```

#### retweet lists

```r
tweet_list <- tweet_list %>% 
  mutate(week = week(created_at),
         weekday = wday(created_at, label = TRUE),
         year = year(created_at), 
         month = month(created_at, label = TRUE),
         date = date(created_at)) %>% 
  group_by(year, month) %>% 
  mutate(monthweek = week - min(week) + 1) %>% 
  group_by(date) %>% 
  mutate(activity = n(),
         original = if_else(is.na(reply_to_status_id)==TRUE &
                              is_retweet==FALSE, TRUE, FALSE),
         likes = sum(favorite_count[original==TRUE]),
         retweets = sum(retweet_count[original==TRUE]))
```



```r
calendarHeat(tweet_list$date, tweet_list$activity, 
             ncolors = 99, color = "g2r", varname="My Tweets & Replies Activitiy")
```

![](index_files/figure-html/unnamed-chunk-6-1.png)<!-- -->
