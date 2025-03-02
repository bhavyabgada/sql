# Procedural SQL

This folder contains examples related to procedural extensions to SQL, including stored procedures, triggers, and dynamic SQL.

## Example File
- [procedural_sql.sql](procedural_sql.sql) - Examples of procedural SQL features

## Topics Covered

### Stored Procedures
- CREATE PROCEDURE syntax
- Input and output parameters
- Local variables and control flow
- Error handling
- Calling procedures (CALL, EXECUTE)

### Triggers
- CREATE TRIGGER syntax
- Event triggers (BEFORE, AFTER)
- Row-level and statement-level triggers
- Trigger timing (INSERT, UPDATE, DELETE)
- Accessing OLD and NEW values

### Dynamic SQL
- EXECUTE IMMEDIATE
- PREPARE and EXECUTE statements
- Building SQL statements dynamically
- Parameter binding
- Security considerations (SQL injection)

## Practical Applications
- Data validation and transformation
- Complex business rules implementation
- Audit logging
- Automated maintenance tasks
- Report generation

## Database System Variations
- MySQL/MariaDB: Stored procedures with DELIMITER
- PostgreSQL: PL/pgSQL language
- Oracle: PL/SQL blocks
- SQL Server: T-SQL procedures

## How to Use
1. Study the example file to understand procedural SQL concepts
2. Experiment with creating your own procedures and triggers
3. Practice implementing business logic in database procedures
4. Learn to use dynamic SQL safely and effectively

## Note
This topic doesn't have specific problems from the problem set, as procedural SQL is typically part of database development rather than isolated query challenges. However, understanding these concepts is essential for building complex database applications and implementing business logic at the database level. 