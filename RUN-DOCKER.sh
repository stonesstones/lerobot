#!/bin/bash

################################################################################
source .env.local
# Set the Docker container name from a project name (first argument).
# If no argument is given, use the current user name as the project name.
if [ -z "$PROJECT" ]; then
  echo "Set PROJECT (e.g. 'export PROJECT=mytest')"
  exit 1
fi
PROJECT=$PROJECT
CONTAINER="${PROJECT}-lerobot"
export HOSTNAME=$(hostname)
export CONTAINER=$CONTAINER  # Export the container name for docker compose to coherently set container name.

# タグが指定されていない場合は "latest" をデフォルトとする（ビルド済みのイメージと合わせる）
if [ -z "$IMAGE_TAG" ]; then
  export IMAGE_TAG=latest
fi

# データセットのパスを指定する
if [ -z "$DATASET_PATH" ]; then
  export DATASET_PATH=$(pwd)/datasets
  echo "DATASET_PATH is not set. Set DATASET_PATH to $DATASET_PATH"
fi

echo "$0: PROJECT=${PROJECT}"
echo "$0: CONTAINER=${CONTAINER}"
echo "$0: Using image tag: ${DEEP_IMAGE_TAG}"

# Run the Docker container in the background.
# Any changes made to './docker/docker-compose.yml' will recreate and overwrite the container.
docker compose -p ${PROJECT} -f ./docker/docker-compose.yml up -d

# Display GUI through X Server by granting full access to any external client.
xhost +

# Enter the Docker container with a Bash shell (with or without a custom 'roslaunch' command).
case "$2" in
  ( "" )
    docker exec -i -t ${CONTAINER} bash
    ;;
  ( * )
    echo "Failed to enter the Docker container '${CONTAINER}': '$2' is not a valid argument value."
    ;;
esac
