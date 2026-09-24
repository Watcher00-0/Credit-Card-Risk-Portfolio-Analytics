# Credit Card Portfolio Risk & Delinquency Segmentation

**Author:** Kishan Kannaujiya  
**Dataset:** UCI Default of Credit Card Clients (30,000 records)  
**Type:** Data Analytics · Business Intelligence · Credit Risk Analytics  
**Tools:** Python · SQL · Power BI · DAX

---

## Project Overview

This project delivers a comprehensive **credit-card portfolio risk and delinquency segmentation analysis** of 30,000 credit-card customers observed over a six-month period (April–September 2005). The analysis was conducted using the UCI Default of Credit Card Clients dataset and follows a professional banking/BI analytical workflow:

- **Data validation and quality assurance**
- **Feature engineering** (18+ risk-relevant metrics)
- **Exploratory data analysis** with 9 visualizations
- **Statistical hypothesis testing** (9 tests)
- **Transparent risk segmentation** (Low / Medium / High Risk)
- **SQL-based portfolio analysis** (14 named queries, PostgreSQL)
- **Interactive Power BI dashboard** specification (5 pages, full interactivity spec)
- **Professional project report** and GitHub packaging

> **Business focus:** This is a **data analytics / business intelligence / credit risk project** — not a generic ML classification project. The primary objective is portfolio understanding, risk concentration analysis, and actionable business insights for credit risk and collections teams.

---

## Business Problem

A credit-card issuing bank holds a portfolio of 30,000 active cardholders. The bank's risk, collections, and portfolio-management teams need to understand **where credit default risk is concentrated** within the portfolio so that limited monitoring and intervention resources can be allocated efficiently.

Key business questions:
- Which customer segments show disproportionately high default rates?
- How is credit exposure distributed across risk levels?
- Which repayment-behavior patterns reliably precede default?
- Are high-credit-limit customers lower risk than low-limit customers?
- How do billing and payment trends differ between defaulters and non-defaulters?
- Which customers should be flagged for proactive outreach?

---

## Project Objectives

1. Understand the overall credit-card portfolio composition and health
2. Analyze customer demographics and credit-limit exposure
3. Analyze six months of repayment-status data (April–September 2005)
4. Analyze billing and payment behavior across the portfolio
5. Identify behavioral patterns statistically associated with default
6. Calculate meaningful, interpretable risk-related KPIs
7. Create a transparent, interpretable customer risk-segmentation framework
8. Analyze default concentration and credit exposure across segments
9. Support SQL-based portfolio analysis
10. Support an interactive Power BI dashboard
11. Generate data-driven business insights and recommendations

---

## Dataset

**Source:** UCI Machine Learning Repository — *Default of Credit Card Clients*  
**URL:** https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients  
**Author:** I-Cheng Yeh (2016)  
**DOI:** https://doi.org/10.24432/C55S3H

| Property | Value |
|---|---|
| Records | 30,000 customers |
| Columns | 25 (original) |
| Missing values | 0 |
| Duplicate rows | 0 |
| Target column | `default payment next month` (0/1) |
| Default rate | 22.12% (6,636 / 23,364) |
| Coverage | April–September 2005, Taiwan |
| Currency | New Taiwan Dollar (NT$) |

> **The raw dataset is not included in this repository.** See [`data/README.md`](data/README.md) for download instructions and full citation.

---

## Technologies

| Tool | Purpose |
|---|---|
| Python 3.10+ | Core analysis language |
| pandas | Data manipulation and aggregation |
| numpy | Numerical computation |
| matplotlib / seaborn | Data visualization (9 figures) |
| scipy | Statistical hypothesis testing |
| xlrd | Legacy `.xls` file reading |
| Jupyter Notebook | Interactive analysis environment |
| PostgreSQL 14+ | SQL portfolio analysis |
| Power BI Desktop | Interactive dashboard |
| DAX | Power BI measures |

---

## Project Structure

```
Credit-Card-Portfolio-Risk-Analytics/
├── notebook/
│   └── Kishan_Kannaujiya_CreditCardRiskPortfolio.ipynb   # 20-section analysis notebook
├── data/
│   └── README.md                                          # Dataset source, download instructions, citation
├── sql/
│   └── risk_analysis.sql                                  # PostgreSQL 14+ — 14 queries + 5 bonus
├── powerbi/
│   ├── dashboard_documentation.md                         # 5-page Power BI specification
│   ├── dax_measures.md                                    # 40+ DAX measures with expected values
│   └── theme.json                                         # Power BI theme (validated JSON)
├── report/
│   └── Kishan_Kannaujiya_ProjectReport.docx               # Professional project report
├── requirements.txt                                       # Python package dependencies
├── README.md                                              # This file
└── LICENSE                                                # MIT License
```

---

## Installation & Setup

### Prerequisites
- Python 3.10 or higher
- pip

### 1. Clone the repository
```bash
git clone https://github.com/<your-username>/Credit-Card-Portfolio-Risk-Analytics.git
cd Credit-Card-Portfolio-Risk-Analytics
```

### 2. Install Python dependencies
```bash
pip install -r requirements.txt
```

### 3. Download the dataset
Follow the instructions in [`data/README.md`](data/README.md) to download the UCI dataset.  
Place `default of credit card clients.xls` in the **project root directory** (same level as `requirements.txt`).

### 4. Run the notebook
```bash
cd notebook
jupyter notebook Kishan_Kannaujiya_CreditCardRiskPortfolio.ipynb
```
Or open it in JupyterLab / VS Code.

> **Important:** The notebook must be run from the directory where `default of credit card clients.xls` is located, or update the file path in the loading cell.

---

## Notebook Execution

The notebook is organized into 20 sections in the following order:

1. Project title and metadata
2. Business problem
3. Project objectives
4. Dataset source
5. Dataset description
6. Data dictionary (all 25 columns)
7. Imports
8. Dataset loading
9. Data validation (programmatic assertions)
10. Data-quality checks
11. Data cleaning and labeling
12. Feature engineering (18+ columns)
13. Exploratory Data Analysis (9 figures)
14. Statistical analysis (9 hypothesis tests)
15. Risk segmentation (scoring framework)
16. KPI calculations
17. Visualizations
18. Key findings
19. Business recommendations
20. Conclusion + CSV export

**Output:** The notebook generates `credit_card_enriched.csv` and `fig_01` – `fig_09.png` in the working directory.

---

## SQL Analysis

The SQL file [`sql/risk_analysis.sql`](sql/risk_analysis.sql) targets **PostgreSQL 14+**.

### Load the data
```sql
-- Option 1: DuckDB
CREATE TABLE credit_card_customers AS
SELECT * FROM read_csv_auto('credit_card_enriched.csv', HEADER=TRUE);

-- Option 2: PostgreSQL psql
\COPY credit_card_customers FROM 'credit_card_enriched.csv' WITH (FORMAT CSV, HEADER TRUE);
```

### Queries included

| Query | Description |
|---|---|
| 1 | Overall portfolio KPIs |
| 2 | Default rate calculation |
| 3 | Default count by status |
| 4 | Credit exposure by risk segment |
| 5 | Default rate by education |
| 6 | Default rate by age group |
| 7 | Default rate by credit-limit band |
| 8 | Default rate by PAY_0 repayment status |
| 9 | High-utilization customer analysis |
| 10 | Delinquency segmentation |
| 11 | Risk segment summary (CTE) |
| 12 | Top risk patterns with window-function ranking |
| 13 | Portfolio concentration (default share vs customer share) |
| 14 | Customer-level analytical profile (drill-through ready) |
| A–E | Bonus: heatmap data, monthly trends, demographics, deciles, HAVING clause |

---

## Power BI Dashboard

### Files
| File | Description |
|---|---|
| [`powerbi/dashboard_documentation.md`](powerbi/dashboard_documentation.md) | Complete 5-page specification |
| [`powerbi/dax_measures.md`](powerbi/dax_measures.md) | 40+ DAX measures |
| [`powerbi/theme.json`](powerbi/theme.json) | Power BI theme — validated JSON |

### How to build the dashboard
1. Open **Power BI Desktop**
2. **Get Data → Text/CSV** → select `credit_card_enriched.csv` → rename table to `CreditCardCustomers`
3. Apply theme: **View → Browse for themes** → select `theme.json`
4. Create a `Measures` table and add all DAX from `dax_measures.md`
5. Build each page following the layout in `dashboard_documentation.md`

### Dashboard pages
| Page | Audience | Content |
|---|---|---|
| 1 — Executive Risk Overview | Senior management | 6 KPI cards, donut, bar charts, treemap, segment comparison |
| 2 — Risk Segmentation | Risk / Portfolio teams | Segment matrix, concentration bars, utilization & coverage |
| 3 — Repayment Behavior | Collections / Credit Risk | PAY_0 analysis, delinquency heatmap, trend charts |
| 4 — Customer Deep Dive | Collections / Relationship | Drill-through table, scatter, filtered profiles |
| 5 — Business Insights | All stakeholders | 8 annotated insight blocks, recommendations |

> **Note:** A `.pbix` binary file cannot be programmatically generated. The specification files above are implementation-ready. See `dashboard_documentation.md` for the complete honesty statement.

---

## Key Analytical Findings

All findings are based on the actual 30,000-row dataset. No results are fabricated.

### Portfolio Health
| KPI | Value |
|---|---|
| Total customers | 30,000 |
| Total credit exposure | NT$5,024,529,680 |
| Overall default rate | **22.12%** |
| Mean credit limit | NT$167,484 |
| Median credit limit | NT$140,000 |
| % always on-time | 66.4% |
| % with any delay | 33.6% |
| % persistent delinquent | 12.5% |

### Risk Segments
| Segment | Customers | % Portfolio | Default Rate | Exposure |
|---|---|---|---|---|
| Low Risk | 13,874 | 46.25% | **10.96%** | NT$2.953B |
| Medium Risk | 10,808 | 36.03% | **19.07%** | NT$1.560B |
| High Risk | 5,318 | 17.73% | **57.43%** | NT$0.512B |

> **Key concentration finding:** High Risk customers (17.7% of portfolio) account for **46.0% of all defaults**.

### Strongest Behavioral Signals
| Signal | Default Rate | vs Portfolio |
|---|---|---|
| PAY_0 = 2 (1 billing cycle behind) | 69.14% | +47.0pp |
| All 6 months delayed | 70.32% | +48.2pp |
| Max delay 7 months | 83.58% | +61.5pp |
| Persistent delinquency (3M+) | 50.9%+ | +28.8pp+ |

### Statistical Tests (all p<0.0001)
| Test | Result |
|---|---|
| MONTHS_DELAYED vs DEFAULT | r = +0.398 (strongest predictor) |
| LIMIT_BAL vs DEFAULT | r = −0.154 |
| Median limit defaulters vs non-defaulters | NT$90K vs NT$150K |
| EDUCATION vs DEFAULT (chi-square) | χ²=163.22 |

---

## Business Recommendations

Based solely on patterns observed in the dataset:

1. **Prioritize monitoring of the High Risk segment** — 17.7% of customers but 46.0% of all defaults.
2. **Flag PAY_0 ≥ 2 as an early-warning trigger** — 69.1% default rate at this threshold.
3. **Treat repeat delinquency (3M+) as a higher priority signal** than single episodes.
4. **Review credit-limit policies for the ≤NT$50K band** — 31.79% default rate vs 11.17% for >NT$500K.
5. **Monitor utilization above 75%** — associated with 30.7–34.2% default rate.
6. **Use behavioral signals ahead of demographic signals** — repayment behavior explains far more variance.
7. **Apply early-stage nudges to Medium Risk customers** (36% of portfolio, 19.07% default rate) to prevent migration to High Risk.

> All recommendations must be validated against regulatory requirements, credit policies, and fair-lending standards before any operational implementation.

---

## Limitations

1. **Temporal snapshot:** The dataset covers only six months (April–September 2005). Repayment behaviors may have changed over time.
2. **Single geography:** Data is from Taiwan; findings may not generalize to other markets.
3. **Observational study:** All statistical associations are correlational. No causal inferences are made.
4. **Undocumented codes:** EDUCATION codes 0, 5, 6 and MARRIAGE code 0 are not defined in the original paper; these rows were retained with annotation.
5. **PAY_1 absent:** The dataset has no PAY_1 column; the naming gap (PAY_0 → PAY_2) is a known dataset characteristic.
6. **Risk segmentation:** The RISK_SCORE framework is an analytical segmentation tool only — not a validated formal credit scoring model.
7. **Static analysis:** The notebook performs cross-sectional analysis on a single 6-month snapshot. Temporal trend analysis requires a longitudinal dataset.
8. **No `.pbix` file:** Power BI Desktop binary files cannot be generated programmatically. The full specification in `powerbi/dashboard_documentation.md` serves as the implementation-ready substitute.

---

## Author

**Kishan Kannaujiya**  
Data Analytics · Business Intelligence · Credit Risk Analytics

---

## Dataset Citation

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

## License

This project is licensed under the MIT License — see [`LICENSE`](LICENSE) for details.  
The UCI dataset has its own terms; see [`data/README.md`](data/README.md).
