-- 8. UNIQUE SQL FEATURES
-- This file covers specialized SQL features including recursive queries and geospatial/graph operations

-- 8.1 Recursive Queries (WITH RECURSIVE)
-- Example of recursive CTE from the master query
WITH RECURSIVE recursive_cte AS (
    -- Base case (anchor member)
    SELECT id, parent_id, name, 1 AS level
    FROM hierarchy_table
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Recursive case
    SELECT h.id, h.parent_id, h.name, r.level + 1
    FROM hierarchy_table h
    JOIN recursive_cte r ON h.parent_id = r.id
)
SELECT 
    id,
    name,
    level,
    REPEAT('  ', level - 1) || name AS hierarchical_display
FROM recursive_cte
ORDER BY level, name;

-- File system path example with recursive CTE
WITH RECURSIVE file_paths AS (
    -- Base case: top-level directories
    SELECT 
        id,
        name,
        parent_id,
        name AS path,
        1 AS depth
    FROM files
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Recursive case: subdirectories and files
    SELECT 
        f.id,
        f.name,
        f.parent_id,
        fp.path || '/' || f.name AS path,
        fp.depth + 1 AS depth
    FROM files f
    JOIN file_paths fp ON f.parent_id = fp.id
)
SELECT id, path, depth
FROM file_paths
ORDER BY path;

-- 8.2 Geospatial Data Queries (ST_Geometry, ST_Distance())
-- PostGIS style geospatial query
SELECT 
    store_name,
    ST_Distance(
        location::geography,
        ST_SetSRID(ST_MakePoint(-73.985428, 40.748817), 4326)::geography
    ) AS distance_meters
FROM stores
WHERE ST_DWithin(
    location::geography,
    ST_SetSRID(ST_MakePoint(-73.985428, 40.748817), 4326)::geography,
    5000  -- 5km radius
)
ORDER BY distance_meters;

-- Finding stores within a polygon (neighborhood boundary)
SELECT 
    store_name,
    address
FROM stores
WHERE ST_Contains(
    (SELECT boundary FROM neighborhoods WHERE name = 'Downtown'),
    location
);

-- 8.3 Graph Queries (Graph extensions in PostgreSQL, Oracle)
-- Oracle property graph query
SELECT 
    src.name AS employee,
    dst.name AS manager
FROM employees_graph
MATCH (src)-[:REPORTS_TO]->(dst)
WHERE dst.department = 'Engineering';

-- PostgreSQL graph query using recursive CTE
WITH RECURSIVE reporting_chain AS (
    -- Base case: CEO (no manager)
    SELECT 
        id,
        name,
        manager_id,
        ARRAY[name] AS chain,
        1 AS level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: all other employees
    SELECT 
        e.id,
        e.name,
        e.manager_id,
        rc.chain || e.name AS chain,
        rc.level + 1 AS level
    FROM employees e
    JOIN reporting_chain rc ON e.manager_id = rc.id
)
SELECT 
    id,
    name,
    level,
    array_to_string(chain, ' -> ') AS reporting_path
FROM reporting_chain
ORDER BY chain;

-- Note: These specialized features enable SQL to handle complex data relationships
-- and specialized data types that go beyond traditional tabular data processing. 