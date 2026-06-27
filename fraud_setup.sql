-- ============================================================
-- setup.sql
-- Credit Card Fraud Detection — PostgreSQL setup & cross-verification
-- Run this after downloading creditcard.csv into the data/ folder
-- ============================================================

-- ── STEP 1: Raw staging table — everything as TEXT first ────
-- Loading as TEXT avoids import failures on malformed/blank values;
-- type casting happens explicitly in Step 3.
CREATE TABLE raw_fraud (
    Time TEXT, V1 TEXT, V2 TEXT, V3 TEXT, V4 TEXT, V5 TEXT, V6 TEXT, V7 TEXT,
    V8 TEXT, V9 TEXT, V10 TEXT, V11 TEXT, V12 TEXT, V13 TEXT, V14 TEXT,
    V15 TEXT, V16 TEXT, V17 TEXT, V18 TEXT, V19 TEXT, V20 TEXT, V21 TEXT,
    V22 TEXT, V23 TEXT, V24 TEXT, V25 TEXT, V26 TEXT, V27 TEXT, V28 TEXT,
    Amount TEXT, Class TEXT
);

-- ── STEP 2: Load the raw CSV ─────────────────────────────────
-- Update the file path to match your local data/ folder location.
COPY raw_fraud FROM 'C:/path/to/data/creditcard.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'utf8');

-- ── STEP 3: Clean table — correct types, NULLIF guards against
-- blank strings that would otherwise fail a direct CAST ────────
CREATE TABLE clean_fraud (
    Time FLOAT8, V1 FLOAT8, V2 FLOAT8, V3 FLOAT8, V4 FLOAT8, V5 FLOAT8,
    V6 FLOAT8, V7 FLOAT8, V8 FLOAT8, V9 FLOAT8, V10 FLOAT8, V11 FLOAT8,
    V12 FLOAT8, V13 FLOAT8, V14 FLOAT8, V15 FLOAT8, V16 FLOAT8, V17 FLOAT8,
    V18 FLOAT8, V19 FLOAT8, V20 FLOAT8, V21 FLOAT8, V22 FLOAT8, V23 FLOAT8,
    V24 FLOAT8, V25 FLOAT8, V26 FLOAT8, V27 FLOAT8, V28 FLOAT8,
    Amount NUMERIC, Class INT
);

INSERT INTO clean_fraud (
    Time, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15,
    V16, V17, V18, V19, V20, V21, V22, V23, V24, V25, V26, V27, V28, Amount, Class
)
SELECT
    NULLIF(Time, '')::FLOAT8,
    NULLIF(V1, '')::FLOAT8,  NULLIF(V2, '')::FLOAT8,  NULLIF(V3, '')::FLOAT8,
    NULLIF(V4, '')::FLOAT8,  NULLIF(V5, '')::FLOAT8,  NULLIF(V6, '')::FLOAT8,
    NULLIF(V7, '')::FLOAT8,  NULLIF(V8, '')::FLOAT8,  NULLIF(V9, '')::FLOAT8,
    NULLIF(V10, '')::FLOAT8, NULLIF(V11, '')::FLOAT8, NULLIF(V12, '')::FLOAT8,
    NULLIF(V13, '')::FLOAT8, NULLIF(V14, '')::FLOAT8, NULLIF(V15, '')::FLOAT8,
    NULLIF(V16, '')::FLOAT8, NULLIF(V17, '')::FLOAT8, NULLIF(V18, '')::FLOAT8,
    NULLIF(V19, '')::FLOAT8, NULLIF(V20, '')::FLOAT8, NULLIF(V21, '')::FLOAT8,
    NULLIF(V22, '')::FLOAT8, NULLIF(V23, '')::FLOAT8, NULLIF(V24, '')::FLOAT8,
    NULLIF(V25, '')::FLOAT8, NULLIF(V26, '')::FLOAT8, NULLIF(V27, '')::FLOAT8,
    NULLIF(V28, '')::FLOAT8,
    NULLIF(Amount, '')::NUMERIC,
    NULLIF(Class, '')::INT
FROM raw_fraud;

-- ── STEP 4: Hourly view — derives hour-of-day from Time without
-- duplicating storage ────────────────────────────────────────
CREATE VIEW clean_fraud_hourly AS
SELECT *, (Time::INT / 3600) % 24 AS hour_of_day
FROM clean_fraud;


-- ============================================================
-- VERIFICATION QUERIES
-- Used to cross-check Pandas-derived results in the notebook.
-- Expected results are noted as comments based on the full,
-- pre-deduplication dataset (284,807 rows).
-- ============================================================

-- Total row count
-- Expected: 284,807
SELECT COUNT(*) AS total_rows FROM clean_fraud;

-- Class distribution
-- Expected: Class 0 = 284,315 | Class 1 = 492
SELECT Class, COUNT(*) AS class_distribution
FROM clean_fraud
GROUP BY Class;

-- Null check on Time column
-- Expected: 0
SELECT COUNT(*) AS null_counts_time
FROM clean_fraud
WHERE Time IS NULL;

-- Overall fraud rate
-- Expected: 0.1727%
SELECT ROUND((COUNT(*) FILTER (WHERE Class = 1)::NUMERIC / COUNT(*) * 100), 4) AS fraud_rate
FROM clean_fraud;

-- Transaction volume by hour of day
SELECT hour_of_day, COUNT(*) AS hourly_volume
FROM clean_fraud_hourly
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;


-- ============================================================
-- DUPLICATE ANALYSIS
-- Investigates whether full-row duplicates represent a fraud
-- pattern (e.g. card-testing) or a data export artifact.
-- ============================================================

-- How many full-row duplicate groups exist?
-- Expected: 773
WITH duplicate_group AS (
    SELECT *, COUNT(*) AS dup_count
    FROM clean_fraud
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,
             24,25,26,27,28,29,30,31
    HAVING COUNT(*) > 1
)
SELECT COUNT(*) AS dup_count FROM duplicate_group;

-- Are duplicate rows disproportionately fraud, or mostly legitimate?
-- Expected: Class 0 = 760 | Class 1 = 13
WITH duplicate_group AS (
    SELECT *, COUNT(*) AS dup_count
    FROM clean_fraud
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,
             24,25,26,27,28,29,30,31
    HAVING COUNT(*) > 1
)
SELECT Class, COUNT(*) AS rows_in_dup_group
FROM duplicate_group
GROUP BY Class;

-- Inspect the 13 fraud duplicate rows directly — checks whether
-- they share identical Time+Amount (artifact signature) or vary
-- (potential card-testing signature)
WITH duplicate_group AS (
    SELECT *, COUNT(*) AS dup_count
    FROM clean_fraud
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,
             24,25,26,27,28,29,30,31
    HAVING COUNT(*) > 1
)
SELECT Time, Amount, Class, (Time::INT / 3600) % 24 AS hour_of_day
FROM duplicate_group
WHERE Class = 1
GROUP BY Time, Amount, Class;


-- ============================================================
-- SUMMARY OF KEY FINDINGS (pre-deduplication, full dataset)
-- ============================================================
-- Total rows           : 284,807
-- Legitimate            : 284,315
-- Fraud                 : 492
-- Fraud rate             : 0.1727%
-- Duplicate row groups   : 773 (760 legitimate, 13 fraud)
--
-- Conclusion: duplicate rows are overwhelmingly legitimate (98.3%),
-- consistent with a data export artifact rather than a fraud pattern.
-- Duplicates were removed before analysis in the Python notebook;
-- this explains the small difference between the SQL fraud rate
-- above (pre-dedup) and the Pandas fraud rate (post-dedup) reported
-- in fraud_capstone.ipynb.
