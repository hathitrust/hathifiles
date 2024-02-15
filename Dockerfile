FROM ruby:3.2
ARG UNAME=app
ARG UID=1000
ARG GID=1000

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  nodejs \
  netcat-traditional

# COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app
#
ENV BUNDLE_PATH /gems
#

ENV RUBYLIB /usr/src/app/lib
RUN gem install bundler
#
# COPY . /usr/src/app
