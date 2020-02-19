#!/usr/bin/env bash
# Configure and launch dockerized redash

set -eo pipefail

cd "$(dirname "$0")"

if [ -f dot-env ]; then
  echo "Error: Redash seems to be already installed! aborting..."
  exit 1
fi

cp dot-env.dist dot-env

POSTGRES_PASSWORD="$(pwgen -1s 32)"
REDASH_COOKIE_SECRET="$(pwgen -1s 32)"
REDASH_SECRET_KEY="$(pwgen -1s 32)"
REDASH_DATABASE_URL="postgresql://postgres:${POSTGRES_PASSWORD}@postgres/postgres"

sed -e "s/^POSTGRES_PASSWORD=/POSTGRES_PASSWORD=${POSTGRES_PASSWORD}/" dot-env > dot-env.bak && mv dot-env.bak dot-env
sed -e "s/^REDASH_COOKIE_SECRET=/REDASH_COOKIE_SECRET=${REDASH_COOKIE_SECRET}/" dot-env > dot-env.bak && mv dot-env.bak dot-env
sed -e "s/^REDASH_SECRET_KEY=/REDASH_SECRET_KEY=${REDASH_SECRET_KEY}/" dot-env > dot-env.bak && mv dot-env.bak dot-env
sed -e "s/^REDASH_DATABASE_URL=/REDASH_DATABASE_URL=${REDASH_DATABASE_URL//\//\\/}/" dot-env > dot-env.bak && mv dot-env.bak dot-env

docker-compose run --rm server create_db
docker-compose up -d
