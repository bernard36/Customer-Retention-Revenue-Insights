#### **Customer Retention \& Revenue Insights**



This project analyzes customer retention, order patterns, and revenue distribution using the [Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). It follows a structured ETL and data warehousing workflow, from staging raw data to delivering analytical views.



#### **Project Overview**



Objective: Transform raw transactional data into a star-schema warehouse to support insights on customer retention, payments, delivery, and revenue.



**Dataset:** Brazilian [E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)



**Tools:** SQL Server (ETL + modeling), GitHub (versioning), BI tools (Power BI/Tableau planned).



###### **ETL Workflow**



**Staging Layer (staging)**



* Imported raw flat files into SQL Server.



* Preserved the original structure for reference.



**Cleaning Layer (clean)**



* Standardized column names and data types.



* Removed duplicates and handled NULLs.



* Applied text transformations (trimming, casing, etc.).



**Analytics Layer (analytics)**



* Designed a star schema with fact and dimension tables.



* Added surrogate keys and business-friendly column names.



* Built dimension tables (customers, products, sellers, payments, regions, geolocation ect.).



* Built fact tables (orders, payments, reviews, shipments, deliveries, order items).



**Date Dimension (dim\_date)**



* Implemented a reusable date dimension table covering multiple granularities (day, month, year, day name).
* Enables flexible time-based analysis (e.g., revenue trends per year, monthly churn rates, seasonal performance).
* Provides a foundation for more advanced analytics such as rolling averages, retention cohorts, and YTD/MTD growth.



**Views (analytics.vw)**



* Created reusable analytical views for reporting:



* Customer retention \& revenue trends.



* Revenue by product category.



* Regional performance.



* Payment usage \& patterns.



* Delivery \& shipping efficiency.





###### **Data Model**



**Dimensions:** dim\_customers, dim\_products, dim\_product\_category, dim\_seller, dim\_geolocation, dim\_region, dim\_payment\_type, dim\_payments\_method, dim\_order\_status, dim\_date



**Facts:** facts\_orders, facts\_order\_items, facts\_payments, facts\_order\_reviews, facts\_shipments, facts\_delivery



This separation ensures clean data lineage: staging → clean → analytics → views → BI.





**Potential Improvements**



Connect views to Power BI / Tableau for interactive dashboards.



