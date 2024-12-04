do $$
declare
  	clinicRecord RECORD;
BEGIN
	SELECT
	 	LOWER(REPLACE(c.id, '-','')) as clinic_id,
		ps.url_path as host,
		ps.port, ps.username
    ps.dbname as dbname,
	INTO clinicRecord
	FROM clinic c
	INNER JOIN province p on p.id = c.province_id
	INNER JOIN provincial_server ps on ps.code = p.code
	WHERE ps.destination = 'DB'
	AND c.main_clinic = true;

   	IF EXISTS (SELECT 1
   	           FROM pg_subscription
   	           WHERE subname ilike 'sub_'||clinicRecord.clinic_id) THEN
   		  EXECUTE 'ALTER SUBSCRIPTION sub_'||clinicRecord.clinic_id||' DISABLE';
		  EXECUTE 'ALTER SUBSCRIPTION sub_'||clinicRecord.clinic_id||' SET (slot_name=NONE)';
          EXECUTE 'DROP SUBSCRIPTION sub_'||clinicRecord.clinic_id||' CASCADE';
    END IF;
    	EXECUTE 'CREATE SUBSCRIPTION sub_'||clinicRecord.clinic_id||' CONNECTION ''host='||clinicRecord.host||' port='||clinicRecord.port||' user='||clinicRecord.username||' dbname='||clinicRecord.dbname||' sslmode=allow '' PUBLICATION pub_'||clinicRecord.clinic_id ||' WITH (create_slot = false, copy_data = true)';

	EXECUTE 'ALTER SUBSCRIPTION sub_'||clinicRecord.clinic_id||' SET (slot_name = '''||clinicRecord.clinic_id||'_slot'')';
	EXECUTE 'ALTER SUBSCRIPTION sub_'||clinicRecord.clinic_id||' ENABLE';
end;
$$;
