// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

//! NOTE: Ported from package:analyzer_utilities/tools.dart
import './analyzer_utilities_tools_hook.dart';

import 'package:path/path.dart';
import 'generate.dart';

/// Check that all targets have been code generated.  If they haven't tell the
/// user to run generate.dart.
void main() async
{
    var script = Platform.script.toFilePath(windows: Platform.isWindows);
    var components = split(script);
    var index = components.indexOf('analysis_server');
    var pkgPath = joinAll(components.sublist(0, index + 1));
    await GeneratedContent.checkAll(
        pkgPath, join(pkgPath, 'tool', 'protocol_spec', 'generate.dart'), allTargets);
}
