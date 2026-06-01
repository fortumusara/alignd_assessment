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
FROM fct_patient_claims_summary f
JOIN dim_patients dp ON f.patient_id = dp.patient_id
JOIN dim_products pr ON f.product_id = pr.product_id
JOIN dim_time dt ON f.date_id = dt.date_id;
