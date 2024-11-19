-- ЧАСТЬ 1

-- 1.1 (в полных годах)
select
	city, age, count(id) as customer_count
from
	users
group by
	city, age
order by
	customer_count desc;

-- 1.2 (в возрастных категориях)
select
	city,
	count(id) as customer_count,
	case 
		when age between 0 and 20 then 'young'
		when age between 21 and 49 then 'adult'
		else 'old'
	end as
		age_category
from
	users
group by
	city, age_category
order by
	customer_count desc;

-- 2
select
	category,
	round(avg(price),2) as avg_price
from
	products
where
	name ilike '%hair%'
	or name ilike '%home%'
group by
	category;

-- ЧАСТЬ 2

-- 1 (без вывода продавцов-ноунеймов (которые ни rich, ни poor))
select
	*
from
	(
		select
			seller_id,
			count(category) as total_categ,
			sum(revenue) as total_revenue,
			avg(rating) as avg_rating,
			case
				when count(category) > 1 and sum(revenue) > 50000 then 'rich'
				when count(category) > 1 and sum(revenue) < 50000 then 'poor'
			end as
				seller_type
		from
			sellers
		where
			category != 'Bedding'
		group by
			seller_id
	) as t1
where
	seller_type is not null
order BY
	seller_id asc;
	

-- 2 (под продавцом я понимаю тут уникальный seller_id)
with PoorSellers as (
	select
		*
	from
		sellers
	where
		seller_id in (
			select
				seller_id
			from 
				sellers
			group by
				seller_id
			having
				count(category) > 1
				and sum(revenue) < 50000
	)
)
select
	seller_id,
	extract (year from age(current_date, min(date_reg))) * 12 + 
	extract (month from age(current_date, min(date_reg))) as month_from_registration,
	(select max(delivery_days) - min(delivery_days) as delivery_days_difference from PoorSellers)
from
	PoorSellers
where
	category != 'Bedding'
group by
	seller_id
order by
	seller_id asc;
  
  -- 3 (за дату регистрации принимаю самую раннюю дату)
select
	seller_id,
   	string_agg(category, '-' order by category asc) as category_pair
from
 	sellers
group by
 	seller_id
having
 	extract (year from min(date_reg)) = 2022
 	and count(category) = 2
 	and sum(revenue) > 75000;
   

