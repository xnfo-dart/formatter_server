// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:grinder/grinder.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart' as yaml;

/// Matches the version line in formatter_server's pubspec.
final _versionPattern = RegExp(r'^version: .*$', multiLine: true);

void main(List<String> args) => grind(args);

@DefaultTask()
@Task("Run tests and analysis")
Future<void> validate() async
{
    // Test it.
    await TestRunner().testAsync();

    // Make sure it's warning clean.
    Analyzer.analyze('bin/listen.dart', fatalWarnings: true);

    // TODO(tekert): format once polisher exposes path format.
    // Format it.
    // Dart.run('bin/format.dart',
    // arguments: ['format', './benchmark/after.dart.txt', '-o', 'none']);

    // Check if we can get parse all dependencys versions used as constants.
/*  if (await getDependancyVersion("dart_style") == null)
    {
        throw "Cant parse all dependencys versions";
    }
*/
}

// Generate all files
@Task("Generate all protocol, integration tests matchers/methods, and API html doc.")
Future<void> generate() async
{
    Dart.run('tool/protocol_spec/generate.dart');
}

/// Gets ready to publish a new version of the package.
///
/// To publish a version, you need to:
///
///   1. Make sure the version in the pubspec is a "-dev" number. This should
///      already be the case since you've already landed patches that change
///      the formatter and bumped to that as a consequence.
///
///   2. Commit the change to develop and Tag it for candidate to release: vX.X.X-betaY.
///
///   3. Merge to master
///
///      git merge --no-commit <BETA_TAG>
///      dart run grinder bump
///      git commit -a
///         Version $THE_VERSION_BEING_BUMPED
///         Merge commit '#DEV_HASH_TO_BASE_RELEASE_OFF' into master
///
///   4. Tag the commit:
///
///         git tag -a "<version>" -m "<version>"
///         git push origin <version>
///
@Task("Bumps from dev to release version")
@Depends(generate, validate)
Future<void> bump() async
{
    // Read the version from the pubspec.
    var pubspecFile = getFile('pubspec.yaml');
    var pubspec = pubspecFile.readAsStringSync();
    var version = Version.parse((yaml.loadYaml(pubspec) as Map)['version'] as String);

    // Require a "-dev" version since we don't otherwise know what to bump it to.
    if (!version.isPreRelease) throw 'Cannot publish non-dev version $version.';

    // Don't allow versions like "1.2.3-dev+4" because it's not clear if the
    // user intended the "+4" to be discarded or not.
    if (version.build.isNotEmpty) throw 'Cannot publish build version $version.';

    var bumped = Version(version.major, version.minor, version.patch);

    // Update the version in the pubspec.
    pubspec = pubspec.replaceAll(_versionPattern, 'version: $bumped');
    pubspecFile.writeAsStringSync(pubspec);

    // Update the version constants in formatter_constants.dart.
    var versionFile = getFile('lib/src/constants.dart');
    var versionSource = versionFile.readAsStringSync();
    var versionReplaced = updateVersionConstant(versionSource, "SERVER_VERSION", bumped);
    versionFile.writeAsStringSync(versionReplaced);

    // Update the version in the CHANGELOG.
    // TODO(tekert): create bump header and move Unreleased header
    var changelogFile = getFile('CHANGELOG.md');
    var changelog = changelogFile
        .readAsStringSync()
        .replaceAll(version.toString(), bumped.toString());
    changelogFile.writeAsStringSync(changelog);

    log("Updated version to '$bumped'.");
}

String updateVersionConstant(String source, String constant, Version v)
{
    return source.replaceAll(RegExp("""const String $constant = "[^"]+";"""),
        """const String $constant = "$v";""");
}
