//* Taken from analysis_server, the analyzer_plugin implementation was missing some methods.
// Original code: https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server/lib/protocol/protocol.dart

// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: constant_identifier_names, non_constant_identifier_names

/// Support for client code that needs to interact with the requests, responses
/// and notifications that are part of the analysis server's wire protocol.
import 'dart:convert' hide JsonDecoder;

// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart' show ResponseDecoder;

import 'package:formatter_server/protocol/protocol_generated.dart';

/// A request that was received from the client.
///
/// Clients may not extend, implement or mix-in this class.
class Request
{
    /// The name of the JSON attribute containing the id of the request.
    static const String ID = 'id';

    /// The name of the JSON attribute containing the name of the request.
    static const String METHOD = 'method';

    /// The name of the JSON attribute containing the request parameters.
    static const String PARAMS = 'params';

    /// The name of the optional JSON attribute indicating the time (milliseconds
    /// since epoch) at which the client made the request.
    static const String CLIENT_REQUEST_TIME = 'clientRequestTime';

    /// The unique identifier used to identify this request.
    final String id;

    /// The method being requested.
    final String method;

    /// A table mapping the names of request parameters to their values.
    final Map<String, Object?> params;

    /// The time (milliseconds since epoch) at which the client made the request
    /// or `null` if this information is not provided by the client.
    final int? clientRequestTime;

    /// Initialize a newly created [Request] to have the given [id] and [method]
    /// name. If [params] is supplied, it is used as the "params" map for the
    /// request. Otherwise an empty "params" map is allocated.
    Request(this.id, this.method, [Map<String, Object?>? params, this.clientRequestTime])
        : params = params ?? <String, Object?>{};

    @override
    int get hashCode
    {
        return id.hashCode;
    }

    @override
    bool operator ==(Object other)
    {
        return other is Request &&
            id == other.id &&
            method == other.method &&
            clientRequestTime == other.clientRequestTime &&
            _equalMaps(params, other.params);
    }

    /// Return a table representing the structure of the Json object that will be
    /// sent to the client to represent this response.
    Map<String, Object> toJson()
    {
        var jsonObject = <String, Object>{};
        jsonObject[ID] = id;
        jsonObject[METHOD] = method;
        if (params.isNotEmpty)
        {
            jsonObject[PARAMS] = params;
        }
        final clientRequestTime = this.clientRequestTime;
        if (clientRequestTime != null)
        {
            jsonObject[CLIENT_REQUEST_TIME] = clientRequestTime;
        }
        return jsonObject;
    }

    bool _equalLists(List? first, List? second)
    {
        if (first == null)
        {
            return second == null;
        }
        if (second == null)
        {
            return false;
        }
        var length = first.length;
        if (length != second.length)
        {
            return false;
        }
        for (var i = 0; i < length; i++)
        {
            if (!_equalObjects(first[i], second[i]))
            {
                return false;
            }
        }
        return true;
    }

    bool _equalMaps(Map? first, Map? second)
    {
        if (first == null)
        {
            return second == null;
        }
        if (second == null)
        {
            return false;
        }
        if (first.length != second.length)
        {
            return false;
        }
        for (var key in first.keys)
        {
            if (!second.containsKey(key))
            {
                return false;
            }
            if (!_equalObjects(first[key], second[key]))
            {
                return false;
            }
        }
        return true;
    }

    bool _equalObjects(Object? first, Object? second)
    {
        if (first == null)
        {
            return second == null;
        }
        if (second == null)
        {
            return false;
        }
        if (first is Map)
        {
            if (second is Map)
            {
                return _equalMaps(first, second);
            }
            return false;
        }
        if (first is List)
        {
            if (second is List)
            {
                return _equalLists(first, second);
            }
            return false;
        }
        return first == second;
    }

    /// Return a request parsed from the given json, or `null` if the [data] is
    /// not a valid json representation of a request. The [data] is expected to
    /// have the following format:
    ///
    ///   {
    ///     'clientRequestTime': millisecondsSinceEpoch
    ///     'id': String,
    ///     'method': methodName,
    ///     'params': {
    ///       paramter_name: value
    ///     }
    ///   }
    ///
    /// where both the parameters and clientRequestTime are optional.
    ///
    /// The parameters can contain any number of name/value pairs. The
    /// clientRequestTime must be an int representing the time at which the client
    /// issued the request (milliseconds since epoch).
    static Request? fromJson(Map<String, Object?> result)
    {
        var id = result[Request.ID];
        var method = result[Request.METHOD];
        if (id is! String || method is! String)
        {
            return null;
        }
        var time = result[Request.CLIENT_REQUEST_TIME];
        if (time is! int?)
        {
            return null;
        }
        var params = result[Request.PARAMS];
        if (params is Map<String, Object?>?)
        {
            return Request(id, method, params, time);
        }
        else
        {
            return null;
        }
    }

    /// Return a request parsed from the given [data], or `null` if the [data] is
    /// not a valid json representation of a request. The [data] is expected to
    /// have the following format:
    ///
    ///   {
    ///     'clientRequestTime': millisecondsSinceEpoch
    ///     'id': String,
    ///     'method': methodName,
    ///     'params': {
    ///       paramter_name: value
    ///     }
    ///   }
    ///
    /// where both the parameters and clientRequestTime are optional.
    ///
    /// The parameters can contain any number of name/value pairs. The
    /// clientRequestTime must be an int representing the time at which the client
    /// issued the request (milliseconds since epoch).
    static Request? fromString(String data)
    {
        try
        {
            var result = json.decode(data);
            if (result is Map<String, Object?>)
            {
                return Request.fromJson(result);
            }
            return null;
        }
        catch (exception)
        {
            return null;
        }
    }
}

//TODO (tekert): some methods are not used. can be deleted or refactored.
/// A response to a request.
///
/// Clients may not extend, implement or mix-in this class.
class Response
{
    /// The [Response] instance that is returned when a real [Response] cannot
    /// be provided at the moment.
    static final Response DELAYED_RESPONSE = Response('DELAYED_RESPONSE');

    /// The name of the JSON attribute containing the id of the request for which
    /// this is a response.
    static const String ID = 'id';

    /// The name of the JSON attribute containing the error message.
    static const String ERROR = 'error';

    /// The name of the JSON attribute containing the result values.
    static const String RESULT = 'result';

    /// The unique identifier used to identify the request that this response is
    /// associated with.
    final String id;

    /// The error that was caused by attempting to handle the request, or `null`
    /// if there was no error.
    final RequestError? error;

    /// A table mapping the names of result fields to their values.  Should be
    /// `null` if there is no result to send.
    Map<String, Object?>? result;

    /// Initialize a newly created instance to represent a response to a request
    /// with the given [id].  If [_result] is provided, it will be used as the
    /// result; otherwise an empty result will be used.  If an [error] is provided
    /// then the response will represent an error condition.
    Response(this.id, {this.result, this.error});

    /// Initialize a newly created instance to represent the FORMAT_INVALID_FILE
    /// error condition.
    Response.formatInvalidFile(Request request)
        : this(request.id,
              error: RequestError(RequestErrorCode.FORMAT_INVALID_FILE,
                  'Error during `${request.method}`: invalid file.'));

    /// Initialize a newly created instance to represent the FORMAT_WITH_ERROR
    /// error condition.
    Response.formatWithErrors(Request request)
        : this(request.id,
              error: RequestError(RequestErrorCode.FORMAT_WITH_ERRORS,
                  'Error during `edit.format`: source contains syntax errors.'));

    /// Initialize a newly created instance to represent the FORMAT_RANGE_ERROR
    /// error condition.
    Response.formatRangeError(
        Request request, int fileLenght, int selectionStart, int selectionEnd)
        : this(request.id,
              error: RequestError(
                  RequestErrorCode.FORMAT_RANGE_ERROR,
                  'Error during `edit.format`: selected code offsets [$selectionStart'
                  '-$selectionEnd] must be within [0-$fileLenght].'));

    /// Initialize a newly created instance to represent the
    /// INVALID_FILE_PATH_FORMAT error condition.
    Response.invalidFilePathFormat(Request request, path)
        : this(request.id,
              error: RequestError(RequestErrorCode.INVALID_FILE_PATH_FORMAT,
                  'Invalid file path format: $path'));

    /// Initialize a newly created instance to represent an error condition caused
    /// by a [request] that had invalid parameter.  [path] is the path to the
    /// invalid parameter, in Javascript notation (e.g. "foo.bar" means that the
    /// parameter "foo" contained a key "bar" whose value was the wrong type).
    /// [expectation] is a description of the type of data that was expected.
    Response.invalidParameter(Request request, String path, String expectation)
        : this(request.id,
              error: RequestError(RequestErrorCode.INVALID_PARAMETER,
                  "Invalid parameter '$path'. $expectation."));

    /// Initialize a newly created instance to represent an error condition caused
    /// by a malformed request.
    Response.invalidRequestFormat()
        : this('',
              error: RequestError(RequestErrorCode.INVALID_REQUEST, 'Invalid request'));

    /// Initialize a newly created instance to represent the SERVER_ERROR error
    /// condition.
    factory Response.serverError(Request request, exception, stackTrace)
    {
        var error = RequestError(RequestErrorCode.SERVER_ERROR, exception.toString());
        if (stackTrace != null)
        {
            error.stackTrace = stackTrace.toString();
        }
        return Response(request.id, error: error);
    }

    /// Initialize a newly created instance to represent an error condition caused
    /// by a [request] that cannot be handled by any known handlers.
    Response.unknownRequest(Request request)
        : this(request.id,
              error: RequestError(RequestErrorCode.UNKNOWN_REQUEST, 'Unknown request'));

    /// Initialize a newly created instance to represent an error condition caused
    /// by a [request] for a service that is not supported.
    Response.unsupportedFeature(String requestId, String message)
        : this(requestId,
              error: RequestError(RequestErrorCode.UNSUPPORTED_FEATURE, message));

    /// Return a table representing the structure of the Json object that will be
    /// sent to the client to represent this response.
    Map<String, Object> toJson()
    {
        var jsonObject = <String, Object>{};
        jsonObject[ID] = id;
        final error = this.error;
        if (error != null)
        {
            jsonObject[ERROR] = error.toJson();
        }
        final result = this.result;
        if (result != null)
        {
            jsonObject[RESULT] = result;
        }
        return jsonObject;
    }

    /// Initialize a newly created instance based on the given JSON data.
    static Response? fromJson(Map<String, Object?> json)
    {
        try
        {
            var id = json[Response.ID];
            if (id is! String)
            {
                return null;
            }

            RequestError? decodedError;
            var error = json[Response.ERROR];
            if (error is Map)
            {
                decodedError =
                    RequestError.fromJson(ResponseDecoder(null), '.error', error);
            }

            Map<String, Object?>? decodedResult;
            var result = json[Response.RESULT];
            if (result is Map<String, Object?>)
            {
                decodedResult = result;
            }

            return Response(id, error: decodedError, result: decodedResult);
        }
        catch (exception)
        {
            return null;
        }
    }
}

/// A notification that can be sent from the server about an event that
/// occurred.
///
/// Clients may not extend, implement or mix-in this class.
class Notification
{
    /// The name of the JSON attribute containing the name of the event that
    /// triggered the notification.
    static const String EVENT = 'event';

    /// The name of the JSON attribute containing the result values.
    static const String PARAMS = 'params';

    /// The name of the event that triggered the notification.
    final String event;

    /// A table mapping the names of notification parameters to their values, or
    /// `null` if there are no notification parameters.
    final Map<String, Object?>? params;

    /// Initialize a newly created [Notification] to have the given [event] name.
    /// If [params] is provided, it will be used as the params; otherwise no
    /// params will be used.
    Notification(this.event, [this.params]);

    /// Initialize a newly created instance based on the given JSON data.
    factory Notification.fromJson(Map json)
    {
        return Notification(json[Notification.EVENT] as String,
            json[Notification.PARAMS] as Map<String, Object?>?);
    }

    /// Return a table representing the structure of the Json object that will be
    /// sent to the client to represent this response.
    Map<String, Object> toJson()
    {
        var jsonObject = <String, Object>{};
        jsonObject[EVENT] = event;
        final params = this.params;
        if (params != null)
        {
            jsonObject[PARAMS] = params;
        }
        return jsonObject;
    }
}

/// An exception that occurred during the handling of a request that requires
/// that an error be returned to the client.
///
/// Clients may not extend, implement or mix-in this class.
class RequestFailure implements Exception
{
    /// The response to be returned as a result of the failure.
    final Response response;

    /// Initialize a newly created exception to return the given reponse.
    RequestFailure(this.response);
}
