-- ЧАСТЬ 1

-- 1.1
with DateDiffs as (
	select
		customer_id,
		shipment_date - order_date as diff
	from
		orders_new
)
select
	cn.name
from
	DateDiffs as t1
left join
	customers_new cn ON t1.customer_id = cn.customer_id
where
	t1.diff = (select max(diff) from DateDiffs);

-- 1.2
with TotalOrders as (
	select
		customer_id,
		count(order_id) as total_orders,
		avg(shipment_date - order_date) as avg_time,
		sum(order_ammount) as total_amnt
	from
		orders_new
	group by
		customer_id
)
select
	cn.name,
	t1.avg_time,
	t1.total_amnt
from
	TotalOrders as t1
left join
	customers_new cn on t1.customer_id = cn.customer_id
where
	t1.total_orders = (select max(total_orders) from TotalOrders)
order by
	total_amnt desc;

-- 1.3
with InfOrders as (
	select
		customer_id,
		sum(case when shipment_date - order_date > interval '5 days' then 1 else 0 end) as delayed_count,
		sum(case when order_status = 'Cancel' then 1 else 0 end) as canceled_count,
		sum(order_ammount) as total_amnt
	from
		orders_new
	where
		shipment_date - order_date > interval '5 days'
		or order_status = 'Cancel'
	group by
		customer_id
)
select
	cn.name,
	t1.delayed_count,
	t1.canceled_count,
	t1.total_amnt
from
	InfOrders as t1
left join
	customers_new as cn on t1.customer_id = cn.customer_id
order by
	t1.total_amnt desc;

-- ЧАСТь 2

-- 2
select
	p.product_category,
 	sum(o.order_ammount) as total_sales,
 	-- категория с наибольшей суммой продаж
 	(
	 	select
	  		product_category
	  	from
	  		orders_2 o2
	  	left join
	  		products_3 p2 on p2.product_id = o2.product_id 
	  	group by
	   		product_category
	  	order by
	  		sum(o2.order_ammount) desc
	  	limit 1
 	) as top_category,
 	-- продукт с макс суммой продаж
	 (
	 	select
	 		product_name
	  	from
	  		orders_2 o1
	  	left join
	  		products_3 p1 on p1.product_id = o1.product_id
	  	where
	  		p1.product_category = p.product_category
	  	group by
	  		p1.product_name
	  	order by
	  		sum(o1.order_ammount) desc
	  	limit 1
	 ) as top_product_in_category
from
	orders_2 o
left join
	products_3 p on o.product_id = p.product_id
group by
	p.product_category;