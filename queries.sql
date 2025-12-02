-- Retail Analytics Queries

-- 1. Monthly Revenue
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       SUM(oi.quantity * oi.price) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

-- 2. Quarterly Revenue
SELECT YEAR(order_date) AS year,
       QUARTER(order_date) AS quarter,
       SUM(oi.quantity * oi.price) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY year, quarter
ORDER BY year, quarter;

-- 3. Profit by Category
SELECT p.category,
       SUM(oi.quantity * (oi.price - p.cost_price)) AS total_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_profit DESC;

-- 4. Top Regions by Revenue
SELECT o.region,
       SUM(oi.quantity * oi.price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.region
ORDER BY revenue DESC;

-- 5. RFM segmentation (example reference date '2025-02-01')
WITH rfm AS (
  SELECT
    c.customer_id,
    MAX(o.order_date) AS last_order_date,
    COUNT(DISTINCT o.order_id) AS frequency,
    SUM(oi.quantity * oi.price) AS monetary
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY c.customer_id
)
SELECT
  customer_id,
  DATEDIFF('2025-02-01', last_order_date) AS recency,
  frequency,
  monetary
FROM rfm
ORDER BY monetary DESC;

-- 6. Top Products by Revenue
SELECT p.product_id, p.product_name, SUM(oi.quantity * oi.price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;

-- 7. Average Order Value (AOV)
SELECT AVG(order_total) AS avg_order_value FROM (
  SELECT o.order_id, SUM(oi.quantity * oi.price) AS order_total
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY o.order_id
) t;

-- 8. Customer Lifetime Value (simple cumulative monetary)
SELECT c.customer_id, c.name, SUM(oi.quantity * oi.price) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name
ORDER BY lifetime_value DESC;

-- 9. Cohort (by month of first order) - requires additional fields; sample approach
-- 10. Cancellation / return rate - requires returns table (not included)