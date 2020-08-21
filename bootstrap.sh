#!/bin/bash

CACHE_FILE=tmp/caching-dev.txt

docker stop postgres && docker rm -f postgres || true
docker stop redis && docker rm -f redis || true

docker run --name postgres -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 postgres:12
docker run --name redis -d -p 6379:6379 redis:6

sleep 1

if [ -f "$CACHE_FILE" ]; then
  echo "Dev cache is already enabled."
else
  ./bin/rails dev:cache
fi

./bin/rails db:setup
