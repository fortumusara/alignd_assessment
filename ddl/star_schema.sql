-- Patients Dimension
CREATE TABLE dim_patients (
    patient_id SERIAL PRIMARY KEY,
    client_name VARCHAR(255),
    date_of_birth DATE,
    gender VARCHAR(20)
);

-- Products Dimension
CREATE TABLE dim_products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(255),
    tier VARCHAR(50),
    status VARCHAR(50)
);

-- Time Dimension
CREATE TABLE dim_time (
    date_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE,
    year INT,
    month INT,
    day INT
);
-- Patient Claims Summary Fact
CREATE TABLE fct_patient_claims_summary (
    claim_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES dim_patients(patient_id),
    product_id VARCHAR(20) REFERENCES dim_products(product_id),
    date_id INT REFERENCES dim_time(date_id),
    claim_amount NUMERIC(12,2),
    claim_status VARCHAR(50)
);
