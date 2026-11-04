#!/bin/sh
# Travis archives job logs asynchronously, minutes behind the live job. A job
# that finishes before its archive has caught up publishes a log cut off
# before the Gradle test results. Hold the job open until its own archived log
# (public v3 API) shows Gradle's final BUILD line. Capped at 40 minutes;
# after_script never changes the build result.
url="https://api.travis-ci.com/v3/job/${TRAVIS_JOB_ID}/log.txt"
i=0
while [ "$i" -lt 120 ]; do
  if curl -fsS "$url" 2>/dev/null | grep -Eq 'BUILD (SUCCESSFUL|FAILED) in [0-9]'; then
    echo "archived log contains the Gradle result after $((i * 20))s"
    exit 0
  fi
  i=$((i + 1))
  sleep 20
done
echo "archived log still incomplete after 40 minutes"
