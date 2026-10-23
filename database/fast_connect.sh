source config.sh

PGPASSWORD=$PGPASSWORD \
  psql \
  -h $DB_HOST \
  -U $DB_USER \
  -d $DB_NAME