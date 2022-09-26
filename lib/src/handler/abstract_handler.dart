// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//import 'package:analyzer_plugin/src/protocol/protocol_internal.dart' hide ResponseResult;

import 'package:formatter_server/src/format_server.dart';
import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/src/protocol/protocol_internal.dart';

abstract class Handler
{
    /// The format server that is using this handler to process a request.
    final FormatServer server;

    /// The request being handled.
    final Request request;

    /// Initialize a newly created handler to be able to service requests for the
    /// [server].
    Handler(this.server, this.request);

    /// Handle the [request].
    Future<void> handle();

    /// Send the [response] to the client.
    void sendResponse(Response response)
    {
        server.sendResponse(response);
    }

    /// Send a response to the client that is associated with the given [request]
    /// and whose body if the given [result].
    void sendResult(ResponseResult result)
    {
        sendResponse(result.toResponse(request.id));
    }
}
