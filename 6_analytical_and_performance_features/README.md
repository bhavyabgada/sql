---
id: 6_analytical_and_performance_features/README
title: Analytical and Performance Features
---
# Analytical and Performance Features

This folder contains examples and problems related to SQL features for query optimization and analytical processing.

## Example File
- [analytical_and_performance_features.sql](analytical_and_performance_features.sql) - Examples of analytical and performance features

## Topics Covered

### Query Optimization
- EXPLAIN and ANALYZE commands
- Index hints and optimizer directives
- Query plan analysis
- Performance tuning techniques

### Materialized Views
- Creating and refreshing materialized views
- Query rewriting with materialized views
- Incremental view maintenance
- View invalidation and validation

### Partitioning
- Range partitioning
- Hash partitioning
- List partitioning
- Partition pruning
- Partition-wise joins

## Problems

### Subqueries

1. **Employees Whose Manager Left the Company** (Easy)
   - Practice using subqueries with NOT IN
   - Find records based on absence in another table

2. **Exchange Seats** (Medium)
   - Practice using CASE expressions with subqueries
   - Swap values between adjacent rows

3. **Movie Rating** (Medium)
   - Practice using multiple subqueries
   - Find aggregated results across different dimensions

4. **Restaurant Growth** (Medium)
   - Practice using window functions and subqueries
   - Calculate running sums over date ranges

5. **Friend Requests II: Who Has the Most Friends** (Medium)
   - Practice using UNION ALL and subqueries
   - Count relationships across multiple records

6. **Investments in 2016** (Medium)
   - Practice using multiple filtering subqueries
   - Find records matching complex criteria

7. **Department Top Three Salaries** (Hard)
   - Practice using window functions and subqueries
   - Find top N values within groups

## How to Use
1. Study the example file to understand analytical and performance features
2. Work through the problems in order of difficulty
3. Compare your solutions with the provided solutions
4. Experiment with different ways to solve the same problem
5. Use EXPLAIN to analyze the performance of your queries 