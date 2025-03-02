# SQL Analytical and Performance Features Cheatsheet

This cheatsheet provides a comprehensive reference for SQL analytical and performance features:
1. Query Optimization
2. Materialized Views
3. Partitioning

## 1. Query Optimization

### EXPLAIN and ANALYZE Commands

#### PostgreSQL
```sql
-- Basic EXPLAIN
EXPLAIN
SELECT * FROM employees WHERE department_id = 10;

-- EXPLAIN with execution details
EXPLAIN ANALYZE
SELECT * FROM employees WHERE department_id = 10;

-- EXPLAIN with formatting options
EXPLAIN (FORMAT JSON)
SELECT * FROM employees WHERE department_id = 10;

-- EXPLAIN with additional analysis
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT * FROM employees WHERE department_id = 10;
```

#### MySQL
```sql
-- Basic EXPLAIN
EXPLAIN
SELECT * FROM employees WHERE department_id = 10;

-- EXPLAIN with extended information
EXPLAIN EXTENDED
SELECT * FROM employees WHERE department_id = 10;

-- EXPLAIN with execution details
EXPLAIN ANALYZE
SELECT * FROM employees WHERE department_id = 10;

-- EXPLAIN with formatting options
EXPLAIN FORMAT=JSON
SELECT * FROM employees WHERE department_id = 10;
```

#### Oracle
```sql
-- Basic EXPLAIN PLAN
EXPLAIN PLAN FOR
SELECT * FROM employees WHERE department_id = 10;

-- View the execution plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- More detailed execution plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR);

-- Execution plan with statistics
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
```

#### SQL Server
```sql
-- Basic execution plan (displays graphical plan)
SET SHOWPLAN_ALL ON;
GO
SELECT * FROM employees WHERE department_id = 10;
GO
SET SHOWPLAN_ALL OFF;
GO

-- Execution plan with statistics
SET STATISTICS PROFILE ON;
GO
SELECT * FROM employees WHERE department_id = 10;
GO
SET STATISTICS PROFILE OFF;
GO

-- Execution plan with IO statistics
SET STATISTICS IO ON;
GO
SELECT * FROM employees WHERE department_id = 10;
GO
SET STATISTICS IO OFF;
GO
```

### Index Hints and Optimizer Directives

#### MySQL
```sql
-- Force index usage
SELECT * FROM employees USE INDEX (idx_department_id)
WHERE department_id = 10;

-- Ignore specific index
SELECT * FROM employees IGNORE INDEX (idx_name)
WHERE department_id = 10;

-- Force specific join order
SELECT * FROM employees STRAIGHT_JOIN departments
ON employees.department_id = departments.id
WHERE departments.location = 'New York';
```

#### PostgreSQL
```sql
-- Enable/disable specific methods
SET enable_seqscan = OFF;
SET enable_indexscan = ON;

-- Set statistics target for better plans
ALTER TABLE employees ALTER COLUMN department_id SET STATISTICS 1000;

-- Set cost parameters
SET random_page_cost = 1.5;
SET seq_page_cost = 1.0;
```

#### Oracle
```sql
-- Index hint
SELECT /*+ INDEX(employees emp_dept_idx) */ *
FROM employees
WHERE department_id = 10;

-- Full table scan hint
SELECT /*+ FULL(employees) */ *
FROM employees
WHERE department_id = 10;

-- Join order hint
SELECT /*+ LEADING(departments employees) */ *
FROM employees
JOIN departments ON employees.department_id = departments.id;

-- Parallel execution hint
SELECT /*+ PARALLEL(employees, 4) */ *
FROM employees
WHERE department_id = 10;
```

#### SQL Server
```sql
-- Index hint
SELECT * FROM employees WITH (INDEX(idx_department_id))
WHERE department_id = 10;

-- Force specific join type
SELECT * FROM employees e
INNER MERGE JOIN departments d ON e.department_id = d.id
WHERE d.location = 'New York';

-- Query optimizer hint
SELECT * FROM employees WITH (FORCESEEK)
WHERE department_id = 10;

-- Recompile hint
SELECT * FROM employees WITH (RECOMPILE)
WHERE department_id = 10;
```

### Query Plan Analysis

#### Key Metrics to Look For
1. **Scan Types**:
   - Sequential Scan/Table Scan: Reads entire table (expensive for large tables)
   - Index Scan: Uses an index to find rows
   - Index Only Scan: Retrieves data directly from index (most efficient)
   - Bitmap Scan: Uses bitmap to track qualifying rows

2. **Join Types**:
   - Nested Loop Join: Good for small tables or indexed joins
   - Hash Join: Good for larger tables without suitable indexes
   - Merge Join: Good for pre-sorted data

3. **Cost Estimates**:
   - Startup Cost: Cost before first row is retrieved
   - Total Cost: Estimated total cost of the operation
   - Rows: Estimated number of rows returned
   - Width: Estimated average width of rows in bytes

4. **Potential Issues**:
   - Missing indexes
   - Inefficient join methods
   - Filter conditions not using indexes
   - Excessive sorting operations

### Performance Tuning Techniques

#### Indexing Strategies
```sql
-- Create basic index
CREATE INDEX idx_employees_dept ON employees(department_id);

-- Create composite index
CREATE INDEX idx_employees_dept_job ON employees(department_id, job_id);

-- Create unique index
CREATE UNIQUE INDEX idx_employees_email ON employees(email);

-- Create functional index
CREATE INDEX idx_employees_upper_name ON employees(UPPER(last_name));

-- Create partial index (PostgreSQL)
CREATE INDEX idx_active_employees ON employees(id) WHERE status = 'ACTIVE';
```

#### Statistics Management
```sql
-- PostgreSQL: Update statistics
ANALYZE employees;

-- MySQL: Update statistics
ANALYZE TABLE employees;

-- Oracle: Gather statistics
EXEC DBMS_STATS.GATHER_TABLE_STATS('schema_name', 'employees');

-- SQL Server: Update statistics
UPDATE STATISTICS employees;
```

#### Query Rewriting
```sql
-- Original query with subquery
SELECT * FROM employees 
WHERE department_id IN (SELECT id FROM departments WHERE location = 'New York');

-- Rewritten with join (often more efficient)
SELECT e.* FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE d.location = 'New York';

-- Original query with OR conditions
SELECT * FROM employees
WHERE department_id = 10 OR department_id = 20;

-- Rewritten with IN (often more efficient)
SELECT * FROM employees
WHERE department_id IN (10, 20);
```

## 2. Materialized Views

### Creating Materialized Views

#### PostgreSQL
```sql
-- Basic materialized view
CREATE MATERIALIZED VIEW sales_summary AS
SELECT 
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(amount) AS total_amount
FROM sales
GROUP BY product_id
WITH DATA;

-- Materialized view without initial data
CREATE MATERIALIZED VIEW sales_summary AS
SELECT 
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(amount) AS total_amount
FROM sales
GROUP BY product_id
WITH NO DATA;

-- Materialized view with index
CREATE MATERIALIZED VIEW sales_summary AS
SELECT 
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(amount) AS total_amount
FROM sales
GROUP BY product_id
WITH DATA;

CREATE INDEX idx_sales_summary_product ON sales_summary(product_id);
```

#### Oracle
```sql
-- Basic materialized view
CREATE MATERIALIZED VIEW sales_summary AS
SELECT 
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(amount) AS total_amount
FROM sales
GROUP BY product_id;

-- Materialized view with refresh options
CREATE MATERIALIZED VIEW sales_summary
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(amount) AS total_amount
FROM sales
GROUP BY product_id;

-- Materialized view with fast refresh
CREATE MATERIALIZED VIEW sales_summary
REFRESH FAST ON COMMIT
ENABLE QUERY REWRITE
AS
SELECT 
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(amount) AS total_amount
FROM sales
GROUP BY product_id;
```

#### SQL Server (Indexed Views)
```sql
-- Create view with schema binding
CREATE VIEW sales_summary
WITH SCHEMABINDING
AS
SELECT 
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(amount) AS total_amount,
    COUNT_BIG(*) AS row_count
FROM dbo.sales
GROUP BY product_id;

-- Create unique clustered index to materialize the view
CREATE UNIQUE CLUSTERED INDEX idx_sales_summary 
ON sales_summary(product_id);
```

### Refreshing Materialized Views

#### PostgreSQL
```sql
-- Complete refresh
REFRESH MATERIALIZED VIEW sales_summary;

-- Concurrent refresh (doesn't block queries)
REFRESH MATERIALIZED VIEW CONCURRENTLY sales_summary;
```

#### Oracle
```sql
-- Complete refresh
EXEC DBMS_MVIEW.REFRESH('sales_summary', 'C');

-- Fast refresh
EXEC DBMS_MVIEW.REFRESH('sales_summary', 'F');

-- Force refresh
EXEC DBMS_MVIEW.REFRESH('sales_summary', '?');

-- Refresh all materialized views
EXEC DBMS_MVIEW.REFRESH_ALL_MVIEWS;
```

### Query Rewriting with Materialized Views

#### Oracle
```sql
-- Enable query rewrite globally
ALTER SYSTEM SET QUERY_REWRITE_ENABLED = TRUE;

-- Enable query rewrite for session
ALTER SESSION SET QUERY_REWRITE_ENABLED = TRUE;

-- Create materialized view with query rewrite enabled
CREATE MATERIALIZED VIEW sales_summary
ENABLE QUERY REWRITE
AS
SELECT 
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(amount) AS total_amount
FROM sales
GROUP BY product_id;
```

### Incremental View Maintenance

#### Oracle
```sql
-- Create materialized view log for fast refresh
CREATE MATERIALIZED VIEW LOG ON sales
WITH ROWID, SEQUENCE (product_id, quantity, amount)
INCLUDING NEW VALUES;

-- Create materialized view with fast refresh
CREATE MATERIALIZED VIEW sales_summary
REFRESH FAST ON COMMIT
AS
SELECT 
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(amount) AS total_amount
FROM sales
GROUP BY product_id;
```

### View Invalidation and Validation

#### PostgreSQL
```sql
-- Check materialized view status
SELECT relname, relispopulated
FROM pg_class
WHERE relname = 'sales_summary';

-- Validate materialized view
REFRESH MATERIALIZED VIEW sales_summary;
```

#### Oracle
```sql
-- Check materialized view status
SELECT mview_name, staleness, last_refresh_date
FROM user_mviews;

-- Compile invalid materialized view
ALTER MATERIALIZED VIEW sales_summary COMPILE;
```

## 3. Partitioning

### Range Partitioning

#### PostgreSQL
```sql
-- Create partitioned table
CREATE TABLE sales (
    id SERIAL,
    sale_date DATE NOT NULL,
    amount DECIMAL(10,2)
) PARTITION BY RANGE (sale_date);

-- Create partitions
CREATE TABLE sales_2020 PARTITION OF sales
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');

CREATE TABLE sales_2021 PARTITION OF sales
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');

CREATE TABLE sales_2022 PARTITION OF sales
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');
```

#### Oracle
```sql
-- Create range-partitioned table
CREATE TABLE sales (
    id NUMBER,
    sale_date DATE,
    amount NUMBER(10,2)
)
PARTITION BY RANGE (sale_date) (
    PARTITION sales_2020 VALUES LESS THAN (TO_DATE('2021-01-01', 'YYYY-MM-DD')),
    PARTITION sales_2021 VALUES LESS THAN (TO_DATE('2022-01-01', 'YYYY-MM-DD')),
    PARTITION sales_2022 VALUES LESS THAN (TO_DATE('2023-01-01', 'YYYY-MM-DD')),
    PARTITION sales_future VALUES LESS THAN (MAXVALUE)
);
```

#### MySQL
```sql
-- Create range-partitioned table
CREATE TABLE sales (
    id INT AUTO_INCREMENT,
    sale_date DATE NOT NULL,
    amount DECIMAL(10,2),
    PRIMARY KEY (id, sale_date)
)
PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

### Hash Partitioning

#### PostgreSQL
```sql
-- Create hash-partitioned table
CREATE TABLE employees (
    id INT NOT NULL,
    name VARCHAR(100),
    department_id INT
) PARTITION BY HASH (id);

-- Create partitions
CREATE TABLE employees_p0 PARTITION OF employees
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE employees_p1 PARTITION OF employees
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE employees_p2 PARTITION OF employees
    FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE employees_p3 PARTITION OF employees
    FOR VALUES WITH (MODULUS 4, REMAINDER 3);
```

#### Oracle
```sql
-- Create hash-partitioned table
CREATE TABLE employees (
    id NUMBER,
    name VARCHAR2(100),
    department_id NUMBER
)
PARTITION BY HASH (id)
PARTITIONS 4
STORE IN (tablespace1, tablespace2, tablespace3, tablespace4);
```

#### MySQL
```sql
-- Create hash-partitioned table
CREATE TABLE employees (
    id INT NOT NULL,
    name VARCHAR(100),
    department_id INT,
    PRIMARY KEY (id)
)
PARTITION BY HASH(id)
PARTITIONS 4;
```

### List Partitioning

#### PostgreSQL
```sql
-- Create list-partitioned table
CREATE TABLE sales_regions (
    id INT,
    region_code VARCHAR(10),
    amount DECIMAL(10,2)
) PARTITION BY LIST (region_code);

-- Create partitions
CREATE TABLE sales_north PARTITION OF sales_regions
    FOR VALUES IN ('N', 'NE', 'NW');
CREATE TABLE sales_south PARTITION OF sales_regions
    FOR VALUES IN ('S', 'SE', 'SW');
CREATE TABLE sales_east PARTITION OF sales_regions
    FOR VALUES IN ('E');
CREATE TABLE sales_west PARTITION OF sales_regions
    FOR VALUES IN ('W');
```

#### Oracle
```sql
-- Create list-partitioned table
CREATE TABLE sales_regions (
    id NUMBER,
    region_code VARCHAR2(10),
    amount NUMBER(10,2)
)
PARTITION BY LIST (region_code) (
    PARTITION north VALUES ('N', 'NE', 'NW'),
    PARTITION south VALUES ('S', 'SE', 'SW'),
    PARTITION east VALUES ('E'),
    PARTITION west VALUES ('W')
);
```

#### MySQL
```sql
-- Create list-partitioned table
CREATE TABLE sales_regions (
    id INT,
    region_code VARCHAR(10),
    amount DECIMAL(10,2),
    PRIMARY KEY (id, region_code)
)
PARTITION BY LIST COLUMNS(region_code) (
    PARTITION north VALUES IN ('N', 'NE', 'NW'),
    PARTITION south VALUES IN ('S', 'SE', 'SW'),
    PARTITION east VALUES IN ('E'),
    PARTITION west VALUES IN ('W')
);
```

### Partition Pruning

Partition pruning is an optimization where the database engine only accesses the partitions needed for a query.

#### Example Queries That Benefit from Partition Pruning

```sql
-- Range partition pruning
SELECT * FROM sales 
WHERE sale_date BETWEEN '2021-01-01' AND '2021-12-31';
-- Only accesses the sales_2021 partition

-- Hash partition pruning
SELECT * FROM employees WHERE id = 1001;
-- Only accesses the partition containing id 1001

-- List partition pruning
SELECT * FROM sales_regions WHERE region_code = 'NE';
-- Only accesses the north partition
```

### Partition-wise Joins

Partition-wise joins optimize joins between tables that are partitioned on the join key.

#### Oracle
```sql
-- Create two tables partitioned on the same key
CREATE TABLE orders (
    order_id NUMBER,
    customer_id NUMBER,
    order_date DATE
)
PARTITION BY RANGE (order_date) (
    PARTITION orders_q1_2021 VALUES LESS THAN (TO_DATE('2021-04-01', 'YYYY-MM-DD')),
    PARTITION orders_q2_2021 VALUES LESS THAN (TO_DATE('2021-07-01', 'YYYY-MM-DD')),
    PARTITION orders_q3_2021 VALUES LESS THAN (TO_DATE('2021-10-01', 'YYYY-MM-DD')),
    PARTITION orders_q4_2021 VALUES LESS THAN (TO_DATE('2022-01-01', 'YYYY-MM-DD'))
);

CREATE TABLE order_items (
    item_id NUMBER,
    order_id NUMBER,
    order_date DATE,
    product_id NUMBER,
    quantity NUMBER
)
PARTITION BY RANGE (order_date) (
    PARTITION items_q1_2021 VALUES LESS THAN (TO_DATE('2021-04-01', 'YYYY-MM-DD')),
    PARTITION items_q2_2021 VALUES LESS THAN (TO_DATE('2021-07-01', 'YYYY-MM-DD')),
    PARTITION items_q3_2021 VALUES LESS THAN (TO_DATE('2021-10-01', 'YYYY-MM-DD')),
    PARTITION items_q4_2021 VALUES LESS THAN (TO_DATE('2022-01-01', 'YYYY-MM-DD'))
);

-- Query that benefits from partition-wise join
SELECT o.order_id, o.customer_id, oi.product_id, oi.quantity
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id AND o.order_date = oi.order_date
WHERE o.order_date BETWEEN TO_DATE('2021-04-01', 'YYYY-MM-DD') 
                        AND TO_DATE('2021-06-30', 'YYYY-MM-DD');
-- Only joins the Q2 partitions of both tables
```

### Partition Maintenance

#### Adding Partitions

```sql
-- PostgreSQL
CREATE TABLE sales_2023 PARTITION OF sales
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

-- Oracle
ALTER TABLE sales ADD PARTITION sales_2023
    VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD'));

-- MySQL
ALTER TABLE sales ADD PARTITION (
    PARTITION p2023 VALUES LESS THAN (2024)
);
```

#### Dropping Partitions

```sql
-- PostgreSQL
DROP TABLE sales_2020;
-- or
ALTER TABLE sales DETACH PARTITION sales_2020;

-- Oracle
ALTER TABLE sales DROP PARTITION sales_2020;

-- MySQL
ALTER TABLE sales DROP PARTITION p2020;
```

#### Splitting Partitions

```sql
-- Oracle
ALTER TABLE sales SPLIT PARTITION sales_2021 AT (TO_DATE('2021-07-01', 'YYYY-MM-DD'))
    INTO (PARTITION sales_2021_h1, PARTITION sales_2021_h2);

-- MySQL
ALTER TABLE sales REORGANIZE PARTITION p2021 INTO (
    PARTITION p2021_h1 VALUES LESS THAN (2021.5),
    PARTITION p2021_h2 VALUES LESS THAN (2022)
);
```

#### Merging Partitions

```sql
-- Oracle
ALTER TABLE sales MERGE PARTITIONS sales_2020, sales_2021
    INTO PARTITION sales_2020_2021;

-- MySQL
ALTER TABLE sales REORGANIZE PARTITION p2020, p2021 INTO (
    PARTITION p2020_2021 VALUES LESS THAN (2022)
);
``` 