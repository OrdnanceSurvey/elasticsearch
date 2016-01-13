FROM ubuntu:trusty
MAINTAINER CSP Support <csp.support@os.uk>

RUN apt-get update && \
	apt-get install -y curl && \
	curl https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo 'deb http://packages.elastic.co/elasticsearch/2.x/debian stable main' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y elasticsearch && \
    apt-get install -y nginx supervisor apache2-utils && \    
    apt-get clean && \
    rm -rf /var/lib/apt/lists && \
    curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u66-b17/jdk-8u66-linux-x64.tar.gz" | tar -xzvf -

ENV JAVA_HOME /jdk1.8.0_66
ENV PATH ${PATH}:${JAVA_HOME}/bin
ENV ELASTICSEARCH_USER **None**
ENV ELASTICSEARCH_PASS **None**
ENV CLUSTER_NAME ES_Cluster

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD run.sh /run.sh
ADD nginx_default /etc/nginx/sites-enabled/default

# Define mountable directories.
VOLUME ["/data"]
# Mount elasticsearch.yml config
ADD config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

RUN /usr/share/elasticsearch/bin/plugin install cloud-aws && \    
    /usr/share/elasticsearch/bin/plugin install discovery-multicast && \
    /usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/v2.1.1 && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    chmod +x /*.sh && \
    chown -R elasticsearch: /usr/share/elasticsearch && \
    chown -R elasticsearch: /data

USER elasticsearch

CMD ["/run.sh"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
#   - 54328: discovery
EXPOSE 9200
EXPOSE 9300
EXPOSE 54328