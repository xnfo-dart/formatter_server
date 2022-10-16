import 'dart:io' as io;

import 'package:grinder/grinder.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart' as yaml;

// Prints the pubspec version key.
void main()
{
    // Get pubspec executable targets names
    var pubspecFile = getFile('pubspec.yaml');
    var pubspec = pubspecFile.readAsStringSync();
    var pubspecMap = yaml.loadYaml(pubspec) as yaml.YamlMap;
    var version = Version.parse(pubspecMap["version"] as String);

    io.stdout.write(version);
}
