#!/bin/bash

# Fill screen with previous logs
docker logs $1 --tail $(tput lines)

# Reattach as long as exit code is not 1 (=detach code)
while true; do
  docker attach $1
  if [[ $? -eq 1 ]]; then
    break
  fi
done
