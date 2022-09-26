// The code was taken from analysis_server package and modified by Xnfo.
// The dart_style package copyright notice is as follows:
//
// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:formatter_server/protocol/protocol_generated.dart';

import 'format_server.dart';
import 'handler/server_get_version.dart';
import 'handler/server_shutdown.dart';
import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/protocol/protocol_constants.dart';
//import 'package:analysis_server/src/handler/legacy/server_cancel_request.dart';
//import 'package:analysis_server/src/handler/legacy/server_set_subscriptions.dart';

/// Instances of the class [ServerDomainHandler] implement a [RequestHandler]
/// that handles requests in the server domain.
class ServerDomainHandler implements RequestHandler
{
    /// The analysis server that is using this handler to process requests.
    final FormatServer server;

    /// Initialize a newly created handler to handle requests for the given
    /// [server].
    ServerDomainHandler(this.server);

    @override
    Response? handleRequest(Request request)
    {
        try
        {
            var requestName = request.method;
            if (requestName == SERVER_REQUEST_GET_VERSION)
            {
                ServerGetVersionHandler(server, request).handle();
                return Response.DELAYED_RESPONSE;
            }
            else if (requestName == SERVER_REQUEST_SHUTDOWN)
            {
                ServerShutdownHandler(server, request).handle();
                return Response.DELAYED_RESPONSE;
            }
            else if (requestName == SERVER_REQUEST_UPDATE_CONTENT)
            {
                //! This needs to be in sync.
                //! needs higher priority.
                return updateContent(request);
            }
        }
        on RequestFailure catch (exception)
        {
            return exception.response;
        }
        return null;
    }

    /// Syncroniusly handle the 'server.updateContent' request.
    // Here is an implementation for the LSP in case we need it.
    // [analysis_server\lib\src\lsp\handlers\handler_text_document_changes.dart]
    Response updateContent(Request request)
    {
        var params = ServerUpdateContentParams.fromRequest(request);

        for (var file in params.files.keys)
        {
            if (!server.isAbsoluteAndNormalized(file))
            {
                return Response.invalidFilePathFormat(request, file);
            }
        }

        server.updateContent(request.id, params.files);
        //
        // Send the response.
        //
        return ServerUpdateContentResult().toResponse(request.id);
    }
}
