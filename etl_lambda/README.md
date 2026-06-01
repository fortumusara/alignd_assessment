#  Data Engineering Assessment: Resilient Pipelines

##  Overview
This project implements a **cloud-based ETL pipeline on AWS** that ingests raw data, processes it with resilient error handling, loads it into a **PostgreSQL star schema**, validates data quality, and transforms it into **analytics-ready datasets** using **dbt**.  
The environment is containerized with **Docker + Poetry** for reproducibility and scalability.

---

## Architecture Diagram
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

## Repository Structure
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
### Step 1. Run the Bash Script (Infrastructure Setup)
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



### Step 2. Upload the Python Code (Lambda Logic)
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

### Step 3. Verify Deployment

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

  # Task 2: Production-Grade Python (Data Cleaning)

##  Goal
Process the `health_products.txt` file into a clean CSV.  
This file contains a metadata header and uses pipe (`|`) delimiters.  
The script must be **idempotent** (safe to run multiple times) and handle **programmatic discovery of the data structure**.

---

### Requirements
- Input file: `data_files/health_products.txt`
- Metadata header: `--- CONFIDENTIAL: INTERNAL ALIGND EXPORT YYYY-MM-DD ---`
- Delimiter: `|`
- Output file: `data_files/health_products_clean.csv`
- Script must:
  - Remove metadata header
  - Discover schema dynamically
  - Normalize product IDs to uppercase
  - Strip whitespace, drop duplicates, and fill missing values
  - Overwrite output safely (idempotent)

---

###  Repository Placement
```text
alignd_assessment/
│
├── scripts/
│   └── clean_health_products.py   # Task 2 cleaning script
│
├── data_files/
│   ├── health_products.txt        # Raw input file
│   └── health_products_clean.csv  # Cleaned output file (generated)

```

#  Task 3: Schema Design & Modeling (PostgreSQL)

##  Goal
Load all files into a **PostgreSQL database** using DBeaver or a script.  
Design a **Star Schema** with Fact and Dimension tables. Provide DDL scripts including **Primary/Foreign keys** and an **indexing strategy** for join columns.

---

##  Requirements
- Input files: `clients.csv`, `health_lapses.parquet`, `health_products_clean.csv`
- Database: PostgreSQL
- Tooling: DBeaver (GUI) or SQL scripts
- Schema design: **Star Schema**
  - **Fact table** → transactional/measure data
  - **Dimension tables** → descriptive attributes
- Constraints:
  - Primary keys on dimension tables
  - Foreign keys in fact table referencing dimensions
  - Indexes on join columns for performance

---

## Repository Placement
```text
alignd_assessment/
│
├── ddl/
│   ├── star_schema.sql     # DDL for fact + dimension tables
│   └── indexes.sql         # Indexing strategy
```

 ## Usage
### Step 1: Connect to PostgreSQL
Open DBeaver and connect to your PostgreSQL instance.

Alternatively, use psql CLI or a Python script with psycopg2.

### Step 2: Create Schema
Run the DDL scripts:

```bash
psql -U <username> -d <database> -f ddl/star_schema.sql
psql -U <username> -d <database> -f ddl/indexes.sql
```

### Step 3: Load Data
Import clients.csv into dim_patients.

Import health_products_clean.csv into dim_products.

Import health_lapses.parquet into fct_patient_claims_summary (via Python/ETL script or DBeaver import).

Populate dim_time by generating dates from your claims data.

### Step 4: Verify Joins
Run a test query:

```sql
SELECT p.tier, SUM(f.claim_amount) AS total_claims
FROM fct_patient_claims_summary f
JOIN dim_products p ON f.product_id = p.product_id
GROUP BY p.tier;
```
### Step 5: Optimize
Check query plans with EXPLAIN ANALYZE.

Add composite indexes if queries frequently filter by multiple dimensions.

Partition fact table if data volume grows significantly.

 Example Query
```sql
-- Claims by patient and product
SELECT dp.client_name, pr.product_name, SUM(f.claim_amount) AS total_claims
FROM fct_patient_claims_summary f
JOIN dim_patients dp ON f.patient_id = dp.patient_id
JOIN dim_products pr ON f.product_id = pr.product_id
GROUP BY dp.client_name, pr.product_name
ORDER BY total_claims DESC;
```
#  Task 4: SQL Transformation & Data Quality

##  Goal
Create a **unified analytical dataset** from the PostgreSQL star schema.  
Ensure **data quality** by resolving duplicates and imputing missing values.

---

##  Requirements
- **Deduplication**: Resolve duplicate records for the same client ID.  
- **Imputation**: Provide a strategy for handling `NULL` income values and justify the statistical method.  
- **Unified dataset**: Join fact and dimension tables into a single analytical view.

---

##  Repository Placement
```text
alignd_assessment/
│
├── sql/
│   ├── transformations.sql   # Deduplication + imputation logic
│   └── analytical_view.sql   # Unified dataset view
```

## Usage
Run sql/transformations.sql in PostgreSQL (via DBeaver or psql).

This will:

Deduplicate claims into fct_patient_claims_clean.

Impute missing incomes in dim_patients.

Create the unified analytical view vw_patient_claims.

Query vw_patient_claims for analytics.

#  Task 5: Automation & Environment (dbt)

##  Goal
Orchestrate the pipeline using the provided **Docker/Poetry environment**.  
Implement dbt models and tests to ensure data quality and reproducibility.

---

##  Requirements
- Create dbt models for:
  - `dim_patients`
  - `fct_patient_claims_summary`
- Implement dbt tests (`unique`, `not_null`) in `schema.yml`.
- Run inside Docker/Poetry environment for reproducibility.

---

##  Repository Placement
```text
alignd_assessment/
│
├── dbt_project/                        # dbt project folder (models + configs)
│   ├── models/                         # SQL models for dimensions and facts
│   │   ├── dim_patients.sql            # Patient dimension model (from clients.csv)
│   │   ├── fct_patient_claims_summary.sql # Claims fact model (from health_lapses.parquet)
│   │   └── schema.yml                  # dbt tests (unique, not_null) for data quality
│   ├── dbt_project.yml                 # Core dbt project configuration (name, profile, seeds, sources)
├── docker/                           # Containerized environment for dbt + PostgreSQL
│   ├── Dockerfile                    # Build instructions for the dbt environment (Python, Poetry, dbt, psycopg2)
│   ├── poetry.lock                   # Auto-generated lockfile (exact dependency versions for reproducibility)
│   └── pyproject.toml                # Poetry project definition (declares dbt-core, dbt-postgres, psycopg2, etc.)
     
```
##  Usage

### Step 1: Build Docker/Poetry Environment
From the project root, build and run the container:

```bash
docker build -t dbt_env -f docker/Dockerfile .
docker run -it -v $(pwd):/app dbt_env bash

```
### Step 2: Initialize dbt Project
Inside the container:

```bash
dbt debug
dbt deps
```
### Step 3: Run dbt Models
Execute the dimension and fact models:

```bash
dbt run --models dim_patients fct_patient_claims_summary
```
### Step 4: Run dbt Tests
Validate schema constraints:

```bash
dbt test
```
### Step 5: Verify Outputs

- `dim_patients` → dimension table populated from clients.csv  
- `fct_patient_claims_summary` → fact table populated from health_lapses.parquet  
- Tests ensure unique keys and not_null constraints on critical columns  

### Step 6: Query Results
Use dbt’s ref() in downstream models or query directly:


```sql
SELECT dp.client_name, SUM(f.claim_amount) AS total_claims
FROM {{ ref('fct_patient_claims_summary') }} f
JOIN {{ ref('dim_patients') }} dp ON f.patient_id = dp.patient_id
GROUP BY dp.client_name
ORDER BY total_claims DESC;
```









