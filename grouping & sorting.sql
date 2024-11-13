-- ЧАСТЬ 1

-- 1.1 (в полных годах)
SELECT
	city, age, count(id) AS customer_count
FROM
	users
GROUP BY
	city, age
ORDER BY
	customer_count DESC;

-- 1.2 (в возрастных категориях)
SELECT
	city,
	count(id) AS customer_count,
	CASE 
		WHEN age BETWEEN 0 AND 20 THEN 'young'
		WHEN age BETWEEN 21 AND 49 THEN 'adult'
		ELSE 'old'
	END AS
		age_category
FROM
	users
GROUP BY
	city, age_category
ORDER BY
	customer_count DESC;

-- 2
SELECT
	category,
	round(avg(price),2) AS avg_price
FROM
	products
WHERE
	name ILIKE '%hair%'
	OR name ILIKE '%home%'
group BY
	category;

-- ЧАСТЬ 2

-- 1 (без вывода продавцов-ноунеймов (которые ни rich, ни poor))
SELECT
	*
FROM
    (SELECT
        seller_id,
        count(category) AS total_categ,
        sum(revenue) AS total_revenue,
        avg(rating) AS avg_rating,
        CASE
            WHEN count(category) > 1 AND sum(revenue) > 50000 THEN 'rich'
            WHEN count(category) > 1 AND sum(revenue) < 50000 THEN 'poor'
        END AS
        	seller_type
	FROM
    	sellers
    WHERE 
    	category != 'Bedding'
    GROUP BY 
    	seller_id) AS t1
WHERE
	seller_type is not NULL
ORDER BY
	seller_id ASC;
	

-- 2 (под продавцом я понимаю тут уникальный seller_id)
SELECT 
    seller_id,
    -- привожу date_reg к типу date
    EXTRACT(YEAR FROM age(current_date, min(to_date(date_reg, 'DD-MM-YYYY')))) * 12 + 
    EXTRACT(MONTH FROM age(current_date, min(to_date(date_reg, 'DD-MM-YYYY')))) AS month_from_registration,
    (SELECT max(delivery_days) - min(delivery_days) AS max_delivery_difference FROM sellers)
FROM 
    sellers
WHERE
	category != 'Bedding'
GROUP BY
	seller_id
HAVING
	-- poor продавцы
	count(category) > 1
	AND sum(revenue) < 50000
ORDER BY
	seller_id ASC;
  
  -- 3 (за дату регистрации принимаю самую раннюю дату)
SELECT
	seller_id,
   	string_agg(category, '-' ORDER BY category ASC) AS category_pair
FROM
 	sellers
GROUP BY
 	seller_id
HAVING
 	EXTRACT(YEAR FROM min(to_date(date_reg, 'DD-MM-YYYY'))) = 2022
 	AND count(category) = 2
 	AND sum(revenue) > 75000;
   

