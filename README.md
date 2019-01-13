# Introduction

This is a simplified docker image and docker-compose, based on https://gitlab.com/Shinobi-Systems/ShinobiDocker.

This diverges from upstream in a few ways:
* Uses the official mysql docker image, and in a separate container rather than running it in the background in the same container as the app
* All database settings are configurable from within the compose file
* Shinobi docker image is kept as small as possible (~500MB compared to ~800MB for migoller/shinobidocker:alpine)
* Removes the update step in docker-entrypoint.sh


