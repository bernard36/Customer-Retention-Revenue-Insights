/* 
	File: 05_load_facts.sql
	Purpose: Insert data into the facts table from the dimension tables
*/

-- Combine clean.orders and clean.order_items into a temp table to get 


-- Insert into analytics.fact_orders
-- Join customer Id from dim_customer with order_id from clean.orders and dim_order_status for order_status
INSERT INTO analytics.facts_orders (customer_id , order_id , purchase_date , purchase_time, order_status)
SELECT	c.id, o.order_id, d.date_sk, o.order_purchase_time, s.id
FROM clean.orders o
JOIN analytics.dim_customers c
	ON o.customer_id = c.customer_id
JOIN analytics.dim_date d
	ON d.full_date = o.order_purchase_date
JOIN analytics.dim_order_status s
	ON o.order_status = s.name



-- Insert into analytics.facts_order_items
-- Join the order_facts table for order_id and product_dim for product id and seller id foreign key
INSERT INTO analytics.facts_order_items (order_id , product_id , seller_id)
SELECT f.id, p.id, p.seller_id
FROM clean.order_items c
LEFT JOIN analytics.facts_orders f
	ON c.order_id = f.order_id
LEFT JOIN analytics.dim_products p
	ON c.product_id = p.product_id
LEFT JOIN analytics.dim_seller s
	ON c.seller_id = s.seller_id




-- Insert into analytics.facts_payments


-- Create a temp table to store payment sequence 
-- If more there's more than 1 occurance of an order_id and the payment value > 0: this payment is an installment
-- If there's only one occurance of an order_id and the payment value > 0: this is a full payment
-- If a payment value is <= 0 this is a failed payment
WITH payment_count AS (
	SELECT DISTINCT order_id, payment_sequential, payment_installments, payment_value, payment_type,
		ROW_NUMBER () OVER (PARTITION BY order_id ORDER BY (SELECT NULL)) payment_count
	FROM clean.order_payments
)
SELECT order_id, payment_sequential, payment_installments, payment_value, payment_type,  
	CASE 
		WHEN payment_count >= 1 AND payment_value <= 0 THEN 'failed'
		WHEN payment_count >= 1 AND payment_value > 0 AND payment_sequential >= 1 AND COUNT(order_id) OVER (PARTITION BY order_id) > 1 THEN 'installment'
		WHEN COUNT(*) OVER (PARTITION BY order_id) = 1 THEN 'full'
		ELSE NULL
	END AS payment_method
INTO #payment_type
FROM payment_count


--  Insert into facts_payments
-- Join the clean.order_payment and the fact_order and the dim_payment_method and the dim_payment_type
INSERT INTO analytics.facts_payments (order_id , payment_installment , payment_method , payment_sequential , payment_value, payment_type)
SELECT DISTINCT	f.id, p.payment_installments, pm.id, p.payment_sequential, p.payment_value, apt.payment_type_sk
FROM clean.order_payments p
JOIN analytics.facts_orders f
	ON p.order_id = f.order_id
JOIN analytics.dim_payments_method pm
	ON pm.payment_method = p.payment_type
JOIN #payment_type pt
	ON p.order_id = pt.order_id
	AND pt.payment_sequential = p.payment_sequential
	AND pt.payment_installments = p.payment_installments
	AND pt.payment_value = p.payment_value
	AND pt.payment_type = p.payment_type
JOIN analytics.dim_payment_type apt
	ON pt.payment_method = apt.payment_type_sk 

	



-- INSERT into Fact_shipments
-- JOIN	clean.order_items table with facts_orders and clean.orders
INSERT INTO analytics.facts_shipments (freight_value, order_id , shipping_limit_date , shipping_limit_time)
SELECT c.freight_value, o.id, d.date_sk, c.shipping_limit_time  
FROM clean.order_items c
LEFT JOIN analytics.facts_orders o
	ON c.order_id = o.order_id
LEFT JOIN analytics.dim_date d
	ON c.shipping_limit_date = d.full_date



-- INSERT into facts_delivery
-- JOIN	clean.orders and fact_orders and dim_date
INSERT INTO analytics.facts_delivery(delivered_date, order_id, delivered_time)
SELECT d.date_sk, o.id, c.order_delivered_time
FROM clean.orders c
LEFT JOIN analytics.facts_orders o
	ON c.order_id = o.order_id
LEFT JOIN analytics.dim_date d
	ON c.order_delivered_customer_date = d.full_date




-- Insert facts_reviews 
-- join with clean.order_reviews and facts_orders
INSERT INTO analytics.facts_order_reviews (order_id , review_creation_date , review_creation_time , review_id , score)
SELECT f.id, d.date_sk, c.review_creation_time, c.review_id, c.review_score
FROM clean.order_reviews c
LEFT JOIN analytics.facts_orders f
	ON c.order_id = f.order_id
LEFT JOIN analytics.dim_date d
	ON c.review_creation_date = d.full_date


-- Inspect facts_orders
SELECT TOP(10) * 
FROM analytics.facts_orders

-- Inspect facts_order_items
SELECT TOP(10) * 
FROM analytics.facts_order_items

-- Inspect facts_payments
SELECT TOP(10) * 
FROM analytics.facts_payments

-- Inspect facts_shipments
SELECT TOP(10) * 
FROM analytics.facts_shipments

-- Inspect facts_delivery
SELECT TOP(10) * 
FROM analytics.facts_delivery

-- Inspect facts_order_reviews
SELECT TOP(10) * 
FROM analytics.facts_order_reviews