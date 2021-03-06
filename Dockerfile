FROM tomcat:8.5-jdk8

MAINTAINER Henri Lefevre <henri.lefevre@wavestone.com>

ENV CATALINA_HOME=/usr/local/tomcat \
    PATH=$CATALINA_HOME/bin:$PATH \
    OPENAM_USER="openam" \
    OPENAM_DATA_DIR="/usr/openam/config" \
    CATALINA_OPTS="-Xmx2048m -server -Dcom.iplanet.services.configpath=$OPENAM_DATA_DIR -Dcom.sun.identity.configuration.directory=$OPENAM_DATA_DIR" \
    VERSION=14.6.4

WORKDIR $CATALINA_HOME

RUN apt-get update \
 && apt-get install -y unzip \
 && rm -rf /var/lib/apt/lists/* \
 && curl https://github.com/OpenIdentityPlatform/OpenAM/releases/download/$VERSION/OpenAM-$VERSION.war -o $CATALINA_HOME/webapps/openam.war -sL \
 && mkdir /usr/openam \
 && curl https://github.com/OpenIdentityPlatform/OpenAM/releases/download/$VERSION/SSOConfiguratorTools-$VERSION.zip -o /usr/openam/ssoconfiguratortools.zip -sL \
 && unzip /usr/openam/ssoconfiguratortools.zip -d /usr/openam/ssoconfiguratortools \
 && rm /usr/openam/ssoconfiguratortools.zip \
 && curl https://github.com/OpenIdentityPlatform/OpenAM/releases/download/$VERSION/SSOAdminTools-$VERSION.zip -o /usr/openam/ssoadmintools.zip -sL \
 && unzip /usr/openam/ssoadmintools.zip -d /usr/openam/ssoadmintools \
 && rm /usr/openam/ssoadmintools.zip \
 && chgrp -R 0 /usr/openam/ \
 && chmod -R g=u /usr/openam/ \
 && chgrp -R 0 /usr/local/tomcat \
 && chmod -R g=u /usr/local/tomcat \
 && useradd -m -r -u 1001 -g root $OPENAM_USER \
 && install -d -o $OPENAM_USER $OPENAM_DATA_DIR

USER $OPENAM_USER

COPY openam-build.sh /tmp/
RUN chmod +x /tmp/openam-build.sh
 && /tmp/openam-build.sh
 && rm -f /tmp/openam-build.sh

CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]
