/***************************************************************************************************
* Data Warehouse Implementation
* name  :  Ahmed Mohamed Fareed
* email : ahmedmofareed1@gmail.com
*
*****************************************************************************************************/


CREATE DATABASE ecommerce_DHW;

GO

USE ecommerce_DHW;

GO
--*****************************************************************************************************
-- Create DimDate Table

CREATE TABLE DimDate (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(15) NOT NULL,
    quarter INT NOT NULL,
    year INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(10) NOT NULL,
    is_weekend BIT NOT NULL,
    is_holiday BIT NOT NULL
);
-- Populate DimDate Table
-- Generate dates from '2014-01-01' to '2020-12-31'
DECLARE @StartDate DATE = '2014-01-01';
DECLARE @EndDate DATE = '2020-12-31';

WITH DateRange AS (
    SELECT
        CAST(@StartDate AS DATE) AS [Date]
    UNION ALL
    SELECT
        DATEADD(DAY, 1, [Date])
    FROM DateRange
    WHERE DATEADD(DAY, 1, [Date]) <= @EndDate
)
INSERT INTO DimDate (
    date_key,
    full_date,
    day,
    month,
    month_name,
    quarter,
    year,
    day_of_week,
    day_name,
    is_weekend,
    is_holiday 
)
SELECT
    CAST(CONVERT(VARCHAR(8), [Date], 112) AS INT) AS date_key, -- Format YYYYMMDD
    [Date] AS full_date,
    DATEPART(DAY, [Date]) AS day,
    DATEPART(MONTH, [Date]) AS month,
    DATENAME(MONTH, [Date]) AS month_name,
    DATEPART(QUARTER, [Date]) AS quarter,
    DATEPART(YEAR, [Date]) AS year,
    DATEPART(WEEKDAY, [Date]) AS day_of_week,
    DATENAME(WEEKDAY, [Date]) AS day_name,
    CASE WHEN DATEPART(WEEKDAY, [Date]) IN (1,7) THEN 1 ELSE 0 END AS is_weekend,
    0 AS is_holiday -- Set to 1 if [Date] is a holiday
FROM
    DateRange
OPTION (MAXRECURSION 0);


-- Create Customer Table
CREATE TABLE DimCustomer (
    customer_key INT PRIMARY KEY IDENTITY(1,1),
    customer_name VARCHAR(50) NOT NULL,
    customer_zip_code SMALLINT NOT NULL,
    customer_city VARCHAR(50) NOT NULL,
    customer_state VARCHAR(30) NOT NULL
);
-- Create DimSeller Table
CREATE TABLE DimSeller (
    seller_key INT PRIMARY KEY IDENTITY(1,1),
    seller_id VARCHAR(50) UNIQUE NOT NULL,
    seller_zip_code SMALLINT NOT NULL,
    seller_city VARCHAR(50) NOT NULL,
    seller_state VARCHAR(30) NOT NULL
);

-- Create DimProduct Table
CREATE TABLE DimProduct (
    product_key INT PRIMARY KEY IDENTITY(1,1),
    product_id VARCHAR(50) UNIQUE NOT NULL,
    product_category VARCHAR(50) NOT NULL,
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g DECIMAL(10,2),
    product_length_cm DECIMAL(10,2),
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2)
);

-- Create DimPaymentType Table
CREATE TABLE DimPaymentType (
    payment_type_key INT PRIMARY KEY IDENTITY(1,1),
    payment_type VARCHAR(20) NOT NULL UNIQUE
);

-- Create DimOrderStatus Table
CREATE TABLE DimOrderStatus (
    order_status_key INT PRIMARY KEY IDENTITY(1,1),
    order_status VARCHAR(20) NOT NULL UNIQUE
);

-- Create FactOrders Table
CREATE TABLE FactOrders (
    order_key INT PRIMARY KEY IDENTITY(1,1),
    order_id VARCHAR(50) UNIQUE NOT NULL,
    customer_key INT NOT NULL FOREIGN KEY REFERENCES DimCustomer(customer_key),
    order_status_key INT NOT NULL FOREIGN KEY REFERENCES DimOrderStatus(order_status_key),
    order_date_key INT NOT NULL FOREIGN KEY REFERENCES DimDate(date_key),
    order_approved_date_key INT FOREIGN KEY REFERENCES DimDate(date_key),
    delivered_date_key INT FOREIGN KEY REFERENCES DimDate(date_key),
    estimated_delivery_date_key INT FOREIGN KEY REFERENCES DimDate(date_key),
    delivery_delay_days INT,
    order_total_value DECIMAL(18,2),
    order_item_count INT
);

-- Create FactOrderItems Table
CREATE TABLE FactOrderItems (
    order_item_key INT PRIMARY KEY IDENTITY(1,1),
    order_key INT NOT NULL FOREIGN KEY REFERENCES FactOrders(order_key),
    order_item_id INT NOT NULL,
    product_key INT NOT NULL FOREIGN KEY REFERENCES DimProduct(product_key),
    seller_key INT NOT NULL FOREIGN KEY REFERENCES DimSeller(seller_key),
    pickup_limit_date_key INT FOREIGN KEY REFERENCES DimDate(date_key),
    price DECIMAL(18,2) NOT NULL,
    shipping_cost DECIMAL(18,2) NOT NULL
);

-- Create FactPayments Table
CREATE TABLE FactPayments (
    payment_key INT PRIMARY KEY IDENTITY(1,1),
    order_key INT NOT NULL FOREIGN KEY REFERENCES FactOrders(order_key),
    payment_sequential INT NOT NULL,
    payment_type_key INT NOT NULL FOREIGN KEY REFERENCES DimPaymentType(payment_type_key),
    payment_installments INT NOT NULL,
    payment_value DECIMAL(18,2) NOT NULL
);

-- Create FactFeedback Table
CREATE TABLE FactFeedback (
    feedback_key INT PRIMARY KEY IDENTITY(1,1),
    feedback_id VARCHAR(50)  NOT NULL,
    order_key INT NOT NULL FOREIGN KEY REFERENCES FactOrders(order_key),
    feedback_score INT NOT NULL,
    feedback_form_sent_date_key INT FOREIGN KEY REFERENCES DimDate(date_key),
    feedback_answer_date_key INT FOREIGN KEY REFERENCES DimDate(date_key),
    time_to_feedback_days INT
);
--*****************************************************************************************************
-- Create Indexes
CREATE INDEX idx_FactOrders_OrderDateKey ON FactOrders(order_date_key);
CREATE INDEX idx_FactOrderItems_OrderKey ON FactOrderItems(order_key);
CREATE INDEX idx_FactPayments_OrderKey ON FactPayments(order_key);
CREATE INDEX idx_FactFeedback_OrderKey ON FactFeedback(order_key);