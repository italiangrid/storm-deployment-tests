FROM italiangrid/cdmi-server

COPY launch_cdmi.sh /launch_cdmi.sh
RUN chmod +x /launch_cdmi.sh

RUN yum install -y git nc && yum clean all

EXPOSE 8888

ENTRYPOINT ["/launch_cdmi.sh"]