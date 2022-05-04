library(tidyquant)
library(xtable)


start_date <- "2022-04-21"
end_date <- "2022-04-26"
cryto_sample <- tq_get("ETH-USD",
                       from = start_date,
                       to = end_date,
                       get = "stock.prices") %>% 
  mutate(date = as.character(date))
xtable(cryto_sample, 
       caption = "Crypto prices",
       label = "Crypto prices", 
       align = "rllllllll",
       caption.placement = "top")
