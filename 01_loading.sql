/* 
	File: 01_staging_load.sql
	Purpose: Verify and Document raw Datasets import
*/

-- Create staging schema
CREATE SCHEMA staging;

-- Confirm tables exists
DECLARE @tableName NVARCHAR(150);  -- Variable for the table name tables
DECLARE @sql NVARCHAR(150); -- Variable for staging schema sql

-- Temp table with list of tables
DECLARE @tables TABLE (name NVARCHAR(150));
INSERT INTO @tables (name)
VALUES 
    ('customers'),  -- Table Names
    ('geolocation'), 
    ('order_items'), 
    ('order_payments'),
    ('order_reviews'),
    ('orders'),
    ('sellers'),
    ('product_category_name_translation');

WHILE EXISTS (SELECT * FROM @tables)
BEGIN 
    SELECT TOP 1 @tableName = name 
    FROM @tables;
    
    IF EXISTS (
       SELECT 1 
       FROM INFORMATION_SCHEMA.TABLES
       WHERE TABLE_NAME = @tableName AND TABLE_TYPE = 'BASE TABLE'  -- Ensure it's actual tables not views
    )
    BEGIN 
        SET @sql = 'ALTER SCHEMA ' + QUOTENAME('staging') + ' TRANSFER ' + QUOTENAME('dbo') + '.' + QUOTENAME(@tableName); -- dynamic sql to add table to staging schema
        EXEC sp_executesql @sql;
        PRINT @tableName + ' transferred to staging schema';
    END
    ELSE 
    BEGIN
        PRINT @tableName + ' does NOT exist';
    END 
        
    DELETE FROM @tables WHERE name = @tableName; -- Delete row after checked for while to keep running 
END;


ALTER SCHEMA staging TRANSFER dbo.products

-- Inspect
SELECT TOP(10) *
FROM staging.customers