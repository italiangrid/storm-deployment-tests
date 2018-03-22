FROM italiangrid/pkg.base:centos6

USER root

ENV UMD_REPO http://repository.egi.eu/sw/production/umd/4/sl6/x86_64/updates/umd-release-4.1.3-1.el6.noarch.rpm
ENV LD_LIBRARY_PATH /usr/lib64/storm

ENV CFLAGS="-O0 -g -Wall"
ENV CXXFLAGS="-O0 -g -Wall"

RUN rpm --import http://repository.egi.eu/sw/production/umd/UMD-RPM-PGP-KEY && \
  yum install -y $UMD_REPO && \
  yum update -y

RUN yum install -y pkgconfig \
  boost-devel \
  curl-devel \
  mysql-devel \
  globus-gssapi-gsi-devel \
  globus-gss-assist-devel \
  globus-common-devel \
  globus-gridmap-callout-error-devel \
  globus-gsi-credential-devel \
  krb5-devel \
  gsoap-devel \
  CGSI-gSOAP-devel \
  libuuid-devel \
  voms \
  gcc \
  gcc-c++ \
  storm-xmlrpc-c-devel \
  argus-pep-api-c \
  argus-pep-api-c-devel \
  gdb \
  strace \
  ltrace \
  gfal2-all \
  gfal2-util \
  gfal2-devel \
  voms-clients3 \
  yum-utils 

RUN debuginfo-install -y CGSI-gSOAP gsoap storm-xmlrpc-c argus-pep-api-c

RUN adduser storm && mkdir -p /etc/storm/frontend-server && mkdir /var/log/storm && \
      chown -R storm:storm /etc/storm && \
      chown storm:storm /var/log/storm && \
      usermod -a -G wheel storm && \
      mkdir /home/storm/.globus 

ADD ./vomses /etc/vomses
ADD ./fe_cnaf_infn_it.cert.pem /certs/hostcert.pem
ADD ./fe_cnaf_infn_it.key.pem /certs/hostkey.pem
ADD ./storm-frontend-server.conf /etc/storm/frontend-server/
ADD ./bootstrap.sh /home/storm
ADD ./test0.p12 /home/storm/.globus/usercred.p12
ADD ./start-fe.sh ./stop-fe.sh /home/storm/

RUN chown -R storm:storm /certs/host*.pem /home/storm && \
      chmod 700 /home/storm/.globus && \
      chmod 600 /home/storm/.globus/usercred.p12 && \
      chown -R storm:storm /home/storm && \
      chmod 755 /home/storm/start-fe.sh /home/storm/stop-fe.sh

USER storm
WORKDIR /home/storm
CMD ["/bin/bash", "bootstrap.sh"]

EXPOSE 8444
