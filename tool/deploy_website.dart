#!/usr/bin/env dart
// Deploy helper tailored for this repository.
// - merges a source branch into a target branch
// - pushes the target branch
// - runs an optional assets sync step and commits any changes to the source
//
// Usage:
//   dart tool/deploy_website.dart [--target BRANCH] [--source BRANCH] [--message MSG] [--assets-dir PATH]
// Defaults: --target deploy-example --source main --assets-dir example/build/web

import 'dart:io';

const _postDeployCommitMessage =
    'chore: sync website asset hash with CHANGELOG';

void main(List<String> args) {
  var target = 'deploy-example';
  var source = 'main';
  var assetsDir = 'example/build/web';
  String? message;
  var showHelp = false;

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--target') {
      _requireNext(args, i);
      target = args[++i];
      continue;
    }
    if (arg == '--source') {
      _requireNext(args, i);
      source = args[++i];
      continue;
    }
    if (arg == '--message') {
      _requireNext(args, i);
      message = args[++i];
      continue;
    }
    if (arg == '--assets-dir') {
      _requireNext(args, i);
      assetsDir = args[++i];
      continue;
    }
    if (arg == '-h' || arg == '--help') {
      showHelp = true;
      continue;
    }
    stderr.writeln('error: unknown argument: $arg');
    exit(1);
  }

  if (showHelp) {
    stdout.writeln('''
Usage: dart tool/deploy_website.dart [--target BRANCH] [--source BRANCH] [--message MSG] [--assets-dir PATH]

Options:
  --target BRANCH   Branch to merge into (default: deploy-example).
  --source BRANCH   Branch to merge from (default: main).
  --message MSG     Merge commit message (default: "Merge <source> into <target>").
  --assets-dir PATH Directory with built web assets to check for post-deploy changes (default: example/build/web).

After the target branch is pushed, the script checks out <source> and
creates a local commit only if the files under <assets-dir> changed. The
post-deploy commit message defaults to:
  $_postDeployCommitMessage
''');
    return;
  }

  message ??= 'Merge $source into $target';

  final repoRoot = Directory(Platform.script.toFilePath()).parent.parent;
  if (!Directory(repoRoot.path).existsSync()) {
    stderr.writeln('error: cannot determine repository root');
    exit(1);
  }

  stdout.writeln("Deploying website: merging '$source' into '$target'");

  _git(['fetch', '--all']);
  _git(['checkout', target]);
  _git(['merge', '--no-ff', source, '-m', message]);
  _git(['push', 'origin', target]);
  _git(['checkout', source]);

  final syncResult = _syncWebsiteAssetHashes(repoRoot, assetsDir);
  if (syncResult.createdCommit) {
    stdout.writeln(
      "Created local commit on '$source' to sync website asset hashes.",
    );
  } else {
    stdout.writeln(
      "No asset changes detected under '$assetsDir'; no commit created.",
    );
  }

  stdout.writeln('Deploy complete.');
}

class _PostDeploySyncResult {
  const _PostDeploySyncResult({required this.createdCommit});
  final bool createdCommit;
}

_PostDeploySyncResult _syncWebsiteAssetHashes(
  Directory repoRoot,
  String assetsDir,
) {
  stdout.writeln('Syncing website asset hashes (if applicable)...');

  // Check for changed files under the assets directory.
  final changedOutput = _gitOutput(['status', '--porcelain', '--', assetsDir]);
  final changedFiles =
      changedOutput
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .map((line) => line.substring(line.indexOf(' ') + 1).trim())
          .toList();

  if (changedFiles.isEmpty) {
    return const _PostDeploySyncResult(createdCommit: false);
  }

  _git(['add', '--', ...changedFiles]);
  _git(['commit', '-m', _postDeployCommitMessage, '--', ...changedFiles]);

  return const _PostDeploySyncResult(createdCommit: true);
}

void _requireNext(List<String> args, int i) {
  if (i + 1 >= args.length) {
    stderr.writeln('error: ${args[i]} requires a value');
    exit(1);
  }
}

void _git(List<String> gitArgs) {
  final result = Process.runSync('git', gitArgs);
  if (result.stdout.toString().isNotEmpty) stdout.write(result.stdout);
  if (result.stderr.toString().isNotEmpty) stderr.write(result.stderr);
  if (result.exitCode != 0) {
    stderr.writeln(
      'error: git ${gitArgs.join(' ')} exited with ${result.exitCode}',
    );
    exit(result.exitCode);
  }
}

String _gitOutput(List<String> gitArgs) {
  final result = Process.runSync('git', gitArgs);
  if (result.stderr.toString().isNotEmpty) stderr.write(result.stderr);
  if (result.exitCode != 0) {
    stderr.writeln(
      'error: git ${gitArgs.join(' ')} exited with ${result.exitCode}',
    );
    exit(result.exitCode);
  }
  return result.stdout.toString();
}
