MERGE `project-e0c626dd-6b61-4b52-a57.analytics.issue_status_history` T
USING (
  -- Último estado conocido por issue desde raw
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
) S
ON T.issue_id = S.issue_id
AND T.is_current = TRUE

-- Caso 1: existe y el estado ha cambiado → cerrar el anterior
WHEN MATCHED AND T.state != S.state THEN
  UPDATE SET
    T.valid_to = S.ingestion_date,
    T.is_current = FALSE

-- Caso 2: no existe aún → insertar nuevo estado
WHEN NOT MATCHED THEN
  INSERT (issue_id, state, valid_from, valid_to, is_current)
  VALUES (
    S.issue_id,
    S.state,
    S.ingestion_date,
    NULL,
    TRUE
  );
