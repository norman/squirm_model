SELECT
  a.attname    "name",
  a.attnum     "number",
  t.typname    "type",
  a.attlen     "length",
  a.attnotnull "not_null",
  a.atthasdef  "has_default",
  a.attndims   "array_dimensions"

FROM pg_class  AS c,
  pg_attribute AS a,
  pg_type      AS t,
  pg_namespace AS n

WHERE a.attnum > 0
  AND a.attrelid = c.oid
  AND c.relname = $1::text
  AND c.relnamespace = n.oid
  AND n.nspname = $2::text
  AND a.atttypid = t.oid
  AND a.attisdropped = 'f'

ORDER BY a.attnum
