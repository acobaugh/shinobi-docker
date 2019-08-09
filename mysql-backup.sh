#!/usr/bin/env bash

test -f .env && export $(cat .env | xargs)

docker exec $(docker-compose ps -q mysql) /usr/bin/mysqldump -u root --password="$MYSQL_ROOT_PASSWORD" $MYSQL_DATABASE > backup.sql
