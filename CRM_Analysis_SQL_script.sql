-- Top 10 accounts by revenue
SELECT TOP 10
  a.account,
  a.sector,
  a.office_location,
  a.revenue
FROM CRManalysis_DB.dbo.accounts a
ORDER BY revenue DESC;


-- Sales performance metrics per sales agent
SELECT
  s.sales_agent,
  COALESCE(st.manager, 'Unknown') AS manager,
  COALESCE(st.regional_office, 'Unknown') AS regional_office,
  COUNT(1) AS deals_count,
  SUM(s.close_value) AS total_revenue,
  ROUND(AVG(s.close_value),2) AS avg_deal_value,
  SUM(CASE WHEN s.deal_stage = 'Won' THEN 1 ELSE 0 END) AS wins,
  SUM(CASE WHEN s.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS losses,
  ROUND(
    100.0 *
    SUM(CASE WHEN s.deal_stage = 'Won' THEN 1 ELSE 0 END) /
    NULLIF(COUNT(1),0),
    2
  ) AS win_rate_percent
FROM CRManalysis_DB.dbo.salestransaction s
LEFT JOIN CRManalysis_DB.dbo.salesteam st
  ON s.sales_agent = st.sales_agent
GROUP BY s.sales_agent, st.manager, st.regional_office
ORDER BY total_revenue DESC;


-- Revenue by product and series (top products)
SELECT
  p.series,
  p.product,
  COUNT(1) AS deals_count,
  SUM(s.close_value) AS total_revenue,
  ROUND(AVG(s.close_value),2) AS avg_deal_value
FROM CRManalysis_DB.dbo.salestransaction s
JOIN CRManalysis_DB.dbo.products p
  ON s.product = p.product
GROUP BY p.series, p.product
ORDER BY total_revenue DESC;


-- Monthly revenue trend (year-month)
SELECT
  YEAR(close_date) AS year,
  MONTH(close_date) AS month,
  CONCAT(CAST(YEAR(close_date) AS VARCHAR(4)), '-', RIGHT('00' + CAST(MONTH(close_date) AS VARCHAR(2)), 2)) AS year_month,
  COUNT(1) AS deals_count,
  SUM(close_value) AS total_revenue,
  ROUND(AVG(close_value),2) AS avg_deal_value
FROM CRManalysis_DB.dbo.salestransaction
WHERE close_date IS NOT NULL
GROUP BY YEAR(close_date), MONTH(close_date)
ORDER BY YEAR(close_date), MONTH(close_date);
