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
-- Join the fact_order table for order id and join the clean.order_payment for payment_installment, payment_sequential and payment_value and join dim_payment for payment_method
INSERT INTO analytics.facts_payments (order_id , payment_installment , payment_method , payment_sequential , payment_value)
SELECT	f.id, p.payment_installments, pm.id, p.payment_sequential, p.payment_value
FROM clean.order_payments p
JOIN analytics.facts_orders f
	ON p.order_id = f.order_id
JOIN analytics.dim_payments_method pm
	ON pm.payment_method = p.payment_type
