Financial Performance Analysis

An end-to-end data analytics capstone project covering the full analytics stack — Python ETL, SQL Server analysis, and Tableau dashboard design — built to answer real executive-level financial performance questions.

Project Overview

<img width="1280" height="720" alt="Project Overview" src="https://github.com/user-attachments/assets/42b04e23-b2f1-4069-a39e-57f61625c419" />


This project simulates a real-world financial analytics workflow for a multi-business-unit organization, spanning 2022–2023. It moves through three stages: ingesting and cleaning raw transactional data, performing structured SQL analysis, and presenting findings through three interconnected executive dashboards.

Datasets used:

TableRowsDescriptionFinancial_Transactions10,400Revenue and expense transactionsCustomers400Customer master dataEmployees200Employee and cost dataVendors120Vendor master dataBudget72Monthly budget targets by business unit


Tech Stack


Python — pandas, SQLAlchemy, logging
SQL Server — T-SQL, window functions, CTEs, LOD-style aggregation
Tableau Desktop — dashboard design, LOD expressions, parameters, dual-axis charts



1. Python ETL Pipeline

A function-based staged pipeline that ingests, cleans, and loads all five datasets into SQL Server.

ingest() → clean_budget() → clean_customers() → clean_transactions()
→ clean_employees() → clean_vendors() → create_db_engine() → upload_to_sql()
→ run_pipeline()

Key features:


Automatic CSV discovery via glob
Per-table cleaning: date parsing, derived columns (e.g. amount_abs), type enforcement
Smart upload logic — creates tables if missing, appends only new rows on rerun (duplicate detection via merge + _merge == left_only)
Full staged logging (console + file, INFO/DEBUG split) for pipeline observability
DTYPE_MAPS and UNIQUE_KEYS config dictionaries per table for maintainable upload logic



2. SQL Analysis — 45 Queries Across 10 Sections

SectionFocus1. Data IntegrityPK/FK validation, null checks, allowed-value checks2. KPI CalculationsRevenue, expense, margin, budget utilization, per-segment breakdowns3. Budget VarianceMonthly/annual variance, over-budget drilldowns, cost-spike detection (LAG)4. Performance ScoringBusiness unit scorecards, consecutive underperformance flags5. EDA & StatisticsMean/median/IQR via PERCENTILE_CONT, distribution buckets6. Anomaly DetectionIQR & Z-score outliers, duplicate transactions, FK/sign mismatches7. Time TrendsYoY and MoM growth analysis8. Customer AnalysisCohort revenue, concentration risk, segment ranking (RANK() OVER)9. Vendor AnalysisSpend by category/region, concentration risk, active vs inactive split10. Headcount & ProductivityRevenue per employee, workforce cost ratios, tenure-based pay analysis

Notable technical solve: DISTINCT cannot be combined with OVER() in SQL Server — resolved by splitting GROUP BY aggregates and PERCENTILE_CONT windows into separate CTEs and joining them.


3. Tableau Dashboard Suite

Three interconnected dashboards (1400×900px), built on a Microsoft SQL Server live connection with Windows Authentication.

Dashboard 1 — Executive Overview

High-level profitability and growth tracking: revenue/expense/profit KPIs, monthly trend analysis, business unit performance, regional revenue split, and YoY growth vs budget.

Dashboard 2 — Budget & Operations

Operational health monitoring: budget variance heatmap (month × business unit), cost-spike timeline with automated anomaly markers, and a productivity quadrant scatter plot (cost vs revenue per employee).

Dashboard 3 — Customer & Vendor

Concentration risk analysis: top 10 customers, revenue by segment, customer cohort analysis, vendor spend treemap, and dual Pareto charts (customer and vendor concentration) with a parameter-driven 80% threshold line.

Design system:

ElementColorRevenue / Profit#2E7D32Expense / Cost#C62828Primary Accent#1A3C5ENeutral Metric#1565C0Budget Target#F57F17Background#F5F5F5

Notable technical solves:


Resolved a join-multiplication bug on the Budget table using FIXED LOD expressions ({ FIXED [business_unit], YEAR(...), MONTH(...) : MIN([budgeted_revenue]) })
Built dynamic Pareto charts with a Tableau Parameter controlling the concentration threshold line in real time
Designed custom diverging color scales for the budget variance heatmap


## Screenshots

### Dashboard 1 — Executive Overview
<img width="1600" height="900" alt="Financial Dashboard 1" src="https://github.com/user-attachments/assets/e6e47510-bbcf-40c9-8bb6-55f7534dd2d9" />

### Dashboard 2 — Budget & Operations
<img width="1600" height="900" alt="Financial Dashboard 2" src="https://github.com/user-attachments/assets/fcffa460-94c5-4d6e-845f-be3e99e453fc" />

### Dashboard 3 — Customer & Vendor
<img width="1600" height="900" alt="Financial Dashboard 3" src="https://github.com/user-attachments/assets/729d16cd-5205-45b4-83d1-6bb778483db0" />


Repository Structure

financial-performance-analysis/
├── README.md
├── etl/
│   └── financial_performance_pipeline.py
├── sql/
│   └── Financial_Performance_Analysis_Clean.sql
├── tableau/
│   └── Financial_Performance_Analysis.twbx
├── logs/
│   └── Financial_Performance_Analysis_pipeline.txt
└── screenshots/


Key Learnings


LOD expression order of operations in Tableau (FIXED runs before joins/filters in some contexts) and how this affects aggregation accuracy
Why DISTINCT cannot be paired with OVER() in SQL Server, and the CTE-split workaround
Designing dashboards around a single clear story per chart rather than maximizing chart count
Building reusable, parameter-driven visual analytics (dynamic thresholds) instead of static cutoffs



Author

Built as part of a Data Analytics certification capstone (Career 247 program).
