-- ============================================================
-- FILE: risk_analysis.sql
-- PROJECT: Credit Card Portfolio Risk & Delinquency Segmentation
-- AUTHOR: Kishan Kannaujiya
-- SQL DIALECT: PostgreSQL 14+
-- SOURCE TABLE: credit_card_customers
--   (loaded from credit_card_enriched.csv produced in Part 1)
-- ============================================================
--
-- HOW TO LOAD:
--   CREATE TABLE credit_card_customers AS
--   SELECT * FROM read_csv_auto('credit_card_enriched.csv', HEADER=TRUE);
--   (DuckDB syntax) OR use \COPY in psql:
--   \COPY credit_card_customers FROM 'credit_card_enriched.csv' WITH (FORMAT CSV, HEADER TRUE);
--
-- EXPECTED COLUMN LIST (original + Part 1 engineered features):
--   Original : ID, LIMIT_BAL, SEX, EDUCATION, MARRIAGE, AGE,
--              PAY_0, PAY_2, PAY_3, PAY_4, PAY_5, PAY_6,
--              BILL_AMT1..6, PAY_AMT1..6, DEFAULT
--   Labels   : EDUCATION_LABEL, MARRIAGE_LABEL, SEX_LABEL, DEFAULT_LABEL
--   Engineered:
--     AVG_BILL_AMT, MAX_BILL_AMT, TOTAL_BILL_6M,
--     TOTAL_PAY_6M, AVG_PAY_AMT,
--     PAY_TO_BILL_RATIO, UTILIZATION,
--     AVG_PAY_STATUS, MAX_PAY_DELAY,
--     MONTHS_DELAYED, MONTHS_SEVERE_DELAY,
--     PERSISTENT_DELINQUENT, RECENT_DELINQUENT, ALWAYS_ON_TIME,
--     BILL_VOLATILITY, PAY_COVERAGE,
--     RISK_SCORE, RISK_SEGMENT,
--     LIMIT_BAND, UTIL_BAND, AGE_GROUP
--
-- NOTE: All expected output values are documented inline based on
--       actual Part 1 Python/pandas results from the 30,000-row dataset.
--       Results of each query should match the Part 1 reference numbers.
-- ============================================================


-- ============================================================
-- QUERY 1: OVERALL PORTFOLIO KPIs
-- Expected: Total customers = 30,000 | Default rate = 22.12%
--           Total exposure = 5,024,529,680 | Mean limit = 167,484
-- ============================================================
SELECT
    COUNT(*)                                    AS total_customers,
    SUM("DEFAULT")                              AS total_defaulters,
    COUNT(*) - SUM("DEFAULT")                  AS total_non_defaulters,
    ROUND(AVG("DEFAULT") * 100, 2)             AS default_rate_pct,
    SUM("LIMIT_BAL")                           AS total_credit_exposure,
    ROUND(AVG("LIMIT_BAL"), 0)                 AS mean_credit_limit,
    PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY "LIMIT_BAL")                 AS median_credit_limit,
    ROUND(AVG("TOTAL_BILL_6M"), 0)             AS avg_6m_total_bill,
    ROUND(AVG("TOTAL_PAY_6M"), 0)              AS avg_6m_total_payment,
    ROUND(AVG("UTILIZATION") * 100, 2)         AS mean_utilization_pct,
    ROUND(AVG("ALWAYS_ON_TIME") * 100, 2)      AS pct_always_on_time,
    ROUND(
        SUM(CASE WHEN "MONTHS_DELAYED" > 0 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    )                                           AS pct_any_delay,
    ROUND(AVG("PERSISTENT_DELINQUENT") * 100, 2) AS pct_persistent_delinquent,
    ROUND(AVG("RECENT_DELINQUENT") * 100, 2)   AS pct_recent_delinquent
FROM credit_card_customers;


-- ============================================================
-- QUERY 2: DEFAULT RATE
-- Expected: Default rate = 22.12% (6,636 of 30,000)
-- ============================================================
SELECT
    SUM("DEFAULT")                              AS defaulted_customers,
    COUNT(*) - SUM("DEFAULT")                  AS non_defaulted_customers,
    COUNT(*)                                    AS total_customers,
    ROUND(SUM("DEFAULT") * 100.0 / COUNT(*), 4) AS default_rate_pct,
    ROUND((1 - AVG("DEFAULT")) * 100, 4)       AS non_default_rate_pct
FROM credit_card_customers;


-- ============================================================
-- QUERY 3: DEFAULT COUNT & RATE BY DEFAULT STATUS
-- ============================================================
SELECT
    "DEFAULT_LABEL"                             AS default_status,
    COUNT(*)                                    AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_portfolio
FROM credit_card_customers
GROUP BY "DEFAULT_LABEL"
ORDER BY "DEFAULT_LABEL";


-- ============================================================
-- QUERY 4: CREDIT EXPOSURE ANALYSIS
-- Expected total exposure = 5,024,529,680
--           Low Risk NT$2.953B | Medium Risk NT$1.560B | High Risk NT$0.512B
-- ============================================================
SELECT
    "RISK_SEGMENT",
    COUNT(*)                                    AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_portfolio,
    SUM("LIMIT_BAL")                           AS total_exposure,
    ROUND(SUM("LIMIT_BAL") * 100.0
          / SUM(SUM("LIMIT_BAL")) OVER (), 2)  AS pct_total_exposure,
    ROUND(AVG("LIMIT_BAL"), 0)                 AS avg_limit,
    ROUND(AVG("DEFAULT") * 100, 2)             AS default_rate_pct
FROM credit_card_customers
GROUP BY "RISK_SEGMENT"
ORDER BY
    CASE "RISK_SEGMENT"
        WHEN 'Low Risk'    THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'High Risk'   THEN 3
    END;


-- ============================================================
-- QUERY 5: DEFAULT RATE BY EDUCATION
-- Expected: Graduate School 19.23% | University 23.73% | High School 25.16%
-- ============================================================
SELECT
    "EDUCATION_LABEL"                           AS education_level,
    COUNT(*)                                    AS customer_count,
    SUM("DEFAULT")                              AS defaulters,
    ROUND(AVG("DEFAULT") * 100, 4)             AS default_rate_pct
FROM credit_card_customers
GROUP BY "EDUCATION_LABEL"
ORDER BY default_rate_pct DESC;


-- ============================================================
-- QUERY 6: DEFAULT RATE BY AGE GROUP
-- Expected: 20-29: 22.8% | 30-39: 20.3% | 40-49: 23.0%
--           50-59: 24.9% | 60+: 28.3%
-- ============================================================
SELECT
    "AGE_GROUP"                                 AS age_group,
    COUNT(*)                                    AS customer_count,
    SUM("DEFAULT")                              AS defaulters,
    ROUND(AVG("DEFAULT") * 100, 4)             AS default_rate_pct,
    ROUND(AVG("AGE"), 1)                       AS avg_age
FROM credit_card_customers
GROUP BY "AGE_GROUP"
ORDER BY "AGE_GROUP";


-- ============================================================
-- QUERY 7: DEFAULT RATE BY CREDIT-LIMIT BAND
-- Expected: <=50K: 31.79% | 50K-100K: 25.80% | 100K-200K: 19.48%
--           200K-500K: 14.80% | >500K: 11.17%
-- ============================================================
SELECT
    "LIMIT_BAND"                                AS credit_limit_band,
    COUNT(*)                                    AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_portfolio,
    SUM("DEFAULT")                              AS defaulters,
    ROUND(AVG("DEFAULT") * 100, 4)             AS default_rate_pct,
    ROUND(AVG("LIMIT_BAL"), 0)                 AS avg_limit,
    SUM("LIMIT_BAL")                           AS total_exposure
FROM credit_card_customers
GROUP BY "LIMIT_BAND"
ORDER BY
    CASE "LIMIT_BAND"
        WHEN '<=50K'      THEN 1
        WHEN '50K-100K'   THEN 2
        WHEN '100K-200K'  THEN 3
        WHEN '200K-500K'  THEN 4
        WHEN '>500K'      THEN 5
    END;


-- ============================================================
-- QUERY 8: DEFAULT RATE BY MOST RECENT REPAYMENT STATUS (PAY_0)
-- Expected: PAY_0 = 2 → 69.14% default rate (2,667 customers)
-- ============================================================
SELECT
    "PAY_0"                                     AS repayment_status_sep05,
    COUNT(*)                                    AS customer_count,
    SUM("DEFAULT")                              AS defaulters,
    ROUND(AVG("DEFAULT") * 100, 4)             AS default_rate_pct,
    CASE
        WHEN "PAY_0" <= -1 THEN 'Paid in full / No consumption'
        WHEN "PAY_0" =  0  THEN 'Revolving credit'
        WHEN "PAY_0" =  1  THEN '1 month delay'
        WHEN "PAY_0" =  2  THEN '2 months delay'
        WHEN "PAY_0" =  3  THEN '3 months delay'
        WHEN "PAY_0" >= 4  THEN '4+ months delay'
        ELSE 'Unknown'
    END                                         AS status_description
FROM credit_card_customers
GROUP BY "PAY_0"
ORDER BY "PAY_0";


-- ============================================================
-- QUERY 9: HIGH-UTILIZATION CUSTOMERS
-- Expected: utilization >75% → ~30.7–34.2% default rates
-- ============================================================
SELECT
    "UTIL_BAND"                                 AS utilization_band,
    COUNT(*)                                    AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_portfolio,
    SUM("DEFAULT")                              AS defaulters,
    ROUND(AVG("DEFAULT") * 100, 4)             AS default_rate_pct,
    ROUND(AVG("UTILIZATION") * 100, 2)         AS avg_utilization_pct,
    ROUND(AVG("LIMIT_BAL"), 0)                 AS avg_credit_limit
FROM credit_card_customers
GROUP BY "UTIL_BAND"
ORDER BY
    CASE "UTIL_BAND"
        WHEN '<=0%'    THEN 1
        WHEN '0-25%'   THEN 2
        WHEN '25-50%'  THEN 3
        WHEN '50-75%'  THEN 4
        WHEN '75-100%' THEN 5
        WHEN '>100%'   THEN 6
    END;


-- ============================================================
-- QUERY 10: DELINQUENCY SEGMENTATION
-- Expected: 0 delayed months → 11.7% default rate (19,931 customers)
--           6 delayed months → 70.32% default rate (1,341 customers)
-- ============================================================
SELECT
    "MONTHS_DELAYED"                            AS months_with_delay,
    COUNT(*)                                    AS customer_count,
    SUM("DEFAULT")                              AS defaulters,
    ROUND(AVG("DEFAULT") * 100, 4)             AS default_rate_pct,
    ROUND(AVG("UTILIZATION") * 100, 2)         AS avg_utilization_pct,
    ROUND(AVG("PAY_COVERAGE"), 4)              AS avg_pay_coverage,
    ROUND(AVG("LIMIT_BAL"), 0)                 AS avg_credit_limit
FROM credit_card_customers
GROUP BY "MONTHS_DELAYED"
ORDER BY "MONTHS_DELAYED";


-- ============================================================
-- QUERY 11: RISK SEGMENT SUMMARY (CTE approach)
-- Expected segments: Low 46.25% / Medium 36.03% / High 17.73%
-- Default rates: Low 10.96% / Medium 19.07% / High 57.43%
-- ============================================================
WITH segment_stats AS (
    SELECT
        "RISK_SEGMENT",
        COUNT(*)                                    AS customer_count,
        SUM("DEFAULT")                              AS defaulters,
        AVG("DEFAULT")                              AS default_rate,
        SUM("LIMIT_BAL")                           AS total_exposure,
        AVG("LIMIT_BAL")                           AS avg_limit,
        AVG("UTILIZATION")                         AS avg_utilization,
        AVG("MONTHS_DELAYED")                      AS avg_months_delayed,
        AVG("MAX_PAY_DELAY")                       AS avg_max_delay,
        AVG("PAY_COVERAGE")                        AS avg_pay_coverage,
        AVG("RISK_SCORE")                          AS avg_risk_score
    FROM credit_card_customers
    GROUP BY "RISK_SEGMENT"
),
totals AS (
    SELECT
        SUM(customer_count) AS total_customers,
        SUM(defaulters)     AS total_defaulters,
        SUM(total_exposure) AS total_exposure
    FROM segment_stats
)
SELECT
    ss."RISK_SEGMENT"                            AS risk_segment,
    ss.customer_count,
    ROUND(ss.customer_count * 100.0 / t.total_customers, 2) AS pct_portfolio,
    ss.defaulters,
    ROUND(ss.defaulters * 100.0 / t.total_defaulters, 2)    AS pct_all_defaults,
    ROUND(ss.default_rate * 100, 4)             AS default_rate_pct,
    ss.total_exposure,
    ROUND(ss.total_exposure * 100.0 / t.total_exposure, 2)  AS pct_total_exposure,
    ROUND(ss.avg_limit, 0)                      AS avg_credit_limit,
    ROUND(ss.avg_utilization * 100, 2)          AS avg_utilization_pct,
    ROUND(ss.avg_months_delayed, 4)             AS avg_months_delayed,
    ROUND(ss.avg_max_delay, 4)                  AS avg_max_delay,
    ROUND(ss.avg_pay_coverage, 4)               AS avg_pay_coverage,
    ROUND(ss.avg_risk_score, 2)                 AS avg_risk_score
FROM segment_stats ss
CROSS JOIN totals t
ORDER BY
    CASE ss."RISK_SEGMENT"
        WHEN 'Low Risk'    THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'High Risk'   THEN 3
    END;


-- ============================================================
-- QUERY 12: TOP RISK PATTERNS — RANKED BY DEFAULT RATE
-- Behavioral cross-segments using window functions
-- ============================================================
WITH behavior_buckets AS (
    SELECT
        CASE
            WHEN "MAX_PAY_DELAY" >= 2 AND "MONTHS_DELAYED" >= 3
                THEN 'Persistent + Severe Delay'
            WHEN "MAX_PAY_DELAY" >= 2 AND "MONTHS_DELAYED" < 3
                THEN 'Severe (single episode)'
            WHEN "MAX_PAY_DELAY" = 1 AND "MONTHS_DELAYED" >= 2
                THEN 'Moderate Repeated Delay'
            WHEN "RECENT_DELINQUENT" = 1 AND "MONTHS_DELAYED" = 1
                THEN 'Recent Only (single month)'
            WHEN "ALWAYS_ON_TIME" = 1 AND "UTILIZATION" > 0.75
                THEN 'On-time but High Utilization'
            WHEN "ALWAYS_ON_TIME" = 1
                THEN 'Consistently On-time'
            ELSE 'Other'
        END                                         AS behavior_pattern,
        "DEFAULT"
    FROM credit_card_customers
),
pattern_stats AS (
    SELECT
        behavior_pattern,
        COUNT(*)                                    AS customer_count,
        SUM("DEFAULT")                              AS defaulters,
        ROUND(AVG("DEFAULT") * 100, 4)             AS default_rate_pct
    FROM behavior_buckets
    GROUP BY behavior_pattern
)
SELECT
    behavior_pattern,
    customer_count,
    defaulters,
    default_rate_pct,
    RANK() OVER (ORDER BY default_rate_pct DESC)   AS risk_rank
FROM pattern_stats
ORDER BY default_rate_pct DESC;


-- ============================================================
-- QUERY 13: PORTFOLIO CONCENTRATION ANALYSIS
-- Default share vs customer share by segment
-- ============================================================
WITH portfolio AS (
    SELECT
        "RISK_SEGMENT",
        COUNT(*)          AS customers,
        SUM("DEFAULT")    AS defaults,
        SUM("LIMIT_BAL") AS exposure
    FROM credit_card_customers
    GROUP BY "RISK_SEGMENT"
),
totals AS (
    SELECT
        SUM(customers) AS n,
        SUM(defaults)  AS d,
        SUM(exposure)  AS e
    FROM portfolio
)
SELECT
    p."RISK_SEGMENT",
    ROUND(p.customers * 100.0 / t.n, 2)      AS pct_customers,
    ROUND(p.defaults  * 100.0 / t.d, 2)      AS pct_defaults,
    ROUND(p.exposure  * 100.0 / t.e, 2)      AS pct_exposure,
    ROUND((p.defaults * 100.0 / t.d) /
          (p.customers * 100.0 / t.n), 4)    AS concentration_ratio
    -- concentration_ratio > 1 means segment is over-represented in defaults
FROM portfolio p
CROSS JOIN totals t
ORDER BY concentration_ratio DESC;


-- ============================================================
-- QUERY 14: CUSTOMER-LEVEL ANALYTICAL SUMMARY
-- Full per-customer risk profile — usable for Power BI drill-through
-- ============================================================
SELECT
    "ID"                                        AS customer_id,
    "LIMIT_BAL"                                AS credit_limit,
    "SEX_LABEL"                                AS gender,
    "EDUCATION_LABEL"                          AS education,
    "MARRIAGE_LABEL"                           AS marital_status,
    "AGE"                                      AS age,
    "AGE_GROUP"                                AS age_group,
    "LIMIT_BAND"                               AS credit_limit_band,
    -- Repayment behavior
    "PAY_0"                                    AS pay_status_sep05,
    "PAY_2"                                    AS pay_status_aug05,
    "PAY_3"                                    AS pay_status_jul05,
    "MAX_PAY_DELAY"                            AS max_payment_delay,
    "MONTHS_DELAYED"                           AS months_delayed,
    "MONTHS_SEVERE_DELAY"                      AS months_severe_delay,
    "PERSISTENT_DELINQUENT"                    AS persistent_delinquent_flag,
    "RECENT_DELINQUENT"                        AS recent_delinquent_flag,
    "ALWAYS_ON_TIME"                           AS always_on_time_flag,
    -- Financial metrics
    ROUND("AVG_BILL_AMT", 0)                  AS avg_monthly_bill,
    ROUND("TOTAL_BILL_6M", 0)                 AS total_6m_bill,
    ROUND("TOTAL_PAY_6M", 0)                  AS total_6m_payment,
    ROUND("UTILIZATION", 4)                   AS utilization_ratio,
    "UTIL_BAND"                                AS utilization_band,
    ROUND("PAY_COVERAGE", 4)                  AS payment_coverage_ratio,
    ROUND("PAY_TO_BILL_RATIO", 4)             AS pay_to_bill_ratio,
    -- Risk
    "RISK_SCORE"                               AS risk_score,
    "RISK_SEGMENT"                             AS risk_segment,
    "DEFAULT"                                  AS defaulted,
    "DEFAULT_LABEL"                            AS default_status
FROM credit_card_customers
ORDER BY "RISK_SCORE" DESC, "MONTHS_DELAYED" DESC;


-- ============================================================
-- BONUS QUERY A: REPAYMENT BEHAVIOR HEATMAP DATA
-- Provides counts for each PAY_0 × DEFAULT combination
-- ============================================================
SELECT
    "PAY_0"                                     AS repayment_status,
    "DEFAULT"                                   AS defaulted,
    COUNT(*)                                    AS customer_count,
    ROUND(COUNT(*) * 100.0
          / SUM(COUNT(*)) OVER (PARTITION BY "PAY_0"), 2) AS pct_within_status
FROM credit_card_customers
GROUP BY "PAY_0", "DEFAULT"
ORDER BY "PAY_0", "DEFAULT";


-- ============================================================
-- BONUS QUERY B: MONTH-BY-MONTH AVERAGE BILL & PAYMENT
-- (for trend line visual in Power BI)
-- ============================================================
SELECT
    'September 2005'                            AS statement_month,
    1                                           AS month_order,
    ROUND(AVG("BILL_AMT1"), 0)                AS avg_bill,
    ROUND(AVG("PAY_AMT1"), 0)                 AS avg_payment,
    ROUND(AVG(CASE WHEN "DEFAULT"=1 THEN "BILL_AMT1" END), 0) AS avg_bill_default,
    ROUND(AVG(CASE WHEN "DEFAULT"=0 THEN "BILL_AMT1" END), 0) AS avg_bill_nondefault
FROM credit_card_customers
UNION ALL
SELECT 'August 2005', 2,
    ROUND(AVG("BILL_AMT2"), 0), ROUND(AVG("PAY_AMT2"), 0),
    ROUND(AVG(CASE WHEN "DEFAULT"=1 THEN "BILL_AMT2" END), 0),
    ROUND(AVG(CASE WHEN "DEFAULT"=0 THEN "BILL_AMT2" END), 0)
FROM credit_card_customers
UNION ALL
SELECT 'July 2005', 3,
    ROUND(AVG("BILL_AMT3"), 0), ROUND(AVG("PAY_AMT3"), 0),
    ROUND(AVG(CASE WHEN "DEFAULT"=1 THEN "BILL_AMT3" END), 0),
    ROUND(AVG(CASE WHEN "DEFAULT"=0 THEN "BILL_AMT3" END), 0)
FROM credit_card_customers
UNION ALL
SELECT 'June 2005', 4,
    ROUND(AVG("BILL_AMT4"), 0), ROUND(AVG("PAY_AMT4"), 0),
    ROUND(AVG(CASE WHEN "DEFAULT"=1 THEN "BILL_AMT4" END), 0),
    ROUND(AVG(CASE WHEN "DEFAULT"=0 THEN "BILL_AMT4" END), 0)
FROM credit_card_customers
UNION ALL
SELECT 'May 2005', 5,
    ROUND(AVG("BILL_AMT5"), 0), ROUND(AVG("PAY_AMT5"), 0),
    ROUND(AVG(CASE WHEN "DEFAULT"=1 THEN "BILL_AMT5" END), 0),
    ROUND(AVG(CASE WHEN "DEFAULT"=0 THEN "BILL_AMT5" END), 0)
FROM credit_card_customers
UNION ALL
SELECT 'April 2005', 6,
    ROUND(AVG("BILL_AMT6"), 0), ROUND(AVG("PAY_AMT6"), 0),
    ROUND(AVG(CASE WHEN "DEFAULT"=1 THEN "BILL_AMT6" END), 0),
    ROUND(AVG(CASE WHEN "DEFAULT"=0 THEN "BILL_AMT6" END), 0)
FROM credit_card_customers
ORDER BY month_order;


-- ============================================================
-- BONUS QUERY C: DEMOGRAPHIC DEFAULT COMPARISON (for KPI matrix)
-- ============================================================
SELECT
    'Sex'                                       AS dimension,
    "SEX_LABEL"                                AS segment_value,
    COUNT(*)                                    AS customers,
    SUM("DEFAULT")                              AS defaults,
    ROUND(AVG("DEFAULT") * 100, 2)             AS default_rate_pct,
    ROUND(AVG("LIMIT_BAL"), 0)                 AS avg_limit
FROM credit_card_customers
GROUP BY "SEX_LABEL"

UNION ALL

SELECT
    'Education',
    "EDUCATION_LABEL",
    COUNT(*),
    SUM("DEFAULT"),
    ROUND(AVG("DEFAULT") * 100, 2),
    ROUND(AVG("LIMIT_BAL"), 0)
FROM credit_card_customers
GROUP BY "EDUCATION_LABEL"

UNION ALL

SELECT
    'Marital Status',
    "MARRIAGE_LABEL",
    COUNT(*),
    SUM("DEFAULT"),
    ROUND(AVG("DEFAULT") * 100, 2),
    ROUND(AVG("LIMIT_BAL"), 0)
FROM credit_card_customers
GROUP BY "MARRIAGE_LABEL"

UNION ALL

SELECT
    'Age Group',
    "AGE_GROUP"::TEXT,
    COUNT(*),
    SUM("DEFAULT"),
    ROUND(AVG("DEFAULT") * 100, 2),
    ROUND(AVG("LIMIT_BAL"), 0)
FROM credit_card_customers
GROUP BY "AGE_GROUP"

ORDER BY dimension, default_rate_pct DESC;


-- ============================================================
-- BONUS QUERY D: TOP 10% RISK-SCORE CUSTOMERS
-- Window function: identify the highest-risk cohort
-- ============================================================
WITH ranked AS (
    SELECT
        "ID",
        "LIMIT_BAL",
        "RISK_SCORE",
        "RISK_SEGMENT",
        "MONTHS_DELAYED",
        "MAX_PAY_DELAY",
        "UTILIZATION",
        "PAY_COVERAGE",
        "DEFAULT",
        NTILE(10) OVER (ORDER BY "RISK_SCORE" DESC) AS decile
    FROM credit_card_customers
)
SELECT
    decile,
    COUNT(*)                                    AS customer_count,
    SUM("DEFAULT")                              AS defaulters,
    ROUND(AVG("DEFAULT") * 100, 2)             AS default_rate_pct,
    ROUND(AVG("RISK_SCORE"), 2)                AS avg_risk_score,
    ROUND(AVG("MONTHS_DELAYED"), 2)            AS avg_months_delayed,
    ROUND(AVG("UTILIZATION") * 100, 2)         AS avg_utilization_pct,
    ROUND(AVG("LIMIT_BAL"), 0)                 AS avg_limit
FROM ranked
GROUP BY decile
ORDER BY decile;


-- ============================================================
-- BONUS QUERY E: HAVING CLAUSE — Segments with default rate > 40%
-- ============================================================
SELECT
    "RISK_SEGMENT",
    "LIMIT_BAND",
    COUNT(*)                                    AS customer_count,
    ROUND(AVG("DEFAULT") * 100, 2)             AS default_rate_pct,
    SUM("LIMIT_BAL")                           AS total_exposure
FROM credit_card_customers
GROUP BY "RISK_SEGMENT", "LIMIT_BAND"
HAVING AVG("DEFAULT") > 0.40
ORDER BY default_rate_pct DESC;

-- ============================================================
-- END OF FILE: risk_analysis.sql
-- ============================================================
