

DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS routes;

-- Lookup table
CREATE TABLE routes (
    route_id     VARCHAR(10) PRIMARY KEY,
    route        VARCHAR(100) NOT NULL,
    service_type VARCHAR(50) NOT NULL
);

-- Fact table
CREATE TABLE deliveries (
    record_id     INTEGER PRIMARY KEY,
    month         VARCHAR(10) NOT NULL,
    route_id      VARCHAR(10) NOT NULL,
    hub           VARCHAR(100) NOT NULL,
    promised_days INTEGER NOT NULL,
    actual_days   INTEGER NOT NULL,

    CONSTRAINT fk_deliveries_route
        FOREIGN KEY (route_id)
        REFERENCES routes(route_id)
);

-- Exactly 4 lookup rows
INSERT INTO routes (route_id, route, service_type) VALUES
    ('R1', 'Metro Link',     'Express'),
    ('R2', 'City Dash',      'Express'),
    ('R3', 'Highway Freight','Standard'),
    ('R4', 'Rural Feeder',   'Standard');


-- Exactly 12 fact rows.
-- Duplicate record_id 12 has been excluded.
INSERT INTO deliveries
    (record_id, month, route_id, hub, promised_days, actual_days)
VALUES
    (1,  'Jan', 'R1', 'Mumbai',  2,  2),
    (2,  'Jan', 'R2', 'Chennai', 3,  4),
    (3,  'Jan', 'R3', 'Delhi',   5,  8),
    (4,  'Jan', 'R4', 'Mumbai',  6, 10),
    (5,  'Feb', 'R1', 'Chennai', 2,  5),
    (6,  'Feb', 'R2', 'Delhi',   3,  3),
    (7,  'Feb', 'R3', 'Delhi',   5, 10),
    (8,  'Feb', 'R4', 'Chennai', 6,  7),
    (9,  'Mar', 'R1', 'Delhi',   2,  8),
    (10, 'Mar', 'R2', 'Mumbai',  3,  5),
    (11, 'Mar', 'R3', 'Chennai', 5,  5),
    (12, 'Mar', 'R4', 'Mumbai',  6, 15);





-- ============================================================
-- S2a — Total delay_days by service type

SELECT
    r.service_type,
    SUM(GREATEST(d.actual_days - d.promised_days, 0))
        AS total_delay_days
FROM deliveries AS d
JOIN routes AS r
    ON d.route_id = r.route_id
GROUP BY r.service_type
ORDER BY total_delay_days DESC

-- S2b 

SELECT
    r.route_id,
    r.route,
    SUM(GREATEST(d.actual_days - d.promised_days, 0))
        AS total_delay_days
FROM deliveries AS d
JOIN routes AS r
    ON d.route_id = r.route_id
GROUP BY
    r.route_id,
    r.route
HAVING SUM(GREATEST(d.actual_days - d.promised_days, 0)) > 8
ORDER BY total_delay_days DESC;



-- S2c

SELECT
    d.hub,
    SUM(GREATEST(d.actual_days - d.promised_days, 0))
        AS total_delay_days
FROM deliveries AS d
JOIN routes AS r
    ON d.route_id = r.route_id
GROUP BY d.hub
ORDER BY
    total_delay_days DESC,
    d.hub ASC
LIMIT 2;



 S3

SELECT
    COUNT(*) AS unmatched_route_keys
FROM deliveries AS d
LEFT JOIN routes AS r
    ON d.route_id = r.route_id
WHERE r.route_id IS NULL;
