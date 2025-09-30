/* 
	File: 03_Dimension_build.sql
	Purpose: Biuld dimensions and facts tables
	Facts:
		fact_orders

	Dimensions: 
		dim_region,
		dim_geolocation,
		dim_customers,
		dim_sellers,
		dim_products_category,
		dim_products,
		dim_delivery_status,
		dim_payments_method

*/

-- Create analytics schema: schema to hold all the facts and dimension tables
CREATE SCHEMA analytics

-- Create dim_region
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_region' AND TABLE_SCHEMA = 'analytics'

)
BEGIN
	CREATE TABLE analytics.dim_region (
		id INT IDENTITY (1,1) PRIMARY KEY, -- Surrogate Key
		city NVARCHAR(200), 
		state NVARCHAR(150)
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

	)
END

-- Add region forein key to geolocation dimension
ALTER TABLE analytics.dim_geolocation
ADD region_id INT FOREIGN KEY REFERENCES analytics.dim_region(id)



-- Create dim_customers
IF NOT EXISTS ( -- Check if table exists before creating
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_customers' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.dim_customers (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Customer ID surrogate key
		customer_id NVARCHAR(300),                  -- Natural Key
		

	)
END


-- Add geolocation_id foreign key to customer dimension
ALTER TABLE analytics.dim_customers
ADD geolocation_id INT FOREIGN KEY REFERENCES analytics.dim_geolocation(id)  -- Foreign Key for geolocation




-- Create dim_seller
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_seller' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.dim_seller (
			id INT IDENTITY (1,1) PRIMARY KEY, -- Surrogate Key
			seller_id NVARCHAR(300),					  -- Natural Key
			 
	)
	
END

-- Add foreign key of geolocation to seller dimension
ALTER TABLE analytics.dim_seller
ADD geolocation_id INT FOREIGN KEY REFERENCES analytics.dim_geolocation(id) -- Foreign key for geolocation




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

-- Create dim_products
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_products' AND TABLE_SCHEMA = 'analytics'
)
BEGIN
	CREATE TABLE analytics.dim_products (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
		product_id NVARCHAR(300), -- Natural Key
		price DECIMAL(10,2),
		weight_g INT,
		length_cm INT,
		height_cm INT,
		widtht_cm INT

	)
END



-- Update product dim by adding seller id foreign key
ALTER TABLE analytics.dim_products
ADD seller_id INT FOREIGN KEY REFERENCES analytics.dim_seller(id)

-- Update product dim by adding category id foreign key
ALTER TABLE analytics.dim_products
ADD category_id INT FOREIGN KEY REFERENCES analytics.dim_product_category(id)


-- Create dim_delivery_status
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_delivery_status' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.dim_delivery_status (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate key
		name NVARCHAR(100)
		
	)
END


-- Create dim_payments_method
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_payments' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.dim_payments_method (
		id INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
		payment_method NVARCHAR(200)
	)
END











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



