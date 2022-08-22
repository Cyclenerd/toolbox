#!/bin/bash

# Add GitHub template stuff later

cp -R ../template/.github/ISSUE_TEMPLATE .github/ && \
git add . && \
git commit -m "issue template" && echo "DONE"

cp ../template/CODE_OF_CONDUCT.md CODE_OF_CONDUCT.md && \
git add . && \
git commit -m "code of conduct" && echo "DONE"

cp ../template/CONTRIBUTING.md . && \
git add . && \
git commit -m "contributing" && echo "DONE"

cp ../template/.github/PULL_REQUEST_TEMPLATE.md .github/ && \
git add . && \
git commit -m "pull template" && echo "DONE"