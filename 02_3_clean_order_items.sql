SELECT TOP(100) *
FROM staging.order_items

-- Transfer to clean schema (trim and datatype)
SELECT 
	LTRIM(RTRIM(order_id)) AS order_id,
	TRY_CAST(LTRIM(RTRIM(order_item_id)) AS INT) order_item_id,
	LTRIM(RTRIM(product_id)) AS product_id,
	LTRIM(RTRIM(seller_id)) AS seller_id,
	TRY_CAST(LTRIM(RTRIM(shipping_limit_date)) AS DATETIME2) AS shipping_limit_date,
	TRY_CAST(LTRIM(RTRIM(price)) AS DECIMAL(10,2)) AS price,
	TRY_CAST(LTRIM(RTRIM(freight_value)) AS DECIMAL(10,2)) AS freight_value
INTO clean.order_items
FROM staging.order_items


-- Null values
DECLARE @sql NVARCHAR(MAX)
SELECT @sql = 
 'SELECT * 
  FROM [clean].[order_items] 
  WHERE ' + STRING_AGG( '[' + COLUMN_NAME + '] IS NULL ', ' OR ')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'order_items' AND TABLE_SCHEMA = 'clean'
PRINT @sql
EXEC sp_executesql @sql

-- No nulls

-- Standardise (seperate date and time columns)
-- Add shipping_limit_time
ALTER TABLE clean.order_items
ADD shipping_limit_time TIME(0)

-- Update table
UPDATE clean.order_items
SET shipping_limit_time = CAST(shipping_limit_date AS TIME(0)),
	shipping_limit_date = CAST(shipping_limit_date AS DATE)

ALTER TABLE clean.order_items
ALTER COLUMN shipping_limit_date DATE






