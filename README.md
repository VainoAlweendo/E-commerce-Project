# E-commerce-Project

## Table of Contents
- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Insights and Recommendations](#insights-and-recommendations)
  

### Project Overview
---
This project showcases my skills in advanced MySQL and PowerBI. The project aims to provide the CEO with insights into the overall performance of the E-commerce shop in order to attract more investments.

![Screenshot (164)](https://github.com/VainoAlweendo/E-commerce-Project/assets/150591546/5978b044-0dd5-46e8-9978-a4777b02b553)


### Data Sources
The data is from the MySQL database named mavenfuzzyfactory. It has been made available by mavenanalytics.io.

### Tools
- MySQL Workbench - Data Analysis
- Power BI - Data Visualization

#### The data was already cleaned and formatted.

### Exploratory Data Analysis
EDA involves exploring the products that produced the most profit and the effectiveness of each marketing campaign.

- What is the overall sales trend?
- Which marketing campaigns lead to more orders?
- Which products have the best profit margins?
- What are the clickthrough rates of each product page?

### Data Analysis

Here are some of the queries from Workbench. This query creates a temporary table to track website visitors who viewed the product page. It later calculates click-through rates and product-to-order rates for these visitors.

---SQL

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

### Insights and Recommendations

- The data shows that both website sessions and orders are growing over time. this is due to our marketing campaigns, especially the GsearchNB campaign. GsearchNB has contributed to the substantial growth in orders over time and the company should look to optimize the campaign by extending its reach.
  
- The Hudson River Mini Bear has a profit margin of 68% which is very good. The company should create marketing campaigns around the products to boost orders as it can generate more profits.
  
- Experiencing a noteworthy surge in conversion rates via organic search, the company has solidified its reputation as a premier online destination for teddy bear enthusiasts. With additional funds infused into the company, there is an opportunity to enhance and elevate our marketing initiatives.

- The sum of orders trended up, resulting in a 9,746.67% increase between Sunday, January 1, 2012, and Wednesday, October 1, 2014.

### References
1. Advanced MySQL for E-commerce and Web Analytics (Udemy)

  

  


