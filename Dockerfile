FROM ruby:3.4 AS base
ARG UNAME=app
ARG UID=1000
ARG GID=1000

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  mariadb-client

WORKDIR /usr/src/app

ENV BUNDLE_PATH=/gems

ENV RUBYLIB=/usr/src/app/lib
RUN gem install bundler

FROM base AS production

RUN groupadd -g $GID -o $UNAME
RUN useradd -m -d /usr/src/app -u $UID -g $GID -o -s /bin/bash $UNAME
RUN mkdir -p /gems && chown $UID:$GID /gems
USER $UNAME
COPY --chown=$UID:$GID Gemfile* /usr/src/app/
WORKDIR /usr/src/app
ENV BUNDLE_PATH=/gems
RUN bundle install
COPY --chown=$UID:$GID . /usr/src/app

LABEL org.opencontainers.image.source="https://github.com/hathitrust/hathifiles"
