-- dbt model: fct_patient_claims_summary
SELECT
    claim_id,
    patient_id,
    product_id,
    date_id,
    claim_amount,
    claim_status
FROM {{ source('raw', 'health_lapses') }};
