# syntax = docker/dockerfile:1.0-experimental

FROM ruby:2.6

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV RACK_ENV=production

ARG MAXMIND_KEY
ENV MAXMIND_KEY=$MAXMIND_KEY

RUN apt-get update -qq && \
    apt-get install -fqq && \
    apt-get install -yqq build-essential net-tools apt-utils libpq-dev ntp git unzip zip

RUN service ntp stop && apt-get install -yqq fake-hwclock && ntpd -gq && service ntp start

RUN mkdir -p /maxminddb
WORKDIR /maxminddb

COPY . ./

RUN ./download.sh

RUN gem install bundler:2.1.4 && bundle install
RUN bundle exec rake db:convert

EXPOSE 8080

CMD ["ruby", "/maxminddb/application.rb", "-p", "8080"]
