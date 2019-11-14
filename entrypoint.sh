#!/bin/sh

set -e

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

LINT_BIN=/npm/node_modules/.bin

cd $GITHUB_WORKSPACE

$LINT_BIN/eslint --version
$LINT_BIN/tslint --version

$LINT_BIN/eslint -f="stylish" "${INPUT_LINT_DIRS:-'.'}" \
    | reviewdog -f="eslint" -reporter=github-pr-check

$LINT_BIN/tslint -p . -c tslint.json \
    | reviewdog -f="tslint" -reporter=github-pr-check
