#!/bin/bash
# This script is to be included in other scripts. It checks, if a .env file
# already exists and creates one if not

# Find parent directoy, where docker-compose.yml is
DIRNAME=`dirname "$0"`
DIR="${DIRNAME}"
if [ "`echo ${DIRNAME} | head -c1`" != "/" ]; then
    DIR="`pwd`/${DIRNAME}"
fi

while [ ! -e "${DIR}/docker-compose.yml" ]; do
    # We found the root, but no docker-compose.yml
    if [ "${DIR}" = "/" ]; then
        echo "\033[31mCould not find a docker-compose.yml\033[0m"
        exit 127
    fi
    # Note: if you want to ignore symlinks, use "$(realpath -s "$path"/..)"
    # Note: readlink -f would be nice, but will not work on MacOS
    cd "${DIR}/.."
    DIR=`pwd`
done

# Create .env when not existing
if [ ! -e "${DIR}/.env" ]; then
    cp "${DIR}/.env.dist" "${DIR}/.env"
    echo "" >> "${DIR}/.env"
    echo "DOCKER_UID=`id -u`" >> "${DIR}/.env"
    if [ `id -g` -gt 50 ]; then
        echo "DOCKER_GID=`id -g`" >> "${DIR}/.env"
    else
        echo "\033[33mWarning: You will have no GID mapping, as the id on your host is not allowed inside the container\033[0m"
    fi
    echo "Created \033[33mnew docker \033[1m.env\033[21m file\033[0m"
fi
