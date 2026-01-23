#Metrics to track:

#Open issues
SELECT COUNT(*) AS open_issues
FROM `project-e0c626dd-6b61-4b52-a57.analytics.issue_status_history`
WHERE is_current = TRUE
  AND state = 'open';

#Closed issues
SELECT COUNT(*) AS open_issues
FROM `project-e0c626dd-6b61-4b52-a57.analytics.issue_status_history`
WHERE is_current = TRUE
  AND state = 'closed';

#Average time to close issues
SELECT
  AVG(TIMESTAMP_DIFF(valid_to, valid_from, HOUR)) AS avg_hours_to_close
FROM `project-e0c626dd-6b61-4b52-a57.analytics.issue_status_history`
WHERE state = 'open'
  AND valid_to IS NOT NULL;


#Number of issues reopened

WITH reopen_events AS (
  SELECT
    issue_id,
    valid_from,
    LAG(state) OVER (
      PARTITION BY issue_id
      ORDER BY valid_from
    ) AS previous_state,
    state
  FROM `project-e0c626dd-6b61-4b52-a57.analytics.issue_status_history`
),
current_state AS (
  SELECT issue_id
  FROM `project-e0c626dd-6b61-4b52-a57.analytics.issue_status_history`
  WHERE is_current = TRUE
    AND state = 'open'
)

SELECT DISTINCT r.issue_id
FROM reopen_events r
JOIN current_state c
  ON r.issue_id = c.issue_id
WHERE r.state = 'open'
  AND r.previous_state = 'closed';

