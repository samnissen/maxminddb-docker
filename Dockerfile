# syntax = docker/dockerfile:1.0-experimental

FROM ruby:2.6

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV RACK_ENV=production

RUN apt-get update -qq
RUN apt-get install -fqq
RUN apt-get install -yqq build-essential net-tools apt-utils libpq-dev ntp wget git unzip zip

RUN service ntp stop
RUN apt-get install -yqq fake-hwclock
RUN ntpd -gq &
RUN service ntp start

RUN mkdir -p /maxminddb
WORKDIR /maxminddb

COPY . ./

RUN --mount=type=secret,id=geolite2citytar wget -nv -O GeoLite2-City.tar.gz -i /run/secrets/geolite2citytar
RUN tar -xvzf GeoLite2-City.tar.gz && mv GeoLite2-City_* db/maxminddb

RUN --mount=type=secret,id=geolite2citycsv wget -nv -O GeoLite2-City-CSV.zip "$(cat /run/secrets/geolite2citycsv)"
RUN unzip GeoLite2-City-CSV.zip && mv GeoLite2-City-CSV_* db/GeoLite2-City

RUN bundle install
RUN bundle exec rake db:convert

EXPOSE 8080

CMD ["ruby", "/maxminddb/application.rb", "-p", "8080"]
