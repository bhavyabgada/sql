-- 3. TRANSACTIONS & CONCURRENCY
-- This file covers transaction control and concurrency management in SQL

-- 3.1 BEGIN TRANSACTION, COMMIT, ROLLBACK
-- Starting a transaction
BEGIN TRANSACTION;

-- Example operations within a transaction
INSERT INTO log_table (query_executed, timestamp)
VALUES ('Transaction example', CURRENT_TIMESTAMP);

UPDATE some_table
SET column_name = 'transaction_value'
WHERE id = 1;

-- Committing changes (making them permanent)
COMMIT;

-- Alternative: Rolling back changes (undoing them)
-- ROLLBACK;

-- 3.2 Row Locking (FOR UPDATE, LOCK IN SHARE MODE)
-- Example of row locking with FOR UPDATE
SELECT 
    main_table.column1, 
    main_table.column2
FROM main_table
WHERE main_table.id = 100
FOR UPDATE;

-- 3.3 Concurrency Control (SERIALIZABLE, READ COMMITTED, READ UNCOMMITTED)
-- Setting transaction isolation level
-- Note: Syntax may vary by database system

-- PostgreSQL example
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- Operations here
COMMIT;

-- MySQL example
START TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Operations here
COMMIT;

-- Oracle example
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- Operations here
COMMIT;

-- Note: Transactions ensure data integrity by grouping operations that should be treated as a single unit.
-- Proper concurrency control prevents issues like dirty reads, non-repeatable reads, and phantom reads. 