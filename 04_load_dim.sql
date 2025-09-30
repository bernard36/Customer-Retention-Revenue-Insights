/* 
	File: 04_load_dim.sql
	Purpose: Insert data into the dim table from the clean schema
*/


SELECT TOP(10) *
FROM clean.geolocation

-- INSERT into analytics.dim_region
-- insert city and state from clean.geolocation into region dimension
INSERT INTO analytics.dim_region (city, state)
SELECT DISTINCT geolocation_city, geolocation_state_full
FROM clean.geolocation



-- INSERT into analytics.dim_geolocation
-- insert long, lat, region_id, zip_prefix into dim geolocation, region_id as foreing key from region_dimension, joining based on city and state from the region dimension table with the clean.geolocation table
INSERT INTO analytics.dim_geolocation (latitude, longitude, region_id, zip_prefix)
SELECT DISTINCT g.geolocation_lat, g.geolocation_lng, r.id, g.geolocation_zip_prefix
FROM clean.geolocation g
JOIN analytics.dim_region r
	ON g.geolocation_city = r.city AND g.geolocation_state_full = r.state



-- INSERT into analytics.customers

-- Combine goelocation and region table into a temporary table for easy join into customer dimension
SELECT g.id geolocation_id, g.zip_prefix, r.city, r.state
INTO #region_geolocation
FROM analytics.dim_region r
JOIN analytics.dim_geolocation g
	ON g.region_id = r.id

-- Remove duplicate from temp table
WITH Duplicate AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY zip_prefix,city,state
			  ORDER BY (SELECT NULL)) AS occurance
	FROM #region_geolocation
)
DELETE FROM Duplicate WHERE occurance > 1


-- insert into the customer dimension with the tempo region_geolocation 
INSERT INTO analytics.dim_customers(customer_id,geolocation_id)
SELECT DISTINCT c.customer_unique_id, g.geolocation_id
FROM clean.customers c
LEFT JOIN #region_geolocation g
	ON c.customer_city = g.city 
	AND c.customer_state_full = g.state
	AND c.zip_prefix = g.zip_prefix
	




-- INSERT into dim_seller
-- insert into dim_seller with the temp table region_geolocation
INSERT INTO analytics.dim_seller (seller_id, geolocation_id)
SELECT DISTINCT c.seller_id, g.geolocation_id
FROM clean.sellers c
LEFT JOIN #region_geolocation g
	ON c.seller_zip_prefix = g.zip_prefix 
	AND c.seller_state_full = g.state
	AND c.seller_city = g.city


-- INSERT into dim_product_category
-- inserted the products category name from the clean.products table
INSERT INTO analytics.dim_product_category (name)
SELECT DISTINCT category_name_english
FROM clean.products



-- INSERT into dim_products
-- insert into dim_products, joining seller_dim with clean.order_items and dim_category_name, to get product_id, price, seller_id and category_id
INSERT INTO analytics.dim_products (product_id,category_id,seller_id, price,height_cm,length_cm,widtht_cm,weight_g)
SELECT DISTINCT c.product_id, cn.id, s.id, c.price, p.product_height_cm, p.product_length_cm, p.product_width_cm, p.product_weight_g
FROM clean.order_items c
LEFT JOIN analytics.dim_seller s
	ON c.seller_id = s.seller_id
LEFT JOIN clean.products p
	ON c.product_id = p.product_id
LEFT JOIN analytics.dim_product_category cn
	ON c.category_name_english = cn.name



SELECT *
FROM analytics.dim_products

-- INSERT into analytics.delivery_status
-- from clean.orders.status
INSERT INTO analytics.dim_delivery_status (name)
SELECT DISTINCT order_status
FROM clean.orders



-- INSERT into dim_payments
SELECT *
FROM clean.order_payments
WHERE payment_installments = 0

