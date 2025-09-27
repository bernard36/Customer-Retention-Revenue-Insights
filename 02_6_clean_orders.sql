SELECT TOP(10) *
FROM staging.orders

-- Transfer to clean schema (Trim and cast)
SELECT 
	LTRIM(RTRIM(order_id)) AS order_id,
	LTRIM(RTRIM(customer_id)) AS customer_id,
	LTRIM(RTRIM(order_status)) AS order_status,
	TRY_CAST(LTRIM(RTRIM(order_purchase_timestamp)) AS DATETIME2) AS order_purchase_date,
	TRY_CAST(LTRIM(RTRIM(order_approved_at)) AS DATETIME2) AS order_approved_at,
	TRY_CAST(LTRIM(RTRIM(order_delivered_carrier_date)) AS DATETIME2) AS order_delivered_carrier_date,
	TRY_CAST(LTRIM(RTRIM(order_delivered_customer_date)) AS DATETIME2) AS order_delivered_customer_date,
	TRY_CAST(LTRIM(RTRIM(order_estimated_delivery_date)) AS DATETIME2) AS order_estimated_delivery_date
INTO clean.orders
FROM staging.orders

-- Drop not needed columns
ALTER TABLE clean.orders
DROP COLUMN order_approved_at, order_delivered_carrier_date, order_estimated_delivery_date

-- Add Derived columns 'order_purchase_time' and 'order_delivered_time'
ALTER TABLE clean.orders
ADD order_purchase_time TIME(0),
	order_delivered_time TIME(0)

-- Populate columns
UPDATE clean.orders
SET order_purchase_time = TRY_CAST(order_purchase_date AS TIME(0)),
	order_delivered_time = TRY_CAST(order_delivered_customer_date AS TIME(0))


-- Change column dates to date only
ALTER TABLE clean.orders
ALTER COLUMN order_purchase_date DATE

ALTER TABLE clean.orders
ALTER COLUMN order_delivered_customer_date DATE
			 

-- Check for nulls
DECLARE @sql NVARCHAR(MAX)

SELECT @sql = 
	' SELECT * 
	  FROM [clean].[orders]
	  WHERE ' + STRING_AGG('[' + COLUMN_NAME + '] IS NULL', ' OR ')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders' AND TABLE_SCHEMA = 'clean'
EXEC sp_executesql @sql

-- Only existing nulls are in delivery date and delivery time. Will leave it in and filter during analysis

-- Duplicates
WITH Duplicates AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id, customer_id, order_status, order_purchase_date, order_delivered_customer_date, order_purchase_time, order_delivered_time
	ORDER BY (SELECT NULL)) AS occurance
	FROM clean.orders
)
SELECT *
FROM Duplicates 
WHERE occurance > 1

-- No duplicates


-- Standardise (consistencies)
SELECT DISTINCT order_status
FROM clean.orders

SELECT TOP(10) *
FROM clean.orders
