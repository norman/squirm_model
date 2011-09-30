SELECT p.proname as "name",
  pg_catalog.pg_get_function_result(p.oid) as "return_type",
  pg_catalog.pg_get_function_arguments(p.oid) as "arguments",
 CASE
  WHEN p.proisagg THEN 'agg'
  WHEN p.proiswindow THEN 'window'
  WHEN p.prorettype = 'pg_catalog.trigger'::pg_catalog.regtype THEN 'trigger'
  ELSE 'normal'
END as "procedure_type"
FROM pg_catalog.pg_proc p
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname = $1::text
  AND n.nspname = $2::text
LIMIT 1