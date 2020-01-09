const replace = require('replace-in-file');

const SEMVER_REGEX = '[0-9]+.[0-9]+.[0-9]+';

const version = process.argv[2];

if (!version || !RegExp(SEMVER_REGEX).test(version)) {
    console.log(
        `Provided version string '${version}' does not have semver format (x.y.z).`
    );
    process.exit(1);
}
console.log(`Setting project version to ${version}`);

replace.sync({
    files: '../src/main/default/lwc/gameApp/gameApp.js',
    from: new RegExp(`HOST_APP_VERSION = \'${SEMVER_REGEX}\';`),
    to: `HOST_APP_VERSION = '${version}';`
});

replace.sync({
    files: ['../package.json', '../package-lock.json'],
    from: new RegExp(`^    "version": \"${SEMVER_REGEX}\",`, 'm'),
    to: `    "version": "${version}",`
});

console.log('Done.');
