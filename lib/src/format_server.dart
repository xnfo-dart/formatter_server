// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:analyzer/instrumentation/service.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/exception/exception.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart'; // for ContentOverlay
// ignore: implementation_imports
/*import 'package:analyzer/src/generated/sdk.dart';*/

import 'package:formatter_server/src/channel/channel.dart';
import 'package:formatter_server/src/server/error_notifier.dart';
import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/protocol/protocol_constants.dart';
import 'package:formatter_server/protocol/protocol_generated.dart';

// Handlers
import 'package:formatter_server/src/handler/abstract_handler.dart';
import 'package:formatter_server/src/handler/edit_format.dart';
import 'package:formatter_server/src/handler/server_get_version.dart';
import 'package:formatter_server/src/handler/server_shutdown.dart';
import 'package:formatter_server/src/handler/server_update_content.dart';

/// Various IDE options.
class FormatServerOptions
{
    String? clientId;
    String? clientVersion;
}

/// A function that can be executed to create a handler for a request.
typedef HandlerGenerator = Handler Function(FormatServer, Request);

class FormatServer
{
    /// A map from the name of a request to a function used to create a request
    /// handler.
    static final Map<String, HandlerGenerator> handlerGenerators = {
        EDIT_REQUEST_FORMAT: EditFormatHandler.new,
        SERVER_REQUEST_GET_VERSION: ServerGetVersionHandler.new,
        SERVER_REQUEST_SHUTDOWN: ServerShutdownHandler.new,
        SERVER_REQUEST_UPDATE_CONTENT: ServerUpdateContentHandler.new,
    };

    /// The channel from which requests are received and to which responses should
    /// be sent.
    final ServerCommunicationChannel channel;

    /// The instrumentation service that is to be used by this format server.
    InstrumentationService instrumentationService;

    /// The [ResourceProvider] using which paths are converted into [Resource]s.
    final OverlayResourceProvider resourceProvider;

    Duration pendingFilesRemoveOverlayDelay = const Duration(seconds: 10);

    /// The next modification stamp for a changed file in the [resourceProvider].
    ///
    /// This value is increased each time it is used and used instead of real
    /// modification stamps. It's seeded with `millisecondsSinceEpoch` to reduce
    /// the chance of colliding with values used in previous formatter sessions if
    /// used as a cache key.
    int overlayModificationStamp = DateTime.now().millisecondsSinceEpoch;

    /// Handle requests on [channel] using a [baseResourceProvider]
    /// for overlaying files access with a [OverlayResourceProvider]
    /// [instrumentationService] is used for logging exceptions.
    FormatServer(this.channel, ResourceProvider baseResourceProvider,
        /*this.sdkManager,*/ this.instrumentationService)
        : resourceProvider = OverlayResourceProvider(baseResourceProvider)
    {
        channel.sendNotification(
            ServerConnectedParams(
                PROTOCOL_VERSION,
                io.pid,
            ).toNotification(),
        );

        channel.requests.listen(handleRequest, onDone: done, onError: error);
        //debounceRequests(channel, discardedRequests).listen(handleRequest, onDone: done, onError: error);
    }

    /// For tests only
    Future<void> dispose() async {}

    /// The socket from which requests are being read has been closed.
    void done() {}

    /// There was an error related to the socket from which requests are being
    /// read.
    void error(Object exception, StackTrace? stackTrace)
    {
        // Don't send to instrumentation service; not an internal error.
        // NOTE(tekert): why? in the lsp implementation intrumentation is used.
        // NOTE(tekert): ported sendServerErrorNotification will do intrumentation, so, everything ok.
        sendServerErrorNotification('Socket error', exception, stackTrace);
    }

    /// Handle a [request] that was read from the communication channel.
    void handleRequest(Request request)
    {
        // NOTE: runZonedGuarded (onError) handles sync and async errors.
        // NOTE: runZoned (ZoneSpecification handleUncaughtError) now handles sync and async errors.

        // Because we don't `await` the execution of the handlers, we wrap the
        // execution in order to have one central place to handle exceptions.
        runZonedGuarded(()
        {
            //analyticsManager.startedRequest(request: request, startTime: DateTime.now());
            //performance.logRequestTiming(request.clientRequestTime);

            // Find request name and get the request handler constructor.
            var generator = handlerGenerators[request.method];
            if (generator != null)
            {
                var handler = generator(this, request);
                handler.handle(); // async
            }
            else
            {
                sendResponse(Response.unknownRequest(request));
            }
        }, (exception, stackTrace)
        {
            // In case an async handler doesn't catch RequestFailure (protocol parse errors),
            // send response but don't log it.
            if (exception is RequestFailure)
            {
                sendResponse(exception.response);
                return;
            }

            // Log the exception.
            instrumentationService.logException(
                FatalException(
                    'Failed to handle request: ${request.method}',
                    exception,
                    stackTrace,
                ),
                null,
                //crashReportingAttachmentsBuilder.forException(exception),
            );
            // Then return an error response to the client.
            var error = RequestError(RequestErrorCode.SERVER_ERROR, exception.toString());
            error.stackTrace = stackTrace.toString();
            var response = Response(request.id, error: error);
            sendResponse(response);
        });
    }

    /// Return `true` if the given path is a valid `FilePath`.
    ///
    /// This means that it is absolute and normalized.
    bool isValidFilePath(String path)
    {
        return resourceProvider.pathContext.isAbsolute(path) &&
            resourceProvider.pathContext.normalize(path) == path;
    }

    /// Send the given [notification] to the client.
    void sendNotification(Notification notification)
    {
        channel.sendNotification(notification);
    }

    /// Send the given [response] to the client.
    void sendResponse(Response response)
    {
        channel.sendResponse(response);
    }

    /// Return `true` if the [path] is both absolute and normalized.
    bool isAbsoluteAndNormalized(String path)
    {
        var pathContext = resourceProvider.pathContext;
        return pathContext.isAbsolute(path) && pathContext.normalize(path) == path;
    }

    /// If the [path] is not a valid file path, that is absolute and normalized,
    /// send an error response, and return `true`. If OK then return `false`.
    bool sendResponseErrorIfInvalidFilePath(Request request, String path)
    {
        if (!isAbsoluteAndNormalized(path))
        {
            sendResponse(Response.invalidFilePathFormat(request, path));
            return true;
        }
        return false;
    }

    /// Sends a `server.error` notification.
    // Ported from lsp implemetation of analysis server socket errors.
    // Stream<Request>.listen onError: parameter
    void sendServerErrorNotification(
        String message,
        Object exception,
        StackTrace? stackTrace, {
        bool fatal = false,
    })
    {
        var fullMessage = message;
        if (exception is CaughtException)
        {
            stackTrace ??= exception.stackTrace;
            fullMessage = '$fullMessage: ${exception.exception}';
        }
        else
        {
            fullMessage = '$fullMessage: $exception';
        }
        final fullError = stackTrace == null ? fullMessage : '$fullMessage\n$stackTrace';
        stackTrace ??= StackTrace.current;

        // send the notification
        channel.sendNotification(
            ServerErrorParams(fatal, fullError, '$stackTrace').toNotification());
/*
        // remember the last few exceptions
        //TODO (tekert): This was for the diagnostics page of the analysis_server, remove.
        // no use here.
        exceptions.add(ServerException(
            message,
            exception,
            stackTrace,
            false,
        ));
*/
        instrumentationService.logException(
            FatalException(
                message,
                exception,
                stackTrace,
            ),
            null,
            //crashReportingAttachmentsBuilder.forException(exception),
        );
    }

    Future<void> shutdown()
    {
        // Defer closing the channel and shutting down the instrumentation server so
        // that the shutdown response can be sent and logged.
        Future(()
        {
            instrumentationService.shutdown();
            channel.close();
        });

        return Future.value();
    }

    /// Implementation for `server.updateContent`.
    void updateContent(String id, Map<String, dynamic> changes)
    {
        //_onAnalysisSetChangedController.add(null);
        changes.forEach((file, change)
        {
            // Prepare the old overlay contents.
            String? oldContents;
            try
            {
                if (resourceProvider.hasOverlay(file))
                {
                    oldContents = resourceProvider.getFile(file).readAsStringSync();
                }
            }
            catch (_) {}

            // Prepare the new contents.
            String? newContents;
            if (change is AddContentOverlay)
            {
                newContents = change.content;
            }
            else if (change is ChangeContentOverlay)
            {
                if (oldContents == null)
                {
                    // The client may only send a ChangeContentOverlay if there is
                    // already an existing overlay for the source.
                    // If we didn't have the file contents, the server and client are out of sync
                    // and this is a serious failure.
                    throw RequestFailure(Response(id,
                        error: RequestError(RequestErrorCode.INVALID_OVERLAY_CHANGE,
                            'Invalid overlay change: Change needs a prior "add" to register the overlay')));
                }
                try
                {
                    newContents = SourceEdit.applySequence(oldContents, change.edits);
                }
                on RangeError
                {
                    throw RequestFailure(Response(id,
                        error: RequestError(RequestErrorCode.INVALID_OVERLAY_RANGE,
                            'Invalid overlay change: Edit range error')));
                }
            }
            else if (change is RemoveContentOverlay)
            {
                newContents = null;
            }
            else
            {
                // Protocol parsing should have ensured that we never get here.
                throw AnalysisException('Illegal change type');
            }

            if (newContents != null)
            {
                resourceProvider.setOverlay(
                    file,
                    content: newContents,
                    modificationStamp: overlayModificationStamp++,
                );
            }
            else
            {
                resourceProvider.removeOverlay(file);
            }
        });
    }
}
