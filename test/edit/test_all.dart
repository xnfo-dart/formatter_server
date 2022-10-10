// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

//import 'format_if_enabled_test.dart' as format_if_enabled;
import 'format_test.dart' as format;

void main()
{
    defineReflectiveSuite(()
    {
        format.main();
        //format_if_enabled.main();
    }, name: 'edit');
}
