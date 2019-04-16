FROM openjdk:8-jdk-alpine

#######################################################################
# Installing additional packages
#######################################################################

RUN apk add --no-cache \
    git curl jq unzip bash ttf-dejavu

#######################################################################
# Installing jenkins
#######################################################################

ENV JENKINS_HOME=/var/jenkins
ENV JENKINS_MASTER_PORT=80
ENV JENKINS_SLAVE_PORT=30050
ENV JENKINS_PLUGINS_URL=http://mirrors.jenkins.io/plugins

ARG JENKINS_VERSION=latest
ARG JENKINS_URL=http://mirrors.jenkins.io/war-stable/${JENKINS_VERSION}/jenkins.war
ARG JENKINS_SHA256_URL=http://mirrors.jenkins.io/war-stable/${JENKINS_VERSION}/jenkins.war.sha256

RUN mkdir -p ${JENKINS_HOME}

WORKDIR ${JENKINS_HOME}

RUN curl -fsSL ${JENKINS_SHA256_URL} | sed -E "s/([a-z0-9]) jenkins/\1  jenkins/" > jenkins.sha256
RUN curl -fsSL ${JENKINS_URL} -o jenkins.war && \
    sha256sum -c jenkins.sha256 && \
    rm -f jenkins.sha256

WORKDIR /

#######################################################################
# Installing consul-template
#######################################################################

ARG CONSUL_TEMPLATE_VERSION=0.19.5
ARG CONSUL_TEMPLATE_ARCHITECTURE=linux_amd64
ARG CONSUL_TEMPLATE_URL=https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
ARG CONSUL_TEMPLATE_SHA256_URL=https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS

WORKDIR /tmp

RUN curl -fsSL ${CONSUL_TEMPLATE_SHA256_URL} | grep ${CONSUL_TEMPLATE_ARCHITECTURE}.zip > consul-template.sha256
RUN curl -fsSL ${CONSUL_TEMPLATE_URL} -o consul-template_${CONSUL_TEMPLATE_VERSION}_${CONSUL_TEMPLATE_ARCHITECTURE}.zip && \
    sha256sum -c consul-template.sha256 && \
    unzip consul-template_${CONSUL_TEMPLATE_VERSION}_${CONSUL_TEMPLATE_ARCHITECTURE}.zip -d /usr/local/bin && \
    rm -f consul-template*

WORKDIR /

#######################################################################
# Copying and laying down the files
#######################################################################

COPY mappedFiles /tmp/mappedFiles
COPY plugins.json /tmp/
COPY fileMappings.json /tmp/

RUN mv /tmp/mappedFiles/bin/fileMapper.sh /usr/local/bin/ && \
    fileMapper.sh /tmp/fileMappings.json && \
    rm -rf /tmp/mappedFiles

RUN plugins.sh /tmp/plugins.json

#######################################################################
# Miscellaneous configuration
#######################################################################

EXPOSE ${JENKINS_MASTER_PORT}
EXPOSE ${JENKINS_SLAVE_PORT}

ENTRYPOINT ["entrypoint.sh"]
