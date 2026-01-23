-- Creates the historical table for issue status changes (SCD Type 2)

CREATE TABLE IF NOT EXISTS `project-e0c626dd-6b61-4b52-a57.analytics.issue_status_history` (
  issue_id    INT64,
  state       STRING,
  valid_from  TIMESTAMP,
  valid_to    TIMESTAMP,
  is_current  BOOL
);
