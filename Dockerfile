FROM centos:7
MAINTAINER Aleksandr Lykhouzov <lykhouzov@gmail.com>
ENV GOSU_VERSION=1.10
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql; \
# Install Percona Mysql
rpm --import https://www.percona.com/downloads/RPM-GPG-KEY-percona;\
yum install -y http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm \
&& yum -y update && yum install -y Percona-Server-{client,server,shared,test}-57 \
# Clean up YUM when done.
&& yum clean all && rm -rf /var/lib/mysql && mkdir /var/lib/mysql \
&& chown -R mysql:mysql /var/lib/mysql && chmod -R 755 /var/lib/mysql \
&& chmod 775 /docker-entrypoint.sh; \
# Setup gosu for easier command execution
gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -r /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu

VOLUME ["/var/lib/mysql","/var/run/mysqld/"]

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3306

CMD ["mysqld","-umysql"]
