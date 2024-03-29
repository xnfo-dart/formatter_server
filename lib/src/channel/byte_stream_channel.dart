import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/src/channel/channel.dart';

import 'package:analyzer/instrumentation/instrumentation.dart';

// Instances of the class [ByteStreamServerChannel] implement a
/// [ServerCommunicationChannel] that uses a stream and a sink (typically,
/// standard input and standard output) to communicate with clients.
class ByteStreamServerChannel implements ServerCommunicationChannel
{
    final Stream<List<int>> _input;
    final IOSink _output;

    /// The instrumentation service that is to be used by this formatter server.
    final InstrumentationService _instrumentationService;

    /// Completer that will be signalled when the input stream is closed.
    final Completer<void> _closed = Completer();

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

    ByteStreamServerChannel(this._input, this._output, this._instrumentationService);
    /*{RequestStatisticsHelper? requestStatistics})
      : _requestStatistics = requestStatistics {
    _requestStatistics?.serverChannel = this;*/

    /// Future that will be completed when the input stream is closed.
    Future<void> get closed
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
        if (!identical(notification.event, 'server.log'))
        {
            _instrumentationService.logNotification(jsonEncoding);
            //_requestStatistics?.logNotification(notification);
        }
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

        //_requestStatistics?.addResponse(response);
        var jsonEncoding = json.encode(response.toJson());
        _outputLine(jsonEncoding);
        _instrumentationService.logResponse(jsonEncoding);
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

        _instrumentationService.logRequest(data);

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
