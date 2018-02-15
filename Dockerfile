FROM openjdk:8-jdk

#######################################################################
# Installing additional packages
#######################################################################

RUN apt-get update && \
    apt-get install -y git curl jq && \
    rm -rf /var/lib/apt/lists/*

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

RUN curl -fsSL ${JENKINS_SHA256_URL} -o jenkins.war.sha256
RUN curl -fsSL ${JENKINS_URL} -o jenkins.war && \
    sha256sum --ignore-missing -c jenkins.war.sha256 && \
    rm -f jenkins.war.sha256

WORKDIR /

#######################################################################
# Installing consul-template
#######################################################################

ARG CONSUL_TEMPLATE_VERSION=0.19.4
ARG CONSUL_TEMPLATE_URL=https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
ARG CONSUL_TEMPLATE_SHA256_URL=https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS

WORKDIR /tmp

RUN curl -fsSL ${CONSUL_TEMPLATE_SHA256_URL} -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip.sha256
RUN curl -fsSL ${CONSUL_TEMPLATE_URL} -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    sha256sum --ignore-missing -c consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip.sha256 && \
    unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -d /usr/local/bin

WORKDIR /

#######################################################################
# Copying and laying down the files
#######################################################################

COPY mappedFiles /tmp/mappedFiles
COPY plugins.json /tmp/
COPY fileMappings.json /tmp/

RUN mv /tmp/mappedFiles/bin/fileMapper.sh /usr/local/bin/ && \
    chmod +x /usr/local/bin/fileMapper.sh && \
    fileMapper.sh /tmp/fileMappings.json && \
    chmod -R +x /usr/local/bin/ && \
    rm -rf /tmp/mappedFiles

RUN plugins.sh /tmp/plugins.json

#######################################################################
# Miscellaneous configuration
#######################################################################

EXPOSE ${JENKINS_MASTER_PORT}
EXPOSE ${JENKINS_SLAVE_PORT}

ENTRYPOINT ["entrypoint.sh"]
