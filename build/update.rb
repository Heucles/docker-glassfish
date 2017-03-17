#!/usr/bin/env ruby

require 'rubygems'

require 'fileutils'
require 'cgi'

BASE_DIR = File.expand_path(File.dirname(__FILE__) + '/..')
DOCKERFILE = "#{BASE_DIR}/Dockerfile"

JAVA_7_VERSION='7'
JAVA_8_VERSION='8'
PAYARA_162='4.1.1.162'
PAYARA_164='4.1.1.164'
PAYARA_171='4.1.1.171'
PAYARA_URLS ={
  PAYARA_162 => 'https://s3-eu-west-1.amazonaws.com/payara.co/Payara+Downloads/Payara+4.1.1.162/payara-4.1.1.162.zip',
  PAYARA_164 => 'https://s3-eu-west-1.amazonaws.com/payara.fish/Payara+Downloads/Payara+4.1.1.164/payara-4.1.1.164.zip',
  PAYARA_171 => 'https://s3-eu-west-1.amazonaws.com/payara.fish/Payara+Downloads/Payara+4.1.1.171.0.1/payara-4.1.1.171.0.1.zip'
}

VARIANTS = []
VARIANTS << {:java => JAVA_7_VERSION, :payara => PAYARA_162}
VARIANTS << {:java => JAVA_8_VERSION, :payara => PAYARA_162}
VARIANTS << {:java => JAVA_7_VERSION, :payara => PAYARA_164}
VARIANTS << {:java => JAVA_8_VERSION, :payara => PAYARA_164}
VARIANTS << {:java => JAVA_8_VERSION, :payara => PAYARA_171}

LATEST_VARIANT = VARIANTS[4]

def sh(command)
  system(command) || (raise "Error executing #{command} in #{Dir.pwd}")
end

def to_tag(variant)
  java_version = variant[:java]
  payara_version = variant[:payara]
  "java-#{java_version}_payara-#{payara_version}"
end

CWD=Dir.pwd

FileUtils.cd BASE_DIR

def update_variant(variant)
  java_version = variant[:java]

  payara_version = variant[:payara]

  File.open(DOCKERFILE, 'wb') do |f|
    f.write <<FILE
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
FROM stocksoftware/java:jdk#{java_version}

ENV GLASSFISH_HOME=/opt/glassfish \\
    GLASSFISH_DOMAINS_DIR=/srv/glassfish/domains \\
    IMQ_HOME=/opt/glassfish/mq \\
    IMQ_VARHOME=/srv/openmq \\
    IMQ_JAVAHOME=${JAVA_HOME}

RUN adduser -D -H -s /bin/bash -h /srv/glassfish -S glassfish && \\
    addgroup -S glassfish && \\
    curl -jksSL #{PAYARA_URLS[payara_version]} > /tmp/payara.zip && \\
    unzip -o -q /tmp/payara.zip -d /tmp && \\
    mv /tmp/payara41 ${GLASSFISH_HOME} && \\
    rm /tmp/payara.zip && \\
    mkdir -p ${GLASSFISH_DOMAINS_DIR} ${IMQ_VARHOME} && \\
    chmod a-w ${GLASSFISH_HOME} && \\
    chown -R glassfish:glassfish /srv/glassfish /srv/openmq && \\
    rm -rf ${GLASSFISH_HOME}/glassfish/domains \\
    ${GLASSFISH_HOME}/glassfish/bin/appclient \\
    ${GLASSFISH_HOME}/glassfish/bin/capture-schema \\
    ${GLASSFISH_HOME}/glassfish/bin/package-appclient \\
    ${GLASSFISH_HOME}/glassfish/bin/startserv \\
    ${GLASSFISH_HOME}/glassfish/bin/wscompile \\
    ${GLASSFISH_HOME}/glassfish/bin/wsgen \\
    ${GLASSFISH_HOME}/glassfish/bin/xjc \\
    ${GLASSFISH_HOME}/glassfish/bin/jspc \\
    ${GLASSFISH_HOME}/glassfish/bin/schemagen \\
    ${GLASSFISH_HOME}/glassfish/bin/stopserv \\
    ${GLASSFISH_HOME}/glassfish/bin/wsdeploy \\
    ${GLASSFISH_HOME}/glassfish/bin/wsimport \\
    ${GLASSFISH_HOME}/glassfish/lib/nadmin \\
    ${GLASSFISH_HOME}/glassfish/lib/nadmin.bat \\
    ${GLASSFISH_HOME}/glassfish/lib/package-appclient.xml \\
    ${GLASSFISH_HOME}/glassfish/lib/install/databases \\
    ${GLASSFISH_HOME}/glassfish/lib/install/templates \\
    ${GLASSFISH_HOME}/glassfish/lib/registration \\
    ${GLASSFISH_HOME}/glassfish/domains/payaradomain \\
    ${GLASSFISH_HOME}/glassfish/modules/console-updatecenter-plugin.jar \\
    ${GLASSFISH_HOME}/glassfish/modules/phonehome-bootstrap.jar \\
    ${GLASSFISH_HOME}/glassfish/modules/payara-micro-cdi.jar \\
    ${GLASSFISH_HOME}/glassfish/lib/asadmin/cli-optional.jar \\
    ${GLASSFISH_HOME}/README.txt \\
    ${GLASSFISH_HOME}/bin \\
    ${GLASSFISH_HOME}/glassfish/bin/*.bat \\
    ${GLASSFISH_HOME}/glassfish/bin/*.js \\
    ${GLASSFISH_HOME}/glassfish/config/asenv.bat \\
    ${GLASSFISH_HOME}/glassfish/legal \\
    ${GLASSFISH_HOME}/javadb \\
    ${GLASSFISH_HOME}/mq/etc \\
    ${GLASSFISH_HOME}/mq/bin/*.exe \\
    ${GLASSFISH_HOME}/mq/lib/etc/README \\
    ${GLASSFISH_HOME}/mq/lib/install \\
    ${GLASSFISH_HOME}/mq/lib/props/broker/install.properties \\
    ${GLASSFISH_HOME}/mq/lib/help \\
    ${GLASSFISH_HOME}/mq/lib/images && \\
    touch ${GLASSFISH_HOME}/mq/lib/props/broker/install.properties && \\
    sed -i  's/^"$imq_javahome\\/bin\\/java" /"$imq_javahome\\/bin\\/java" -XX:+PerfDisableSharedMem /' /opt/glassfish/mq/bin/imq*

COPY asadmin /opt/glassfish/glassfish/bin/asadmin
COPY asenv.conf /opt/glassfish/glassfish/config/asaenv.conf
COPY imqenv.conf /opt/glassfish/mq/etc/imqenv.conf
COPY imqinit /opt/glassfish/mq/lib/imqinit

RUN chmod a+x /opt/glassfish/glassfish/bin/asadmin

USER glassfish:glassfish

ENV PATH ${PATH}:${GLASSFISH_HOME}/glassfish/bin:${GLASSFISH_HOME}/mq/bin
FILE
  end

  if `git status -s | grep Dockerfile`.chomp.size > 0
    sh("git add Dockerfile && git commit -m 'Update to the latest structure'")
  end
end

def describe_tag(tag, variant, branch = nil)
  "* **#{tag}**: Java: #{variant[:java]}, Payara: #{variant[:payara]} [![Build Status](https://secure.travis-ci.org/stocksoftware/docker-glassfish.png?branch=#{CGI.escape(branch || tag)})](http://travis-ci.org/stocksoftware/docker-glassfish)\n"
end

begin
  sh('git checkout master')

  content = IO.read('README.md')

  tags = <<TAGS
## Tags

TAGS
  tags << describe_tag('latest', LATEST_VARIANT, 'master')
  VARIANTS.each do |variant|
    tags << describe_tag(to_tag(variant), variant)
  end
  tags += <<TAGS

## Usage
TAGS

  content.gsub!(/\#\# Tags.*\#\# Usage\n/m, tags)

  File.open('README.md', 'wb') do |f|
    f.write content
  end

  if `git status -s | grep README.md`.chomp.size > 0
    sh("git add README.md && git commit -m 'Update README'")
  end

  VARIANTS.each do |variant|
    tag = to_tag(variant)
    puts "Updating branch #{tag}"

    # ignore failure
    sh("git branch #{tag} 2>/dev/null") rescue nil

    sh("git checkout #{tag}")
    sh('git merge --no-edit -X theirs master')

    update_variant(variant)
  end

  sh('git checkout master')

  puts 'Updating master'
  update_variant(LATEST_VARIANT)

ensure
  FileUtils.cd CWD
end
