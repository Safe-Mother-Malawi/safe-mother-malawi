#!/usr/bin/env node
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const root = __dirname;
const flutterDir = path.join(root, '.vercel-flutter');
const flutterBin = process.platform === 'win32'
  ? path.join(flutterDir, 'bin', 'flutter.bat')
  : path.join(flutterDir, 'bin', 'flutter');
const pubspecPath = path.join(root, 'pubspec.yaml');
const webPubspecPath = path.join(root, 'pubspec_web.yaml');
const backupPath = path.join(root, 'pubspec.yaml.bak');

function run(command) {
  execSync(command, { cwd: root, stdio: 'inherit' });
}

function quote(value) {
  return `"${value}"`;
}

function restorePubspec() {
  if (fs.existsSync(backupPath)) {
    fs.copyFileSync(backupPath, pubspecPath);
    fs.unlinkSync(backupPath);
  }
}

function installFlutterIfNeeded() {
  if (fs.existsSync(flutterBin)) {
    return;
  }

  if (fs.existsSync(flutterDir)) {
    throw new Error(
      `${flutterDir} exists but ${flutterBin} is missing. Delete .vercel-flutter and rebuild.`,
    );
  }

  console.log('Installing Flutter stable for this build...');
  run(`git clone https://github.com/flutter/flutter.git -b stable --depth 1 ${quote(flutterDir)}`);
}

function writeBuildStamp() {
  const commit = process.env.VERCEL_GIT_COMMIT_SHA
    || execSync('git rev-parse HEAD', { cwd: root }).toString().trim();
  const branch = process.env.VERCEL_GIT_COMMIT_REF
    || execSync('git branch --show-current', { cwd: root }).toString().trim();
  const stamp = {
    commit,
    branch,
    builtAt: new Date().toISOString(),
  };

  fs.mkdirSync(path.join(root, 'build', 'web'), { recursive: true });
  fs.writeFileSync(
    path.join(root, 'build', 'web', 'build-stamp.json'),
    `${JSON.stringify(stamp, null, 2)}\n`,
  );
  console.log(`Build stamp: ${branch} @ ${commit.slice(0, 7)}`);
}

console.log('Building Safe Mother Malawi web app...');

try {
  if (!fs.existsSync(webPubspecPath)) {
    throw new Error('pubspec_web.yaml is missing.');
  }

  installFlutterIfNeeded();

  run(`${quote(flutterBin)} config --no-analytics`);

  console.log('Using web pubspec...');
  restorePubspec();
  fs.copyFileSync(pubspecPath, backupPath);
  fs.copyFileSync(webPubspecPath, pubspecPath);

  console.log('Installing Flutter dependencies...');
  run(`${quote(flutterBin)} pub get`);

  console.log('Building Flutter web release...');
  run(`${quote(flutterBin)} build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true`);

  restorePubspec();
  writeBuildStamp();

  console.log('Web build completed successfully.');
} catch (error) {
  restorePubspec();
  console.error(`Build failed: ${error.message}`);
  process.exit(1);
}
