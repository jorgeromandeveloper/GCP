-- Detects only meaningful state changes for each issue

WITH ordered_issues AS (
  SELECT
    issue_id,
    state,
    ingestion_date,
    LAG(state) OVER (
      PARTITION BY issue_id
      ORDER BY ingestion_date
    ) AS previous_state
  FROM `project-e0c626dd-6b61-4b52-a57.raw_data.github_issues`
)

SELECT
  issue_id,
  state,
  ingestion_date
FROM ordered_issues
WHERE previous_state IS NULL
   OR state != previous_state
ORDER BY issue_id, ingestion_date;
