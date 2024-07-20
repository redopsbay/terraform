#!/bin/bash

set -eo pipefail

### Check if pre-commit is available in your machine

which pre-commit >> /dev/null && export IS_PRECOMMIT_AVAILABLE="0"
if [[ "$IS_PRECOMMIT_AVAILABLE" != "0" ]]; then
  echo "[FAILED]: pre-commit cli is not available"
  echo "To install it, type: pip3 install pre-commit"
else
  echo "[OK]: pre-commit cli found!"
  if test -f "../.git/hooks/pre-commit"; then
    echo "[OK] File .git/hooks/pre-commit exists!"
  else
    echo "[INFO] Installing pre-commit script...."
    pushd ../ >> /dev/null && pre-commit install && popd >> /dev/null
  fi

fi

### Check if terraform-docs is available in your machine

which terraform-docs >> /dev/null && export IS_TERRAFORM_DOCS_AVAILABLE="0"
if [[ "$IS_TERRAFORM_DOCS_AVAILABLE" != "0" ]]; then
  echo "[FAILED]: terraform-docs command not available"
  echo -e "To install it, type: wget --verbose https://github.com/terraform-docs/terraform-docs/releases/download/v0.17.0/terraform-docs-v0.17.0-linux-amd64.tar.gz -O /tmp/terraform-docs.tar.gz \n"
  echo "tar xf /tmp/terraform-docs.tar.gz && sudo install terraform-docs /usr/local/bin/terraform-docs"
else
  echo "[FOUND]: terraform-docs comand found!"
  if test -f "/usr/local/bin/terraform-docs"; then
    echo "[OK] File /usr/local/bin/terraform-docs exists!"
  else
    echo "[WARNING] ensure that terraform-docs is located at executable path /usr/local/bin/terraform-docs"
  fi
fi