--Data Understanding

select * from public.superstoreorders sso 

Select * from SuperStoreOrders sso limit 10



-- 1. Data Quality Assessment 

--/ Missing Values Analysis

select count(*) as liczba_wierszy 
from SuperStoreOrders sso -- 51290 rekordów

Select COUNT(order_id) from SuperStoreOrders sso 

Select
    Count(*) - Count(order_id) as brakujace_id,
    Count(*) - Count(order_date) as brakujace_daty,
    Count(*) - Count(ship_date) as brakujace_ship_date,
    Count(*) - Count(profit) as brakujace_profit,
    Count(*) - Count(ship_mode) as brakujace_ship_mode,
    Count(*) - Count(customer_name) as brakujace_customer_name,
    Count(*) - Count(segment) as brakujace_segment ,
    Count(*) - Count(state) as brakujace_state,
    Count(*) - Count(country) as brakujace_country,
    Count(*) - Count(market) as brakujace_market,
    Count(*) - Count(region) as brakujace_region,
    Count(*) - Count(product_id) as brakujace_product_id,
    Count(*) - Count(category) as brakujace_category,
    Count(*) - Count(sub_category) as brakujace_sub_category,
    Count(*) - Count(product_name) as brakujace_product_name,
    Count(*) - Count(sales) as brakujace_sales,
    Count(*) - Count(quantity) as brakujace_quantity,
    Count(*) - Count(discount) as brakujace_discount,
    Count(*) - Count(profit) as brakujace_profit,
    Count(*) - Count(shipping_cost) as brakujace_shipping_cost,
    Count(*) - Count(order_priority) as brakujace_order_priority,
    Count(*) - Count(year) as brakujace_year
    from SuperStoreOrders sso;
  

--Data Completeness Check   
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_null,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_null,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS ship_date_null,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS customer_name_null,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS product_name_null,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS sales_null,
    SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS profit_null
    FROM SuperStoreOrders sso;



--Business Rules Validation
   SELECT 
    -- 1. We check for numerical anomalies (sales and quantity cannot be less than or equal to 0).
    SUM(CASE WHEN sso.sales <= 0 THEN 1 ELSE 0 END) AS bledna_sprzedaz,
    SUM(CASE WHEN sso.quantity <= 0 THEN 1 ELSE 0 END) AS bledna_ilosc,
    SUM(CASE WHEN sso.shipping_cost < 0 THEN 1 ELSE 0 END) AS bledny_koszt_wysylki,
    SUM(CASE WHEN sso.discount < 0 OR sso.discount > 1 THEN 1 ELSE 0 END) AS bledne_rabaty,
    SUM(CASE WHEN sso.ship_date < sso.order_date THEN 1 ELSE 0 END) AS wsteczna_data_wysylki
    FROM SuperStoreOrders sso;  
   --Transactions with Non-Positive Sales: 1, Records with Ship Date Earlier Than Order Date: 10,159


--Data Anomaly Investigation   
SELECT order_id, product_name, sales, quantity, profit
FROM SuperStoreOrders sso
WHERE sales <= 0;  -- non-positive sales = 1

SELECT order_id, product_name, sales, quantity, profit
FROM SuperStoreOrders sso
WHERE sso.ship_date < sso.order_date -- wrong records 10159

SELECT *
FROM superstoreorders sso
WHERE sales <= 0;

SELECT order_id, order_date, ship_date
FROM SuperStoreOrders sso
WHERE ship_date < order_date
LIMIT 10; --wrong dates



-- Date Validation
-- Shipping Time Inspection

SELECT
    sso.order_date,
    sso.ship_date,

    CASE
        WHEN sso.ship_date LIKE '%/%'
        THEN TO_DATE(sso.ship_date, 'DD/MM/YYYY')
        ELSE TO_DATE(sso.ship_date, 'DD-MM-YYYY')
    END
    -
    CASE
        WHEN sso.order_date LIKE '%/%'
        THEN TO_DATE(sso.order_date, 'DD/MM/YYYY')
        ELSE TO_DATE(sso.order_date, 'DD-MM-YYYY')
    END AS days_diff

FROM SuperStoreOrders sso
ORDER BY days_diff desc 
LIMIT 20; --- 7 days max


--Shipping Time Analysis
SELECT
    MIN(
        CASE
            WHEN sso.ship_date LIKE '%/%'
            THEN TO_DATE(sso.ship_date,'DD/MM/YYYY')
            ELSE TO_DATE(sso.ship_date,'DD-MM-YYYY')
        END
        -
        CASE
            WHEN sso.order_date LIKE '%/%'
            THEN TO_DATE(sso.order_date,'DD/MM/YYYY')
            ELSE TO_DATE(sso.order_date,'DD-MM-YYYY')
        END
    ) AS min_days,

    MAX(
        CASE
            WHEN sso.ship_date LIKE '%/%'
            THEN TO_DATE(sso.ship_date,'DD/MM/YYYY')
            ELSE TO_DATE(sso.ship_date,'DD-MM-YYYY')
        END
        -
        CASE
            WHEN sso.order_date LIKE '%/%'
            THEN TO_DATE(sso.order_date,'DD/MM/YYYY')
            ELSE TO_DATE(sso.order_date,'DD-MM-YYYY')
        END
    ) AS max_days
FROM SuperStoreOrders sso; --min 0 days, max 7 days



--Zidentyfikowano mieszane formaty dat (DD/MM/YYYY oraz DD-MM-YYYY).
--Przekształcono wartości tekstowe na typ DATE przy użyciu CASE WHEN oraz TO_DATE().
--Obliczono liczbę dni pomiędzy datą zamówienia a datą wysyłki (days_diff).
--Zweryfikowano poprawność procesu logistycznego.
--Ustalono, że czas realizacji zamówień mieści się w zakresie 0-7 dni.
--Wykryto 10 159 pozornie błędnych rekordów, gdzie ship_date < order_date.
--Ustalono przyczynę: mieszane formaty dat (DD/MM/YYYY oraz DD-MM-YYYY).


----------------------------------

--DROP TABLE SuperStoreOrders;

--Wykryto nieprawidłową interpretację dat podczas importu.
--Usunięto tabelę i ponownie zaimportowano dane.
--Kolumny dat zostały zaimportowane jako TEXT zamiast DATE.
--Umożliwiło to późniejszą poprawną standaryzację mieszanych formatów dat.

select * from public.superstoreorders sso

-- 2. Data Cleaning

--Date Standardization Testing
SELECT
    sso.order_id,
CASE
        WHEN sso.order_date LIKE '%/%'
        THEN TO_DATE(sso.order_date, 'DD/MM/YYYY')
        ELSE TO_DATE(sso.order_date, 'DD-MM-YYYY')
    END AS order_date_clean,

    CASE
        WHEN sso.ship_date LIKE '%/%'
        THEN TO_DATE(sso.ship_date, 'DD/MM/YYYY')
        ELSE TO_DATE(sso.ship_date, 'DD-MM-YYYY')
    END AS ship_date_clean
FROM SuperStoreOrders sso
LIMIT 20;


SELECT COUNT(*)
FROM (
    SELECT
        CASE
            WHEN sso.order_date LIKE '%/%'
            THEN TO_DATE(sso.order_date, 'DD/MM/YYYY')
            ELSE TO_DATE(sso.order_date, 'DD-MM-YYYY')
        END AS order_date_clean,

        CASE
            WHEN sso.ship_date LIKE '%/%'
            THEN TO_DATE(sso.ship_date, 'DD/MM/YYYY')
            ELSE TO_DATE(sso.ship_date, 'DD-MM-YYYY')
        END AS ship_date_clean
FROM SuperStoreOrders sso
) t
WHERE ship_date_clean < order_date_clean; ---0 wrong records


--Creation of a Clean Analytical View
CREATE VIEW view_superstore_clean AS
SELECT
    sso.order_id,
CASE
        WHEN sso.order_date LIKE '%/%'
        THEN TO_DATE(sso.order_date,'DD/MM/YYYY')
        ELSE TO_DATE(sso.order_date,'DD-MM-YYYY')
    END AS order_date,

    CASE
        WHEN sso.ship_date LIKE '%/%'
        THEN TO_DATE(sso.ship_date,'DD/MM/YYYY')
        ELSE TO_DATE(sso.ship_date,'DD-MM-YYYY')
    END AS ship_date,

    sso.ship_mode,
    sso.customer_name,
    sso.segment,
    sso.state,
    sso.country,
    sso.market,
    sso.region,
    sso.product_id,
    sso.category,
    sso.sub_category,
    sso.product_name,
    sso.sales,
    sso.quantity,
    sso.discount,
    sso.profit,
    sso.shipping_cost,
    sso.order_priority,
    sso.year
FROM SuperStoreOrders sso;


--data check
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'superstoreorders';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'view_superstore_clean';

--data
SELECT *
FROM view_superstore_clean
LIMIT 10;


-- 3. Data Understanding

-- Business Data Profiling
SELECT
    COUNT(DISTINCT customer_name) AS customers,
    COUNT(DISTINCT product_name) AS products,
    COUNT(DISTINCT country) AS countries
FROM view_superstore_clean;

--The dataset includes:

--795 customers
--3788 products
--147 countries

--Total sales

SELECT
    country,
    ROUND(SUM(sales),2) AS sales
FROM view_superstore_clean
GROUP BY country
ORDER BY sales DESC -- United States = 2.3 mln




SELECT
    category,
    ROUND(SUM(profit),2) AS profit
FROM view_superstore_clean
GROUP BY category
ORDER BY profit DESC; 
--Technology      663 779
--Office Supplies 518 473
--Furniture       286 782


SELECT
    COUNT(*) AS total_rows
FROM view_superstore_clean; -- 51290


SELECT
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order
FROM view_superstore_clean;
-- oldest order,
-- newest order.

--Post-Cleaning Data Quality Validation
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_null,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_null,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS ship_date_null,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS sales_null,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity_null,
    SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS profit_null
FROM view_superstore_clean;



---Duplicate Analysis
SELECT COUNT(*) total_rows,
       COUNT(DISTINCT (
           order_id,
           product_id,
           customer_name,
           sales
       )) unique_rows
FROM view_superstore_clean; -- 9 records look suspicious.


--Potential Duplicate Detection
SELECT
    order_id,
    product_id,
    COUNT(*)
FROM view_superstore_clean
GROUP BY 1,2
HAVING COUNT(*) > 1;




---How many times does the identical combination occur?
SELECT
    *,
    COUNT(*) OVER (
        PARTITION BY
            order_id,
            product_id,
            quantity,
            sales,
            discount,
            profit,
            shipping_cost
    ) AS cnt
FROM view_superstore_clean;



--Full Duplicate Detection !
SELECT *
FROM (
    SELECT *,
           COUNT(*) OVER (
               PARTITION BY
                   order_id,
                   product_id,
                   quantity,
                   sales,
                   discount,
                   profit,
                   shipping_cost
           ) AS cnt
    FROM view_superstore_clean
) t
WHERE cnt > 1; -- 0 records, duplicates !
-- There are no records that are identical in terms of all the key transaction attributes !
-- Stage 1:
-- 9 potential duplicates

-- Stage 2:
-- detailed analysis

-- Conclusion: 0 confirmed exact duplicates !


--3. Exploratory Data Analysis (EDA)

SELECT
    MIN(sales),
    MAX(sales),
    MIN(profit),
    MAX(profit)
FROM view_superstore_clean;

SELECT
    MIN(order_date),
    MAX(order_date),
    MIN(ship_date),
    MAX(ship_date)
FROM view_superstore_clean;

SELECT COUNT(*)
FROM view_superstore_clean
WHERE ship_date < order_date;

SELECT
    MIN(discount),
    MAX(discount)
FROM view_superstore_clean;


-- highest profit ?

SELECT *
FROM view_superstore_clean
ORDER BY profit DESC
LIMIT 10;

-- greatest loss ?

SELECT *
FROM view_superstore_clean
ORDER BY profit asc
LIMIT 10;

--Discount Impact Analysis !

SELECT
    discount,
    ROUND(AVG(profit),2) AS avg_profit,
    ROUND(SUM(profit),2) AS total_profit,
    COUNT(*) AS transactions
FROM view_superstore_clean
GROUP BY discount
ORDER BY discount;
--Once the discount exceeds approximately 25–30%, the average profit becomes negative.


--Business Data Profiling
SELECT
    COUNT(DISTINCT customer_name) AS customers,
    COUNT(DISTINCT product_name) AS products,
    COUNT(DISTINCT country) AS countries,
    COUNT(DISTINCT market) AS markets
FROM view_superstore_clean;

-------------------------------------------------------------------------------

-- 795 clients, 3,788 products, 147 countries, 7 markets, 51,290 records !


select SUM(sales) / COUNT(DISTINCT customer_name) 
from view_superstore_clean;
--On average, one customer generated: 15,903 sales

--Sales Performance by Country
SELECT
    country,
    ROUND(SUM(sales),2) AS sales
FROM view_superstore_clean
GROUP BY country
ORDER BY sales DESC
LIMIT 10;

-- Subcategory Profitability Analysis
SELECT
    sub_category,
    ROUND(SUM(profit),2) AS profit
FROM view_superstore_clean
GROUP BY sub_category
ORDER BY profit DESC;



-- Subcategories with the highest losses

SELECT
    sub_category,
    ROUND(SUM(profit),2) AS profit
FROM view_superstore_clean
GROUP BY sub_category
ORDER BY profit asc

-- Tables were identified as the most unprofitable subcategory, generating a total loss of approximately $64K.



-- Top Customers Analysis

SELECT
    customer_name,
    ROUND(SUM(profit),2) AS profit
FROM view_superstore_clean
GROUP BY customer_name
ORDER BY profit DESC
LIMIT 20;



-- Profit by Country Analysis
SELECT
    country,
    ROUND(SUM(profit),2) AS profit
FROM view_superstore_clean
GROUP BY country
ORDER BY profit DESC
LIMIT 20;


-- Root Cause Analysis of Tables Losses
SELECT
    discount,
    ROUND(AVG(profit),2) AS avg_profit
FROM view_superstore_clean
WHERE sub_category = 'Tables'
GROUP BY discount
ORDER BY discount;
-- Tablets are profitable at low discount levels but become unprofitable once the discount exceeds approximately 30%.

-- Discount Impact Analysis for Tables
SELECT
    discount,
    ROUND(AVG(profit),2) AS avg_profit,
    COUNT(*) as transactions
FROM view_superstore_clean
WHERE sub_category = 'Tables'
GROUP BY discount
ORDER BY discount;


--Category Profitability Analysis

SELECT
    category,
    ROUND(SUM(sales),2) sales,
    ROUND(SUM(profit),2) profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM view_superstore_clean
GROUP BY category
ORDER BY profit_margin DESC;

-- Profit Analysis by Market

Select 
    market,
    ROUND(SUM(profit), 2) AS profit
FROM view_superstore_clean
GROUP BY market
ORDER BY profit DESC;

-- Market Profit Margin Analysis
SELECT
    market,
    ROUND(SUM(sales),2) AS sales,
    ROUND(SUM(profit),2) AS profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM view_superstore_clean
GROUP BY market
ORDER BY profit_margin DESC;

-- APAC = highest profit

-- Canada = best efficiency


-- Product-Level Profitability Analysis

select product_name,
    ROUND(SUM(profit),2) AS profit
FROM view_superstore_clean 
GROUP BY product_name
ORDER BY profit
LIMIT 10;


-- Discount Impact Analysis for a Loss-Making Product
SELECT
    discount,
    COUNT(*) AS transactions,
    ROUND(AVG(profit),2) AS avg_profit
FROM view_superstore_clean
WHERE product_name = 'Cubify CubeX 3D Printer Double Head Print'
GROUP BY discount
ORDER BY discount;


-- Profit Margin Calculation

SELECT
    sub_category,
    ROUND(SUM(sales),2) AS sales,
    ROUND(SUM(profit),2) AS profit,
    ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin,
    ROUND(SUM(profit) / NULLIF(SUM(sales),0) * 100,2) as profit_margin_2 -- the same but better :)
FROM view_superstore_clean
GROUP BY sub_category
ORDER BY profit_margin DESC;


-- Profit Margin Analysis by Category
-- Which category is the most profitable? Technology !
SELECT
    category,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM view_superstore_clean
GROUP BY category
ORDER BY profit_margin DESC;



-- Subcategory Profit Margin Analysis
SELECT
    sub_category,
    ROUND(SUM(sales),2) sales,
    ROUND(SUM(profit),2) profit,

    ROUND(
        SUM(profit) /
        NULLIF(SUM(sales),0) * 100,
        2
    ) AS profit_margin

FROM view_superstore_clean
GROUP BY sub_category
ORDER BY profit_margin; 


---Które subkategorie mają najgorszą marżę?
SELECT
    sub_category,
    ROUND(SUM(sales),2) sales,
    ROUND(SUM(profit),2) profit,

    ROUND(
        SUM(profit) /
        NULLIF(SUM(sales),0) * 100,
        2
    ) AS profit_margin

FROM view_superstore_clean
GROUP BY sub_category
ORDER BY profit_margin;
--Furniture is performing poorly, because Tables are generating a negative margin.


-- Furniture Profitability Investigation
SELECT
    category,
    sub_category,
    ROUND(SUM(profit),2) AS profit
FROM view_superstore_clean
WHERE category = 'Furniture'
GROUP BY category, sub_category
ORDER BY profit;

-- Furniture is not the problem. Tables are the problem.
-- The company sold the tables for over $757,000 but ultimately lost more than $64,000 on them.


-- Which pieces of furniture sell the best?
 
SELECT
    sub_category,
    ROUND(SUM(sales),2) AS sales,
    ROUND(SUM(profit),2) AS profit,
    ROUND(
        SUM(profit) /
        NULLIF(SUM(sales),0) * 100,
        2
    ) AS profit_margin
FROM view_superstore_clean
WHERE category = 'Furniture'
GROUP BY sub_category
ORDER BY sales DESC;


-- Do tables have, on average, higher discounts than other subcategories?

SELECT
    sub_category,
    ROUND(AVG(discount),2) AS avg_discount,
    ROUND(SUM(profit),2) AS profit
FROM view_superstore_clean
GROUP BY sub_category
ORDER BY avg_discount DESC;

-- Conclusions:
-- The Technology sector has the highest profitability: 13.99%; discounts exceeding approximately 25–30% cause average profit to turn negative..
-- Most profitable subcategories: Copiers, Phones, Bookcases
-- Biggest business problem: Tables, because Margin = -8.47%, Avg Discount = 29%, Profit = -64,084.

-- Year-over-Year Performance Analysis
SELECT
    year,
    ROUND(SUM(sales),2) AS sales,
    ROUND(SUM(profit),2) AS profit
FROM view_superstore_clean
GROUP BY year
ORDER BY year;

-- Poland Market Investigation
select * FROM view_superstore_clean
where country = 'Poland'

------------------------------------------------------------------------------------------------------------------------



