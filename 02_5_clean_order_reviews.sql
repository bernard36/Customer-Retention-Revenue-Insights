SELECT TOP(10) *
FROM staging.order_reviews


-- Transfer to clean (Trim and Casting)
SELECT 
	LTRIM(RTRIM(review_id)) AS review_id,
	LTRIM(RTRIM(order_id)) AS order_id,
	TRY_CAST(LTRIM(RTRIM(review_score)) AS INT) AS review_score,
	LTRIM(RTRIM(review_comment_title)) AS review_comment_title,
	LTRIM(RTRIM(review_comment_message)) AS review_comment_message,
	TRY_CAST(LTRIM(RTRIM(review_creation_date)) AS DATETIME2) AS review_creation_date,
	TRY_CAST(LTRIM(RTRIM(review_answer_timestamp)) AS DATETIME2) AS review_answer_timestamp
INTO clean.order_reviews
FROM staging.order_reviews

SELECT TOP(10) *
FROM clean.order_reviews