-- dbt model: dim_patients
SELECT
    patient_id,
    client_name,
    date_of_birth,
    gender,
    income
FROM {{ source('raw', 'clients') }};
