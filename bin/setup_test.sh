#!/bin/bash
docker-compose build
docker-compose run --rm hf bundle install
docker-compose up -d mariadb pushgateway
