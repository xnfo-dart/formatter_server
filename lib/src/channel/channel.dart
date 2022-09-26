// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:formatter_server/protocol/protocol.dart';

/// The abstract class [ServerCommunicationChannel] defines the behavior of
/// objects that allow an [FormatServer] to receive [Request]s and to return
/// both [Response]s and [Notification]s.
abstract class ServerCommunicationChannel
{
    /// The single-subscription stream of requests.
    Stream<Request> get requests;

    /// Close the communication channel.
    void close();

    /// Send the given [notification] to the client.
    void sendNotification(Notification notification);

    /// Send the given [response] to the client.
    void sendResponse(Response response);
}

// Instances of the class [ByteStreamServerChannel] implement a
/// [ServerCommunicationChannel] that uses a stream and a sink (typically,
/// standard input and standard output) to communicate with clients.
class ByteStreamServerChannel implements ServerCommunicationChannel
{
    final Stream _input;
    final IOSink _output;

    /// Completer that will be signalled when the input stream is closed.
    final Completer _closed = Completer();

    /// True if [close] has been called.
    bool _closeRequested = false;

    /// Decode input bytes, sink them when a line ending is detected and transform the line into a request object.
    @override
    late final Stream<Request> requests =
        _input.transform(const Utf8Decoder()).transform(const LineSplitter()).transform(
                StreamTransformer.fromHandlers(
                    handleData: _readRequest,
                    handleDone: (sink)
                    {
                        close();
                        sink.close();
                    },
                ),
            );

    ByteStreamServerChannel(this._input, this._output);

    /// Future that will be completed when the input stream is closed.
    Future get closed
    {
        return _closed.future;
    }

    @override
    void close()
    {
        if (!_closeRequested)
        {
            _closeRequested = true;
            assert(!_closed.isCompleted);
            _closed.complete();
        }
    }

    @override
    void sendNotification(Notification notification)
    {
        // Don't send any further notifications after the communication channel is
        // closed.
        if (_closeRequested)
        {
            return;
        }
        var jsonEncoding = json.encode(notification.toJson());
        _outputLine(jsonEncoding);
    }

    @override
    void sendResponse(Response response)
    {
        // Don't send any further responses after the communication channel is
        // closed.
        if (_closeRequested)
        {
            return;
        }

        var jsonEncoding = json.encode(response.toJson());
        _outputLine(jsonEncoding);
    }

    /// Send the string [s] to [_output] followed by a newline.
    void _outputLine(String s)
    {
        runZonedGuarded(()
        {
            _output.writeln(s);
        }, (e, s)
        {
            close();
        });
    }

    /// Read a request from the given [data] and use the given function to handle
    /// the request.
    void _readRequest(String data, Sink<Request> sink)
    {
        // Ignore any further requests after the communication channel is closed.
        if (_closed.isCompleted)
        {
            return;
        }

        // Parse the string as a JSON descriptor and process the resulting
        // structure as a request.
        var request = Request.fromString(data);
        if (request == null)
        {
            sendResponse(Response.invalidRequestFormat());
            return;
        }
        sink.add(request);
    }
}
