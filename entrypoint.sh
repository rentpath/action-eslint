#!/bin/sh

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

npm install -g \
  @rentpath/eslint-config-rentpath@3.0.1 \
  eslint@5.12.1 \
  eslint-import-resolver-alias@1.1.2 \
  eslint-plugin-mocha@5.2.1 \
  eslint-plugin-standard@4.0.1 \
  tslint@5.20.0 \
  tslint-import-group-ordering@2.1.1 \
  tslint-lines-between-class-members@1.2.4 \
  tslint-no-circular-imports@0.7.0

eslint --version
tslint --version

eslint -f="stylish" "${INPUT_LINT_DIRS:-'.'}" \
    | reviewdog -f="eslint" -reporter=github-pr-check

tslint -p . -c tslint.json \
    | reviewdog -f="tslint" -reporter=github-pr-check
