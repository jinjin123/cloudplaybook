FROM centos:7systemd
MAINTAINER chankongching@gmail.com

COPY ./chef-12.5.1-1.el7.x86_64.rpm /tmp/chef-12.5.1-1.el7.x86_64.rpm
RUN  rpm -ivh /tmp/chef-12.5.1-1.el7.x86_64.rpm

# Installing nodejs for azure
RUN  set -x && \
     cd /root && \
     yum install wget make gcc-c++ -y && \
     wget -N http://nodejs.org/dist/node-latest.tar.gz && \
     tar zxvf node-latest.tar.gz && \
     cd node-v* && \
     ./configure && \
     make install && \
     node --version

# Installing azure command line
RUN  set -x && \
     npm install azure-cli -g

# Installing python for aws
RUN  set -x && \
     yum -y install https://centos7.iuscommunity.org/ius-release.rpm && \
     yum -y install python36u python36u-pip

RUN  which python3.6
RUN  which pip3.6
