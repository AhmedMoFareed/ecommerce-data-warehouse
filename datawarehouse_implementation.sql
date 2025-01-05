INSERT INTO [ecommerce_DHW].[dbo].[DimCustomer]
SELECT 
       [user_name] AS  customer_name
      ,[customer_zip_code]
      ,[customer_city]
      ,[customer_state]
  FROM [staging].[dbo].users
-------------------------------------------------------------------------------------------

INSERT INTO [ecommerce_DHW].[dbo].[DimOrderStatus]
SELECT 
       DISTINCT[order_status]
  FROM[staging].[dbo].[orders] 

 --------------------------------------------------------------------------------------------------
INSERT INTO [ecommerce_DHW].[dbo].[DimPaymentType]
SELECT
      DISTINCT [payment_type]
  FROM [staging].[dbo].[payment]
---------------------------------------------------------------------------------------------------

INSERT INTO [ecommerce_DHW].[dbo].[DimProduct]
SELECT
       [product_id]
      ,ISNULL([product_category],'other')
      ,[product_name_lenght]
      ,[product_description_lenght]
      ,[product_photos_qty]
      ,[product_weight_g]
      ,[product_length_cm]
      ,[product_height_cm]
      ,[product_width_cm]

	FROM [staging].[dbo].[products]

-----------------------------------------------------------------------------------------------------------------
INSERT INTO [ecommerce_DHW].[dbo].[DimSeller]
SELECT [seller_id]
      ,[seller_zip_code]
      ,[seller_city]
      ,[seller_state]
  FROM [staging].[dbo].[sellers]
------------------------------------------------------------------------------------------------------------------
INSERT INTO [ecommerce_DHW].[dbo].[FactOrders]
SELECT
       o.[order_id]
      ,u.customer_key
      ,CASE 
        WHEN o.order_status = 'approved' THEN 4
        WHEN o.order_status = 'canceled' THEN 3
        WHEN o.order_status = 'created' THEN 1
        WHEN o.order_status = 'delivered' THEN 7
        WHEN o.order_status = 'invoiced' THEN 8
        WHEN o.order_status = 'processing' THEN 5
        WHEN o.order_status = 'shipped' THEN 2
        WHEN o.order_status = 'unavailable' THEN 6
        ELSE NULL 
      END AS order_status_key
      ,CAST(CONVERT(VARCHAR(8), o.order_date, 112) AS INT) AS order_date_key
      ,CAST(CONVERT(VARCHAR(8), o.order_approved_date, 112) AS INT) AS order_approved_date_key
      ,CAST(CONVERT(VARCHAR(8), o.delivered_date, 112) AS INT) AS delivered_date_key
      ,CAST(CONVERT(VARCHAR(8), o.estimated_time_delivery, 112) AS INT) AS estimated_time_delivery_key
	  ,ISNULL(DATEDIFF(day, o.order_approved_date, o.delivered_date),0) AS delivery_delay_days
	  ,sum(i.price +i.shipping_cost) AS order_total_value
	  ,count(i.order_item_id) AS order_item_count
FROM[staging].dbo.orders o
LEFT JOIN staging.dbo.users u
ON o.user_name = u.user_name
LEFT JOIN [staging].[dbo].[order_items] i
ON o.order_id = i.order_id
GROUP BY 
       o.[order_id]
      ,u.customer_key
      ,CASE 
        WHEN o.order_status = 'approved' THEN 4
        WHEN o.order_status = 'canceled' THEN 3
        WHEN o.order_status = 'created' THEN 1
        WHEN o.order_status = 'delivered' THEN 7
        WHEN o.order_status = 'invoiced' THEN 8
        WHEN o.order_status = 'processing' THEN 5
        WHEN o.order_status = 'shipped' THEN 2
        WHEN o.order_status = 'unavailable' THEN 6
        ELSE NULL 
		END
      ,CAST(CONVERT(VARCHAR(8), o.order_date, 112) AS INT) 
      ,CAST(CONVERT(VARCHAR(8), o.order_approved_date, 112) AS INT) 
      ,CAST(CONVERT(VARCHAR(8), o.pickup_date, 112) AS INT) 
      ,CAST(CONVERT(VARCHAR(8), o.delivered_date, 112) AS INT) 
      ,CAST(CONVERT(VARCHAR(8), o.estimated_time_delivery, 112) AS INT)
	  ,DATEDIFF(day, o.order_approved_date, o.delivered_date)

-----------------------------------------------------------------------------------------------------
INSERT INTO [ecommerce_DHW].[dbo].[FactOrderItems]
SELECT
	   fo.order_key 
      ,i.order_item_id
      ,p.product_key
      ,s.seller_key
      ,CAST(CONVERT(VARCHAR(8), i.pickup_limit_date, 112) AS INT) AS pickup_limit_date_key
      ,i.price
      ,i.shipping_cost
  FROM [staging].[dbo].[order_items] i
  LEFT JOIN[ecommerce_DHW].[dbo].[DimProduct]  p
  ON p.product_id = i.product_id
  LEFT JOIN [ecommerce_DHW].[dbo].[DimSeller] s
  ON i.seller_id = s.seller_id
  LEFT JOIN [ecommerce_DHW].[dbo].[FactOrders] fo
  ON i.order_id = fo.order_id
------------------------------------------------------------------------------------------------------
INSERT INTO [ecommerce_DHW].[dbo].[FactPayments]
SELECT fo.order_key
      ,p.[payment_sequential]
      ,CASE 
        WHEN payment_type = 'blipay' THEN 4
        WHEN payment_type = 'credit_card' THEN 1
        WHEN payment_type = 'debit_card' THEN 2
        WHEN payment_type = 'not_defined' THEN 3
        WHEN payment_type = 'voucher' THEN 5
        ELSE NULL
    END AS payment_type_key
      ,p.[payment_installments]
      ,p.[payment_value]
  FROM [staging].[dbo].[payment] p
  left join [ecommerce_DHW].[dbo].[FactOrders] fo
  on p.order_id = fo.order_id
-------------------------------------------------------------------------------------------------------
INSERT INTO ecommerce_DHW.dbo.FactFeedback
SELECT 
       f.[feedback_id]
      ,fo.[order_key]
      ,f.[feedback_score]
      ,CAST(CONVERT(VARCHAR(8), f.[feedback_form_sent_date], 112) AS INT) AS feedback_form_sent_date_key
      ,CAST(CONVERT(VARCHAR(8), f.[feedback_answer_date], 112) AS INT) AS feedback_answer_date_key
	  ,DATEDIFF(day,f.[feedback_form_sent_date],f.[feedback_answer_date]) AS time_to_feedback_days
  FROM [staging].[dbo].[feedback] f
  LEFT JOIN [ecommerce_DHW].[dbo].[FactOrders] fo
  ON f.order_id = fo.order_id


