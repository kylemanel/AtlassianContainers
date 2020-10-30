#~/bin/sh

# SCRIPT ENVIRONMENT:
CONTAINER_NAME=postgres
CONTAINER_USER=postgres
PGPASSWD=zhnGDsfpbNUnQNVI
DB_ADMIN_NAME=postgres
DB_NAME=testjiradb
DB_USER=testjiradbuser
DB_USER_PW='J5OzzjqT8gDWx5J1'
DB_PASSWORD=zhnGDsfpbNUnQNVI

# COMMANDS:

# Create user with password;

	docker exec -e PGPASSWORD=$PGPASSWD -u $CONTAINER_USER $CONTAINER_NAME psql -U $DB_ADMIN_NAME -c \
	"CREATE USER $DB_USER WITH PASSWORD $DB_USER_PW;"
# Create database with specifications
	docker exec -e PGPASSWORD=$PGPASSWD -u $CONTAINER_USER $CONTAINER_NAME psql -U $DB_ADMIN_NAME -c \
	"CREATE DATABASE testconfdb WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;"
# Grant all privileges on a database to a user
	docker exec -e PGPASSWORD=$PGPASSWD -u $CONTAINER_USER $CONTAINER_NAME psql -U $DB_ADMIN_NAME -c \
	"GRANT ALL ON DATABASE testconfdb TO testjiradbuser;"
# Alter a database's name;
	docker exec -e PGPASSWORD=$PGPASSWD -u $CONTAINER_USER $CONTAINER_NAME psql -U $DB_ADMIN_NAME -c \
	"ALTER DATABASE testconfdb RENAME TO $NEW_DB_NAME"
# Alter a database's owner;
	docker exec -e PGPASSWORD=$PGPASSWD -u $CONTAINER_USER $CONTAINER_NAME psql -U $DB_ADMIN_NAME -c \
	"ALTER DATABASE testconfb OWNER TO $ROLE"

# docker exec -e PGPASSWORD=zhnGDsfpbNUnQNVI -u postgres postgres psql -U postgres -c "CREATE USER testconfdbuser WITH PASSWORD 'J5OzzjqT8gDWx5J1';"
# docker exec -e PGPASSWORD=zhnGDsfpbNUnQNVI -u postgres postgres psql -U postgres -c "CREATE DATABASE testconfdb WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;"
# docker exec -e PGPASSWORD=zhnGDsfpbNUnQNVI -u postgres postgres psql -U postgres -c "GRANT ALL ON DATABASE testconfdb TO testconfdbuser;"
# docker exec -e PGPASSWORD=zhnGDsfpbNUnQNVI -u postgres postgres psql -U postgres -c "ALTER DATABASE testconfdb RENAME TO $NEW_DB_NAME"
# docker exec -e PGPASSWORD=zhnGDsfpbNUnQNVI -u postgres postgres psql -U postgres -c "ALTER DATABASE testconfb OWNER TO $ROLE"
