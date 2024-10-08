#!/bin/bash

# Set parameters
ORG_ALIAS="quiz"
DATA="sample"

if [ "$#" -eq 1 ]; then
  ORG_ALIAS=$1
else if [ "$#" -eq 2 ]; then
    ORG_ALIAS=$1
    DATA=$2
  fi
fi


echo ""
echo "Installing Quiz org:"
echo "- Org alias:      $ORG_ALIAS"
echo "- Data:           $DATA"
echo ""

# Install script
echo "Cleaning previous scratch org..."
sf org delete scratch -p -o $ORG_ALIAS &> /dev/null
echo ""

echo "Creating scratch org..." && \
sf org create scratch -f config/project-scratch-def.json -a $ORG_ALIAS -d -y 30 --no-ancestors --no-namespace && \
echo "" && \

echo "Pushing source..." && \
sf project deploy start && \
echo "" && \

echo "Assigning permission sets..." && \
sf org assign permset -n Quiz_Host && \
echo "" && \

echo "Importing data..." && \
sf data tree import -p data/$DATA/plan.json && \
echo "" && \

echo "Generating user password..." && \
sf org generate password && \
echo "" && \

echo "Opening org..." && \
sf org open -p lightning/setup/SecurityRemoteProxy/home && \
echo ""

EXIT_CODE="$?"

# Check exit code
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Installation completed."
else
    echo "Installation failed."
fi
exit $EXIT_CODE
