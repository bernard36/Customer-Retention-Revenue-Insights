SELECT TOP(10) *
FROM staging.order_payments

-- Transfer to clean schema (Trim and datatype)
SELECT 
	LTRIM(RTRIM(order_id)) AS order_id,
	TRY_CAST(LTRIM(RTRIM(payment_sequential)) AS INT) AS payment_sequential,
	LTRIM(RTRIM(payment_type)) AS payment_type,
	TRY_CAST(LTRIM(RTRIM(payment_installments)) AS INT) AS payment_installments,
	TRY_CAST(LTRIM(RTRIM(payment_value)) AS DECIMAL(10,2)) AS payment_value
INTO clean.order_payments
FROM staging.order_payments


-- Null (dynamically creates sql string checking all the columns names of the order_payment for null)
DECLARE @sql NVARCHAR(MAX);

SELECT @sql = 
	' SELECT * 
	  FROM [clean].[order_payments] 
	  WHERE ' + STRING_AGG('['+ COLUMN_NAME +'] IS NULL ', ' OR ')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'order_payments' AND TABLE_SCHEMA = 'clean'
EXEC sp_executesql @sql

-- No Null


-- Standardize
SELECT order_id, payment_sequential, payment_type, payment_installments, payment_value
FROM clean.order_payments
-- No standardisation needed


-- Duplicates (Check for duplicates with partition by)
SELECT *
FROM (
		SELECT *, ROW_NUMBER () OVER (PARTITION BY order_id, payment_sequential, payment_type, payment_installments, payment_value 
					ORDER BY (SELECT NULL)) AS occurance
		FROM clean.order_payments) AS duplicate
WHERE occurance > 1
-- No duplicates found


SELECT TOP (2) *
FROM clean.order_payments








