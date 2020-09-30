#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH

version="l"
if [ "$#" -eq 1 ]; then
  version="$1"
else
  echo "Missing project version argument"
  exit -1
fi

cd ..
# Update node package
sed -E -i '' -e "s|\"version\": \"[0-9]+\.[0-9]+\.[0-9]+\",|\"version\": \"$version\",|" package.json && \
# Update UI
sed -E -i '' -e "s|HOST_APP_VERSION = '[0-9]+\.[0-9]+\.[0-9]+';|HOST_APP_VERSION = '$version';|" src/main/default/lwc/gameApp/gameApp.js && \
# Update DX Project config
sed -E -i '' -e "s|\"versionName\": \"ver [0-9]+\.[0-9]+\.[0-9]+\"|\"versionName\": \"ver $version\"|" sfdx-project.json && \
sed -E -i '' -e "s|\"versionNumber\": \"[0-9]+\.[0-9]+\.[0-9]+\.NEXT\"|\"versionNumber\": \"$version.NEXT\"|" sfdx-project.json && \
npm install
# Stage changed files
git add package.json package-lock.json sfdx-project.json src/main/default/lwc/gameApp/gameApp.js

EXIT_CODE="$?"

# Check exit code
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "Version set to $version"
else
    echo "Failed to set version $version"
fi
exit $EXIT_CODE
