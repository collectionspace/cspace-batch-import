#!/bin/bash

docker stop postgres && docker rm -f postgres || true
docker stop redis && docker rm -f redis || true

docker run --name postgres -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 postgres:12
docker run --name redis -d -p 6379:6379 redis:6

sleep 1
./bin/rails dev:cache
./bin/rails db:setup
