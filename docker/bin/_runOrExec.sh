#!/bin/bash
# This script is to be included in other scripts. It checks, if a container is
# already running and use "exec" or "run" accordingly

# Check for a docker .env file first
. "`dirname "$0"`/_checkEnv.sh"

# Default to php container
if [ -z ${CONTAINER} ]; then
    CONTAINER="php"
fi

# Check if non-interactive mode is enabled (for jenkins)
OPT=""
if [ "${COMPOSE_NON_INTERACTIVE}" = "1" ]; then
    OPT="-T"
fi

# Determine right task
if [ -n "`docker-compose "${DOCKER_COMPOSE_FILES[@]}" ps | grep -e "_${CONTAINER}_.* Up "`" ]; then
    echo "Use \033[32mrunning\033[0m existing ${CONTAINER} container"
    TASK="exec"

    # Run in userspace with the given user
    if [ "${USER}" != "root" ]; then
        OPT="${OPT} --user ${USER}"
    fi
else
    echo "Run in \033[31mnew\033[0m ${CONTAINER} container"
    TASK="run --no-deps --rm"

    # Run in userspace, when non-root user is given
    if [ "${USER}" != "root" ]; then
        OPT="${OPT} -e USERSPACE=1"
    fi
fi

# Exclude the command from being mangled by MINGW on windows
# See https://stackoverflow.com/a/34386471
if [ -z ${MSYS2_ARG_CONV_EXCL} ]; then
    export MSYS2_ARG_CONV_EXCL=${CMD}
fi

if [ -z ${WITHBASH} ]; then
    docker-compose ${TASK} ${OPT} ${CONTAINER} ${CMD}
else
    docker-compose ${TASK} ${OPT} ${CONTAINER} bash -c "${CMD}"
fi
