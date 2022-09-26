// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:formatter_server/src/channel/channel.dart';
import 'package:formatter_server/src/socket_server.dart';

/// Instances of the class [StdioServer] implement a simple server operating
/// over standard input and output. The primary responsibility of this server
/// is to split incoming messages on newlines and pass them along to the
/// formatting server.
class StdioFormatServer
{
    /// A format Server instance.
    SocketServer socketServer;

    /// Initialize a newly created stdio server.
    StdioFormatServer(this.socketServer);

    /// Begin serving requests over stdio.
    ///
    /// Return a future that will be completed when stdin closes.
    Future serveStdio()
    {
        //TODO (tekert): check if non-blocking is disabled on stdin
        var serverChannel = ByteStreamServerChannel(
            stdin,
            stdout.nonBlocking,
        );
        socketServer.createFormatServer(serverChannel);
        return serverChannel.closed;
    }
}
