
DO $$
DECLARE
l_schema_name TEXT := 'public';
rec record;

BEGIN
for rec IN
(
SELECT rel.relname as table_name
       FROM pg_catalog.pg_class rel
            INNER JOIN pg_catalog.pg_namespace nsp
                       ON nsp.oid = rel.relnamespace
       WHERE nsp.nspname = l_schema_name AND rel.relhastriggers = true
	   ORDER BY 1
)
  LOOP
       EXECUTE format ('ALTER TABLE %I
                        ENABLE TRIGGER ALL',rec.table_name);
  END LOOP;
END $$;
