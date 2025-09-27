-- Transfer to clean schema
SELECT 
	TRY_CAST(LTRIM(RTRIM(geolocation_zip_code_prefix)) AS INT) AS geolocation_zip_prefix,
	TRY_CAST(LTRIM(RTRIM(geolocation_lat)) AS DECIMAL(10,6)) AS geolocation_lat,
	TRY_CAST(LTRIM(RTRIM(geolocation_lng)) AS DECIMAL(10,6)) AS geolocation_lng,
	LTRIM(RTRIM(geolocation_city)) AS geolocation_city,
	LTRIM(RTRIM(geolocation_state)) AS geolocation_state
INTO clean.geolocation
FROM staging.geolocation


-- Add full name of city derived column
ALTER TABLE clean.geolocation
ADD geolocation_state_full NVARCHAR(150)

-- Update geolocation_state_full column
UPDATE g
SET g.geolocation_state_full = c.customer_state_full
FROM clean.geolocation g
JOIN clean.customers c
	ON g.geolocation_state = c.customer_state


-- Nulls
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



-- Delete Duplicates
WITH Duplicates AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY geolocation_zip_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state 
		ORDER BY (SELECT NULL)) AS occurance
	FROM clean.geolocation
)
DELETE FROM Duplicates WHERE occurance > 1
-- Deleted 400k + duplicates











	