PG_PASSWORD="bogus_password"
USER_PW="another_bogus_password"

docker exec -e PGPASSWORD="${PG_PASSWORD}" -u postgres postgres psql -U postgres -c "CREATE USER jira WITH PASSWORD '$USER_PW';"
docker exec -e PGPASSWORD="${PG_PASSWORD}" -u postgres postgres psql -U postgres -c "CREATE DATABASE jiradb WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;"
