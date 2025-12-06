# 🚀 SQL Interview Final Day Cheatsheet

> **2-Hour Power Revision** — Master all key patterns, solutions & theory

---

## 📋 Table of Contents
1. [Window Functions](#1-window-functions)
2. [PARTITION BY](#2-partition-by)
3. [Common Table Expressions (CTE)](#3-common-table-expressions-cte)
4. [Joins](#4-joins)
5. [Subqueries](#5-subqueries)
6. [Aggregations & Grouping](#6-aggregations--grouping)
7. [Theoretical Questions](#7-theoretical-questions)
8. [Quick Reference Patterns](#8-quick-reference-patterns)

---

# 1. Window Functions

## 🧠 Core Concept
Window functions perform calculations across rows **without collapsing them** (unlike GROUP BY).

```sql
FUNCTION() OVER (
    PARTITION BY col    -- Optional: divide into groups
    ORDER BY col        -- Optional: order within partition
)
```

## 📊 The Big Four Ranking Functions

| Function | Ties | Gaps | Example Result |
|----------|------|------|----------------|
| `ROW_NUMBER()` | No | N/A | 1, 2, 3, 4, 5 |
| `RANK()` | Yes | Yes | 1, 1, 3, 4, 4, 6 |
| `DENSE_RANK()` | Yes | No | 1, 1, 2, 3, 3, 4 |
| `NTILE(n)` | Divides into n buckets | N/A | 1, 1, 2, 2, 3, 3 |

---

## ROW_NUMBER() Solutions

### Q1: Top 3 Employees per Department
```sql
-- LOGIC: Assign row numbers within each dept, then filter to top 3
SELECT DepartmentID, EmployeeName, Salary, EmployeeRank
FROM (
    SELECT 
        DepartmentID,
        EmployeeName,
        Salary,
        ROW_NUMBER() OVER (
            PARTITION BY DepartmentID 
            ORDER BY Salary DESC
        ) AS EmployeeRank
    FROM Employees
) ranked
WHERE EmployeeRank <= 3;
```
**💡 Pattern**: Use subquery because you can't filter window functions in WHERE directly.

### Q2: Latest Order per Customer
```sql
-- LOGIC: Number orders by date (newest first), pick the #1
SELECT CustomerID, OrderID, OrderDate, Amount
FROM (
    SELECT 
        CustomerID,
        OrderID,
        OrderDate,
        Amount,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID 
            ORDER BY OrderDate DESC
        ) AS rn
    FROM Orders
) ranked
WHERE rn = 1;
```

---

## RANK() Solutions

### Q1: Rank Students by Exam Scores
```sql
-- LOGIC: RANK() gives same rank for ties, skips next
SELECT 
    StudentID,
    StudentName,
    ExamScore,
    RANK() OVER (ORDER BY ExamScore DESC) AS Rank
FROM Students;
```
**Result**: If two students have 95, both get rank 1, next gets rank 3.

### Q2: Product Sales Rank Within Category
```sql
SELECT 
    Category,
    ProductName,
    TotalSales,
    RANK() OVER (
        PARTITION BY Category 
        ORDER BY TotalSales DESC
    ) AS SalesRank
FROM Products;
```

---

## DENSE_RANK() Solutions

### Q1: Movie Ratings (No Gaps)
```sql
-- LOGIC: DENSE_RANK() = same rank for ties, NO gaps
SELECT 
    MovieID,
    MovieName,
    Rating,
    DENSE_RANK() OVER (ORDER BY Rating DESC) AS Rank
FROM Movies;
```
**Result**: Ratings 9,9,8,7 → Ranks 1,1,2,3 (not 1,1,3,4)

### Q2: Customer Spending Rank
```sql
-- LOGIC: First aggregate, then rank
SELECT 
    CustomerID,
    SUM(SpendAmount) AS TotalSpend,
    DENSE_RANK() OVER (ORDER BY SUM(SpendAmount) DESC) AS Rank
FROM Transactions
GROUP BY CustomerID;
```

---

## LAG() Solutions

### Q1: Monthly Revenue vs Previous Month
```sql
-- LOGIC: LAG(col, n) gets value from n rows back
SELECT 
    Month,
    Revenue,
    LAG(Revenue, 1) OVER (ORDER BY Month) AS PreviousMonthRevenue
FROM MonthlyRevenue;
```
**💡 First row will have NULL for PreviousMonthRevenue.**

### Q2: Employee Salary Changes
```sql
SELECT 
    EmployeeID,
    EffectiveDate,
    Salary,
    LAG(Salary, 1) OVER (
        PARTITION BY EmployeeID 
        ORDER BY EffectiveDate
    ) AS PreviousSalary
FROM EmployeeSalaries;
```

---

## LEAD() Solutions

### Q1: Next Flight for Same Airline
```sql
-- LOGIC: LEAD(col, n) gets value from n rows ahead
SELECT 
    FlightID,
    Airline,
    DepartureTime,
    LEAD(DepartureTime, 1) OVER (
        PARTITION BY Airline 
        ORDER BY DepartureTime
    ) AS NextFlightDepartureTime
FROM Flights;
```

### Q2: Stock Price Next-Day Comparison
```sql
SELECT 
    StockID,
    StockDate,
    ClosingPrice,
    LEAD(ClosingPrice, 1) OVER (
        PARTITION BY StockID 
        ORDER BY StockDate
    ) AS NextDayClosingPrice
FROM Stocks;
```

---

# 2. PARTITION BY

## 🧠 Core Concept
PARTITION BY divides data into groups for window function calculations. Each partition is processed independently.

```sql
-- Without PARTITION BY: Calculation over ALL rows
AVG(salary) OVER () -- Average of entire table

-- With PARTITION BY: Calculation per group
AVG(salary) OVER (PARTITION BY department_id) -- Average per dept
```

---

## Solutions

### Q1: Rank Employees by Salary Within Department
```sql
SELECT 
    DepartmentID,
    EmployeeName,
    Salary,
    RANK() OVER (
        PARTITION BY DepartmentID 
        ORDER BY Salary DESC
    ) AS RankInDepartment
FROM Employees;
```

### Q2: Rolling Average Order Value per Customer
```sql
-- LOGIC: Running average = include all rows up to current
SELECT 
    CustomerID,
    OrderDate,
    Amount,
    AVG(Amount) OVER (
        PARTITION BY CustomerID 
        ORDER BY OrderDate 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS AverageToDate
FROM Orders;
```
**💡 Key Frame Clauses**:
- `ROWS UNBOUNDED PRECEDING` = from start to current (running total)
- `ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING` = 3-row moving window

### Q3: Customers with Increasing Spend
```sql
-- LOGIC: Compare current amount with LAG, filter increases
SELECT 
    CustomerID,
    TransactionDate,
    Amount,
    PreviousAmount,
    CASE WHEN Amount > PreviousAmount THEN 'Yes' ELSE 'No' END AS Increased
FROM (
    SELECT 
        CustomerID,
        TransactionDate,
        Amount,
        LAG(Amount, 1) OVER (
            PARTITION BY CustomerID 
            ORDER BY TransactionDate
        ) AS PreviousAmount
    FROM Transactions
) t
WHERE Amount > PreviousAmount;
```

### Q4: Flag First Purchase per Customer
```sql
-- LOGIC: ROW_NUMBER = 1 means first purchase
SELECT 
    CustomerID,
    PurchaseDate,
    Item,
    CASE WHEN rn = 1 THEN 'Yes' ELSE 'No' END AS IsFirstPurchase
FROM (
    SELECT 
        CustomerID,
        PurchaseDate,
        Item,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID 
            ORDER BY PurchaseDate
        ) AS rn
    FROM Purchases
) t;
```

---

# 3. Common Table Expressions (CTE)

## 🧠 Core Concept
CTEs are temporary named result sets that make complex queries readable.

```sql
WITH cte_name AS (
    SELECT ...
)
SELECT * FROM cte_name;
```

**Advantages over Subqueries**:
- More readable
- Can reference multiple times
- Supports recursion

---

## Solutions

### Q1: Top 3 Customers per Month
```sql
-- LOGIC: CTE calculates monthly totals, main query ranks & filters
WITH MonthlySpend AS (
    SELECT 
        CustomerID,
        DATE_TRUNC('month', OrderDate) AS Month,
        SUM(Amount) AS TotalSpend,
        ROW_NUMBER() OVER (
            PARTITION BY DATE_TRUNC('month', OrderDate) 
            ORDER BY SUM(Amount) DESC
        ) AS SpendRank
    FROM Orders
    GROUP BY CustomerID, DATE_TRUNC('month', OrderDate)
)
SELECT CustomerID, Month, TotalSpend, SpendRank
FROM MonthlySpend
WHERE SpendRank <= 3;
```

### Q2: Sales Over 150% of Regional Daily Average
```sql
WITH DailyAvg AS (
    SELECT 
        Region,
        AVG(Amount) AS AvgDailySales
    FROM Sales
    GROUP BY Region
)
SELECT 
    s.SaleID,
    s.SaleDate,
    s.Region,
    s.Amount,
    d.AvgDailySales
FROM Sales s
JOIN DailyAvg d ON s.Region = d.Region
WHERE s.Amount > d.AvgDailySales * 1.5;
```

### Q3: Second Highest Transaction per Customer
```sql
WITH RankedTransactions AS (
    SELECT 
        CustomerID,
        Amount,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID 
            ORDER BY Amount DESC
        ) AS rn
    FROM Transactions
)
SELECT CustomerID, Amount AS SecondHighestAmount
FROM RankedTransactions
WHERE rn = 2;
```

### Q4: Employees Earning > 2x Department Average
```sql
WITH DeptAvg AS (
    SELECT 
        DepartmentID,
        AVG(Salary) AS AvgSalary
    FROM Employees
    GROUP BY DepartmentID
)
SELECT e.EmployeeID, e.DepartmentID, e.Salary, d.AvgSalary
FROM Employees e
JOIN DeptAvg d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > d.AvgSalary * 2;
```

---

# 4. Joins

## 🧠 Visual Reference

```
LEFT JOIN:    [████████]     RIGHT JOIN:      [████████]
              [    ████]                 [████    ]

INNER JOIN:   [    ████]     FULL OUTER:  [████████████]
                                          [████    ████]
```

---

## Solutions

### Q1: Customers Without Orders
```sql
-- LOGIC: LEFT JOIN + check for NULL on right side
SELECT c.CustomerID, c.Name
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;
```
**💡 Pattern**: Find "orphans" = LEFT JOIN + IS NULL

### Q2: Employee and Manager Names (Self Join)
```sql
-- LOGIC: Join table to itself using manager relationship
SELECT 
    e.EmployeeID,
    e.Name AS EmployeeName,
    m.Name AS ManagerName
FROM Employees e
LEFT JOIN Employees m ON e.ManagerID = m.EmployeeID;
```
**💡 Use LEFT JOIN to include employees without managers (CEO).**

### Q3: Products Never Sold
```sql
SELECT p.ProductID, p.Name
FROM Products p
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
WHERE od.ProductID IS NULL;
```

### Q4: Highest Sale per Region
```sql
SELECT 
    r.RegionName,
    MAX(s.Amount) AS HighestSale
FROM Sales s
JOIN Regions r ON s.Region = r.RegionID
GROUP BY r.RegionName;
```

### Q5: Total Revenue per Category
```sql
SELECT 
    c.Name AS CategoryName,
    SUM(s.Quantity * s.Price) AS TotalRevenue
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.Name;
```

### Q6: Students and Their Courses
```sql
SELECT 
    s.Name AS StudentName,
    c.Title AS CourseName
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Courses c ON e.CourseID = c.CourseID
ORDER BY s.Name, c.Title;
```

### Q7: Complete Order Details (Multi-Join)
```sql
SELECT 
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    p.Name AS ProductName,
    oi.Quantity,
    p.Price,
    (oi.Quantity * p.Price) AS TotalCost
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID;
```

---

# 5. Subqueries

## 🧠 Core Concept

| Placement | Returns | Example |
|-----------|---------|---------|
| SELECT | Scalar (1 value) | `(SELECT MAX(sal) FROM emp)` |
| FROM | Table (derived table) | `FROM (SELECT ...) AS t` |
| WHERE | Value or list | `WHERE id IN (SELECT ...)` |

---

## Solutions

### Q1: Customers with Above-Average Spend
```sql
-- LOGIC: Compare total to overall average
SELECT CustomerID, SUM(Amount) AS TotalSpend
FROM Orders
GROUP BY CustomerID
HAVING SUM(Amount) > (
    SELECT AVG(TotalSpend) 
    FROM (
        SELECT SUM(Amount) AS TotalSpend 
        FROM Orders 
        GROUP BY CustomerID
    ) t
);
```

### Q2: Second Highest Salary
```sql
-- Method 1: Subquery with MAX
SELECT MAX(Salary) AS SecondHighest
FROM Employees
WHERE Salary < (SELECT MAX(Salary) FROM Employees);

-- Method 2: LIMIT OFFSET
SELECT DISTINCT Salary
FROM Employees
ORDER BY Salary DESC
LIMIT 1 OFFSET 1;

-- Method 3: DENSE_RANK
SELECT Salary
FROM (
    SELECT Salary, DENSE_RANK() OVER (ORDER BY Salary DESC) AS rn
    FROM Employees
) t
WHERE rn = 2;
```

### Q3: Products with No Orders
```sql
-- Method 1: NOT IN
SELECT ProductID
FROM Products
WHERE ProductID NOT IN (SELECT ProductID FROM OrderItems);

-- Method 2: NOT EXISTS (preferred for NULLs)
SELECT ProductID
FROM Products p
WHERE NOT EXISTS (
    SELECT 1 FROM OrderItems oi WHERE oi.ProductID = p.ProductID
);
```
**⚠️ NOT IN fails with NULLs. Use NOT EXISTS for safety.**

### Q4: Highest Paid per Department (Correlated Subquery)
```sql
-- LOGIC: For each row, check if salary = max in that dept
SELECT EmployeeID, DepartmentID, Salary
FROM Employees e
WHERE Salary = (
    SELECT MAX(Salary) 
    FROM Employees 
    WHERE DepartmentID = e.DepartmentID
);
```

### Q5: Customers with > 1 Order
```sql
SELECT CustomerID
FROM Orders
GROUP BY CustomerID
HAVING COUNT(*) > 1;
```

### Q6: Products More Expensive Than Average
```sql
SELECT ProductID, Price
FROM Products
WHERE Price > (SELECT AVG(Price) FROM Products);
```

### Q7: Employees in Top 10% Salary
```sql
-- LOGIC: Find 90th percentile cutoff, filter above it
SELECT EmployeeID, Salary
FROM Employees
WHERE Salary >= (
    SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY Salary)
    FROM Employees
);

-- Alternative with subquery:
SELECT EmployeeID, Salary
FROM Employees e
WHERE (
    SELECT COUNT(*) FROM Employees WHERE Salary > e.Salary
) < (SELECT COUNT(*) * 0.1 FROM Employees);
```

### Q8: Customers Who Ordered ALL Products
```sql
-- LOGIC: Use double NOT EXISTS (relational division)
SELECT c.CustomerID
FROM Customers c
WHERE NOT EXISTS (
    SELECT p.ProductID
    FROM Products p
    WHERE NOT EXISTS (
        SELECT 1 
        FROM Orders o 
        WHERE o.CustomerID = c.CustomerID 
        AND o.ProductID = p.ProductID
    )
);
```
**💡 Translation**: "No product exists that this customer hasn't ordered"

### Q9: Cities With No Orders
```sql
SELECT DISTINCT c.City
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.CustomerID = c.CustomerID
);
```

### Q10: Departments with Only One Employee
```sql
SELECT DepartmentID
FROM Employees
GROUP BY DepartmentID
HAVING COUNT(*) = 1;
```

---

# 6. Aggregations & Grouping

## 🧠 Aggregate Functions Quick Reference

| Function | Purpose | NULL handling |
|----------|---------|---------------|
| `COUNT(*)` | Count all rows | Includes NULLs |
| `COUNT(col)` | Count non-NULL | Excludes NULLs |
| `SUM(col)` | Total | Ignores NULLs |
| `AVG(col)` | Average | Ignores NULLs |
| `MIN/MAX(col)` | Min/Max | Ignores NULLs |

---

## Solutions

### Q1: Total Revenue per Product
```sql
SELECT 
    ProductID,
    SUM(Quantity * Price) AS TotalRevenue
FROM OrderItems
GROUP BY ProductID;
```

### Q2: Average Order Value per Customer
```sql
SELECT 
    CustomerID,
    AVG(Amount) AS AvgOrderValue
FROM Orders
GROUP BY CustomerID;
```

### Q3: Number of Orders per Month
```sql
SELECT 
    DATE_TRUNC('month', OrderDate) AS Month,
    COUNT(*) AS OrderCount
FROM Orders
GROUP BY DATE_TRUNC('month', OrderDate)
ORDER BY Month;
```

### Q4: Highest-Spending Customer
```sql
SELECT CustomerID, SUM(Amount) AS TotalSpend
FROM Orders
GROUP BY CustomerID
ORDER BY TotalSpend DESC
LIMIT 1;
```

### Q5: Product Count per Category
```sql
SELECT CategoryID, COUNT(*) AS ProductCount
FROM Products
GROUP BY CategoryID;
```

### Q6: Orders per Customer per Year
```sql
SELECT 
    CustomerID,
    EXTRACT(YEAR FROM OrderDate) AS OrderYear,
    COUNT(*) AS OrderCount
FROM Orders
GROUP BY CustomerID, EXTRACT(YEAR FROM OrderDate);
```

### Q7: Daily Average Sales by Store
```sql
SELECT 
    StoreID,
    SaleDate,
    AVG(Amount) AS AvgDailySales
FROM Sales
GROUP BY StoreID, SaleDate;
```

### Q8: Most Popular Product Each Month
```sql
WITH MonthlyProductCounts AS (
    SELECT 
        DATE_TRUNC('month', o.OrderDate) AS Month,
        oi.ProductID,
        COUNT(*) AS OrderCount,
        ROW_NUMBER() OVER (
            PARTITION BY DATE_TRUNC('month', o.OrderDate)
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM Orders o
    JOIN OrderItems oi ON o.OrderID = oi.OrderID
    GROUP BY DATE_TRUNC('month', o.OrderDate), oi.ProductID
)
SELECT Month, ProductID, OrderCount
FROM MonthlyProductCounts
WHERE rn = 1;
```

### Q9: Top 5 Customers by Order Frequency
```sql
SELECT CustomerID, COUNT(*) AS OrderCount
FROM Orders
GROUP BY CustomerID
ORDER BY OrderCount DESC
LIMIT 5;
```

### Q10: Categories with No Sales
```sql
SELECT c.CategoryID, c.Name
FROM Categories c
LEFT JOIN Products p ON c.CategoryID = p.CategoryID
LEFT JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY c.CategoryID, c.Name
HAVING COUNT(oi.ProductID) = 0;
```

---

# 7. Theoretical Questions

## 🎯 Must-Know Answers

### Q: What types of JOINs exist?

| Join Type | Returns |
|-----------|---------|
| **INNER JOIN** | Only matching rows from both tables |
| **LEFT (OUTER) JOIN** | All from left + matching from right |
| **RIGHT (OUTER) JOIN** | All from right + matching from left |
| **FULL (OUTER) JOIN** | All from both tables |
| **CROSS JOIN** | Cartesian product (all combinations) |
| **SELF JOIN** | Table joined to itself |

---

### Q: What is a Primary Key?
- Column(s) that **uniquely identify** each row
- **NOT NULL** + **UNIQUE** combined
- Each table should have exactly ONE primary key
- Example: `EmployeeID`, `OrderID`

---

### Q: What is a Foreign Key?
- Column that **references a Primary Key** in another table
- Creates relationships between tables
- Enforces **referential integrity**
- Can be NULL (unless specified otherwise)

---

### Q: Difference between LEFT JOIN and LEFT OUTER JOIN?
**None!** They are exactly the same.
- `LEFT JOIN` is shorthand for `LEFT OUTER JOIN`
- SQL allows `OUTER` keyword to be optional

---

### Q: What is Normalization?
**Process of organizing data to reduce redundancy and improve integrity.**

| Form | Rule |
|------|------|
| 1NF | Atomic values, no repeating groups |
| 2NF | 1NF + no partial dependencies |
| 3NF | 2NF + no transitive dependencies |

**Benefits**: Less redundancy, better data integrity, more flexibility

---

### Q: WHERE vs HAVING?

| WHERE | HAVING |
|-------|--------|
| Filters **rows** before grouping | Filters **groups** after grouping |
| Cannot use aggregate functions | CAN use aggregate functions |
| Runs before GROUP BY | Runs after GROUP BY |

```sql
SELECT dept, AVG(salary)
FROM employees
WHERE status = 'active'    -- Row filter (before GROUP BY)
GROUP BY dept
HAVING AVG(salary) > 50000 -- Group filter (after GROUP BY)
```

---

### Q: UNION vs UNION ALL?

| UNION | UNION ALL |
|-------|-----------|
| Removes duplicates | Keeps all rows |
| Slower (needs sorting) | Faster |
| Use when duplicates unwanted | Use for performance |

---

### Q: DELETE vs TRUNCATE vs DROP?

| Command | What it does | Rollback? | Triggers? |
|---------|--------------|-----------|-----------|
| DELETE | Removes rows (can filter) | Yes | Yes |
| TRUNCATE | Removes ALL rows | No* | No |
| DROP | Removes entire table | No | No |

*Rollback support varies by database

---

### Q: What is an Index?
- Data structure to **speed up data retrieval**
- Like a book index - quick lookup
- Trade-off: Faster reads, slower writes

**Types**:
- B-tree (default, general purpose)
- Hash (equality comparisons)
- GIN/GiST (full-text, arrays, JSON)

---

### Q: Correlated vs Non-Correlated Subquery?

| Non-Correlated | Correlated |
|----------------|------------|
| Runs once independently | Runs once per outer row |
| No reference to outer query | References outer query columns |
| Generally faster | Can be slow for large datasets |

```sql
-- Non-correlated (runs once)
WHERE salary > (SELECT AVG(salary) FROM emp)

-- Correlated (runs per row)
WHERE salary > (SELECT AVG(salary) FROM emp e2 WHERE e2.dept = e1.dept)
```

---

# 8. Quick Reference Patterns

## 🔥 Common Interview Patterns

### Pattern 1: Top N per Group
```sql
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY group_col ORDER BY val DESC) AS rn
    FROM table
) t WHERE rn <= N;
```

### Pattern 2: Find Duplicates
```sql
SELECT col, COUNT(*)
FROM table
GROUP BY col
HAVING COUNT(*) > 1;
```

### Pattern 3: Running Total
```sql
SUM(amount) OVER (ORDER BY date ROWS UNBOUNDED PRECEDING)
```

### Pattern 4: Compare to Previous Row
```sql
current_value - LAG(value) OVER (ORDER BY date) AS change
```

### Pattern 5: Find Gaps in Sequence
```sql
SELECT id + 1 AS gap_start
FROM table t
WHERE NOT EXISTS (SELECT 1 FROM table WHERE id = t.id + 1);
```

### Pattern 6: Consecutive Days/Events
```sql
-- Use date - ROW_NUMBER to create groups
SELECT *, date - ROW_NUMBER() OVER (ORDER BY date) * INTERVAL '1 day' AS grp
FROM table
```

### Pattern 7: Pivot (Rows to Columns)
```sql
SELECT 
    category,
    SUM(CASE WHEN year = 2023 THEN amount END) AS "2023",
    SUM(CASE WHEN year = 2024 THEN amount END) AS "2024"
FROM sales
GROUP BY category;
```

### Pattern 8: Unpivot (Columns to Rows)
```sql
SELECT id, 'col1' AS column_name, col1 AS value FROM table
UNION ALL
SELECT id, 'col2', col2 FROM table;
```

---

## 🚨 Common Mistakes to Avoid

1. **NOT IN with NULLs** — Use NOT EXISTS instead
2. **Using SELECT * with GROUP BY** — Only select grouped columns + aggregates
3. **Filtering window functions in WHERE** — Use subquery
4. **Forgetting ORDER BY with LIMIT** — Results are non-deterministic
5. **JOIN without proper conditions** — Creates Cartesian product
6. **Comparing NULLs with =** — Use IS NULL / IS NOT NULL

---

## 📝 SQL Execution Order

```
1. FROM & JOINs    (Get data from tables)
2. WHERE           (Filter rows)
3. GROUP BY        (Create groups)
4. HAVING          (Filter groups)
5. SELECT          (Choose columns)
6. DISTINCT        (Remove duplicates)
7. ORDER BY        (Sort results)
8. LIMIT/OFFSET    (Limit rows returned)
```

**💡 This is why you can't use column aliases in WHERE!**

---

## 🏆 Final Tips

1. **Read the question carefully** — Note "per department", "each customer", etc.
2. **Think in sets** — SQL operates on sets, not loops
3. **Start simple** — Build query step by step, test each part
4. **Use CTEs for clarity** — Easier to debug and explain
5. **Handle edge cases** — NULLs, ties, empty results
6. **Explain your logic** — Interviewers care about thought process

---

**Good luck! You've got this! 🎉**

