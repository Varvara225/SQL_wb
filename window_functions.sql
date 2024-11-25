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
	lag(total_sales, 1) over (partition by "SHOPNUMBER", "CATEGORY" order by "DATE") as "PREV_SALES"
from
	SalesData
order by
	"DATE_", "SHOPNUMBER", "CATEGORY";
   
   -- ЧАСТЬ 3
   
   -- 3.1

create table if not exists query (
    searchid SERIAL primary key,
    year int,
    month int,
    day int,
    userid int,
    ts bigint,
    devicetype varchar(20),
    deviceid varchar(50),
    query varchar(255)
);

insert into query (year, month, day, userid, ts, devicetype, deviceid, query) values
(2023, 1, 1, 101, 1672537600, 'mobile', 'device_001', 'к'),
(2023, 1, 1, 101, 1672537660, 'android', 'device_001', 'ку'),
(2023, 1, 1, 101, 1672537720, 'mobile', 'device_001', 'куп'),
(2023, 1, 1, 101, 1672537780, 'mobile', 'device_001', 'купить'),
(2023, 1, 1, 101, 1672537840, 'mobile', 'device_001', 'купить кур'),
(2023, 1, 1, 101, 1672537900, 'mobile', 'device_001', 'купить куртку'),
(2023, 1, 2, 102, 1672624000, 'android', 'device_002', 'телефон'),
(2023, 1, 2, 102, 1672624060, 'android', 'device_002', 'смартфон'),
(2023, 1, 2, 102, 1672624120, 'android', 'device_002', 'смартфон Samsung'),
(2023, 1, 2, 102, 1672624180, 'android', 'device_002', 'смартфон Samsung Galaxy'),
(2023, 1, 3, 103, 1672710400, 'tablet', 'device_003', 'ноутбук'),
(2023, 1, 3, 103, 1672710460, 'tablet', 'device_003', 'ноутбук Acer'),
(2023, 1, 3, 103, 1672710520, 'tablet', 'device_003', 'ноутбук Acer Aspire'),
(2023, 1, 4, 104, 1672796800, 'mobile', 'device_004', 'кроссовки'),
(2023, 1, 4, 104, 1672796860, 'android', 'device_004', 'кроссовки Nike'),
(2023, 1, 4, 104, 1672796920, 'mobile', 'device_004', 'кроссовки Adidas'),
(2023, 1, 5, 105, 1672883200, 'desktop', 'device_005', 'часы'),
(2023, 1, 5, 105, 1672883260, 'desktop', 'device_005', 'умные часы'),
(2023, 1, 5, 105, 1672883320, 'desktop', 'device_005', 'умные часы Apple'),
(2023, 1, 6, 106, 1672969600, 'tablet', 'device_006', 'игровая приставка'),
(2023, 1, 6, 106, 1672969660, 'tablet', 'device_006', 'игровая приставка PlayStation'),
(2023, 1, 6, 106, 1672969720, 'tablet', 'device_006', 'игровая приставка Xbox');

alter table query
add column is_final int;

with ranked_queries as (
    select *,
           lead(ts) over (partition by userid, deviceid order by ts) as next_ts,
           lead(query) over (partition by userid order by ts) as next_query
    from query
), final_values as (
    select *,
           case 
               when next_ts is null then 1
               when next_ts - ts > 180 then 1
               when length(next_query) < length(query) and next_ts - ts > 60 then 2
               else 0
           end as is_final_value
    from ranked_queries
)
update query
set is_final = final_values.is_final_value
from final_values
where query.searchid = final_values.searchid;

select
	*
from
	query
	