# 🧠 Data Engineering Assessment: Resilient Pipelines

## 📘 Overview
This project implements a **cloud-based ETL pipeline on AWS** that ingests raw data, processes it with resilient error handling, loads it into a **PostgreSQL star schema**, validates data quality, and transforms it into **analytics-ready datasets** using **dbt**.  
The environment is containerized with **Docker + Poetry** for reproducibility and scalability.

---

## 🧩 Architecture Diagram
![AWS ETL Pipeline](docs/architecture_diagram.png)

**Caption:**  
This architecture illustrates the end-to-end AWS ETL pipeline. Raw data uploaded to S3 triggers a Lambda function that converts and validates files. Cleaned data flows into PostgreSQL for structured storage and then feeds dbt models for automated transformation and testing. The Docker environment ensures reproducibility, while CloudWatch provides monitoring and error visibility.

---

## ⚙️ Components
| Layer | Technology | Purpose |
|-------|-------------|----------|
| Ingestion | **AWS S3** | Stores raw and processed data |
| Processing | **AWS Lambda** | Converts `.parquet` → `.csv`, handles errors |
| Cleaning | **Python Script** | Parses and cleans pipe-delimited files |
| Storage | **PostgreSQL** | Implements star schema for analytics |
| Transformation | **dbt** | Builds models and runs data quality tests |
| Environment | **Docker + Poetry** | Ensures reproducible builds |
| Monitoring | **CloudWatch** | Logs ETL events and errors |

---

## 🧱 Repository Structure
```text

alignd_assessment/
│
├── etl_lambda/                  # AWS Lambda ETL function
│   ├── lambda_function.py        # Converts Parquet → CSV with error handling
│   ├── requirements.txt          # Python dependencies for Lambda
│   └── README.md                 # Notes on deployment and configuration
│
├── scripts/                      # Data cleaning scripts
│   └── clean_health_products.py  # Cleans pipe-delimited health_products.txt
│
├── ddl/                          # Database schema definitions
│   ├── star_schema.sql           # Star schema DDL (fact + dimension tables)
│   └── indexes.sql               # Indexing strategy for join columns
│
├── dbt_project/                  # dbt models and configs
│   ├── models/
│   │   ├── dim_patients.sql
│   │   ├── fct_patient_claims_summary.sql
│   │   └── schema.yml            # dbt tests (unique, not_null)
│   ├── dbt_project.yml
│   └── README.md
│
├── docker/                       # Containerized environment
│   ├── Dockerfile                # Docker build for dbt + PostgreSQL
│   ├── poetry.lock               # Poetry lockfile
│   └── pyproject.toml            # Poetry project definition
│
├── data_files/                   # Sample input data
│   ├── clients.csv
│   ├── health_lapses.parquet
│   └── health_products.txt
│
├── docs/                         # Documentation and diagrams
│   ├── architecture_diagram.png  # Final AWS ETL pipeline diagram
│   └── README_architecture.md    # Narrative walkthrough of architecture
│
├── .gitignore                    # Ignore rules (env files, data dumps, etc.)
└── README.md                     # Root project documentation


 ```


## Deployment Instructions – Task 1: Resilient Cloud ETL
## 1. Run the Bash Script (Infrastructure Setup)
The bash script is stored in `scripts/setup_task1.sh`
The bash script will:
- Create the required S3 buckets (`[initials]-source-bucket-analytics` and `[initials]-processed-bucket-analytics`)
- Package the Lambda code into a ZIP
- Deploy the Lambda function with the correct role and handler

Create the script using `nano`:

```bash
nano setup_task1.sh
 ```
Paste in your bash script, save (CTRL+O), and exit (CTRL+X).

Make it executable and run the script:
```bash
chmod +x setup_task1.sh
./setup_task1.sh
 ```



## 2. Upload the Python Code (Lambda Logic)
The Lambda function logic is stored in `etl_lambda/lambda_function.py`.  
This script handles:
- Converting `health_lapses.parquet` → CSV
- Uploading the CSV to the processed bucket
- Moving failed files to `/error/` prefix and logging to CloudWatch

After editing or updating the Python code, Create or edit the file using nano:

```bash
nano etl_lambda/lambda_function.py
 ```
repackage and update the Lambda:

```bash
cd etl_lambda
zip -r ../etl_lambda.zip .
cd ..
aws lambda update-function-code \
  --function-name <initials>-etl-function \
  --zip-file fileb://etl_lambda.zip
 ```

## 3. Verify Deployment

Once the infrastructure and Lambda function are set up:

1. Upload `health_lapses.parquet` to your **source bucket**:

2. Check outcomes:
-  **Success** → A converted CSV file appears in `s3://<initials>-processed-bucket-analytics/`.
-  **Failure** → The original parquet file is moved to `s3://<initials>-source-bucket-analytics/error/`.

3. Review logs in **CloudWatch**:
- Navigate to the Lambda’s log group in the AWS Console.
- Confirm that success or error events are logged with details.

4. (Optional) Test with additional files:
- Upload `clients.csv` or `health_products.txt` to validate bucket permissions and Lambda triggers.




