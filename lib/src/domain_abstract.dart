// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/src/format_server.dart';

/// An abstract implementation of a request handler.
abstract class AbstractRequestHandler implements RequestHandler
{
    /// The analysis server that is using this handler to process requests.
    final FormatServer server;

    /// Initialize a newly created request handler to be associated with the given
    /// analysis [server].
    AbstractRequestHandler(this.server);
}
