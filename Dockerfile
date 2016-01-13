FROM tutum/curl:trusty
MAINTAINER FENG, HONGLIN <hfeng@tutum.co>

RUN curl https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo 'deb http://packages.elastic.co/elasticsearch/2.x/debian stable main' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y wget elasticsearch && \
    apt-get install -y nginx supervisor apache2-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u66-b17/jdk-8u66-linux-x64.tar.gz" -O jdk.tar.gz && \
    tar -xvzf jdk.tar.gz && \
    mv jdk /

ENV JAVA_HOME=/jdk
ENV ELASTICSEARCH_USER **None**
ENV ELASTICSEARCH_PASS **None**

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD run.sh /run.sh
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD nginx_default /etc/nginx/sites-enabled/default
RUN chmod +x /*.sh

# Define mountable directories.
VOLUME ["/data"]

# Mount elasticsearch.yml config
ADD config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

CMD ["/run.sh"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
#   - 54328: discovery
EXPOSE 9200
EXPOSE 9300
EXPOSE 54328