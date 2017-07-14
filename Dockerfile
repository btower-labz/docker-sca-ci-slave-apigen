# Jenkins ApiGen slave image for SCA project.
# TODO: check https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#run

FROM jenkinsci/slave
MAINTAINER BTower Labz <labz@btower.net>

COPY jenkins-slave /usr/local/bin/jenkins-slave

#Install additional software
USER root
RUN apt-get update
RUN uname -a
RUN cat /etc/issue

#Install basic tools
RUN apt-get install -y curl git unzip lsof nano apt-utils

#Install basic php
RUN apt-get install -y php5-common php5-cli php5-xsl

# Install composer
COPY composer-setup.php /tmp/composer-setup.php
RUN php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'HASH OK'; } else { echo 'HASH FAIL'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;"
RUN php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm /tmp/composer-setup.php
RUN touch /home/jenkins/.composer
RUN chown jenkins:jenkins /home/jenkins/.composer

USER jenkins
RUN php --version

# Install API Gen
# PHP 7.1 ready Smart and Simple Documentation for your PHP project 
# https://github.com/ApiGen/ApiGen
RUN composer global require apigen/apigen

ENTRYPOINT ["jenkins-slave"]
