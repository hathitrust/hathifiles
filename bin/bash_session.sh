#!/bin/bash
# Opens up a hathifiles bash session.
docker-compose up -d pushgateway
docker-compose run --rm "hf" bash
# Now do e.g. `bundle exec rspec` or whatever.
# Exit to be done with the session.
docker-compose down; yes | docker system prune
