// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:formatter_server/src/domain_abstract.dart';
import 'package:formatter_server/src/format_server.dart';
import 'package:formatter_server/src/handler/format_handler.dart';
import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/protocol/protocol_constants.dart';

/// Instances of the class [EditDomainHandler] implement a [RequestHandler]
/// that handles requests in the edit domain.
class EditDomainHandler extends AbstractRequestHandler
{
    /// Initialize a newly created handler to handle requests for the given
    /// [server].
    EditDomainHandler(FormatServer server) : super(server);

    @override
    Response? handleRequest(Request request)
    {
        try
        {
            var requestName = request.method;
            if (requestName == EDIT_REQUEST_FORMAT)
            {
                EditFormatHandler(server, request).handle();
                return Response.DELAYED_RESPONSE;
            }
        }
        on RequestFailure catch (exception)
        {
            return exception.response;
        }
        return null;
    }
}
