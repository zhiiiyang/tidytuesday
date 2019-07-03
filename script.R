library(dplyr)
library(d3treeR)
library(treemap)
library(RColorBrewer)
library(stringr)

dat <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-07-02/media_franchises.csv")
dat2 <- dat[!duplicated(dat), ]

treemap(
  dat2,
  index=c("revenue_category", "franchise"),
  vSize="revenue",
  vColor="revenue",
  type="value"
)

treemap(
  dat2,
  index=c("revenue_category", "franchise"),
  vSize="revenue",
  vColor="revenue",
  type="index"
)

# create a new factor variable, bin, from categorizing the revenue
dat3 <- dat2 %>% arrange(revenue_category, revenue)  %>%
  group_by(revenue_category) %>%
  mutate(bin = cut(revenue, 
                   breaks = c(-Inf, quantile(revenue, probs = seq(0.25, 0.75, 0.25)), Inf), 
                   labels = c(1, 2, 3, 4)))

# create a second new factor variable from bin and revenue_category

dat3$newbin <- with(dat3, interaction(revenue_category,  bin)) 

dat3$newbin <- factor(dat3$newbin, as.character(unique(dat3$newbin)))

dat3 %>% group_by(revenue_category, bin) %>% select(newbin)


# extract the number of color needed and create the palette

counts <- dat3 %>% group_by(revenue_category) %>% 
  summarise(n = n_distinct(bin)) %>% 
  pull(n)


palette <- sapply(1:n_distinct(dat3$revenue_category), 
            function(i) brewer.pal(counts[i], 
                                   c("Greys", "Reds", "Oranges", "RdYlBu", 
                                     "Blues", "Purples", "PuRd", "Greens")[i])) %>% 
           unlist()

# replot the treemap 

treemap(
  dat3,
  index=c("revenue_category", "franchise"),
  vSize="revenue",
  vColor="newbin",
  type="categorical",
  position.legend	="none",
  palette = palette
)

# replace unusual characters that might return errors from d3tree

dat3$franchise <- str_replace_all(dat3$franchise, "[&]", "and")
dat3 <- dat3 %>% mutate(franchise = 
                          ifelse(is.na(str_match(franchise, "Jump Comics"))==FALSE, 
                                 "ohonen Jump / Jump Comics", franchise))

dat3$revenue_category <- factor(dat3$revenue_category)

dat3$revenue_category <- recode(dat3$revenue_category, 
                                `Merchandise, Licensing & Retail` = "Merchandise, Licensing and Retail")

# Now it is ready 

treenew <- treemap(
  dat3,
  index=c("revenue_category", "franchise"),
  vSize="revenue",
  vColor="newbin",
  type="categorical",
  position.legend	="none",
  palette = palette
)

d3tree(treenew, rootname = "Revenue by category")

# Use style_widget fcuntion to change the style from https://github.com/d3treeR/d3treeR/issues/10#issuecomment-248098578

style_widget <- function(hw=NULL, style="", addl_selector="") {
  stopifnot(!is.null(hw), inherits(hw, "htmlwidget"))
  
  # use current id of htmlwidget if already specified
  elementId <- hw$elementId
  if(is.null(elementId)) {
    # borrow htmlwidgets unique id creator
    elementId <- sprintf(
      'htmlwidget-%s',
      htmlwidgets:::createWidgetId()
    )
    hw$elementId <- elementId
  }
  
  htmlwidgets::prependContent(
    hw,
    htmltools::tags$style(
      sprintf(
        "#%s %s {%s}",
        elementId,
        addl_selector,
        style
      )
    )
  )
}

style_widget(
  d3tree(treenew, rootname = "Revenue by category"),
  addl_selector="text",
  style="font-family:cursive; font-size:10px;"
)

style_widget(
  d3tree2(treenew, rootname = "Revenue by category"),
  addl_selector="text",
  style="font-family:cursive; font-size:10px;"
)

style_widget(
  d3tree3(treenew, rootname = "Revenue by category"),
  addl_selector="text",
  style="font-family:cursive; font-size:10px;"
)
