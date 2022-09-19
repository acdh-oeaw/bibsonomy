FROM tomcat:9-jdk8-openjdk-slim-bullseye 

COPY project.properties /home/bibsonomy/project.properties
# install some packages
RUN apt update && apt install -y git curl wget unzip links vim nano maven && \
    git clone --branch v3.8.18 --single-branch https://bitbucket.org/bibsonomy/bibsonomy.git /app && \
    cd /app && mvn clean install -Dmaven.test.skip -DskipTests && \
    cd /app && mvn war:inplace && \
# allow slashes
    echo 'org.apache.tomcat.util.buf.UDecoder.ALLOW_ENCODED_SLASH=true\n\
          org.apache.catalina.connector.CoyoteAdapter.ALLOW_BACKSLASH=true\n'\
    >> /usr/local/tomcat/conf/catalina.properties && \
# set context for the project configuration file
    sed -i 's|autoDeploy="true">|autoDeploy="true"> <Context docBase="/app/bibsonomy-webapp/src/main/webapp" workDir="/app/bibsonomy-webapp/work" path="" reloadable="true"> </Context>|g' /usr/local/tomcat/conf/server.xml && \
    sed -i 's|</Context>|<Parameter name="config.location" value="/home/bibsonomy/project.properties" override="false" /> </Context>|g' /usr/local/tomcat/conf/context.xml && \
    sed -i 's|</Context>|<Resources cachingAllowed="true" cacheMaxSize="100000" /> </Context>|g' /usr/local/tomcat/conf/context.xml && \
    cd /usr/local/tomcat/lib/ && \
    wget https://repo1.maven.org/maven2/commons-logging/commons-logging/1.2/commons-logging-1.2.jar && \
    wget https://repo1.maven.org/maven2/log4j/log4j/1.2.12/log4j-1.2.12.jar && \
    wget https://repo1.maven.org/maven2/commons-dbcp/commons-dbcp/1.4/commons-dbcp-1.4.jar && \
    wget https://repo1.maven.org/maven2/org/apache/commons/commons-dbcp2/2.5.0/commons-dbcp2-2.5.0.jar && \
    wget https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.6.3/slf4j-api-1.6.3.jar && \
    wget https://repo1.maven.org/maven2/org/slf4j/slf4j-log4j12/1.6.3/slf4j-log4j12-1.6.3.jar && \
    wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.27/mysql-connector-java-8.0.27.jar

EXPOSE 8080
CMD ["catalina.sh", "run"]
