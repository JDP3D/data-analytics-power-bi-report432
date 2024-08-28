-- Create a view where the rows are the store types and the columns are the total sales, percentage of total sales and the count of orders

CREATE VIEW
    question4_view AS
SELECT
    store_type,
    ROUND(SUM(sale_price * "Product Quantity")::NUMERIC, 2) AS total_sales,
     -- percentage using window function
    ROUND(SUM(sale_price * "Product Quantity")::NUMERIC / 
    SUM(SUM(sale_price * "Product Quantity")::NUMERIC) OVER() * 100, 2) AS percentage_of_sales,
    COUNT(orders_powerbi."Store Code") as number_of_orders
FROM
    dim_stores
JOIN
    orders_powerbi ON orders_powerbi."Store Code" = dim_stores."store code"
JOIN
    dim_products ON dim_products.product_code  = orders_powerbi.product_code
GROUP BY
    store_type