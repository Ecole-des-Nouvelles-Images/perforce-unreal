FROM ubuntu:noble

RUN apt-get update
RUN apt-get install curl gpg -y

RUN curl -sS https://package.perforce.com/perforce.pubkey | gpg --dearmor -o /usr/share/keyrings/perforce.gpg

RUN echo "deb [signed-by=/usr/share/keyrings/perforce.gpg] http://package.perforce.com/apt/ubuntu noble release" > /etc/apt/sources.list.d/perforce.list

RUN apt-get update
RUN apt-get install helix-p4d -y
RUN apt-get clean

ARG DOCKER_USER=perforce
RUN addgroup --system $DOCKER_USER && adduser --system $DOCKER_USER

WORKDIR /
COPY docker-entrypoint.sh /
RUN chmod 500 /docker-entrypoint.sh
RUN chown $DOCKER_USER:$DOCKER_USER /docker-entrypoint.sh

RUN mkdir /metadata && mkdir /library && mkdir /journals && mkdir /backup && mkdir /ssl
RUN chown $DOCKER_USER:$DOCKER_USER /metadata /library /journals /backup /ssl
RUN chmod 700 /metadata /library /journals /backup /ssl

USER $DOCKER_USER

ENV P4_PORT=ssl:1666
ENV P4_ROOT=/metadata
ENV P4_NAME=myserver
ENV P4_JOURNAL=/journals/journal
ENV P4_SSL_DIR=/ssl

ENTRYPOINT ["/docker-entrypoint.sh"]
