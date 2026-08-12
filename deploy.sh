#!/usr/bin/env bash
# Publish ~/Documents/website to https://davidgaut.github.io
# Run from this folder:  bash deploy.sh
set -euo pipefail

REPO="davidgaut.github.io"
USER="davidgaut"
cd "$(dirname "$0")"

if ! command -v git >/dev/null || ! command -v gh >/dev/null; then
  echo "Missing tooling. Install first (asks for your password):"
  echo "  sudo apt update && sudo apt install -y git gh"
  exit 1
fi

if ! git config --global user.email >/dev/null 2>&1; then
  git config --global user.name "David Gauthier"
  git config --global user.email "david.victor.gauthier@gmail.com"
  echo "Set global git identity."
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Not signed in to GitHub. Run this once, then re-run deploy.sh:"
  echo "  gh auth login"
  exit 1
fi

if [ ! -d .git ]; then
  git init -q -b main
  git add .
  git commit -qm "Personal site"
  echo "Repo initialised."
else
  git add .
  git diff --cached --quiet || git commit -qm "Update site"
fi

if gh repo view "$USER/$REPO" >/dev/null 2>&1; then
  git push -q origin main
else
  gh repo create "$REPO" --public --source=. --remote=origin --push
fi

# Enable Pages from main / root. Harmless if already enabled.
gh api -X POST "repos/$USER/$REPO/pages" \
  -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 \
  || echo "Pages may already be enabled — check Settings -> Pages."

echo
echo "Done. Live shortly at https://$USER.github.io"
echo "First build takes about a minute."
