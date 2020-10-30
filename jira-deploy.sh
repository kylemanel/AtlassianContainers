#!/bin/sh
set -x

NAME="jira"
DOCKER_DIRECTORY=/opt/docker/$NAME

FROM=7.12.3
VERSION=8.0.1
PORTS=" -p 8080:8080"
RUN_OPTIONS=" -d --restart=always"
USER=" --user 8080:8080"
    USER_INFO="/etc/passwd:/etc/passwd:ro"

DOCKER_FILE=" -f $DOCKER_DIRECTORY/Dockerfiles/$NAME/Dockerfilev$VERSION"
DOCKER_VERSION=$VERSION.1
ENV_FILE=" --env-file=$DOCKER_DIRECTORY/$NAME.env"
IMAGE=" inbaytech/$NAME"
INSTALLATION_DIR="/opt/atlassian/atlassian-$NAME-$VERSION"
NAME_PROMPT=" --name $NAME-$VERSION"
    DATA_DIR="/opt/docker/var/volumes/$NAME/data:/var/atlassian/$NAME"
    LOGS_DIR="/opt/docker/var/volumes/$NAME/log:$INSTALLATION_DIR/logs"
	SERVER_XML="/opt/docker/var/volumes/$NAME/config/server.xml:$INSTALLATION_DIR/conf/server.xml"

DOCKER_REFERENCE=" $IMAGE:$DOCKER_VERSION"
VOLUMES=" -v $USER_INFO -v $DATA_DIR -v $LOGS_DIR"

TAG=" -t $DOCKER_REFERENCE"

#old=`docker ps -a --filter "name=$NAME" --filter "status=exited" --format "{{.ID}}"`
#if [ -n "$old" ]; then
#  docker rm $old
#fi

docker cp $NAME-$FROM:$INSTALLATION_DIR/conf/server.xml /opt/docker/conf/$NAME-$VERSION-server.xml
docker build $DOCKER_FILE $TAG .
docker cp /opt/docker/conf/$NAME-$FROM-server.xml $NAME-$VERSION:$INSTALLATION_DIR/conf/server.xml

docker run \
            $RUN_OPTIONS \
            $NAME_PROMPT \
            $ENV_FILE \
            $USER \
            $VOLUMES \
            $PORTS \
            $TAG

# docker build  -f /opt/docker/jira/Dockerfiles/jira/Dockerfilev7.12.1
# docker run  -d --restart=always  --name jira-7.12.1  --env-file=$DOCKER_DIRECTORY/$NAME.env jira  -p 8080:8080  -t $DOCKER_REFERENCE