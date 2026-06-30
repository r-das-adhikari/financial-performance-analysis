USE FinancialPerformance_DB
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

SELECT TOP 10 * FROM Budget;
GO
SELECT TOP 10 * FROM Customers;
GO
SELECT TOP 10 * FROM Financial_Transactions;
GO
SELECT TOP 10 * FROM Employees;
GO
SELECT TOP 10 * FROM Vendors;
GO

-- ================================================================================================
-- STEP 1: DATA INTEGRITY CHECKS
-- ================================================================================================

-- ------------------------------------------------------------------------------------------------
-- 1.1 PK UNIQUENESS CHECKS
-- ------------------------------------------------------------------------------------------------

-- Budget
SELECT
      year,
      month,
      business_unit,
      COUNT(*) AS duplicate_count
FROM Budget
GROUP BY year, month, business_unit
HAVING COUNT(*) > 1
GO

-- Customers
SELECT
       customer_id,
       COUNT(*) AS duplicate_count
FROM Customers
GROUP BY customer_id
HAVING COUNT(*) > 1
GO

-- Financial Transactions
SELECT
      transaction_id,
      COUNT(*) AS duplicate_count
FROM Financial_Transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1
GO

-- Employees
SELECT
      employee_id,
      COUNT(*) AS duplicate_count
FROM Employees
GROUP BY employee_id
HAVING COUNT(*) > 1
GO

-- Vendors
SELECT
      vendor_id,
      COUNT(*) AS duplicate_count
FROM Vendors
GROUP BY vendor_id
HAVING COUNT(*) > 1
GO

-- ------------------------------------------------------------------------------------------------
-- 1.2 FK VALIDATION
-- ------------------------------------------------------------------------------------------------

-- Transactions -> Customers (customer_id should exist in Customers)
SELECT
      ft.transaction_id,
      ft.customer_id
FROM Financial_Transactions ft
LEFT JOIN Customers c ON ft.customer_id = c.customer_id
WHERE ft.customer_id IS NOT NULL
  AND c.customer_id  IS NULL
GO

-- Transactions -> Vendors (vendor_id should exist in Vendors)
SELECT
      ft.transaction_id,
      ft.vendor_id
FROM Financial_Transactions ft
LEFT JOIN Vendors v ON ft.vendor_id = v.vendor_id
WHERE ft.vendor_id IS NOT NULL
  AND v.vendor_id  IS NULL
GO

-- ------------------------------------------------------------------------------------------------
-- 1.3 NULL CHECKS ON CRITICAL COLUMNS
-- ------------------------------------------------------------------------------------------------

-- Financial Transactions
SELECT
     SUM(CASE WHEN transaction_id   IS NULL THEN 1 ELSE 0 END) AS null_transaction_id,
     SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS null_transaction_date,
     SUM(CASE WHEN amount           IS NULL THEN 1 ELSE 0 END) AS null_amount,
     SUM(CASE WHEN account_type     IS NULL THEN 1 ELSE 0 END) AS null_account_type,
     SUM(CASE WHEN category         IS NULL THEN 1 ELSE 0 END) AS null_category,
     SUM(CASE WHEN business_unit    IS NULL THEN 1 ELSE 0 END) AS null_business_unit,
     SUM(CASE WHEN region           IS NULL THEN 1 ELSE 0 END) AS null_region,
     SUM(CASE WHEN customer_id      IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
     SUM(CASE WHEN vendor_id        IS NULL THEN 1 ELSE 0 END) AS null_vendor_id
FROM Financial_Transactions
GO

-- Budget
SELECT
     SUM(CASE WHEN year             IS NULL THEN 1 ELSE 0 END) AS null_year,
     SUM(CASE WHEN month            IS NULL THEN 1 ELSE 0 END) AS null_month,
     SUM(CASE WHEN business_unit    IS NULL THEN 1 ELSE 0 END) AS null_business_unit,
     SUM(CASE WHEN budgeted_revenue IS NULL THEN 1 ELSE 0 END) AS null_budgeted_revenue,
     SUM(CASE WHEN budgeted_expense IS NULL THEN 1 ELSE 0 END) AS null_budgeted_expense
FROM Budget
GO

-- Customers
SELECT
     SUM(CASE WHEN customer_id   IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
     SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS null_customer_name,
     SUM(CASE WHEN segment       IS NULL THEN 1 ELSE 0 END) AS null_segment,
     SUM(CASE WHEN join_date     IS NULL THEN 1 ELSE 0 END) AS null_join_date,
     SUM(CASE WHEN region        IS NULL THEN 1 ELSE 0 END) AS null_region,
     SUM(CASE WHEN status        IS NULL THEN 1 ELSE 0 END) AS null_status
FROM Customers
GO

-- Employees
SELECT
    SUM(CASE WHEN employee_id     IS NULL THEN 1 ELSE 0 END) AS null_employee_id,
    SUM(CASE WHEN employee_name   IS NULL THEN 1 ELSE 0 END) AS null_employee_name,
    SUM(CASE WHEN business_unit   IS NULL THEN 1 ELSE 0 END) AS null_business_unit,
    SUM(CASE WHEN join_date       IS NULL THEN 1 ELSE 0 END) AS null_join_date,
    SUM(CASE WHEN status          IS NULL THEN 1 ELSE 0 END) AS null_status,
    SUM(CASE WHEN region          IS NULL THEN 1 ELSE 0 END) AS null_region,
    SUM(CASE WHEN cost_to_company IS NULL THEN 1 ELSE 0 END) AS null_cost_to_company
FROM Employees
GO

-- Vendors
SELECT
    SUM(CASE WHEN vendor_id   IS NULL THEN 1 ELSE 0 END) AS null_vendor_id,
    SUM(CASE WHEN vendor_name IS NULL THEN 1 ELSE 0 END) AS null_vendor_name,
    SUM(CASE WHEN category    IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN region      IS NULL THEN 1 ELSE 0 END) AS null_region,
    SUM(CASE WHEN active      IS NULL THEN 1 ELSE 0 END) AS null_active
FROM Vendors
GO

-- ------------------------------------------------------------------------------------------------
-- 1.4 ROW COUNT VALIDATION
-- ------------------------------------------------------------------------------------------------

SELECT 'Budget'                  AS table_name, COUNT(*) AS row_count FROM Budget
UNION ALL
SELECT 'Customers',              COUNT(*) FROM Customers
UNION ALL
SELECT 'Financial_Transactions', COUNT(*) FROM Financial_Transactions
UNION ALL
SELECT 'Employees',              COUNT(*) FROM Employees
UNION ALL
SELECT 'Vendors',                COUNT(*) FROM Vendors
GO

-- ------------------------------------------------------------------------------------------------
-- 1.5 ALLOWED VALUES CHECK
-- ------------------------------------------------------------------------------------------------

-- account_type should only be Revenue / Expense / Asset / Liability / Equity
SELECT
      account_type,
      COUNT(*) AS count
FROM Financial_Transactions
GROUP BY account_type
ORDER BY count DESC
GO

-- active in Vendors should only be Y / N
SELECT
      active,
      COUNT(*) AS count
FROM Vendors
GROUP BY active
GO

-- status in Customers should only be Active / Inactive
SELECT
      status,
      COUNT(*) AS count
FROM Customers
GROUP BY status
GO

-- status in Employees should only be Active / Inactive
SELECT
      status,
      COUNT(*) AS count
FROM Employees
GROUP BY status
GO

-- business_unit should only be Retail / Enterprise / Online
SELECT
      business_unit,
      COUNT(*) AS count
FROM Financial_Transactions
GROUP BY business_unit
ORDER BY count DESC
GO

-- ================================================================================================
-- STEP 2: KPI CALCULATIONS
-- ================================================================================================

-- ------------------------------------------------------------------------------------------------
-- 2.1 TOTAL REVENUE, TOTAL EXPENSE, NET PROFIT & GROSS MARGIN
-- ------------------------------------------------------------------------------------------------

SELECT
     ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END), 2)   AS total_revenue,
     ROUND(SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END), 2)   AS total_expense,
     ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END) +
           SUM(CASE WHEN account_type = 'Expense' THEN amount     ELSE 0 END), 2)   AS net_profit,
     ROUND((SUM(CASE WHEN account_type = 'Revenue' THEN amount    ELSE 0 END) +
            SUM(CASE WHEN account_type = 'Expense' THEN amount    ELSE 0 END)) /
            NULLIF(SUM(CASE WHEN account_type = 'Revenue' THEN amount ELSE 0 END), 0) * 100, 2) AS gross_margin_pct
FROM Financial_Transactions
GO

-- ------------------------------------------------------------------------------------------------
-- 2.2 REVENUE, EXPENSE, PROFIT & MARGIN BY BUSINESS UNIT
-- ------------------------------------------------------------------------------------------------

SELECT
     business_unit,
     ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END), 2)   AS total_revenue,
     ROUND(SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END), 2)   AS total_expense,
     ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END) +
           SUM(CASE WHEN account_type = 'Expense' THEN amount     ELSE 0 END), 2)   AS net_profit,
     ROUND((SUM(CASE WHEN account_type = 'Revenue' THEN amount    ELSE 0 END) +
            SUM(CASE WHEN account_type = 'Expense' THEN amount    ELSE 0 END)) /
            NULLIF(SUM(CASE WHEN account_type = 'Revenue' THEN amount ELSE 0 END), 0) * 100, 2) AS gross_margin_pct
FROM Financial_Transactions
GROUP BY business_unit
ORDER BY total_revenue DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 2.3 REVENUE, EXPENSE, PROFIT & MARGIN BY REGION
-- ------------------------------------------------------------------------------------------------

SELECT
     region,
     ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END), 2)   AS total_revenue,
     ROUND(SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END), 2)   AS total_expense,
     ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END) +
           SUM(CASE WHEN account_type = 'Expense' THEN amount     ELSE 0 END), 2)   AS net_profit,
     ROUND((SUM(CASE WHEN account_type = 'Revenue' THEN amount    ELSE 0 END) +
            SUM(CASE WHEN account_type = 'Expense' THEN amount    ELSE 0 END)) /
            NULLIF(SUM(CASE WHEN account_type = 'Revenue' THEN amount ELSE 0 END), 0) * 100, 2) AS gross_margin_pct
FROM Financial_Transactions
GROUP BY region
ORDER BY total_revenue DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 2.4 BUDGET UTILISATION %
-- ------------------------------------------------------------------------------------------------

WITH Actuals AS (
     SELECT
           YEAR(transaction_date)  AS year,
           MONTH(transaction_date) AS month,
           business_unit,
           SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END) AS actual_revenue,
           SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END) AS actual_expense
     FROM Financial_Transactions
     GROUP BY YEAR(transaction_date), MONTH(transaction_date), business_unit
)
SELECT
      b.year,
      b.business_unit,
      ROUND(SUM(b.budgeted_revenue), 2)                                                  AS total_budgeted_revenue,
      ROUND(SUM(a.actual_revenue),   2)                                                  AS total_actual_revenue,
      ROUND(SUM(a.actual_revenue)  / NULLIF(SUM(b.budgeted_revenue), 0) * 100, 2)       AS revenue_utilisation_pct,
      ROUND(SUM(b.budgeted_expense), 2)                                                  AS total_budgeted_expense,
      ROUND(SUM(a.actual_expense),   2)                                                  AS total_actual_expense,
      ROUND(SUM(a.actual_expense)  / NULLIF(SUM(b.budgeted_expense), 0) * 100, 2)       AS expense_utilisation_pct,
      CASE
            WHEN ROUND(SUM(a.actual_expense) / NULLIF(SUM(b.budgeted_expense), 0) * 100, 2) > 100 THEN 'Over Utilised'
            WHEN ROUND(SUM(a.actual_expense) / NULLIF(SUM(b.budgeted_expense), 0) * 100, 2) < 80  THEN 'Under Utilised'
            ELSE 'Optimal'
      END AS utilisation_status
FROM Budget b
LEFT JOIN Actuals a ON b.year          = a.year
                   AND b.month         = a.month
                   AND b.business_unit = a.business_unit
GROUP BY b.year, b.business_unit
ORDER BY b.year, b.business_unit
GO

-- ------------------------------------------------------------------------------------------------
-- 2.5 COST PER EMPLOYEE BY BUSINESS UNIT
-- ------------------------------------------------------------------------------------------------

SELECT
      business_unit,
      COUNT(DISTINCT employee_id)          AS total_employees,
      SUM(cost_to_company)                 AS total_ctc,
      ROUND(AVG(cost_to_company), 2)       AS avg_cost_per_employee,
      MIN(cost_to_company)                 AS min_ctc,
      MAX(cost_to_company)                 AS max_ctc
FROM Employees
WHERE status = 'Active'
GROUP BY business_unit
ORDER BY avg_cost_per_employee DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 2.6 REVENUE PER CUSTOMER
-- ------------------------------------------------------------------------------------------------

SELECT
      ft.customer_id,
      c.customer_name,
      c.segment,
      c.region,
      c.status,
      COUNT(ft.transaction_id)             AS total_transactions,
      ROUND(SUM(ft.amount),  2)            AS total_revenue,
      ROUND(AVG(ft.amount),  2)            AS avg_revenue_per_transaction
FROM Financial_Transactions ft
LEFT JOIN Customers c ON ft.customer_id = c.customer_id
WHERE ft.account_type = 'Revenue'
GROUP BY ft.customer_id, c.customer_name, c.segment, c.region, c.status
ORDER BY total_revenue DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 2.7 SPEND PER VENDOR
-- ------------------------------------------------------------------------------------------------

SELECT
      ft.vendor_id,
      v.vendor_name,
      v.category,
      v.region,
      v.active,
      COUNT(ft.transaction_id)             AS total_transactions,
      ROUND(SUM(ft.amount_abs), 2)         AS total_spend,
      ROUND(AVG(ft.amount_abs), 2)         AS avg_spend_per_transaction
FROM Financial_Transactions ft
LEFT JOIN Vendors v ON ft.vendor_id = v.vendor_id
WHERE ft.account_type = 'Expense'
GROUP BY ft.vendor_id, v.vendor_name, v.category, v.region, v.active
ORDER BY total_spend DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 2.8 OVERALL KPI SUMMARY
-- ------------------------------------------------------------------------------------------------

SELECT
      ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END), 2)  AS total_revenue,
      ROUND(SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END), 2)  AS total_expense,
      ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END) +
            SUM(CASE WHEN account_type = 'Expense' THEN amount     ELSE 0 END), 2)  AS net_profit,
      ROUND((SUM(CASE WHEN account_type = 'Revenue' THEN amount    ELSE 0 END) +
             SUM(CASE WHEN account_type = 'Expense' THEN amount    ELSE 0 END)) /
             NULLIF(SUM(CASE WHEN account_type = 'Revenue' THEN amount ELSE 0 END), 0) * 100, 2) AS gross_margin_pct,
      COUNT(DISTINCT customer_id)                                                    AS total_customers,
      COUNT(DISTINCT vendor_id)                                                      AS total_vendors,
      COUNT(transaction_id)                                                          AS total_transactions
FROM Financial_Transactions
GO

-- ------------------------------------------------------------------------------------------------
-- 2.9 TOP AND BOTTOM PERFORMING BUSINESS UNITS
-- ------------------------------------------------------------------------------------------------

WITH unit_performance AS (
    SELECT
          business_unit,
          ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END), 2) AS total_revenue,
          ROUND(SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END), 2) AS total_expense,
          ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END) +
                SUM(CASE WHEN account_type = 'Expense' THEN amount     ELSE 0 END), 2) AS net_profit
    FROM Financial_Transactions
    GROUP BY business_unit
)
SELECT
      business_unit,
      total_revenue,
      total_expense,
      net_profit,
      CASE
          WHEN net_profit = MAX(net_profit) OVER () THEN 'Top Performer'
          WHEN net_profit = MIN(net_profit) OVER () THEN 'Bottom Performer'
          ELSE 'Average Performer'
      END AS performance_status
FROM unit_performance
ORDER BY net_profit DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 2.10 CUSTOMER SEGMENT KPI BREAKDOWN
-- ------------------------------------------------------------------------------------------------

SELECT
    c.segment,
    COUNT(DISTINCT ft.customer_id)                                                    AS total_customers,
    COUNT(ft.transaction_id)                                                          AS total_transactions,
    ROUND(SUM(ft.amount), 2)                                                          AS total_revenue,
    ROUND(AVG(ft.amount), 2)                                                          AS avg_revenue_per_transaction,
    ROUND(SUM(ft.amount) / NULLIF(COUNT(DISTINCT ft.customer_id), 0), 2)             AS revenue_per_customer
FROM Financial_Transactions ft
JOIN Customers c ON ft.customer_id = c.customer_id
WHERE ft.account_type = 'Revenue'
GROUP BY c.segment
ORDER BY total_revenue DESC
GO

-- ================================================================================================
-- STEP 3: BUDGET VARIANCE ANALYSIS
-- ================================================================================================

-- ------------------------------------------------------------------------------------------------
-- 3.1 MONTHLY BUDGET VARIANCE BY BUSINESS UNIT
-- ------------------------------------------------------------------------------------------------

WITH actuals AS (
    SELECT
        YEAR(transaction_date)  AS year,
        MONTH(transaction_date) AS month,
        business_unit,
        ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END), 2) AS actual_revenue,
        ROUND(SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END), 2) AS actual_expense
    FROM Financial_Transactions
    GROUP BY YEAR(transaction_date), MONTH(transaction_date), business_unit
)
SELECT
    b.year,
    b.month,
    b.business_unit,
    b.budgeted_revenue,
    ISNULL(a.actual_revenue, 0)                                                              AS actual_revenue,
    ROUND(ISNULL(a.actual_revenue, 0) - b.budgeted_revenue, 2)                              AS revenue_variance,
    ROUND((ISNULL(a.actual_revenue, 0) - b.budgeted_revenue)
          / NULLIF(b.budgeted_revenue, 0) * 100, 2)                                         AS revenue_variance_pct,
    b.budgeted_expense,
    ISNULL(a.actual_expense, 0)                                                              AS actual_expense,
    ROUND(ISNULL(a.actual_expense, 0) - b.budgeted_expense, 2)                              AS expense_variance,
    ROUND((ISNULL(a.actual_expense, 0) - b.budgeted_expense)
          / NULLIF(b.budgeted_expense, 0) * 100, 2)                                         AS expense_variance_pct,
    CASE
        WHEN ISNULL(a.actual_expense, 0) > b.budgeted_expense THEN 'Over Budget'
        WHEN ISNULL(a.actual_expense, 0) < b.budgeted_expense THEN 'Under Budget'
        ELSE 'On Track'
    END AS budget_status,
    CASE
        WHEN ISNULL(a.actual_revenue, 0) >= b.budgeted_revenue THEN 'Target Met'
        ELSE 'Below Target'
    END AS revenue_status
FROM Budget b
LEFT JOIN actuals a ON b.year          = a.year
                   AND b.month         = a.month
                   AND b.business_unit = a.business_unit
ORDER BY b.year, b.month, b.business_unit
GO

-- ------------------------------------------------------------------------------------------------
-- 3.2 ANNUAL BUDGET VARIANCE SUMMARY
-- ------------------------------------------------------------------------------------------------

WITH actuals AS (
    SELECT
        YEAR(transaction_date) AS year,
        business_unit,
        ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END), 2) AS actual_revenue,
        ROUND(SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END), 2) AS actual_expense
    FROM Financial_Transactions
    GROUP BY YEAR(transaction_date), business_unit
)
SELECT
    b.year,
    b.business_unit,
    SUM(b.budgeted_revenue)                                                                  AS total_budgeted_revenue,
    ISNULL(a.actual_revenue, 0)                                                              AS total_actual_revenue,
    ROUND(ISNULL(a.actual_revenue, 0) - SUM(b.budgeted_revenue), 2)                         AS revenue_variance,
    ROUND((ISNULL(a.actual_revenue, 0) - SUM(b.budgeted_revenue))
          / NULLIF(SUM(b.budgeted_revenue), 0) * 100, 2)                                    AS revenue_variance_pct,
    SUM(b.budgeted_expense)                                                                  AS total_budgeted_expense,
    ISNULL(a.actual_expense, 0)                                                              AS total_actual_expense,
    ROUND(ISNULL(a.actual_expense, 0) - SUM(b.budgeted_expense), 2)                         AS expense_variance,
    ROUND((ISNULL(a.actual_expense, 0) - SUM(b.budgeted_expense))
          / NULLIF(SUM(b.budgeted_expense), 0) * 100, 2)                                    AS expense_variance_pct,
    CASE
        WHEN ISNULL(a.actual_expense, 0) > SUM(b.budgeted_expense) THEN 'Over Budget'
        WHEN ISNULL(a.actual_expense, 0) < SUM(b.budgeted_expense) THEN 'Under Budget'
        ELSE 'On Track'
    END AS budget_status
FROM Budget b
LEFT JOIN actuals a ON b.year          = a.year
                   AND b.business_unit = a.business_unit
GROUP BY b.year, b.business_unit, a.actual_revenue, a.actual_expense
ORDER BY b.year, b.business_unit
GO

-- ------------------------------------------------------------------------------------------------
-- 3.3 OVER BUDGET MONTHS DRILL DOWN
-- ------------------------------------------------------------------------------------------------

WITH actuals AS (
    SELECT
        YEAR(transaction_date)  AS year,
        MONTH(transaction_date) AS month,
        business_unit,
        ROUND(SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END), 2) AS actual_expense
    FROM Financial_Transactions
    GROUP BY YEAR(transaction_date), MONTH(transaction_date), business_unit
)
SELECT
    b.year,
    b.month,
    b.business_unit,
    b.budgeted_expense,
    ISNULL(a.actual_expense, 0)                                                  AS actual_expense,
    ROUND(ISNULL(a.actual_expense, 0) - b.budgeted_expense, 2)                  AS overspend_amount,
    ROUND((ISNULL(a.actual_expense, 0) - b.budgeted_expense)
          / NULLIF(b.budgeted_expense, 0) * 100, 2)                              AS overspend_pct
FROM Budget b
LEFT JOIN actuals a ON b.year          = a.year
                   AND b.month         = a.month
                   AND b.business_unit = a.business_unit
WHERE ISNULL(a.actual_expense, 0) > b.budgeted_expense
ORDER BY overspend_amount DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 3.4 COST SPIKE DETECTION
-- Months where expense jumped > 20% vs previous month
-- ------------------------------------------------------------------------------------------------

WITH monthly_expense AS (
    SELECT
        YEAR(transaction_date)  AS year,
        MONTH(transaction_date) AS month,
        business_unit,
        ROUND(SUM(amount_abs), 2) AS actual_expense
    FROM Financial_Transactions
    WHERE account_type = 'Expense'
    GROUP BY YEAR(transaction_date), MONTH(transaction_date), business_unit
),
with_prev AS (
    SELECT
        year,
        month,
        business_unit,
        actual_expense,
        LAG(actual_expense) OVER (
            PARTITION BY business_unit
            ORDER BY year, month
        ) AS prev_month_expense
    FROM monthly_expense
)
SELECT
    year,
    month,
    business_unit,
    actual_expense,
    prev_month_expense,
    ROUND(actual_expense - prev_month_expense, 2)                                         AS expense_change,
    ROUND((actual_expense - prev_month_expense) / NULLIF(prev_month_expense, 0) * 100, 2) AS expense_change_pct,
    CASE
        WHEN (actual_expense - prev_month_expense) / NULLIF(prev_month_expense, 0) * 100 > 20
        THEN 'Cost Spike'
        ELSE 'Normal'
    END AS spike_flag
FROM with_prev
WHERE prev_month_expense IS NOT NULL
ORDER BY expense_change_pct DESC
GO

-- ================================================================================================
-- STEP 4: UNDERPERFORMING vs OVERACHIEVING UNITS
-- ================================================================================================

-- ------------------------------------------------------------------------------------------------
-- 4.1 BUSINESS UNIT PERFORMANCE SCORECARD
-- Revenue, Expense, Profit with performance flags
-- ------------------------------------------------------------------------------------------------

WITH actuals AS (
    SELECT
        YEAR(transaction_date) AS year,
        business_unit,
        ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END), 2) AS actual_revenue,
        ROUND(SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END), 2) AS actual_expense,
        ROUND(SUM(amount), 2)                                                         AS net_profit
    FROM Financial_Transactions
    GROUP BY YEAR(transaction_date), business_unit
),
budget_summary AS (
    SELECT
        year,
        business_unit,
        SUM(budgeted_revenue) AS total_budgeted_revenue,
        SUM(budgeted_expense) AS total_budgeted_expense
    FROM Budget
    GROUP BY year, business_unit
)
SELECT
    a.year,
    a.business_unit,
    b.total_budgeted_revenue,
    a.actual_revenue,
    ROUND(a.actual_revenue - b.total_budgeted_revenue, 2)                                    AS revenue_variance,
    ROUND(a.actual_revenue / NULLIF(b.total_budgeted_revenue, 0) * 100, 2)                   AS revenue_achievement_pct,
    b.total_budgeted_expense,
    a.actual_expense,
    ROUND(a.actual_expense - b.total_budgeted_expense, 2)                                    AS expense_variance,
    a.net_profit,
    ROUND(a.net_profit / NULLIF(a.actual_revenue, 0) * 100, 2)                              AS gross_margin_pct,
    CASE
        WHEN a.actual_revenue >= b.total_budgeted_revenue * 1.05 THEN 'Overachieving'
        WHEN a.actual_revenue >= b.total_budgeted_revenue        THEN 'On Target'
        WHEN a.actual_revenue >= b.total_budgeted_revenue * 0.90 THEN 'Slightly Below'
        ELSE                                                           'Underperforming'
    END AS revenue_flag,
    CASE
        WHEN a.actual_expense > b.total_budgeted_expense * 1.05 THEN 'Significantly Over Budget'
        WHEN a.actual_expense > b.total_budgeted_expense        THEN 'Over Budget'
        WHEN a.actual_expense < b.total_budgeted_expense * 0.80 THEN 'Under Utilised'
        ELSE                                                          'On Track'
    END AS expense_flag,
    CASE
        WHEN a.actual_revenue >= b.total_budgeted_revenue
         AND a.actual_expense <= b.total_budgeted_expense THEN 'Healthy'
        WHEN a.actual_revenue >= b.total_budgeted_revenue
         AND a.actual_expense >  b.total_budgeted_expense THEN 'Revenue Good / Cost Overrun'
        WHEN a.actual_revenue <  b.total_budgeted_revenue
         AND a.actual_expense <= b.total_budgeted_expense THEN 'Revenue Miss / Cost Controlled'
        ELSE                                                    'Needs Attention'
    END AS overall_health
FROM actuals a
JOIN budget_summary b ON a.year          = b.year
                     AND a.business_unit = b.business_unit
ORDER BY a.year, revenue_achievement_pct DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 4.2 CONSECUTIVE UNDERPERFORMING MONTHS
-- Flag units that underperformed 2+ months in a row
-- ------------------------------------------------------------------------------------------------

WITH actuals AS (
    SELECT
        YEAR(transaction_date)  AS year,
        MONTH(transaction_date) AS month,
        business_unit,
        ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount ELSE 0 END), 2) AS actual_revenue
    FROM Financial_Transactions
    GROUP BY YEAR(transaction_date), MONTH(transaction_date), business_unit
),
performance AS (
    SELECT
        b.year,
        b.month,
        b.business_unit,
        b.budgeted_revenue,
        ISNULL(a.actual_revenue, 0) AS actual_revenue,
        CASE
            WHEN ISNULL(a.actual_revenue, 0) < b.budgeted_revenue THEN 1
            ELSE 0
        END AS is_underperforming
    FROM Budget b
    LEFT JOIN actuals a ON b.year          = a.year
                       AND b.month         = a.month
                       AND b.business_unit = a.business_unit
),
with_prev AS (
    SELECT
        year, month, business_unit,
        is_underperforming,
        LAG(is_underperforming) OVER (
            PARTITION BY business_unit
            ORDER BY year, month
        ) AS prev_month_flag
    FROM performance
)
SELECT
    year,
    month,
    business_unit,
    'Consecutive Underperformance' AS alert
FROM with_prev
WHERE is_underperforming = 1
  AND prev_month_flag    = 1
ORDER BY business_unit, year, month
GO

-- ================================================================================================
-- STEP 5: EDA & DESCRIPTIVE STATISTICS
-- ================================================================================================

-- ------------------------------------------------------------------------------------------------
-- 5.1 OVERALL SUMMARY STATISTICS
-- Mean, Median, Std Dev, Min, Max, IQR on transaction amount
-- ------------------------------------------------------------------------------------------------

SELECT TOP 1
    total_transactions,
    total_amount,
    mean_amount,
    std_dev,
    min_amount,
    max_amount,
    range_amount,
    median_amount,
    Q1,
    Q3,
    IQR
FROM (
    SELECT
        COUNT(transaction_id)  OVER ()                                                    AS total_transactions,
        ROUND(SUM(amount_abs)  OVER (), 2)                                                AS total_amount,
        ROUND(AVG(amount_abs)  OVER (), 2)                                                AS mean_amount,
        ROUND(STDEV(amount_abs)OVER (), 2)                                                AS std_dev,
        ROUND(MIN(amount_abs)  OVER (), 2)                                                AS min_amount,
        ROUND(MAX(amount_abs)  OVER (), 2)                                                AS max_amount,
        ROUND(MAX(amount_abs)  OVER () - MIN(amount_abs) OVER (), 2)                      AS range_amount,
        ROUND(PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY amount_abs) OVER (), 2)        AS median_amount,
        ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_abs) OVER (), 2)        AS Q1,
        ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_abs) OVER (), 2)        AS Q3,
        ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_abs) OVER () -
              PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_abs) OVER (), 2)        AS IQR
    FROM Financial_Transactions
) x
GO

-- ------------------------------------------------------------------------------------------------
-- 5.2 SUMMARY STATISTICS BY ACCOUNT TYPE
-- ------------------------------------------------------------------------------------------------

WITH base AS (
    SELECT account_type, amount_abs
    FROM Financial_Transactions
),
stats AS (
    SELECT
        account_type,
        COUNT(*)                        AS total_transactions,
        ROUND(SUM(amount_abs), 2)       AS total_amount,
        ROUND(AVG(amount_abs), 2)       AS mean_amount,
        ROUND(STDEV(amount_abs), 2)     AS std_dev,
        ROUND(MIN(amount_abs), 2)       AS min_amount,
        ROUND(MAX(amount_abs), 2)       AS max_amount
    FROM base
    GROUP BY account_type
),
percentiles AS (
    SELECT DISTINCT
        account_type,
        ROUND(PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY account_type), 2) AS median_amount,
        ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY account_type), 2) AS Q1,
        ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY account_type), 2) AS Q3,
        ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY account_type) -
              PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY account_type), 2) AS IQR
    FROM base
)
SELECT
    s.account_type,
    s.total_transactions,
    s.total_amount,
    s.mean_amount,
    s.std_dev,
    s.min_amount,
    s.max_amount,
    p.median_amount,
    p.Q1,
    p.Q3,
    p.IQR
FROM stats s
JOIN percentiles p ON s.account_type = p.account_type
ORDER BY s.account_type
GO

-- ------------------------------------------------------------------------------------------------
-- 5.3 SUMMARY STATISTICS BY CATEGORY
-- ------------------------------------------------------------------------------------------------

WITH base AS (
    SELECT category, account_type, amount_abs
    FROM Financial_Transactions
),
stats AS (
    SELECT
        category,
        account_type,
        COUNT(*)                        AS total_transactions,
        ROUND(SUM(amount_abs), 2)       AS total_amount,
        ROUND(AVG(amount_abs), 2)       AS mean_amount,
        ROUND(STDEV(amount_abs), 2)     AS std_dev,
        ROUND(MIN(amount_abs), 2)       AS min_amount,
        ROUND(MAX(amount_abs), 2)       AS max_amount
    FROM base
    GROUP BY category, account_type
),
percentiles AS (
    SELECT DISTINCT
        category,
        account_type,
        ROUND(PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY category, account_type), 2) AS median_amount,
        ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY category, account_type), 2) AS Q1,
        ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY category, account_type), 2) AS Q3,
        ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY category, account_type) -
              PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY category, account_type), 2) AS IQR
    FROM base
)
SELECT
    s.category,
    s.account_type,
    s.total_transactions,
    s.total_amount,
    s.mean_amount,
    s.std_dev,
    s.min_amount,
    s.max_amount,
    p.median_amount,
    p.Q1,
    p.Q3,
    p.IQR
FROM stats s
JOIN percentiles p ON s.category     = p.category
                  AND s.account_type = p.account_type
ORDER BY s.account_type, s.total_amount DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 5.4 DISTRIBUTION OF TRANSACTIONS BY AMOUNT RANGE
-- ------------------------------------------------------------------------------------------------

SELECT
    CASE
        WHEN amount_abs BETWEEN 0      AND 25000  THEN '1. 0 - 25K'
        WHEN amount_abs BETWEEN 25001  AND 50000  THEN '2. 25K - 50K'
        WHEN amount_abs BETWEEN 50001  AND 100000 THEN '3. 50K - 100K'
        WHEN amount_abs BETWEEN 100001 AND 200000 THEN '4. 100K - 200K'
        ELSE                                           '5. 200K+'
    END                               AS amount_bucket,
    account_type,
    COUNT(transaction_id)             AS total_transactions,
    ROUND(SUM(amount_abs), 2)         AS total_amount,
    ROUND(AVG(amount_abs), 2)         AS avg_amount
FROM Financial_Transactions
GROUP BY
    CASE
        WHEN amount_abs BETWEEN 0      AND 25000  THEN '1. 0 - 25K'
        WHEN amount_abs BETWEEN 25001  AND 50000  THEN '2. 25K - 50K'
        WHEN amount_abs BETWEEN 50001  AND 100000 THEN '3. 50K - 100K'
        WHEN amount_abs BETWEEN 100001 AND 200000 THEN '4. 100K - 200K'
        ELSE                                           '5. 200K+'
    END,
    account_type
ORDER BY amount_bucket, account_type
GO

-- ------------------------------------------------------------------------------------------------
-- 5.5 EMPLOYEE CTC DISTRIBUTION BY BUSINESS UNIT
-- ------------------------------------------------------------------------------------------------

WITH base AS (
    SELECT business_unit, employee_id, cost_to_company
    FROM Employees
    WHERE status = 'Active'
),
stats AS (
    SELECT
        business_unit,
        COUNT(DISTINCT employee_id)         AS total_employees,
        ROUND(SUM(cost_to_company),  2)     AS total_ctc,
        ROUND(AVG(cost_to_company),  2)     AS mean_ctc,
        ROUND(STDEV(cost_to_company), 2)    AS std_dev_ctc,
        MIN(cost_to_company)                AS min_ctc,
        MAX(cost_to_company)                AS max_ctc
    FROM base
    GROUP BY business_unit
),
percentiles AS (
    SELECT DISTINCT
        business_unit,
        ROUND(PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY cost_to_company) OVER (PARTITION BY business_unit), 2) AS median_ctc,
        ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY cost_to_company) OVER (PARTITION BY business_unit), 2) AS Q1_ctc,
        ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cost_to_company) OVER (PARTITION BY business_unit), 2) AS Q3_ctc,
        ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cost_to_company) OVER (PARTITION BY business_unit) -
              PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY cost_to_company) OVER (PARTITION BY business_unit), 2) AS IQR_ctc
    FROM base
)
SELECT
    s.business_unit,
    s.total_employees,
    s.total_ctc,
    s.mean_ctc,
    s.std_dev_ctc,
    s.min_ctc,
    s.max_ctc,
    p.median_ctc,
    p.Q1_ctc,
    p.Q3_ctc,
    p.IQR_ctc
FROM stats s
JOIN percentiles p ON s.business_unit = p.business_unit
ORDER BY s.business_unit
GO

-- ------------------------------------------------------------------------------------------------
-- 5.6 BUDGET VARIANCE DISTRIBUTION STATISTICS
-- ------------------------------------------------------------------------------------------------

WITH actuals AS (
    SELECT
        YEAR(transaction_date)  AS year,
        MONTH(transaction_date) AS month,
        business_unit,
        ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END), 2) AS actual_revenue,
        ROUND(SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END), 2) AS actual_expense
    FROM Financial_Transactions
    GROUP BY YEAR(transaction_date), MONTH(transaction_date), business_unit
),
variance_data AS (
    SELECT
        b.year,
        b.month,
        b.business_unit,
        ROUND(ISNULL(a.actual_revenue, 0) - b.budgeted_revenue, 2) AS revenue_variance,
        ROUND(ISNULL(a.actual_expense, 0) - b.budgeted_expense, 2) AS expense_variance
    FROM Budget b
    LEFT JOIN actuals a ON b.year          = a.year
                       AND b.month         = a.month
                       AND b.business_unit = a.business_unit
)
SELECT
    business_unit,
    ROUND(AVG(revenue_variance),   2) AS avg_revenue_variance,
    ROUND(STDEV(revenue_variance), 2) AS std_dev_revenue_variance,
    ROUND(MIN(revenue_variance),   2) AS min_revenue_variance,
    ROUND(MAX(revenue_variance),   2) AS max_revenue_variance,
    ROUND(AVG(expense_variance),   2) AS avg_expense_variance,
    ROUND(STDEV(expense_variance), 2) AS std_dev_expense_variance,
    ROUND(MIN(expense_variance),   2) AS min_expense_variance,
    ROUND(MAX(expense_variance),   2) AS max_expense_variance
FROM variance_data
GROUP BY business_unit
ORDER BY business_unit
GO

-- ================================================================================================
-- STEP 6: OUTLIER & ANOMALY DETECTION
-- ================================================================================================

-- ------------------------------------------------------------------------------------------------
-- 6.1 IQR BASED OUTLIER DETECTION
-- Transactions outside Q1 - 1.5*IQR and Q3 + 1.5*IQR
-- ------------------------------------------------------------------------------------------------

WITH iqr_stats AS (
    SELECT DISTINCT
        account_type,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY account_type) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY account_type) AS q3
    FROM Financial_Transactions
),
bounds AS (
    SELECT
        account_type,
        ROUND(q1 - 1.5 * (q3 - q1), 2) AS lower_bound,
        ROUND(q3 + 1.5 * (q3 - q1), 2) AS upper_bound
    FROM iqr_stats
)
SELECT
    ft.transaction_id,
    ft.transaction_date,
    ft.account_type,
    ft.category,
    ft.business_unit,
    ft.region,
    ft.amount_abs,
    b.lower_bound,
    b.upper_bound,
    CASE
        WHEN ft.amount_abs > b.upper_bound THEN 'Upper Outlier'
        WHEN ft.amount_abs < b.lower_bound THEN 'Lower Outlier'
    END AS outlier_type
FROM Financial_Transactions ft
JOIN bounds b ON ft.account_type = b.account_type
WHERE ft.amount_abs > b.upper_bound
   OR ft.amount_abs < b.lower_bound
ORDER BY ft.amount_abs DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 6.2 Z-SCORE BASED OUTLIER DETECTION
-- Z-score > 3 are outliers
-- ------------------------------------------------------------------------------------------------

WITH stats AS (
    SELECT
        account_type,
        AVG(amount_abs)   AS mean_amount,
        STDEV(amount_abs) AS std_dev
    FROM Financial_Transactions
    GROUP BY account_type
)
SELECT
    ft.transaction_id,
    ft.transaction_date,
    ft.account_type,
    ft.category,
    ft.business_unit,
    ft.region,
    ft.amount_abs,
    ROUND((ft.amount_abs - s.mean_amount) / NULLIF(s.std_dev, 0), 2) AS z_score,
    'Outlier' AS z_score_flag
FROM Financial_Transactions ft
JOIN stats s ON ft.account_type = s.account_type
WHERE ABS((ft.amount_abs - s.mean_amount) / NULLIF(s.std_dev, 0)) > 3
ORDER BY z_score DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 6.3 DUPLICATE TRANSACTION DETECTION
-- Same amount, date, business unit, category, account type
-- ------------------------------------------------------------------------------------------------

SELECT
    transaction_date,
    amount,
    business_unit,
    category,
    account_type,
    COUNT(*) AS duplicate_count
FROM Financial_Transactions
GROUP BY
    transaction_date,
    amount,
    business_unit,
    category,
    account_type
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 6.4 UNUSUALLY HIGH SINGLE DAY SPEND
-- Days where total expense z-score > 2
-- ------------------------------------------------------------------------------------------------

WITH daily_expense AS (
    SELECT
        transaction_date,
        business_unit,
        ROUND(SUM(amount_abs), 2) AS daily_total
    FROM Financial_Transactions
    WHERE account_type = 'Expense'
    GROUP BY transaction_date, business_unit
),
stats AS (
    SELECT
        business_unit,
        AVG(daily_total)   AS mean_daily,
        STDEV(daily_total) AS std_daily
    FROM daily_expense
    GROUP BY business_unit
)
SELECT
    d.transaction_date,
    d.business_unit,
    d.daily_total,
    ROUND(s.mean_daily, 2)                                             AS mean_daily_expense,
    ROUND(s.std_daily,  2)                                             AS std_dev,
    ROUND((d.daily_total - s.mean_daily) / NULLIF(s.std_daily, 0), 2) AS z_score,
    'High Spend Day'                                                   AS anomaly_flag
FROM daily_expense d
JOIN stats s ON d.business_unit = s.business_unit
WHERE (d.daily_total - s.mean_daily) / NULLIF(s.std_daily, 0) > 2
ORDER BY z_score DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 6.5 TRANSACTIONS WITH MISSING FK
-- Revenue with no customer / Expense with no vendor
-- ------------------------------------------------------------------------------------------------

SELECT
    transaction_id,
    transaction_date,
    amount,
    account_type,
    category,
    business_unit,
    'Revenue with no Customer' AS anomaly_flag
FROM Financial_Transactions
WHERE account_type = 'Revenue'
  AND customer_id  IS NULL

UNION ALL

SELECT
    transaction_id,
    transaction_date,
    amount,
    account_type,
    category,
    business_unit,
    'Expense with no Vendor' AS anomaly_flag
FROM Financial_Transactions
WHERE account_type = 'Expense'
  AND vendor_id    IS NULL
ORDER BY anomaly_flag, transaction_date
GO

-- ------------------------------------------------------------------------------------------------
-- 6.6 SIGN MISMATCH — NEGATIVE REVENUE / POSITIVE EXPENSE
-- ------------------------------------------------------------------------------------------------

SELECT
    transaction_id,
    transaction_date,
    account_type,
    amount,
    category,
    business_unit,
    'Sign Mismatch' AS anomaly_flag
FROM Financial_Transactions
WHERE (account_type = 'Revenue' AND amount < 0)
   OR (account_type = 'Expense' AND amount > 0)
ORDER BY account_type, amount
GO

-- ------------------------------------------------------------------------------------------------
-- 6.7 ANOMALY SUMMARY — ALL ANOMALY TYPES IN ONE VIEW
-- ------------------------------------------------------------------------------------------------

WITH iqr_stats AS (
    SELECT DISTINCT
        account_type,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY account_type) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount_abs) OVER (PARTITION BY account_type) AS q3
    FROM Financial_Transactions
),
outlier_bounds AS (
    SELECT
        account_type,
        q1 - 1.5 * (q3 - q1) AS lower_bound,
        q3 + 1.5 * (q3 - q1) AS upper_bound
    FROM iqr_stats
)
SELECT 'IQR Outliers'           AS anomaly_type, COUNT(ft.transaction_id) AS total_count
FROM Financial_Transactions ft
JOIN outlier_bounds b ON ft.account_type = b.account_type
WHERE ft.amount_abs > b.upper_bound
   OR ft.amount_abs < b.lower_bound

UNION ALL

SELECT 'Sign Mismatch',         COUNT(*)
FROM Financial_Transactions
WHERE (account_type = 'Revenue' AND amount < 0)
   OR (account_type = 'Expense' AND amount > 0)

UNION ALL

SELECT 'Revenue No Customer',   COUNT(*)
FROM Financial_Transactions
WHERE account_type = 'Revenue' AND customer_id IS NULL

UNION ALL

SELECT 'Expense No Vendor',     COUNT(*)
FROM Financial_Transactions
WHERE account_type = 'Expense' AND vendor_id IS NULL

UNION ALL

SELECT 'Duplicate Transactions', COUNT(*)
FROM (
    SELECT transaction_date, amount, business_unit, category, account_type
    FROM Financial_Transactions
    GROUP BY transaction_date, amount, business_unit, category, account_type
    HAVING COUNT(*) > 1
) AS dupes
GO

-- ================================================================================================
-- STEP 7: TIME TREND ANALYSIS
-- ================================================================================================

-- ------------------------------------------------------------------------------------------------
-- 7.1 YEAR OVER YEAR (YoY) COMPARISON
-- ------------------------------------------------------------------------------------------------

WITH yearly AS (
    SELECT
        YEAR(transaction_date)                                                        AS year,
        ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END), 2) AS total_revenue,
        ROUND(SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END), 2) AS total_expense,
        ROUND(SUM(amount), 2)                                                         AS net_profit
    FROM Financial_Transactions
    GROUP BY YEAR(transaction_date)
)
SELECT
    y.year,
    y.total_revenue,
    y.total_expense,
    y.net_profit,
    LAG(y.total_revenue) OVER (ORDER BY y.year)                                       AS prev_year_revenue,
    LAG(y.total_expense) OVER (ORDER BY y.year)                                       AS prev_year_expense,
    LAG(y.net_profit)    OVER (ORDER BY y.year)                                       AS prev_year_profit,
    ROUND((y.total_revenue - LAG(y.total_revenue) OVER (ORDER BY y.year))
          / NULLIF(LAG(y.total_revenue) OVER (ORDER BY y.year), 0) * 100, 2)         AS revenue_yoy_growth_pct,
    ROUND((y.total_expense - LAG(y.total_expense) OVER (ORDER BY y.year))
          / NULLIF(LAG(y.total_expense) OVER (ORDER BY y.year), 0) * 100, 2)         AS expense_yoy_growth_pct,
    ROUND((y.net_profit - LAG(y.net_profit) OVER (ORDER BY y.year))
          / NULLIF(LAG(y.net_profit) OVER (ORDER BY y.year), 0) * 100, 2)            AS profit_yoy_growth_pct
FROM yearly y
ORDER BY year
GO

-- ------------------------------------------------------------------------------------------------
-- 7.2 MONTH OVER MONTH (MoM) GROWTH
-- ------------------------------------------------------------------------------------------------

WITH monthly AS (
    SELECT
        YEAR(transaction_date)                                                        AS year,
        MONTH(transaction_date)                                                       AS month,
        ROUND(SUM(CASE WHEN account_type = 'Revenue' THEN amount     ELSE 0 END), 2) AS total_revenue,
        ROUND(SUM(CASE WHEN account_type = 'Expense' THEN amount_abs ELSE 0 END), 2) AS total_expense,
        ROUND(SUM(amount), 2)                                                         AS net_profit
    FROM Financial_Transactions
    GROUP BY YEAR(transaction_date), MONTH(transaction_date)
)
SELECT
    year,
    month,
    total_revenue,
    total_expense,
    net_profit,
    LAG(total_revenue) OVER (ORDER BY year, month)                                    AS prev_month_revenue,
    ROUND((total_revenue - LAG(total_revenue) OVER (ORDER BY year, month))
          / NULLIF(LAG(total_revenue) OVER (ORDER BY year, month), 0) * 100, 2)      AS revenue_mom_growth_pct,
    ROUND((total_expense - LAG(total_expense) OVER (ORDER BY year, month))
          / NULLIF(LAG(total_expense) OVER (ORDER BY year, month), 0) * 100, 2)      AS expense_mom_growth_pct,
    ROUND((net_profit - LAG(net_profit) OVER (ORDER BY year, month))
          / NULLIF(LAG(net_profit) OVER (ORDER BY year, month), 0) * 100, 2)         AS profit_mom_growth_pct
FROM monthly
ORDER BY year, month
GO

-- ================================================================================================
-- STEP 8: CUSTOMER ANALYSIS
-- ================================================================================================

-- ------------------------------------------------------------------------------------------------
-- 8.1 CUSTOMER COHORT ANALYSIS
-- Revenue by customer join year — which cohort contributes most
-- ------------------------------------------------------------------------------------------------

SELECT
    YEAR(c.join_date)                                       AS join_year,
    COUNT(DISTINCT c.customer_id)                           AS total_customers,
    COUNT(ft.transaction_id)                                AS total_transactions,
    ROUND(SUM(ft.amount), 2)                                AS total_revenue,
    ROUND(SUM(ft.amount) /
          NULLIF(COUNT(DISTINCT c.customer_id), 0), 2)      AS revenue_per_customer,
    ROUND(SUM(ft.amount) * 100 /
          NULLIF(SUM(SUM(ft.amount)) OVER (), 0), 2)        AS revenue_contribution_pct
FROM Financial_Transactions ft
JOIN Customers c ON ft.customer_id = c.customer_id
WHERE ft.account_type = 'Revenue'
GROUP BY YEAR(c.join_date)
ORDER BY join_year
GO

-- ------------------------------------------------------------------------------------------------
-- 8.2 CUSTOMER CONCENTRATION RISK
-- What % of revenue comes from top 10 customers
-- ------------------------------------------------------------------------------------------------

WITH customer_revenue AS (
    SELECT
        ft.customer_id,
        c.customer_name,
        ROUND(SUM(ft.amount), 2) AS total_revenue
    FROM Financial_Transactions ft
    JOIN Customers c ON ft.customer_id = c.customer_id
    WHERE ft.account_type = 'Revenue'
    GROUP BY ft.customer_id, c.customer_name
),
total AS (
    SELECT ROUND(SUM(total_revenue), 2) AS grand_total
    FROM customer_revenue
),
ranked AS (
    SELECT
        customer_id,
        customer_name,
        total_revenue,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM customer_revenue
)
SELECT
    r.revenue_rank,
    r.customer_id,
    r.customer_name,
    r.total_revenue,
    ROUND(r.total_revenue / NULLIF(t.grand_total, 0) * 100, 2)      AS revenue_pct,
    ROUND(SUM(r.total_revenue) OVER (ORDER BY r.revenue_rank) /
          NULLIF(t.grand_total, 0) * 100, 2)                         AS cumulative_pct
FROM ranked r
CROSS JOIN total t
WHERE r.revenue_rank <= 10
ORDER BY r.revenue_rank
GO

-- ------------------------------------------------------------------------------------------------
-- 8.3 CUSTOMER REVENUE RANKING WITHIN SEGMENT
-- ------------------------------------------------------------------------------------------------

WITH customer_revenue AS (
    SELECT
        ft.customer_id,
        c.customer_name,
        c.segment,
        c.region,
        c.status,
        COUNT(ft.transaction_id)         AS total_transactions,
        ROUND(SUM(ft.amount), 2)         AS total_revenue
    FROM Financial_Transactions ft
    JOIN Customers c ON ft.customer_id = c.customer_id
    WHERE ft.account_type = 'Revenue'
    GROUP BY ft.customer_id, c.customer_name, c.segment, c.region, c.status
)
SELECT
    customer_id,
    customer_name,
    segment,
    region,
    status,
    total_transactions,
    total_revenue,
    RANK() OVER (PARTITION BY segment ORDER BY total_revenue DESC) AS rank_within_segment
FROM customer_revenue
ORDER BY segment, rank_within_segment
GO

-- ================================================================================================
-- STEP 9: VENDOR ANALYSIS
-- ================================================================================================

-- ------------------------------------------------------------------------------------------------
-- 9.1 VENDOR SPEND BY CATEGORY
-- ------------------------------------------------------------------------------------------------

SELECT
    v.category,
    COUNT(DISTINCT ft.vendor_id)                            AS total_vendors,
    COUNT(ft.transaction_id)                                AS total_transactions,
    ROUND(SUM(ft.amount_abs), 2)                            AS total_spend,
    ROUND(AVG(ft.amount_abs), 2)                            AS avg_transaction_value,
    ROUND(SUM(ft.amount_abs) /
          NULLIF(COUNT(DISTINCT ft.vendor_id), 0), 2)       AS spend_per_vendor,
    ROUND(SUM(ft.amount_abs) * 100 /
          NULLIF(SUM(SUM(ft.amount_abs)) OVER (), 0), 2)    AS spend_contribution_pct
FROM Financial_Transactions ft
JOIN Vendors v ON ft.vendor_id = v.vendor_id
WHERE ft.account_type = 'Expense'
GROUP BY v.category
ORDER BY total_spend DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 9.2 VENDOR SPEND RANKING WITHIN CATEGORY
-- ------------------------------------------------------------------------------------------------

WITH vendor_spend AS (
    SELECT
        ft.vendor_id,
        v.vendor_name,
        v.category,
        v.region,
        v.active,
        COUNT(ft.transaction_id)         AS total_transactions,
        ROUND(SUM(ft.amount_abs), 2)     AS total_spend
    FROM Financial_Transactions ft
    JOIN Vendors v ON ft.vendor_id = v.vendor_id
    WHERE ft.account_type = 'Expense'
    GROUP BY ft.vendor_id, v.vendor_name, v.category, v.region, v.active
)
SELECT
    vendor_id,
    vendor_name,
    category,
    region,
    active,
    total_transactions,
    total_spend,
    RANK() OVER (PARTITION BY category ORDER BY total_spend DESC) AS rank_within_category
FROM vendor_spend
ORDER BY category, rank_within_category
GO

-- ------------------------------------------------------------------------------------------------
-- 9.3 VENDOR SPEND BY REGION
-- ------------------------------------------------------------------------------------------------

SELECT
    v.region,
    v.category,
    COUNT(DISTINCT ft.vendor_id)                            AS total_vendors,
    COUNT(ft.transaction_id)                                AS total_transactions,
    ROUND(SUM(ft.amount_abs), 2)                            AS total_spend,
    ROUND(AVG(ft.amount_abs), 2)                            AS avg_transaction_value,
    ROUND(SUM(ft.amount_abs) /
          NULLIF(COUNT(DISTINCT ft.vendor_id), 0), 2)       AS spend_per_vendor
FROM Financial_Transactions ft
JOIN Vendors v ON ft.vendor_id = v.vendor_id
WHERE ft.account_type = 'Expense'
GROUP BY v.region, v.category
ORDER BY total_spend DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 9.4 ACTIVE vs INACTIVE VENDOR ANALYSIS
-- ------------------------------------------------------------------------------------------------

SELECT
    v.active,
    COUNT(DISTINCT v.vendor_id)                             AS total_vendors,
    COUNT(ft.transaction_id)                                AS total_transactions,
    ROUND(SUM(ft.amount_abs), 2)                            AS total_spend,
    ROUND(AVG(ft.amount_abs), 2)                            AS avg_transaction_value,
    ROUND(SUM(ft.amount_abs) /
          NULLIF(COUNT(DISTINCT ft.vendor_id), 0), 2)       AS spend_per_vendor,
    ROUND(SUM(ft.amount_abs) * 100 /
          NULLIF(SUM(SUM(ft.amount_abs)) OVER (), 0), 2)    AS spend_contribution_pct
FROM Financial_Transactions ft
JOIN Vendors v ON ft.vendor_id = v.vendor_id
WHERE ft.account_type = 'Expense'
GROUP BY v.active
ORDER BY total_spend DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 9.5 VENDOR CONCENTRATION RISK
-- What % of total spend goes to top 10 vendors
-- ------------------------------------------------------------------------------------------------

WITH vendor_spend AS (
    SELECT
          ft.vendor_id,
          v.vendor_name,
          v.category,
          ROUND(SUM(ft.amount_abs), 2) AS total_spend
    FROM Financial_Transactions ft
    JOIN Vendors v ON ft.vendor_id = v.vendor_id
    WHERE ft.account_type = 'Expense'
    GROUP BY ft.vendor_id, v.vendor_name, v.category
),
total AS (
    SELECT ROUND(SUM(total_spend), 2) AS grand_total
    FROM vendor_spend
),
ranked AS (
    SELECT
          vendor_id,
          vendor_name,
          category,
          total_spend,
          RANK() OVER (ORDER BY total_spend DESC) AS spend_rank
    FROM vendor_spend
)
SELECT
      r.spend_rank,
      r.vendor_id,
      r.vendor_name,
      r.category,
      r.total_spend,
      ROUND(r.total_spend / NULLIF(t.grand_total, 0) * 100.0, 2)                        AS spend_pct,
      ROUND(SUM(r.total_spend) OVER (ORDER BY r.spend_rank) /
            NULLIF(t.grand_total, 0) * 100.0, 2)                                         AS cumulative_pct
FROM ranked r
CROSS JOIN total t
WHERE r.spend_rank <= 10
ORDER BY r.spend_rank
GO

-- ------------------------------------------------------------------------------------------------
-- 9.6 VENDOR SPEND BY BUSINESS UNIT
-- ------------------------------------------------------------------------------------------------

SELECT
    ft.business_unit,
    v.category,
    COUNT(DISTINCT ft.vendor_id)                            AS total_vendors,
    COUNT(ft.transaction_id)                                AS total_transactions,
    ROUND(SUM(ft.amount_abs), 2)                            AS total_spend,
    ROUND(AVG(ft.amount_abs), 2)                            AS avg_spend,
    ROUND(SUM(ft.amount_abs) * 100 /
          NULLIF(SUM(SUM(ft.amount_abs)) OVER (), 0), 2)    AS spend_contribution_pct
FROM Financial_Transactions ft
JOIN Vendors v ON ft.vendor_id = v.vendor_id
WHERE ft.account_type = 'Expense'
GROUP BY ft.business_unit, v.category
ORDER BY ft.business_unit, total_spend DESC
GO

-- ================================================================================================
-- STEP 10: HEADCOUNT & PRODUCTIVITY ANALYSIS
-- ================================================================================================

-- ------------------------------------------------------------------------------------------------
-- 10.1 REVENUE PER EMPLOYEE BY BUSINESS UNIT
-- ------------------------------------------------------------------------------------------------

WITH revenue_by_unit AS (
    SELECT
        business_unit,
        ROUND(SUM(CASE WHEN account_type = 'Revenue'
                       THEN amount ELSE 0 END), 2)          AS total_revenue
    FROM Financial_Transactions
    GROUP BY business_unit
),
headcount_by_unit AS (
    SELECT
        business_unit,
        COUNT(DISTINCT employee_id)                         AS total_employees,
        ROUND(SUM(cost_to_company), 2)                      AS total_ctc
    FROM Employees
    WHERE status = 'Active'
    GROUP BY business_unit
)
SELECT
    r.business_unit,
    r.total_revenue,
    h.total_employees,
    h.total_ctc,
    ROUND(r.total_revenue  / NULLIF(h.total_employees, 0), 2) AS revenue_per_employee,
    ROUND(h.total_ctc      / NULLIF(h.total_employees, 0), 2) AS cost_per_employee,
    ROUND(r.total_revenue  / NULLIF(h.total_ctc,        0), 2) AS revenue_to_cost_ratio
FROM revenue_by_unit r
LEFT JOIN headcount_by_unit h ON r.business_unit = h.business_unit
ORDER BY revenue_per_employee DESC
GO

-- ------------------------------------------------------------------------------------------------
-- 10.2 TOTAL WORKFORCE COST VS REVENUE
-- Overall company level productivity
-- ------------------------------------------------------------------------------------------------

WITH total_revenue AS (
    SELECT
        ROUND(SUM(CASE WHEN account_type = 'Revenue'
                       THEN amount ELSE 0 END), 2)          AS total_revenue,
        ROUND(SUM(CASE WHEN account_type = 'Expense'
                       THEN amount_abs ELSE 0 END), 2)      AS total_expense
    FROM Financial_Transactions
),
total_headcount AS (
    SELECT
        COUNT(DISTINCT employee_id)                         AS total_employees,
        ROUND(SUM(cost_to_company), 2)                      AS total_ctc
    FROM Employees
    WHERE status = 'Active'
)
SELECT
    r.total_revenue,
    r.total_expense,
    h.total_employees,
    h.total_ctc,
    ROUND(r.total_revenue / NULLIF(h.total_employees, 0), 2)        AS revenue_per_employee,
    ROUND(r.total_expense / NULLIF(h.total_employees, 0), 2)        AS expense_per_employee,
    ROUND(h.total_ctc     / NULLIF(h.total_employees, 0), 2)        AS avg_cost_per_employee,
    ROUND(h.total_ctc     / NULLIF(r.total_revenue,   0) * 100, 2)  AS ctc_as_pct_of_revenue,
    ROUND(h.total_ctc     / NULLIF(r.total_expense,   0) * 100, 2)  AS ctc_as_pct_of_expense
FROM total_revenue r
CROSS JOIN total_headcount h
GO

-- ------------------------------------------------------------------------------------------------
-- 10.3 CTC DISTRIBUTION BY TENURE BUCKET
-- Are longer serving employees paid more?
-- ------------------------------------------------------------------------------------------------

SELECT
    CASE
        WHEN DATEDIFF(YEAR, join_date, GETDATE()) < 1  THEN 'Less than 1 year'
        WHEN DATEDIFF(YEAR, join_date, GETDATE()) < 3  THEN '1 - 3 years'
        WHEN DATEDIFF(YEAR, join_date, GETDATE()) < 5  THEN '3 - 5 years'
        ELSE '5+ years'
    END                                                     AS tenure_bucket,
    COUNT(DISTINCT employee_id)                             AS total_employees,
    ROUND(AVG(cost_to_company), 2)                          AS avg_ctc,
    ROUND(MIN(cost_to_company), 2)                          AS min_ctc,
    ROUND(MAX(cost_to_company), 2)                          AS max_ctc,
    ROUND(SUM(cost_to_company), 2)                          AS total_ctc
FROM Employees
WHERE status = 'Active'
GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, join_date, GETDATE()) < 1  THEN 'Less than 1 year'
        WHEN DATEDIFF(YEAR, join_date, GETDATE()) < 3  THEN '1 - 3 years'
        WHEN DATEDIFF(YEAR, join_date, GETDATE()) < 5  THEN '3 - 5 years'
        ELSE '5+ years'
    END
ORDER BY avg_ctc DESC
GO

-- ================================================================================================
--                              END OF ANALYSIS
-- ================================================================================================
