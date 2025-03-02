-- 6. ANALYTICAL & PERFORMANCE FEATURES
-- This file covers SQL features for query optimization and analytical processing

-- 6.1 Query Optimization (EXPLAIN, ANALYZE, INDEX HINTS)
-- EXPLAIN example (PostgreSQL style)
EXPLAIN ANALYZE
SELECT 
    main_table.column1, 
    main_table.column2
FROM main_table
WHERE main_table.boolean_column = TRUE;

-- Index hint example (MySQL style)
SELECT 
    main_table.column1, 
    main_table.column2
FROM main_table USE INDEX (idx_boolean_column)
WHERE main_table.boolean_column = TRUE;

-- Oracle hint example
SELECT /*+ INDEX(main_table idx_boolean_column) */
    main_table.column1, 
    main_table.column2
FROM main_table
WHERE main_table.boolean_column = TRUE;

-- 6.2 Materialized Views (CREATE MATERIALIZED VIEW)
-- PostgreSQL style materialized view
CREATE MATERIALIZED VIEW sales_summary AS
SELECT 
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(amount) AS total_amount
FROM sales
GROUP BY product_id
WITH DATA;

-- Refreshing a materialized view
REFRESH MATERIALIZED VIEW sales_summary;

-- Oracle style materialized view with refresh options
CREATE MATERIALIZED VIEW sales_summary
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(amount) AS total_amount
FROM sales
GROUP BY product_id;

-- 6.3 Partitioning (PARTITION BY RANGE, PARTITION BY HASH)
-- PostgreSQL table partitioning by range
CREATE TABLE sales (
    id SERIAL,
    sale_date DATE NOT NULL,
    amount DECIMAL(10,2)
) PARTITION BY RANGE (sale_date);

-- Creating partitions
CREATE TABLE sales_2020 PARTITION OF sales
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');

CREATE TABLE sales_2021 PARTITION OF sales
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');

-- MySQL hash partitioning
CREATE TABLE employees (
    id INT NOT NULL,
    name VARCHAR(100),
    department_id INT
)
PARTITION BY HASH(id)
PARTITIONS 4;

-- Oracle list partitioning
CREATE TABLE sales_regions (
    id NUMBER,
    region_code VARCHAR2(10),
    amount NUMBER
)
PARTITION BY LIST (region_code) (
    PARTITION north VALUES ('N', 'NE', 'NW'),
    PARTITION south VALUES ('S', 'SE', 'SW'),
    PARTITION east VALUES ('E'),
    PARTITION west VALUES ('W')
);

-- Note: These features help optimize query performance for large datasets.
-- The appropriate technique depends on the specific database system and use case. 