#!/bin/bash
echo ""

if [ "$#" -eq 1 ]; then
  echo "Live debug for org $1"
  echo ""
  sfdx force:apex:log:tail -c -u $1
else
  if [ "$#" -eq 2 ]; then
    echo "Live debug for org $1 with $2 filter"
    echo ""
    sfdx force:apex:log:tail -c -u $1 | grep $2
  else
    echo "Usage: live-debug.sh ORG_ALIAS [FILTER]"
    echo "  ORG_ALIAS     Salesforce DX org alias (e.g: quiz-dev)"
    echo "  FILTER        Filters applied to log messages (e.g: USER_DEBUG)"
    echo ""
    exit -1
  fi
fi