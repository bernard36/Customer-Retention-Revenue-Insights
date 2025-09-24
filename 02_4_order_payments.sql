SELECT TOP(10) *
FROM staging.order_payments

-- Transfer to clean schema
SELECT 
	LTRIM(RTRIM(order_id)) AS order_id,
	TRY_CAST(LTRIM(RTRIM(payment_sequential)) AS INT) AS payment_sequential,
	LTRIM(RTRIM(payment_type)) AS payment_type,
	TRY_CAST(LTRIM(RTRIM(payment_installments)) AS INT) AS payment_installments,
	TRY_CAST(LTRIM(RTRIM(payment_value)) AS DECIMAL(10,2)) AS payment_value
INTO clean.order_payments
FROM staging.order_payments




