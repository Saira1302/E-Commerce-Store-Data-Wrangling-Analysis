# 🛒 E-Commerce Data Wrangling & Analysis with R and MySQL

##  Project Overview

This project demonstrates an end-to-end **data wrangling and analysis workflow using R and MySQL** on an e-commerce database.

Data was extracted from multiple relational tables, combined into an analysis-ready dataset, cleaned, transformed, and analyzed to identify sales patterns, customer spending behavior, product performance, and monthly revenue trends.

The project also includes a **logistic regression model** to classify customers as high spenders based on demographic and purchasing information.

---

##  Project Objectives

The main objectives of this project are to:

* Connect R to a MySQL database
* Extract data from multiple relational tables
* Combine related datasets using joins
* Handle missing values
* Detect and remove potential outliers
* Create new analytical variables
* Analyze product and geographic sales
* Compare spending across membership levels
* Analyze monthly sales trends
* Build a customer high-spender classification model
* Evaluate the classification model

---

##  Database Tables

The MySQL database contains several tables related to the e-commerce system:

* `customers`
* `products`
* `orders`
* `order_items`
* `payments`
* `website_visits`

The main analysis combines customer, order, product, order item, and payment information.

---

#  Data Wrangling Workflow

```text
MySQL Database
      ↓
Connect R to MySQL
      ↓
Extract Relational Tables
      ↓
Join Customer + Order + Product Data
      ↓
Inspect Dataset
      ↓
Handle Missing Values
      ↓
Detect & Remove Outliers
      ↓
Feature Engineering
      ↓
Sales & Customer Analysis
      ↓
Monthly Sales Analysis
      ↓
Customer Classification
      ↓
Model Evaluation
```

---

#  1. MySQL Database Connection

R was connected to the MySQL database using the `DBI` and `RMySQL` packages.

The project retrieves data directly from the relational database using `dbReadTable()`.

For security, database credentials should be stored using environment variables rather than being written directly into the script.

---

# 2. Data Integration

Multiple tables were combined using `left_join()`.

The main dataset was created by joining:

```text
Orders
   ↓
Customers
   ↓
Order Items
   ↓
Products
   ↓
Payments
```

This created a consolidated dataset suitable for analysis.

---

# 3. Missing Data Handling

Missing values were identified and handled during preprocessing.

The current workflow replaces missing values with `0` using `replace_na()`.

```r
ecommerce_data <- ecommerce_data %>%
  mutate(across(everything(), ~replace_na(., 0)))
```

This step prepares the dataset for subsequent analysis and calculations.

---

# 4. Outlier Detection

Potential outliers were identified using the **Interquartile Range (IQR) method**.

The lower and upper limits were calculated as:

```text
Lower Bound = Q1 − 1.5 × IQR

Upper Bound = Q3 + 1.5 × IQR
```

Numeric variables were checked against these boundaries, and observations outside the calculated range were removed.

---

# 5. Feature Engineering

New variables were created to support business analysis.

### Order Month

The order date was transformed into a monthly period:

```r
order_month = format(as.Date(order_date), "%Y-%m")
```

### Revenue

Revenue was calculated using:

```r
revenue = quantity * price
```

This derived variable was then used for product, city, and monthly sales analysis.

---

# 6. Sales Analysis

## Top-Selling Products

Products were grouped and ranked according to their total generated revenue.

This visualization helps identify which products contribute the most to sales.

## Sales by City

Sales were aggregated by city to identify geographic differences in revenue generation.

## Membership Level vs Average Spending

Average customer spending was compared across different membership levels.

These analyses provide a basic view of **product performance, geographic sales distribution, and customer spending behavior**.

---

# 7. Monthly Sales Trend

Monthly revenue was aggregated and converted into a time-series format using `tsibble`.

The monthly sales data was then visualized to examine changes in sales over time.

```r
sales_ts <- ecommerce_data %>%
  group_by(order_month) %>%
  summarise(monthly_sales = sum(revenue, na.rm = TRUE)) %>%
  mutate(order_month = yearmonth(order_month)) %>%
  as_tsibble(index = order_month)
```

The resulting time-series visualization provides an overview of monthly sales trends.

---

# 8. High-Spender Classification

A new variable called `high_spender` was created using the median customer spending value.

Customers with spending above the median were classified as:

```text
Yes → High Spender
No  → Non-High Spender
```

The target variable was converted into a factor for classification modeling.

---

# 9. Logistic Regression

A logistic regression model was developed using `tidymodels`.

The model uses:

* Age
* Gender
* Membership level
* Total amount spent

to classify customers as high spenders or non-high spenders.

The dataset was divided into:

* **80% training data**
* **20% testing data**

Stratified splitting was used to maintain the distribution of the target variable.

---

# 10. Model Evaluation

The classification model was evaluated using:

### ROC AUC

Measures the model's ability to distinguish between high spenders and non-high spenders.

### Confusion Matrix

Shows the number of:

* True Positives
* True Negatives
* False Positives
* False Negatives

### Accuracy

Measures the overall proportion of correctly classified observations.

---

## Tools & Technologies

### Programming Language

**R**

### Database

**MySQL**

### Libraries

* `DBI`
* `RMySQL`
* `dplyr`
* `tidyverse`
* `ggplot2`
* `tsibble`
* `fable`
* `tidymodels`

---

## Skills Demonstrated

This project demonstrates practical experience with:

* SQL Database Connectivity
* Relational Data Integration
* Data Wrangling
* Data Cleaning
* Missing Value Handling
* Outlier Detection
* IQR Method
* Feature Engineering
* Revenue Analysis
* Customer Segmentation
* Sales Analysis
* Time-Series Preparation
* Data Visualization
* Logistic Regression
* Classification
* Model Evaluation



If you don't have the database schema or SQL file, simply remove the `sql/` folder from the structure.

---

## Project Outcome

This project demonstrates how R can be connected to a relational MySQL database to transform raw e-commerce data into an **analysis-ready dataset**.

The workflow combines database integration, data cleaning, statistical preprocessing, feature engineering, visualization, time-series analysis, and predictive modeling to extract useful business insights from e-commerce data.



Interested in **Data Analysis, Machine Learning, Business Intelligence, Digital Marketing, and SEO**.
