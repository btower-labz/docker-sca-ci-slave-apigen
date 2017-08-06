# Jenkins APIGen slave image for SCA project.
# TODO: check https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices

FROM btowerlabz/docker-sca-ci-slave
MAINTAINER btower-labz <labz@btower.net>

LABEL Name="docker-sca-ci-slave-apigen"
LABEL Vendor="btower-labz"
LABEL Version="1.0.0"
LABEL Description="Provides apigen sca ci agent, either slave or swarm mode"

ARG LABELS=/home/jenkins/swarm-labels.cfg

#Install additional software
USER root

#Install basic php environment
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y php-common php-cli php-xsl php-mbstring
RUN echo 'debconf debconf/frontend select Dialog' | debconf-set-selections

# Install composer
ADD getcomposer.sh /tmp/getcomposer.sh
RUN ["/bin/bash", "-c", "chmod u+x /tmp/getcomposer.sh; /tmp/getcomposer.sh"]

USER jenkins

# Install API Gen
# PHP 7.1 ready Smart and Simple Documentation for your PHP project
# https://github.com/ApiGen/ApiGen
RUN composer global require apigen/apigen
RUN printf " apigen" >>${LABELS}

#ADD composer.json /home/jenkins/.composer/composer.json
#RUN ["/bin/bash", "-c", "composer global update"]
#RUN mkdir -p /home/jenkins/.ssh && touch /home/jenkins/.ssh/known_hosts

# Set agent labels
RUN printf " php apigen" >>${LABELS}

# Send some info to build log
RUN uname -a; cat /etc/issue; php --version; php --ini; php -m; cat ${LABELS}
