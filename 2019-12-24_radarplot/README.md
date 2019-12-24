---
title: "Radar/spider plot  for My Tweet Frequency"
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
library(tidyr)
library(ggplot2)
```

```
## Warning: package 'ggplot2' was built under R version 3.6.2
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
## 1 345609~ 12092492~ 2019-12-23 23:07:36 zhiiiyang   @eri~ Twitt~
## 2 345609~ 12092283~ 2019-12-23 21:44:37 zhiiiyang   @and~ Twitt~
## 3 345609~ 12089873~ 2019-12-23 05:46:49 zhiiiyang   "Wan~ Twitt~
## 4 345609~ 12086472~ 2019-12-22 07:15:44 zhiiiyang   Her ~ Twitt~
## 5 345609~ 12080702~ 2019-12-20 17:02:56 zhiiiyang   @R_b~ Twitt~
## 6 345609~ 12075771~ 2019-12-19 08:23:23 zhiiiyang   "@ja~ Twitt~
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

### Tidy retweet lists

```r
radar_df <- tweet_list %>%
  mutate(created_at = with_tz(created_at, tzone = "America/Los_Angeles"), 
         hour = stringr::str_pad(hour(created_at), 2, pad = "0"),
         mins = minute(floor_date(created_at, "30 mins"))) %>% 
  unite(group, c("hour", "mins")) %>% 
  group_by(group) %>%
  summarise(tweets = n()) %>%
  select(group, tweets)

radar_df_com <- rbind(radar_df, 
                      data.frame(group = setdiff(paste0(rep(stringr::str_pad(0:23, 2, pad="0"), 
                                                       each = 2), "_", c(0,30)), radar_df$group),
                                 tweets = 0)) %>%
                mutate(group = (as.numeric(as.factor(group))- 1)/2) %>%
                arrange(group)

radar_df_com<- rbind(radar_df_com, 
                     data.frame(group = 24, radar_df_com[radar_df_com$group==0, "tweets"]))
```

## Create spider plot 

```r
ggplot(radar_df_com, aes(x = group, y = log(tweets))) +
  geom_point(size = 4, color = "darkslateblue") +
  geom_polygon(color = "darkslateblue", fill=NA) + 
  coord_polar(direction = 1) +
  ggtitle("Tweet frequency of @zhiiiyang by time of day") +
  ylab("log(Tweet(count))") +
  xlab("Time of Day") +
  scale_x_continuous(breaks = c(0, 6, 12, 18)) + 
  theme_minimal() +
  theme(axis.text.y=element_blank(),
        axis.title = element_text(face="italic"),
        axis.text.x = element_text(size = 15)) 
```

![](README_files/figure-html/unnamed-chunk-6-1.png)<!-- -->
