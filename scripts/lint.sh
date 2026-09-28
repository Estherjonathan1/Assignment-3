#!/usr/bin/env bash
# lint.sh - checks required files exist and validates Bash syntax

set -u
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

echo "===== Lint ====="

for f in README.md app/app.sh scripts/lint.sh scripts/build.sh tests/test.sh Dockerfile compose.yaml .dockerignore .github/workflows/ci.yml; do
  [[ -f "$f" ]] && pass "Required file exists: $f" || fail "Missing required file: $f"
done

for f in app/*.sh scripts/*.sh tests/*.sh; do
  [[ -f "$f" ]] || continue
  bash -n "$f" >/dev/null 2>&1 && pass "Bash syntax: $f" || fail "Bash syntax error: $f"
done

if command -v shellcheck >/dev/null 2>&1; then
  for f in app/*.sh scripts/*.sh tests/*.sh; do
    [[ -f "$f" ]] || continue
    if shellcheck "$f" >/tmp/shellcheck-"$(basename "$f")".log 2>&1; then
      pass "ShellCheck: $f"
    else
      echo "WARN: ShellCheck found issues in $f (not counted as a failure)"
      cat /tmp/shellcheck-"$(basename "$f")".log
    fi
  done
else
  echo "INFO: shellcheck not installed, skipping extra static analysis"
fi

echo
echo "Passed: $PASS"
echo "Failed: $FAIL"
[[ $FAIL -eq 0 ]]
