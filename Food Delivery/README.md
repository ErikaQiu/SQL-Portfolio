# Canadian Food Delivery Insights SQL Project

## Project Overview

This project analyzes the food delivery service data in 8 populous Canadian cities. The aim is to extract insights from the restaurants offering delivery under 30 minutes from an iconic downtown location in each city.

## Dataset

The dataset is organized into 6 tables:
- `Restaurant`: Information about the restaurants including name and delivery details.
- `City`: Details of the cities covered in the study.
- `Price`: Pricing data for menu items.
- `Reviews`: Customer reviews for each restaurant.
- `Restaurant_Category`: Categories of the restaurants such as American, Chinese, etc.

Variables include the restaurants’ name, number of reviews of each restaurant, delivery time, and distance, among others.

## Key Questions Explored

- Which restaurant has the longest average delivery time, and what is that time across different restaurant categories?
- How does the restaurant with the highest number of reviews in each city compare with the city's average?

## Insights Gained

The analysis has revealed that certain categories, notably American (Traditional), could significantly enhance their delivery efficiency. A detailed case study on 'Eggspectation' demonstrates how addressing lengthy delivery times could improve service offerings.

## Visualization

The results are visualized in Tableau, providing an interactive way to explore the data and insights.

## Repository Structure

- `sql_queries/` - This directory contains all the SQL query files used to extract data from the database.
- `tableau_visualizations/` - Contains the Tableau workbook files with all the visualizations.
- `data/` - Sample data used for analysis.
- `docs/` - Additional documentation related to the project.

## How to Use

1. Clone the repository to get a local copy.
2. Ensure you have the necessary SQL and Tableau setup on your machine.
3. Run the SQL queries to explore the dataset and gain insights.
4. Open the Tableau workbook to view the visualizations.

## Contributions

If you'd like to contribute to this project, please submit a pull request or create an issue with your proposed changes or additions.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
