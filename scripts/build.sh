#!/usr/bin/env bash
# build.sh - builds the devops-tool image and runs smoke tests

set -u
IMAGE="devops-tool"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

echo "===== Build ====="
if docker build -t "$IMAGE" . >/tmp/build.log 2>&1; then
  pass "Docker image builds successfully"
else
  fail "Docker image failed to build"
  cat /tmp/build.log
fi

echo
echo "===== Smoke tests ====="

if docker run --rm "$IMAGE" help >/tmp/smoke-help.log 2>&1; then
  pass "help smoke test passes"
else
  fail "help smoke test failed"
  cat /tmp/smoke-help.log
fi

if docker run --rm "$IMAGE" system-info >/tmp/smoke-system.log 2>&1; then
  pass "system-info smoke test passes"
else
  fail "system-info smoke test failed"
  cat /tmp/smoke-system.log
fi

# Invalid command must fail
docker run --rm "$IMAGE" invalid-command >/tmp/smoke-invalid.log 2>&1
rc=$?
if [[ $rc -ne 0 ]]; then
  pass "invalid command returns non-zero (exit $rc)"
else
  fail "invalid command should return non-zero"
fi

echo
echo "===== Results ====="
echo "Passed: $PASS"
echo "Failed: $FAIL"
[[ $FAIL -eq 0 ]]
