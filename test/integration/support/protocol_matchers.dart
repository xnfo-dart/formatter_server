// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// This file has been automatically generated. Please do not edit it manually.
// To regenerate the file, use the script
// "tool/protocol_spec/generate.dart".

/// Matchers for data types defined in the analysis server API.
import 'package:test/test.dart';

import 'integration_tests.dart';

/// AddContentOverlay
///
/// {
///   "type": "add"
///   "content": String
/// }
final Matcher isAddContentOverlay = LazyMatcher(() => MatchesJsonObject(
    'AddContentOverlay', {'type': equals('add'), 'content': isString}));

/// ChangeContentOverlay
///
/// {
///   "type": "change"
///   "edits": List<SourceEdit>
/// }
final Matcher isChangeContentOverlay = LazyMatcher(() => MatchesJsonObject(
    'ChangeContentOverlay',
    {'type': equals('change'), 'edits': isListOf(isSourceEdit)}));

/// CodeStyle
///
/// {
///   "code": int
/// }
final Matcher isCodeStyle =
    LazyMatcher(() => MatchesJsonObject('CodeStyle', {'code': isInt}));

/// FilePath
///
/// String
final Matcher isFilePath = isString;

/// Position
///
/// {
///   "file": FilePath
///   "offset": int
/// }
final Matcher isPosition = LazyMatcher(
    () => MatchesJsonObject('Position', {'file': isFilePath, 'offset': isInt}));

/// RemoveContentOverlay
///
/// {
///   "type": "remove"
/// }
final Matcher isRemoveContentOverlay = LazyMatcher(() =>
    MatchesJsonObject('RemoveContentOverlay', {'type': equals('remove')}));

/// RequestError
///
/// {
///   "code": RequestErrorCode
///   "message": String
///   "stackTrace": optional String
/// }
final Matcher isRequestError = LazyMatcher(() => MatchesJsonObject(
    'RequestError', {'code': isRequestErrorCode, 'message': isString},
    optionalFields: {'stackTrace': isString}));

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
final Matcher isRequestErrorCode = MatchesEnum('RequestErrorCode', [
  'FORMAT_INVALID_FILE',
  'FORMAT_WITH_ERRORS',
  'FORMAT_RANGE_ERROR',
  'INVALID_FILE_PATH_FORMAT',
  'INVALID_OVERLAY_CHANGE',
  'INVALID_OVERLAY_RANGE',
  'INVALID_PARAMETER',
  'INVALID_REQUEST',
  'SERVER_ALREADY_STARTED',
  'SERVER_ERROR',
  'UNKNOWN_REQUEST',
  'UNSUPPORTED_FEATURE'
]);

/// SourceEdit
///
/// {
///   "offset": int
///   "length": int
///   "replacement": String
///   "id": optional String
/// }
final Matcher isSourceEdit = LazyMatcher(() => MatchesJsonObject(
    'SourceEdit', {'offset': isInt, 'length': isInt, 'replacement': isString},
    optionalFields: {'id': isString}));

/// SourceFileEdit
///
/// {
///   "file": FilePath
///   "fileStamp": long
///   "edits": List<SourceEdit>
/// }
final Matcher isSourceFileEdit = LazyMatcher(() => MatchesJsonObject(
    'SourceFileEdit',
    {'file': isFilePath, 'fileStamp': isInt, 'edits': isListOf(isSourceEdit)}));

/// TabSize
///
/// {
///   "block": int
///   "cascade": int
///   "expression": int
///   "constructorInitializer": int
/// }
final Matcher isTabSize = LazyMatcher(() => MatchesJsonObject('TabSize', {
      'block': isInt,
      'cascade': isInt,
      'expression': isInt,
      'constructorInitializer': isInt
    }));

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
final Matcher isEditFormatParams =
    LazyMatcher(() => MatchesJsonObject('edit.format params', {
          'file': isString,
          'selectionOffset': isInt,
          'selectionLength': isInt
        }, optionalFields: {
          'selectionOnly': isBool,
          'lineLength': isInt,
          'tabSize': isTabSize,
          'insertSpaces': isBool,
          'codeStyle': isCodeStyle
        }));

/// edit.format result
///
/// {
///   "edits": List<SourceEdit>
///   "selectionOffset": int
///   "selectionLength": int
/// }
final Matcher isEditFormatResult =
    LazyMatcher(() => MatchesJsonObject('edit.format result', {
          'edits': isListOf(isSourceEdit),
          'selectionOffset': isInt,
          'selectionLength': isInt
        }));

/// server.connected params
///
/// {
///   "version": String
///   "pid": int
/// }
final Matcher isServerConnectedParams = LazyMatcher(() => MatchesJsonObject(
    'server.connected params', {'version': isString, 'pid': isInt}));

/// server.error params
///
/// {
///   "isFatal": bool
///   "message": String
///   "stackTrace": String
/// }
final Matcher isServerErrorParams = LazyMatcher(() => MatchesJsonObject(
    'server.error params',
    {'isFatal': isBool, 'message': isString, 'stackTrace': isString}));

/// server.getVersion params
final Matcher isServerGetVersionParams = isNull;

/// server.getVersion result
///
/// {
///   "version": String
/// }
final Matcher isServerGetVersionResult = LazyMatcher(
    () => MatchesJsonObject('server.getVersion result', {'version': isString}));

/// server.shutdown params
final Matcher isServerShutdownParams = isNull;

/// server.shutdown result
final Matcher isServerShutdownResult = isNull;

/// server.updateContent params
///
/// {
///   "files": Map<FilePath, AddContentOverlay | ChangeContentOverlay | RemoveContentOverlay>
/// }
final Matcher isServerUpdateContentParams =
    LazyMatcher(() => MatchesJsonObject('server.updateContent params', {
          'files': isMapOf(
              isFilePath,
              isOneOf([
                isAddContentOverlay,
                isChangeContentOverlay,
                isRemoveContentOverlay
              ]))
        }));

/// server.updateContent result
///
/// {
/// }
final Matcher isServerUpdateContentResult =
    LazyMatcher(() => MatchesJsonObject('server.updateContent result', null));
