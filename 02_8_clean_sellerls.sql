SELECT TOP (1000) [seller_id]
      ,[seller_zip_code_prefix]
      ,[seller_city]
      ,[seller_state]
  FROM [CustomerRRInsight].[staging].[sellers]


-- Transfer to clean schema (Trim and cast)
SELECT 
    LTRIM(RTRIM(seller_id)) AS seller_id,
    TRY_CAST(LTRIM(RTRIM(seller_zip_code_prefix)) AS INT) AS seller_zip_prefix,
    LTRIM(RTRIM(LOWER(seller_city))) AS seller_city,
    LTRIM(RTRIM(UPPER(seller_state))) AS seller_state
INTO clean.sellers
FROM staging.sellers


-- Add seller state full column
ALTER TABLE clean.sellers
ADD seller_state_full NVARCHAR(150)

-- Update columns with geolocation state_full
UPDATE c
SET c.seller_state_full = g.geolocation_state_full
FROM clean.sellers c
JOIN clean.geolocation g
    ON c.seller_state = g.geolocation_state


-- Handle Nulls
DECLARE @sql NVARCHAR(MAX)

SELECT @sql = 
    ' SELECT * 
      FROM [clean].[sellers]
      WHERE ' + STRING_AGG('[' + COLUMN_NAME + '] IS NULL', ' OR ')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sellers' AND TABLE_SCHEMA = 'clean'
EXEC sp_executesql @sql

-- No Nulls


-- Handle Duplicates
WITH Duplicates AS (
    SELECT *, ROW_NUMBER () OVER (PARTITION BY seller_id, seller_zip_prefix, seller_city, seller_state, seller_state_full
             ORDER BY (SELECT NULL)) AS occurance
    FROM clean.sellers
       
)
SELECT *
FROM Duplicates
WHERE occurance > 1
-- No duplicates

SELECT TOP(10) * 
FROM clean.sellers
