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
import 'package:formatter_server/src/edit_domain.dart';
import 'package:formatter_server/src/domain_server.dart';
import 'package:formatter_server/src/server/error_notifier.dart';
import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/protocol/protocol_constants.dart';
import 'package:formatter_server/protocol/protocol_generated.dart';

/// Various IDE options.
class FormatServerOptions
{
    String? clientId;
    String? clientVersion;
}

class FormatServer
{
    /// The channel from which requests are received and to which responses should
    /// be sent.
    final ServerCommunicationChannel channel;

    /// A list of the request handlers used to handle the requests sent to this
    /// server.
    late List<RequestHandler> handlers;

    /// The instrumentation service that is to be used by this format server.
    InstrumentationService instrumentationService;

    /// The [ResourceProvider] using which paths are converted into [Resource]s.
    final OverlayResourceProvider resourceProvider;

    /// Key: a file path for which removing of the overlay was requested.
    /// Value: a timer that will remove the overlay, or cancelled.
    ///
    /// This helps for analysis server running remotely, with slow remote file
    /// systems, in the following scenario:
    /// 1. User edits file, IDE sends "add overlay".
    /// 2. User saves file, IDE saves file locally, sends "remove overlay".
    /// 3. The remove server reads the file on "remove overlay". But the content
    ///    of the file on the remove machine is not the same as it is locally,
    ///    and not what the user looks in the IDE. So, analysis results, such
    ///    as semantic highlighting, are inconsistent with the local file content.
    /// 4. (after a few seconds) The file is synced to the remove machine,
    ///    the watch event happens, server reads the file, sends analysis
    ///    results that are consistent with the local file content.
    ///
    /// We try to prevent the inconsistency between moments (3) and (4).
    /// It is not wrong, we are still in the eventual consistency, but we
    /// want to keep the inconsistency time shorter.
    ///
    /// To do this we keep the last overlay content on "remove overlay",
    /// and wait for the next watch event in (4). But there might be race
    /// condition, and when it happens, we still want to get to the eventual
    /// consistency, so on timer we remove the overlay anyway.
    // TODO (tekert): check this, i was going to do it in a different way.
    final Map<String, Timer> _pendingFilesToRemoveOverlay = {};

    Duration pendingFilesRemoveOverlayDelay = const Duration(seconds: 10);

    /// The next modification stamp for a changed file in the [resourceProvider].
    ///
    /// This value is increased each time it is used and used instead of real
    /// modification stamps. It's seeded with `millisecondsSinceEpoch` to reduce
    /// the chance of colliding with values used in previous formatter sessions if
    /// used as a cache key.
    int overlayModificationStamp = DateTime.now().millisecondsSinceEpoch;

    /// The object used to manage the SDK's known to this server.
    /*final DartSdkManager sdkManager;*/

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

        handlers = <RequestHandler>[
            EditDomainHandler(this),
            ServerDomainHandler(this),
        ];
    }

    /// For tests only
    Future<void> dispose() async
    {
        for (var timer in _pendingFilesToRemoveOverlay.values)
        {
            timer.cancel();
        }
    }

    /// The socket from which requests are being read has been closed.
    void done() {}

    /// There was an error related to the socket from which requests are being
    /// read.
    void error(argument) {}

    /// Handle a [request] that was read from the communication channel.
    void handleRequest(Request request)
    {
        // runZonedGuarded (onError) handles sync and async errors.
        // runZoned (ZoneSpecification handleUncaughtError) hnadles only async (microtask async too).
        runZonedGuarded(()
        {
            var count = handlers.length;
            for (var i = 0; i < count; i++)
            {
                try
                {
                    // Ask each registered handler if it can handle it.
                    var response = handlers[i].handleRequest(request);
                    if (response == Response.DELAYED_RESPONSE)
                    {
                        // Means the request is being handled asyncrhonously,
                        // the handler will be responsible for sending [Response] when ready.
                        return;
                    }
                    if (response != null)
                    {
                        sendResponse(response);
                        return;
                    }
                }
                on RequestFailure catch (exception)
                {
                    sendResponse(exception.response);
                    return;
                }
                catch (exception, stackTrace)
                {
                    var error =
                        RequestError(RequestErrorCode.SERVER_ERROR, exception.toString());
                    error.stackTrace = stackTrace.toString();
                    var response = Response(request.id, error: error);
                    sendResponse(response);
                    return;
                }
            }
            sendResponse(Response.unknownRequest(request));
        }, (exception, stackTrace)
        {
            // In case an async handler doesnt catch it, send response but log it.
            if (exception is RequestFailure)
            {
                sendResponse(exception.response);
                //return; // TODO: test if log is actually logged.
            }

            instrumentationService.logException(
                FatalException(
                    'Failed to handle request: ${request.method}',
                    exception,
                    stackTrace,
                ),
                null,
            );
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
    //TODO (tekert): check for what it was used.
    void sendServerErrorNotification(
        String message,
        dynamic exception,
        /*StackTrace*/ stackTrace, {
        bool fatal = false,
    })
    {
        var msg = exception == null ? message : '$message: $exception';
        if (stackTrace != null && exception is! CaughtException)
        {
            stackTrace = StackTrace.current;
        }

        // send the notification
        channel.sendNotification(
            ServerErrorParams(fatal, msg, '$stackTrace').toNotification());

        // remember the last few exceptions
        if (exception is CaughtException)
        {
            stackTrace ??= exception.stackTrace;
        }
/*
        TODO (tekert): This was for the diagnostics page of the analysis_server, remove.
        exceptions.add(ServerException(
            message,
            exception,
            stackTrace is StackTrace ? stackTrace : StackTrace.current,
            fatal,
        ));
*/
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
            String newContents;
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
                _pendingFilesToRemoveOverlay.remove(file)?.cancel();
                _pendingFilesToRemoveOverlay[file] = Timer(
                    pendingFilesRemoveOverlayDelay,
                    ()
                    {
                        _pendingFilesToRemoveOverlay.remove(file);
                        resourceProvider.removeOverlay(file);
                        //_changeFileInDrivers(file);
                    },
                );
                return;
            }
            else
            {
                // Protocol parsing should have ensured that we never get here.
                throw AnalysisException('Illegal change type');
            }

            _pendingFilesToRemoveOverlay.remove(file)?.cancel();
            resourceProvider.setOverlay(
                file,
                content: newContents,
                modificationStamp: overlayModificationStamp++,
            );

            //_changeFileInDrivers(file);
        });
    }
}
