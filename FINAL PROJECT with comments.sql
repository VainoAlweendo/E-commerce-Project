-- 1
-- This query calculates the number of website sessions and orders per quarter, excluding data from 2015.
-- It provides an overview of the overall business performance over time.

SELECT 
YEAR(website_sessions.created_at) AS YR,
QUARTER(website_sessions.created_at) AS QTR,
COUNT( DISTINCT website_sessions.website_session_id) AS SESSIONS,
COUNT( DISTINCT orders.order_id ) AS orders
FROM website_sessions
  LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE YEAR(website_sessions.created_at) != 2015
GROUP BY 1,2
ORDER BY 1,2;

-- 2
-- This query calculates session-to-order rates, revenue per order, and revenue per session per quarter.
-- It helps to evaluate the efficiency and revenue generation of the e-commerce site.

SELECT 
YEAR(website_sessions.created_at) AS YR,
QUARTER(website_sessions.created_at) AS QTR,
-- COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_rate,
-- COUNT(DISTINCT orders.order_id) AS orders,
SUM(orders.price_usd)/COUNT(DISTINCT orders.order_id) AS revenue_per_order,
-- SUM(orders.price_usd) AS REVENUE,
SUM(orders.price_usd) /COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
 FROM website_sessions
   LEFT JOIN orders
     ON website_sessions.website_session_id = orders.website_session_id
 GROUP BY 1,2    
 ORDER BY 1,2   
;

-- 3
-- This query breaks down orders into various categories based on UTM parameters and other criteria.
-- It helps to assess the effectiveness of different marketing campaigns and sources.

SELECT 
YEAR(website_sessions.created_at) AS YR,
QUARTER(website_sessions.created_at) AS QTR,
COUNT(DISTINCT orders.order_id ) AS orders,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' AND website_sessions.utm_source = 'gsearch' THEN orders.order_id ELSE NULL END) AS GsearchNB,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' AND website_sessions.utm_source = 'bsearch' THEN orders.order_id ELSE NULL END) AS BsearchNB,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS Brand_overall,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign IS NULL AND website_sessions.http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS organic_search,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign IS NULL AND website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN orders.order_id ELSE NULL END) AS direct_typein
FROM orders
  LEFT JOIN website_sessions
   ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2   ;

-- 4
-- This query calculates conversion rates for different marketing campaigns.
-- It measures how effective each campaign is in converting website sessions into orders.

SELECT 
YEAR(website_sessions.created_at) AS YR,
QUARTER(website_sessions.created_at) AS QTR,
-- COUNT(DISTINCT orders.order_id ) AS orders,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' AND website_sessions.utm_source = 'gsearch' THEN orders.order_id ELSE NULL END) 
 /COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' AND website_sessions.utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS GsearchNB_Conversion_rates,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' AND website_sessions.utm_source = 'bsearch' THEN orders.order_id ELSE NULL END)
 /COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' AND website_sessions.utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS BsearchNB_conversion_rates,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END)
 /COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS Brand_overall_conversion_rate,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign IS NULL AND website_sessions.http_referer IS NOT NULL THEN orders.order_id ELSE NULL END)
 /COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign IS NULL AND website_sessions.http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_conversion_rates,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign IS NULL AND website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN orders.order_id ELSE NULL END)
 /COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign IS NULL AND website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_typein_conversion_rates
FROM website_sessions
  LEFT JOIN orders
   ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2 ;

-- 5
-- This query calculates revenue and margin for specific product categories over time.
-- It provides insights into the financial performance of different product lines.

SELECT 
YEAR(created_at) AS YR,
MONTH(created_at) AS MTH,
SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS FUZZYBEAR_revenue,
SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS FUZZYBEAR_margin,
SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS LOVEBEAR_revenue,
SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS LOVEBEAR_margin,
SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS MINIBEAR_revenue,
SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS MINIBEAR_margin,
SUM(price_usd) AS total_revenue,
SUM(price_usd - cogs_usd) AS total_margin
FROM order_items
GROUP BY 1,2
ORDER BY 1,2;

-- 6
-- This query creates a temporary table to track website visitors who viewed the product page.
-- It later calculates click-through rates and product-to-order rates for these visitors.

CREATE TEMPORARY TABLE products_pageviews
SELECT 
-- YEAR(created_at) AS YR,
-- MONTH(created_at) AS MTH,
website_pageview_id,
website_session_id,
created_at AS saw_product_page_at
FROM website_pageviews
WHERE pageview_url = '/products'
-- GROUP BY 1,2
-- ORDER BY 1,2
;

SELECT
YEAR(saw_product_page_at) AS YR,
MONTH(saw_product_page_at) AS MTH,
COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page,
COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page,
COUNT(DISTINCT website_pageviews.website_session_id) / COUNT(DISTINCT products_pageviews.website_session_id) AS clickthrough_rate,
COUNT(DISTINCT orders.order_id) AS orders,
COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT products_pageviews.website_session_id) AS product_to_order_rate
FROM products_pageviews
   LEFT JOIN website_pageviews
     ON website_pageviews.website_session_id = products_pageviews.website_session_id
     AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
   LEFT JOIN orders
     ON orders.website_session_id = products_pageviews.website_session_id
GROUP BY 1,2 ;

-- 7
-- This series of queries examines cross-selling of products by primary product ID.
-- It provides insights into which cross-sell products are most successful and their impact on overall sales.

CREATE TEMPORARY TABLE primary_products
SELECT 
	order_id, 
    primary_product_id, 
    created_at AS ordered_at
FROM orders 
WHERE created_at > '2014-12-05' -- when the 4th product was added (says so in question)
;

/*SELECT
	primary_products.*, 
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0; -- only bringing in cross-sells;*/

SELECT 
	primary_product_id, 
    COUNT(DISTINCT order_id) AS total_orders, 
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS _xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS _xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS _xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS _xsold_p4,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) / COUNT(DISTINCT order_id) AS p1_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) / COUNT(DISTINCT order_id) AS p2_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) / COUNT(DISTINCT order_id) AS p3_xsell_rt,
    COUNT(DISTinct CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) / COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM
(
SELECT
	primary_products.*, 
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0 -- only bringing in cross-sells
) AS primary_w_cross_sell
GROUP BY 1;


SELECT
order_items.product_id,
products.product_name,
SUM(order_items.price_usd - order_items.cogs_usd)/SUM(order_items.price_usd)  as margin
FROM order_items
   LEFT JOIN products
     ON order_items.product_id = products.product_id
GROUP BY 1;

