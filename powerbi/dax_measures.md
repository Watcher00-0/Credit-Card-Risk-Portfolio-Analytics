# DAX Measures Reference
## Credit Card Portfolio Risk & Delinquency Segmentation
**Author:** Kishan Kannaujiya  
**Tool:** Power BI Desktop  
**Data Source:** `credit_card_enriched.csv` (table name in Power BI: `CreditCardCustomers`)

> All expected values documented inline are the **actual Part 1 computed results** from the 30,000-row dataset.  
> DAX syntax follows Power BI DAX 2024 conventions. All measures are meant to be created in the `Measures` table.

---

## Setup — Data Import Note

Import `credit_card_enriched.csv` into Power BI Desktop via **Get Data → Text/CSV**.  
Rename the table to **`CreditCardCustomers`** in Power Query before loading.  
All DAX below references this exact table name.

---

## Section 1 — Core Portfolio KPIs

### [Total Customers]
```dax
Total Customers = 
COUNTROWS( CreditCardCustomers )
```
> **Expected value:** 30,000  
> _Counts all rows in the table. No filter applied intentionally — this is the base portfolio count._

---

### [Defaulted Customers]
```dax
Defaulted Customers = 
CALCULATE(
    COUNTROWS( CreditCardCustomers ),
    CreditCardCustomers[DEFAULT] = 1
)
```
> **Expected value:** 6,636  
> _Count of customers with DEFAULT = 1 (defaulted on next payment)._

---

### [Non-Default Customers]
```dax
Non-Default Customers = 
CALCULATE(
    COUNTROWS( CreditCardCustomers ),
    CreditCardCustomers[DEFAULT] = 0
)
```
> **Expected value:** 23,364

---

### [Default Rate]
```dax
Default Rate = 
DIVIDE(
    CALCULATE( COUNTROWS( CreditCardCustomers ), CreditCardCustomers[DEFAULT] = 1 ),
    COUNTROWS( CreditCardCustomers ),
    0
)
```
> **Expected value:** 0.2212 (displayed as 22.12% with percentage format)  
> _DIVIDE() safely handles zero denominator — returns 0 if no rows exist._

---

### [Default Rate %]
```dax
Default Rate % = 
FORMAT( [Default Rate], "0.00%" )
```
> **Expected value:** "22.12%"  
> _String version for use in dynamic titles and card visuals._

---

### [Total Credit Exposure]
```dax
Total Credit Exposure = 
SUM( CreditCardCustomers[LIMIT_BAL] )
```
> **Expected value:** 5,024,529,680 (NT$)  
> _Sum of all credit limits across the portfolio._

---

### [Average Credit Limit]
```dax
Average Credit Limit = 
AVERAGE( CreditCardCustomers[LIMIT_BAL] )
```
> **Expected value:** 167,484 (NT$)

---

### [Median Credit Limit]
```dax
Median Credit Limit = 
MEDIAN( CreditCardCustomers[LIMIT_BAL] )
```
> **Expected value:** 140,000 (NT$)

---

### [Average Utilization]
```dax
Average Utilization = 
AVERAGEX(
    FILTER( CreditCardCustomers, NOT ISBLANK( CreditCardCustomers[UTILIZATION] ) ),
    CreditCardCustomers[UTILIZATION]
)
```
> **Expected value:** 0.3730 (displayed as 37.3%)  
> _Filters out any blank UTILIZATION values before averaging._

---

### [Median Utilization]
```dax
Median Utilization = 
MEDIANX(
    FILTER( CreditCardCustomers, NOT ISBLANK( CreditCardCustomers[UTILIZATION] ) ),
    CreditCardCustomers[UTILIZATION]
)
```
> **Expected value:** 0.2848 (28.5%)

---

## Section 2 — Payment & Billing KPIs

### [Average 6M Total Bill]
```dax
Average 6M Total Bill = 
AVERAGE( CreditCardCustomers[TOTAL_BILL_6M] )
```
> **Expected value:** 269,862 (NT$)

---

### [Average 6M Total Payment]
```dax
Average 6M Total Payment = 
AVERAGE( CreditCardCustomers[TOTAL_PAY_6M] )
```
> **Expected value:** 31,651 (NT$)

---

### [Average Monthly Payment]
```dax
Average Monthly Payment = 
AVERAGE( CreditCardCustomers[AVG_PAY_AMT] )
```
> **Expected value:** ~5,275 (NT$)

---

### [Average Monthly Bill]
```dax
Average Monthly Bill = 
AVERAGE( CreditCardCustomers[AVG_BILL_AMT] )
```
> **Expected value:** ~44,977 (NT$)

---

### [Average Payment Coverage]
```dax
Average Payment Coverage = 
AVERAGEX(
    FILTER( CreditCardCustomers, NOT ISBLANK( CreditCardCustomers[PAY_COVERAGE] ) ),
    CreditCardCustomers[PAY_COVERAGE]
)
```
> **Expected value:** ~0.487 (49%)  
> _Represents what fraction of the average bill is covered by average payment._

---

### [Average Pay-to-Bill Ratio]
```dax
Average Pay To Bill Ratio = 
AVERAGEX(
    FILTER( CreditCardCustomers, NOT ISBLANK( CreditCardCustomers[PAY_TO_BILL_RATIO] ) ),
    CreditCardCustomers[PAY_TO_BILL_RATIO]
)
```
> _6M total payment divided by 6M total bill. Identical result to PAY_COVERAGE at portfolio level._

---

## Section 3 — Delinquency KPIs

### [% Always On-Time]
```dax
Pct Always On-Time = 
DIVIDE(
    CALCULATE( COUNTROWS( CreditCardCustomers ), CreditCardCustomers[ALWAYS_ON_TIME] = 1 ),
    COUNTROWS( CreditCardCustomers ),
    0
)
```
> **Expected value:** 0.6644 (66.4%)

---

### [% Any Delay (6M)]
```dax
Pct Any Delay = 
DIVIDE(
    CALCULATE( COUNTROWS( CreditCardCustomers ), CreditCardCustomers[MONTHS_DELAYED] > 0 ),
    COUNTROWS( CreditCardCustomers ),
    0
)
```
> **Expected value:** 0.3356 (33.6%)

---

### [% Persistent Delinquent]
```dax
Pct Persistent Delinquent = 
DIVIDE(
    CALCULATE( COUNTROWS( CreditCardCustomers ), CreditCardCustomers[PERSISTENT_DELINQUENT] = 1 ),
    COUNTROWS( CreditCardCustomers ),
    0
)
```
> **Expected value:** 0.1248 (12.5%)  
> _PERSISTENT_DELINQUENT = 1 when MONTHS_DELAYED ≥ 3._

---

### [% Recent Delinquent]
```dax
Pct Recent Delinquent = 
DIVIDE(
    CALCULATE( COUNTROWS( CreditCardCustomers ), CreditCardCustomers[RECENT_DELINQUENT] = 1 ),
    COUNTROWS( CreditCardCustomers ),
    0
)
```
> **Expected value:** 0.2273 (22.7%)  
> _RECENT_DELINQUENT = 1 when PAY_0 > 0._

---

### [Average Months Delayed]
```dax
Average Months Delayed = 
AVERAGE( CreditCardCustomers[MONTHS_DELAYED] )
```
> **Expected value:** 0.834 months

---

### [Average Max Pay Delay]
```dax
Average Max Pay Delay = 
AVERAGE( CreditCardCustomers[MAX_PAY_DELAY] )
```
> **Expected value:** 0.439 months

---

## Section 4 — Risk Segment Measures

### [Customers by Risk Segment — Low Risk]
```dax
Low Risk Customers = 
CALCULATE(
    COUNTROWS( CreditCardCustomers ),
    CreditCardCustomers[RISK_SEGMENT] = "Low Risk"
)
```
> **Expected value:** 13,874

---

### [Customers by Risk Segment — Medium Risk]
```dax
Medium Risk Customers = 
CALCULATE(
    COUNTROWS( CreditCardCustomers ),
    CreditCardCustomers[RISK_SEGMENT] = "Medium Risk"
)
```
> **Expected value:** 10,808

---

### [Customers by Risk Segment — High Risk]
```dax
High Risk Customers = 
CALCULATE(
    COUNTROWS( CreditCardCustomers ),
    CreditCardCustomers[RISK_SEGMENT] = "High Risk"
)
```
> **Expected value:** 5,318

---

### [Default Rate — Low Risk Segment]
```dax
Default Rate Low Risk = 
CALCULATE(
    [Default Rate],
    CreditCardCustomers[RISK_SEGMENT] = "Low Risk"
)
```
> **Expected value:** 0.1096 (10.96%)

---

### [Default Rate — Medium Risk Segment]
```dax
Default Rate Medium Risk = 
CALCULATE(
    [Default Rate],
    CreditCardCustomers[RISK_SEGMENT] = "Medium Risk"
)
```
> **Expected value:** 0.1907 (19.07%)

---

### [Default Rate — High Risk Segment]
```dax
Default Rate High Risk = 
CALCULATE(
    [Default Rate],
    CreditCardCustomers[RISK_SEGMENT] = "High Risk"
)
```
> **Expected value:** 0.5743 (57.43%)

---

### [Selected Segment Default Rate]
```dax
Selected Segment Default Rate = 
IF(
    HASONEVALUE( CreditCardCustomers[RISK_SEGMENT] ),
    [Default Rate],
    BLANK()
)
```
> _Returns the default rate only when exactly one segment is selected (slicer context). Used in segment-detail KPI cards._

---

### [Segment Default Rate vs Portfolio]
```dax
Segment Default Rate vs Portfolio = 
[Default Rate] - CALCULATE( [Default Rate], ALL( CreditCardCustomers[RISK_SEGMENT] ) )
```
> _Difference between the segment's default rate and the overall portfolio default rate (22.12%).  
> Positive = above average risk. Used for conditional formatting._

---

### [High Risk Share of Defaults]
```dax
High Risk Share of Defaults = 
DIVIDE(
    CALCULATE(
        CALCULATE( COUNTROWS( CreditCardCustomers ), CreditCardCustomers[DEFAULT] = 1 ),
        CreditCardCustomers[RISK_SEGMENT] = "High Risk"
    ),
    CALCULATE( COUNTROWS( CreditCardCustomers ), CreditCardCustomers[DEFAULT] = 1 ),
    0
)
```
> **Expected value:** 0.4600 (46.0%)  
> _17.7% of customers generate 46.0% of all defaults — key concentration metric._

---

### [Credit Exposure by Segment]
```dax
Credit Exposure by Segment = 
CALCULATE( SUM( CreditCardCustomers[LIMIT_BAL] ), ALLEXCEPT( CreditCardCustomers, CreditCardCustomers[RISK_SEGMENT] ) )
```
> _Use in a matrix or clustered bar; returns total exposure scoped to whichever segment is in context._

---

## Section 5 — Dynamic Titles & Context Labels

### [Dashboard Title — Default Rate]
```dax
Dashboard Title Default Rate = 
"Overall Default Rate: " & FORMAT( [Default Rate], "0.00%" )
```
> **Example output:** "Overall Default Rate: 22.12%"

---

### [Selected Filters Label]
```dax
Selected Filters Label = 
VAR seg  = IF( HASONEVALUE( CreditCardCustomers[RISK_SEGMENT] ), SELECTEDVALUE( CreditCardCustomers[RISK_SEGMENT] ), "All Segments" )
VAR edu  = IF( HASONEVALUE( CreditCardCustomers[EDUCATION_LABEL] ), SELECTEDVALUE( CreditCardCustomers[EDUCATION_LABEL] ), "All Education" )
RETURN
    seg & " | " & edu
```
> _Builds a dynamic subtitle string reflecting active slicer selections._

---

### [KPI Card — Default Rate with Arrow]
```dax
Default Rate Card Label = 
VAR rate = [Default Rate]
VAR portfolio_rate = CALCULATE( [Default Rate], ALL( CreditCardCustomers ) )
VAR diff = rate - portfolio_rate
RETURN
    FORMAT( rate, "0.00%" ) &
    IF( diff > 0, " ▲", IF( diff < 0, " ▼", " ●" ) )
```
> _Appends an up/down arrow to the default rate for segment comparison cards._

---

## Section 6 — Conditional Formatting Measures

### [Default Rate Color Threshold]
```dax
Default Rate Color Value = 
SWITCH(
    TRUE(),
    [Default Rate] >= 0.50,  3,  -- Red (High risk)
    [Default Rate] >= 0.30,  2,  -- Orange (Elevated)
    [Default Rate] >= 0.22,  1,  -- Amber (Above average)
    0                            -- Green (Below average)
)
```
> _Returns 0–3 integer for use in conditional formatting rules on matrices and cards._

---

### [Utilization Color Flag]
```dax
Utilization Color Flag = 
SWITCH(
    TRUE(),
    AVERAGE( CreditCardCustomers[UTILIZATION] ) > 0.90, 3,
    AVERAGE( CreditCardCustomers[UTILIZATION] ) > 0.75, 2,
    AVERAGE( CreditCardCustomers[UTILIZATION] ) > 0.50, 1,
    0
)
```

---

## Section 7 — Repayment Behavior Measures

### [PAY_0 Category Distribution]
```dax
PAY0 Delayed Count = 
CALCULATE(
    COUNTROWS( CreditCardCustomers ),
    CreditCardCustomers[PAY_0] > 0
)
```

---

### [Severe Delinquency Count]
```dax
Severe Delinquency Count = 
CALCULATE(
    COUNTROWS( CreditCardCustomers ),
    CreditCardCustomers[MONTHS_SEVERE_DELAY] >= 2
)
```

---

### [Average Risk Score]
```dax
Average Risk Score = 
AVERAGE( CreditCardCustomers[RISK_SCORE] )
```
> **Expected value:** ~3.36 (portfolio-level average)

---

### [High Risk Score Count (Score ≥ 7)]
```dax
High Risk Score Count = 
CALCULATE(
    COUNTROWS( CreditCardCustomers ),
    CreditCardCustomers[RISK_SCORE] >= 7
)
```
> **Expected value:** 5,318 (matches High Risk segment definition)

---

## Section 8 — Demographic Measures

### [Male Default Rate]
```dax
Male Default Rate = 
CALCULATE( [Default Rate], CreditCardCustomers[SEX] = 1 )
```
> **Expected value:** 0.2417 (24.17%)

---

### [Female Default Rate]
```dax
Female Default Rate = 
CALCULATE( [Default Rate], CreditCardCustomers[SEX] = 2 )
```
> **Expected value:** 0.2078 (20.78%)

---

### [Default Rate — Low Credit Limit (≤50K)]
```dax
Default Rate Low Limit Band = 
CALCULATE( [Default Rate], CreditCardCustomers[LIMIT_BAND] = "<=50K" )
```
> **Expected value:** 0.3179 (31.79%)

---

### [Default Rate — PAY_0 = 2]
```dax
Default Rate PAY0 Eq 2 = 
CALCULATE( [Default Rate], CreditCardCustomers[PAY_0] = 2 )
```
> **Expected value:** 0.6914 (69.14%)

---

## Quick Reference — All Measures Summary

| Measure Name | Category | Expected Value |
|---|---|---|
| Total Customers | Portfolio | 30,000 |
| Defaulted Customers | Portfolio | 6,636 |
| Non-Default Customers | Portfolio | 23,364 |
| Default Rate | Portfolio | 22.12% |
| Total Credit Exposure | Portfolio | NT$5,024,529,680 |
| Average Credit Limit | Portfolio | NT$167,484 |
| Median Credit Limit | Portfolio | NT$140,000 |
| Average Utilization | Portfolio | 37.3% |
| Average 6M Total Bill | Portfolio | NT$269,862 |
| Average 6M Total Payment | Portfolio | NT$31,651 |
| Pct Always On-Time | Delinquency | 66.4% |
| Pct Any Delay | Delinquency | 33.6% |
| Pct Persistent Delinquent | Delinquency | 12.5% |
| Pct Recent Delinquent | Delinquency | 22.7% |
| Low Risk Customers | Segment | 13,874 (46.25%) |
| Medium Risk Customers | Segment | 10,808 (36.03%) |
| High Risk Customers | Segment | 5,318 (17.73%) |
| Default Rate Low Risk | Segment | 10.96% |
| Default Rate Medium Risk | Segment | 19.07% |
| Default Rate High Risk | Segment | 57.43% |
| High Risk Share of Defaults | Segment | 46.0% |
| Male Default Rate | Demographic | 24.17% |
| Female Default Rate | Demographic | 20.78% |
| Default Rate PAY0 = 2 | Behavior | 69.14% |

---

*All measures validated against Part 1 Python/pandas results from the actual 30,000-row dataset.*
