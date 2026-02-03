import requests
import pandas as pd
from google.cloud import bigquery
from datetime import datetime, timezone


PROJECT_ID = "project-e0c626dd-6b61-4b52-a57"
DATASET_ID = "raw_data"
TABLE_ID = "github_issues"

REPO_OWNER = "apache"
REPO_NAME = "airflow"
ISSUES_URL = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/issues"


def fetch_github_issues():
    response = requests.get(ISSUES_URL, params={"state": "all", "per_page": 100})
    response.raise_for_status()
    return response.json()


def transform_issues(issues):
    rows = []

    for issue in issues:
        if "pull_request" in issue:
            continue  # Excluir PRs

        rows.append({
            "issue_id": issue["id"],
            "number": issue["number"],
            "title": issue["title"],
            "state": issue["state"],
            "created_at": issue["created_at"],
            "closed_at": issue["closed_at"],
            "author": issue["user"]["login"],
            "repo": f"{REPO_OWNER}/{REPO_NAME}",
            "ingestion_date": datetime.now(timezone.utc)
        })

    return pd.DataFrame(rows)


def load_to_bigquery(df):
    client = bigquery.Client(project=PROJECT_ID)
    table_ref = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"

    job = client.load_table_from_dataframe(
        df,
        table_ref,
        job_config=bigquery.LoadJobConfig(
            write_disposition="WRITE_TRUNCATE"
        )
    )

    job.result()
    print(f"Loaded {job.output_rows} rows into {table_ref}")


def main():
    issues = fetch_github_issues()
    df = transform_issues(issues)
    load_to_bigquery(df)


if __name__ == "__main__":
    main()