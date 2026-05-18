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

-- Refreshable materialized view to aggregate hourly resource usage
-- This runs on a schedule (every hour) instead of triggering on INSERT
-- Processes all historical data to maintain a complete running total
-- Note: Refreshable views store data directly, no separate target table needed
CREATE MATERIALIZED VIEW IF NOT EXISTS logs.hourly_resource_usage_mv
REFRESH EVERY 1 HOUR
ENGINE = MergeTree()
ORDER BY (hour, user_id, gpu_type, gpu_provider, job_name)
PARTITION BY toYYYYMM(hour)
AS SELECT
  toStartOfHour(timestamp) AS hour,
  user_id,
  gpu_type,
  gpu_provider,
  job_name,
  sum(vram_usage * interval_seconds) / 60.0 AS vram_minutes,
  sum(cpu_usage * interval_seconds) / 60.0 AS cpu_minutes,
  sum(memory_usage * interval_seconds) / 60.0 AS memory_minutes,
  count() AS event_count
FROM logs.events
GROUP BY hour, user_id, gpu_type, gpu_provider, job_name;

-- Verify table creation
SHOW TABLES FROM logs;

-- Show table schema
DESCRIBE logs.events;
