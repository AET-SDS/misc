#!/bin/bash

set -o errexit

AET_REPO_PATH=${1:-'../aet'}
AET_DOCKER_PATH=${2:-'../aet-docker'}

unzip_artifact() {
    # $1 - zip to unpack
    rm -rf "${AET_DOCKER_PATH:?}/$1"
    unzip -oq "$AET_REPO_PATH/zip/target/packages-$AET_VERSION/$1" -d "$AET_DOCKER_PATH/$1"
}

if [ ! -d "$AET_REPO_PATH" ] || [ ! -d "$AET_DOCKER_PATH" ]; then
    echo -e "$AET_REPO_PATH or $AET_DOCKER_PATH doesn't exists.\nexiting..."
    exit 1
fi

AET_VERSION=$(grep -E ".*<version>.*" "$AET_REPO_PATH/pom.xml" | head -n 1 | tr -dc '0-9|.|[A-Z]|-')

for app in 'configs' 'bundles' 'features' 'report'; do
    echo "Checking if $AET_DOCKER_PATH/$app exist..."
    [ -d "$AET_DOCKER_PATH/$app" ] || mkdir -p "$AET_DOCKER_PATH/$app"
    echo "Unzipping $app"
    unzip_artifact $app
done

sudo chown aet:aet -R "$AET_DOCKER_PATH"

echo "Finished copying artifacts"
