-- ЧАСТЬ 1

-- 1.1 (оконные + first/last_value)
select
	 first_name,
	 last_name,
	 salary,
	 industry,
	 first_value(first_name) over w as name_highest_sal,
	 last_value(first_name) over w as name_lowest_sal
from
	salary
window w
	as (partition by industry order by salary desc rows between unbounded preceding and unbounded following);

-- 1.2 (без оконных + max/min)
select
	s.first_name,
	s.last_name,
	s.salary,
	s.industry,
	(
		select
			first_name
		from
			salary
		where
			industry = s.industry
			and salary = (select max(salary) from salary where industry = s.industry)
	) as name_highest_sal,
	(
		select
			first_name
		from
			salary
		where
			industry = s.industry
			and salary = (select min(salary) from salary where industry = s.industry)
	) as name_lowest_sal
from
	salary s
order by
	industry;

-- ЧАСТЬ 2

-- 1

select
	sh."SHOPNUMBER",
	sh."CITY",
	sh."ADDRESS",
	t2."SUM_QTY",
	t2."SUM_QTY_PRICE"
from
	(
		select distinct
			t1."SHOPNUMBER",
			sum(t1."QTY") over w as "SUM_QTY",
			sum((t1."QTY" * goods."PRICE")) over w as "SUM_QTY_PRICE"
		from
			(
				select
					*
				from
					sales
				where
					sales."DATE"::date = '2016-01-02'
			) as t1 -- продажи за 02.01.2016
		left join
			shops on t1."SHOPNUMBER" = shops."SHOPNUMBER"
		left join
			goods on t1."ID_GOOD" = goods."ID_GOOD"
		window w
			as (partition by t1."SHOPNUMBER")
	) as t2	-- сумма проданных товаров в штуках и в рублях по магазинам за 2е января
left join
	shops as sh on t2."SHOPNUMBER" = sh."SHOPNUMBER" -- вытаскиваем инфу про адрес магазина
order by
	sh."SHOPNUMBER" asc;

-- 2

select
	t2."DATE_",
	sh."CITY",
	(total_sale_date/total_sale) as "SUM_SALES_REL"
from 
	(
		select
			*,
			sum(total_sale_date) over (partition by t1."SHOPNUMBER") as total_sale
		from 
			(
				select
					sales."DATE"::date as "DATE_",
					sales."SHOPNUMBER",
					sum((sales."QTY" * goods."PRICE")) as total_sale_date
				from
					sales
				left join
					goods on sales."ID_GOOD" = goods."ID_GOOD"
				where
					goods."CATEGORY" = 'ЧИСТОТА'
				group by 
					sales."DATE"::date,
					sales."SHOPNUMBER"
			) as t1 -- продажи товаров категории 'чистота' по датам и магазинам
	) as t2
left join
	shops as sh on t2."SHOPNUMBER" = sh."SHOPNUMBER"
order by
	t2."DATE_"

-- 3
	
select 
	t1."DATE_",
	t1."SHOPNUMBER",
	t1."ID_GOOD"
from 
	(
		select
			"DATE"::date as "DATE_",
			"SHOPNUMBER",
			sales."ID_GOOD",
			rank() over (partition by "SHOPNUMBER", "DATE"::date order by "QTY" desc) as pos
		from
			sales
		left join
			goods on sales."ID_GOOD" = goods."ID_GOOD"
	) as t1
where
	pos <= 3
order by
	t1."DATE_",
	t1."SHOPNUMBER"

-- 4
with SalesData as (
	select
		s."DATE",
		s."SHOPNUMBER",
		g."CATEGORY",
		sum((s."QTY" * g."PRICE")) AS total_sales
	from
		sales s
	left join
		shops sh on s."SHOPNUMBER" = sh."SHOPNUMBER"
	left join
		goods g on s."ID_GOOD" = g."ID_GOOD" 
	where
		sh."CITY" = 'СПб'
	group by
		s."DATE",
		s."SHOPNUMBER",
		g."CATEGORY"
)
select
	"DATE"::date as "DATE_",
	"SHOPNUMBER",
	"CATEGORY",
    sum(total_sales) over (partition by "SHOPNUMBER", "CATEGORY" order by "DATE" rows between 1 preceding and 1 preceding) as "PREV_SALES"
from
	SalesData
order by
	"DATE_", "SHOPNUMBER", "CATEGORY";
   
   -- ЧАСТЬ 3
   
   -- 3.1


	