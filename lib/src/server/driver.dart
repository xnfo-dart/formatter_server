// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;
import 'dart:math';

//import 'package:path/path.dart' as path;
import 'package:args/args.dart';
import 'package:formatter_server/src/constants.dart';
import 'package:formatter_server/protocol/protocol_constants.dart';

import 'package:formatter_server/starter.dart';
import 'package:formatter_server/src/format_server.dart';
import 'package:formatter_server/src/socket_server.dart';
import 'package:formatter_server/src/server/stdio_server.dart';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/instrumentation/file_instrumentation.dart';
import 'package:analyzer/instrumentation/instrumentation.dart';
// ignore: implementation_imports
//import 'package:analyzer/src/generated/sdk.dart';

/// The [Driver] class represents a single running instance of the formatter
/// server.  It is responsible for parsing command line options
/// and starting the HTTP and/or stdio servers.
class Driver implements ServerStarter
{
    /// The name of the option used to set the identifier for the client.
    static const String CLIENT_ID = 'client-id';

    /// The name of the option used to set the version for the client.
    static const String CLIENT_VERSION = 'client-version';

    /// The name of the option used to cause instrumentation to also be written to
    /// a local file.
    static const String PROTOCOL_TRAFFIC_LOG = 'protocol-traffic-log';
    static const String PROTOCOL_TRAFFIC_LOG_ALIAS = 'instrumentation-log-file';

    //static const formatterserverVersion = "0.5.0-dev";

    Driver();

    // The instrumentation service that is to be used by the analysis server.
    InstrumentationService? instrumentationService;

    /// For internal formatter command-line use only.
    /// Use the given parser [results] to start this server.
    @override
    void start(ArgResults results)
    {
        if (results['version'] as bool)
        {
            print("API: $LISTEN_PROTOCOL_VERSION");
            return;
        }

        var formatServerOptions = FormatServerOptions();
        formatServerOptions.clientId = results[CLIENT_ID] as String?;
        // For clients that don't supply their own identifier, use a default
        formatServerOptions.clientId ??= 'unknown.client';
        formatServerOptions.clientVersion = results[CLIENT_VERSION] as String?;

        var logFilePath = (results[PROTOCOL_TRAFFIC_LOG] ??
            results[PROTOCOL_TRAFFIC_LOG_ALIAS]) as String?;

        var allInstrumentationServices = this.instrumentationService == null
            ? <InstrumentationService>[]
            : [this.instrumentationService!];
        if (logFilePath != null)
        {
            _rollLogFiles(logFilePath, 5);
            allInstrumentationServices.add(InstrumentationLogAdapter(
                FileInstrumentationLogger(logFilePath),
                watchEventExclusionFiles: {logFilePath}));
        }
        final instrumentationService =
            MulticastInstrumentationService(allInstrumentationServices);
        this.instrumentationService = instrumentationService;

        instrumentationService.logVersion(
            /*results[TRAIN_USING] != null
            ? 'training-0'
            :*/
            _readUuid(instrumentationService),
            formatServerOptions.clientId ?? '',
            formatServerOptions.clientVersion ?? '',
            PROTOCOL_VERSION,
            "",
        );

        //TODO (tekert): delete this
        /*final defaultSdkPath = _getSdkPath();
        final dartSdkManager = DartSdkManager(defaultSdkPath);*/

        final socketServer = SocketServer(/*dartSdkManager,*/ instrumentationService);

        //httpServer = HttpFormatServer(socketServer);

        _captureExceptions(instrumentationService, () async
        {
            Future<void> serveResult;
            var stdioServer = StdioFormatServer(socketServer);

            // Creates a channel, then instances a [FormatServer] that listen to requests in that channel.
            //! Important note:
            // this error zone is handled _captureExceptions (more notes there)
            // listen onError is handled by FormatServer.error() wich sends an [Notification] Error to client.
            // Each request is handled in another nested Error Zone for handlers wich logs any exeption error,
            //   Any unhandled (in Handler from a Request) [RequestFailure] Exeption is
            //   sent as a [Response] with Error [RequestError] (please handle them inside each handler).
            serveResult = stdioServer.serveStdio();

            // When stdioServer is closed then..
            serveResult.then((_) async
            {
                /*final httpServer = this.httpServer;
                if (httpServer != null) {
                    httpServer.close();
                }*/
                await instrumentationService.shutdown();
                socketServer.formatServer!.shutdown();
                io.exit(0);
            });
        });
/*
        , print: results[INTERNAL_PRINT_TO_CONSOLE] as bool
            ? null
            : httpServer!.recordPrint);
*/
    }

    /// Perform log files rolling.
    ///
    /// Rename existing files with names `[path].(x)` to `[path].(x+1)`.
    /// Keep at most [numOld] files.
    /// Rename the file with the given [path] to `[path].1`.
    static void _rollLogFiles(String path, int numOld)
    {
        for (var i = numOld - 1; i >= 0; i--)
        {
            try
            {
                var oldPath = i == 0 ? path : '$path.$i';
                io.File(oldPath).renameSync('$path.${i + 1}');
            }
            catch (e)
            {
                // If a file can't be renamed, then leave it and attempt to rename the
                // remaining files.
            }
        }
    }

    /// Execute the given [callback] within a zone that will capture any unhandled
    /// exceptions and both report them to the client and send them to the given
    /// instrumentation [service]. If a [print] function is provided, then also
    /// capture any data printed by the callback and redirect it to the function.
    void _captureExceptions(InstrumentationService service, void Function() callback,
        {void Function(String line)? print})
    {
        void errorFunction(Zone self, ZoneDelegate parent, Zone zone, Object exception,
            StackTrace stackTrace) async
        {
            service.logException(exception, stackTrace);
            await service.shutdown(); // flush before throwing.
            throw exception;
        }

        var printFunction = print == null
            ? null
            : (Zone self, ZoneDelegate parent, Zone zone, String line)
                {
                    // Note: we don't pass the line on to stdout, because that is
                    // reserved for communication to the client.
                    print(line);
                };
        // Warning, errors gets caught but exception logs don't have time to flush (service.logException).
        var zoneSpecification =
            ZoneSpecification(handleUncaughtError: errorFunction, print: printFunction);

        return runZoned(callback, zoneSpecification: zoneSpecification);
    }

    /// Read the UUID from disk, generating and storing a new one if necessary.
    String _readUuid(InstrumentationService service)
    {
        final instrumentationLocation =
            PhysicalResourceProvider.INSTANCE.getStateLocation('.instrumentation');
        if (instrumentationLocation == null)
        {
            return _generateUuidString();
        }
        var uuidFile = io.File(instrumentationLocation.getChild('uuid.txt').path);
        try
        {
            if (uuidFile.existsSync())
            {
                var uuid = uuidFile.readAsStringSync();
                if (uuid.length > 5)
                {
                    return uuid;
                }
            }
        }
        catch (exception, stackTrace)
        {
            service.logException(exception, stackTrace);
        }
        var uuid = _generateUuidString();
        try
        {
            uuidFile.parent.createSync(recursive: true);
            uuidFile.writeAsStringSync(uuid);
        }
        catch (exception, stackTrace)
        {
            service.logException(exception, stackTrace);
            // Slightly alter the uuid to indicate it was not persisted
            uuid = 'temp-$uuid';
        }
        return uuid;
    }

    /// Constructs a uuid combining the current date and a random integer.
    String _generateUuidString()
    {
        var millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
        var random = Random().nextInt(0x3fffffff);
        return '$millisecondsSinceEpoch$random';
    }
}
