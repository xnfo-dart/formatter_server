// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

//import 'command_line_options_test.dart' as command_line_options_test;
import 'get_version_test.dart' as get_version_test;
import 'shutdown_test.dart' as shutdown_test;

void main()
{
    defineReflectiveSuite(()
    {
        //command_line_options_test.main(); //TODO(tekert)
        get_version_test.main();
        shutdown_test.main();
    }, name: 'server');
}
