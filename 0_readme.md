---
id: 0_readme
title: SQL Learning Path
slug: /
---
# SQL Learning Path

This repository contains a structured set of SQL examples organized by topic, designed to help you learn SQL from basic to advanced concepts. Each file focuses on a specific topic and its subtopics, with examples drawn from a comprehensive master query.

## Files Organization

1. **1_basic_sql_commands.sql**
   - SELECT, FROM, WHERE
   - INSERT, UPDATE, DELETE, MERGE (Upsert)
   - GROUP BY, HAVING, ORDER BY, LIMIT

2. **2_advanced_query_techniques.sql**
   - Joins (INNER, LEFT, RIGHT, FULL OUTER, CROSS)
   - Subqueries (EXISTS, IN, NOT IN, SCALAR SUBQUERY)
   - Common Table Expressions (CTE) (WITH, WITH RECURSIVE)
   - Window Functions (ROW_NUMBER(), RANK(), DENSE_RANK(), LAG(), LEAD(), NTILE())
   - Hierarchical Queries (CONNECT BY, WITH RECURSIVE)

3. **3_transactions_and_concurrency.sql**
   - BEGIN TRANSACTION, COMMIT, ROLLBACK
   - Row Locking (FOR UPDATE, LOCK IN SHARE MODE)
   - Concurrency Control (SERIALIZABLE, READ COMMITTED, READ UNCOMMITTED)

4. **4_data_types_json_xml_arrays.sql**
   - JSON Functions (JSON_EXTRACT(), JSON_TABLE(), JSONB)
   - XML Handling (XMLTable(), XMLQUERY())
   - ARRAY Handling (ARRAY_AGG(), STRING_AGG(), LISTAGG())

5. **5_procedural_sql.sql**
   - Stored Procedures (CREATE PROCEDURE, CALL, EXECUTE IMMEDIATE)
   - Triggers (CREATE TRIGGER, AFTER UPDATE, BEFORE INSERT)
   - Dynamic SQL (EXECUTE IMMEDIATE, PREPARE)

6. **6_analytical_and_performance_features.sql**
   - Query Optimization (EXPLAIN, ANALYZE, INDEX HINTS)
   - Materialized Views (CREATE MATERIALIZED VIEW)
   - Partitioning (PARTITION BY RANGE, PARTITION BY HASH)

7. **7_reporting_and_pivoting.sql**
   - Pivoting (PIVOT, UNPIVOT)
   - Aggregated String Concatenation (LISTAGG(), STRING_AGG())

8. **8_unique_sql_features.sql**
   - Recursive Queries (WITH RECURSIVE)
   - Geospatial Data Queries (ST_Geometry, ST_Distance())
   - Graph Queries (Graph extensions in PostgreSQL, Oracle)

## How to Use This Repository

1. Start with file 1 and work your way through in numerical order
2. Each file builds on concepts from previous files
3. Examples use placeholder table and column names for demonstration purposes
4. Syntax may vary slightly between different database systems (MySQL, PostgreSQL, Oracle, SQL Server)

## Master Query

All examples are derived from a comprehensive master query (`master_query.sql`) that demonstrates many SQL features in a single file. This master query serves as a reference for how different SQL features can be combined in complex queries.

## Database Compatibility

The examples include syntax variations for different database systems where appropriate:
- MySQL/MariaDB
- PostgreSQL
- Oracle
- SQL Server

Note that not all features are available in all database systems, and syntax may vary. 