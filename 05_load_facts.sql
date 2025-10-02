/* 
	File: 05_load_facts.sql
	Purpose: Insert data into the facts table from the dimension tables
*/

-- Combine clean.orders and clean.order_items into a temp table to get 


-- Insert into analytics.fact_orders
-- Join customer Id from dim_customer with order_id from clean.orders 
INSERT INTO analytics.facts_orders (customer_id , order_id , purchase_date , purchase_time)
SELECT	c.id, o.order_id, d.date_sk, o.order_purchase_time
FROM clean.orders o
JOIN analytics.dim_customers c
	ON o.customer_id = c.customer_id
JOIN analytics.dim_date d
	ON d.full_date = o.order_purchase_date


-- Insert into analytics.facts_order_items
-- Join the order_facts table for order_id and product_dim for product id and seller id foreign key
INSERT INTO analytics.facts_order_items (order_id , product_id , seller_id)
SELECT f.id, p.id, p.seller_id
FROM clean.order_items c
JOIN analytics.facts_orders f
	ON f.order_id = c.order_id
JOIN analytics.dim_products p
	ON c.product_id = p.product_id


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







