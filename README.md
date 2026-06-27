# credit-card-fraud-analysis
Exploratory Data Analysis (EDA) of the ULB Credit Card Fraud dataset. Investigating fraud patterns, temporal anomalies, and rule-based detection efficacy using Python and SQL.

# Credit Card Fraud Detection — Exploratory Analysis

## Project Description
An exploratory data analysis identifying behavioural patterns in credit card
fraud using a real, anonymised transaction dataset. This project investigates
WHEN fraud happens, HOW MUCH fraudulent transactions are typically worth, and
WHY simple rule-based detection is insufficient — answering 10 specific
business questions a fraud analyst would be asked to investigate.

## Dataset
Credit Card Fraud Detection (ULB / Kaggle)
284,807 transactions, 31 columns. Features V1-V28 are anonymised/PCA-transformed
for privacy. Highly imbalanced: 0.17% fraud rate.
Source: [https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud]

## Key Findings
1. Fraud accounts for only 0.17% of transactions — extreme class imbalance
2. Fraud peaks at 2:00 AM (1.45% rate) — but this peak is dominated by
   LOW-VALUE transactions, consistent with automated card-testing
3. High-value fraud outliers cluster more around late morning (hour 11),
   not at night — suggesting two distinct fraud behaviours on different schedules
4. Fraud median ($9.82) is far below legitimate median ($22.00) — most
   fraud is small-value testing, but a small number of large extractions
   pull the average up to $123.87
5. V17 is the single most correlated feature with fraud (r = -0.313)
6. A simple "flag if Amount > $200" rule catches only 17% of fraud while
   wrongly flagging 10% of legitimate transactions — demonstrating why
   production systems need multi-feature models, not single thresholds

## Tools Used
Python (Pandas, NumPy, Matplotlib, Seaborn, SciPy), PostgreSQL, SQLAlchemy

## How to Run
1. Clone this repo
2. Download creditcard.csv from [https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud] into the data/ folder
3. pip install -r requirements.txt
4. Open fraud_capstone.ipynb and run all cells

## Cross-Verification
All key metrics were independently verified using direct SQL queries
against a PostgreSQL database, confirming the Pandas-derived results.
