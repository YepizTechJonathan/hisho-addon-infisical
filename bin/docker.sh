#!/usr/bin/env bash
# docker for Infisical's unit and install: the account's rootless Docker when it has one (a Kihon), else the system's
# (a Souko). An account added to the docker group after its session started can't use the system one until the next
# login (a Souko's first boot does that): then it runs with the group now, through sg (2026-10-29).
uid=$(id -u)
if [ -z "${DOCKER_HOST:-}" ] && [ -S "/run/user/$uid/docker.sock" ]; then
  export DOCKER_HOST="unix:///run/user/$uid/docker.sock"
fi
if [ -z "${DOCKER_HOST:-}" ] && ! id -nG | tr ' ' '\n' | grep -qx docker \
   && getent group docker | cut -d: -f4 | tr ',' '\n' | grep -qx "$(id -un)"; then
  exec sg docker -c "docker $(printf '%q ' "$@")"
fi
exec docker "$@"
