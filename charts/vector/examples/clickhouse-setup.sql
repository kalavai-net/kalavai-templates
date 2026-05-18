-- ClickHouse setup for Vector JSON logs
-- Run this script in ClickHouse client to create the database and table

-- Create database for logs
CREATE DATABASE IF NOT EXISTS logs;

-- Use the logs database
USE logs;

-- Create table for JSON log events
CREATE TABLE IF NOT EXISTS logs.events (
  -- Timestamp when the log was generated
  timestamp DateTime64(3),

  -- Application-specific fields (examples - add/remove as needed)
  user_id String,
  model_id String,
  job_name String,
  event_id String,
  vram_usage UInt16,
  memory_usage UInt16,
  cpu_usage UInt16,
  gpu_type String,
  interval_seconds UInt16,
  gpu_provider String
) 
ENGINE = MergeTree()
ORDER BY (timestamp, user_id)
SETTINGS index_granularity = 8192;

-- Optional: Create a materialized view for error logs
CREATE MATERIALIZED VIEW IF NOT EXISTS logs.errors_mv
ENGINE = MergeTree()
ORDER BY (timestamp, user_id)
AS SELECT *
FROM logs.events
WHERE gpu_type = 'V100';

-- Verify table creation
SHOW TABLES FROM logs;

-- Show table schema
DESCRIBE logs.events;
