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

ENV JENKINS_HOME=/var/jenkins_home
ENV JENKINS_MASTER_PORT=80
ENV JENKINS_SLAVE_PORT=30050
ENV JENKINS_PLUGINS_URL=http://mirrors.jenkins.io/plugins

ARG JENKINS_VERSION=2.46.2
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war
ARG JENKINS_SHA=aa7f243a4c84d3d6cfb99a218950b8f7b926af7aa2570b0e1707279d464472c7

RUN mkdir -p ${JENKINS_HOME}

RUN curl -fsSL ${JENKINS_URL} -o ${JENKINS_HOME}/jenkins.war && \
    echo "${JENKINS_SHA}  ${JENKINS_HOME}/jenkins.war" | sha256sum -c -

#######################################################################
# Installing consul-template
#######################################################################

ARG CONSUL_TEMPLATE_VERSION=0.18.2
ARG CONSUL_TEMPLATE_URL=https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
ARG CONSUL_TEMPLATE_SHA=6fee6ab68108298b5c10e01357ea2a8e4821302df1ff9dd70dd9896b5c37217c

RUN curl -fsSL ${CONSUL_TEMPLATE_URL} -o /tmp/consul_template.zip && \
    echo "${CONSUL_TEMPLATE_SHA}  /tmp/consul_template.zip" | sha256sum -c - && \
    echo unzip /tmp/consul_template.zip -d /usr/local/bin

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

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
