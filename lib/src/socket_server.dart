// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' as io;

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/instrumentation/instrumentation.dart';
// ignore: implementation_imports
//import 'package:analyzer/src/generated/sdk.dart';

import 'package:path/path.dart';

import 'package:formatter_server/src/format_server.dart';
import 'package:formatter_server/src/channel/channel.dart';
import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/protocol/protocol_generated.dart';

/// Instances of the class [SocketServer] implement the common parts of
/// http-based and stdio-based format servers.  The primary responsibility of
/// the SocketServer is to manage the lifetime of the [FormatServer] and to
/// encode and decode the JSON messages exchanged with the client.
class SocketServer
{
    /// The function used to create a new SDK using the default SDK.
    /*final DartSdkManager sdkManager;*/

    final InstrumentationService instrumentationService;

    /// The format server that was created when a client established a
    /// connection, or `null` if no such connection has yet been established.
    FormatServer? formatServer;

    SocketServer(
        /*this.sdkManager,*/
        this.instrumentationService,
    );

    /// Create an format server which will communicate with the client using the
    /// given serverChannel.
    void createFormatServer(ServerCommunicationChannel serverChannel)
    {
        if (formatServer != null)
        {
            var error = RequestError(
                RequestErrorCode.SERVER_ALREADY_STARTED, 'Server already started');

            serverChannel.sendResponse(Response('', error: error));

            serverChannel.requests.listen((Request request)
            {
                serverChannel.sendResponse(Response(request.id, error: error));
            });
            return;
        }
        var resourceProvider =
            PhysicalResourceProvider(stateLocation: _getStandardStateLocation());

        formatServer = FormatServer(
            serverChannel,
            resourceProvider,
            /*sdkManager,*/
            instrumentationService,
        );
    }
}

/// Returns the path to default state location.
///
/// Generally this is ~/.dartCFormatServer. It can be overridden via the
/// FORMAT_STATE_LOCATION_OVERRIDE environment variable, in which case this
/// method will return the contents of that environment variable.
String? _getStandardStateLocation()
{
    final Map<String, String> env = io.Platform.environment;
    if (env.containsKey('FORMAT_STATE_LOCATION_OVERRIDE'))
    {
        return env['FORMAT_STATE_LOCATION_OVERRIDE'];
    }

    const String formatDir = ".dartCFormatServer";

    final home = io.Platform.isWindows ? env['LOCALAPPDATA'] : env['HOME'];
    return home != null && io.FileSystemEntity.isDirectorySync(home)
        ? join(home, formatDir)
        : null;
}
