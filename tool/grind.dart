// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:grinder/grinder.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:path/path.dart' as p;

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

    // TODO(tekert): format by running dart_polisher bin/format.dart from dependency.
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

@Task("Validation for use in continuous integration")
Future<void> validateCI() async
{
    // Test it.
    await TestRunner().testAsync();

    // Make sure it's warning clean.
    Analyzer.analyze('bin/listen.dart', fatalWarnings: true);

    // Style is applied when bumping.
}

// Generate all files
@Task("Generate all protocols, integration tests (matchers/methods), and API doc.")
Future<void> generate() async
{
    Dart.run('tool/protocol_spec/generate.dart');
}

// TODO: check the constant version too, return error if they mismatch.
@Task("Print the pubspec[version] attribute")
Future<void> version() async
{
    // Get pubspec executable targets names
    var pubspecFile = getFile('pubspec.yaml');
    var pubspec = pubspecFile.readAsStringSync();
    var pubspecMap = yaml.loadYaml(pubspec) as yaml.YamlMap;
    var version = Version.parse(pubspecMap["version"] as String);

    print(version);
}

@Task('Compile to native, --output=<filename> '
    '(all paths are relative to ./build directory)')
//@Depends(validateCI)
Future<void> build() async
{
    TaskArgs args = context.invocation.arguments;
    var outName = args.getOption("output");
    var verbose = !args.getFlag("quiet");

    // Get base normalized output Dir and File name from input.
    var outPath = FilePath(outName);
    if (outPath.parent != null) outName = outPath.name;
    var basePath = outPath.parent?.path ?? "";
    var outDirPath = p.normalize(joinDir(buildDir, [basePath]).path);
    var outDir = getDir(outDirPath);

    // Get pubspec executable targets names
    var pubspecFile = getFile('pubspec.yaml');
    var pubspec = pubspecFile.readAsStringSync();
    var pubspecMap = yaml.loadYaml(pubspec) as yaml.YamlMap;
    var pubspecExecutables = pubspecMap["executables"] as yaml.YamlMap;
    var defaultOutName = pubspecExecutables.keys
        .firstWhere((k) => pubspecExecutables[k] == 'listen', orElse: () => null);
    // Use default name from pubspec if not given
    outName ??= defaultOutName as String?;

    // Setup file output to compile
    FilePath(outDir).createDirectory(recursive: true);
    var outFile = joinFile(outDir, [outName!]);
    var binFile = joinFile(binDir, ["listen.dart"]);

    // There should be a Dart Compile method but there is not, so we run it manually.
    // (dart compile "-v" flag is not in help messages)
    run(dartVM.path,
        arguments: [
            "compile",
            "exe",
            binFile.path,
            "-o",
            outFile.path,
            verbose ? "-v" : "--verbosity=error"
        ],
        quiet: !verbose);
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
