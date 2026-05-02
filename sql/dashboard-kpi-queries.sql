-- OBETA Warehouse Picking Performance Dashboard KPI Queries

-- 1. Number of Picks
SELECT COUNT(*) AS number_of_picks
FROM obeta_production.pick;

-- 2. Total Pick Volume
SELECT SUM(pick_volume) AS total_pick_volume
FROM obeta_production.pick;

-- 3. Average Order Duration
SELECT AVG(order_duration) AS average_order_duration_minutes
FROM obeta_production.pick;

-- 4. Products Used in Picks
SELECT COUNT(DISTINCT product_key) AS products_used_in_picks
FROM obeta_production.pick;

-- Alternative if product_id is directly available
-- SELECT COUNT(DISTINCT product_id) AS products_used_in_picks
-- FROM obeta_production.pick;

-- 5. Number of Orders
SELECT COUNT(*) AS number_of_orders
FROM obeta_production.`order`;

-- Alternative if order_id is directly available in the fact table
-- SELECT COUNT(DISTINCT order_id) AS number_of_orders
-- FROM obeta_production.pick;

-- 6. Picking Activity Over Time
SELECT
    year,
    month,
    COUNT(pick_id) AS number_of_picks
FROM obeta_production.pick
GROUP BY year, month
ORDER BY year, month;

-- 7. Top Product Groups by Picks
SELECT
    p.year,
    pr.product_group,
    COUNT(p.pick_id) AS number_of_picks
FROM obeta_production.pick p
JOIN obeta_production.product pr
    ON p.product_key = pr.product_key
GROUP BY p.year, pr.product_group
ORDER BY p.year, number_of_picks DESC;

-- 8. Average Duration by Origin
SELECT
    o.origin,
    AVG(p.order_duration) AS average_order_duration
FROM obeta_production.pick p
JOIN obeta_production.`order` o
    ON p.order_key = o.order_key
GROUP BY o.origin
ORDER BY average_order_duration DESC;

-- 9. Pick Volume by Warehouse Section
SELECT
    pr.warehouse_section,
    SUM(p.pick_volume) AS total_pick_volume
FROM obeta_production.pick p
JOIN obeta_production.product pr
    ON p.product_key = pr.product_key
GROUP BY pr.warehouse_section
ORDER BY total_pick_volume DESC;

-- 10. Picks by Origin
SELECT
    o.origin,
    COUNT(p.pick_id) AS number_of_picks
FROM obeta_production.pick p
JOIN obeta_production.`order` o
    ON p.order_key = o.order_key
GROUP BY o.origin
ORDER BY number_of_picks DESC;
