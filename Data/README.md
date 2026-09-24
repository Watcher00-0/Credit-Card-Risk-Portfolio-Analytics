# Data Directory

## Dataset Information

**Dataset Name:** Default of Credit Card Clients  
**Source:** UCI Machine Learning Repository  
**URL:** [https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients](https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients)  
**Original Author:** I-Cheng Yeh  
**Coverage Period:** April 2005 – September 2005  
**Geography:** Taiwan  
**Currency:** New Taiwan Dollar (NT$)  
**Records:** 30,000 customers  
**Columns:** 25 (24 features + 1 binary target)

---

## Why the Raw Dataset Is Not Included

The raw dataset file (`default of credit card clients.xls`) is **not committed to this repository** for the following reasons:

1. **Repository size:** The `.xls` binary is ~3.8MB. GitHub recommends keeping individual committed files under 50MB, but for a clean, dependency-light repo the raw data is excluded.
2. **Licensing:** The UCI dataset is freely available under its repository terms. The authoritative, versioned copy should always be downloaded from the official source to ensure data integrity.
3. **Reproducibility:** All analysis results in this project are derived from the verified 30,000-record dataset obtained directly from UCI. The `credit_card_enriched.csv` file (output of the Part 1 notebook) is also excluded from the repository because it can be fully reproduced by running the notebook against the source data.

---

## How to Obtain the Dataset

### Option 1 — UCI Repository (recommended)

1. Visit: [https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients](https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients)
2. Click **Download** to obtain `default+of+credit+card+clients.zip`
3. Extract the file — you will find `default of credit card clients.xls`
4. Place the `.xls` file in the **project root directory** (same folder as the notebook)

### Option 2 — Kaggle Mirror

The dataset is also available on Kaggle:  
[https://www.kaggle.com/datasets/uciml/default-of-credit-card-clients-dataset](https://www.kaggle.com/datasets/uciml/default-of-credit-card-clients-dataset)

---

## Verified Dataset Properties

The following properties were verified programmatically in the notebook before any analysis:

| Property | Value |
|---|---|
| Rows | 30,000 |
| Columns | 25 |
| Missing values | 0 |
| Duplicate rows | 0 |
| Unique customer IDs | 30,000 |
| Target column | `default payment next month` (renamed `DEFAULT`) |
| Target distribution | 0 = 23,364 (77.88%) / 1 = 6,636 (22.12%) |

---

## Column Reference

| Column | Description | Type |
|---|---|---|
| ID | Unique customer identifier | Integer |
| LIMIT_BAL | Credit limit (NT$) | Integer |
| SEX | 1=Male, 2=Female | Integer |
| EDUCATION | 1=Graduate, 2=University, 3=High School, 4+=Other | Integer |
| MARRIAGE | 1=Married, 2=Single, 3=Other | Integer |
| AGE | Customer age in years (21–79) | Integer |
| PAY_0 | Repayment status September 2005 | Integer |
| PAY_2 | Repayment status August 2005 | Integer |
| PAY_3 | Repayment status July 2005 | Integer |
| PAY_4 | Repayment status June 2005 | Integer |
| PAY_5 | Repayment status May 2005 | Integer |
| PAY_6 | Repayment status April 2005 | Integer |
| BILL_AMT1–6 | Monthly bill statement amounts (NT$) — Sep to Apr 2005 | Integer |
| PAY_AMT1–6 | Monthly payment amounts (NT$) — Sep to Apr 2005 | Integer |
| default payment next month | **Target**: 1 = defaulted, 0 = did not default | Integer |

**PAY status codes:** -2=No consumption, -1=Paid in full, 0=Revolving credit, 1–8=Months delayed

> **Note:** PAY_1 is absent from this dataset. PAY_0 represents September 2005 and PAY_2 represents August 2005. This naming gap is a known characteristic of the original UCI dataset.

---

## Citation

If using this dataset in academic or professional work, please cite:

```
Yeh, I. C. (2016). Default of Credit Card Clients.
UCI Machine Learning Repository.
https://doi.org/10.24432/C55S3H
```

```bibtex
@misc{yeh2016default,
  title        = {Default of Credit Card Clients},
  author       = {Yeh, I-Cheng},
  year         = {2016},
  howpublished = {UCI Machine Learning Repository},
  note         = {\url{https://doi.org/10.24432/C55S3H}}
}
```

---

## Enriched Dataset (Generated)

The notebook produces `credit_card_enriched.csv` in the project root.  
This file adds 18+ engineered columns to the original 25 columns:

| Engineered Column | Description |
|---|---|
| AVG_BILL_AMT | Average monthly bill over 6 months |
| MAX_BILL_AMT | Maximum single monthly bill |
| TOTAL_BILL_6M | Sum of all 6 monthly bills |
| TOTAL_PAY_6M | Sum of all 6 monthly payments |
| AVG_PAY_AMT | Average monthly payment |
| PAY_TO_BILL_RATIO | Total payments ÷ total bills |
| UTILIZATION | Avg bill ÷ credit limit |
| AVG_PAY_STATUS | Mean repayment status code over 6 months |
| MAX_PAY_DELAY | Worst monthly repayment delay |
| MONTHS_DELAYED | Count of months with PAY > 0 |
| MONTHS_SEVERE_DELAY | Count of months with PAY ≥ 2 |
| PERSISTENT_DELINQUENT | Flag: 1 if delayed in 3+ of 6 months |
| RECENT_DELINQUENT | Flag: 1 if PAY_0 > 0 (delayed in Sep 2005) |
| ALWAYS_ON_TIME | Flag: 1 if all PAY statuses ≤ 0 |
| BILL_VOLATILITY | Std deviation of 6 monthly bills |
| PAY_COVERAGE | Avg payment ÷ avg bill |
| RISK_SCORE | Composite risk score (0–13 scale) |
| RISK_SEGMENT | Categorical: Low Risk / Medium Risk / High Risk |
| + label columns | EDUCATION_LABEL, MARRIAGE_LABEL, SEX_LABEL, DEFAULT_LABEL |
| + band columns | LIMIT_BAND, UTIL_BAND, AGE_GROUP |
