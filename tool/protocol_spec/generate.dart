// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import './analyzer_utilities_pkg/tools.dart';
import 'package:path/path.dart';

import 'codegen_inttest_methods.dart' as codegen_inttest_methods;
import 'codegen_dart_protocol.dart' as codegen_dart_protocol;
import 'codegen_protocol_constants.dart' as codegen_protocol_constants;
import 'codegen_matchers.dart' as codegen_matchers;
import 'to_html.dart' as to_html;

/// Generate all targets.
void main() async
{
    var script = Platform.script.toFilePath(windows: Platform.isWindows);
    var pkgPath = normalize(join(dirname(script), '..', '..'));
    await GeneratedContent.generateAll(pkgPath, allTargets);
}

/// Get a list of all generated targets.
List<GeneratedContent> get allTargets
{
    var targets = <GeneratedContent>[];
    targets.add(codegen_inttest_methods.target);
    targets.add(codegen_matchers.target);
    //targets.add(codegen_dart_protocol.clientTarget(false));
    targets.add(codegen_dart_protocol.serverTarget(false));
    targets.add(codegen_protocol_constants.serverTarget);
    targets.add(to_html.target);
    return targets;
}
