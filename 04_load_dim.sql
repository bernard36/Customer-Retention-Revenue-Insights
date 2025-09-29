/* 
	File: 04_load_dim.sql
	Purpose: Insert data into the dim table from the clean schema
*/


SELECT TOP(10) *
FROM clean.geolocation

-- INSERT into analytics.dim_region
-- insert city and state from clean.geolocation into region dimension
INSERT INTO analytics.dim_region (city, state)
SELECT DISTINCT geolocation_city, geolocation_state_full
FROM clean.geolocation


-- INSERT into analytics.dim_geolocation
-- insert long, lat, region_id, zip_prefix into dim geolocation, region_id as foreing key from region_dimension, joining based on city and state from the region dimension table with the clean.geolocation table
INSERT INTO analytics.dim_geolocation (latitude, longitude, region_id, zip_prefix)
SELECT DISTINCT g.geolocation_lat, g.geolocation_lng, r.id, g.geolocation_zip_prefix
FROM clean.geolocation g
JOIN analytics.dim_region r
	ON g.geolocation_city = r.city AND g.geolocation_state_full = r.state




