-- ==========================================
-- Task 4: SQL Transformation & Data Quality
-- Deduplication + Imputation in one script
-- ==========================================

-- Step 1: Deduplicate claims by patient_id
-- Keep the latest claim (highest date_id) or highest claim_amount
WITH ranked_claims AS (
    SELECT
        f.claim_id,
        f.patient_id,
        f.product_id,
        f.date_id,
        f.claim_amount,
        f.claim_status,
        ROW_NUMBER() OVER (
            PARTITION BY f.patient_id
            ORDER BY f.date_id DESC, f.claim_amount DESC
        ) AS rn
    FROM fct_patient_claims_summary f
)
-- Create a cleaned claims table
CREATE TABLE fct_patient_claims_clean AS
SELECT *
FROM ranked_claims
WHERE rn = 1;

-- Step 2: Impute NULL income values in dim_patients
-- Strategy: Median imputation (robust against outliers)
WITH median_income AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY income) AS med
    FROM dim_patients
    WHERE income IS NOT NULL
)
UPDATE dim_patients
SET income = (SELECT med FROM median_income)
WHERE income IS NULL;

-- Step 3: Create unified analytical dataset view
CREATE OR REPLACE VIEW vw_patient_claims AS
SELECT
    dp.patient_id,
    dp.client_name,
    dp.gender,
    dp.income,
    pr.product_name,
    pr.tier,
    pr.status,
    dt.full_date,
    f.claim_amount,
    f.claim_status
FROM fct_patient_claims_clean f
JOIN dim_patients dp ON f.patient_id = dp.patient_id
JOIN dim_products pr ON f.product_id = pr.product_id
JOIN dim_time dt ON f.date_id = dt.date_id;
