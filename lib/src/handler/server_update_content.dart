// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/protocol/protocol_generated.dart';
import 'package:formatter_server/src/handler/abstract_handler.dart';

/// The handler for the `server.updateContent` request.
class ServerUpdateContentHandler extends Handler
{
    /// Initialize a newly created handler to be able to service requests for the
    /// [server].
    ServerUpdateContentHandler(super.server, super.request);

    //! This needs to be called syncroniously or microtask.
    //! needs higher priority.
    /// Syncroniusly handle the 'server.updateContent' request.
    // Here is an implementation for the LSP in case we need it.
    // [analysis_server\lib\src\lsp\handlers\handler_text_document_changes.dart]
    @override
    Future<void> handle() //async
    {
        var params = ServerUpdateContentParams.fromRequest(request);

        for (var file in params.files.keys)
        {
            if (!server.isAbsoluteAndNormalized(file))
            {
                sendResponse(Response.invalidFilePathFormat(request, file));
                return Future.value();
            }
        }

        server.updateContent(request.id, params.files);

        //
        // Send the response.
        //
        sendResult(ServerUpdateContentResult());

        return Future.value(); // Its safer if this is not asynchronous
    }
}
