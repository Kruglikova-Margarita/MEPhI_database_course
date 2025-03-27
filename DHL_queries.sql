-- 1) список товаров в посылке с заданным номером накладной и номера их позиций в накладной (invoice_number = 5)

SELECT invoice_position, product_category_name
FROM shipments_product_categories INNER JOIN product_categories USING(product_category_id)
WHERE (invoice_number = 5)
ORDER BY invoice_position;



-- 2) список посылок, которые ожидает partner с заданным id, упорядоченные в порядке возрастания даты получения (receiver_id = 100)

SELECT * 
FROM shipments 
WHERE (receiver_id = 100 AND receipt_date > CURRENT_DATE)
ORDER BY receipt_date;



-- 3) список поставляемых в заданную страну категорий товаров и количество посылок для каждой категории товара (country_name = 'Marshall Islands')

WITH storages_in_country AS (
	SELECT dhl_storage_id 
	FROM dhl_storages INNER JOIN countries USING(country_code)
	WHERE (countries.country_name = 'Marshall Islands')
), shipments_in_country AS (
	SELECT invoice_number
	FROM shipments INNER JOIN storages_in_country ON (shipments.receiver_storage_id = storages_in_country.dhl_storage_id)
), product_ids AS (
	SELECT product_category_id, COUNT(product_category_id) AS count_product_category
	FROM shipments_product_categories INNER JOIN shipments_in_country USING(invoice_number)
	GROUP BY product_category_id
)
SELECT product_category_name, count_product_category
FROM product_categories INNER JOIN product_ids USING(product_category_id)
ORDER BY count_product_category;



SELECT product_category_name, COUNT(product_category_id) AS count_product_category
FROM shipments 
INNER JOIN dhl_storages ON (shipments.receiver_storage_id = dhl_storages.dhl_storage_id)
INNER JOIN countries USING(country_code)
INNER JOIN shipments_product_categories USING(invoice_number)
INNER JOIN product_categories USING(product_category_id)
WHERE (countries.country_name = 'Marshall Islands')
GROUP BY product_category_id, product_category_name
ORDER BY count_product_category;



-- 4) список 10 самых отправляемых категорий товаров для заданного partner и количество посылок для каждой категории товара (shipper_id = 1)

WITH product_ids AS (
	SELECT product_category_id, COUNT(product_category_id) AS count_product_category
	FROM shipments_product_categories INNER JOIN shipments USING(invoice_number) 
	WHERE (shipments.shipper_id = 1)
	GROUP BY product_category_id
)
SELECT product_category_name, count_product_category
FROM product_categories INNER JOIN product_ids USING(product_category_id)
ORDER BY count_product_category DESC
LIMIT 10;



-- 5) какой partner чаще всего отправляет заданную категорию товара заданному partner (receiver_id = 86, product_category_name = 'plan')

WITH shipments_product_ids AS (
	SELECT *
	FROM product_categories INNER JOIN shipments_product_categories USING(product_category_id)
	WHERE (product_category_name = 'plan')
), required_partner AS (
	SELECT shipper_id AS partner_id
	FROM shipments_product_ids INNER JOIN shipments USING(invoice_number)
	WHERE (receiver_id = 86)
	GROUP BY partner_id
	ORDER BY COUNT(shipper_id) DESC
	LIMIT 1
)
SELECT *
FROM partners INNER JOIN required_partner USING(partner_id);



-- 6) частота использования каждого базиса incoterms в % в порядке убывания

WITH num_of_shipments AS (
	SELECT COUNT(*)::FLOAT AS num
	FROM shipments
)
SELECT incoterms_basis, COUNT(*), (100 * COUNT(*)/num) AS percent_of_using
FROM shipments, num_of_shipments
GROUP BY incoterms_basis, num
ORDER BY percent_of_using DESC;



-- 7) список номеров посылок, которые отправлены, но еще не доставлены, с указанием дат и стран отправления и назначения

WITH select_shipper_country_code AS (
	SELECT invoice_number, receiver_storage_id, departure_date, receipt_date, country_code AS shipper_country_code
	FROM shipments INNER JOIN dhl_storages ON (shipments.shipper_storage_id = dhl_storages.dhl_storage_id)
	WHERE (departure_date < '2000-01-01' AND receipt_date > '2000-01-01')
), select_receiver_country_code AS (
	SELECT invoice_number, departure_date, receipt_date, shipper_country_code, country_code AS receiver_country_code
	FROM select_shipper_country_code INNER JOIN dhl_storages ON (select_shipper_country_code.receiver_storage_id = dhl_storages.dhl_storage_id)
), select_shipper_country AS (
	SELECT invoice_number, departure_date, receipt_date, country_name AS shipper_country, receiver_country_code
	FROM select_receiver_country_code INNER JOIN countries ON (select_receiver_country_code.shipper_country_code = countries.country_code)
)
SELECT invoice_number, departure_date, receipt_date, shipper_country, country_name AS receiver_country 
FROM select_shipper_country INNER JOIN countries ON (select_shipper_country.receiver_country_code = countries.country_code)
ORDER BY invoice_number;



-- 8) список номеров посылок, с одинаковыми заданными странами отправления и назначения, отправленными в заданный день (страна отправления: 'Marshall Islands', страна назначения: 'Nigeria', дата отправления: '2019-01-18)

WITH shipper_storages AS (
	SELECT dhl_storage_id
	FROM countries INNER JOIN dhl_storages USING(country_code) 
	WHERE (country_name = 'Marshall Islands')
), receiver_storages AS (
	SELECT dhl_storage_id
	FROM countries INNER JOIN dhl_storages USING(country_code) 
	WHERE (country_name = 'Nigeria')
), shipments_same_shipper_country AS (
	SELECT invoice_number, shipper_id ,receiver_id, shipper_storage_id, receiver_storage_id, incoterms_basis, weight_kg, departure_date, receipt_date 
	FROM shipments INNER JOIN shipper_storages ON (shipments.shipper_storage_id = shipper_storages.dhl_storage_id)
	WHERE (departure_date = '2019-01-18')
)
SELECT invoice_number, shipper_id ,receiver_id, shipper_storage_id, receiver_storage_id, incoterms_basis, weight_kg, departure_date, receipt_date 
FROM shipments_same_shipper_country INNER JOIN receiver_storages ON (shipments_same_shipper_country.receiver_storage_id = receiver_storages.dhl_storage_id)
ORDER BY invoice_number;



-- 9) список людей, которым пришла посылка на заданный склад в заданную дату (dhl_storages.address = E'14063 Harmon Keys Apt. 759\nNancyshire, MD 50435', shipments.receipt_date = '1953-06-28')

WITH required_shipments AS (
	SELECT receiver_id, invoice_number
	FROM shipments INNER JOIN dhl_storages ON (shipments.receiver_storage_id = dhl_storages.dhl_storage_id)
	WHERE (address = E'121 Rachel Divide\nLake Staceymouth, NH 42325' AND receipt_date = '1994-01-11') 
)
SELECT receiver_id, first_name, last_name, phone_number, invoice_number
FROM required_shipments INNER JOIN partners ON (required_shipments.receiver_id = partners.partner_id)
ORDER BY receiver_id;



-- 10) список стран с указанием самой часто отправляемой категории товара для каждой страны и количества посылок с ней

WITH shipments_dhl_storages AS (
	SELECT invoice_number, country_code
	FROM shipments INNER JOIN dhl_storages ON (shipments.shipper_storage_id = dhl_storages.dhl_storage_id)
), shipments_countries AS (
	SELECT invoice_number, country_name
	FROM shipments_dhl_storages INNER JOIN countries USING(country_code)
), shipments_product_categories_countries AS (
	SELECT product_category_id, country_name
	FROM shipments_countries INNER JOIN shipments_product_categories USING(invoice_number)
), product_categories_countries AS (
	SELECT product_category_name, country_name
	FROM shipments_product_categories_countries INNER JOIN product_categories USING(product_category_id)
), count_product_categories_countries AS (
	SELECT country_name, product_category_name, COUNT(product_category_name) AS number_shipments, 
	ROW_NUMBER() OVER (
		PARTITION BY country_name
		ORDER BY COUNT(product_category_name) DESC
	) AS maximum
	FROM product_categories_countries
	GROUP BY product_category_name, country_name
)
SELECT country_name, product_category_name, number_shipments
FROM count_product_categories_countries 
WHERE maximum = 1;



WITH product_categories_countries AS (
	SELECT product_category_name, country_name
	FROM shipments 
	INNER JOIN dhl_storages ON (shipments.shipper_storage_id = dhl_storages.dhl_storage_id)
	INNER JOIN countries USING(country_code)
	INNER JOIN shipments_product_categories USING(invoice_number)
	INNER JOIN product_categories USING(product_category_id)
), count_product_categories_countries AS (
	SELECT country_name, product_category_name, COUNT(product_category_name) AS number_shipments, 
	ROW_NUMBER() OVER (
		PARTITION BY country_name
		ORDER BY COUNT(product_category_name) DESC
	) AS maximum
	FROM product_categories_countries
	GROUP BY product_category_name, country_name
)
SELECT country_name, product_category_name, number_shipments
FROM count_product_categories_countries 
WHERE maximum = 1;





