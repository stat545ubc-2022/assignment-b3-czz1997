## Toronto Apartment Building App

**Toronto Apartment Building App** is a shiny application that is designed to
provide useful tools to explore the apartment buildings in Toronto dataset for 
those interested. 
Specifically, the application facilitates analysis on the relationship between
the year buildings were built/number of storeys buildings have, and facilities
equipped by buildings, such as fire alarm and emergency power system.
The dataset is acquired from [The City of Toronto’s Open Data Portal](
https://open.toronto.ca/).

### Overview
The application provides the following four major functions, each is based on 
the previous function and provides further analytical insights into the dataset:
- Raw Data: Raw data after filtering
- Distribution: Distribution of each facility
- Analysis: Analysis on the coverage rate of selected facilities
- Predictions: Predictions on the coverage rate of selected facilities

### Raw Data
Provides raw data after applying given filters. Raw data is presented as an
interactive table.

### Distribution
Provides distribution (counts) of selected facilities with respect to year built
and number of storeys, by tidying filtered data. Distribution data is presented 
as bar charts with different facilities in different colors.

### Analysis
Provides analysis on the coverage rates of selected facilities. Coverage rate is
calculated on tidied data by number of records with given facility equipped over
total number of records. Users can choose to show the coverage rates with 
respect to the year buildings were built or the number of storeys buildings 
have. Coverage rate data is presented as an interactive table and a line chart.

### Prediction
Provides prediction on the coverage rates of selected facilities. Prediction
model is computed based on the tidied data and therefore will be impacted by the 
filters. Predicted coverage rates are clamped into the range [0, 1]. Users can 
choose to show the coverage rate predictions with respect to the year buildings 
were built or the number of storeys buildings have, and the range of 
predictions. Coverage rate prediction data is presented as a line chart.
