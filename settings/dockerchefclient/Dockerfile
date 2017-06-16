FROM centos:7systemd
MAINTAINER chankongching@gmail.com

COPY ./chef-12.5.1-1.el7.x86_64.rpm /tmp/chef-12.5.1-1.el7.x86_64.rpm
RUN  rpm -ivh /tmp/chef-12.5.1-1.el7.x86_64.rpm
# RUN  yum install -y docker

# RUN  set -x && \
#      systemctl enable docker 

# CMD ["/usr/sbin/init"]

# RUN  set -x && \
#     systemctl start docker

#RUN  docker login -ukeithyau -pthomas123 dockerpriv.kybot.io:5002
#RUN  docker pull dockerpriv.kybot.io:5002/keithyau/kyligence_azure:latest

RUN  set -x && \
     cd /root && \
     yum install wget make gcc-c++ -y && \
     wget -N http://nodejs.org/dist/node-latest.tar.gz && \
     tar zxvf node-latest.tar.gz && \
     cd node-v* && \
     ./configure && \
     make install && \
     node --version 
RUN  set -x && \
     npm install azure-cli -g
