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

