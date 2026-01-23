INSERT INTO `project-e0c626dd-6b61-4b52-a57.analytics.issue_status_history`
(issue_id, state, valid_from, valid_to, is_current)

SELECT
  s.issue_id,
  s.state,
  s.ingestion_date AS valid_from,
  NULL AS valid_to,
  TRUE AS is_current
FROM (
  SELECT
    issue_id,
    state,
    ingestion_date
  FROM (
    SELECT
      issue_id,
      state,
      ingestion_date,
      ROW_NUMBER() OVER (
        PARTITION BY issue_id
        ORDER BY ingestion_date DESC
      ) AS rn
    FROM `project-e0c626dd-6b61-4b52-a57.raw_data.github_issues`
  )
  WHERE rn = 1
) s
LEFT JOIN `project-e0c626dd-6b61-4b52-a57.analytics.issue_status_history` t
  ON s.issue_id = t.issue_id
 AND t.is_current = TRUE
WHERE t.issue_id IS NULL
   OR t.state != s.state;
