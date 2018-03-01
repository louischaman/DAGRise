# contains 
require(dplyr)
require(ggplot2)
df = data.table::fread("pp-2017.csv", header = F)

## date_count
date_count = df %>% 
      group_by(V3) %>% 
      summarise(count = n()) %>%
      arrange(-count) # test comment
Sys.sleep(4)

## count_postcodes
postcodes = df %>% group_by(V4) %>% 
      summarise(count = n()) %>%
      arrange(-count) %>%
      dplyr::filter(V4 != "")
Sys.sleep(4)

## top_dates_and_postcodes
top_results1 = df[df$V3 %in% date_count$V3[1:5],]
top_results = inner_join(top_results1, postcodes[1:3,], by = "V4")
Sys.sleep(1)


## top_dates_and_postcodes
write.csv(top_results, "output.csv")
Sys.sleep(1)

## summary_plot

top_results %>% group_by(V3, V4) %>% summarise(count = n()) %>%
      ggplot( aes(paste(substr(V3,1,11), V4), count)) +
      geom_col()+ggtitle("this")
Sys.sleep(1)
ggsave("save_plot.png")

