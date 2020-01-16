# Reference URL: https://runnable.com/docker/java/dockerize-your-java-application
# Reference URL: https://www.howtoforge.com/tutorial/how-to-create-docker-images-with-dockerfile/
# Reference URL: https://hub.docker.com/r/mcpayment/ubuntu1404-java8/~/dockerfile/
# Reference URL: https://github.com/TexaiCognitiveArchitecture/docker-java8-jenkins-maven-git-nano
# Reference URL: https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#apt-get
# Reference Command: docker search ubuntu/java

# Download base image ubuntu 18.04
FROM ubuntu:18.04

MAINTAINER  Desire Banse

# Prepare installation of Oracle Java 8
ENV JAVA_VER 8
# ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
# ENV JAVA_HOME /opt/java-jdk/jdk1.8.0_211

RUN apt-get update
RUN apt-get -y install curl gnupg

# Install Java8 from oracle binaries
# RUN mkdir /opt/java-jdk
# COPY jdk-8u211-linux-x64.tar.gz /root/
# RUN tar -C /opt/java-jdk -zxf /root/jdk-8u211-linux-x64.tar.gz
# RUN update-alternatives --install /usr/bin/java java /opt/java-jdk/jdk1.8.0_211/bin/java 1
# RUN update-alternatives --install /usr/bin/javac javac /opt/java-jdk/jdk1.8.0_211/bin/javac 1

RUN echo 'deb http://archive.ubuntu.com/ubuntu xenial main universe' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y git wget && \
    apt-get install -y openjdk-8-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install git, wget, Oracle Java8
#RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" >> /etc/apt/sources.list && \
#    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" >> /etc/apt/sources.list && \
#    echo 'deb http://archive.ubuntu.com/ubuntu xenial main universe' >> /etc/apt/sources.list && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 && \
#    apt-get update && \
#    apt-get install -y git wget && \
#    echo oracle-java${JAVA_VER}-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
#    apt-get install -y --force-yes --no-install-recommends oracle-java${JAVA_VER}-installer oracle-java${JAVA_VER}-set-default && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
#    rm -rf /var/cache/oracle-jdk${JAVA_VER}-installer

# Set Oracle Java as the default Java
# RUN update-java-alternatives -s java-8-oracle
# RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> ~/.bashrc

# Install maven 3.3.9
RUN wget --no-verbose -O /tmp/apache-maven-3.3.9-bin.tar.gz http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz && \
    tar xzf /tmp/apache-maven-3.3.9-bin.tar.gz -C /opt/ && \
    ln -s /opt/apache-maven-3.3.9 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin  && \
    rm -f /tmp/apache-maven-3.3.9-bin.tar.gz

ENV MAVEN_HOME /opt/maven

COPY hit-dev.nist.gov.keystore /root/


RUN cd /root/ && git clone https://github.com/usnistgov/hit-core.git
RUN cd /root/hit-core && git checkout master
RUN cd /root/hit-core/ && mvn clean

# COPY settings.xml /root/
COPY settings.xml /root/.m2/

# continue installation
RUN cd /root/hit-core/ && mvn -U clean install -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true

RUN cd /root/ && git clone https://github.com/usnistgov/hl7-profile-validation
RUN cd /root/hl7-profile-validation && git checkout develop
RUN cd /root/hl7-profile-validation && mvn -U clean install -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true

RUN cd /root/ && git clone https://github.com/usnistgov/hit-core-xml
RUN cd /root/hit-core-xml/ && git checkout master
COPY pom_core.xml /root/hit-core-xml/pom.xml
RUN cd /root/hit-core-xml && mvn -pl '!hit-core-xml-service,!hit-core-xml-api' install -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.test.skip
RUN cd /root/hit-core-xml/hit-core-xml-domain && mvn -U install -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.test.skip
RUN cd /root/hit-core-xml/hit-core-xml-repo && mvn -U install -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.test.skip

RUN cd /root/ && git clone https://github.com/usnistgov/hit-xml-validation.git
RUN cd /root/hit-xml-validation && mvn -U clean install -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true

RUN cd /root/ && git clone https://github.com/usnistgov/schematronValidation.git
RUN cd /root/schematronValidation && mvn -U clean install -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true

RUN cd /root/ && git clone https://github.com/usnistgov/hit-core-hl7v2.git
RUN cd /root/hit-core-hl7v2 && git checkout master
COPY pom.xml /root/hit-core-hl7v2/pom.xml
COPY pom_api.xml /root/hit-core-hl7v2/hit-core-hl7v2-api/pom.xml
COPY pom_domain.xml /root/hit-core-hl7v2/hit-core-hl7v2-domain/pom.xml
COPY pom_repo.xml /root/hit-core-hl7v2/hit-core-hl7v2-repo/pom.xml
COPY pom_service.xml /root/hit-core-hl7v2/hit-core-hl7v2-service/pom.xml
RUN cd /root/hit-core-hl7v2 && mvn -U clean install -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true

# tools for the server side and client side
# RUN cd /root/ && wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

RUN curl -sL https://deb.nodesource.com/setup_8.x  | bash -
RUN apt-get -y install nodejs

RUN npm cache clean -f
RUN npm install -g n
RUN n 8.14.1

RUN apt-get install -y build-essential
RUN apt-get install -y ruby2.5
RUN apt-get install -y ruby2.5-dev
RUN apt-get install -y ruby-ffi
RUN gem update --system
RUN gem install sass
RUN gem install compass

RUN cd /root/ && npm install -g bower

# build the IZ tool
RUN cd /root/ && git clone https://github.com/usnistgov/hit-iz-tool
RUN cd /root/hit-iz-tool && git checkout apps/cni-new
COPY pom_iz.xml /root/hit-iz-tool/hit-iz-web/pom.xml
COPY pom_iz_tool.xml /root/hit-iz-tool/pom.xml
RUN cd /root/hit-iz-tool/hit-iz-web/client && npm install

RUN cd /root/hit-iz-tool/hit-iz-web/client && bower install --allow-root

RUN cd /root/ && npm install -g grunt
RUN cd /root/hit-iz-tool/hit-iz-web/client && grunt build

RUN cd /root/hit-iz-tool/ && mvn -U clean install -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.test.skip

EXPOSE 80 443
