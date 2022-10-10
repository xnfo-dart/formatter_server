// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../tool/protocol_spec/check_all_test.dart' as check_spec;
import 'analysis/test_all.dart' as analysis;
import 'channel/test_all.dart' as channel;
import 'domain_server_test.dart' as domain_server;
import 'edit/test_all.dart' as edit;
import 'protocol_test.dart' as protocol;
import 'socket_server_test.dart' as socket_server;

void main()
{
    defineReflectiveSuite(()
    {
        analysis.main();
        channel.main();
        domain_server.main();
        edit.main();
        protocol.main();
        socket_server.main();

        defineReflectiveSuite(()
        {
            defineReflectiveTests(SpecTest);
        }, name: 'spec');
    }, name: 'analysis_server');
}

@reflectiveTest
class SpecTest
{
    void test_specHasBeenGenerated()
    {
        check_spec.main();
    }
}
