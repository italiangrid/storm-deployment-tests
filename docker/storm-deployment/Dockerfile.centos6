FROM italiangrid/base:centos6

ADD setup /setup
RUN sh /setup/setup.sh

# expose StoRM ports
EXPOSE 8080 8085 8086 8443 8444 9998 2710
