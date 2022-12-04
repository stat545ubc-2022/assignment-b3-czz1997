#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets)
library(shinythemes)
library(broom)
library(datateachr)
library(dplyr)
library(tidyverse)
library(markdown) # necessary for the app to load properly in shinyapp.io

options(shiny.autoreload = TRUE)

# Define UI for application
ui <- fluidPage(
    # Application theme
    theme = shinytheme("flatly"),

    # Application title
    titlePanel("Toronto Apartment Buildings"),

    # Sidebar
    sidebarLayout(
        sidebarPanel(
            h3("Filters"),
            hr(),
            sliderInput("yearInput", "Year Range", 1805, 2019, c(1900, 2019)), # year range filter
            sliderInput("storeyInput", "Number of storeys range", 0, 51, c(0, 51)), # storey range filter
            hr(),
            uiOutput("propertyTypeOutput"), # property type filter
            uiOutput("facilityTypeOutput")), # facility type filter

        mainPanel(
          tabsetPanel(
            tabPanel("Introduction",
                     includeMarkdown("readme.md")), # display readme of the app
            tabPanel("Raw Data",
                     h3("This table shows the raw data after applying given filters."),
                     hr(),
                     DT::dataTableOutput("rawTable"),
                     p("Table: Toronto Apartment Buildings Dataset (filtered)")),
            tabPanel("Distribution",
                     h3("The following bar charts shows the distribution of selected facilities over year and number of storeys."),
                     hr(),
                     h4("Distribution over year"),
                     hr(),
                     plotOutput("bar_year"),
                     br(),
                     hr(),
                     h4("Distribution over number of storeys"),
                     hr(),
                     plotOutput("bar_storey")),
            tabPanel("Analysis",
                     h3("Coverage rate analysis for selected facilities"),
                     hr(),
                     radioButtons("byInput", "Show Coverage Data With Respect To:",
                                  choices = c("Year", "Number of Storeys"),
                                  selected = "Year"),
                     hr(),
                     tabsetPanel(
                          tabPanel("Table", DT::dataTableOutput("coverage_table")),
                          tabPanel("Plot", plotOutput("coverage_plot")))),
            tabPanel("Predictions",
                     h3("Coverage rate prediction for selected facilities"),
                     hr(),
                     radioButtons("predictByInput", "Show Coverage Predictions With Respect To:",
                                  choices = c("Year", "Number of Storeys"),
                                  selected = "Year"),
                     uiOutput("predictionRangeOutput"),
                     hr(),
                     plotOutput("prediction_plot"))
          )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    # Side bar panel
    output$propertyTypeOutput <- renderUI({
      pickerInput("propertyTypeInput","Property Type",
                  sort(unique(apt_buildings$property_type)), # retrieve options from column
                  unique(apt_buildings$property_type), # select all by default
                  options = list(`actions-box` = TRUE), multiple = T)
    }) # property type filter

    output$facilityTypeOutput <- renderUI({
      pickerInput("facilityTypeInput", "Facility Type",
                  choices = list(
                    "Balconies" = "balconies",
                    "Barrier Free Accessibility Entry" = "barrier_free_accessibilty_entr",
                    "Exterior Fire Escape" = "exterior_fire_escape",
                    "Fire Alarm" = "fire_alarm",
                    "Garbage Chutes" = "garbage_chutes",
                    "Intercom" = "intercom",
                    "Laundry Room" = "laundry_room",
                    "Locker or Storage Room" = "locker_or_storage_room",
                    "Sprinkler System" = "sprinkler_system",
                    "Emergency Power" = "emergency_power",
                    "Cooling Room" = "cooling_room"
                  ), # use named list to get rid of column names
                  selected = c("exterior_fire_escape", "fire_alarm", "sprinkler_system", "emergency_power"),
                  options = list(`actions-box` = TRUE), multiple = T)
    }) # facility type filter

    # Raw table tab
    filtered <- reactive({
      if (is.null(input$propertyTypeInput) || is.null(input$facilityTypeInput)) {
        return(NULL)
      }

      apt_buildings %>%
        select(c(id, year_built, year_registered, no_of_storeys,
                 prop_management_company_name, property_type, site_address,
                 input$facilityTypeInput)) %>%
        tidyr::drop_na(everything()) %>%
        filter(year_built >= input$yearInput[1],
               year_built <= input$yearInput[2],
               no_of_storeys >= input$storeyInput[1],
               no_of_storeys <= input$storeyInput[2],
               property_type %in% input$propertyTypeInput) # apply filter
    }) # filtered dataset

    output$rawTable <- DT::renderDataTable({
      filtered()
    })

    # Distribution tab
    tidied <- reactive({
      if (is.null(filtered())) {
        return(NULL)
      }

      filtered() %>%
        pivot_longer(cols = c(-id, -year_built, -year_registered,
                              -no_of_storeys, -prop_management_company_name,
                              -property_type, -site_address),
                     names_to  = "facilities",
                     values_to = "equipped") # tidy the filtered dataset
    }) # tidied dataset

    tidied_equipped_only <- reactive({
      if (is.null(tidied())) {
        return(NULL)
      }

      tidied() %>%
        filter(equipped == "YES")
    })

    output$bar_year <- renderPlot({
      if (is.null(tidied())) {
        return()
      }
      ggplot(tidied_equipped_only(), aes(x = year_built, fill = facilities)) +
        geom_bar(position="dodge") +
        ggtitle("Number of Buildings with Specific Facilities With Respect to Year") +
        xlab("Year") +
        ylab("Count") +
        theme_minimal() +
        theme_bw()
    })

    output$bar_storey <- renderPlot({
      if (is.null(tidied())) {
        return()
      }
      ggplot(tidied_equipped_only(), aes(x = no_of_storeys, fill = facilities)) +
        geom_bar(position="dodge") +
        ggtitle("Number of Buildings with Specific Facilities With Respect to Number of Storeys") +
        xlab("Number of Storeys") +
        ylab("Count") +
        theme_minimal() +
        theme_bw()
    })

    # Analysis tab
    coverage.year <- reactive({
      if (is.null(tidied())) {
        return(NULL)
      }

      tidied() %>%
        group_by(year_built, facilities) %>%
        summarise(coverage = sum(equipped == "YES") / n())
    }) # compute coverage by year on tidied dataset

    coverage.storey <- reactive({
      if (is.null(tidied())) {
        return(NULL)
      }

      tidied() %>%
        group_by(no_of_storeys, facilities) %>%
        summarise(coverage = sum(equipped == "YES") / n())
    }) # compute coverage by storey on tidied dataset

    output$coverage_table <- DT::renderDataTable({
      if(input$byInput == "Year") {
        coverage.year()
      } else {
        coverage.storey()
      }
    })

    output$coverage_plot <- renderPlot({
      if(input$byInput == "Year") {
        coverage_data <- coverage.year()
      } else {
        coverage_data <- coverage.storey()
      }
      if (is.null(coverage_data)) {
        return()
      }

      ggplot(coverage_data, aes(x=if(input$byInput == "Year") year_built else no_of_storeys, y=coverage)) +
        geom_area(aes(fill=facilities), alpha=0.1, position = "identity") +
        geom_line(aes(color = facilities, linetype = facilities)) +
        ggtitle("Coverage Rate Changes") +
        xlab(input$byInput) +
        ylab("Coverage") +
        theme_minimal() +
        theme_bw()
    })

    # Prediction tab
    output$predictionRangeOutput <- renderUI({
      if (input$predictByInput == "Year") {
        sliderInput("predictYearInput", "Prediction Year Range", 1805, 2100, c(1980, 2050))
      } else {
        sliderInput("predictStoreyInput", "Prediction Number of Storeys Range", 0, 100, c(0, 75))
      }
    }) # prediction range selector

    prediction <- reactive({
      if (input$predictByInput == "Year") {
        if (is.null(coverage.year()) || is.null(input$predictYearInput)) {
          return(NULL)
        }

        predictRange <- data.frame(year_built = seq(input$predictYearInput[1], input$predictYearInput[2], 1))
        coverage.year() %>%
          select(facilities, year_built, coverage) %>%
          nest(data = c(year_built, coverage)) %>%
          mutate(model = map(data, ~ lm(coverage ~ I(year_built - 1805), data = .x))) %>%
          transmute(facilities, yhat = map(model, ~ augment(x = .x, newdata=predictRange))) %>%
          unnest(yhat) %>%
          mutate(predicted = pmax(pmin(.fitted, 1), 0)) # clamp predicted value into range [0, 1]
      } else {
        if (is.null(coverage.storey()) || is.null(input$predictStoreyInput)) {
          return(NULL)
        }

        predictRange <- data.frame(no_of_storeys = seq(input$predictStoreyInput[1], input$predictStoreyInput[2], 1))
        coverage.storey() %>%
          select(facilities, no_of_storeys, coverage) %>%
          nest(data = c(no_of_storeys, coverage)) %>%
          mutate(model = map(data, ~ lm(coverage ~ no_of_storeys, data = .x))) %>%
          transmute(facilities, yhat = map(model, ~ augment(x = .x, newdata=predictRange))) %>%
          unnest(yhat) %>%
          mutate(predicted = pmax(pmin(.fitted, 1), 0)) # clamp predicted value into range [0, 1]
      }
    }) # fit linear model on coverage data and compute predictions

    output$prediction_plot <- renderPlot({
      if (is.null(prediction())) {
        return()
      }

      ggplot(prediction(), aes(x=if(input$predictByInput == "Year") year_built else no_of_storeys, y=predicted)) +
        geom_line(aes(color = facilities, linetype = facilities)) +
        geom_area(aes(fill=facilities), alpha=0.1, position = "identity") +
        ggtitle("Coverage Prediction") +
        xlab(input$predictByInput) +
        ylab("Predicted Coverage") +
        theme_minimal() +
        theme_bw()
    })
}

# Run the application
shinyApp(ui = ui, server = server)
