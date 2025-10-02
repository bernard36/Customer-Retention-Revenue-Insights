/* 
	File: 03_2_create_facts_tables.sql
	Purpose: Biuld Facts table 

	Facts:
		fact_order,
		fact_order_items,
		fact_payments,
		fact_shipments,
		facts_delivery,
		fact_review

*/

-- FACT TABLE

-- Create facts_order
-- Stores all order at the customer level 
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'fact_orders' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.facts_orders (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
		order_id NVARCHAR(300), -- Natural Key
		customer_id INT FOREIGN KEY REFERENCES analytics.dim_customers(id), -- Foreign Key for customer dimension
		purchase_date INT FOREIGN KEY REFERENCES analytics.dim_date(date_sk), -- Foreign key for date_dimension
		purchase_time TIME(0), -- Time of purchase
		order_status INT FOREIGN KEY REFERENCES analytics.dim_delivery_status(id) -- Foreign key to connect dim_delivery_status 
	)
END



-- Create analytics.facts_order_items
-- Stores all orders at the product level. See each items per order
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'facts_order_items' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.facts_order_items (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Primary key of all items per order
		order_id INT FOREIGN KEY REFERENCES analytics.facts_orders(id), -- Foreign key of order_id from fact's table
		product_id INT FOREIGN KEY REFERENCES analytics.dim_products(id), -- Foreign key for dimension products
		seller_id INT FOREIGN KEY REFERENCES analytics.dim_seller(id), -- Foreign key for dimension seller
	)
END


-- Create analytics.facts_payments
-- Stores all payments at the order level
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'facts_payments' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.facts_payments (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate key
		order_id INT FOREIGN KEY REFERENCES analytics.facts_orders(id), -- Foreign key to connect to facts_orders
		payment_method INT FOREIGN KEY REFERENCES analytics.dim_payments_method(id), -- Foreign key to connect dimension payment_method table
		payment_sequential INT,
		payment_installment INT,
		payment_type NVARCHAR(150) FOREIGN KEY REFERENCES analytics.dim_payment_type(payment_type_sk), -- Foreign key to connect dimension payment type table
		payment_value DECIMAL(10,2)
	)
END




-- Create analytics.facts_shipments
-- Stores all shipments at the order level
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'facts_shipments' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.facts_shipments (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate key
		order_id INT FOREIGN KEY REFERENCES analytics.facts_orders(id), -- Foreign key to connect to facts_orders
		shipping_limit_date INT FOREIGN KEY REFERENCES analytics.dim_date(date_sk), -- Foreign key to connect dim_dates
		shipping_limit_time TIME(0),
		freight_value DECIMAL(10,2) 
	)
END


-- Create facts_delivery
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = 'analytics' AND TABLE_NAME = 'facts_delivery'
)
BEGIN
	CREATE TABLE analytics.facts_delivery (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate key
		order_id INT FOREIGN KEY REFERENCES analytics.facts_orders(id), -- Foreign key to connect to facts_orders
		delivered_date INT FOREIGN KEY REFERENCES analytics.dim_date(date_sk),  -- Foreign key to connect dim_dates
		delivered_time TIME(0)
	)
END


-- Create analytics.facts_reviews
-- Stores all reviews at the order level
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'facts_reviews' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.facts_order_reviews (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate key
		order_id INT FOREIGN KEY REFERENCES analytics.facts_orders(id), -- Foreign key to connect to facts_orders
		review_id NVARCHAR(300), -- Natural Key
		score INT,
		review_creation_date INT FOREIGN KEY REFERENCES analytics.dim_date(date_sk), -- Foreign Key to connect dim_dates
		review_creation_time TIME (0)
	)
END


