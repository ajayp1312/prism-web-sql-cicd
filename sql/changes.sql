-- Prism-web baseline schema loaded manually from baseline_ddl.sql
-- Future incremental changes go below this line
-- test trigger check
-- test trigger check2
-- test trigger check3
-- test trigger check4
-- test trigger check5
-- test trigger check5
-- test trigger check7
CREATE TABLE IF NOT EXISTS test_automation (
    id SERIAL PRIMARY KEY,
    test_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);