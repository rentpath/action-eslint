#!/bin/sh

set -e

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

LINT_BIN=/npm/node_modules/.bin

cd $GITHUB_WORKSPACE

$LINT_BIN/eslint --version
$LINT_BIN/tslint --version

if [ "${INPUT_TSLINT}" == 'true' ]; then
  $LINT_BIN/tslint -p . -c tslint.json -t  \
    | reviewdog -f="tslint" -reporter=github-pr-check

  if [ "${INPUT_REPORTER}" == 'github-pr-review' ]; then
    # Use jq and github-pr-review reporter to format result to include link to rule page.
    $LINT_BIN/tslint -p "${INPUT_LINT_DIRS:-'.'}" -c "${INPUT_STYLELINT_CONFIG:-tslint.json}" -f json \
      | jq -r '.[] | {filePath: .filePath, messages: .messages[]} | "\(.filePath):\(.messages.line):\(.messages.column):\(.messages.message) [\(.messages.ruleId)](https://eslint.org/docs/rules/\(.messages.ruleId))"' \
      | reviewdog -efm="%f:%l:%c:%m" -name="${INPUT_NAME}:-tslint}" -reporter=github-pr-review -level="${INPUT_LEVEL}"
  else
    $LINT_BIN/tslint -t="stylish" -p "${INPUT_LINT_DIRS:-'.'}" -c "${INPUT_STYLELINT_CONFIG:-tslint.json}" --config="${INPUT_ESLINT_CONFIG}" \
      | reviewdog -f="eslint" -name="${INPUT_NAME:-tslint}" -reporter="${INPUT_REPORTER:-github-pr-check}" -level="${INPUT_LEVEL}"
  fi
else
  if [ "${INPUT_REPORTER}" == 'github-pr-review' ]; then
    # Use jq and github-pr-review reporter to format result to include link to rule page.
    $LINT_BIN/eslint "${INPUT_STYLELINT_IGNORE}" "${INPUT_LINT_DIRS:-'.'}" --config="${INPUT_STYLELINT_CONFIG}" -f json \
      | jq -r '.[] | {filePath: .filePath, messages: .messages[]} | "\(.filePath):\(.messages.line):\(.messages.column):\(.messages.message) [\(.messages.ruleId)](https://eslint.org/docs/rules/\(.messages.ruleId))"' \
      | reviewdog -efm="%f:%l:%c:%m" -name="${INPUT_NAME}:-eslint}" -reporter=github-pr-review -level="${INPUT_LEVEL}"
  else
    $LINT_BIN/eslint -f="stylish" "${INPUT_LINT_DIRS:-'.'}" --config="${INPUT_ESLINT_CONFIG}" \
      | reviewdog -f="eslint" -name="${INPUT_NAME:-eslint}" -reporter="${INPUT_REPORTER:-github-pr-check}" -level="${INPUT_LEVEL}"
  fi
fi

