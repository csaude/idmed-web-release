#/bin/bash

# Entrypoint Script
# Author: colaco.nhongo@csaude.org.mz
# Version: 1.5.0
# October 21th, 2022
# Update Dec 2nd, 2024
bucardo -h db -U bucardo add table clinical_service_clinic_sectors db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add customcols clinical_service_clinic_sectors "SELECT clinical_service_id,clinic_sector_id" db=main
bucardo -h db -U bucardo add table stock_adjustment db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table referred_patients_report db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table clinical_service_attribute db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_trans_reference_type db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table destroyed_stock db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table doctor db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table refered_stock_moviment db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table service_patient db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table stock_center db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table inventory db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table appointment db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_trans_reference db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table stock_operation_type db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table health_information_system db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table clinic db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table clinic_sector db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table group_info db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table stock_entrance db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table group_member db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table stock_level db=main relgroup=idmed_relgroupbucardo -h db -U bucardo add db idmedCentral db=idmed_maputo0 user=postgres pass=1csaude2 port=5432 host=idmed.csaude.org.mz
bucardo -h db -U bucardo add table stock db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table group_member_prescription db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table drug_distributor db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table stock_distributor_batch db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_attribute db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table group_pack db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table group_pack_header db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table form db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table national_clinic db=main relgroup=idmed_relgroup

# Particoes
# bucardo -h db -U bucardo add table pack db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122008 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122009 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122010 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122011 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122012 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122013 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122014 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122015 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122016 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122017 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122018 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122019 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122020 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122021 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122022 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122023 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122024 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122025 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122026 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122027 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122028 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122029 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122030 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_21122031 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pack_others db=main relgroup=idmed_relgroup

# bucardo -h db -U bucardo add table patient db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_1000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_2000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_3000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_4000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_5000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_6000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_7000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_8000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_9000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_10000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_11000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_12000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_13000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_14000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_15000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_16000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_17000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_18000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_19000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_20000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_21000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_22000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_23000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_24000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_25000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_26000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_27000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_28000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_29000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_30000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_31000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_32000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_33000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_34000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_35000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_36000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_37000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_38000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_39000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_40000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_41000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_42000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_43000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_44000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_45000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_46000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_47000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_48000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_49000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_50000 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_others db=main relgroup=idmed_relgroup

# bucardo -h db -U bucardo add table patient_service_identifier db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122008 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122009 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122010 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122011 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122012 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122013 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122014 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122015 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122016 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122017 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122018 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122019 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122020 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122021 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122022 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122023 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122024 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122025 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21212026 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122027 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122028 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122029 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122030 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_21122031 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_service_identifier_others db=main relgroup=idmed_relgroup

# bucardo -h db -U bucardo add table episode db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122008 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122009 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122010 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122011 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122012 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122013 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122014 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122015 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122016 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122017 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122018 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122019 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122020 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122021 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122022 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122023 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122024 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122025 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122026 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122027 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122028 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122029 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122030 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_21122031 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_others db=main relgroup=idmed_relgroup

# bucardo -h db -U bucardo add table patient_visit db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122008 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122009 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122010 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122011 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122012 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122013 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122014 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122015 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122016 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122017 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122018 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122019 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122020 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122021 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122022 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122023 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122024 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122025 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122026 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122027 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122028 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122029 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122030 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_21122031 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_visit_others db=main relgroup=idmed_relgroup

# bucardo -h db -U bucardo add table prescription db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122008 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122009 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122010 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122011 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122012 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122013 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122014 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122015 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122016 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122017 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122018 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122019 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122020 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122021 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122022 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122023 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122024 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122025 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122026 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122027 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122028 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122029 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122030 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_21122031 db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_others db=main relgroup=idmed_relgroup

bucardo -h db -U bucardo add table patient_visit_details db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescribed_drug db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table prescription_detail db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table packaged_drug db=main relgroup=idmed_relgroup

bucardo -h db -U bucardo add table tbscreening db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table adherence_screening db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table vital_signs_screening db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table ramscreening db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table pregnancy_screening db=main relgroup=idmed_relgroup

#Tabelas que deveriam ter dados harmonizados
bucardo -h db -U bucardo add table therapeutic_line db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table spetial_prescription_motive db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table interoperability_attribute db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table clinical_service_attribute_type db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table clinical_service db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table patient_attribute_type db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table therapeutic_regimen db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table clinic_sector_type db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table identifier_type db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table duration db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table drug db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table start_stop_reason db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table episode_type db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table group_type db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table dispense_mode db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table province db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table district db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table posto_administrativo db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table localidade db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table dispense_type db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table interoperability_type db=main relgroup=idmed_relgroup
bucardo -h db -U bucardo add table facility_type db=main relgroup=idmed_relgroup

bucardo -h db -U bucardo add customcode patient_visit_details_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_details getdbh=1
bucardo -h db -U bucardo add customcode prescribed_drug_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescribed_drug getdbh=1
bucardo -h db -U bucardo add customcode prescription_detail_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_detail getdbh=1
bucardo -h db -U bucardo add customcode packaged_drug_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=packaged_drug getdbh=1

bucardo -h db -U bucardo add customcode tbscreening_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=tbscreening getdbh=1
bucardo -h db -U bucardo add customcode adherence_screening_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=adherence_screening getdbh=1
bucardo -h db -U bucardo add customcode vital_signs_screening_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=vital_signs_screening getdbh=1
bucardo -h db -U bucardo add customcode ramscreening_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=ramscreening getdbh=1
bucardo -h db -U bucardo add customcode pregnancy_screening_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pregnancy_screening getdbh=1

#Particoes
bucardo -h db -U bucardo add customcode pack_21122008 pack_21122008_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122008 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122009 pack_21122009_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122009 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122010 pack_21122010_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122010 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122011 pack_21122011_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122011 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122012 pack_21122012_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122012 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122013 pack_21122013_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122013 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122014 pack_21122014_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122014 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122015 pack_21122015_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122015 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122016 pack_21122016_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122016 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122017 pack_21122017_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122017 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122018 pack_21122018_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122018 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122019 pack_21122019_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122019 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122020 pack_21122020_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122020 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122021 pack_21122021_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122021 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122022 pack_21122022_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122022 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122023 pack_21122023_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122023 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122024 pack_21122024_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122024 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122025 pack_21122025_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122025 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122026 pack_21122026_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122026 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122027 pack_21122027_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122027 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122028 pack_21122028_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122028 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122029 pack_21122029_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122029 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122030 pack_21122030_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122030 getdbh=1
bucardo -h db -U bucardo add customcode pack_21122031 pack_21122031_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_21122031 getdbh=1
bucardo -h db -U bucardo add customcode pack_others   pack_others_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=pack_others getdbh=1

bucardo -h db -U bucardo add customcode patient_1000  patient_1000_filter_only_us_rec  whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_1000 getdbh=1
bucardo -h db -U bucardo add customcode patient_2000  patient_2000_filter_only_us_rec  whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_2000 getdbh=1
bucardo -h db -U bucardo add customcode patient_3000  patient_3000_filter_only_us_rec  whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_3000 getdbh=1
bucardo -h db -U bucardo add customcode patient_4000  patient_4000_filter_only_us_rec  whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_4000 getdbh=1
bucardo -h db -U bucardo add customcode patient_5000  patient_5000_filter_only_us_rec  whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_5000 getdbh=1
bucardo -h db -U bucardo add customcode patient_6000  patient_6000_filter_only_us_rec  whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_6000 getdbh=1
bucardo -h db -U bucardo add customcode patient_7000  patient_7000_filter_only_us_rec  whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_7000 getdbh=1
bucardo -h db -U bucardo add customcode patient_8000  patient_8000_filter_only_us_rec  whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_8000 getdbh=1
bucardo -h db -U bucardo add customcode patient_9000  patient_9000_filter_only_us_rec  whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_9000 getdbh=1
bucardo -h db -U bucardo add customcode patient_10000 patient_10000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_10000 getdbh=1
bucardo -h db -U bucardo add customcode patient_11000 patient_11000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_11000 getdbh=1
bucardo -h db -U bucardo add customcode patient_12000 patient_12000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_12000 getdbh=1
bucardo -h db -U bucardo add customcode patient_13000 patient_13000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_13000 getdbh=1
bucardo -h db -U bucardo add customcode patient_14000 patient_14000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_14000 getdbh=1
bucardo -h db -U bucardo add customcode patient_15000 patient_15000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_15000 getdbh=1
bucardo -h db -U bucardo add customcode patient_16000 patient_16000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_16000 getdbh=1
bucardo -h db -U bucardo add customcode patient_17000 patient_17000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_17000 getdbh=1
bucardo -h db -U bucardo add customcode patient_18000 patient_18000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_18000 getdbh=1
bucardo -h db -U bucardo add customcode patient_19000 patient_19000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_19000 getdbh=1
bucardo -h db -U bucardo add customcode patient_20000 patient_20000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_20000 getdbh=1
bucardo -h db -U bucardo add customcode patient_21000 patient_21000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_21000 getdbh=1
bucardo -h db -U bucardo add customcode patient_22000 patient_22000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_22000 getdbh=1
bucardo -h db -U bucardo add customcode patient_23000 patient_23000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_23000 getdbh=1
bucardo -h db -U bucardo add customcode patient_24000 patient_24000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_24000 getdbh=1
bucardo -h db -U bucardo add customcode patient_25000 patient_25000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_25000 getdbh=1
bucardo -h db -U bucardo add customcode patient_26000 patient_26000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_26000 getdbh=1
bucardo -h db -U bucardo add customcode patient_27000 patient_27000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_27000 getdbh=1
bucardo -h db -U bucardo add customcode patient_28000 patient_28000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_28000 getdbh=1
bucardo -h db -U bucardo add customcode patient_29000 patient_29000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_29000 getdbh=1
bucardo -h db -U bucardo add customcode patient_30000 patient_30000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_30000 getdbh=1
bucardo -h db -U bucardo add customcode patient_31000 patient_31000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_31000 getdbh=1
bucardo -h db -U bucardo add customcode patient_32000 patient_32000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_32000 getdbh=1
bucardo -h db -U bucardo add customcode patient_33000 patient_33000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_33000 getdbh=1
bucardo -h db -U bucardo add customcode patient_34000 patient_34000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_34000 getdbh=1
bucardo -h db -U bucardo add customcode patient_35000 patient_35000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_35000 getdbh=1
bucardo -h db -U bucardo add customcode patient_36000 patient_36000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_36000 getdbh=1
bucardo -h db -U bucardo add customcode patient_37000 patient_37000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_37000 getdbh=1
bucardo -h db -U bucardo add customcode patient_38000 patient_38000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_38000 getdbh=1
bucardo -h db -U bucardo add customcode patient_39000 patient_39000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_39000 getdbh=1
bucardo -h db -U bucardo add customcode patient_40000 patient_40000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_40000 getdbh=1
bucardo -h db -U bucardo add customcode patient_41000 patient_41000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_41000 getdbh=1
bucardo -h db -U bucardo add customcode patient_42000 patient_42000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_42000 getdbh=1
bucardo -h db -U bucardo add customcode patient_43000 patient_43000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_43000 getdbh=1
bucardo -h db -U bucardo add customcode patient_44000 patient_44000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_44000 getdbh=1
bucardo -h db -U bucardo add customcode patient_45000 patient_45000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_45000 getdbh=1
bucardo -h db -U bucardo add customcode patient_46000 patient_46000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_46000 getdbh=1
bucardo -h db -U bucardo add customcode patient_47000 patient_47000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_47000 getdbh=1
bucardo -h db -U bucardo add customcode patient_48000 patient_48000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_48000 getdbh=1
bucardo -h db -U bucardo add customcode patient_49000 patient_49000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_49000 getdbh=1
bucardo -h db -U bucardo add customcode patient_50000 patient_50000_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_50000 getdbh=1
bucardo -h db -U bucardo add customcode patient_others patient_others_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_others getdbh=1

bucardo -h db -U bucardo add customcode patient_service_identifier_21122008 patient_service_identifier_21122008_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122008 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122009 patient_service_identifier_21122009_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122009 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122010 patient_service_identifier_21122010_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122010 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122011 patient_service_identifier_21122011_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122011 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122012 patient_service_identifier_21122012_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122012 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122013 patient_service_identifier_21122013_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122013 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122014 patient_service_identifier_21122014_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122014 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122015 patient_service_identifier_21122015_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122015 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122016 patient_service_identifier_21122016_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122016 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122017 patient_service_identifier_21122017_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122017 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122018 patient_service_identifier_21122018_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122018 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122019 patient_service_identifier_21122019_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122019 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122020 patient_service_identifier_21122020_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122020 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122021 patient_service_identifier_21122021_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122021 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122022 patient_service_identifier_21122022_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122022 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122023 patient_service_identifier_21122023_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122023 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122024 patient_service_identifier_21122024_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122024 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122025 patient_service_identifier_21122025_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122025 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21212026 patient_service_identifier_21212026_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21212026 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122027 patient_service_identifier_21122027_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122027 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122028 patient_service_identifier_21122028_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122028 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122029 patient_service_identifier_21122029_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122029 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122030 patient_service_identifier_21122030_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122030 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_21122031 patient_service_identifier_21122031_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_21122031 getdbh=1
bucardo -h db -U bucardo add customcode patient_service_identifier_others   patient_service_identifier_others_filter_only_us_rec   whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_service_identifier_others   getdbh=1

bucardo -h db -U bucardo add customcode episode_21122008 episode_21122008_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122008 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122009 episode_21122009_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122009 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122010 episode_21122010_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122010 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122011 episode_21122011_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122011 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122012 episode_21122012_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122012 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122013 episode_21122013_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122013 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122014 episode_21122014_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122014 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122015 episode_21122015_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122015 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122016 episode_21122016_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122016 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122017 episode_21122017_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122017 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122018 episode_21122018_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122018 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122019 episode_21122019_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122019 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122020 episode_21122020_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122020 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122021 episode_21122021_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122021 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122022 episode_21122022_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122022 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122023 episode_21122023_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122023 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122024 episode_21122024_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122024 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122025 episode_21122025_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122025 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122026 episode_21122026_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122026 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122027 episode_21122027_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122027 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122028 episode_21122028_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122028 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122029 episode_21122029_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122029 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122030 episode_21122030_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122030 getdbh=1
bucardo -h db -U bucardo add customcode episode_21122031 episode_21122031_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_21122031 getdbh=1
bucardo -h db -U bucardo add customcode episode_others   episode_others_filter_only_us_rec   whenrun=before_sync src_code=customcode.filter.us.pl relation=episode_others   getdbh=1

bucardo -h db -U bucardo add customcode patient_visit_21122008 patient_visit_21122008_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122008 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122009 patient_visit_21122009_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122009 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122010 patient_visit_21122010_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122010 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122011 patient_visit_21122011_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122011 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122012 patient_visit_21122012_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122012 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122013 patient_visit_21122013_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122013 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122014 patient_visit_21122014_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122014 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122015 patient_visit_21122015_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122015 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122016 patient_visit_21122016_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122016 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122017 patient_visit_21122017_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122017 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122018 patient_visit_21122018_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122018 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122019 patient_visit_21122019_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122019 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122020 patient_visit_21122020_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122020 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122021 patient_visit_21122021_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122021 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122022 patient_visit_21122022_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122022 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122023 patient_visit_21122023_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122023 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122024 patient_visit_21122024_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122024 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122025 patient_visit_21122025_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122025 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122026 patient_visit_21122026_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122026 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122027 patient_visit_21122027_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122027 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122028 patient_visit_21122028_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122028 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122029 patient_visit_21122029_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122029 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122030 patient_visit_21122030_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122030 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_21122031 patient_visit_21122031_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_21122031 getdbh=1
bucardo -h db -U bucardo add customcode patient_visit_others   patient_visit_others_filter_only_us_rec   whenrun=before_sync src_code=customcode.filter.us.pl relation=patient_visit_others getdbh=1

bucardo -h db -U bucardo add customcode prescription_21122008 prescription_21122008_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122008 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122009 prescription_21122009_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122009 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122010 prescription_21122010_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122010 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122011 prescription_21122011_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122011 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122012 prescription_21122012_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122012 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122013 prescription_21122013_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122013 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122014 prescription_21122014_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122014 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122015 prescription_21122015_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122015 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122016 prescription_21122016_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122016 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122017 prescription_21122017_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122017 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122018 prescription_21122018_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122018 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122019 prescription_21122019_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122019 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122020 prescription_21122020_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122020 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122021 prescription_21122021_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122021 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122022 prescription_21122022_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122022 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122023 prescription_21122023_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122023 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122024 prescription_21122024_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122024 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122025 prescription_21122025_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122025 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122026 prescription_21122026_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122026 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122027 prescription_21122027_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122027 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122028 prescription_21122028_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122028 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122029 prescription_21122029_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122029 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122030 prescription_21122030_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122030 getdbh=1
bucardo -h db -U bucardo add customcode prescription_21122031 prescription_21122031_filter_only_us_rec whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_21122031 getdbh=1
bucardo -h db -U bucardo add customcode prescription_others   prescription_others_filter_only_us_rec   whenrun=before_sync src_code=customcode.filter.us.pl relation=prescription_others getdbh=1
