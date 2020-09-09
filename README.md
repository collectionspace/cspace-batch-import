# README

Pre-reqs:

- Docker
  - Postgres
  - Redis
- Ruby
- Yarn

To re/start all services:

```bash
./bootstrap.sh # this will blow away any existing databases!

# to run tests
./bin/rails t

# to start the dev server
./bin/rails s

# to run jobs
bundle exec sidekiq
```
