#!/bin/bash

set -o errexit

AET_REPO_PATH=${$1'/home/aet/aet'}
AET_DOCKER_PATH=${$2'/home/aet/aet-docker'}

if [ ! -d AET_REPO_PATH ] && [ ! -d AET_DOCKER_PATH ]; then
    echo -e "$AET_REPO_PATH or $AET_DOCKER_PATH doesn't exists.\n exiting..."
    exit 1
fi

AET_VERSION=$(grep -E ".*<version>.*" "$AET_REPO_PATH/pom.xml" | head -n 1 | tr -dc '0-9|.|[A-Z]|-')

bundles=(
    "api/communication-api/target/com.cognifide.aet.communication-api-$AET_VERSION.jar"
    "api/datastorage-api/target/com.cognifide.aet.datastorage-api-$AET_VERSION.jar"
    "api/jobs-api/target/com.cognifide.aet.jobs-api-$AET_VERSION.jar"
    "api/validation-api/target/com.cognifide.aet.validation-api-$AET_VERSION.jar"
    "core/cleaner/target/com.cognifide.aet.cleaner-$AET_VERSION.jar"
    "core/communication/target/com.cognifide.aet.communication-$AET_VERSION.jar"
    "core/datastorage/target/com.cognifide.aet.datastorage-$AET_VERSION.jar"
    "core/jobs/target/com.cognifide.aet.jobs-$AET_VERSION.jar"
    "core/runner/target/com.cognifide.aet.runner-$AET_VERSION.jar"
    "core/validation/target/com.cognifide.aet.validation-$AET_VERSION.jar"
    "core/worker/target/com.cognifide.aet.worker-$AET_VERSION.jar"
    "osgi-dependencies/proxy/target/com.cognifide.aet.proxy-$AET_VERSION.jar"
    "osgi-dependencies/selenium/target/com.cognifide.aet.selenium-$AET_VERSION.jar"
    "osgi-dependencies/w3chtml5validator/target/com.cognifide.aet.w3chtml5validator-$AET_VERSION.jar"
    "rest-endpoint/target/com.cognifide.aet.rest-endpoint-$AET_VERSION.jar"
    "test-executor/target/com.cognifide.aet.test-executor-$AET_VERSION.jar"
)

report="report/target/com.cognifide.aet.report-$AET_VERSION.zip"

features=(
    'osgi-dependencies/aet-features.xml'
    'osgi-dependencies/aet-webconsole.xml'
)

copy_bundles() {
    for artifact in "${bundles[@]}"; do
        rsync -av --stats --progress "$AET_REPO_PATH/$artifact" "$AET_DOCKER_PATH/bundles"
    done 
}

copy_report() {
    target_dir=$(dirname "$report")

    artifact=$report
    unzip -o "$AET_REPO_PATH/$artifact" -d "$AET_DOCKER_PATH/report"
    # rm -rf "$AET_REPO_PATH/$target_dir/*"
}

copy_features() {
    for artifact in "${features[@]}"; do
        rsync -av --stats --progress "$AET_REPO_PATH/$artifact" "$AET_DOCKER_PATH/features"
    done
}

fix_ownership() {
    sudo chown aet:aet -R $AET_DOCKER_PATH/*
}

main() {
    copy_bundles
    copy_report
    copy_features
    fix_ownership
}

main