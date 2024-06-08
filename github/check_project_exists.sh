#!/bin/bash

GITLAB_TOKEN=$1
GITLAB_GROUP_ID=$2
PROJECT_NAME=$3

# Check if the project exists
PROJECT_EXISTS=$(curl --silent --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.com/api/v4/projects?search=$PROJECT_NAME&namespace_id=$GITLAB_GROUP_ID" | jq -r '.[0].name == "'$PROJECT_NAME'"')

if [ "$PROJECT_EXISTS" = "true" ]; then
  echo "{\"result\": \"true\"}"
else
  echo "{\"result\": \"false\"}"
fi
