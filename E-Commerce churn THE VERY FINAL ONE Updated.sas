/* ── IMPORT DATA ── */
FILENAME REFFILE '/home/u64508133/E Commerce Dataset.xlsx';
PROC IMPORT DATAFILE=REFFILE
    DBMS=XLSX
    OUT=WORK.ecommerce
    REPLACE;
    SHEET="E Comm";
    GETNAMES=YES;
RUN;


/* ── FIRST LOOK ── */
PROC PRINT DATA=WORK.ecommerce (OBS=10);
    TITLE "First 10 Rows - E-Commerce Churn Dataset";
RUN;

PROC CONTENTS DATA=WORK.ecommerce;
    TITLE "Dataset Structure and Column Info";
RUN;

PROC CORR DATA=WORK.ecommerce;
    VAR Churn 
        Tenure 
        WarehouseToHome 
        HourSpendOnApp 
        NumberOfDeviceRegistered 
        NumberOfAddress 
        OrderAmountHikeFromlastYear 
        CouponUsed 
        OrderCount 
        DaySinceLastOrder 
        CashbackAmount 
        SatisfactionScore;
    TITLE "Correlation Between Features and Churn";
RUN;


/* ── NUMERICAL STATISTICS ── */
PROC MEANS DATA=WORK.ecommerce N NMISS MEAN MEDIAN STD MIN MAX;
    VAR Tenure WarehouseToHome HourSpendOnApp
        NumberOfDeviceRegistered NumberOfAddress
        OrderAmountHikeFromlastYear CouponUsed
        OrderCount DaySinceLastOrder CashbackAmount SatisfactionScore;
    TITLE "Descriptive Statistics - All Numerical Variables";
RUN;


/* ── NUMERICAL STATS BY CHURN ── */
PROC MEANS DATA=WORK.ecommerce N MEAN MEDIAN STD;
    CLASS Churn;
    VAR Tenure WarehouseToHome HourSpendOnApp
        DaySinceLastOrder CashbackAmount SatisfactionScore;
    TITLE "Numerical Statistics Grouped by Churn Status";
RUN;


/* ── CATEGORICAL DISTRIBUTIONS ── */
PROC FREQ DATA=WORK.ecommerce;
    TABLES Churn
           PreferredLoginDevice
           PreferredPaymentMode
           Gender
           PreferedOrderCat
           MaritalStatus
           CityTier
           Complain
           / NOCUM;
    TITLE "Categorical Variable Distributions";
RUN;


/* ── CATEGORICAL VS CHURN ── */
PROC FREQ DATA=WORK.ecommerce;
    TABLES PreferredLoginDevice*Churn
           PreferredPaymentMode*Churn
           Gender*Churn
           PreferedOrderCat*Churn
           MaritalStatus*Churn
           Complain*Churn
           / NOROW NOCOL NOPERCENT;
    TITLE "Categorical Variables vs Churn Rate";
RUN;


/* ── MISSING VALUES ── */
PROC MEANS DATA=WORK.ecommerce NMISS N;
    VAR Tenure WarehouseToHome HourSpendOnApp
        OrderAmountHikeFromlastYear CouponUsed
        OrderCount DaySinceLastOrder;
    TITLE "Missing Values Count per Column (Before Cleaning)";
RUN;


/* ── VISUALIZATIONS ── */
PROC SGPLOT DATA=WORK.ecommerce;
    VBAR Churn / FILLATTRS=(COLOR=CX4472C4) DATALABEL;
    TITLE "Viz 1: Overall Churn Distribution";
    XAXIS LABEL="Churn (0=No, 1=Yes)";
    YAXIS LABEL="Number of Customers";
RUN;

PROC SGPLOT DATA=WORK.ecommerce;
    HISTOGRAM Tenure / GROUP=Churn TRANSPARENCY=0.5;
    DENSITY Tenure / GROUP=Churn;
    TITLE "Viz 2: Tenure Distribution by Churn Status";
    XAXIS LABEL="Tenure (Months)";
    YAXIS LABEL="Frequency";
    KEYLEGEND / TITLE="Churn";
RUN;

PROC SGPLOT DATA=WORK.ecommerce;
    VBOX CashbackAmount / CATEGORY=Churn
        FILLATTRS=(COLOR=CX70AD47)
        MEDIANATTRS=(COLOR=RED THICKNESS=2);
    TITLE "Viz 3: Cashback Amount by Churn Status";
    XAXIS LABEL="Churn (0=No, 1=Yes)";
    YAXIS LABEL="Cashback Amount";
RUN;

PROC SGPLOT DATA=WORK.ecommerce;
    VBAR Complain / GROUP=Churn GROUPDISPLAY=STACK DATALABEL;
    TITLE "Viz 4: Complaint Status vs Churn";
    XAXIS LABEL="Complain (0=No, 1=Yes)";
    YAXIS LABEL="Number of Customers";
    KEYLEGEND / TITLE="Churn";
RUN;

PROC SGPLOT DATA=WORK.ecommerce;
    VBAR PreferredPaymentMode / GROUP=Churn
        GROUPDISPLAY=CLUSTER DATALABEL;
    TITLE "Viz 5: Preferred Payment Mode vs Churn";
    XAXIS LABEL="Payment Mode";
    YAXIS LABEL="Number of Customers";
    KEYLEGEND / TITLE="Churn";
RUN;

PROC SGPLOT DATA=WORK.ecommerce;
    VBOX DaySinceLastOrder / CATEGORY=Churn
        FILLATTRS=(COLOR=CXED7D31)
        MEDIANATTRS=(COLOR=BLUE THICKNESS=2);
    TITLE "Viz 6: Days Since Last Order by Churn Status";
    XAXIS LABEL="Churn (0=No, 1=Yes)";
    YAXIS LABEL="Days Since Last Order";
RUN;

PROC SGPLOT DATA=WORK.ecommerce;
    VBAR SatisfactionScore / GROUP=Churn
        GROUPDISPLAY=CLUSTER DATALABEL;
    TITLE "Viz 7: Satisfaction Score vs Churn";
    XAXIS LABEL="Satisfaction Score (1-5)";
    YAXIS LABEL="Number of Customers";
    KEYLEGEND / TITLE="Churn";
RUN;

PROC SGPLOT DATA=WORK.ecommerce;
    SCATTER X=Tenure Y=CashbackAmount / GROUP=Churn
        MARKERATTRS=(SIZE=5);
    TITLE "Viz 8: Tenure vs Cashback Amount by Churn";
    XAXIS LABEL="Tenure (Months)";
    YAXIS LABEL="Cashback Amount";
    KEYLEGEND / TITLE="Churn";
RUN;

PROC SGPLOT DATA=WORK.ecommerce;
    VBAR PreferedOrderCat / GROUP=Churn
        GROUPDISPLAY=CLUSTER DATALABEL;
    TITLE "Viz 9: Preferred Order Category vs Churn";
    XAXIS LABEL="Order Category";
    YAXIS LABEL="Number of Customers";
    KEYLEGEND / TITLE="Churn";
RUN;


/* ── DATA CLEANING ── */
PROC SQL;
    SELECT COUNT(*) AS Duplicate_CustomerIDs
    FROM (
        SELECT CustomerID, COUNT(*) AS freq
        FROM WORK.ECOMMERCE
        GROUP BY CustomerID
        HAVING COUNT(*) > 1
    );
QUIT;

DATA WORK.ecommerce_clean;
    SET WORK.ecommerce;
    DROP CustomerID;
RUN;

DATA WORK.ecommerce_clean;
    SET WORK.ecommerce_clean;
    IF PreferredLoginDevice = "Phone" THEN PreferredLoginDevice = "Mobile Phone";
    IF PreferredPaymentMode = "CC" THEN PreferredPaymentMode = "Credit Card";
    ELSE IF PreferredPaymentMode = "COD" THEN PreferredPaymentMode = "Cash on Delivery";
    ELSE IF PreferredPaymentMode = "E wallet" THEN PreferredPaymentMode = "E Wallet";
    IF PreferedOrderCat = "Mobile Phone" THEN PreferedOrderCat = "Mobile";
RUN;

PROC MEANS DATA=WORK.ecommerce_clean Q1 MEDIAN Q3 MIN MAX;
    VAR Tenure WarehouseToHome HourSpendOnApp
        NumberOfDeviceRegistered SatisfactionScore
        NumberOfAddress OrderAmountHikeFromlastYear
        CouponUsed OrderCount DaySinceLastOrder CashbackAmount;
RUN;


/* ── TRAIN / TEST SPLIT ── */
PROC SURVEYSELECT DATA=WORK.ecommerce_clean
    OUT=split_data
    SAMPRATE=0.8
    OUTALL
    SEED=123;
RUN;

DATA train test;
    SET split_data;
    IF Selected = 1 THEN OUTPUT train;
    ELSE OUTPUT test;
RUN;

DATA train;
    SET train;
    IF Tenure > 37 THEN DELETE;
    IF WarehouseToHome > 36.5 THEN DELETE;
    IF HourSpendOnApp = 5 THEN DELETE;
    IF NumberOfAddress > 12 THEN DELETE;
RUN;


/* ── IMPUTATION ── */
PROC MEANS DATA=train MEDIAN;
    VAR Tenure WarehouseToHome HourSpendOnApp
        OrderAmountHikeFromlastYear
        CouponUsed OrderCount DaySinceLastOrder;
RUN;

DATA train_imputed;
    SET train;
    IF Tenure = . THEN Tenure = 9;
    IF WarehouseToHome = . THEN WarehouseToHome = 14;
    IF HourSpendOnApp = . THEN HourSpendOnApp = 3;
    IF OrderAmountHikeFromlastYear = . THEN OrderAmountHikeFromlastYear = 15;
    IF CouponUsed = . THEN CouponUsed = 1;
    IF OrderCount = . THEN OrderCount = 2;
    IF DaySinceLastOrder = . THEN DaySinceLastOrder = 3;
RUN;

DATA test_imputed;
    SET test;
    IF Tenure = . THEN Tenure = 9;
    IF WarehouseToHome = . THEN WarehouseToHome = 14;
    IF HourSpendOnApp = . THEN HourSpendOnApp = 3;
    IF OrderAmountHikeFromlastYear = . THEN OrderAmountHikeFromlastYear = 15;
    IF CouponUsed = . THEN CouponUsed = 1;
    IF OrderCount = . THEN OrderCount = 2;
    IF DaySinceLastOrder = . THEN DaySinceLastOrder = 3;
RUN;


/* ── ENCODING ── */
DATA train_enc;
    SET train_imputed;
    IF Gender = "Male" THEN Gender_enc = 1;
    ELSE Gender_enc = 0;
RUN;

DATA test_enc;
    SET test_imputed;
    IF Gender = "Male" THEN Gender_enc = 1;
    ELSE Gender_enc = 0;
RUN;

DATA train_enc;
    SET train_enc;
    Login_Computer = (PreferredLoginDevice = "Computer");
RUN;

DATA test_enc;
    SET test_enc;
    Login_Computer = (PreferredLoginDevice = "Computer");
RUN;

DATA train_enc;
    SET train_enc;
    Pay_CreditCard     = (PreferredPaymentMode = "Credit Card");
    Pay_CashOnDelivery = (PreferredPaymentMode = "Cash on Delivery");
    Pay_DebitCard      = (PreferredPaymentMode = "Debit Card");
    Pay_EWallet        = (PreferredPaymentMode = "E Wallet");
RUN;

DATA test_enc;
    SET test_enc;
    Pay_CreditCard     = (PreferredPaymentMode = "Credit Card");
    Pay_CashOnDelivery = (PreferredPaymentMode = "Cash on Delivery");
    Pay_DebitCard      = (PreferredPaymentMode = "Debit Card");
    Pay_EWallet        = (PreferredPaymentMode = "E Wallet");
RUN;

DATA train_enc;
    SET train_enc;
    Cat_Fashion = (PreferedOrderCat = "Fashion");
    Cat_Grocery = (PreferedOrderCat = "Grocery");
    Cat_Laptop  = (PreferedOrderCat = "Laptop & Accessory");
    Cat_Mobile  = (PreferedOrderCat = "Mobile");
RUN;

DATA test_enc;
    SET test_enc;
    Cat_Fashion = (PreferedOrderCat = "Fashion");
    Cat_Grocery = (PreferedOrderCat = "Grocery");
    Cat_Laptop  = (PreferedOrderCat = "Laptop & Accessory");
    Cat_Mobile  = (PreferedOrderCat = "Mobile");
RUN;

DATA train_enc;
    SET train_enc;
    Marital_Single  = (MaritalStatus = "Single");
    Marital_Married = (MaritalStatus = "Married");
RUN;

DATA test_enc;
    SET test_enc;
    Marital_Single  = (MaritalStatus = "Single");
    Marital_Married = (MaritalStatus = "Married");
RUN;

DATA train_enc;
    SET train_enc;
    DROP Gender PreferredLoginDevice PreferredPaymentMode PreferedOrderCat MaritalStatus;
RUN;

DATA test_enc;
    SET test_enc;
    DROP Gender PreferredLoginDevice PreferredPaymentMode PreferedOrderCat MaritalStatus;
RUN;


/* ── FEATURE ENGINEERING ── */
DATA WORK.final_features;
    SET train_enc;
    IF Tenure > 0 THEN Engagement_Score = OrderCount / Tenure;
    ELSE Engagement_Score = 0;
    IF HourSpendOnApp >= 3 THEN High_App_User = 1;
    ELSE High_App_User = 0;
    IF DaySinceLastOrder > 15 THEN Inactive_Customer = 1;
    ELSE Inactive_Customer = 0;
    Complaint_Risk = Complain * (6 - SatisfactionScore);
    Customer_Value = CashbackAmount + (OrderCount * 10);
    Loyalty_Score  = Tenure * OrderCount;
    IF Engagement_Score < 0.5 THEN Low_Engagement = 1;
    ELSE Low_Engagement = 0;
    Risk_Flag = Inactive_Customer + Complain + Low_Engagement;
RUN;

DATA WORK.test_features;
    SET test_enc;
    IF Tenure > 0 THEN Engagement_Score = OrderCount / Tenure;
    ELSE Engagement_Score = 0;
    IF HourSpendOnApp >= 3 THEN High_App_User = 1;
    ELSE High_App_User = 0;
    IF DaySinceLastOrder > 15 THEN Inactive_Customer = 1;
    ELSE Inactive_Customer = 0;
    Complaint_Risk = Complain * (6 - SatisfactionScore);
    Customer_Value = CashbackAmount + (OrderCount * 10);
    Loyalty_Score  = Tenure * OrderCount;
    IF Engagement_Score < 0.5 THEN Low_Engagement = 1;
    ELSE Low_Engagement = 0;
    Risk_Flag = Inactive_Customer + Complain + Low_Engagement;
RUN;

DATA WORK.final_features;
    SET WORK.final_features;
    DROP Selected;
RUN;

DATA WORK.test_features;
    SET WORK.test_features;
    DROP Selected;
RUN;


/* ── LOGISTIC REGRESSION ── */
PROC LOGISTIC DATA=WORK.final_features OUTMODEL=WORK.logistic_model PLOTS(MAXPOINTS=NONE)=ROC;
    MODEL Churn(EVENT='1') =
        Tenure
        WarehouseToHome
        HourSpendOnApp
        NumberOfDeviceRegistered
        NumberOfAddress
        OrderAmountHikeFromlastYear
        CouponUsed
        OrderCount
        DaySinceLastOrder
        CashbackAmount
        SatisfactionScore
        CityTier
        Complain
        Gender_enc
        Login_Computer
        Pay_CreditCard
        Pay_CashOnDelivery
        Pay_DebitCard
        Pay_EWallet
        Cat_Fashion
        Cat_Grocery
        Cat_Laptop
        Cat_Mobile
        Marital_Single
        Marital_Married
        Engagement_Score
        High_App_User
        Inactive_Customer
        Complaint_Risk
        Customer_Value
        Loyalty_Score
        Low_Engagement
        Risk_Flag
        / SELECTION=STEPWISE SLENTRY=0.05 SLSTAY=0.05
          CTABLE PPROB=0.5
          LACKFIT;
    TITLE "Model 1: Logistic Regression - Churn Prediction";
RUN;

PROC LOGISTIC INMODEL=WORK.logistic_model;
    SCORE DATA=WORK.test_features
          OUT=WORK.logistic_scored;
RUN;

DATA WORK.logistic_scored;
    SET WORK.logistic_scored;
    IF P_1 >= 0.3 THEN Predicted_Churn = 1;
    ELSE Predicted_Churn = 0;
RUN;

PROC FREQ DATA=WORK.logistic_scored;
    TABLES Churn * Predicted_Churn / NOCUM NOPERCENT;
    TITLE "Logistic Regression: Confusion Matrix on Test Set";
RUN;

PROC SQL;
    SELECT
        SUM(Churn = Predicted_Churn) / COUNT(*) * 100  AS Accuracy     FORMAT=8.2,
        SUM(Churn = 1 AND Predicted_Churn = 1) /
            SUM(Churn = 1) * 100                       AS Sensitivity  FORMAT=8.2,
        SUM(Churn = 0 AND Predicted_Churn = 0) /
            SUM(Churn = 0) * 100                       AS Specificity  FORMAT=8.2
    FROM WORK.logistic_scored;
QUIT;
TITLE "Logistic Regression: Performance Metrics on Test Set";


/* ── POST-MODEL VISUALIZATIONS ── */
PROC SGPLOT DATA=WORK.logistic_scored;
    HISTOGRAM P_1 / GROUP=Churn TRANSPARENCY=0.4 BINWIDTH=0.05;
    TITLE "Viz 10: Predicted Churn Probability by Actual Churn Status";
    XAXIS LABEL="Predicted Probability of Churn" VALUES=(0 TO 1 BY 0.1);
    YAXIS LABEL="Count";
    KEYLEGEND / TITLE="Actual Churn";
RUN;

DATA WORK.scored_tenure_group;
    SET WORK.logistic_scored;
    IF      Tenure <= 6  THEN Tenure_Group = "0-6 Months";
    ELSE IF Tenure <= 12 THEN Tenure_Group = "7-12 Months";
    ELSE IF Tenure <= 24 THEN Tenure_Group = "13-24 Months";
    ELSE                      Tenure_Group = "25+ Months";
RUN;

PROC SGPLOT DATA=WORK.scored_tenure_group;
    VBAR Tenure_Group / RESPONSE=P_1 STAT=MEAN DATALABEL FILLATTRS=(COLOR=CX4472C4);
    TITLE "Viz 11: Average Predicted Churn Probability by Tenure Group";
    XAXIS LABEL="Customer Tenure Group";
    YAXIS LABEL="Avg Predicted Churn Probability" VALUES=(0 TO 1 BY 0.1);
RUN;


/* ── EXPORT PREDICTIONS ── */
DATA WORK.final_predictions;
    SET WORK.logistic_scored;
    KEEP Churn Predicted_Churn P_1;
    RENAME P_1 = Churn_Probability;
RUN;

PROC PRINT DATA=WORK.final_predictions (OBS=20) NOOBS;
    TITLE "Final Predictions: First 20 Rows (Logistic Regression on Test Set)";
RUN;