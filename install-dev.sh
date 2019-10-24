#!/bin/bash

# Set parameters
ORG_ALIAS="quiz-dev"

echo ""
echo "Installing Quiz org:"
echo "- Org alias:      $ORG_ALIAS"
echo ""

# Install script
echo "Cleaning previous scratch org..."
sfdx force:org:delete -p -u $ORG_ALIAS &> /dev/null
echo ""

echo "Creating scratch org..." && \
sfdx force:org:create -s -f config/project-scratch-def.json -a $ORG_ALIAS -d 30 && \
echo "" && \

echo "Pushing source..." && \
sfdx force:source:push -f -u $ORG_ALIAS && \
echo "" && \

echo "Assigning permissions..." && \
sfdx force:user:permset:assign -n Quiz_Admin -u $ORG_ALIAS && \
echo "" && \

echo "Importing data..." && \
sfdx force:data:tree:import -p data/plan.json -u $ORG_ALIAS && \
echo "" && \

echo "Generating user password..." && \
sfdx force:user:password:generate -u $ORG_ALIAS && \
echo ""

EXIT_CODE="$?"

# Check exit code
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Installation completed."
  echo ""
  sfdx force:org:open -p /lightning/setup/SecurityRemoteProxy/home -u $ORG_ALIAS
else
    echo "Installation failed."
fi

exit $EXIT_CODE
