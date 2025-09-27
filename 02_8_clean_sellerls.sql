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

SELECT TOP(10) *
FROM staging.sellers
    
SELECT TOP(10) *
FROM clean.customers

SELECT TOP(10) *
FROM clean.geolocation
