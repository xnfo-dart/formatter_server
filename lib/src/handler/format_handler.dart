// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/error/listener.dart';

import 'package:analyzer_plugin/protocol/protocol_common.dart' hide Position;

import "package:dart_polisher/dart_polisher.dart" hide CodeStyle;
import 'package:dart_polisher/dart_polisher.dart' as dartformatter
    show CodeStyle; // API Protocol uses same name.
import 'package:formatter_server/src/format_server.dart';
import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/protocol/protocol_generated.dart';
import 'package:formatter_server/src/handler/abstract_handler.dart';

import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/token.dart';

import 'package:_fe_analyzer_shared/src/scanner/reader.dart';

// For performance reasons, so we dont recreate it on every request.
DartFormatter formatter = DartFormatter(FormatterOptions());

// The handler for the `edit.format` request.
class EditFormatHandler extends Handler
{
    /// Initialize a newly created handler to be able to service requests for the
    /// [server].
    EditFormatHandler(FormatServer server, Request request) : super(server, request);

    @override
    Future<void> handle() async
    {
        // Throw RequestFailure when validating json fields.
        var params = EditFormatParams.fromRequest(request);
        var file = params.file;

        String unformattedCode;
        try
        {
            // The [resouseProvider] is managed by an overlay, wich is updated (onOpen onChange onClose) from Clients.
            // Its the responsibility of the client to update the overlay using the API.
            var resource = server.resourceProvider.getFile(file);
            unformattedCode = resource.readAsStringSync();
        }
        catch (e)
        {
            sendResponse(Response.formatInvalidFile(request));
            return;
        }

        int? start = params.selectionOffset;
        int? length = params.selectionLength;

        // No need to preserve 0,0 selection
        if (start == 0 && length == 0)
        {
            start = null;
            length = null;
        }

        SourceCode formattedResult;
        var edits = <SourceEdit>[];
        try
        {
            // Translate selection and file contents from API to SourceCode
            final sourceCode = SourceCode(unformattedCode,
                uri: null,
                isCompilationUnit: true,
                selectionStart: start,
                selectionLength: length);

            // Translate CodeStyle from API to dart_formatter.CodeStyle.
            final style = dartformatter.CodeStyle.getEnum(params.codeStyle?.code);

            // Translate tab sizes from API to CodeIndent.
            final tabSizes = CodeIndent.opt(
                block: params.tabSize?.block,
                expression: params.tabSize?.expression,
                cascade: params.tabSize?.cascade,
                constructorInitializer: params.tabSize?.constructorInitializer,
            );

            // Finally assemble all into FormatterOptions to be used by the DartFormatter.
            final fo = FormatterOptions.opt(
                pageWidth: params.lineLength,
                insertSpaces: params.insertSpaces,
                style: style,
                tabSizes: tabSizes,
            );

            // Create new instance only if settings have changed.
            if (formatter.options != fo) formatter = DartFormatter(fo);

            // Format source code.
            formattedResult = formatter.formatSource(sourceCode);
            final formattedSource = formattedResult.text;

            if (formattedSource != unformattedCode)
            {
                OffsetRange? range;
                if (params.selectionOnly ?? false)
                {
                    range = OffsetRange(
                        start: params.selectionOffset,
                        end: params.selectionOffset + params.selectionLength);
                }

                edits =
                    _generateMinimalEdits(unformattedCode, formattedSource, range: range);
            }
        }
        on ArgumentError // RangeError is included by this base class
        {
            // SourceCode and _generateMinimalEdits throws this type.
            sendResponse(Response.formatRangeError(request, unformattedCode.length,
                params.selectionOffset, params.selectionOffset + params.selectionLength));
            return;
        }
        on FormatterException
        {
            sendResponse(Response.formatWithErrors(request));
            return;
        }

        var newStart = formattedResult.selectionStart;
        var newLength = formattedResult.selectionLength;

        // Sending null start/length values would violate protocol, so convert back
        // to 0.
        newStart ??= 0;
        newLength ??= 0;

        sendResult(EditFormatResult(edits, newStart, newLength));
    }
}

// A text range using zero based offsets [start] and [end]
class OffsetRange
{
    OffsetRange({required this.start, required this.end});

    /// The range's start offset. (zero-based)
    final int start;

    /// The range's end offset. (zero-based)
    final int end;
}

//**********************************************************************************
//* Below implementations are taken/adapted to work with a non-lsp protocol from
//* https://github.com/dart-lang/sdk/tree/master/pkg/analysis_server/lib/src/lsp/source_edits.dart

List<SourceEdit> _generateFullEdit(String unformattedSource, String formattedSource)
{
    return [SourceEdit(0, unformattedSource.length, formattedSource)];
}

/// Generates edits that modify the minimum amount of code (only whitespace) to
/// change [unformattedCode] to [formatted].
///
/// This allows editors to more easily track important locations (such as
/// breakpoints) without needing to do their own diffing.
///
/// If [range] is supplied, only whitespace edits that fall entirely inside this
/// range will be included in the results. (range from [unformattedCode])
///
/// Throws Exception [RangeError] if range is not null and contains an invalid
/// range inside [unformattedCode]
List<SourceEdit> _generateMinimalEdits(String unformattedCode, String formatted,
    {OffsetRange? range})
{
    // TODO (tekert): parsing here is not really necessesary, [result] is only
    // used to get source code, lineInfo and featureset wich we already have from the formatter.
    // formatter.formatSource(code); already parses the code, we dont need to do it twice.
    // its 6x times slower than the Scanner for tokens. 6ms vs 1ms on most files
    var featureSet = FeatureSet.latestLanguageVersion();
    ParseStringResult resultUnformatted = parseString(
        content: unformattedCode, featureSet: featureSet, throwIfDiagnostics: false);

    final unformatted = resultUnformatted.content;
    //final lineInfo = result.lineInfo;
    final rangeStart = range?.start;
    final rangeEnd = range?.end;

    if (rangeStart != null)
    {
        RangeError.checkValueInInterval(
            rangeStart, 0, resultUnformatted.unit.length, "range.start");
    }
    if (rangeEnd != null)
    {
        RangeError.checkValueInInterval(
            rangeEnd, rangeStart ?? 0, resultUnformatted.unit.length, "range.end");
    }

    // It shouldn't be the case that we can't parse the code but if it happens
    // fall back to a full replacement rather than fail.
    final parsedFormatted = _parse(formatted, resultUnformatted.unit.featureSet);
    final parsedUnformatted = _parse(unformatted,
        resultUnformatted.unit.featureSet); // or resultUnformatted.unit.beginToken
    if (parsedFormatted == null || parsedUnformatted == null)
    {
        return _generateFullEdit(unformatted, formatted);
    }

    final unformattedTokens = _iterateAllTokens(parsedUnformatted).iterator;
    final formattedTokens = _iterateAllTokens(parsedFormatted).iterator;

    var unformattedOffset = 0;
    var formattedOffset = 0;
    final edits = <SourceEdit>[];

    /// Helper for comparing whitespace and appending an edit.
    void addEditFor(
        int unformattedStart,
        int unformattedEnd,
        int formattedStart,
        int formattedEnd,
    )
    {
        final unformattedWhitespace =
            unformatted.substring(unformattedStart, unformattedEnd);
        final formattedWhitespace = formatted.substring(formattedStart, formattedEnd);

        if (rangeStart != null && rangeEnd != null)
        {
            // If this change crosses over the start of the requested range, discarding
            // the change may result in leading whitespace of the next line not being
            // formatted correctly.
            //
            // To handle this, if both unformatted/formatted contain at least one
            // newline, split this change into two around the last newline so that the
            // final part (likely leading whitespace) can be included without
            // including the whole change. This cannot be done if the newline is at
            // the end of the source whitespace though, as this would create a split
            // where the first part is the same and the second part is empty,
            // resulting in an infinite loop/stack overflow.
            //
            // Without this, functionality like VS Code's "format modified lines"
            // (which uses Git status to know which lines are edited) may appear to
            // fail to format the first newly added line in a range.
            if (unformattedStart < rangeStart &&
                unformattedEnd > rangeStart &&
                unformattedWhitespace.contains('\n') &&
                formattedWhitespace.contains('\n') &&
                !unformattedWhitespace.endsWith('\n'))
            {
                // Find the offsets of the character after the last newlines.
                final unformattedOffset = unformattedWhitespace.lastIndexOf('\n') + 1;
                final formattedOffset = formattedWhitespace.lastIndexOf('\n') + 1;
                // Call us again for the leading part
                addEditFor(
                    unformattedStart,
                    unformattedStart + unformattedOffset,
                    formattedStart,
                    formattedStart + formattedOffset,
                );
                // Call us again for the trailing part
                addEditFor(
                    unformattedStart + unformattedOffset,
                    unformattedEnd,
                    formattedStart + formattedOffset,
                    formattedEnd,
                );
                return;
            }

            // If we're formatting only a range, skip over any segments that don't fall
            // entirely within that range.
            if (unformattedStart < rangeStart || unformattedEnd > rangeEnd)
            {
                return;
            }
        }

        if (unformattedWhitespace == formattedWhitespace)
        {
            return;
        }

        // Validate we didn't find more than whitespace. If this occurs, it's likely
        // the token offsets used were incorrect. In this case it's better to not
        // modify the code than potentially remove something important.
        if (unformattedWhitespace.trim().isNotEmpty ||
            formattedWhitespace.trim().isNotEmpty)
        {
            return;
        }

        var startOffset = unformattedStart;
        var endOffset = unformattedEnd;
        var newText = formattedWhitespace;

        // Simplify some common cases where the new whitespace is a subset of
        // the old.
        if (formattedWhitespace.isNotEmpty)
        {
            if (unformattedWhitespace.startsWith(formattedWhitespace))
            {
                startOffset = unformattedStart + formattedWhitespace.length;
                newText = '';
            }
            else if (unformattedWhitespace.endsWith(formattedWhitespace))
            {
                endOffset = unformattedEnd - formattedWhitespace.length;
                newText = '';
            }
        }

        // Finally, append the edit for this whitespace.
        // Note: As with all LSP edits, offsets are based on the original location
        // as they are applied in one shot. They should not account for the previous
        // edits in the same set.
        edits.add(SourceEdit(startOffset, endOffset - startOffset, newText));
    }

    // Process the whitespace before each token.
    bool unformattedHasMore, formattedHasMore;
    while ((unformattedHasMore = unformattedTokens.moveNext()) & // Don't short-circuit
        (formattedHasMore = formattedTokens.moveNext()))
    {
        final unformattedToken = unformattedTokens.current;
        final formattedToken = formattedTokens.current;

        if (unformattedToken.lexeme != formattedToken.lexeme)
        {
            // If the token lexems do not match, there is a difference in the parsed
            // token streams (this should not ordinarily happen) so fall back to a
            // full edit.
            return _generateFullEdit(unformatted, formatted);
        }

        addEditFor(
            unformattedOffset,
            unformattedToken.offset,
            formattedOffset,
            formattedToken.offset,
        );

        // When range formatting, if we've processed a token that ends after the
        // range then there can't be any more relevant edits and we can return early.
        if (rangeEnd != null && unformattedToken.end > rangeEnd)
        {
            return edits;
        }

        unformattedOffset = unformattedToken.end;
        formattedOffset = formattedToken.end;
    }

    // If we got here and either of the streams still have tokens, something
    // did not match so fall back to a full edit.
    if (unformattedHasMore || formattedHasMore)
    {
        return _generateFullEdit(unformatted, formatted);
    }

    // Finally, handle any whitespace that was after the last token.
    addEditFor(
        unformattedOffset,
        unformatted.length,
        formattedOffset,
        formatted.length,
    );

    return edits;
}

/// Iterates over a token stream returning all tokens including comments.
Iterable<Token> _iterateAllTokens(Token token) sync*
{
    while (token.type != TokenType.EOF)
    {
        Token? commentToken = token.precedingComments;
        while (commentToken != null)
        {
            yield commentToken;
            commentToken = commentToken.next;
        }
        yield token;
        token = token.next!;
    }
}

/// Parse and return the first [Token] of the given Dart source, `null` if code cannot
/// be parsed.
Token? _parse(String s, FeatureSet featureSet)
{
    // parseString from 'package:analyzer/dart/analysis/utilities.dart'
    // is using this to obtain tokens, Scanner uses Source and AnalysisErrorListener
    // to report errors, and we dont need them so we use a _SourceMock and NULL_LISTENER,
    // we could use StringSource(s) either way as Source but will no be used.
    try
    {
        var scanner =
            Scanner(_SourceMock.instance, CharSequenceReader(s), AnalysisErrorListener.NULL_LISTENER)
                ..configureFeatures(
                    featureSetForOverriding: featureSet,
                    featureSet: featureSet,
                );
        return scanner.tokenize();
    }
    catch (e)
    {
        return null;
    }
}

class _SourceMock implements Source
{
    static final Source instance = _SourceMock();

    @override
    dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
