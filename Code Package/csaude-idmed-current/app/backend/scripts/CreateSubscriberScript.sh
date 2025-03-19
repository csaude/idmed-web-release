PGPASSWORD=$POSTGRES_PASSWORD psql --username $POSTGRES_USER --host "db" --port $POSTGRES_PORT --dbname $POSTGRES_DB -c "
do \$\$
declare
	clinicRecord RECORD;
	target_db_host TEXT := '$TARGET_DB_HOST';
	target_db_port TEXT := '$TARGET_DB_PORT';
	target_db_user TEXT := '$TARGET_DB_USER';
	target_db_name TEXT := '$TARGET_DB_NAME';
	target_db_pass TEXT := '$TARGET_DB_PASS';
BEGIN
	SELECT
	 	LOWER(REPLACE(c.id, '-','')) as clinic_id
	INTO clinicRecord
	FROM clinic c
	WHERE c.main_clinic = true;

   	IF EXISTS (SELECT 1
   	           FROM pg_subscription
   	           WHERE subname ilike 'sub_'||clinicRecord.clinic_id) THEN
   		  EXECUTE 'ALTER SUBSCRIPTION sub_'||clinicRecord.clinic_id||' DISABLE';
		  EXECUTE 'ALTER SUBSCRIPTION sub_'||clinicRecord.clinic_id||' SET (slot_name=NONE)';
          	  EXECUTE 'DROP SUBSCRIPTION sub_'||clinicRecord.clinic_id||' CASCADE';
    END IF;
    	EXECUTE 'CREATE SUBSCRIPTION sub_'||clinicRecord.clinic_id||' CONNECTION ''host='||target_db_host||' port='||target_db_port||' user='||target_db_user||' password='||target_db_pass ||' dbname='||target_db_name||' sslmode=allow '' PUBLICATION pub_'||clinicRecord.clinic_id ||' WITH (create_slot = false, copy_data = false)';

	EXECUTE 'ALTER SUBSCRIPTION sub_'||clinicRecord.clinic_id||' SET (slot_name = '''||clinicRecord.clinic_id||'_slot'')';
	EXECUTE 'ALTER SUBSCRIPTION sub_'||clinicRecord.clinic_id||' ENABLE';
end;
\$\$;
"
echo === Master created subscription successfully ===

