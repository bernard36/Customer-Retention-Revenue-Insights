/* 
	File: 03_Dimension_build.sql
	Purpose: Biuld dimension tables with surrogate keys
	Dimensions: 
		dim_customers,
		dim_sellers,
		dim_geolocation,
		dim_products,
		dim_products_category,
		dim_delivery_status,
		dim_order_review,
		dim_payments

*/

-- Create analytics schema: schema to hold all the facts and dimension tables
CREATE SCHEMA analytics



SELECT TOP(10) *
FROM clean.customers

-- Create dim_customers
IF NOT EXISTS ( -- Check if table exists before creating
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_customers' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.dim_customers (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Customer ID surrogate key
		customer_id INT,                  -- Natural Key

	)
END;



-- Create dim_seller
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_seller' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.dim_seller (
			id INT IDENTITY (1,1) PRIMARY KEY, -- Surrogate Key
			seller_id INT					  -- Natural Key
	)
	
END




-- Create dim_geolocation
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_geolocation' AND TABLE_SCHEMA = 'analytics'
)
BEGIN
	CREATE TABLE analytics.dim_geolocation (
		id  INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
		zip_prefix INT, 
		latitude DECIMAL(10,6),
		longitude DECIMAL(10,6),
		city NVARCHAR(150),
		state NVARCHAR(150)

	)
END




-- Create dim_products
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_products' AND TABLE_SCHEMA = 'analytics'
)
BEGIN
	CREATE TABLE analytics.dim_products (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
		product_id INT, -- Natural Key
		weight_g INT,
		length_cm INT,
		height_cm INT,
		widtht_cm INT

	)
END



-- Create dim_product_category
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_product_category' AND TABLE_SCHEMA = 'analytics'

)
BEGIN 
	CREATE TABLE analytics.dim_product_category (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
		name NVARCHAR(200)
	)
END



-- Create dim_delivery_status
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_delivery_status' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.dim_delivery_status (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate key
		status NVARCHAR(100),
		delivery_date DATE,
		delivery_time TIME(0)
	)
END


-- Create dim_order_review
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_order_review' AND TABLE_SCHEMA = 'analytics'
)
BEGIN
	CREATE TABLE dim_order_review (
		id INT IDENTITY (1,1) PRIMARY KEY, -- Surrogate Key
		review_id INT, -- Natural Key
		score INT,
		creation_date DATE,
		creation_time TIME(0)
	)
END


-- Create dim_payments
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_payments' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.dim_payments (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
		payment_sequential INT,
		payment_type NVARCHAR(100),
		payment_installments INT,
		amount INT
	)
END