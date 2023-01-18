#FROM openjdk:8-alpine
#FROM Your source for Alpine Docker images necessary here
MAINTAINER Kyle Manel <kyletmanel@gmail.com>
LABEL Description="This image is used to start Atlassian JIRA" \
    Developer="kylemanel" \
    Vendor="Atlassian" \
    Version="${JIRA_VERSION}"

ENV DOMAIN            example_domain
#Application selection:
ENV APP               jira

#JIRA variables:
ENV JIRA_VERSION      7.12.3
ENV JIRA_ID           8080
ENV JIRA_HOME         /var/atlassian/"${APP}"
ENV JIRA_INSTALL      /opt/atlassian/atlassian-"${APP}"-"${JIRA_VERSION}"
ENV JIRA_URL          "${APP}".corp.${DOMAIN}.com
ENV JIRA_PACKAGE      atlassian-"${APP}"-core-"${JIRA_VERSION}".tar.gz
ENV JIRA_DOWNLOAD_URL https://www.atlassian.com/software/"${APP}"/downloads/binary/"${JIRA_PACKAGE}"

ENV APP_VERSION       "${JIRA_VERSION}"
ENV APP_ID            "${JIRA_ID}"
ENV APP_URL           "${JIRA_URL}"
ENV APP_HOME          "${JIRA_HOME}"
ENV APP_INSTALL       "${JIRA_INSTALL}"
ENV APP_PACKAGE       "${JIRA_PACKAGE}"
ENV APP_DOWNLOAD_URL  "${JIRA_DOWNLOAD_URL}"

#Environment modifications:
ENV MIN_RAM           1g
ENV MAX_RAM           4g
ENV ENV_FILE          "${APP_INSTALL}"/bin/setenv.sh

#Requirement downloads:
ENV PSQL_VERSION             42.0.0
ENV PSQL_PACKAGE             postgresql-"${PSQL_VERSION}".jar
ENV PSQL_DRIVER_DOWNLOAD_URL https://jdbc.postgresql.org/download/"${PSQL_PACKAGE}"

#Operating user and group:
ENV RUN_USER        "${APP}"
ENV RUN_GROUP       "${APP}"
ENV RUN_ID          "${APP_ID}"

# Install Atlassian Jira and helper tools and setup initial home

################################################################
################################################################
################################################################
################################################################
RUN set -x

# Install Atlassian JIRA, requirements, helper tools and setup initial home:

# Environment Deployment & Configuration:
RUN mkdir -p                    ${APP_HOME}/caches/indexes ${APP_INSTALL}/conf/Catalina
RUN apk add                     --no-cache openssl openssl-dev apr apr-util apr-dev xmlstarlet
RUN apk add                     --no-cache --virtual=build-dependencies build-base wget ca-certificates
RUN update-ca-certificates

# User Configuration:
RUN addgroup -g                 "${RUN_ID}" -S "${RUN_GROUP}"
RUN adduser -u                  "${RUN_ID}" -G "${RUN_GROUP}" -S "${RUN_USER}"
RUN chmod -R 700                "${APP_HOME}"

# Download and install JIRA:
RUN wget                        "${APP_DOWNLOAD_URL}" -P /tmp
RUN tar -xzf                    /tmp/"${APP_PACKAGE}" --strip-components=1 -C "${JIRA_INSTALL}"
RUN wget -t 2                   -P "${APP_INSTALL}"/lib/ "${PSQL_DRIVER_DOWNLOAD_URL}"
RUN chown -R                    "${APP}":"${APP}"  "${APP_INSTALL}" "${APP_HOME}"

# JIRA_HOME Configuration:
RUN echo -e                     "\njira.home=${APP_HOME}" >> ${APP_INSTALL}/atlassian-${APP}/WEB-INF/classes/${APP}-application.properties

# Configuration file instantiation:
RUN touch -d "@0"               "${APP_INSTALL}/conf/server.xml"

# Tomcat installation:
RUN cd                          "${APP_INSTALL}/bin" && tar -zxvf tomcat-native.tar.gz
RUN cd                          "${APP_INSTALL}/bin/tomcat-native-1.2.17-src/native" && ./configure --with-apr=/usr --with-java-home=$JAVA_HOME
RUN cd                          "${APP_INSTALL}/bin/tomcat-native-1.2.17-src/native" && make && make install

# Memory configuration:
RUN sed -i 's/JVM_MINIMUM_MEMORY=.*/JVM_MINIMUM_MEMORY=4g/' "${APP_INSTALL}"/bin/setenv.sh
RUN sed -i 's/JVM_MAXIMUM_MEMORY=.*/JVM_MAXIMUM_MEMORY=8g/' "${APP_INSTALL}"/bin/setenv.sh

# Certificate installation:
RUN cd /tmp && echo "yes" |     openssl s_client -connect jira.corp.${DOMAIN}.com:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/public.crt && keytool -import -noprompt -alias jira.corp.${DOMAIN}.com -keystore /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts -storepass changeit -file /tmp/public.crt

# Permission resolution:
RUN chown -R                    "${APP}":"${APP}" "${APP_HOME}" "${APP_INSTALL}"

# Cleanup:
RUN apk del                     build-dependencies build-base wget
RUN rm -r                       /tmp/"${APP_PACKAGE}"

################################################################
################################################################
################################################################
################################################################

# Use the jira user
USER jira

# Expose default HTTP connector port
EXPOSE 8080

# Persist both the home and logs directories
VOLUME ["${APP_HOME}", "${APP_INSTALL}/logs"]

# Set the default working directory as the installation directory.
WORKDIR "${JIRA_INSTALL}"

# Copy & set entrypoint for manual access
COPY ./docker-entrypoint.sh /
#RUN chown ${RUN_USER}:${RUN_GROUP} /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian JIRA as a foreground process by default
CMD ["/opt/atlassian/atlassian-jira-7.12.3/bin/catalina.sh", "run"]
