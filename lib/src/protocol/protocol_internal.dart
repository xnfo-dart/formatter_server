// The code was taken from analysis_server package and modified by Xnfo.
// The dart_style package copyright notice is as follows:
//
// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
//TODO: use json from the standard library (C code) instead of analyzer_plugin and measure performanace or ask why is was used.
import 'dart:convert' hide JsonDecoder;

import 'package:analyzer_plugin/protocol/protocol_common.dart';
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show HasToJson, JsonDecoder;
export 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show JsonDecoder, listEqual, HasToJson;

import 'package:formatter_server/protocol/protocol.dart';

// ignore: non_constant_identifier_names
final Map<String, RefactoringKind> REQUEST_ID_REFACTORING_KINDS =
    HashMap<String, RefactoringKind>();

/// JsonDecoder for decoding requests.  Errors are reporting by throwing a
/// [RequestFailure].
class RequestDecoder extends JsonDecoder
{
    /// The request being deserialized.
    final Request _request;

    RequestDecoder(this._request);

    @override
    RefactoringKind? get refactoringKind
    {
        // Refactoring feedback objects should never appear in requests.
        return null;
    }

    @override
    Object mismatch(String jsonPath, String expected, [Object? actual])
    {
        var buffer = StringBuffer();
        buffer.write('Expected to be ');
        buffer.write(expected);
        if (actual != null)
        {
            buffer.write('; found "');
            buffer.write(json.encode(actual));
            buffer.write('"');
        }
        return RequestFailure(
            Response.invalidParameter(_request, jsonPath, buffer.toString()));
    }

    @override
    Object missingKey(String jsonPath, String key)
    {
        return RequestFailure(Response.invalidParameter(
            _request, jsonPath, 'Expected to contain key ${json.encode(key)}'));
    }
}

/// The result data associated with a response.
abstract class ResponseResult implements HasToJson
{
    /// Return a response whose result data is this object for the request with
    /// the given [id].
    Response toResponse(String id);
}

abstract class RequestParams implements HasToJson
{
    /// Return a request whose parameters are taken from this object and that has
    /// the given [id].
    Request toRequest(String id);
}

/// JsonDecoder for decoding responses from the server.  This is intended to be
/// used only for testing.  Errors are reported using bare [Exception] objects.
class ResponseDecoder extends JsonDecoder
{
    @override
    final RefactoringKind? refactoringKind;

    ResponseDecoder(this.refactoringKind);

    @override
    Object mismatch(String jsonPath, String expected, [Object? actual])
    {
        var buffer = StringBuffer();
        buffer.write('Expected ');
        buffer.write(expected);
        if (actual != null)
        {
            buffer.write(' found "');
            buffer.write(json.encode(actual));
            buffer.write('"');
        }
        buffer.write(' at ');
        buffer.write(jsonPath);
        return Exception(buffer.toString());
    }

    @override
    Object missingKey(String jsonPath, String key)
    {
        return Exception('Missing key $key at $jsonPath');
    }
}

/// Compare the maps [mapA] and [mapB], using [valueEqual] to compare map
/// values.
bool mapEqual<K, V>(Map<K, V>? mapA, Map<K, V>? mapB, bool Function(V a, V b) valueEqual)
{
    if (mapA == null)
    {
        return mapB == null;
    }
    if (mapB == null)
    {
        return false;
    }
    if (mapA.length != mapB.length)
    {
        return false;
    }
    for (var entryA in mapA.entries)
    {
        var key = entryA.key;
        var valueA = entryA.value;
        var valueB = mapB[key];
        if (valueB == null || !valueEqual(valueA, valueB))
        {
            return false;
        }
    }
    return true;
}

/// Translate the input [map], applying [keyCallback] to all its keys, and
/// [valueCallback] to all its values.
Map<KR, VR> mapMap<KP, VP, KR, VR>(Map<KP, VP> map,
    {KR Function(KP key)? keyCallback, VR Function(VP value)? valueCallback})
{
    Map<KR, VR> result = HashMap<KR, VR>();
    map.forEach((key, value)
    {
        KR resultKey;
        VR resultValue;
        if (keyCallback != null)
        {
            resultKey = keyCallback(key);
        }
        else
        {
            resultKey = key as KR;
        }

        if (valueCallback != null)
        {
            resultValue = valueCallback(value);
        }
        else
        {
            resultValue = value as VR;
        }
        result[resultKey] = resultValue;
    });
    return result;
}
