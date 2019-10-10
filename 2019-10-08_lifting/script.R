library(ggplot2)
library(gganimate)
library(tidyverse)
library(viridis)

df <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-10-08/ipf_lifts.csv")

df2 <- df %>% mutate(year = as.numeric(str_sub(date, 1, 4))) %>%
  select(year, sex, age, bodyweight_kg, best3squat_kg, best3bench_kg, best3deadlift_kg) %>%
  gather("type", "value", - year, - sex, - age, - bodyweight_kg) %>%
  mutate(sex = recode(sex, "F"="Female", "M"="Male"),
         sex = fct_relevel(sex, "Male"),
         type = recode(type, 
                       "best3bench_kg"="Bench",
                       "best3deadlift_kg"="Deadlift",
                       "best3squat_kg"="Squat"),
         year = as.integer(year)) 


ggplot(df2 %>% filter(value>0 & age > 0.5), 
       aes(x=bodyweight_kg, y=value, col = age) ) +
  geom_point() +
  facet_grid(sex~type) +
  scale_color_viridis(direction = -1, option = "plasma", 
                      name = "Age")+
  theme_bw() +
  # gganimate specific bits:
  labs(title = 'Year: {frame_time}', 
       x = 'Body Weight in kg', 
       y = 'Maximum of the first three successful attempts for the lift in kg') +
  transition_time(year) +
  ease_aes('linear')
