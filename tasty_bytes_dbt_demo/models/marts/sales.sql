SELECT 
    DATE(oh.order_ts) AS order_date,
    l.location_id,
    l.location AS location_name,
    l.city,
    l.region,
    l.country,
    t.truck_brand_name,
    m.menu_type,
    m.menu_item_name,
    m.item_category,
    -- Sales metrics
    COUNT(DISTINCT oh.order_id) AS total_orders,
    COUNT(DISTINCT oh.customer_id) AS unique_customers,
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.price) AS gross_sales,
    SUM(oh.order_discount_amount) AS total_discounts,
    SUM(oh.order_tax_amount) AS total_tax,
    SUM(oh.order_total) AS net_sales,
    -- Profitability metrics
    SUM(od.quantity * m.cost_of_goods_usd) AS total_cogs,
    SUM(od.price) - SUM(od.quantity * m.cost_of_goods_usd) AS gross_profit,
    -- Average metrics
    AVG(oh.order_total) AS avg_order_value,
    AVG(od.price) AS avg_item_price,
    AVG(od.quantity) AS avg_quantity_per_line
FROM {{ ref('raw_pos_order_header') }} oh
JOIN {{ ref('raw_pos_order_detail') }} od
    ON oh.order_id = od.order_id
JOIN {{ ref('raw_pos_location') }} l
    ON oh.location_id = l.location_id
JOIN {{ ref('raw_pos_truck') }} t
    ON oh.truck_id = t.truck_id
JOIN {{ ref('raw_pos_menu') }} m
    ON od.menu_item_id = m.menu_item_id
GROUP BY 
    DATE(oh.order_ts),
    l.location_id,
    l.location,
    l.city,
    l.region,
    l.country,
    t.truck_brand_name,
    m.menu_type,
    m.menu_item_name,
    m.item_category
