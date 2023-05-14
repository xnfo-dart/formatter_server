// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// This file has been automatically generated. Please do not edit it manually.
// To regenerate the file, use the script
// "tool/protocol_spec/generate.dart".

// ignore_for_file: constant_identifier_names

/// Convenience methods for running integration tests.
import 'dart:async';

import 'package:formatter_server/protocol/protocol_generated.dart';
import 'package:formatter_server/src/protocol/protocol_internal.dart';
import 'package:test/test.dart';

import 'integration_tests.dart';
import 'protocol_matchers.dart';

/// Convenience methods for running integration tests.
abstract class IntegrationTestMixin
{
    Server get server;

    /// Return the version number of the formatter server.
    ///
    /// Returns
    ///
    /// version: String
    ///
    ///   The version number of the formatter server
    ///
    /// protocol: String
    ///
    ///   The version number of the API Protocol used in the formatter server
    Future<ServerGetVersionResult> sendServerGetVersion() async
    {
        var result = await server.send('server.getVersion', null);
        var decoder = ResponseDecoder(null);
        return ServerGetVersionResult.fromJson(decoder, 'result', result);
    }

    /// Cleanly shutdown the formatter server. Requests that are received after
    /// this request will not be processed. Requests that were received before
    /// this request, but for which a response has not yet been sent, will not be
    /// responded to. No further responses or notifications will be sent after
    /// the response to this request has been sent.
    Future<void> sendServerShutdown() async
    {
        var result = await server.send('server.shutdown', null);
        outOfTestExpect(result, isNull);
        return null;
    }

    /// Update the content of one or more files. Files that were previously
    /// updated but not included in this update remain unchanged. This
    /// effectively represents an overlay of the filesystem. The files whose
    /// content is overridden are therefore seen by server as being files with
    /// the given content, even if the files do not exist on the filesystem or if
    /// the file path represents the path to a directory on the filesystem.
    ///
    /// Parameters
    ///
    /// files: Map<FilePath, AddContentOverlay | ChangeContentOverlay |
    /// RemoveContentOverlay>
    ///
    ///   A table mapping the files whose content has changed to a description of
    ///   the content change.
    ///
    /// Returns
    Future<ServerUpdateContentResult> sendServerUpdateContent(
        Map<String, Object> files) async
    {
        var params = ServerUpdateContentParams(files).toJson();
        var result = await server.send('server.updateContent', params);
        var decoder = ResponseDecoder(null);
        return ServerUpdateContentResult.fromJson(decoder, 'result', result);
    }

    /// Reports that the server is running. This notification is issued once
    /// after the server has started running but before any requests are
    /// processed to let the client know that it started correctly.
    ///
    /// It is not possible to subscribe to or unsubscribe from this notification.
    ///
    /// Parameters
    ///
    /// version: String
    ///
    ///   The version number of the formatter server.
    ///
    /// pid: int
    ///
    ///   The process id of the formatter server process.
    late Stream<ServerConnectedParams> onServerConnected;

    /// Stream controller for [onServerConnected].
    late StreamController<ServerConnectedParams> _onServerConnected;

    /// Reports that an unexpected error has occurred while executing the server.
    /// This notification is not used for problems with specific requests (which
    /// are returned as part of the response) but is used for exceptions that
    /// occur while performing other tasks, such as analysis or preparing
    /// notifications.
    ///
    /// It is not possible to subscribe to or unsubscribe from this notification.
    ///
    /// Parameters
    ///
    /// isFatal: bool
    ///
    ///   True if the error is a fatal error, meaning that the server will
    ///   shutdown automatically after sending this notification.
    ///
    /// message: String
    ///
    ///   The error message indicating what kind of error was encountered.
    ///
    /// stackTrace: String
    ///
    ///   The stack trace associated with the generation of the error, used for
    ///   debugging the server.
    late Stream<ServerErrorParams> onServerError;

    /// Stream controller for [onServerError].
    late StreamController<ServerErrorParams> _onServerError;

    /// Format the contents of a single file. The currently selected region of
    /// text is passed in so that the selection can be preserved across the
    /// formatting operation. The updated selection will be as close to matching
    /// the original as possible, but whitespace at the beginning or end of the
    /// selected region will be ignored. If preserving selection information is
    /// not required, zero (0) can be specified for both the selection offset and
    /// selection length.
    ///
    /// If a request is made for a file which does not exist, an error of type
    /// FORMAT_INVALID_FILE will be generated. If the source contains syntax
    /// errors, an error of type FORMAT_WITH_ERRORS will be generated. If the
    /// selection range is outside of the file character lenght and error off
    /// type FORMAT_RANGE_ERROR will be generated.
    ///
    /// Parameters
    ///
    /// file: String
    ///
    ///   The file containing the code to be formatted.
    ///
    /// selectionOffset: int
    ///
    ///   The offset of the current selection in the file.
    ///
    /// selectionLength: int
    ///
    ///   The length of the current selection in the file.
    ///
    /// selectionOnly: bool (optional)
    ///
    ///   True if the code to be formatted should be limited to the selected text
    ///   (or the smallest portion of text that encloses the selected text that
    ///   can be formatted).
    ///   defaults to false if not set.
    ///
    /// lineLength: int (optional)
    ///
    ///   The line length to be used by the formatter.
    ///   defaults to 90 if not set.
    ///
    /// tabSize: TabSize (optional)
    ///
    ///   The tab size in spaces to be used by the formatter.
    ///   defaults all indents to 4 if not set.
    ///
    /// insertSpaces: bool (optional)
    ///
    ///   True if the code to be formatted should use spaces for indentations,
    ///   false to use tab stops. ignores [tabSize] if false.
    ///   defaults to true if not set.
    ///
    /// codeStyle: CodeStyle (optional)
    ///
    ///   Set of common code styles. default to 0 = dart_style with unlocked
    ///   indent sizes. for more info check [CodeStyle] type.
    ///   defaults to 0 if not set.
    ///
    /// Returns
    ///
    /// edits: List<SourceEdit>
    ///
    ///   The edit(s) to be applied in order to format the code. The list will be
    ///   empty if the code was already formatted (there are no changes).
    ///
    /// selectionOffset: int
    ///
    ///   The offset of the selection after formatting the code.
    ///
    /// selectionLength: int
    ///
    ///   The length of the selection after formatting the code.
    Future<EditFormatResult> sendEditFormat(
        String file, int selectionOffset, int selectionLength,
        {bool? selectionOnly,
        int? lineLength,
        TabSize? tabSize,
        bool? insertSpaces,
        CodeStyle? codeStyle}) async
    {
        var params = EditFormatParams(file, selectionOffset, selectionLength,
                selectionOnly: selectionOnly,
                lineLength: lineLength,
                tabSize: tabSize,
                insertSpaces: insertSpaces,
                codeStyle: codeStyle)
            .toJson();
        var result = await server.send('edit.format', params);
        var decoder = ResponseDecoder(null);
        return EditFormatResult.fromJson(decoder, 'result', result);
    }

    /// Initialize the fields in InttestMixin, and ensure that notifications will
    /// be handled.
    void initializeInttestMixin()
    {
        _onServerConnected = StreamController<ServerConnectedParams>(sync: true);
        onServerConnected = _onServerConnected.stream.asBroadcastStream();
        _onServerError = StreamController<ServerErrorParams>(sync: true);
        onServerError = _onServerError.stream.asBroadcastStream();
    }

    /// Dispatch the notification named [event], and containing parameters
    /// [params], to the appropriate stream.
    void dispatchNotification(String event, params)
    {
        var decoder = ResponseDecoder(null);
        switch (event)
        {
            case 'server.connected':
                outOfTestExpect(params, isServerConnectedParams);
                _onServerConnected
                    .add(ServerConnectedParams.fromJson(decoder, 'params', params));
                break;
            case 'server.error':
                outOfTestExpect(params, isServerErrorParams);
                _onServerError.add(ServerErrorParams.fromJson(decoder, 'params', params));
                break;
            default:
                fail('Unexpected notification: $event');
        }
    }
}
