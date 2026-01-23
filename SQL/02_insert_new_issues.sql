INSERT INTO `project-e0c626dd-6b61-4b52-a57.analytics.issues`
(issue_id, number, title, author, repo)

SELECT DISTINCT
  r.issue_id,
  r.number,
  r.title,
  r.author,
  r.repo
FROM `project-e0c626dd-6b61-4b52-a57.raw_data.github_issues` r
LEFT JOIN `project-e0c626dd-6b61-4b52-a57.analytics.issues` a
  ON r.issue_id = a.issue_id
WHERE a.issue_id IS NULL;
