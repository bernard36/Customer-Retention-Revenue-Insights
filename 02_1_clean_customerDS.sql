-- Clean Schema
CREATE SCHEMA clean

-- transfer to clean schema after casting to proper datatype and trimming
SELECT 
    LTRIM(RTRIM(customer_id)) AS customer_id,
    LTRIM(RTRIM(customer_unique_id)) AS customer_unique_id,
    CAST(LTRIM(RTRIM(customer_zip_code_prefix)) AS INT) AS zip_prefix,
    LTRIM(RTRIM(
        UPPER(LEFT(customer_city,1)) + LOWER(SUBSTRING(customer_city,2,LEN(customer_city)))
    )) AS customer_city,
    LTRIM(RTRIM(UPPER(customer_state))) AS customer_state
INTO clean.customers -- create and transfer data to clean schema from staging schema
FROM staging.customers


-- Check for missing values (Dynamicaly)
DECLARE @sql NVARCHAR(MAX);

SELECT @sql = 'SELECT * FROM [clean].[customers] WHERE ' + STRING_AGG('[' + COLUMN_NAME + '] IS NULL', ' OR ')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customers' AND TABLE_SCHEMA = 'clean'

PRINT @sql

-- run sql
EXEC sp_executesql @sql;

-- No Null found


-- Duplicates
WITH Duplicates AS (
SELECT *,
    ROW_NUMBER() OVER(PARTITION BY customer_id, customer_unique_id, zip_prefix, customer_city, customer_state 
    ORDER BY (SELECT NULL)
    ) AS occurance
FROM clean.customers -- Numbers all the unique rows starting from 1, if 2, mean duplicate
)
DELETE FROM Duplicates WHERE occurance > 1 -- Delete rows with 2 occurance

-- No duplicates found

SELECT DISTINCT customer_state
FROM clean.customers

-- Standardize: location formatting: make customer_state abbreviation full 
-- Add customer_state_full columns
ALTER TABLE clean.customers
ADD customer_state_full NVARCHAR(50)

-- update columns with the fullname of the states by joining the abv on customer_table with the abv on brazillian_state table
UPDATE c
SET c.customer_state_full = LOWER(full_state.column2)
FROM clean.customers c
JOIN dbo.brazillian_states full_state
    ON c.customer_state = full_state.column1

-- make customer_city lowercase for standardisation
UPDATE c
SET c.customer_city = LOWER(c.customer_city)
FROM clean.customers c

-- inspect
SELECT *
FROM clean.customers






