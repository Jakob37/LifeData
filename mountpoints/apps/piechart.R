
library(tidyverse)
my_df <- read_csv("testdata.csv")

# my_df contains the dataframe
# aes defines what columns to use for different style aspects

plt <- ggplot(my_df, aes(x=fruit, y=quantity, color=color)) + 
    geom_point() + 
    theme_classic() +
    ggtitle("Fruit coloring")

# here we define the x axis to be fruit color
# Note that green contains many different fruits
# geom_point is the style of the plot
ggplot(my_df, aes(x=color, y=quantity, color=fruit)) + 
    geom_point() + 
    theme_classic() +
    ggtitle("Colors of the fruits")

# We can use different 'geom's and we can layer multiple different types
ggplot(my_df, aes(x=fruit, y=quantity, color=color, group=color)) + 
    geom_point() + 
    geom_line() +
    theme_classic() +
    ggtitle("Colors of the fruits")

my_df$fruit_perc <- my_df$quantity / sum(my_df$quantity) * 100

# Time to do a pie chart
# First: google "pie chart ggplot"
ggplot(my_df, aes(x="", y=fruit_perc, fill=fruit)) + 
    geom_bar(width=1, stat="identity") + 
    coord_polar("y", start=0)

ggplot(my_df, aes(x="", y=fruit_perc, fill=fruit)) + 
    geom_bar(width=1, stat="identity")


my_df
