#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM anapsix/alpine-java:jdk7
MAINTAINER Stock Software


ENV GLASSFISH_HOME=/opt/glassfish \
    GLASSFISH_DOMAINS_DIR=/srv/glassfish/domains \
    OPENMQ_INSTANCES_DIR=/srv/openmq/instances

RUN apk update && \
    apk upgrade && \
    apk add bash curl ca-certificates && \
    rm -rf /var/cache/apk/* && \
    adduser -D -H -s /bin/bash -h /srv/glassfish -S glassfish && \
    addgroup -S glassfish && \
    curl -jksSL https://s3-eu-west-1.amazonaws.com/payara.co/Payara+Downloads/Payara+4.1.1.162/payara-4.1.1.162.zip > /tmp/payara-4.1.1.162.zip && \
    unzip -o -q /tmp/payara-4.1.1.162.zip -d /opt && \
    mv /opt/payara41 ${GLASSFISH_HOME} && \
    rm /tmp/payara-4.1.1.162.zip && \
    mkdir -p ${GLASSFISH_DOMAINS_DIR} ${OPENMQ_INSTANCES_DIR} && \
    chmod a-w ${GLASSFISH_HOME} && \
    chown -R glassfish:glassfish /srv/glassfish /srv/openmq && \
    rm -rf ${GLASSFISH_HOME}/glassfish/domains/domain1 \
    ${GLASSFISH_HOME}/glassfish/domains/payaradomain \
    ${GLASSFISH_HOME}/glassfish/modules/console-updatecenter-plugin.jar \
    ${GLASSFISH_HOME}/glassfish/modules/phonehome-bootstrap.jar \
    ${GLASSFISH_HOME}/README.txt \
    ${GLASSFISH_HOME}/bin \
    ${GLASSFISH_HOME}/glassfish/bin/*.bat \
    ${GLASSFISH_HOME}/glassfish/bin/*.js \
    ${GLASSFISH_HOME}/glassfish/config/asenv.bat \
    ${GLASSFISH_HOME}/glassfish/legal \
    ${GLASSFISH_HOME}/mq/etc/rc \
    ${GLASSFISH_HOME}/mq/etc/registry \
    ${GLASSFISH_HOME}/mq/etc/xml \
    ${GLASSFISH_HOME}/mq/etc/etc \
    ${GLASSFISH_HOME}/mq/etc/passfile.sample \
    ${GLASSFISH_HOME}/mq/bin/*.exe \
    ${GLASSFISH_HOME}/mq/lib/help \
    ${GLASSFISH_HOME}/mq/lib/images

# Should also delete ${GLASSFISH_HOME}/javadb but can't until timer database is configured to point at a real database

USER glassfish:glassfish

ENV PATH ${PATH}:${GLASSFISH_HOME}/glassfish/bin:${GLASSFISH_HOME}/mq/bin
