FROM italiangrid/cdmi-server

RUN yum install -y git nc
RUN yum clean all

COPY data /data

WORKDIR /data

RUN ls
RUN chmod +x run.sh

EXPOSE 8888

ENTRYPOINT ["./run.sh"]