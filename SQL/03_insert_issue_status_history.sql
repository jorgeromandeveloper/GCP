-- Inserts historical issue state changes into analytics table (SCD Type 2)

INSERT INTO `project-e0c626dd-6b61-4b52-a57.analytics.issue_status_history`
(issue_id, state, valid_from, valid_to, is_current)

WITH changes AS (
  SELECT
    issue_id,
    state,
    ingestion_date AS valid_from,
    LEAD(ingestion_date) OVER (
      PARTITION BY issue_id
      ORDER BY ingestion_date
    ) AS next_change
  FROM (
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
  WHERE previous_state IS NULL
     OR state != previous_state
)

SELECT
  issue_id,
  state,
  valid_from,
  next_change AS valid_to,
  next_change IS NULL AS is_current
FROM changes;
