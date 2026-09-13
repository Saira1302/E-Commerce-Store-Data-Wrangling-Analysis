install.packages("RMySQL")
install.packages("DBI")

library(DBI)
library(RMySQL)

con <- dbConnect(
  RMySQL::MySQL(),
  dbname = "ecommerce_db",
  host = "localhost",
  user = "root",
  password = "ab12ab12@saira"
)

customers <- dbReadTable(con, "customers")
products <- dbReadTable(con, "products")
orders <- dbReadTable(con, "orders")
order_items <- dbReadTable(con, "order_items")
payments <- dbReadTable(con, "payments")
website_visits <- dbReadTable(con, "website_visits")

head(customers)

library(dplyr)

ecommerce_data <- orders %>%
  left_join(customers, by = "customer_id") %>%
  left_join(order_items, by = "order_id") %>%
  left_join(products, by = "product_id") %>%
  left_join(payments, by = "order_id")

glimpse(ecommerce_data)

library(tidyverse)

# Handle missing data
ecommerce_data <- ecommerce_data %>%
  mutate(across(everything(), ~replace_na(., 0)))  # Replace NAs with 0 (you can use mean or median instead)

# Remove outliers using IQR method (for numeric columns)
numeric_cols <- sapply(ecommerce_data, is.numeric)
for (col in names(ecommerce_data)[numeric_cols]) {
  Q1 <- quantile(ecommerce_data[[col]], 0.25, na.rm = TRUE)
  Q3 <- quantile(ecommerce_data[[col]], 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  ecommerce_data <- ecommerce_data %>%
    filter(ecommerce_data[[col]] >= (Q1 - 1.5 * IQR) & ecommerce_data[[col]] <= (Q3 + 1.5 * IQR))
}

# Feature engineering: Create new variables
ecommerce_data <- ecommerce_data %>%
  mutate(
    order_month = format(as.Date(order_date), "%Y-%m"),
    revenue = quantity * price
  )

library(ggplot2)

# 1. Top-selling products
ecommerce_data %>%
  group_by(product_name) %>%
  summarise(total_sales = sum(revenue, na.rm = TRUE)) %>%
  arrange(desc(total_sales)) %>%
  ggplot(aes(x = reorder(product_name, total_sales), y = total_sales)) +
  geom_col(fill = "skyblue") +
  coord_flip() +
  labs(title = "Top Selling Products", x = "Product", y = "Total Sales")

# 2. Sales by city
ecommerce_data %>%
  group_by(city) %>%
  summarise(total_sales = sum(revenue, na.rm = TRUE)) %>%
  ggplot(aes(x = reorder(city, total_sales), y = total_sales, fill = city)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(title = "Sales by City", x = "City", y = "Total Sales")

# 3. Membership level vs Average Spending
ecommerce_data %>%
  group_by(membership_level) %>%
  summarise(avg_spent = mean(total_amount, na.rm = TRUE)) %>%
  ggplot(aes(x = membership_level, y = avg_spent, fill = membership_level)) +
  geom_col(show.legend = FALSE) +
  labs(title = "Average Spending by Membership Level", x = "Membership", y = "Avg. Spending")




library(tsibble)
library(fable)

# Convert to time series format
sales_ts <- ecommerce_data %>%
  group_by(order_month) %>%
  summarise(monthly_sales = sum(revenue, na.rm = TRUE)) %>%
  mutate(order_month = yearmonth(order_month)) %>%
  as_tsibble(index = order_month)

# Plot sales trends
autoplot(sales_ts, monthly_sales) +
  labs(title = "Monthly Sales Trend", x = "Month", y = "Total Sales")


colnames(ecommerce_data)

library(dplyr)
library(tidymodels)

# Ensure 'total_amount' exists and is numeric
ecommerce_data$total_amount <- as.numeric(ecommerce_data$total_amount)

# Create high_spender as a factor
ecommerce_data <- ecommerce_data %>%
  mutate(
    high_spender = ifelse(total_amount > median(total_amount, na.rm = TRUE), "Yes", "No"),
    high_spender = as.factor(high_spender)
  )

# Check balance
table(ecommerce_data$high_spender)


set.seed(123)
data_split <- initial_split(ecommerce_data, prop = 0.8, strata = high_spender)
train_data <- training(data_split)
test_data  <- testing(data_split)

model <- logistic_reg() %>%
  set_engine("glm") %>%
  fit(high_spender ~ age + gender + membership_level + total_amount, data = train_data)

# Predict
predictions <- predict(model, test_data, type = "prob") %>%
  bind_cols(predict(model, test_data)) %>%
  bind_cols(test_data %>% select(high_spender))

# Evaluate
roc_auc(predictions, truth = high_spender, .pred_Yes)
conf_mat(predictions, truth = high_spender, estimate = .pred_class)
accuracy(predictions, truth = high_spender, estimate = .pred_class)
