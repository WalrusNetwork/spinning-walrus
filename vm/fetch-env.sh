#!/usr/bin/env sh

cp info.example.yml info.yml

yq w -i info.yml base_args.GITLAB_OAUTH_TOKEN "$GITLAB_OAUTH_TOKEN"
yq w -i info.yml base_args.MAVEN_AUTHORIZATION_TOKEN "$NEXUS_NEW_DEPLOY_KEY"
yq w -i info.yml base_args.VULTR_API_KEY "$VULTR_API_KEY"
yq w -i info.yml base_args.GRAPHQL_TOKEN "$GRAPHQL_TOKEN"