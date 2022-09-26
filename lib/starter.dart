// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';

import 'package:analyzer/instrumentation/instrumentation.dart';

import 'package:formatter_server/src/server/driver.dart';

/// An object that can be used to start an formatter server. This class exists so
/// that clients can configure an formatter server before starting it.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ServerStarter
{
    /// Initialize a newly created starter to start up an formatter server.
    factory ServerStarter() = Driver;

    /// Set the instrumentation [service] that is to be used by the formatter
    /// server.
    set instrumentationService(InstrumentationService service);

    /// Use the given parsed command-line [results] to start this server.
    void start(ArgResults results);
}
