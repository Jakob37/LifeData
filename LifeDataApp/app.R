library(shiny)
library(tidyverse)

my_df <- read_csv("../testdata.csv")
my_df$fruit_perc <- my_df$quantity / sum(my_df$quantity) * 100
print("Hello Global")

ui <- fluidPage(
   
   titlePanel("Life Data"),
   
   sidebarLayout(
      sidebarPanel(
         checkboxInput("show_perc", "Show Percentages"),
         textInput("plot_title", "Plot Title")
      ),
      
      mainPanel(
         plotOutput("piePlot")
      )
   )
)

server <- function(input, output) {
   
   output$piePlot <- renderPlot({
       
       if (input$show_perc) {
           plt <- ggplot(my_df, aes(x="", y=fruit_perc, fill=fruit)) 
       }
       else {
           plt <- ggplot(my_df, aes(x="", y=quantity, fill=fruit))
       }
       
       plt + 
           geom_bar(width=1, stat="identity") + 
           coord_polar("y", start=0) +
           theme_classic() +
           ggtitle(input$plot_title)
       
   })
}

shinyApp(ui = ui, server = server)

