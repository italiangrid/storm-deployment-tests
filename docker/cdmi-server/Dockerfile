FROM centos:7

RUN yum update -y
RUN yum install -y wget

RUN rpm --import http://repo.indigo-datacloud.eu/repository/RPM-GPG-KEY-indigodc
RUN wget http://repo.indigo-datacloud.eu/repository/indigo/2/centos7/x86_64/base/indigodc-release-2.0.0-1.el7.centos.noarch.rpm
RUN yum localinstall -y indigodc-release-2.0.0-1.el7.centos.noarch.rpm
RUN yum-config-manager --disable INDIGO-2-base

#RUN yum install -y cdmi-server
RUN wget https://ci.cloud.cnaf.infn.it/job/CDMI/job/master/lastSuccessfulBuild/artifact/cdmi-server-1.2.1-1.el7.centos.x86_64.rpm
RUN yum localinstall -y cdmi-server-1.2.1-1.el7.centos.x86_64.rpm

EXPOSE 8888