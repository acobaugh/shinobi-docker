# Introduction

This is a simplified docker image and docker-compose, based on https://gitlab.com/Shinobi-Systems/ShinobiDocker.

This diverges from upstream in a few ways:
* Uses the official mysql docker image, and in a separate container rather than running it in the background in the same container as the app
* All database settings are configurable from within the compose file
* Shinobi docker image is kept as small as possible (~500MB compared to ~800MB for migoller/shinobidocker:alpine)
* Removes the update step in docker-entrypoint.sh


## Setup

1. Create the `.env` file and change/populate it if needed:

   `cp env.example .env` 
 
Note: `.env` is used here instead of `env_file`s due to how compose uses variables. In order to use `MYSQL_USER` and `MYSQL_PASSWORD` in the mysql container healthcheck, these have to be declared within the compose environment (.env). Then to keep the compose file DRY, these are pulled out into the `.env` file then referenced in the `environment` blocks for both containers.

2. Start containers with:
   
   `docker-compose up`
