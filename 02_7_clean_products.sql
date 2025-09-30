SELECT TOP(10) *
FROM staging.products


-- Transfer to clean schema (Trim and cast)
SELECT 
	LTRIM(RTRIM(product_id)) AS product_id,
	LTRIM(RTRIM(product_category_name)) AS product_category_name,
	TRY_CAST(LTRIM(RTRIM(product_name_lenght)) AS INT) AS product_name_length,
	TRY_CAST(LTRIM(RTRIM(product_description_lenght)) AS INT) AS product_description_length,
	TRY_CAST(LTRIM(RTRIM(product_photos_qty)) AS INT) AS product_photos_qty,
	TRY_CAST(LTRIM(RTRIM(product_weight_g)) AS INT) AS product_weight_g,
	TRY_CAST(LTRIM(RTRIM(product_length_cm)) AS INT) AS product_length_cm,
	TRY_CAST(LTRIM(RTRIM(product_height_cm)) AS INT) AS product_height_cm,
	TRY_CAST(LTRIM(RTRIM(product_width_cm)) AS INT) AS product_width_cm
INTO clean.products
FROM staging.products


-- Drop non needed columns
ALTER TABLE clean.products
DROP COLUMN product_name_length, product_description_length, product_photos_qty 

-- Add translation of the product category column 
ALTER TABLE clean.products
ADD category_name_english NVARCHAR(300)


-- Update columns
UPDATE p
SET p.category_name_english = t.column2
FROM clean.products p
LEFT JOIN staging.product_category_name_translation t
	ON p.product_category_name = t.column1



-- Handle duplicates
DECLARE @sql NVARCHAR(MAX)

SELECT @sql = 
	' SELECT * 
	  FROM [clean].[products]
	  WHERE ' + STRING_AGG('[' + COLUMN_NAME + '] IS NULL', ' OR ')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'products' AND TABLE_SCHEMA = 'clean'
EXEC sp_executesql @sql

-- Deleted Row that has not category name
DELETE FROM clean.products WHERE product_category_name IS NULL

-- Handle duplicates
WITH Duplicates AS (
	SELECT *, ROW_NUMBER () OVER (PARTITION BY product_id, product_category_name, product_weight_g, product_length_cm, product_height_cm, product_width_cm
	ORDER BY (SELECT NULL)) AS occurance
	FROM clean.products
)
SELECT *
FROM Duplicates
WHERE occurance > 1
-- No duplicates


-- Check for consistencies
SELECT DISTINCT product_category_name
FROM clean.products
-- All consistent data

SELECT TOP(10) *
FROM clean.products


	