# Credit Card Fraud Detection — Exploratory Analysis

Exploratory data analysis of the ULB Credit Card Fraud dataset, investigating fraud patterns, temporal anomalies, and rule-based detection efficacy using Python and SQL.

## Project Description

An exploratory data analysis identifying behavioural patterns in credit card fraud using a real, anonymised transaction dataset. This project investigates **WHEN** fraud happens, **HOW MUCH** fraudulent transactions are typically worth, and **WHY** simple rule-based detection is insufficient — answering 10 specific business questions a fraud analyst would be asked to investigate.

## Dataset

**Credit Card Fraud Detection** (ULB / Kaggle)
284,807 transactions, 31 columns. Features V1–V28 are anonymised/PCA-transformed for privacy. Highly imbalanced: 0.17% fraud rate.

Source: [kaggle.com/datasets/mlg-ulb/creditcardfraud](https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud)

## Key Findings

Ten business questions were answered through systematic EDA; the most significant findings:

1. **Fraud accounts for only 0.17% of transactions** — a textbook extreme class imbalance that makes naive detection rules ineffective.
2. **Fraud peaks at 2:00 AM (1.45% rate)** — but this peak is dominated by **low-value** transactions, consistent with automated card-testing behaviour.
3. **High-value fraud outliers cluster around late morning (hour 11)**, not at night — a markedly different pattern from the broader 2 AM spike.
4. **Together, these two patterns point to two distinct fraud strategies operating on different schedules** — automated low-value testing at night, and targeted high-value extraction during business hours — each requiring a different detection approach.
5. **Fraud median ($9.82) is far below the legitimate median ($22.00)**, while the fraud mean ($123.87) is far above both — most fraud is small-value testing, but a small number of large extractions pull the average up sharply.
6. **V17 is the single most correlated feature with fraud** (r = -0.313) among the 28 anonymised features.
7. **A simple "flag if Amount > $200" rule catches only 17% of fraud while wrongly flagging 10% of legitimate transactions** — demonstrating why production fraud systems require multi-feature models, not single thresholds.

## Business Recommendation

Given the two distinct fraud patterns identified, a fraud team should implement a two-pronged detection strategy: one rule tuned to catch high-volume, low-value bursts around 2:00 AM, and a separate risk-scoring model — incorporating V17 and other top-correlated features — to monitor for high-value transactions during the late-morning window. A single Amount-based threshold, as shown in Finding 7, is not sufficient on its own.

## Tools Used

- **Python** — Pandas, NumPy, Matplotlib, Seaborn, SciPy
- **PostgreSQL** — data cleaning, staging tables, cross-verification queries
- **SQLAlchemy** — Python-to-PostgreSQL connection

## Repository Structure

```
credit-card-fraud-analysis/
├── README.md
├── fraud_capstone.ipynb        # Main analysis notebook
├── requirements.txt
├── setup.sql                   # Raw → clean table creation, duplicate analysis
├── data/
│   └── README.md               # Dataset download instructions
├── images/                     # Saved chart outputs
└── tools/
    └── chart_templates.py      # Reusable chart functions
```

## How to Run

1. Clone this repo
2. Download `creditcard.csv` from [Kaggle](https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud) into the `data/` folder
3. Install dependencies: `pip install -r requirements.txt`
4. Set up PostgreSQL and run `setup.sql` to create the cleaned tables used for cross-verification
5. Open `fraud_capstone.ipynb` and run all cells top to bottom

## Cross-Verification

All key metrics were independently verified using direct SQL queries against a PostgreSQL database, confirming the Pandas-derived results (e.g. fraud rate matched to within 0.01 percentage points across both tools).

## A Note on Duplicates

The raw dataset contains 773 fully-duplicated rows. Analysis showed 98.3% of these were legitimate transactions, consistent with a data export artifact rather than a fraud pattern — duplicates were removed before analysis. Full reasoning is documented in the notebook's appendix.
