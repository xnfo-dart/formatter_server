// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// This file has been automatically generated. Please do not edit it manually.
// To regenerate the file, use the script
// "tool/protocol_spec/generate.dart".

// ignore_for_file: constant_identifier_names

//TODO: use json from the standard library (C code) instead of analyzer_plugin and measure performnace or ask why is was used.
import 'dart:convert' hide JsonDecoder;

import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/src/protocol/protocol_internal.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

/// CodeStyle
///
/// {
///   "code": int
/// }
///
/// Clients may not extend, implement or mix-in this class.
class CodeStyle implements HasToJson
{
    /// 0 = dart_style, original style with unlocked indents
    /// 1 = dart_expanded, based on dart_style with outer braces on blocks that
    /// are not collection literals.
    /// 2 = [not available yet]
    /// 3 = [not available yet]
    int code;

    CodeStyle(this.code);

    factory CodeStyle.fromJson(JsonDecoder jsonDecoder, String jsonPath, Object? json)
    {
        json ??= {};
        if (json is Map)
        {
            int code;
            if (json.containsKey('code'))
            {
                code = jsonDecoder.decodeInt('$jsonPath.code', json['code']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'code');
            }
            return CodeStyle(code);
        }
        else
        {
            throw jsonDecoder.mismatch(jsonPath, 'CodeStyle', json);
        }
    }

    @override
    Map<String, Object> toJson()
    {
        var result = <String, Object>{};
        result['code'] = code;
        return result;
    }

    @override
    String toString() => json.encode(toJson());

    @override
    bool operator ==(other)
    {
        if (other is CodeStyle)
        {
            return code == other.code;
        }
        return false;
    }

    @override
    int get hashCode => code.hashCode;
}

/// edit.format params
///
/// {
///   "file": String
///   "selectionOffset": int
///   "selectionLength": int
///   "selectionOnly": optional bool
///   "lineLength": optional int
///   "tabSize": optional TabSize
///   "insertSpaces": optional bool
///   "codeStyle": optional CodeStyle
/// }
///
/// Clients may not extend, implement or mix-in this class.
class EditFormatParams implements RequestParams
{
    /// The file containing the code to be formatted.
    String file;

    /// The offset of the current selection in the file.
    int selectionOffset;

    /// The length of the current selection in the file.
    int selectionLength;

    /// True if the code to be formatted should be limited to the selected text
    /// (or the smallest portion of text that encloses the selected text that can
    /// be formatted).
    /// defaults to false if not set.
    bool? selectionOnly;

    /// The line length to be used by the formatter.
    /// defaults to 90 if not set.
    int? lineLength;

    /// The tab size in spaces to be used by the formatter.
    /// defaults all indents to 4 if not set.
    TabSize? tabSize;

    /// True if the code to be formatted should use spaces for indentations,
    /// false to use tab stops. ignores [tabSize] if false.
    /// defaults to true if not set.
    bool? insertSpaces;

    /// Set of common code styles. default to 0 = dart_style with unlocked indent
    /// sizes. for more info check [CodeStyle] type.
    /// defaults to 0 if not set.
    CodeStyle? codeStyle;

    EditFormatParams(this.file, this.selectionOffset, this.selectionLength,
        {this.selectionOnly,
        this.lineLength,
        this.tabSize,
        this.insertSpaces,
        this.codeStyle});

    factory EditFormatParams.fromJson(
        JsonDecoder jsonDecoder, String jsonPath, Object? json)
    {
        json ??= {};
        if (json is Map)
        {
            String file;
            if (json.containsKey('file'))
            {
                file = jsonDecoder.decodeString('$jsonPath.file', json['file']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'file');
            }
            int selectionOffset;
            if (json.containsKey('selectionOffset'))
            {
                selectionOffset = jsonDecoder.decodeInt(
                    '$jsonPath.selectionOffset', json['selectionOffset']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'selectionOffset');
            }
            int selectionLength;
            if (json.containsKey('selectionLength'))
            {
                selectionLength = jsonDecoder.decodeInt(
                    '$jsonPath.selectionLength', json['selectionLength']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'selectionLength');
            }
            bool? selectionOnly;
            if (json.containsKey('selectionOnly'))
            {
                selectionOnly = jsonDecoder.decodeBool(
                    '$jsonPath.selectionOnly', json['selectionOnly']);
            }
            int? lineLength;
            if (json.containsKey('lineLength'))
            {
                lineLength =
                    jsonDecoder.decodeInt('$jsonPath.lineLength', json['lineLength']);
            }
            TabSize? tabSize;
            if (json.containsKey('tabSize'))
            {
                tabSize =
                    TabSize.fromJson(jsonDecoder, '$jsonPath.tabSize', json['tabSize']);
            }
            bool? insertSpaces;
            if (json.containsKey('insertSpaces'))
            {
                insertSpaces = jsonDecoder.decodeBool(
                    '$jsonPath.insertSpaces', json['insertSpaces']);
            }
            CodeStyle? codeStyle;
            if (json.containsKey('codeStyle'))
            {
                codeStyle = CodeStyle.fromJson(
                    jsonDecoder, '$jsonPath.codeStyle', json['codeStyle']);
            }
            return EditFormatParams(file, selectionOffset, selectionLength,
                selectionOnly: selectionOnly,
                lineLength: lineLength,
                tabSize: tabSize,
                insertSpaces: insertSpaces,
                codeStyle: codeStyle);
        }
        else
        {
            throw jsonDecoder.mismatch(jsonPath, 'edit.format params', json);
        }
    }

    factory EditFormatParams.fromRequest(Request request)
    {
        return EditFormatParams.fromJson(
            RequestDecoder(request), 'params', request.params);
    }

    @override
    Map<String, Object> toJson()
    {
        var result = <String, Object>{};
        result['file'] = file;
        result['selectionOffset'] = selectionOffset;
        result['selectionLength'] = selectionLength;
        var selectionOnly = this.selectionOnly;
        if (selectionOnly != null)
        {
            result['selectionOnly'] = selectionOnly;
        }
        var lineLength = this.lineLength;
        if (lineLength != null)
        {
            result['lineLength'] = lineLength;
        }
        var tabSize = this.tabSize;
        if (tabSize != null)
        {
            result['tabSize'] = tabSize.toJson();
        }
        var insertSpaces = this.insertSpaces;
        if (insertSpaces != null)
        {
            result['insertSpaces'] = insertSpaces;
        }
        var codeStyle = this.codeStyle;
        if (codeStyle != null)
        {
            result['codeStyle'] = codeStyle.toJson();
        }
        return result;
    }

    @override
    Request toRequest(String id)
    {
        return Request(id, 'edit.format', toJson());
    }

    @override
    String toString() => json.encode(toJson());

    @override
    bool operator ==(other)
    {
        if (other is EditFormatParams)
        {
            return file == other.file &&
                selectionOffset == other.selectionOffset &&
                selectionLength == other.selectionLength &&
                selectionOnly == other.selectionOnly &&
                lineLength == other.lineLength &&
                tabSize == other.tabSize &&
                insertSpaces == other.insertSpaces &&
                codeStyle == other.codeStyle;
        }
        return false;
    }

    @override
    int get hashCode => Object.hash(
            file,
            selectionOffset,
            selectionLength,
            selectionOnly,
            lineLength,
            tabSize,
            insertSpaces,
            codeStyle,
        );
}

/// edit.format result
///
/// {
///   "edits": List<SourceEdit>
///   "selectionOffset": int
///   "selectionLength": int
/// }
///
/// Clients may not extend, implement or mix-in this class.
class EditFormatResult implements ResponseResult
{
    /// The edit(s) to be applied in order to format the code. The list will be
    /// empty if the code was already formatted (there are no changes).
    List<SourceEdit> edits;

    /// The offset of the selection after formatting the code.
    int selectionOffset;

    /// The length of the selection after formatting the code.
    int selectionLength;

    EditFormatResult(this.edits, this.selectionOffset, this.selectionLength);

    factory EditFormatResult.fromJson(
        JsonDecoder jsonDecoder, String jsonPath, Object? json)
    {
        json ??= {};
        if (json is Map)
        {
            List<SourceEdit> edits;
            if (json.containsKey('edits'))
            {
                edits = jsonDecoder.decodeList(
                    '$jsonPath.edits',
                    json['edits'],
                    (String jsonPath, Object? json) =>
                        SourceEdit.fromJson(jsonDecoder, jsonPath, json));
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'edits');
            }
            int selectionOffset;
            if (json.containsKey('selectionOffset'))
            {
                selectionOffset = jsonDecoder.decodeInt(
                    '$jsonPath.selectionOffset', json['selectionOffset']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'selectionOffset');
            }
            int selectionLength;
            if (json.containsKey('selectionLength'))
            {
                selectionLength = jsonDecoder.decodeInt(
                    '$jsonPath.selectionLength', json['selectionLength']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'selectionLength');
            }
            return EditFormatResult(edits, selectionOffset, selectionLength);
        }
        else
        {
            throw jsonDecoder.mismatch(jsonPath, 'edit.format result', json);
        }
    }

    factory EditFormatResult.fromResponse(Response response)
    {
        return EditFormatResult.fromJson(
            ResponseDecoder(REQUEST_ID_REFACTORING_KINDS.remove(response.id)),
            'result',
            response.result);
    }

    @override
    Map<String, Object> toJson()
    {
        var result = <String, Object>{};
        result['edits'] = edits.map((SourceEdit value) => value.toJson()).toList();
        result['selectionOffset'] = selectionOffset;
        result['selectionLength'] = selectionLength;
        return result;
    }

    @override
    Response toResponse(String id)
    {
        return Response(id, result: toJson());
    }

    @override
    String toString() => json.encode(toJson());

    @override
    bool operator ==(other)
    {
        if (other is EditFormatResult)
        {
            return listEqual(
                    edits, other.edits, (SourceEdit a, SourceEdit b) => a == b) &&
                selectionOffset == other.selectionOffset &&
                selectionLength == other.selectionLength;
        }
        return false;
    }

    @override
    int get hashCode => Object.hash(
            Object.hashAll(edits),
            selectionOffset,
            selectionLength,
        );
}

/// RequestError
///
/// {
///   "code": RequestErrorCode
///   "message": String
///   "stackTrace": optional String
/// }
///
/// Clients may not extend, implement or mix-in this class.
class RequestError implements HasToJson
{
    /// A code that uniquely identifies the error that occurred.
    RequestErrorCode code;

    /// A short description of the error.
    String message;

    /// The stack trace associated with processing the request, used for
    /// debugging the server.
    String? stackTrace;

    RequestError(this.code, this.message, {this.stackTrace});

    factory RequestError.fromJson(JsonDecoder jsonDecoder, String jsonPath, Object? json)
    {
        json ??= {};
        if (json is Map)
        {
            RequestErrorCode code;
            if (json.containsKey('code'))
            {
                code = RequestErrorCode.fromJson(
                    jsonDecoder, '$jsonPath.code', json['code']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'code');
            }
            String message;
            if (json.containsKey('message'))
            {
                message = jsonDecoder.decodeString('$jsonPath.message', json['message']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'message');
            }
            String? stackTrace;
            if (json.containsKey('stackTrace'))
            {
                stackTrace =
                    jsonDecoder.decodeString('$jsonPath.stackTrace', json['stackTrace']);
            }
            return RequestError(code, message, stackTrace: stackTrace);
        }
        else
        {
            throw jsonDecoder.mismatch(jsonPath, 'RequestError', json);
        }
    }

    @override
    Map<String, Object> toJson()
    {
        var result = <String, Object>{};
        result['code'] = code.toJson();
        result['message'] = message;
        var stackTrace = this.stackTrace;
        if (stackTrace != null)
        {
            result['stackTrace'] = stackTrace;
        }
        return result;
    }

    @override
    String toString() => json.encode(toJson());

    @override
    bool operator ==(other)
    {
        if (other is RequestError)
        {
            return code == other.code &&
                message == other.message &&
                stackTrace == other.stackTrace;
        }
        return false;
    }

    @override
    int get hashCode => Object.hash(
            code,
            message,
            stackTrace,
        );
}

/// RequestErrorCode
///
/// enum {
///   FORMAT_INVALID_FILE
///   FORMAT_WITH_ERRORS
///   FORMAT_RANGE_ERROR
///   INVALID_FILE_PATH_FORMAT
///   INVALID_OVERLAY_CHANGE
///   INVALID_OVERLAY_RANGE
///   INVALID_PARAMETER
///   INVALID_REQUEST
///   SERVER_ALREADY_STARTED
///   SERVER_ERROR
///   UNKNOWN_REQUEST
///   UNSUPPORTED_FEATURE
/// }
///
/// Clients may not extend, implement or mix-in this class.
class RequestErrorCode implements Enum
{
    /// An "edit.format" request specified a FilePath which does not match a Dart
    /// file in an analysis root.
    static const RequestErrorCode FORMAT_INVALID_FILE =
        RequestErrorCode._('FORMAT_INVALID_FILE');

    /// An "edit.format" request specified a file that contains syntax errors.
    static const RequestErrorCode FORMAT_WITH_ERRORS =
        RequestErrorCode._('FORMAT_WITH_ERRORS');

    /// An "edit.format" request specified an invalid selection range.
    static const RequestErrorCode FORMAT_RANGE_ERROR =
        RequestErrorCode._('FORMAT_RANGE_ERROR');

    /// The format of the given file path is invalid, e.g. is not absolute and
    /// normalized.
    static const RequestErrorCode INVALID_FILE_PATH_FORMAT =
        RequestErrorCode._('INVALID_FILE_PATH_FORMAT');

    /// An "server.updateContent" request contained a ChangeContentOverlay object
    /// which can't be applied, due to not having a matching AddContentOverlay
    /// for this file. This happens if the clients does not send an "add" before
    /// subsecuent changes.
    static const RequestErrorCode INVALID_OVERLAY_CHANGE =
        RequestErrorCode._('INVALID_OVERLAY_CHANGE');

    /// An "server.updateContent" request contained a ChangeContentOverlay object
    /// which can't be applied, due to an edit having an offset or length that is
    /// out of range.
    static const RequestErrorCode INVALID_OVERLAY_RANGE =
        RequestErrorCode._('INVALID_OVERLAY_RANGE');

    /// One of the method parameters was invalid.
    static const RequestErrorCode INVALID_PARAMETER =
        RequestErrorCode._('INVALID_PARAMETER');

    /// A malformed request was received.
    static const RequestErrorCode INVALID_REQUEST = RequestErrorCode._('INVALID_REQUEST');

    /// The formatter server has already been started (and hence won't accept new
    /// connections).
    ///
    /// This error is included for future expansion; at present the formatter
    /// server can only speak to one client at a time so this error will never
    /// occur.
    static const RequestErrorCode SERVER_ALREADY_STARTED =
        RequestErrorCode._('SERVER_ALREADY_STARTED');

    /// An internal error occurred in the formatter server. Also see the
    /// server.error notification.
    static const RequestErrorCode SERVER_ERROR = RequestErrorCode._('SERVER_ERROR');

    /// A request was received which the formatter server does not recognize, or
    /// cannot handle in its current configuration.
    static const RequestErrorCode UNKNOWN_REQUEST = RequestErrorCode._('UNKNOWN_REQUEST');

    /// The formatter server was requested to perform an action which is not
    /// supported.
    ///
    /// This is a legacy error; it will be removed before the API reaches version
    /// 1.0.
    static const RequestErrorCode UNSUPPORTED_FEATURE =
        RequestErrorCode._('UNSUPPORTED_FEATURE');

    /// A list containing all of the enum values that are defined.
    static const List<RequestErrorCode> VALUES = <RequestErrorCode>[
        FORMAT_INVALID_FILE,
        FORMAT_WITH_ERRORS,
        FORMAT_RANGE_ERROR,
        INVALID_FILE_PATH_FORMAT,
        INVALID_OVERLAY_CHANGE,
        INVALID_OVERLAY_RANGE,
        INVALID_PARAMETER,
        INVALID_REQUEST,
        SERVER_ALREADY_STARTED,
        SERVER_ERROR,
        UNKNOWN_REQUEST,
        UNSUPPORTED_FEATURE
    ];

    @override
    final String name;

    const RequestErrorCode._(this.name);

    factory RequestErrorCode(String name)
    {
        switch (name)
        {
            case 'FORMAT_INVALID_FILE':
                return FORMAT_INVALID_FILE;
            case 'FORMAT_WITH_ERRORS':
                return FORMAT_WITH_ERRORS;
            case 'FORMAT_RANGE_ERROR':
                return FORMAT_RANGE_ERROR;
            case 'INVALID_FILE_PATH_FORMAT':
                return INVALID_FILE_PATH_FORMAT;
            case 'INVALID_OVERLAY_CHANGE':
                return INVALID_OVERLAY_CHANGE;
            case 'INVALID_OVERLAY_RANGE':
                return INVALID_OVERLAY_RANGE;
            case 'INVALID_PARAMETER':
                return INVALID_PARAMETER;
            case 'INVALID_REQUEST':
                return INVALID_REQUEST;
            case 'SERVER_ALREADY_STARTED':
                return SERVER_ALREADY_STARTED;
            case 'SERVER_ERROR':
                return SERVER_ERROR;
            case 'UNKNOWN_REQUEST':
                return UNKNOWN_REQUEST;
            case 'UNSUPPORTED_FEATURE':
                return UNSUPPORTED_FEATURE;
        }
        throw Exception('Illegal enum value: $name');
    }

    factory RequestErrorCode.fromJson(
        JsonDecoder jsonDecoder, String jsonPath, Object? json)
    {
        if (json is String)
        {
            try
            {
                return RequestErrorCode(json);
            }
            catch (_)
            {
                // Fall through
            }
        }
        throw jsonDecoder.mismatch(jsonPath, 'RequestErrorCode', json);
    }

    @override
    String toString() => 'RequestErrorCode.$name';

    String toJson() => name;
}

/// server.connected params
///
/// {
///   "version": String
///   "pid": int
/// }
///
/// Clients may not extend, implement or mix-in this class.
class ServerConnectedParams implements HasToJson
{
    /// The version number of the formatter server.
    String version;

    /// The process id of the formatter server process.
    int pid;

    ServerConnectedParams(this.version, this.pid);

    factory ServerConnectedParams.fromJson(
        JsonDecoder jsonDecoder, String jsonPath, Object? json)
    {
        json ??= {};
        if (json is Map)
        {
            String version;
            if (json.containsKey('version'))
            {
                version = jsonDecoder.decodeString('$jsonPath.version', json['version']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'version');
            }
            int pid;
            if (json.containsKey('pid'))
            {
                pid = jsonDecoder.decodeInt('$jsonPath.pid', json['pid']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'pid');
            }
            return ServerConnectedParams(version, pid);
        }
        else
        {
            throw jsonDecoder.mismatch(jsonPath, 'server.connected params', json);
        }
    }

    factory ServerConnectedParams.fromNotification(Notification notification)
    {
        return ServerConnectedParams.fromJson(
            ResponseDecoder(null), 'params', notification.params);
    }

    @override
    Map<String, Object> toJson()
    {
        var result = <String, Object>{};
        result['version'] = version;
        result['pid'] = pid;
        return result;
    }

    Notification toNotification()
    {
        return Notification('server.connected', toJson());
    }

    @override
    String toString() => json.encode(toJson());

    @override
    bool operator ==(other)
    {
        if (other is ServerConnectedParams)
        {
            return version == other.version && pid == other.pid;
        }
        return false;
    }

    @override
    int get hashCode => Object.hash(
            version,
            pid,
        );
}

/// server.error params
///
/// {
///   "isFatal": bool
///   "message": String
///   "stackTrace": String
/// }
///
/// Clients may not extend, implement or mix-in this class.
class ServerErrorParams implements HasToJson
{
    /// True if the error is a fatal error, meaning that the server will shutdown
    /// automatically after sending this notification.
    bool isFatal;

    /// The error message indicating what kind of error was encountered.
    String message;

    /// The stack trace associated with the generation of the error, used for
    /// debugging the server.
    String stackTrace;

    ServerErrorParams(this.isFatal, this.message, this.stackTrace);

    factory ServerErrorParams.fromJson(
        JsonDecoder jsonDecoder, String jsonPath, Object? json)
    {
        json ??= {};
        if (json is Map)
        {
            bool isFatal;
            if (json.containsKey('isFatal'))
            {
                isFatal = jsonDecoder.decodeBool('$jsonPath.isFatal', json['isFatal']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'isFatal');
            }
            String message;
            if (json.containsKey('message'))
            {
                message = jsonDecoder.decodeString('$jsonPath.message', json['message']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'message');
            }
            String stackTrace;
            if (json.containsKey('stackTrace'))
            {
                stackTrace =
                    jsonDecoder.decodeString('$jsonPath.stackTrace', json['stackTrace']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'stackTrace');
            }
            return ServerErrorParams(isFatal, message, stackTrace);
        }
        else
        {
            throw jsonDecoder.mismatch(jsonPath, 'server.error params', json);
        }
    }

    factory ServerErrorParams.fromNotification(Notification notification)
    {
        return ServerErrorParams.fromJson(
            ResponseDecoder(null), 'params', notification.params);
    }

    @override
    Map<String, Object> toJson()
    {
        var result = <String, Object>{};
        result['isFatal'] = isFatal;
        result['message'] = message;
        result['stackTrace'] = stackTrace;
        return result;
    }

    Notification toNotification()
    {
        return Notification('server.error', toJson());
    }

    @override
    String toString() => json.encode(toJson());

    @override
    bool operator ==(other)
    {
        if (other is ServerErrorParams)
        {
            return isFatal == other.isFatal &&
                message == other.message &&
                stackTrace == other.stackTrace;
        }
        return false;
    }

    @override
    int get hashCode => Object.hash(
            isFatal,
            message,
            stackTrace,
        );
}

/// server.getVersion params
///
/// Clients may not extend, implement or mix-in this class.
class ServerGetVersionParams implements RequestParams
{
    @override
    Map<String, Object> toJson() => {};

    @override
    Request toRequest(String id)
    {
        return Request(id, 'server.getVersion', null);
    }

    @override
    bool operator ==(other) => other is ServerGetVersionParams;

    @override
    int get hashCode => 55877452;
}

/// server.getVersion result
///
/// {
///   "version": String
///   "protocol": String
/// }
///
/// Clients may not extend, implement or mix-in this class.
class ServerGetVersionResult implements ResponseResult
{
    /// The version number of the formatter server
    String version;

    /// The version number of the API Protocol used in the formatter server
    String protocol;

    ServerGetVersionResult(this.version, this.protocol);

    factory ServerGetVersionResult.fromJson(
        JsonDecoder jsonDecoder, String jsonPath, Object? json)
    {
        json ??= {};
        if (json is Map)
        {
            String version;
            if (json.containsKey('version'))
            {
                version = jsonDecoder.decodeString('$jsonPath.version', json['version']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'version');
            }
            String protocol;
            if (json.containsKey('protocol'))
            {
                protocol =
                    jsonDecoder.decodeString('$jsonPath.protocol', json['protocol']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'protocol');
            }
            return ServerGetVersionResult(version, protocol);
        }
        else
        {
            throw jsonDecoder.mismatch(jsonPath, 'server.getVersion result', json);
        }
    }

    factory ServerGetVersionResult.fromResponse(Response response)
    {
        return ServerGetVersionResult.fromJson(
            ResponseDecoder(REQUEST_ID_REFACTORING_KINDS.remove(response.id)),
            'result',
            response.result);
    }

    @override
    Map<String, Object> toJson()
    {
        var result = <String, Object>{};
        result['version'] = version;
        result['protocol'] = protocol;
        return result;
    }

    @override
    Response toResponse(String id)
    {
        return Response(id, result: toJson());
    }

    @override
    String toString() => json.encode(toJson());

    @override
    bool operator ==(other)
    {
        if (other is ServerGetVersionResult)
        {
            return version == other.version && protocol == other.protocol;
        }
        return false;
    }

    @override
    int get hashCode => Object.hash(
            version,
            protocol,
        );
}

/// server.shutdown params
///
/// Clients may not extend, implement or mix-in this class.
class ServerShutdownParams implements RequestParams
{
    @override
    Map<String, Object> toJson() => {};

    @override
    Request toRequest(String id)
    {
        return Request(id, 'server.shutdown', null);
    }

    @override
    bool operator ==(other) => other is ServerShutdownParams;

    @override
    int get hashCode => 366630911;
}

/// server.shutdown result
///
/// Clients may not extend, implement or mix-in this class.
class ServerShutdownResult implements ResponseResult
{
    @override
    Map<String, Object> toJson() => {};

    @override
    Response toResponse(String id)
    {
        return Response(id, result: null);
    }

    @override
    bool operator ==(other) => other is ServerShutdownResult;

    @override
    int get hashCode => 193626532;
}

/// server.updateContent params
///
/// {
///   "files": Map<FilePath, AddContentOverlay | ChangeContentOverlay | RemoveContentOverlay>
/// }
///
/// Clients may not extend, implement or mix-in this class.
class ServerUpdateContentParams implements RequestParams
{
    /// A table mapping the files whose content has changed to a description of
    /// the content change.
    Map<String, Object> files;

    ServerUpdateContentParams(this.files);

    factory ServerUpdateContentParams.fromJson(
        JsonDecoder jsonDecoder, String jsonPath, Object? json)
    {
        json ??= {};
        if (json is Map)
        {
            Map<String, Object> files;
            if (json.containsKey('files'))
            {
                files = jsonDecoder.decodeMap('$jsonPath.files', json['files'],
                    valueDecoder: (String jsonPath, Object? json) =>
                        jsonDecoder.decodeUnion(jsonPath, json, 'type', {
                            'add': (String jsonPath, Object? json) =>
                                AddContentOverlay.fromJson(jsonDecoder, jsonPath, json),
                            'change': (String jsonPath, Object? json) =>
                                ChangeContentOverlay.fromJson(
                                    jsonDecoder, jsonPath, json),
                            'remove': (String jsonPath, Object? json) =>
                                RemoveContentOverlay.fromJson(jsonDecoder, jsonPath, json)
                        }));
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'files');
            }
            return ServerUpdateContentParams(files);
        }
        else
        {
            throw jsonDecoder.mismatch(jsonPath, 'server.updateContent params', json);
        }
    }

    factory ServerUpdateContentParams.fromRequest(Request request)
    {
        return ServerUpdateContentParams.fromJson(
            RequestDecoder(request), 'params', request.params);
    }

    @override
    Map<String, Object> toJson()
    {
        var result = <String, Object>{};
        result['files'] =
            mapMap(files, valueCallback: (Object value) => (value as dynamic).toJson());
        return result;
    }

    @override
    Request toRequest(String id)
    {
        return Request(id, 'server.updateContent', toJson());
    }

    @override
    String toString() => json.encode(toJson());

    @override
    bool operator ==(other)
    {
        if (other is ServerUpdateContentParams)
        {
            return mapEqual(files, other.files, (Object a, Object b) => a == b);
        }
        return false;
    }

    @override
    int get hashCode => Object.hashAll([...files.keys, ...files.values]);
}

/// server.updateContent result
///
/// {
/// }
///
/// Clients may not extend, implement or mix-in this class.
class ServerUpdateContentResult implements ResponseResult
{
    ServerUpdateContentResult();

    factory ServerUpdateContentResult.fromJson(
        JsonDecoder jsonDecoder, String jsonPath, Object? json)
    {
        json ??= {};
        if (json is Map)
        {
            return ServerUpdateContentResult();
        }
        else
        {
            throw jsonDecoder.mismatch(jsonPath, 'server.updateContent result', json);
        }
    }

    factory ServerUpdateContentResult.fromResponse(Response response)
    {
        return ServerUpdateContentResult.fromJson(
            ResponseDecoder(REQUEST_ID_REFACTORING_KINDS.remove(response.id)),
            'result',
            response.result);
    }

    @override
    Map<String, Object> toJson()
    {
        var result = <String, Object>{};
        return result;
    }

    @override
    Response toResponse(String id)
    {
        return Response(id, result: toJson());
    }

    @override
    String toString() => json.encode(toJson());

    @override
    bool operator ==(other)
    {
        if (other is ServerUpdateContentResult)
        {
            return true;
        }
        return false;
    }

    @override
    int get hashCode => 0;
}

/// TabSize
///
/// {
///   "block": int
///   "cascade": int
///   "expression": int
///   "constructorInitializer": int
/// }
///
/// Clients may not extend, implement or mix-in this class.
class TabSize implements HasToJson
{
    /// The number of spaces in a block or collection body.
    int block;

    /// How much wrapped cascade sections indent.
    int cascade;

    /// The number of spaces in a single level of expression nesting.
    int expression;

    /// The ":" on a wrapped constructor initialization list.
    int constructorInitializer;

    TabSize(this.block, this.cascade, this.expression, this.constructorInitializer);

    factory TabSize.fromJson(JsonDecoder jsonDecoder, String jsonPath, Object? json)
    {
        json ??= {};
        if (json is Map)
        {
            int block;
            if (json.containsKey('block'))
            {
                block = jsonDecoder.decodeInt('$jsonPath.block', json['block']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'block');
            }
            int cascade;
            if (json.containsKey('cascade'))
            {
                cascade = jsonDecoder.decodeInt('$jsonPath.cascade', json['cascade']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'cascade');
            }
            int expression;
            if (json.containsKey('expression'))
            {
                expression =
                    jsonDecoder.decodeInt('$jsonPath.expression', json['expression']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'expression');
            }
            int constructorInitializer;
            if (json.containsKey('constructorInitializer'))
            {
                constructorInitializer = jsonDecoder.decodeInt(
                    '$jsonPath.constructorInitializer', json['constructorInitializer']);
            }
            else
            {
                throw jsonDecoder.mismatch(jsonPath, 'constructorInitializer');
            }
            return TabSize(block, cascade, expression, constructorInitializer);
        }
        else
        {
            throw jsonDecoder.mismatch(jsonPath, 'TabSize', json);
        }
    }

    @override
    Map<String, Object> toJson()
    {
        var result = <String, Object>{};
        result['block'] = block;
        result['cascade'] = cascade;
        result['expression'] = expression;
        result['constructorInitializer'] = constructorInitializer;
        return result;
    }

    @override
    String toString() => json.encode(toJson());

    @override
    bool operator ==(other)
    {
        if (other is TabSize)
        {
            return block == other.block &&
                cascade == other.cascade &&
                expression == other.expression &&
                constructorInitializer == other.constructorInitializer;
        }
        return false;
    }

    @override
    int get hashCode => Object.hash(
            block,
            cascade,
            expression,
            constructorInitializer,
        );
}
