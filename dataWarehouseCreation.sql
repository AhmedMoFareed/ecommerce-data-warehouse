CREATE DATABASE sales_DWH;
GO
--*******************************************************************************
USE sales_DWH;

CREATE TABLE fact_order(
order_id varchar(50) primary key,
customer_key int,
seller_key int,
payment_sequential int,
payment_key tinyint,
payment_installments smallint,
payment_value decimal(12,2),
order_date int,
order_status varchar(50),
order_approval_date int,
pickup_date int,
delivered_date int,
estimated_time_delivery int,
total_price decimal(12,2),
total_shipping_cost decimal(12,2)
)
CREATE TABLE order_item_bridge(
order_id varchar(50),
order_item_id int,
product_key int,
price decimal(12,2),
shipping_cost decimal(12,2)
)
CREATE TABLE feedback_fact(
feedback_id varchar(50),
order_id varchar(50),
feedback_score int,
feedback_from_sent_date int,
feedback_answer_date int
)

CREATE TABLE dim_customer(
customer_key int primary key,
user_name varchar(50) not null,
customer_zip_code int not null,
customer_city varchar(50),
customer_state varchar (30)
)

CREATE TABLE dim_seller(
seller_key int primary key,
seller_id varchar(50) not null,
seller_zip_code int not null,
seller_city varchar(50) not null,
seller_state varchar(30) not null
)
CREATE TABLE dim_product(
product_key int primary key,
product_id varchar(50) not null,	
product_category varchar(50),
product_name_lenght float,
product_description_lenght float,
product_photos_qty float,
product_weight_g float,
product_length_cm float,
product_height_cm float,
product_width_cm float
)
CREATE TABLE date_dim(
date_key int primary key,
date date not null,
day int not null,
month int not null,
year int not null,
day_name varchar(20) not null,
month_name varchar(20) not null,
week_of_year int not null,
quarter int not null,
is_weekend bit not null,
)
CREATE TABLE payment_dim(
payment_key tinyint primary key,
payment_type varchar(20)
)

CREATE TABLE order_fact(
order_id varchar(50),
order_item_id smallint,
product_id varchar(50),
seller_id varchar(50),
pickup_limit_date int, --date key
price	decimal(12,2),
shipping_cost decimal(12,2)
)

/*
	  ,CAST(FORMAT(SOH.[OrderDate],'yyyyMMdd') AS INT) AS [OrderDate]
	  ,CAST(FORMAT(SOH.[DueDate],'yyyyMMdd') AS INT) AS [DueDate]
	  ,CAST(FORMAT(SOH.[ShipDate],'yyyyMMdd') AS INT) AS [ShipDate]
	  )
*/
--***************************************************************************************
-- CREATE 