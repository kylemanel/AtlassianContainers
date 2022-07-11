#!/bin/sh
set -x
NAME="jira"
    DOCKER_DIRECTORY=/opt/docker/$NAME
FROM=7.12.3
VERSION=8.0.1
PORTS=" -p 8198:8080"
RUN_OPTIONS=" -d --restart=always"
VENDOR="company_name"
USER=" --user 8080:8080"
    USER_INFO=" /etc/passwd:/etc/passwd:ro"
    DOCKER_FILE=" -f $DOCKER_DIRECTORY/Dockerfiles/$NAME/Dockerfilev$VERSION"
DOCKER_VERSION=$VERSION.1
    ENV_FILE=" --env-file=$DOCKER_DIRECTORY/$NAME.env"
IMAGE=" ${VENDOR}/$NAME"
    INSTALL_DIR="/opt/atlassian/atlassian-$NAME-$VERSION"
    OLD_INSTALL_DIR="/opt/atlassian/atlassian-$NAME-$FROM"
    NAME_PROMPT=" --name $NAME-$VERSION-test"
    DATA_DIR=" /opt/docker/var/volumes/$NAME/test:/var/atlassian/$NAME"
    LOGS_DIR=" /opt/docker/var/volumes/$NAME/log:/opt/atlassian/atlassian-$NAME-$VERSION/logs"
	SERVER_XML=" /opt/docker/var/volumes/$NAME/config/server.xml:$INSTALLATION_DIR/conf/server.xml"
DOCKER_REFERENCE=" $IMAGE:$DOCKER_VERSION"
VOLUMES=" -v $USER_INFO -v $DATA_DIR" #"-v $LOGS_DIR"
TAG=" -t $DOCKER_REFERENCE"
# TO REMOVE OUT-OF-DATE DOCKER containers //ANTIQUATED
# ~ as the build sequence draws docker configurations from previous server, and the name pulls version, a new docker container won't have the same 'name'
#old=`docker ps -a --filter "name=$NAME" --filter "status=exited" --format "{{.ID}}"`
#if [ -n "$old" ]; then
#  docker rm $old
#fi
# Pull the previous server's server.xml file and retain it in /opt/docker/conf/$NAME-$VERSION-server.xml
#docker cp $NAME-$FROM:$OLD_INSTALL_DIR/conf/server.xml /opt/docker/conf/$NAME-$VERSION-server.xml
# docker cp $NAME-$FROM:$INSTALLATION_DIR/conf/server.xml /opt/docker/$NAME/server.xml
docker cp $NAME-$FROM:$INSTALL_DIR/conf/server.xml /opt/docker/conf/$NAME-$FROM-server.xml
docker build \
            $DOCKER_FILE \
            $TAG .
docker run \
            $RUN_OPTIONS \
            $NAME_PROMPT \
            $ENV_FILE \
            $USER \
            $VOLUMES \
            $PORTS \
            $TAG
# Removed $VOLUMES between USER and PORTS below during testing
