#Metrics to track:

#Open issues
SELECT COUNT(*) AS open_issues
FROM `project-e0c626dd-6b61-4b52-a57.analytics.issue_status_history`
WHERE is_current = TRUE
  AND state = 'open';

#Average time to close issues
SELECT
  AVG(TIMESTAMP_DIFF(valid_to, valid_from, HOUR)) AS avg_hours_to_close
FROM `project-e0c626dd-6b61-4b52-a57.analytics.issue_status_history`
WHERE state = 'open'
  AND valid_to IS NOT NULL;

#Number of issues reopened

WITH ordered_issues AS (
  SELECT
    issue_id,
    state,
    ingestion_date,
    LEAD(state) OVER (
      PARTITION BY issue_id
      ORDER BY ingestion_date
    ) AS next_state
  FROM `project-e0c626dd-6b61-4b52-a57.raw_data.github_issues`
)

SELECT
    issue_id,
    state,
    ingestion_date
FROM ordered_issues
WHERE

