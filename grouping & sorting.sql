-- ЧАСТЬ 1

-- 1.1 (в полных годах)
select
	city, age, COUNT(id) as customer_count
from
	users
group by
	city, age
order by
	customer_count desc;

-- 1.2 (в возрастных категориях)
select
	city,
	COUNT(id) as customer_count,
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
select *
from
    (select
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
    	seller_id) as t1
where
	seller_type is not null
order by
	seller_id asc;
	

-- 2 (под продавцом я понимаю тут уникальный seller_id)
select 
    seller_id,
    -- привожу date_reg к типу date
    extract(year from age(current_date, min(to_date(date_reg, 'DD-MM-YYYY')))) * 12 + 
    extract(month from age(current_date, min(to_date(date_reg, 'DD-MM-YYYY')))) as month_from_registration,
    (select max(delivery_days) - min(delivery_days) as max_delivery_difference from sellers)
from 
    sellers
where 
    category != 'Bedding'
group by 
    seller_id
having
	-- poor продавцы
    count(category) > 1
    and sum(revenue) < 50000
order by
	seller_id asc;
  
  -- 3 (за дату регистрации принимаю самую раннюю дату)
select
	seller_id,
   	string_agg(category, '-' ORDER BY category asc) as category_pair
from
 	sellers
group by
 	seller_id
having
 	extract(year from min(to_date(date_reg, 'DD-MM-YYYY'))) = 2022
 	and count(category) = 2
 	and sum(revenue) > 75000;
   

