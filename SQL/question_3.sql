-- 3.. Which German store type had the highest revenue for 2022?

SELECT
  store_type AS top_german_store_type_by_revenue_2022,
  ROUND((SUM(sale_price * "Product Quantity"))::numeric, 2) AS total_revenue
FROM
    dim_products
Join
    orders_powerbi ON orders_powerbi.product_code = dim_products.product_code
JOIN
    dim_stores ON orders_powerbi."Store Code" = dim_stores."store code"
WHERE
    date_part('year', TO_Date("Order Date", 'YYYY-MM-DD')) = 2022
    AND dim_stores.country_code = 'DE'
GROUP BY
    store_type
ORDER BY
    total_revenue DESC
LIMIT
    1