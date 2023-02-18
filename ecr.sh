#!/bin/sh -
REPO_NAME="nginx1"
REPO_ARN=$(aws ecr describe-repositories --repository-name ${REPO_NAME} --query "repositories[].repositoryArn" --output text 2>&1)
if [[ "$REPO_ARN" == *"RepositoryNotFoundException"* ]]; then
  REPO_ARN=$(aws ecr create-repository --repository-name ${REPO_NAME} --query "repository.repositoryArn" --output text 2>&1)  
fi

echo ${REPO_ARN}

