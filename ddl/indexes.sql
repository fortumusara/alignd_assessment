-- Indexes on foreign keys for faster joins
CREATE INDEX idx_claims_patient ON fct_patient_claims_summary(patient_id);
CREATE INDEX idx_claims_product ON fct_patient_claims_summary(product_id);
CREATE INDEX idx_claims_date ON fct_patient_claims_summary(date_id);

-- Optional composite index for frequent queries
CREATE INDEX idx_claims_patient_product_date
    ON fct_patient_claims_summary(patient_id, product_id, date_id);
