FROM ubuntu:trusty
MAINTAINER CSP Support <csp.support@os.uk>

RUN apt-get update && \
	apt-get install -y wget curl && \
	curl https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo 'deb http://packages.elastic.co/elasticsearch/2.x/debian stable main' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y elasticsearch && \
    apt-get install -y nginx supervisor apache2-utils && \    
    apt-get clean && \
    rm -rf /var/lib/apt/lists && \
    wget --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u66-b17/jdk-8u66-linux-x64.tar.gz" -O jdk-8-linux-x64.tar.gz && \
    tar -xvzf jdk-8-linux-x64.tar.gz && \
    rm -rf jdk-8-linux-x64.tar.gz

ENV JAVA_HOME /jdk1.8.0_66
ENV PATH ${PATH}:${JAVA_HOME}/bin
ENV ELASTICSEARCH_USER **None**
ENV ELASTICSEARCH_PASS **None**
ENV CLUSTER_NAME **REQUIRED**
ENV ES_OPTS ""
ENV ES_S3_BUCKET_NAME **REQUIRED**
ENV AWS_ACCESS_KEY_ID **REQUIRED**
ENV AWS_SECRET_KEY **REQUIRED**
ENV EC2_TAG_NODE_NAME **REQUIRED**
ENV ELASTICSEARCH_NODE_NAME ${TUTUM_CONTAINER_HOSTNAME}
ENV NETWORK_BIND_HOST 0.0.0.0
ENV NETWORK_PUBLISH_HOST _ec2:privateIp_
ENV NUMBER_OF_SHARDS 7
ENV NUMBER_OF_REPLICAS 2

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD run.sh /run.sh
ADD nginx_default /etc/nginx/sites-enabled/default

# Define mountable directories.
# Mount elasticsearch.yml config
ADD config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

RUN /usr/share/elasticsearch/bin/plugin install cloud-aws && \
    /usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/v2.1.1 && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    chmod +x /*.sh && \
    chown -R elasticsearch: /usr/share/elasticsearch
USER elasticsearch

CMD ["/run.sh", "${ES_OPTS}"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300