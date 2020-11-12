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

## Config

Environment:

- APP_URL
- AWS_ACCESS_KEY_ID
- AWS_BUCKET
- AWS_REGION
- AWS_SECRET_ACCESS_KEY
- DATABASE_URL
- LANG
- LOCKBOX_MASTER_KEY
- RACK_ENV
- RAILS_ENV
- RAILS_LOG_TO_STDOUT
- RAILS_SERVE_STATIC_FILES
- REDIS_URL
- SECRET_KEY_BASE

The `REDIS_URL` can be set on a per cache basis using:

- REDIS_CABLE_URL # websockets
- REDIS_CACHE_URL # rails cache and session storage
- REDIS_REFCACHE_URL # refcache
- REDIS_SIDEKIQ_URL # background jobs
