#!/usr/bin/env bash
# test.sh - tests for app/app.sh
# Covers: help, system-info, invalid command, missing host, valid host,
# missing port, non-numeric port, out-of-range port.

set -u
APP="./app/app.sh"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

echo "===== Testing app.sh ====="

# 1. help
if "$APP" help >/tmp/test1.log 2>&1; then
  grep -qi "Commands:" /tmp/test1.log && pass "help shows usage" || fail "help output missing usage text"
else
  fail "help command failed"
fi

# 2. system-info
if "$APP" system-info >/tmp/test2.log 2>&1; then
  grep -qi "Hostname:" /tmp/test2.log && pass "system-info shows system details" || fail "system-info output missing expected fields"
else
  fail "system-info command failed"
fi

# 3. invalid command
"$APP" bogus >/tmp/test3.log 2>&1
rc=$?
[[ $rc -eq 2 ]] && pass "invalid command returns exit code 2" || fail "invalid command should return exit code 2 (got $rc)"

# 4. missing host
"$APP" check-host >/tmp/test4.log 2>&1
rc=$?
[[ $rc -eq 2 ]] && pass "check-host with missing host returns exit code 2" || fail "check-host with missing host should return exit code 2 (got $rc)"

# 5. valid host
"$APP" check-host localhost >/tmp/test5.log 2>&1
rc=$?
[[ $rc -eq 0 ]] && pass "check-host localhost succeeds" || fail "check-host localhost should succeed (got $rc)"

# 6. missing port
"$APP" check-port localhost >/tmp/test6.log 2>&1
rc=$?
[[ $rc -eq 2 ]] && pass "check-port with missing port returns exit code 2" || fail "check-port with missing port should return exit code 2 (got $rc)"

# 7. non-numeric port
"$APP" check-port localhost abc >/tmp/test7.log 2>&1
rc=$?
[[ $rc -eq 2 ]] && pass "check-port with non-numeric port returns exit code 2" || fail "check-port with non-numeric port should return exit code 2 (got $rc)"

# 8. out-of-range port
"$APP" check-port localhost 99999 >/tmp/test8.log 2>&1
rc=$?
[[ $rc -eq 2 ]] && pass "check-port with out-of-range port returns exit code 2" || fail "check-port with out-of-range port should return exit code 2 (got $rc)"

echo
echo "===== Results ====="
echo "Passed: $PASS"
echo "Failed: $FAIL"
[[ $FAIL -eq 0 ]]
