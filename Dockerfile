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
    IMQ_HOME=/opt/glassfish/mq \
    IMQ_VARHOME=/srv/openmq \
    IMQ_JAVAHOME=${JAVA_HOME}

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
    mkdir -p ${GLASSFISH_DOMAINS_DIR} ${IMQ_VARHOME} && \
    chmod a-w ${GLASSFISH_HOME} && \
    chown -R glassfish:glassfish /srv/glassfish /srv/openmq && \
    rm -rf ${GLASSFISH_HOME}/glassfish/domains \
    ${GLASSFISH_HOME}/glassfish/bin/appclient \
    ${GLASSFISH_HOME}/glassfish/bin/capture-schema \
    ${GLASSFISH_HOME}/glassfish/bin/package-appclient \
    ${GLASSFISH_HOME}/glassfish/bin/startserv \
    ${GLASSFISH_HOME}/glassfish/bin/wscompile \
    ${GLASSFISH_HOME}/glassfish/bin/wsgen \
    ${GLASSFISH_HOME}/glassfish/bin/xjc \
    ${GLASSFISH_HOME}/glassfish/bin/jspc \
    ${GLASSFISH_HOME}/glassfish/bin/schemagen \
    ${GLASSFISH_HOME}/glassfish/bin/stopserv \
    ${GLASSFISH_HOME}/glassfish/bin/wsdeploy \
    ${GLASSFISH_HOME}/glassfish/bin/wsimport \
    ${GLASSFISH_HOME}/glassfish/lib/nadmin \
    ${GLASSFISH_HOME}/glassfish/lib/nadmin.bat \
    ${GLASSFISH_HOME}/glassfish/domains/payaradomain \
    ${GLASSFISH_HOME}/glassfish/modules/console-updatecenter-plugin.jar \
    ${GLASSFISH_HOME}/glassfish/modules/phonehome-bootstrap.jar \
    ${GLASSFISH_HOME}/README.txt \
    ${GLASSFISH_HOME}/bin \
    ${GLASSFISH_HOME}/glassfish/bin/*.bat \
    ${GLASSFISH_HOME}/glassfish/bin/*.js \
    ${GLASSFISH_HOME}/glassfish/config/asenv.bat \
    ${GLASSFISH_HOME}/glassfish/legal \
    ${GLASSFISH_HOME}/javadb \
    ${GLASSFISH_HOME}/mq/etc \
    ${GLASSFISH_HOME}/mq/bin/*.exe \
    ${GLASSFISH_HOME}/mq/lib/help \
    ${GLASSFISH_HOME}/mq/lib/images

USER glassfish:glassfish

COPY asenv.conf /opt/glassfish/glassfish/config/asaenv.conf
ENV PATH ${PATH}:${GLASSFISH_HOME}/glassfish/bin:${GLASSFISH_HOME}/mq/bin
