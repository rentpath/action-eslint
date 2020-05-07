#!/bin/sh

set -e

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

cd $GITHUB_WORKSPACE

npm install

if [ "${INPUT_TSLINT}" == 'true' ]; then
  npm install -g tslint@$(jq -r '.dependencies.eslint // .devDependencies.tslint | gsub("[\\^\\~]"; "")' package.json)
  tslint --version

  if [ "${INPUT_REPORTER}" == 'github-pr-review' ]; then
    # Use jq and github-pr-review reporter to format result to include link to rule page.
    tslint --project ${INPUT_LINT_DIRS:-'.'} --config "${INPUTLINT_CONFIG:-tslint.json}" --format json \
      | jq -r '.[] | {filePath: .filePath, messages: .messages[]} | "\(.filePath):\(.messages.line):\(.messages.column):\(.messages.message) [\(.messages.ruleId)](https://eslint.org/docs/rules/\(.messages.ruleId))"' \
      | reviewdog -efm="%f:%l:%c:%m" -name="${INPUT_NAME}:-tslint}" -reporter=github-pr-review -level="${INPUT_LEVEL}"
  else
    tslint --format="stylish" --project ${INPUT_LINT_DIRS:-'.'} --config "${INPUT_LINT_CONFIG:-tslint.json}" \
      | reviewdog -f="tslint" -name="${INPUT_NAME:-tslint}" -reporter="${INPUT_REPORTER:-github-pr-check}" -level="${INPUT_LEVEL}"
  fi
else
  npm install -g eslint@$(jq -r '.dependencies.eslint // .devDependencies.eslint | gsub("[\\^\\~]"; "")' package.json)
  eslint --version

  if [ "${INPUT_REPORTER}" == 'github-pr-review' ]; then
    # Use jq and github-pr-review reporter to format result to include link to rule page.
    eslint ${INPUT_LINT_DIRS:-'.'} --ext="${INPUT_LINT_EXT}" --config "${INPUT_LINT_CONFIG}" -f json \
      | jq -r '.[] | {filePath: .filePath, messages: .messages[]} | "\(.filePath):\(.messages.line):\(.messages.column):\(.messages.message) [\(.messages.ruleId)](https://eslint.org/docs/rules/\(.messages.ruleId))"' \
      | reviewdog -efm="%f:%l:%c:%m" -name="${INPUT_NAME}:-eslint}" -reporter=github-pr-review -level="${INPUT_LEVEL}"
  else
    eslint ${INPUT_LINT_DIRS:-'.'} --ext="${INPUT_LINT_EXT}" --config "${INPUT_LINT_CONFIG}" \
      | reviewdog -f="eslint" -name="${INPUT_NAME:-eslint}" -reporter="${INPUT_REPORTER:-github-pr-check}" -level="${INPUT_LEVEL}"
  fi
fi

