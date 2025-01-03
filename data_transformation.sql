USE sales_DWH;
-- data dimension creation
DECLARE @StartDate DATE = '2015-01-01';
DECLARE @EndDate DATE = '2019-12-31';

WITH DateRange AS (
    SELECT @StartDate AS [date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [date])
    FROM DateRange
    WHERE [date] < @EndDate
)
INSERT INTO date_dim
SELECT 
    CONVERT(INT, FORMAT([date], 'yyyyMMdd')) AS date_key,
    [date],
    DAY([date]) AS [day],
    MONTH([date]) AS [month],
    YEAR([date]) AS [year],
    DATENAME(WEEKDAY, [date]) AS day_name,
    DATENAME(MONTH, [date]) AS month_name,
    DATEPART(WEEK, [date]) AS week_of_year,
    DATEPART(QUARTER, [date]) AS quarter,
    CASE WHEN DATEPART(WEEKDAY, [date]) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend
FROM DateRange
OPTION (MAXRECURSION 0);

-- ********************************************************************
-- INSERT DATA INTO CUSTOMERS DIMENSION
INSERT INTO [sales_DWH].[dbo].[dim_customer]
SELECT [customer_key]
      ,[user_name]
      ,[customer_zip_code]
      ,[customer_city]
      ,[customer_state]
FROM [staging].[dbo].[users]
SELECT TOP(10) * FROM [dbo].[dim_customer]
--*******************************************************************
-- INSERT SELLER DIMENSION DATA
INSERT INTO [sales_DWH].[dbo].[dim_seller]
SELECT [seller_key]
      ,[seller_id]
      ,[seller_zip_code]
      ,[seller_city]
      ,[seller_state]
	  FROM [staging].dbo.sellers
SELECT TOP(10)* FROM [dim_seller]
--***********************************************************************
-- INSERT PRODUCT DATA
INSERT INTO [sales_DWH].[dbo].[dim_product]
SELECT [product_key]
      ,[product_id]
      ,[product_category]
      ,[product_name_lenght]
      ,[product_description_lenght]
      ,[product_photos_qty]
      ,[product_weight_g]
      ,[product_length_cm]
      ,[product_height_cm]
      ,[product_width_cm]
	  FROM [staging].[dbo].[products]
SELECT * FROM dim_product
-- *****************************************
-- INSERT DATA INTO FEEDBACK TABLE
INSERT INTO [sales_DWH].[dbo].[feedback_fact]
SELECT
	   [feedback_id]
      ,[order_id]
      ,[feedback_score]
      ,CONVERT(INT, FORMAT(feedback_form_sent_date, 'yyyyMMdd')) AS feedback_from_sent_date
      ,CONVERT(INT, FORMAT(feedback_answer_date, 'yyyyMMdd')) AS feedback_answer_date
  FROM [staging].[dbo].[feedback]
SELECT TOP(10) * FROM feedback_fact
--***********************************************************************************
-- INSERT DATA INTO FACT ORDER
INSERT INTO [sales_DWH].dbo.fact_order
SELECT distinct
       o.[order_id]
      ,u.[customer_key]
      ,s.[seller_key]
      ,p.[payment_sequential]
      ,p.[payment_installments]
      ,p.[payment_value]
	  ,CONVERT(INT, FORMAT(isnull(o.[order_date],'1900-01-01'), 'yyyyMMdd')) AS order_date
      ,o.[order_status]
      ,CONVERT(INT, FORMAT(isnull(o.[order_approved_date],'1900-01-01'), 'yyyyMMdd')) as order_approval_date
      ,CONVERT(INT, FORMAT(isnull(o.[pickup_date],'1900-01-01'), 'yyyyMMdd')) as pickup_date
      ,CONVERT(INT, FORMAT(isnull(o.[delivered_date],'1900-01-01'), 'yyyyMMdd')) as delivered_date
      ,CONVERT(INT, FORMAT(isnull(o.[estimated_time_delivery],'1900-01-01'), 'yyyyMMdd')) as estimated_time_delivery
      ,sum(isnull(i.price,0)) as total_price
      ,sum(isnull(i.shipping_cost,0)) as total_shipping_cost
  FROM [staging].dbo.orders o
   join [staging].dbo.order_items i
  on i.order_id = o.order_id
  left join [staging].dbo.payment p
  on p.order_id = i.order_id
  left join [staging].dbo.users u
  on u.user_name = o.user_name
  left join [staging].dbo.sellers s
  on s.seller_id = i.seller_id
where o.order_id is not null
group by o.[order_id]
      ,u.[customer_key]
      ,s.[seller_key]
      ,p.[payment_sequential]
      ,p.[payment_installments]
      ,p.[payment_value]
      ,o.[order_date]
      ,o.[order_status]
      ,o.[order_approved_date]
      ,o.[pickup_date]
      ,o.[delivered_date]
      ,o.[estimated_time_delivery] 
SELECT TOP(10)* FROM [dbo].[fact_order]
--************************************************************************
insert into [sales_DWH].[dbo].[order_item_bridge]
SELECT       
		i.[order_id]
      ,i.[order_item_id]
      ,p.[product_key]
      ,i.[price]
      ,i.[shipping_cost]
  FROM [staging].[dbo].[order_items] i
  left join [staging].[dbo].products p
  on i.product_id = p.product_id