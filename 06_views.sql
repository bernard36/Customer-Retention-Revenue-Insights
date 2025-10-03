/* 
	File: 06_views.sql
	Purpose: Create analytical views for further analysis
*/

-- Summary of customers, products, payments, regions, and dates
CREATE VIEW analytics.vw_order_summary AS 
SELECT o.order_id,
	   c.customer_id,
	   r.city,
	   r.state,
	   d.month_name AS month,
	   d.year AS year,
	   os.name AS order_status,
	   SUM(p.price) AS total_payment,
	   SUM(sh.freight_value) AS total_freight

FROM analytics.facts_order_items oi
LEFT JOIN analytics.facts_orders o ON oi.order_id = o.id
LEFT JOIN analytics.dim_customers c ON o.customer_id = c.id
LEFT JOIN analytics.dim_geolocation g ON c.geolocation_id = g.id
LEFT JOIN analytics.dim_region r ON g.region_id = r.id
LEFT JOIN analytics.dim_products p ON oi.product_id = p.id
LEFT JOIN analytics.dim_seller s ON p.seller_id = s.id
LEFT JOIN analytics.dim_date d ON o.purchase_date = d.date_sk
LEFT JOIN analytics.dim_order_status os ON o.order_status = os.id
LEFT JOIN analytics.facts_shipments sh ON o.id = sh.order_id
GROUP BY o.order_id, c.customer_id, r.city, r.state, d.month_name, d.year, os.name

SELECT TOP(10) *
FROM analytics.vw_order_summary

-- Customer Retention & Revenue Insights
-- Track how often customers return and how much revenue they bring
-- Check unique customer order count and their first and last purchase date and average order amount and total_price
CREATE VIEW analytics.vw_customer_retention AS 
SELECT 
	c.customer_id, 
	COUNT(o.order_id ) AS total_orders,
	MIN (d.full_date) AS first_purchase,
	MAX (d.full_date) AS last_purchase,
	SUM(p.payment_value) AS lifetime_value,
	CAST(AVG(p.payment_value) AS DECIMAL (10,2)) AS avg_order_value

FROM analytics.facts_order_items oi
LEFT JOIN analytics.facts_orders o
	ON oi.order_id = o.id
LEFT JOIN analytics.dim_customers c
	ON o.customer_id = c.id
LEFT JOIN analytics.dim_date d
	ON o.purchase_date = d.date_sk
LEFT JOIN analytics.facts_payments p
	ON o.id = p.order_id
GROUP BY c.customer_id

SELECT TOP(100) *
FROM analytics.vw_customer_retention
WHERE total_orders > 1


