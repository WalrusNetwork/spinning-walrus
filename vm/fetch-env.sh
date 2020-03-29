#!/usr/bin/env sh

cp info.example.yml info.yml

yq w -i info.yml base_args.GITLAB_OAUTH_TOKEN "$GITLAB_OAUTH_TOKEN"
yq w -i info.yml base_args.MAVEN_AUTHORIZATION_TOKEN "$MAVEN_AUTHORIZATION_TOKEN"
yq w -i info.yml base_args.VULTR_API_KEY "$VULTR_API_KEY"