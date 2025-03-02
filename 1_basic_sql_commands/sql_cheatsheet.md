# SQL Basic Commands Cheatsheet

This cheatsheet provides an exhaustive reference for the basic SQL commands covered in the lesson:
1. SELECT, FROM, WHERE
2. INSERT, UPDATE, DELETE, MERGE
3. GROUP BY, HAVING, ORDER BY, LIMIT

## 1. SELECT, FROM, WHERE

### SELECT Statement

#### Basic Syntax
```sql
SELECT [DISTINCT | ALL] 
    [TOP n [PERCENT] [WITH TIES]] 
    column_expression [AS alias] [, ...]
FROM table_source [AS alias] [, ... | JOIN ...]
[WHERE search_condition]
```

#### Column Selection
- `SELECT *` - Select all columns
- `SELECT column1, column2` - Select specific columns
- `SELECT DISTINCT column` - Select only unique values
- `SELECT column AS alias` - Rename column in result set
- `SELECT table.column` - Qualify column with table name
- `SELECT TOP n column` - Select first n rows (SQL Server)
- `SELECT column FROM table LIMIT n` - Select first n rows (MySQL, PostgreSQL)
- `SELECT column FROM table FETCH FIRST n ROWS ONLY` - Select first n rows (Oracle, DB2)

#### Expressions in SELECT
- Arithmetic: `SELECT price * quantity AS total`
- String concatenation: `SELECT first_name || ' ' || last_name AS full_name`
- Functions: `SELECT UPPER(name), ROUND(price, 2)`
- Constants: `SELECT 'Category: ' || category, 42 AS meaning`
- CASE: `SELECT CASE WHEN price > 100 THEN 'Expensive' ELSE 'Affordable' END AS price_category`
- Subqueries: `SELECT (SELECT MAX(salary) FROM employees) AS max_salary`

### FROM Clause

#### Table Sources
- Single table: `FROM employees`
- Multiple tables: `FROM employees, departments`
- Subquery: `FROM (SELECT * FROM employees WHERE dept_id = 10) AS dept10_employees`
- Common Table Expression: `WITH dept_stats AS (SELECT...) FROM dept_stats`
- Table-valued function: `FROM dbo.GetEmployees(10)`
- Derived table: `FROM (VALUES (1, 'A'), (2, 'B')) AS t(id, name)`

#### Table Aliases
```sql
SELECT e.name, d.name 
FROM employees AS e, departments AS d
```

### WHERE Clause

#### Comparison Operators
- Equal: `WHERE salary = 50000`
- Not equal: `WHERE salary <> 50000` or `WHERE salary != 50000`
- Greater than: `WHERE salary > 50000`
- Less than: `WHERE salary < 50000`
- Greater than or equal: `WHERE salary >= 50000`
- Less than or equal: `WHERE salary <= 50000`

#### Logical Operators
- AND: `WHERE salary > 50000 AND department_id = 10`
- OR: `WHERE salary > 100000 OR position = 'Manager'`
- NOT: `WHERE NOT (salary < 50000)`
- Operator precedence: NOT, AND, OR (use parentheses to control)

#### Pattern Matching
- LIKE with wildcards:
  - `WHERE name LIKE 'A%'` - Starts with 'A'
  - `WHERE name LIKE '%son'` - Ends with 'son'
  - `WHERE name LIKE '%smith%'` - Contains 'smith'
  - `WHERE name LIKE '_a%'` - Second character is 'a'
  - `WHERE name LIKE '[ABC]%'` - Starts with A, B, or C
  - `WHERE name LIKE '[^XYZ]%'` - Doesn't start with X, Y, or Z
- ESCAPE character: `WHERE filename LIKE '%.txt' ESCAPE '\'`

#### NULL Values
- `WHERE column IS NULL` - Column has no value
- `WHERE column IS NOT NULL` - Column has a value
- Note: `column = NULL` doesn't work; always use IS NULL

#### Range Tests
- BETWEEN: `WHERE salary BETWEEN 50000 AND 100000`
- NOT BETWEEN: `WHERE salary NOT BETWEEN 50000 AND 100000`

#### List Tests
- IN: `WHERE department_id IN (10, 20, 30)`
- NOT IN: `WHERE department_id NOT IN (10, 20, 30)`
- IN with subquery: `WHERE department_id IN (SELECT id FROM departments WHERE location = 'NY')`

#### Existence Tests
- EXISTS: `WHERE EXISTS (SELECT 1 FROM orders WHERE orders.customer_id = customers.id)`
- NOT EXISTS: `WHERE NOT EXISTS (SELECT 1 FROM orders WHERE orders.customer_id = customers.id)`

#### Quantified Comparisons
- ALL: `WHERE salary > ALL (SELECT avg_salary FROM departments)`
- ANY/SOME: `WHERE salary > ANY (SELECT min_salary FROM departments)`

## 2. INSERT, UPDATE, DELETE, MERGE

### INSERT Statement

#### Basic Syntax
```sql
INSERT INTO table_name [(column1, column2, ...)]
VALUES (value1, value2, ...) [, (value1, value2, ...), ...];
```

#### Variations
- Insert single row with all columns:
```sql
INSERT INTO employees
VALUES (1, 'John', 'Smith', 50000);
```

- Insert single row with specific columns:
```sql
INSERT INTO employees (id, first_name, last_name)
VALUES (1, 'John', 'Smith');
```

- Insert multiple rows:
```sql
INSERT INTO employees (id, first_name, last_name)
VALUES 
    (1, 'John', 'Smith'),
    (2, 'Jane', 'Doe');
```

- Insert from SELECT:
```sql
INSERT INTO employees_archive (id, first_name, last_name, salary)
SELECT id, first_name, last_name, salary
FROM employees
WHERE termination_date IS NOT NULL;
```

- Insert with DEFAULT values:
```sql
INSERT INTO log_entries (log_date, message)
VALUES (DEFAULT, 'System check');
```

- Insert with expressions:
```sql
INSERT INTO order_totals (order_id, total)
VALUES (1234, (SELECT SUM(price * quantity) FROM order_items WHERE order_id = 1234));
```

- Insert with RETURNING (PostgreSQL):
```sql
INSERT INTO employees (first_name, last_name)
VALUES ('John', 'Smith')
RETURNING id, first_name, last_name;
```

### UPDATE Statement

#### Basic Syntax
```sql
UPDATE table_name
SET column1 = value1 [, column2 = value2, ...]
[WHERE condition];
```

#### Variations
- Update all rows:
```sql
UPDATE products
SET price = price * 1.1;
```

- Update with condition:
```sql
UPDATE employees
SET salary = 60000
WHERE department_id = 10 AND salary < 50000;
```

- Update with expressions:
```sql
UPDATE order_items
SET total_price = price * quantity,
    tax = price * quantity * 0.08;
```

- Update with subquery:
```sql
UPDATE employees
SET salary = (SELECT AVG(salary) FROM employees WHERE department_id = e.department_id)
WHERE performance_rating = 'Average';
```

- Update with CASE:
```sql
UPDATE employees
SET salary = CASE
    WHEN performance_rating = 'Excellent' THEN salary * 1.2
    WHEN performance_rating = 'Good' THEN salary * 1.1
    ELSE salary
END;
```

- Update with JOIN (SQL Server):
```sql
UPDATE e
SET e.salary = e.salary * 1.1
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE d.name = 'Sales';
```

- Update with RETURNING (PostgreSQL):
```sql
UPDATE employees
SET salary = salary * 1.1
WHERE department_id = 10
RETURNING id, first_name, last_name, salary;
```

### DELETE Statement

#### Basic Syntax
```sql
DELETE FROM table_name
[WHERE condition];
```

#### Variations
- Delete all rows:
```sql
DELETE FROM temporary_logs;
```

- Delete with condition:
```sql
DELETE FROM employees
WHERE termination_date < '2020-01-01';
```

- Delete with subquery:
```sql
DELETE FROM customers
WHERE id NOT IN (SELECT DISTINCT customer_id FROM orders);
```

- Delete with JOIN (SQL Server):
```sql
DELETE e
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE d.is_active = 0;
```

- Delete with USING (PostgreSQL):
```sql
DELETE FROM employees
USING departments
WHERE employees.department_id = departments.id AND departments.is_active = 0;
```

- Delete with RETURNING (PostgreSQL):
```sql
DELETE FROM employees
WHERE department_id = 10
RETURNING id, first_name, last_name;
```

- Delete with TOP/LIMIT:
```sql
DELETE TOP(100) FROM error_logs; -- SQL Server
DELETE FROM error_logs LIMIT 100; -- MySQL
```

### MERGE Statement (Upsert)

#### Basic Syntax
```sql
MERGE INTO target_table [AS target]
USING source_table [AS source]
ON join_condition
WHEN MATCHED [AND condition] THEN
    UPDATE SET column1 = value1 [, column2 = value2, ...]
WHEN NOT MATCHED [BY TARGET] [AND condition] THEN
    INSERT [(column1 [, column2, ...])]
    VALUES (value1 [, value2, ...])
[WHEN NOT MATCHED BY SOURCE [AND condition] THEN
    DELETE];
```

#### Variations
- Basic MERGE (insert or update):
```sql
MERGE INTO customers AS target
USING staged_customers AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET 
        target.name = source.name,
        target.email = source.email,
        target.updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
    INSERT (id, name, email, created_at)
    VALUES (source.id, source.name, source.email, CURRENT_TIMESTAMP);
```

- MERGE with DELETE option:
```sql
MERGE INTO inventory AS target
USING product_catalog AS source
ON target.product_id = source.id
WHEN MATCHED AND source.is_discontinued = 1 THEN
    DELETE
WHEN MATCHED THEN
    UPDATE SET 
        target.price = source.price,
        target.quantity = target.quantity + source.quantity
WHEN NOT MATCHED THEN
    INSERT (product_id, price, quantity)
    VALUES (source.id, source.price, source.quantity);
```

- MERGE with conditions:
```sql
MERGE INTO employees AS target
USING employee_updates AS source
ON target.id = source.id
WHEN MATCHED AND source.salary > target.salary THEN
    UPDATE SET 
        target.salary = source.salary,
        target.updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED AND source.hire_date > '2023-01-01' THEN
    INSERT (id, first_name, last_name, salary, hire_date)
    VALUES (source.id, source.first_name, source.last_name, source.salary, source.hire_date);
```

- MERGE with OUTPUT (SQL Server):
```sql
MERGE INTO customers AS target
USING staged_customers AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET target.name = source.name
WHEN NOT MATCHED THEN
    INSERT (id, name) VALUES (source.id, source.name)
OUTPUT $action, inserted.id, inserted.name;
```

## 3. GROUP BY, HAVING, ORDER BY, LIMIT

### GROUP BY Clause

#### Basic Syntax
```sql
SELECT column1, column2, aggregate_function(column3)
FROM table_name
[WHERE condition]
GROUP BY column1, column2 [, ...];
```

#### Aggregate Functions
- `COUNT(*)` - Count all rows
- `COUNT(column)` - Count non-NULL values in column
- `COUNT(DISTINCT column)` - Count unique non-NULL values
- `SUM(column)` - Sum of values in column
- `AVG(column)` - Average of values in column
- `MIN(column)` - Minimum value in column
- `MAX(column)` - Maximum value in column
- `STDDEV(column)` - Standard deviation of values
- `VARIANCE(column)` - Variance of values
- `STRING_AGG(column, delimiter)` - Concatenate strings with delimiter (SQL Server)
- `GROUP_CONCAT(column)` - Concatenate strings (MySQL)
- `LISTAGG(column, delimiter)` - Concatenate strings (Oracle)
- `array_agg(column)` - Aggregate values into array (PostgreSQL)
- `json_agg(column)` - Aggregate values into JSON array (PostgreSQL)

#### Grouping Options
- Group by single column:
```sql
SELECT department_id, COUNT(*) as employee_count
FROM employees
GROUP BY department_id;
```

- Group by multiple columns:
```sql
SELECT department_id, job_title, AVG(salary) as avg_salary
FROM employees
GROUP BY department_id, job_title;
```

- Group by expression:
```sql
SELECT YEAR(hire_date) as hire_year, COUNT(*) as hire_count
FROM employees
GROUP BY YEAR(hire_date);
```

- Group by column position (not recommended):
```sql
SELECT department_id, COUNT(*) as employee_count
FROM employees
GROUP BY 1;
```

- GROUPING SETS (SQL Server, PostgreSQL, Oracle):
```sql
SELECT department_id, job_title, COUNT(*) as employee_count
FROM employees
GROUP BY GROUPING SETS (
    (department_id, job_title),
    (department_id),
    (job_title),
    ()
);
```

- ROLLUP (hierarchical subtotals):
```sql
SELECT region, country, city, SUM(sales) as total_sales
FROM sales_data
GROUP BY ROLLUP (region, country, city);
```

- CUBE (all possible combinations):
```sql
SELECT region, country, product, SUM(sales) as total_sales
FROM sales_data
GROUP BY CUBE (region, country, product);
```

### HAVING Clause

#### Basic Syntax
```sql
SELECT column1, column2, aggregate_function(column3)
FROM table_name
[WHERE condition]
GROUP BY column1, column2 [, ...]
HAVING having_condition;
```

#### HAVING vs WHERE
- WHERE filters rows before grouping
- HAVING filters groups after grouping
- HAVING can use aggregate functions, WHERE cannot

#### Examples
- Basic HAVING:
```sql
SELECT department_id, COUNT(*) as employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 10;
```

- HAVING with multiple conditions:
```sql
SELECT department_id, AVG(salary) as avg_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 50000 AND COUNT(*) >= 5;
```

- HAVING with expressions:
```sql
SELECT product_category, SUM(sales) as total_sales
FROM sales_data
GROUP BY product_category
HAVING SUM(sales) > 1000000 AND MAX(sales) / MIN(sales) < 100;
```

- HAVING with subquery:
```sql
SELECT department_id, AVG(salary) as avg_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > (SELECT AVG(salary) * 1.2 FROM employees);
```

### ORDER BY Clause

#### Basic Syntax
```sql
SELECT column1, column2, ...
FROM table_name
[WHERE condition]
[GROUP BY column1, column2, ...]
[HAVING condition]
ORDER BY column1 [ASC|DESC] [, column2 [ASC|DESC], ...];
```

#### Sorting Options
- Sort by single column ascending (default):
```sql
SELECT * FROM employees
ORDER BY last_name;
```

- Sort by single column descending:
```sql
SELECT * FROM employees
ORDER BY salary DESC;
```

- Sort by multiple columns:
```sql
SELECT * FROM employees
ORDER BY department_id ASC, salary DESC;
```

- Sort by column position:
```sql
SELECT first_name, last_name, hire_date
FROM employees
ORDER BY 3 DESC;
```

- Sort by expression:
```sql
SELECT first_name, last_name, salary
FROM employees
ORDER BY salary * 1.1;
```

- Sort by CASE expression:
```sql
SELECT first_name, last_name, department_id
FROM employees
ORDER BY CASE
    WHEN department_id = 10 THEN 1
    WHEN department_id = 20 THEN 2
    ELSE 3
END;
```

- Sort with NULLS FIRST/LAST (PostgreSQL, Oracle):
```sql
SELECT first_name, last_name, commission
FROM employees
ORDER BY commission DESC NULLS LAST;
```

### LIMIT/OFFSET Clause

#### Basic Syntax (varies by database)
```sql
-- MySQL, PostgreSQL, SQLite
SELECT column1, column2, ...
FROM table_name
[WHERE condition]
[ORDER BY column1 [ASC|DESC]]
LIMIT row_count [OFFSET offset_value];

-- SQL Server
SELECT [TOP row_count] column1, column2, ...
FROM table_name
[WHERE condition]
[ORDER BY column1 [ASC|DESC]];

-- Oracle
SELECT column1, column2, ...
FROM table_name
[WHERE condition]
[ORDER BY column1 [ASC|DESC]]
FETCH FIRST row_count ROWS ONLY [OFFSET offset_value ROWS];
```

#### Examples
- Basic LIMIT:
```sql
SELECT * FROM employees
ORDER BY salary DESC
LIMIT 10;
```

- LIMIT with OFFSET:
```sql
SELECT * FROM employees
ORDER BY hire_date DESC
LIMIT 10 OFFSET 20;
```

- Pagination example:
```sql
-- Page 3 with 25 items per page
SELECT * FROM products
ORDER BY name
LIMIT 25 OFFSET 50;
```

- TOP with ties (SQL Server):
```sql
SELECT TOP 10 WITH TIES *
FROM employees
ORDER BY salary DESC;
```

- FETCH FIRST (Oracle, PostgreSQL):
```sql
SELECT * FROM employees
ORDER BY salary DESC
FETCH FIRST 10 ROWS ONLY;
```

- FETCH with OFFSET (Oracle, PostgreSQL):
```sql
SELECT * FROM employees
ORDER BY hire_date DESC
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;
```

- FETCH with PERCENT (Oracle, PostgreSQL):
```sql
SELECT * FROM employees
ORDER BY salary DESC
FETCH FIRST 5 PERCENT ROWS ONLY;
```

## Additional Notes

### SQL Execution Order
The logical order in which SQL clauses are processed:
1. FROM (including JOINs)
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT (including expressions and aggregates)
6. ORDER BY
7. LIMIT/OFFSET

This is important to understand when troubleshooting queries or understanding why certain constructs work or don't work.

### Common Table Expressions (CTEs)
While not explicitly covered in the lesson, CTEs are often used with these basic commands:

```sql
WITH employee_stats AS (
    SELECT department_id, COUNT(*) as employee_count, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT d.name, es.employee_count, es.avg_salary
FROM employee_stats es
JOIN departments d ON es.department_id = d.id
ORDER BY es.avg_salary DESC;
```

### Subqueries
Subqueries can be used in various parts of the basic commands:

- In SELECT:
```sql
SELECT 
    e.name,
    (SELECT COUNT(*) FROM projects p WHERE p.manager_id = e.id) as project_count
FROM employees e;
```

- In FROM:
```sql
SELECT dept_name, avg_salary
FROM (
    SELECT d.name as dept_name, AVG(e.salary) as avg_salary
    FROM employees e
    JOIN departments d ON e.department_id = d.id
    GROUP BY d.name
) as dept_stats
WHERE avg_salary > 50000;
```

- In WHERE:
```sql
SELECT *
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

- In HAVING:
```sql
SELECT department_id, AVG(salary)
FROM employees
GROUP BY department_id
HAVING AVG(salary) > (SELECT AVG(salary) FROM employees);
``` 