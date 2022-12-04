# STAT 545B - Assignment 3 & 4

This is the repository for STAT 545B - Assignment 3 & 4. It contains two shiny apps: 
an improved BC Liquor App (Assignment 3 Option A) and a Toronto Apartment Buildings app (Assignment 4 Option C).

## Assignment 4

In this assignment, a shiny app is built entirely from scratch: **Toronto Apartment Buildings** (Option C). 
The source code for the app can be found in [here](/apt_buildings).
Visit the app at https://czz1997.shinyapps.io/apt_buildings/.

### Features

- **UI Features**
  - Shiny theme "Flatly" to provide an appealing look for the application
  - Picker box to allow users to select multiple options for the filter. Also provides "Select All" and "Deselect All" functionality.
  - Interactive table to allow users to search, sort and page through the tables in the application
  - Including markdown to load the readme of the application into the main page
  - HTML tags like h4, hr and br to improve the look of the application
  - Tab set to organize different functionality
  - And more!!!
- **Functional Features**
  - Filter the range of numerical data (year and number of storeys), values of categorical data (property type) and columns (facility type)
  - Tidy the dataset and display the distribution of selected facilities with respect to year and number of storeys
  - Compute the coverage of selected facilities with respect to year or number of storeys and show the results as tables and line chart
  - Derive the prediction model by fitting the coverage data and predict on new data of users' choice
  - And more!!!
  
### Acknowledgements

The dataset used by the app is from The City of Toronto’s Open Data Portal.

## Assignment 3

In this assignment, a shiny app is built by improving the existing **BC Liquor app** (Option A).
The source code for the app can be found in [here](/bcl_new).
Visit the app at https://czz1997.shinyapps.io/bcl_new/.

### New Features

1. Allow users to decide the color of the bars in the plot.\
This feature could be useful if users want to collect plots under different filter and
want to distinguish them via different colors.

2. Sort data by price.\
Originally the data does not have any order, and providing the ability to sort data by price
can help discover the relationship between price and other variables and facilitate adjusting
the price range filter.

3. Separate plot and table tabs.\
Putting plot and table in different tabs can improve the UI to make the app
more visually pleasant and easy to use

4. Interactive table\
Interactive table provides searching, paging and sorting abilities for users
to further explore the results.

### Acknowledgements

This app is based on the BC Liquor app by Dean Attali. The dataset used by the app is from OpenDataBC.
