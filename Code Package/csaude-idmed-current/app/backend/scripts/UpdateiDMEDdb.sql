-- 1.8.0

-- Para a primeira CTE (crítico!)
CREATE INDEX idx_pack_pickup_date 
    ON pack(pickup_date) 
    WHERE pickup_date IS NOT NULL;

CREATE INDEX idx_pvd_pack_episode 
    ON patient_visit_details(pack_id, episode_id, patient_visit_id);

CREATE INDEX idx_episode_psi_ssr 
    ON episode(id, patient_service_identifier_id, start_stop_reason_id);

CREATE INDEX idx_psi_service 
    ON patient_service_identifier(id, service_id);

CREATE INDEX idx_patient_visit_patient 
    ON patient_visit(id, patient_id);

-- Para a segunda CTE
CREATE INDEX idx_pvd_pack_prescription 
    ON patient_visit_details(pack_id, prescription_id);

CREATE INDEX idx_prescription_detail_prescription 
    ON prescription_detail(prescription_id, therapeutic_regimen_id, therapeutic_line_id);

select initstockmovementbatch();

LF
Ln 23, Col 90
