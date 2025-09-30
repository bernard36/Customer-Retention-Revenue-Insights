/* 
	File: 03_2_create_facts_tables.sql
	Purpose: Biuld Facts table 

	Facts:
		fact_order,
		fact_order_items,
		fact_payments,
		fact_shipments

*/

-- FACT TABLE

IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'fact_orders' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.facts_orders (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
		order_id INT, -- Natural Key
		customer_id INT FOREIGN KEY REFERENCES analytics.dim_customers(id), -- Foreign Key for customer dimension
		product_id INT FOREIGN KEY REFERENCES analytics.dim_products(id), -- Foreign Key for product dimension
		delivery_status_id INT FOREIGN KEY REFERENCES analytics.dim_delivery_status(id), -- Foreign Key for delivery_status dimension
		payment_method INT FOREIGN KEY REFERENCES analytics.dim_payments_method(id), -- Foreign Key for payment method dimension
		purchase_date DATE, -- Date of purchase
		purchase_time TIME(0), -- Time of purchase
		payment_sequential INT, -- Payment sequential
		payment_installments INT, -- Payment Installment
		delivery_amount DECIMAL(10,2), -- Delivery amount
		delivery_date DATE, -- Delivery date
		delivery_time TIME(0), -- Delivery time
		total_payment DECIMAL(10,2), -- Total Payment
		order_review_score INT -- order_review_score
	)
END



-- Create analytics.facts_order_item
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'facts_order_items' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 

END


-- Create analytics.facts_payments
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'facts_payments' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 

END


-- Create analytics.facts_shipments
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'facts_shipments' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 

END


