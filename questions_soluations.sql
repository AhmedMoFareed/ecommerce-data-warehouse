-- When is the peak season of our ecommerce ?
SELECT   sum(o.order_item_count) as Number_of_sold_items
		,sum(o.order_total_value) AS total_order_per_season
		,d.quarter
FROM [dbo].[FactOrders] o
left join DimDate d
on o.order_approved_date_key = d.date_key
group by d.quarter
order by 2 desc
-- quarter two is the peak season
-------------------------------------------------------------------------------------------------
--What time users are most likely make an order or using the ecommerce app?
-- this question need time dimension to answer but in my model i haven't include one
-------------------------------------------------------------------------------------------------
-- What is the preferred way to pay in the ecommerce?
SELECT   count(fp.payment_key) as frequent_payment
		,dp.payment_type
FROM FactPayments fp
left join [dbo].[DimPaymentType] dp
on fp.payment_type_key = dp.payment_type_key
group by dp.payment_type
order by frequent_payment desc
-- the preferred way to pay in the ecommerce is credit_card
---------------------------------------------------------------------------------------------------
-- How many installment is usually done when paying in the ecommerce?
SELECT   f.[payment_installments]
		,count(f.[payment_key]) as frequent_installment
FROM FactPayments f
group by f.[payment_installments]
order by frequent_installment desc
-- one installmen
--------------------------------------------------------------------------------------------------------
-- What is the average spending time for user for our ecommerce?
-- this calculation need time dimensio
-------------------------------------------------------------------------------------------------------
--
