#!/usr/bin/env bash
set -euo pipefail

# Defaults, if not set
: "${FLAKIFY_URI:=github:thelonelyghost/workstation-deps-nix}"
: "${FLAKIFY_TEMPLATE:=flakify}"

if git rev-parse --git-dir &>/dev/null; then
  IS_GIT_DIR=yep
else
  IS_GIT_DIR=
fi

TEMPDIR="$(mktemp -d)"
# shellcheck disable=SC2064
trap "rm -rf '${TEMPDIR}'" EXIT

pushd "${TEMPDIR}" &>/dev/null
nix flake init -t "${FLAKIFY_URI}#${FLAKIFY_TEMPLATE}"
popd &>/dev/null

if ! [ -e ./flake.nix ]; then
  cp "${TEMPDIR}"/flake.{nix,lock} ./
  if [ -n "${IS_GIT_DIR}" ]; then
    git add -f -N ./flake.nix ./flake.lock
  fi
fi

if ! [ -e ./default.nix ]; then
  cp "${TEMPDIR}"/default.nix ./
  if [ -n "${IS_GIT_DIR}" ]; then
    git add -f -N ./default.nix
  fi
fi

if ! grep -qFe 'use flake' .envrc &>/dev/null; then
  cat "${TEMPDIR}"/.envrc >> ./.envrc
  direnv allow .
fi

if [ -n "${EDITOR:-}" ]; then
  "${EDITOR}" ./flake.nix
else
  printf '\n\tWARNING: missing variable %q\n\n' "EDITOR" >&2
fi
