/* 
	File: 03_Dimension_build.sql
	Purpose: Biuld dimension tables with surrogate keys
	Dimensions: 
		dim_customers,
		dim_sellers,
		dim_geolocation,
		dim_products,
		dim_order_review,
		dim_payments,
		dim_orders_status

*/

-- Create analytics schema
CREATE SCHEMA analytics

SELECT TOP(10) *
FROM clean.customers

-- Create dim_customers
IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'dim_customers' AND TABLE_SCHEMA = 'analytics'
)
BEGIN 
	CREATE TABLE analytics.dim_customers (
		customer_id INT IDENTITY(1,1) PRIMARY KEY, -- Customer ID surrogate key
		customer_natural_key INT,                  -- Natural Key: original customer unique ID from customer dataset

	)
END;
 
	


