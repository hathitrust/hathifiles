FROM ruby:3.2
ARG UNAME=app
ARG UID=1000
ARG GID=1000

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  nodejs \
  netcat-traditional

RUN wget -O /usr/local/bin/wait-for https://github.com/eficode/wait-for/releases/download/v2.2.3/wait-for; chmod +x /usr/local/bin/wait-for

# COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app
#
ENV BUNDLE_PATH /gems
#

ENV RUBYLIB /usr/src/app/lib
RUN gem install bundler
#
# COPY . /usr/src/app
