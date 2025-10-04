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



-- Payment method performance
-- Show which payment methods are most used, and how reliable they are. 
-- 1. checks the total amount of transaction which each payment method and
-- 2. check the total amount payed for each payment method and checks the success rate of each payment method
CREATE VIEW analytics.vw_payment_method_performance AS
SELECT pm.payment_method, 
	   SUM (p.payment_value) AS total_payment,
	   COUNT(p.order_id) AS total_transactions,
	   SUM (CASE WHEN pt.is_success = 1 THEN 1 ELSE 0 END) AS successful_payments,
	   CAST((SUM (CASE WHEN pt.is_success = 1 THEN 1 ELSE 0 END) / COUNT(order_id)) AS DECIMAL(10,2)) AS successful_rate
FROM analytics.facts_payments p
LEFT JOIN analytics.dim_payments_method pm
	ON p.payment_method = pm.id
LEFT JOIN analytics.dim_payment_type pt
	ON p.payment_type = pt.payment_type_sk
GROUP BY pm.payment_method


-- Delivery Performance
-- Track delivery speed & reliability.
-- Calculates the number of days it takes for delivery, from purchase date to delivery date, and see each purchase date and delivery date and frieght value
CREATE VIEW analytics.vw_delivery_performance AS 
SELECT o.order_id,
	   d1.full_date AS purchase_date,
	   d2.full_date AS delivery_date,
	   DATEDIFF(DAY, d1.full_date, d2.full_date) AS delivery_days,
	   sh.freight_value,
	   os.name AS order_status
FROM analytics.facts_delivery d
LEFT JOIN analytics.facts_orders o
	ON d.order_id = o.id
LEFT JOIN analytics.facts_shipments sh
	ON d.order_id = sh.order_id
LEFT JOIN analytics.dim_order_status os
	ON o.order_status = os.id
LEFT JOIN analytics.dim_date d1
	ON o.purchase_date = d1.date_sk
LEFT JOIN analytics.dim_date d2
	ON d.delivered_date = d2.date_sk





-- Product & Category Performance
-- Analyze which products and categories bring the most sales.
-- Analyze hieghest and lowest review for each product per category, see total_revenue and number of orders per product
CREATE VIEW analytics.vw_product_and_category_performance AS 
SELECT	pc.name AS product_category,
		p.product_id AS product_id,
		COUNT(p.product_id) AS number_of_items,
		SUM(p.price) AS total_revenue,
		MIN(r.score) AS lowest_review_score,
		MAX(r.score) AS hieghest_review_score,
		AVG(r.score) AS average_review_score
FROM analytics.facts_order_items oi
LEFT JOIN analytics.dim_products p
	ON oi.product_id = p.id
LEFT JOIN analytics.facts_order_reviews r
	ON oi.order_id = r.order_id
LEFT JOIN analytics.dim_product_category pc
	ON p.category_id = pc.id
GROUP BY pc.name, p.product_id





