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
FROM stocksoftware/ruby
MAINTAINER Stock Software

ENV GLASSFISH_BASE_DIR=/opt/glassfish \
    GLASSFISH_DOMAINS_DIR=/srv/glassfish/domains \
    OPENMQ_INSTANCES_DIR=/srv/openmq/instances

RUN adduser -D -H -s /bin/bash -h /srv/glassfish -S glassfish && \
    addgroup -S glassfish && \
    curl -jksSL https://s3-eu-west-1.amazonaws.com/payara.co/Payara+Downloads/payara-4.1.152.1.zip > /tmp/payara-4.1.152.1.zip && \
    unzip -o -q /tmp/payara-4.1.152.1.zip -d /opt && \
    mv /opt/payara41 ${GLASSFISH_BASE_DIR} && \
    rm /tmp/payara-4.1.152.1.zip && \
    mkdir -p ${GLASSFISH_DOMAINS_DIR} ${OPENMQ_INSTANCES_DIR} && \
    chown -R glassfish:glassfish /srv/glassfish /srv/openmq && \
    rm -rf ${GLASSFISH_BASE_DIR}/glassfish/domains/domain1 \
    ${GLASSFISH_BASE_DIR}/glassfish/domains/payaradomain \
    ${GLASSFISH_BASE_DIR}/glassfish/modules/console-updatecenter-plugin.jar \
    ${GLASSFISH_BASE_DIR}/glassfish/modules/phonehome-bootstrap.jar \
    ${GLASSFISH_BASE_DIR}/README.txt \
    ${GLASSFISH_BASE_DIR}/bin \
    ${GLASSFISH_BASE_DIR}/glassfish/bin/*.bat \
    ${GLASSFISH_BASE_DIR}/glassfish/bin/*.js \
    ${GLASSFISH_BASE_DIR}/glassfish/config/asenv.bat \
    ${GLASSFISH_BASE_DIR}/glassfish/legal \
    ${GLASSFISH_BASE_DIR}/mq/bin/*.exe \
    ${GLASSFISH_BASE_DIR}/mq/lib/help \
    ${GLASSFISH_BASE_DIR}/mq/lib/images

# Should also delete ${GLASSFISH_BASE_DIR}/javadb but can't until timer database is configured to point at a real database

USER glassfish:glassfish

ENV PATH ${PATH}:${GLASSFISH_BASE_DIR}/glassfish/bin:${GLASSFISH_BASE_DIR}/mq/bin
