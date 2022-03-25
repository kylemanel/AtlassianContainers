PG_PASSWORD="t818_880u10_63_R3910c30
APP_PW="bogus_password"

docker exec -e PGPASSWORD="${PG_PASSWORD}" -u postgres postgres psql -U postgres -c "CREATE USER jira WITH PASSWORD 't81515n756F3';"
docker exec -e PGPASSWORD="${PG_PASSWORD}" -u postgres postgres psql -U postgres -c "CREATE DATABASE jiradb WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;"
