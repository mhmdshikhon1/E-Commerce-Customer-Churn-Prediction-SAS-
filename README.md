# E-Commerce Customer Churn Prediction Using SAS

## Project Overview
This project aims to analyze an e-commerce customer dataset to identify patterns and predict customer churn. Built entirely using SAS, the project involves a comprehensive data science pipeline including data exploration, data cleaning, statistical imputation, feature engineering, and predictive modeling using Logistic Regression. 

By identifying at-risk customers, e-commerce businesses can take proactive measures to improve retention, enhance customer satisfaction, and optimize promotional strategies.

## Team Collaboration
This project was successfully executed through a collaborative team effort. The workload was divided across the pipeline to ensure thorough analysis and robust model building.

**Team Members:**
* **Abdullah Abu Dahab**
* **Abdelrhman Mohamed**
* **Mahmoud Hosny**
* **Ziad Elsheikh**
* **Mohamed Shaikhoun**

### Roles & Responsibilities
* **Data Exploration, Preprocessing & Feature Engineering:** Abdullah Abu Dahab, Abdelrhman Mohamed, and Mahmoud Hosny handled the initial phases. This included importing the dataset, generating descriptive statistics, handling missing values, standardizing categorical variables, and engineering complex behavioral features.
* **Predictive Modeling & Evaluation:** **Mohamed Shaikhoun** and **Ziad Elsheikh** led the predictive modeling phase. They were responsible for building the Stepwise Logistic Regression model, scoring the test dataset, evaluating the model's performance (Confusion Matrix, Accuracy, Sensitivity, Specificity), generating post-model probability visualizations, and exporting the final predictions.

## Project Pipeline

### 1. Exploratory Data Analysis (EDA)
* Extracted structural information, correlation matrices, and summary statistics.
* Grouped numerical statistics by churn status to observe variances in features like `Tenure`, `CashbackAmount`, and `DaySinceLastOrder`.
* Generated detailed distributions for categorical variables (e.g., `PreferredLoginDevice`, `PreferredPaymentMode`, `Complain`).
* Visualized the data using `PROC SGPLOT` (Histograms, Box Plots, Stacked Bar Charts, and Scatter Plots) to understand the relationship between features and churn.

### 2. Data Cleaning & Preprocessing
* **Duplicate Handling:** Identified and removed duplicate `CustomerID` records.
* **Standardization:** Cleaned categorical variables to ensure consistency (e.g., merging "Phone" into "Mobile Phone", "CC" to "Credit Card").
* **Train/Test Split:** Applied an 80/20 split using `PROC SURVEYSELECT` with a fixed seed (123) for reproducibility.
* **Outlier Removal:** Filtered extreme outliers from the training set based on specific thresholds for `Tenure`, `WarehouseToHome`, `HourSpendOnApp`, and `NumberOfAddress`.
* **Imputation:** Applied median imputation for missing numerical values to preserve data distribution.

### 3. Feature Engineering & Encoding
* Converted categorical variables into binary dummy variables.
* Derived new analytical features to capture customer behavior:
  * `Engagement_Score`: Ratio of Order Count to Tenure.
  * `High_App_User`: Flag for users spending 3 or more hours on the app.
  * `Inactive_Customer`: Flag for users with more than 15 days since their last order.
  * `Complaint_Risk`: A combined metric of complaints and satisfaction scores.
  * `Customer_Value`: A weighted score combining cashback amount and order count.
  * `Loyalty_Score`: Tenure multiplied by Order Count.
  * `Risk_Flag`: An aggregated risk indicator combining inactivity, complaints, and low engagement.

### 4. Logistic Regression Modeling
* Implemented a Stepwise Logistic Regression model (`PROC LOGISTIC`) utilizing the engineered features.
* Applied feature selection with significance entry/stay levels set to 0.05.
* Scored the 20% test set and applied a classification threshold of 0.3 for churn prediction.
* Grouped predicted probabilities by customer tenure to analyze churn likelihood over time.

## Model Performance
The final Logistic Regression model was evaluated on the unseen test set, yielding the following performance metrics:
* **Accuracy:** 89.26%
* **Sensitivity (True Positive Rate):** 50.41%
* **Specificity (True Negative Rate):** 97.02%

## Files & Results
The detailed SAS output, including all generated statistical tables and visualizations, is available in the attached HTML file:
**`Results_ E-Commerce churn THE VERY FINAL ONE.sas.html`**

*([View Detailed SAS Results Report](https://htmlpreview.github.io/?https://github.com/mhmdshikhon1/E-Commerce-Customer-Churn-Prediction-SAS-/blob/main/Results_%20E-Commerce%20churn%20THE%20VERY%20FINAL%20ONE.sas.html)).*
