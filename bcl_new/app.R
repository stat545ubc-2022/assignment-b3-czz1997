#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(ggplot2)
library(dplyr)
bcl <- read_csv("https://raw.githubusercontent.com/daattali/shiny-server/master/bcl/data/bcl-data.csv")
options(shiny.autoreload = TRUE)

# Features added to the basic BC Liquor shiny app:
# 1. allow users to decide the color of the bars in the plot.
# This feature could be useful if users want to collect plots under different filter and
# want to distinguish them via different colors.
# 2. sort data by price.
# Originally the data does not have any order, and providing the ability to sort data by price
# can help discover the relationship between price and other variables and facilitate adjusting
# the price range filter.
# 3. separate plot and table tabs.
# Putting plot and table in different tabs can improve the UI to make the app
# more visually pleasant and easy to use
# 4. interactive table
# Interactive table provides searching, paging and sorting abilities for users
# to further explore the results.

ui <- fluidPage(
  titlePanel("BC Liquor Store prices"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("priceInput", "Price", 0, 100, c(25, 40), pre = "$"),
      radioButtons("typeInput", "Product type",
                   choices = c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
                   selected = "WINE"),
      uiOutput("countryOutput"),
      # Feature 1: allow users to decide the color of the bars in the plot
      colourpicker::colourInput("colorInput", "Plot color", "Black"),
      # Feature 2: sort data by price
      checkboxInput("sortInput", "Sort results by price", TRUE)
    ),
    mainPanel(
      # Feature 3: separate plot and table tabs
      tabsetPanel(
        tabPanel("Plot", plotOutput("coolplot")),
        tabPanel("Table", DT::dataTableOutput("results"))# Feature 4: interactive table
      )
    )
  )
)

server <- function(input, output) {
  output$countryOutput <- renderUI({
    selectInput("countryInput", "Country",
                sort(unique(bcl$Country)),
                selected = "CANADA")
  })

  filtered <- reactive({
    if (is.null(input$countryInput)) {
      return(NULL)
    }

    unsorted <-
      bcl %>%
        filter(Price >= input$priceInput[1],
               Price <= input$priceInput[2],
               Type == input$typeInput,
               Country == input$countryInput
        )

    # Feature 2: sort data by price
    if (input$sortInput) {
      unsorted %>%
        arrange(Price)
    } else {
      unsorted
    }
  })

  output$coolplot <- renderPlot({
    if (is.null(filtered())) {
      return()
    }
    ggplot(filtered(), aes(Alcohol_Content)) +
      geom_histogram(fill=input$colorInput) # Feature 1: allow users to decide the color of the bars in the plot
  })

  # Feature 4: interactive table
  output$results <- DT::renderDataTable({
    filtered()
  })
}

shinyApp(ui = ui, server = server)
