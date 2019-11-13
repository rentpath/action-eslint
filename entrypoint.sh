#!/bin/sh

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ ! -f "$(npm bin)/eslint" ]; then
    yarn install
fi

$(yarn bin)/eslint --version
$(yarn bin)/tslint --version

$(yarn bin)/eslint -f="stylish" "${INPUT_LINT_DIRS:-'.'}" \
    | reviewdog -f="eslint" -reporter=github-pr-check

$(yarn bin)/tslint -p . -c tslint.json \
    | reviewdog -f="tslint" -reporter=github-pr-check
