# Power BI Dashboard — Full Implementation Specification
## Credit Card Portfolio Risk & Delinquency Segmentation
**Author:** Kishan Kannaujiya  
**Tool:** Power BI Desktop (June 2024+ recommended)  
**Data Source:** `credit_card_enriched.csv` → Table: `CreditCardCustomers`

---

> **⚠️ .pbix File Notice:**  
> A valid `.pbix` binary file **cannot be programmatically generated** in this environment. Power BI Desktop `.pbix` files are proprietary binary/ZIP archives containing an embedded Analysis Services Tabular model, layout JSON, and metadata that can only be created and saved by Power BI Desktop itself. This document provides a **complete, implementation-ready specification** detailed enough to build the dashboard directly in Power BI Desktop. Every page, visual, field, measure, slicer, filter, interaction, drill-through, bookmark, and formatting rule is fully specified below.

---

## Table of Contents
1. [Data Import & Model Setup](#1-data-import--model-setup)
2. [Design System](#2-design-system)
3. [Page 1 — Executive Risk Overview](#3-page-1--executive-risk-overview)
4. [Page 2 — Risk Segmentation](#4-page-2--risk-segmentation)
5. [Page 3 — Repayment Behavior](#5-page-3--repayment-behavior)
6. [Page 4 — Customer Portfolio Deep Dive](#6-page-4--customer-portfolio-deep-dive)
7. [Page 5 — Business Insights](#7-page-5--business-insights)
8. [Interactivity Specification](#8-interactivity-specification)
9. [Navigation & Bookmarks](#9-navigation--bookmarks)
10. [Conditional Formatting Rules](#10-conditional-formatting-rules)

---

## 1. Data Import & Model Setup

### Step 1 — Import
- **Get Data → Text/CSV** → select `credit_card_enriched.csv`
- In Power Query Editor:
  - Rename table: `CreditCardCustomers`
  - Verify data types (all numeric columns → Whole Number or Decimal Number; label/text columns → Text; RISK_SEGMENT, LIMIT_BAND, UTIL_BAND, AGE_GROUP → Text)
  - Do **not** modify column values — data is pre-cleaned from Part 1
  - Click **Close & Apply**

### Step 2 — Create Measures Table
- In Report view: **Enter Data** → blank 1×1 table → rename to `Measures`
- Create all DAX measures from `dax_measures.md` inside this table

### Step 3 — Sorting Columns
Create the following **Sort By Column** assignments in Data view:

| Column | Sort By |
|---|---|
| RISK_SEGMENT | Create a helper column: `RISK_SORT` = IF(RISK_SEGMENT="Low Risk",1,IF(RISK_SEGMENT="Medium Risk",2,3)) |
| LIMIT_BAND | Create `LIMIT_BAND_SORT` = SWITCH(LIMIT_BAND,"<=50K",1,"50K-100K",2,"100K-200K",3,"200K-500K",4,">500K",5,6) |
| AGE_GROUP | Create `AGE_SORT` = SWITCH(AGE_GROUP,"20–29",1,"30–39",2,"40–49",3,"50–59",4,"60+",5,6) |
| UTIL_BAND | Create `UTIL_SORT` = SWITCH(UTIL_BAND,"<=0%",1,"0–25%",2,"25–50%",3,"50–75%",4,"75–100%",5,">100%",6,7) |

### Step 4 — Page Canvas Size
All pages: **Width 1280px × Height 720px** (16:9 widescreen)

---

## 2. Design System

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| `bg-primary` | `#F7F8FA` | Page canvas background |
| `bg-surface` | `#FFFFFF` | Visual/card backgrounds |
| `bg-dark` | `#1A2744` | Header bars, navigation strip |
| `accent-blue` | `#1F6FEB` | Primary accent, KPI highlights |
| `accent-blue-light` | `#D0E4FF` | Hover states, light fill |
| `risk-low` | `#22A05B` | Low Risk segment color |
| `risk-medium` | `#F5A623` | Medium Risk segment color |
| `risk-high` | `#D9232D` | High Risk segment color |
| `default-red` | `#D9232D` | Default / negative outcome |
| `nondefault-blue` | `#1F6FEB` | Non-default / positive outcome |
| `neutral-gray` | `#8C93A3` | Supporting text, borders |
| `border` | `#E5E7EB` | Card borders, dividers |
| `text-primary` | `#1A2033` | Headings, key values |
| `text-secondary` | `#57606A` | Descriptions, subtitles |
| `text-on-dark` | `#FFFFFF` | Text on dark backgrounds |

### Typography

| Role | Font | Size | Weight | Color |
|---|---|---|---|---|
| Page title | Segoe UI | 16pt | Bold | `#FFFFFF` (on dark header) |
| Section header | Segoe UI | 12pt | Semibold | `#1A2033` |
| KPI value | Segoe UI | 22pt | Bold | `#1A2033` or segment color |
| KPI label | Segoe UI | 9pt | Regular | `#57606A` |
| Axis labels | Segoe UI | 9pt | Regular | `#57606A` |
| Data labels | Segoe UI | 9pt | Semibold | varies |
| Body text (insights) | Segoe UI | 10pt | Regular | `#1A2033` |
| Tooltips | Segoe UI | 9pt | Regular | `#1A2033` |

### Visual Standards

| Property | Value |
|---|---|
| Card corner radius | 6px |
| Card border | 1px solid `#E5E7EB` |
| Card shadow | Subtle (Power BI visual shadow: on, offset 2) |
| Card padding | 12px internal |
| Visual spacing | 8px gap between visuals |
| Header bar height | 44px |
| Navigation strip | Left sidebar 56px wide OR top strip 40px high |
| Grid alignment | Use Power BI snap-to-grid with 8px grid |

### KPI Card Template
Each KPI card contains:
- **Top label** (9pt, `#57606A`, uppercase): e.g., "TOTAL CUSTOMERS"
- **Value** (22pt, bold, `#1A2033`): e.g., "30,000"
- **Sub-label or delta** (9pt, `#57606A`): e.g., "as at Sep 2005"
- Background: `#FFFFFF`, border: 1px `#E5E7EB`, corner: 6px

### Segment Colors (consistent across all pages)
- Low Risk: `#22A05B` (green)
- Medium Risk: `#F5A623` (amber)
- High Risk: `#D9232D` (red)
- These colors must be applied consistently in every visual that shows segment data.

---

## 3. Page 1 — Executive Risk Overview

### Page Purpose
Senior management overview of the portfolio's health, default concentration, and risk distribution. No deep interaction required — but all slicers remain active.

### Header Bar
- Background: `#1A2744` (dark navy)
- Height: 44px, full width
- Left content: **"Credit Card Portfolio Risk & Delinquency Segmentation"** (16pt, bold, white)
- Right content: Dynamic title measure: `"Default Rate: " & FORMAT([Default Rate], "0.00%")` (12pt, white)
- Separator: 2px line below header in `#2D3F6B`

### KPI Cards Row (6 cards, equal width, evenly spaced)
Position: y=60px, full width, card height ~90px

| Card # | Label | Measure | Format | Expected Value |
|---|---|---|---|---|
| 1 | TOTAL CUSTOMERS | `[Total Customers]` | `#,##0` | 30,000 |
| 2 | TOTAL CREDIT EXPOSURE | `[Total Credit Exposure]` | `NT$ #,##0,,` + "B" (billions) | NT$5.02B |
| 3 | DEFAULTED CUSTOMERS | `[Defaulted Customers]` | `#,##0` | 6,636 |
| 4 | DEFAULT RATE | `[Default Rate]` | `0.00%` | 22.12% |
| 5 | AVERAGE CREDIT LIMIT | `[Average Credit Limit]` | `NT$ #,##0` | NT$167,484 |
| 6 | AVERAGE UTILIZATION | `[Average Utilization]` | `0.0%` | 37.3% |

**Conditional formatting on card 4 (Default Rate):**  
- Background: `#FFF0F0` (light red) when `[Default Rate] > 0.25`  
- Value color: `#D9232D` always for Default Rate card

### Visual Row 1 (y=170px, full width, 2 visuals side-by-side)

**Visual 1A — Default vs Non-Default Donut Chart** (left half)
- Visual type: Donut chart
- Legend: DEFAULT_LABEL
- Values: `[Total Customers]`
- Colors: Non-Default = `#1F6FEB`, Default = `#D9232D`
- Title: "Portfolio Default Distribution"
- Data labels: on, show value and percentage
- Inner label: `[Default Rate %]` (use a blank measure as center label via DAX card trick or overlaid text box)
- No legend visible (use data labels instead)

**Visual 1B — Default Rate by Credit Limit Band** (right half)
- Visual type: Clustered bar chart (horizontal)
- Y-axis: LIMIT_BAND (sorted by LIMIT_BAND_SORT)
- X-axis: `[Default Rate]` (format 0.00%)
- Color: Conditional by value threshold (see Section 10)
- Data labels: on, right of bar
- Reference line: 22.12% (portfolio average, dotted, `#57606A`)
- Title: "Default Rate by Credit Limit Band"
- Expected bars: ≤50K=31.79%, 50K–100K=25.80%, 100K–200K=19.48%, 200K–500K=14.80%, >500K=11.17%

### Visual Row 2 (y=420px, full width, 3 visuals)

**Visual 2A — Risk Segment Treemap** (left third)
- Visual type: Treemap
- Group: RISK_SEGMENT
- Values: `[Total Customers]`
- Color: Low Risk=`#22A05B`, Medium Risk=`#F5A623`, High Risk=`#D9232D`
- Data labels: segment name + count + %
- Title: "Portfolio by Risk Segment"

**Visual 2B — Default Rate by Risk Segment (column chart)** (center third)
- Visual type: Clustered column chart
- X-axis: RISK_SEGMENT (sorted)
- Y-axis: `[Default Rate]` (format 0.0%)
- Colors: Low=`#22A05B`, Medium=`#F5A623`, High=`#D9232D`
- Data labels: on
- Reference line: 22.12% avg
- Title: "Default Rate by Risk Segment"
- Expected: Low=10.96%, Medium=19.07%, High=57.43%

**Visual 2C — Credit Exposure Waterfall / Stacked Bar** (right third)
- Visual type: Stacked bar chart (100%)
- Axis: "Portfolio Exposure"
- Series: RISK_SEGMENT
- Values: `[Total Credit Exposure]`
- Colors: Low=`#22A05B`, Medium=`#F5A623`, High=`#D9232D`
- Data labels: NT$xB (billions) and %
- Title: "Credit Exposure by Risk Segment"
- Expected: Low=NT$2.95B (58.8%), Medium=NT$1.56B (31.1%), High=NT$0.51B (10.2%)

### Slicer Panel (right sidebar or top strip)
All pages share a collapsible slicer panel. Page 1 slicers:

| Slicer | Field | Style |
|---|---|---|
| Gender | SEX_LABEL | Dropdown |
| Education | EDUCATION_LABEL | Dropdown |
| Marital Status | MARRIAGE_LABEL | Dropdown |
| Age Group | AGE_GROUP | List (sorted) |
| Credit Limit Band | LIMIT_BAND | List (sorted) |
| Risk Segment | RISK_SEGMENT | Tile / Button |

**Slicer formatting:**
- Background: `#FFFFFF`, border: 1px `#E5E7EB`
- Selected tile: background `#1A2744`, text `#FFFFFF`
- Unselected tile: background `#F7F8FA`, text `#1A2033`
- Include a "Reset Filters" button (bookmark action — see Section 9)

### Page Footer
- Text box at bottom: "Source: UCI Default of Credit Card Clients Dataset | 30,000 records | April–September 2005 | NT$ = New Taiwan Dollar"
- Font: 8pt, `#8C93A3`

---

## 4. Page 2 — Risk Segmentation

### Page Purpose
Detailed analysis of the three risk segments — customer profiles, default rates, exposure, and behavioral characteristics. Primary audience: Credit Risk and Portfolio Management teams.

### Header Bar
Same styling as Page 1. Title: "Risk Segmentation Analysis"  
Dynamic subtitle: `[Selected Filters Label]` measure

### Segment Selector (Tile Slicer — prominent, full width row)
- Field: RISK_SEGMENT
- Style: Button/Tile, full width
- Colors when selected: Low=`#22A05B`, Medium=`#F5A623`, High=`#D9232D`
- When a segment is selected, ALL visuals on this page cross-filter

### KPI Cards Row (5 cards, below segment slicer)
| Label | Measure | Notes |
|---|---|---|
| CUSTOMERS IN SEGMENT | `[Total Customers]` | Changes with slicer selection |
| DEFAULT RATE | `[Default Rate]` | `[Default Rate Card Label]` with arrow |
| VS PORTFOLIO AVG | `[Segment Default Rate vs Portfolio]` | Show as +/-pp, red if positive |
| TOTAL EXPOSURE | `[Total Credit Exposure]` | NT$ billions |
| AVG CREDIT LIMIT | `[Average Credit Limit]` | NT$ |

### Visual Row 1 (3 visuals)

**Visual A — Segment Comparison Matrix (Table)**
- Visual type: Matrix / Table
- Rows: RISK_SEGMENT
- Columns: Customers, % Portfolio, Defaults, Default Rate, Total Exposure (B), Avg Limit, Avg Utilization, Avg Months Delayed, Avg Pay Coverage
- Conditional formatting on Default Rate column: gradient green (low) → red (high)
- Row highlighting: when a row is selected, linked visuals filter
- Sort: by RISK_SORT ascending

| Segment | Customers | % Portfolio | Default Rate | Exposure (B) | Avg Limit | Avg Util | Avg Months Del | Avg Pay Cov |
|---|---|---|---|---|---|---|---|---|
| Low Risk | 13,874 | 46.25% | 10.96% | NT$2.953 | NT$212,811 | 15.1% | 0.0 | 70.9% |
| Medium Risk | 10,808 | 36.03% | 19.07% | NT$1.560 | NT$144,321 | 51.9% | 0.6 | 40.3% |
| High Risk | 5,318 | 17.73% | 57.43% | NT$0.512 | NT$96,309 | 65.5% | 3.5 | 8.3% |

**Visual B — Default Concentration Dumbbell / Dot Plot**
- Visual type: Clustered bar (2 series overlaid as grouped bars)
- X-axis: RISK_SEGMENT
- Series 1: % of portfolio (bar, `#1F6FEB`, lighter shade)
- Series 2: % of all defaults (bar, `#D9232D`)
- Title: "Portfolio Share vs Default Share by Segment"
- Key insight annotation: "High Risk = 17.7% customers → 46.0% of defaults"
- (Implement as a clustered bar with 2 measures: customers% vs defaults%)

**Visual C — Risk Score Distribution Histogram**
- Visual type: Column chart (histogram-style)
- X-axis: RISK_SCORE (0–13)
- Y-axis: Count of customers
- Color: Conditional by RISK_SEGMENT
  - Score 0–2: `#22A05B`, Score 3–6: `#F5A623`, Score 7–13: `#D9232D`
- Title: "Risk Score Distribution"
- Data labels: off (too many bars)
- Tooltip: show score, count, default rate

### Visual Row 2 (3 visuals)

**Visual D — Avg Utilization by Segment (gauge or column)**
- Visual type: Clustered column
- X: RISK_SEGMENT | Y: `[Average Utilization]`
- Colors: segment colors
- Reference line: portfolio avg 37.3%
- Expected: Low=15.1%, Medium=51.9%, High=65.5%

**Visual E — Avg Payment Coverage by Segment**
- Visual type: Clustered column
- X: RISK_SEGMENT | Y: `[Average Payment Coverage]`
- Colors: REVERSED (High coverage = good = green)
  - Low Risk high coverage → green; High Risk low coverage → red
- Expected: Low=70.9%, Medium=40.3%, High=8.3%
- Reference line: 50% threshold

**Visual F — Credit Exposure Donut by Segment**
- Visual type: Donut
- Legend: RISK_SEGMENT
- Values: SUM(LIMIT_BAL)
- Colors: segment colors
- Data labels: NT$xB and %
- Title: "Credit Exposure Distribution"

### Drill-through Setup
- Configure RISK_SEGMENT as a drill-through field (see Section 8)
- Right-clicking a segment in any visual → "See customer details" → navigates to Page 4 filtered to that segment

---

## 5. Page 3 — Repayment Behavior

### Page Purpose
Deep analysis of PAY_0–PAY_6 patterns, delinquency indicators, and their relationship to default. Primary audience: Collections and Credit Risk teams.

### Header Bar
Title: "Repayment Behavior Analysis"

### KPI Cards Row (4 cards)
| Label | Measure | Expected |
|---|---|---|
| % ALWAYS ON-TIME | `[Pct Always On-Time]` | 66.4% |
| % ANY DELAY (6M) | `[Pct Any Delay]` | 33.6% |
| % PERSISTENT DELINQUENT | `[Pct Persistent Delinquent]` | 12.5% |
| % RECENT DELINQUENT | `[Pct Recent Delinquent]` | 22.7% |

Card 1 value: green `#22A05B`  
Cards 2–4 values: amber/red conditional on threshold

### Visual Row 1 (2 visuals)

**Visual A — Default Rate by PAY_0 Status (Column Chart)**
- Visual type: Clustered column
- X-axis: PAY_0 (-2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8)
- Y-axis: `[Default Rate]` (format 0.0%)
- Color coding:
  - PAY_0 ≤ 0: `#1F6FEB` (low risk)
  - PAY_0 = 1: `#F5A623` (amber)
  - PAY_0 ≥ 2: `#D9232D` (red)
- Reference line: 22.12% dashed
- Data labels: on
- Title: "Default Rate by Repayment Status (Sep 2005)"
- Key annotation box: "PAY_0 = 2 → 69.1% default rate"
- Expected values: -2=13.2%, -1=16.8%, 0=12.8%, 1=33.9%, 2=69.1%, 3=75.8%, 7=83.6%

**Visual B — PAY_0 Status Distribution (Stacked Bar)**
- Visual type: Clustered bar (horizontal)
- Y-axis: PAY_0 values
- X-axis: Count of customers + Default rate as secondary measure
- Two measures: customer count (bar) + default rate (line on secondary axis)
- This is a combo chart
- Title: "Customer Count & Default Rate by PAY_0"

### Visual Row 2 — Repayment Status Heatmap

**Visual C — PAY Status Heatmap across 6 months**
- Visual type: Matrix
- Rows: RISK_SEGMENT
- Columns: PAY_0, PAY_2, PAY_3, PAY_4, PAY_5, PAY_6 (average values)
- Values: `AVERAGEX(...)` per PAY column
- Conditional formatting: color gradient
  - ≤ -1: `#D0E4FF` (blue, good)
  - = 0: `#FFFFFF` (white, neutral)
  - 1–2: `#FFE0C0` (amber)
  - ≥ 3: `#FFD0D0` (red, bad)
- Title: "Average Repayment Status Heatmap by Risk Segment & Month"
- Column headers renamed: "Sep-05", "Aug-05", "Jul-05", "Jun-05", "May-05", "Apr-05"

### Visual Row 3 (3 visuals)

**Visual D — MONTHS_DELAYED Distribution**
- Visual type: Column chart
- X: MONTHS_DELAYED (0–6)
- Y: `[Total Customers]`
- Color: Gradient low-to-high (0=green, 6=red)
- Secondary axis: `[Default Rate]` line
- Title: "Months Delayed Distribution & Default Rate"
- Expected: 0 months=19,931 cust/11.7%, 6 months=1,341 cust/70.3%

**Visual E — Default Rate by MAX_PAY_DELAY**
- Visual type: Clustered column (step chart style)
- X: MAX_PAY_DELAY (-2 to 8)
- Y: `[Default Rate]`
- Color: conditional
- Title: "Default Rate by Maximum Payment Delay"
- Key point annotation: max delay 7 months → 83.6%

**Visual F — Persistent vs Recent Delinquency Scatter**
- Visual type: Scatter chart
- X-axis: MONTHS_DELAYED (0–6)
- Y-axis: `[Default Rate]`
- Size: `[Total Customers]`
- Color: RISK_SEGMENT colors
- Play axis: (not applicable — static)
- Title: "Default Rate vs Months Delayed (bubble size = customers)"

### Slicers (Page 3)
- Risk Segment (tile slicer, top)
- Gender (dropdown)
- Education (dropdown)
- Age Group (list)
- Cross-filter: selecting a bar in Visual A filters all other visuals on the page

---

## 6. Page 4 — Customer Portfolio Deep Dive

### Page Purpose
Drill-through / analytical detail page. Accessed from other pages by right-click → drill-through. Also browsable directly. Audience: Collections and Relationship Management teams.

### Header Bar
Title: "Customer Portfolio Deep Dive"  
Dynamic subtitle: `"Filtered to: " & [Selected Filters Label]`

### Drill-through Configuration
- Drill-through field: RISK_SEGMENT
- When drilled through from Page 2 or Page 3, the page retains the segment filter
- Include a **Back button** (arrow icon, top-left, Power BI built-in back navigation)

### KPI Row (5 cards, filtered to drilled-through context)
| Label | Measure |
|---|---|
| CUSTOMERS (IN VIEW) | `[Total Customers]` |
| DEFAULT RATE | `[Default Rate]` with arrow label |
| AVG CREDIT LIMIT | `[Average Credit Limit]` |
| AVG UTILIZATION | `[Average Utilization]` |
| AVG MONTHS DELAYED | `[Average Months Delayed]` |

### Main Visual — Customer Detail Table

Visual type: Table (not matrix)  
Fields (left to right):

| Column | Field | Format |
|---|---|---|
| Customer ID | ID | Plain integer |
| Credit Limit | LIMIT_BAL | `NT$ #,##0` |
| Credit Band | LIMIT_BAND | Text |
| Risk Score | RISK_SCORE | Integer, conditional color (0–2 green, 3–6 amber, 7–13 red) |
| Risk Segment | RISK_SEGMENT | Text with segment color background |
| Utilization | UTILIZATION | `0.0%`, conditional color |
| Months Delayed | MONTHS_DELAYED | Integer, conditional color |
| Max Delay | MAX_PAY_DELAY | Integer |
| Persistent Delq | PERSISTENT_DELINQUENT | ✓/✗ icon (1=red ✗, 0=green ✓) |
| Recent Delq | RECENT_DELINQUENT | ✓/✗ icon |
| Pay Coverage | PAY_COVERAGE | `0.0%`, conditional color (low=red) |
| Avg Bill (NT$) | AVG_BILL_AMT | `#,##0` |
| Avg Payment (NT$) | AVG_PAY_AMT | `#,##0` |
| Defaulted | DEFAULT_LABEL | Text, color: Default=red, Non-Default=blue |

Table settings:
- Row alternating color: `#FFFFFF` / `#F7F8FA`
- Word wrap: off
- Row height: 24px
- Total rows shown: 50 per page (use pagination)
- Sort default: RISK_SCORE descending

### Secondary Visuals (right panel)

**Visual A — Risk Score Histogram (filtered context)**
- Column chart: RISK_SCORE distribution for selected segment

**Visual B — Utilization vs Pay Coverage Scatter**
- X: UTILIZATION | Y: PAY_COVERAGE
- Size: LIMIT_BAL (normalized)
- Color: DEFAULT (red/blue)
- Title: "Utilization vs Payment Coverage"
- Add quadrant lines at 0.50 for both axes

### Slicers (Page 4)
- Risk Segment (tile, single select)
- Default Status (tile: "Default" / "Non-Default")
- Months Delayed (range slider: 0–6)
- Utilization Band (list)

---

## 7. Page 5 — Business Insights

### Page Purpose
Decision-support page. Static analytical content (text boxes + supporting visuals) for senior management and business stakeholders. Not primarily interactive — but slicers remain functional.

### Header Bar
Title: "Business Insights & Recommendations"  
Color: `#1A2744`

### Layout — Two-Column Format

**Left column (55% width) — Insights text boxes**

Each insight block:
- Background: `#FFFFFF`, border-left: 4px solid (color by severity), corner: 6px, padding: 12px

---

**INSIGHT 1 — Portfolio Default Rate** (border color: `#D9232D`)  
> The portfolio carries a **22.12% overall default rate** across 30,000 customers, with total credit exposure of **NT$5.02 billion**. This represents a materially elevated default level relative to typical mature credit-card portfolios, indicating significant risk concentration that warrants active monitoring.

---

**INSIGHT 2 — Risk Concentration** (border color: `#D9232D`)  
> **High Risk customers (17.7% of the portfolio) account for 46.0% of all defaults** while holding only 10.2% of total credit exposure. This concentration means that a focused intervention strategy targeting this segment could have an outsized impact on portfolio default outcomes.

---

**INSIGHT 3 — Repayment Behavior as the Dominant Signal** (border color: `#F5A623`)  
> The number of delayed months (MONTHS_DELAYED, r = +0.398) is the single strongest behavioral indicator of default in this dataset, ahead of credit limit, utilization, and demographics. Customers with **PAY_0 = 2 (one billing cycle behind)** show a **69.1% default rate** — more than three times the portfolio average.

---

**INSIGHT 4 — Early-Warning Threshold: PAY_0 ≥ 2** (border color: `#F5A623`)  
> When a customer's most-recent repayment status reaches code 2 or above, the observed default probability exceeds 69%. An automated monitoring rule triggering at this threshold could enable collections contact before the situation deteriorates to formal default.

---

**INSIGHT 5 — Credit Limit Inverse Relationship** (border color: `#22A05B`)  
> Defaulters have a median credit limit of **NT$90,000** vs **NT$150,000** for non-defaulters (Mann-Whitney U, p<0.0001, r = -0.154). The ≤NT$50K limit band carries a **31.79% default rate** vs 11.17% for the >NT$500K band — suggesting credit limits set at origination partially reflect underlying risk.

---

**INSIGHT 6 — Utilization and Payment Coverage** (border color: `#F5A623`)  
> Customers in the High Risk segment carry average utilization of **65.5%** and average payment coverage of only **8.3%** — compared to 15.1% utilization and 70.9% coverage in the Low Risk segment. Customers with utilization above 75% show default rates of 30.7–34.2%.

---

**INSIGHT 7 — Demographics: Behavioral Signals Dominate** (border color: `#22A05B`)  
> While all demographic variables (sex, education, marriage) show statistically significant associations with default (chi-square, all p<0.0001), their effect sizes are small. Repayment behavior metrics explain far more variance and should be the primary input to any monitoring or segmentation decision.

---

**INSIGHT 8 — Older Customers: Small Segment, Elevated Rate** (border color: `#F5A623`)  
> Customers aged 60+ show a 28.3% observed default rate — but represent only 1.1% of the portfolio. Customers aged 50–59 show 24.9%. While these rates are elevated above the portfolio average, the small segment size limits portfolio-level impact.

---

**Right column (45% width) — Supporting visuals**

**Visual A — Top Risk Patterns Summary (horizontal bar)**
- X: Default rate | Y: Behavior pattern (from Query 12 in SQL)
- Patterns: Persistent+Severe Delay, Severe single episode, Moderate Repeated, Recent Only, On-time High Utilization, Consistently On-time
- Color: conditional by default rate
- Title: "Default Rate by Behavioral Pattern"

**Visual B — Segment Concentration Double Bar**
- X: Risk Segment | Y: Two series — % Portfolio, % Defaults
- Colors: `#1F6FEB` for portfolio share, `#D9232D` for default share
- Title: "Customer Share vs Default Share"
- Expected: High Risk 17.7% portfolio share → 46.0% default share

**Visual C — Key Metrics Comparison Table (Matrix)**
Rows: Risk Segment | Columns: Default Rate, Avg Limit, Avg Util, Avg Coverage  
Conditional formatting on all numeric columns.

### Footnote / Disclaimer (bottom of page)
Text box (8pt, `#8C93A3`):
> "All recommendations are based solely on statistical patterns observed in this dataset. Statistical associations do not imply causation. Any operational implementation must be validated against current regulatory requirements, the institution's credit policies, and applicable fair-lending standards."

---

## 8. Interactivity Specification

### 8.1 Slicer Interactions

| Slicer | Affects | Type |
|---|---|---|
| RISK_SEGMENT | All visuals on all pages | Cross-filter |
| SEX_LABEL | All visuals on current page | Cross-filter |
| EDUCATION_LABEL | All visuals on current page | Cross-filter |
| MARRIAGE_LABEL | All visuals on current page | Cross-filter |
| AGE_GROUP | All visuals on current page | Cross-filter |
| LIMIT_BAND | All visuals on current page | Cross-filter |
| DEFAULT Status (Page 4) | Table and scatter only | Cross-filter |
| MONTHS_DELAYED range (Page 4) | Table only | Filter |

**Sync slicers across pages:**  
RISK_SEGMENT slicer should be synced across Pages 1, 2, 3, 4 using Power BI's **View → Sync Slicers** pane.  
SEX, EDUCATION, MARRIAGE slicers: sync across Pages 1, 2, 3.

### 8.2 Cross-Filtering

All visuals on a page have **cross-filtering enabled by default**.  
Exception: The insight text boxes on Page 5 are static text — they cannot be filtered.

In Power BI:
- Select a visual → **Format → Edit interactions** (pencil icon)
- Set cross-filter (funnel icon) ON for all visuals that should respond
- Set cross-filter OFF for static text boxes and footnotes

When a user clicks:
- A bar in the "Default Rate by Credit Limit Band" chart → all other visuals on the page filter to that credit limit band
- A segment in the treemap → all page visuals filter to that segment
- A cell in the repayment heatmap → filters to that segment × month combination

### 8.3 Cross-Highlighting

Use cross-highlighting (not cross-filtering) for:
- The donut chart (Page 1) when a bar chart bar is clicked — the relevant slice highlights but all slices remain visible
- The scatter chart (Page 3) when a segment is selected in the tile slicer

To enable: **Format → Edit interactions → Highlight** (bar chart icon, not funnel icon)

### 8.4 Drill-Through

**From any page → Page 4 (Customer Portfolio Deep Dive):**
- Configure in Page 4: **Visualizations pane → Add drill-through fields** → add RISK_SEGMENT
- On Page 1, 2, 3: right-click any visual that contains RISK_SEGMENT in its data → "Drill through → Customer Portfolio Deep Dive"
- Page 4 automatically retains the selected segment as a filter context
- **Back button:** Insert → Buttons → Back (top-left of Page 4, styled with `#1A2744` border)

**Drill-through preserves:**
- RISK_SEGMENT filter
- Any page-level slicer values that were active at the time of drill-through (Power BI default behavior)

### 8.5 Tooltips

**Default tooltip contents for all visuals:**
- Customer count
- Default rate (formatted as %)
- Average credit limit
- Average utilization
- Segment (if applicable)

**Custom tooltip page (optional — advanced):**
Create a hidden page (Page size: Tooltip, 320×200px) with:
- Mini KPI cards: Count, Default Rate, Avg Limit
- Small bar: top 3 repayment statuses
- Set this as a report-page tooltip for the main visuals on Pages 1 and 2

### 8.6 Dynamic Titles

Each visual title should use the format:  
`"[Visual Subject] — " & [Selected Filters Label]`

For KPI card titles, use the `Dashboard Title Default Rate` measure or similar.

Implementation:
- Click visual title → fx (conditional formatting) icon → select "Field value" → select the dynamic title measure

Examples:
- Page 1 donut: "Portfolio Default Distribution — All Segments" → changes to "Portfolio Default Distribution — High Risk" when High Risk is selected

### 8.7 Bookmark Navigation

**Create the following bookmarks** (View → Bookmarks pane):

| Bookmark Name | State Captured | Button Label |
|---|---|---|
| `BM_AllClear` | All slicers reset to default (all selected) | "Reset Filters" |
| `BM_HighRisk` | RISK_SEGMENT = "High Risk" on all pages | "High Risk View" |
| `BM_MedRisk` | RISK_SEGMENT = "Medium Risk" | "Medium Risk View" |
| `BM_LowRisk` | RISK_SEGMENT = "Low Risk" | "Low Risk View" |
| `BM_DefaultOnly` | DEFAULT = 1 | "Defaulters Only" |

**To create a bookmark:**
1. Set slicers to desired state
2. View → Bookmarks → Add
3. Rename the bookmark
4. Insert → Buttons → Blank → assign bookmark action

**Reset Filters button:**
- Present on every page, top-right corner
- Style: small rectangle, `#F7F8FA` background, `#1A2744` border, text "⟳ Reset Filters" (10pt)
- Action: bookmark `BM_AllClear`

### 8.8 Page Navigation

**Navigation strip (left sidebar, 56px wide, all pages):**
Background: `#1A2744`

Navigation buttons (vertical, icon + label):

| Button | Target Page | Icon (emoji/symbol) |
|---|---|---|
| Executive Overview | Page 1 | 🏛 |
| Risk Segments | Page 2 | 📊 |
| Repayment | Page 3 | 📅 |
| Customer Deep Dive | Page 4 | 🔍 |
| Insights | Page 5 | 💡 |

Button styling:
- Default: `#1A2744` bg, `#8C93A3` text
- Hover/active: `#2D3F6B` bg, `#FFFFFF` text, left border 3px `#1F6FEB`
- Implementation: use Power BI Buttons with page navigation action + conditional formatting for active state

**Alternative — Top navigation strip (40px, full width):**
Horizontal button row below the header. Same styling, horizontal layout. Easier to implement in Power BI; recommended if vertical sidebar requires complex layout.

---

## 9. Navigation & Bookmarks

### Complete Bookmark List

| ID | Name | Page | Slicer State | Purpose |
|---|---|---|---|---|
| BM01 | `BM_AllClear` | All | All slicers cleared | Global reset |
| BM02 | `BM_HighRisk` | P1, P2 | RISK_SEGMENT = High Risk | Quick segment view |
| BM03 | `BM_MedRisk` | P1, P2 | RISK_SEGMENT = Medium Risk | Quick segment view |
| BM04 | `BM_LowRisk` | P1, P2 | RISK_SEGMENT = Low Risk | Quick segment view |
| BM05 | `BM_DefaultOnly` | P3, P4 | DEFAULT = 1 | Defaulters only |
| BM06 | `BM_PersistDelq` | P3 | PERSISTENT_DELINQUENT = 1 | Persistent delinquency view |
| BM07 | `BM_RecentDelq` | P3 | RECENT_DELINQUENT = 1 | Recent delinquency view |

### Bookmark Capture Settings
When creating bookmarks, capture:
- ✅ Data (current filter/slicer state)
- ✅ Display (visible/hidden state of visuals)
- ❌ Current page (do NOT check — use page navigation separately)

### Reset Filters Button Implementation
1. Insert → Buttons → Blank → Position: top-right, 80×24px
2. Format → Style → Text: "⟳ Reset" | Font 9pt | Color `#1A2744`
3. Action → Type: Bookmark → Bookmark: `BM_AllClear`
4. Available on all 5 pages

---

## 10. Conditional Formatting Rules

### Default Rate Color Scale (for matrices and tables)
Applied to any measure or column showing default rate:

| Value | Color | Background |
|---|---|---|
| 0–15% | `#22A05B` (green) | `#F0FFF4` |
| 15–22% | `#F5A623` (amber) | `#FFF8E1` |
| 22–35% | `#E65100` (dark orange) | `#FFF3E0` |
| >35% | `#D9232D` (red) | `#FFF0F0` |

Implementation: Format visual → Conditional formatting → Background color → Rules-based, using [Default Rate Color Value] measure (0–3 integer).

### Utilization Color Scale
| Value | Color |
|---|---|
| 0–50% | `#22A05B` |
| 50–75% | `#F5A623` |
| >75% | `#D9232D` |

### Risk Score Color Scale (for table column)
| Value | Color |
|---|---|
| 0–2 | `#22A05B` |
| 3–6 | `#F5A623` |
| 7–13 | `#D9232D` |

Implementation: Rules-based on the `RISK_SCORE` column directly.

### PERSISTENT_DELINQUENT & RECENT_DELINQUENT Icons
In the customer table (Page 4):
- Value 1 → Show "⚠" icon in red `#D9232D`
- Value 0 → Show "✓" icon in green `#22A05B`
- Implementation: Create a DAX column or use conditional icon formatting

### PAY Coverage — Reversed Scale (higher = better)
| Value | Color |
|---|---|
| ≥ 50% | `#22A05B` |
| 20–50% | `#F5A623` |
| < 20% | `#D9232D` |

---

## Appendix A — Data Columns Available in Power BI

All columns below are available after importing `credit_card_enriched.csv`:

**Original columns:**  
`ID`, `LIMIT_BAL`, `SEX`, `EDUCATION`, `MARRIAGE`, `AGE`, `PAY_0`, `PAY_2`, `PAY_3`, `PAY_4`, `PAY_5`, `PAY_6`, `BILL_AMT1`–`BILL_AMT6`, `PAY_AMT1`–`PAY_AMT6`, `DEFAULT`

**Label columns (text):**  
`SEX_LABEL`, `EDUCATION_LABEL`, `MARRIAGE_LABEL`, `DEFAULT_LABEL`

**Engineered columns:**  
`AVG_BILL_AMT`, `MAX_BILL_AMT`, `TOTAL_BILL_6M`, `TOTAL_PAY_6M`, `AVG_PAY_AMT`, `PAY_TO_BILL_RATIO`, `UTILIZATION`, `AVG_PAY_STATUS`, `MAX_PAY_DELAY`, `MONTHS_DELAYED`, `MONTHS_SEVERE_DELAY`, `PERSISTENT_DELINQUENT`, `RECENT_DELINQUENT`, `ALWAYS_ON_TIME`, `BILL_VOLATILITY`, `PAY_COVERAGE`, `RISK_SCORE`, `RISK_SEGMENT`

**Banding columns:**  
`LIMIT_BAND`, `UTIL_BAND`, `AGE_GROUP`

---

## Appendix B — Visual Type Mapping Summary

| Page | Visual | Type | Primary Field |
|---|---|---|---|
| P1 | Default Distribution | Donut | DEFAULT_LABEL |
| P1 | Default Rate by Limit Band | Bar | LIMIT_BAND |
| P1 | Risk Segment Treemap | Treemap | RISK_SEGMENT |
| P1 | Default Rate by Segment | Column | RISK_SEGMENT |
| P1 | Exposure by Segment | Stacked Bar 100% | RISK_SEGMENT |
| P2 | Segment Matrix | Matrix | RISK_SEGMENT |
| P2 | Concentration Double Bar | Clustered Bar | RISK_SEGMENT |
| P2 | Risk Score Histogram | Column | RISK_SCORE |
| P2 | Utilization by Segment | Column | RISK_SEGMENT |
| P2 | Pay Coverage by Segment | Column | RISK_SEGMENT |
| P2 | Exposure Donut | Donut | RISK_SEGMENT |
| P3 | Default Rate by PAY_0 | Column | PAY_0 |
| P3 | PAY_0 Count + Rate | Combo | PAY_0 |
| P3 | Repayment Heatmap | Matrix | RISK_SEGMENT × months |
| P3 | Months Delayed + Rate | Combo | MONTHS_DELAYED |
| P3 | Default Rate by Max Delay | Column | MAX_PAY_DELAY |
| P3 | Delinquency Scatter | Scatter | MONTHS_DELAYED |
| P4 | Customer Detail | Table | All relevant columns |
| P4 | Risk Score Histogram | Column | RISK_SCORE |
| P4 | Util vs Pay Coverage | Scatter | UTILIZATION, PAY_COVERAGE |
| P5 | Behavioral Patterns Bar | Bar | pattern / default rate |
| P5 | Concentration Double Bar | Clustered Bar | RISK_SEGMENT |
| P5 | Key Metrics Matrix | Matrix | RISK_SEGMENT |

---

*This specification is sufficient to build the dashboard entirely in Power BI Desktop. All KPI values, segment definitions, and default rates reference the actual Part 1 computed results from the 30,000-row dataset.*
