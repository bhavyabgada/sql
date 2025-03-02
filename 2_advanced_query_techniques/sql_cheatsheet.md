# SQL Advanced Query Techniques Cheatsheet

This cheatsheet provides an exhaustive reference for advanced SQL query techniques covered in the lesson:
1. Joins (INNER, LEFT, RIGHT, FULL OUTER, CROSS)
2. Subqueries (EXISTS, IN, NOT IN, SCALAR SUBQUERY)
3. Common Table Expressions (CTE)
4. Window Functions
5. Hierarchical Queries

## 1. Joins

### Types of Joins

#### INNER JOIN
```sql
SELECT t1.column1, t2.column2
FROM table1 t1
INNER JOIN table2 t2 ON t1.key = t2.key;
```
- Returns only matching rows from both tables
- Rows without matches are excluded
- Most common join type

#### LEFT JOIN (LEFT OUTER JOIN)
```sql
SELECT t1.column1, t2.column2
FROM table1 t1
LEFT JOIN table2 t2 ON t1.key = t2.key;
```
- Returns all rows from left table (table1)
- Matching rows from right table (table2)
- NULL values for right table columns when no match exists

#### RIGHT JOIN (RIGHT OUTER JOIN)
```sql
SELECT t1.column1, t2.column2
FROM table1 t1
RIGHT JOIN table2 t2 ON t1.key = t2.key;
```
- Returns all rows from right table (table2)
- Matching rows from left table (table1)
- NULL values for left table columns when no match exists

#### FULL OUTER JOIN
```sql
SELECT t1.column1, t2.column2
FROM table1 t1
FULL OUTER JOIN table2 t2 ON t1.key = t2.key;
```
- Returns all rows from both tables
- Matching rows are combined
- NULL values for columns from the table without a match

#### CROSS JOIN
```sql
SELECT t1.column1, t2.column2
FROM table1 t1
CROSS JOIN table2 t2;
```
- Returns Cartesian product (all possible combinations)
- No ON clause needed
- Results in t1.row_count × t2.row_count rows

### Advanced Join Techniques

#### Self Join
```sql
SELECT e1.name AS employee, e2.name AS manager
FROM employees e1
JOIN employees e2 ON e1.manager_id = e2.id;
```
- Joining a table to itself
- Requires different aliases for the same table
- Useful for hierarchical or relationship data within a table

#### Multi-Table Join
```sql
SELECT c.name, o.order_date, p.product_name
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;
```
- Joining more than two tables
- Each join adds a new table to the result set
- Join order matters for performance but not for results

#### Non-Equi Join
```sql
SELECT e.name, s.salary_range
FROM employees e
JOIN salary_grades s ON e.salary BETWEEN s.min_salary AND s.max_salary;
```
- Join condition uses operators other than equality (=)
- Can use >, <, >=, <=, BETWEEN, etc.
- Useful for range-based relationships

#### Join with USING Clause
```sql
SELECT c.name, o.order_date
FROM customers c
JOIN orders o USING (customer_id);
```
- Simplified join syntax when join columns have the same name
- Column appears only once in the result set
- Not supported in all database systems

#### Natural Join
```sql
SELECT c.name, o.order_date
FROM customers c
NATURAL JOIN orders o;
```
- Automatically joins tables on all columns with the same name
- No explicit join condition needed
- Dangerous in production (schema changes can break queries)

## 2. Subqueries

### Types of Subqueries

#### Scalar Subquery (returns single value)
```sql
SELECT employee_name, salary,
       (SELECT AVG(salary) FROM employees) AS avg_company_salary
FROM employees;
```
- Returns exactly one row and one column
- Can be used anywhere a single value is expected
- Often used in SELECT list or WHERE conditions

#### Row Subquery (returns single row)
```sql
SELECT *
FROM employees
WHERE (department_id, salary) = (SELECT department_id, MAX(salary)
                                FROM employees
                                WHERE department_id = 10);
```
- Returns exactly one row with multiple columns
- Used with row constructors and comparison operators

#### Column Subquery (returns single column)
```sql
SELECT *
FROM employees
WHERE department_id IN (SELECT department_id
                       FROM departments
                       WHERE location = 'New York');
```
- Returns multiple rows but only one column
- Often used with IN, ANY, ALL operators

#### Table Subquery (returns multiple rows and columns)
```sql
SELECT *
FROM (SELECT department_id, AVG(salary) AS avg_salary
      FROM employees
      GROUP BY department_id) dept_avg
WHERE avg_salary > 50000;
```
- Returns multiple rows and multiple columns
- Used in FROM clause as a derived table
- Must have an alias

### Subquery Operators

#### EXISTS / NOT EXISTS
```sql
SELECT department_name
FROM departments d
WHERE EXISTS (SELECT 1
              FROM employees e
              WHERE e.department_id = d.id
              AND e.salary > 100000);
```
- Tests for existence of rows in the subquery
- Returns TRUE if subquery returns at least one row
- Often optimized to stop after finding first match

#### IN / NOT IN
```sql
SELECT *
FROM employees
WHERE department_id IN (SELECT id
                       FROM departments
                       WHERE location = 'New York');
```
- Compares a value to a list of values from subquery
- Equivalent to multiple OR conditions
- Be careful with NULL values in NOT IN

#### ANY / SOME
```sql
SELECT *
FROM employees
WHERE salary > ANY (SELECT salary
                   FROM employees
                   WHERE department_id = 10);
```
- Compares a value to each value returned by subquery
- Returns TRUE if any comparison is TRUE
- ANY and SOME are synonyms

#### ALL
```sql
SELECT *
FROM employees
WHERE salary > ALL (SELECT salary
                   FROM employees
                   WHERE department_id = 10);
```
- Compares a value to each value returned by subquery
- Returns TRUE only if all comparisons are TRUE

### Correlated Subqueries

```sql
SELECT e.name, e.salary
FROM employees e
WHERE e.salary > (SELECT AVG(salary)
                 FROM employees
                 WHERE department_id = e.department_id);
```
- References columns from the outer query
- Executed once for each row in the outer query
- Can be slower than non-correlated subqueries

### Subquery Placement

#### In SELECT Clause
```sql
SELECT e.name,
       (SELECT d.name FROM departments d WHERE d.id = e.department_id) AS dept_name
FROM employees e;
```
- Must return a scalar value (single row, single column)
- Executed for each row in the outer query

#### In FROM Clause (Derived Table)
```sql
SELECT d.department_name, d.avg_salary
FROM (SELECT department_id, AVG(salary) AS avg_salary
      FROM employees
      GROUP BY department_id) AS e
JOIN departments d ON e.department_id = d.id;
```
- Creates a temporary result set used as a table
- Must have an alias
- Can improve readability for complex queries

#### In WHERE Clause
```sql
SELECT *
FROM employees
WHERE department_id IN (SELECT id
                       FROM departments
                       WHERE budget > 1000000);
```
- Filters rows based on subquery results
- Most common subquery placement

#### In HAVING Clause
```sql
SELECT department_id, AVG(salary)
FROM employees
GROUP BY department_id
HAVING AVG(salary) > (SELECT AVG(salary) FROM employees);
```
- Filters groups based on subquery results
- Subquery can reference outer query (correlated)

## 3. Common Table Expressions (CTE)

### Basic CTE Syntax
```sql
WITH cte_name AS (
    SELECT column1, column2
    FROM table_name
    WHERE condition
)
SELECT *
FROM cte_name;
```
- Temporary named result set
- Exists only for the duration of the query
- Makes complex queries more readable

### Multiple CTEs
```sql
WITH 
dept_avg AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
),
high_salary_depts AS (
    SELECT department_id
    FROM dept_avg
    WHERE avg_salary > 50000
)
SELECT e.*
FROM employees e
JOIN high_salary_depts h ON e.department_id = h.department_id;
```
- Define multiple CTEs separated by commas
- Later CTEs can reference earlier ones
- Improves complex query organization

### Recursive CTE
```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Base case (anchor member)
    SELECT id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case (recursive member)
    SELECT e.id, e.name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.id
)
SELECT *
FROM employee_hierarchy;
```
- Consists of anchor (base case) and recursive member
- UNION ALL connects the parts
- Recursive member references the CTE itself
- Terminates when no new rows are added
- Requires RECURSIVE keyword in some databases

### CTE vs Subquery
- CTEs are more readable for complex queries
- CTEs can be referenced multiple times in the main query
- CTEs support recursion
- Subqueries can sometimes be more efficient for simple cases

## 4. Window Functions

### Window Function Syntax
```sql
SELECT column1, column2,
       WINDOW_FUNCTION() OVER (
           PARTITION BY partition_column
           ORDER BY sort_column
           ROWS/RANGE BETWEEN frame_start AND frame_end
       ) AS window_result
FROM table_name;
```
- Performs calculation across a set of rows
- Does not collapse rows like GROUP BY
- OVER clause defines the window (set of rows)

### Window Components

#### PARTITION BY
```sql
SELECT department_id, employee_name, salary,
       AVG(salary) OVER (PARTITION BY department_id) AS dept_avg
FROM employees;
```
- Divides rows into groups (partitions)
- Window function calculated separately for each partition
- Optional (if omitted, entire result set is one partition)

#### ORDER BY
```sql
SELECT employee_name, hire_date,
       RANK() OVER (ORDER BY hire_date) AS seniority_rank
FROM employees;
```
- Defines the order of rows within each partition
- Required for ranking and some analytical functions
- Optional for aggregate functions

#### Window Frame
```sql
SELECT employee_name, hire_date, salary,
       SUM(salary) OVER (
           ORDER BY hire_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total
FROM employees;
```
- Defines which rows to include in function calculation
- ROWS: physical rows
- RANGE: logical range based on values
- Common frames:
  - ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW (running total)
  - ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING (moving average)
  - ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING (entire partition)

### Types of Window Functions

#### Ranking Functions
```sql
SELECT employee_name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num,
       RANK() OVER (ORDER BY salary DESC) AS rank,
       DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank,
       NTILE(4) OVER (ORDER BY salary DESC) AS quartile
FROM employees;
```
- ROW_NUMBER(): Unique sequential number (1, 2, 3, ...)
- RANK(): Same value gets same rank, leaves gaps (1, 1, 3, ...)
- DENSE_RANK(): Same value gets same rank, no gaps (1, 1, 2, ...)
- NTILE(n): Divides rows into n approximately equal groups

#### Analytic Functions
```sql
SELECT employee_name, hire_date,
       LEAD(employee_name, 1) OVER (ORDER BY hire_date) AS next_hire,
       LAG(employee_name, 1) OVER (ORDER BY hire_date) AS previous_hire,
       FIRST_VALUE(employee_name) OVER (ORDER BY hire_date) AS first_hire,
       LAST_VALUE(employee_name) OVER (
           ORDER BY hire_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS last_hire
FROM employees;
```
- LEAD(): Access data from subsequent row
- LAG(): Access data from previous row
- FIRST_VALUE(): First value in window frame
- LAST_VALUE(): Last value in window frame
- NTH_VALUE(): Nth value in window frame

#### Aggregate Window Functions
```sql
SELECT employee_name, department_id, salary,
       SUM(salary) OVER (PARTITION BY department_id) AS dept_total,
       AVG(salary) OVER (PARTITION BY department_id) AS dept_avg,
       COUNT(*) OVER (PARTITION BY department_id) AS dept_count,
       MAX(salary) OVER (PARTITION BY department_id) AS dept_max,
       MIN(salary) OVER (PARTITION BY department_id) AS dept_min
FROM employees;
```
- Apply aggregate functions over a window
- Common functions: SUM, AVG, COUNT, MAX, MIN
- Unlike GROUP BY, doesn't reduce number of rows

#### Distribution Functions
```sql
SELECT employee_name, salary,
       PERCENT_RANK() OVER (ORDER BY salary) AS percent_rank,
       CUME_DIST() OVER (ORDER BY salary) AS cumulative_dist,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department_id) AS median
FROM employees;
```
- PERCENT_RANK(): Relative rank (0 to 1)
- CUME_DIST(): Cumulative distribution (0 to 1)
- PERCENTILE_CONT(): Continuous percentile
- PERCENTILE_DISC(): Discrete percentile

## 5. Hierarchical Queries

### Recursive CTE for Hierarchies
```sql
WITH RECURSIVE org_hierarchy AS (
    -- Base case: top-level employees (no manager)
    SELECT id, name, manager_id, 1 AS level, ARRAY[id] AS path, name AS path_name
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: employees with managers
    SELECT e.id, e.name, e.manager_id, oh.level + 1, oh.path || e.id, oh.path_name || ' > ' || e.name
    FROM employees e
    JOIN org_hierarchy oh ON e.manager_id = oh.id
)
SELECT id, name, level, path_name
FROM org_hierarchy
ORDER BY path;
```
- Most portable approach across modern databases
- Can track additional information like level and path
- Prevents infinite loops with cycle detection

### Oracle CONNECT BY
```sql
SELECT LEVEL, LPAD(' ', 2 * (LEVEL - 1)) || name AS org_chart,
       SYS_CONNECT_BY_PATH(name, '/') AS path
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR id = manager_id
ORDER SIBLINGS BY name;
```
- Oracle-specific syntax for hierarchical queries
- START WITH: Specifies root node(s)
- CONNECT BY: Defines relationship between rows
- PRIOR: References parent row
- LEVEL: Current depth in hierarchy
- ORDER SIBLINGS BY: Orders nodes at same level

### SQL Server Hierarchical Queries
```sql
-- Using Common Table Expression (CTE)
WITH org_hierarchy AS (
    SELECT id, name, manager_id, 0 AS level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    SELECT e.id, e.name, e.manager_id, oh.level + 1
    FROM employees e
    JOIN org_hierarchy oh ON e.manager_id = oh.id
)
SELECT * FROM org_hierarchy;

-- Using Recursive Query
SELECT id, name, manager_id, [level]
FROM employees
CROSS APPLY dbo.GetEmployeeHierarchy(id) AS h;
```
- SQL Server supports recursive CTEs
- Can also use table-valued functions
- Older versions used recursive stored procedures

### PostgreSQL Hierarchical Queries
```sql
-- Using ltree extension
SELECT id, name, manager_id, path::text
FROM (
    SELECT id, name, manager_id, nlevel(path) AS depth, path
    FROM employees_with_path
    WHERE path <@ 'root.executive'
    ORDER BY path
) subq;

-- Using recursive CTE
WITH RECURSIVE org_hierarchy AS (
    SELECT id, name, manager_id, 1 AS level, ARRAY[id] AS path
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    SELECT e.id, e.name, e.manager_id, oh.level + 1, oh.path || e.id
    FROM employees e
    JOIN org_hierarchy oh ON e.manager_id = oh.id
)
SELECT * FROM org_hierarchy;
```
- PostgreSQL supports recursive CTEs
- Also has ltree extension for hierarchical data
- Can use array operators for path manipulation

### Common Hierarchical Query Operations

#### Finding All Descendants
```sql
WITH RECURSIVE descendants AS (
    SELECT id, name, manager_id
    FROM employees
    WHERE id = 10  -- Starting employee ID
    
    UNION ALL
    
    SELECT e.id, e.name, e.manager_id
    FROM employees e
    JOIN descendants d ON e.manager_id = d.id
)
SELECT * FROM descendants WHERE id != 10;  -- Exclude starting employee
```
- Finds all reports (direct and indirect) under an employee

#### Finding All Ancestors
```sql
WITH RECURSIVE ancestors AS (
    SELECT id, name, manager_id
    FROM employees
    WHERE id = 42  -- Starting employee ID
    
    UNION ALL
    
    SELECT e.id, e.name, e.manager_id
    FROM employees e
    JOIN ancestors a ON e.id = a.manager_id
)
SELECT * FROM ancestors WHERE id != 42;  -- Exclude starting employee
```
- Finds all managers (direct and indirect) above an employee

#### Finding Siblings
```sql
SELECT id, name
FROM employees
WHERE manager_id = (
    SELECT manager_id
    FROM employees
    WHERE id = 42  -- Target employee ID
)
AND id != 42;  -- Exclude the target employee
```
- Finds all employees with the same manager

#### Finding Level/Depth
```sql
WITH RECURSIVE emp_hierarchy AS (
    SELECT id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    SELECT e.id, e.name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.id
)
SELECT id, name, level
FROM emp_hierarchy
ORDER BY level, name;
```
- Determines the depth of each node in the hierarchy 