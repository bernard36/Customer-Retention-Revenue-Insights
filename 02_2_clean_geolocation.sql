SELECT *
FROM staging.geolocation
WHERE geolocation_zip_code_prefix IS NULL OR geolocation_lat IS NULL OR geolocation_lng IS NULL

-- Transfer to clean schema
SELECT 
	TRY_CAST(LTRIM(RTRIM(geolocation_zip_code_prefix)) AS INT) AS geolocation_zip_prefix,
	TRY_CAST(LTRIM(RTRIM(geolocation_lat)) AS DECIMAL(10,6)) AS geolocation_lat,
	TRY_CAST(LTRIM(RTRIM(geolocation_lng)) AS DECIMAL(10,6)) AS geolocation_lng,
	LTRIM(RTRIM(geolocation_city)) AS geolocation_city,
	LTRIM(RTRIM(geolocation_state)) AS geolocation_state
INTO clean.geolocation
FROM staging.geolocation



-- Identify nulls
-- Temp table to store null rows
--CREATE TABLE #NullRows_geolocation (
--	geolocation_zip_prefix INT,
--	geolocation_lat DECIMAL(10,6),
--	geolocation_lng DECIMAL(10,6),
--	geolocation_city NVARCHAR(50),
--	geolocation_state NVARCHAR(50)
--)

-- Select null rows dynamically with string_agg from clean.geolocation
--DECLARE @sql NVARCHAR(MAX);

--SELECT @sql = 
--	'INSERT INTO #NullRows_geolocation ' +
--	'SELECT * FROM [clean].[geolocation] ' + 
--    'WHERE ' + STRING_AGG('[' + COLUMN_NAME + ']  IS NULL', ' OR ') 
--FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME = 'geolocation' AND TABLE_SCHEMA = 'clean'

--EXEC sp_executesql @sql;

-- Update the latitude null rows with the average latitude of the city
WITH Avg_latitude_city AS (
	SELECT geolocation_city, AVG(geolocation_lat) avg_lat
	FROM clean.geolocation
	GROUP BY geolocation_city
)
UPDATE c
SET geolocation_lat = avg_lat
FROM clean.geolocation c
JOIN Avg_latitude_city a
	ON c.geolocation_city = a.geolocation_city
WHERE geolocation_lat IS NULL


-- Replacing the remaining null row latitude due to the city not having any latitude with the average latitude of the state
WITH Avg_latitude_state AS (
	SELECT AVG(geolocation_lat) avg_lat, geolocation_state
	FROM clean.geolocation
	GROUP BY geolocation_state
)
UPDATE clean.geolocation
SET geolocation_lat = avg_lat
FROM clean.geolocation c 
JOIN Avg_latitude_state a
	ON a.geolocation_state = c.geolocation_state
WHERE geolocation_lat IS NULL


-- Replace the longtitude null rows with the average longtitude of the city
WITH Avg_longtitude_city AS (
	SELECT AVG(geolocation_lng) avg_lng, geolocation_city
	FROM clean.geolocation
	GROUP BY geolocation_city
)
UPDATE clean.geolocation
SET geolocation_lng = avg_lng
FROM clean.geolocation c
JOIN Avg_longtitude_city a
	ON c.geolocation_city = a.geolocation_city
WHERE geolocation_lng IS NULL

-- Replace the longtitude null rows with the average longtitude of the state due to the city that don't have longtitude
WITH Avg_longtitude_state AS (
	SELECT AVG(geolocation_lng) avg_lng, geolocation_state
	FROM clean.geolocation
	GROUP BY geolocation_state
)
UPDATE clean.geolocation
SET geolocation_lng = avg_lng
FROM clean.geolocation c
JOIN Avg_longtitude_state a
	ON c.geolocation_state = a.geolocation_state
WHERE geolocation_lng IS NULL









	