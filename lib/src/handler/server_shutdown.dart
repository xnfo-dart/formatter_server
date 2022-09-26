// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/protocol/protocol_generated.dart';
import 'package:formatter_server/src/format_server.dart';
import 'abstract_handler.dart';

/// The handler for the `server.shutdown` request.
class ServerShutdownHandler extends Handler
{
    /// Initialize a newly created handler to be able to service requests for the
    /// [server].
    ServerShutdownHandler(FormatServer server, Request request) : super(server, request);

    @override
    Future<void> handle() async
    {
        await server.shutdown();
        sendResult(ServerShutdownResult());
    }
}
