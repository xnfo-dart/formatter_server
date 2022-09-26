// Util methods for string manipulation

import 'dart:convert';

import 'package:analyzer_plugin/protocol/protocol_common.dart' show SourceEdit;

/// Split new lines but returns start and end offsets instead of substrings.
/// It should be on the standard library.
extension SplitOffset on LineSplitter
{
    // Character constants.
    static const int _LF = 10;
    static const int _CR = 13;

    /// This should be on the standard library, changed to return offset Ranges.
    /// Taken from LineSplitter.split();
    ///
    /// Split [lines] into individual lines.
    ///
    /// If [start] and [end] are provided, only split the contents of
    /// `lines.substring(start, end)`. The [start] and [end] values must
    /// specify a valid sub-range of [lines]
    /// (`0 <= start <= end <= lines.length`).
    ///
    /// Returns [LineRange]s that contain start and end line offsets.
    Iterable<LineRange> splitOffset(final String lines, [int start = 0, int? end]) sync*
    {
        // ignore: parameter_assignments
        end = RangeError.checkValidRange(start, end, lines.length);

        var sliceStart = start;
        var char = 0;
        for (var i = start; i < end; i++)
        {
            final previousChar = char;
            char = lines.codeUnitAt(i);
            if (char != _CR)
            {
                if (char != _LF) continue;
                if (previousChar == _CR)
                {
                    sliceStart = i + 1;
                    continue;
                }
            }
            yield LineRange(sliceStart, i);
            sliceStart = i + 1;
        }
        if (sliceStart < end)
        {
            yield LineRange(sliceStart, end);
        }
    }
}

class LineRange
{
    final int start;
    final int end;
    LineRange(this.start, this.end);
}

// Utils for tab conversion
// NOTE: no longer used, doesnt work on multiline string with indents,
// now its internally done in the formatter

class ConvertTab
{
    /// Indent string that will be used for conversion to tab.
    final String _indent;

    /// A single Tab character.
    static const _tabChar = "\t";

    /// From where in [_original] to keep adding [_tabChar] to the [_buffer].
    var _lastOffset = 0;

    /// Output bufffer to use instead of edits.
    /// call toString() to get the complete output.
    final _buffer = StringBuffer();

    /// SourceEdits for space to tab conversion.
    final _edits = <SourceEdit>[];

    /// The string to convert.
    final String _original;

    /// String to convert to tab indents, and a [indentSize] to use for replacing indent with tab.
    ConvertTab(this._original, int indentSize) : _indent = " " * indentSize;

    List<SourceEdit> getEdits()
    {
        // This should be on the standard library, don't know why it isn't.
        final lineIter = const LineSplitter().splitOffset(_original);
        // Get lines start and end offsets (line ends when \n or \r\n is encountered).
        for (final line in lineIter)
        {
            // Skip empty lines
            if (line.start == line.end) continue;

            var lineOffset = line.start;
            // Check if we have an indent.
            while (_original.startsWith(_indent, lineOffset))
            {
                _edits.add(SourceEdit(lineOffset, _indent.length, _tabChar));

                // Now check for next indent level.
                lineOffset += _indent.length;
            }
        }
        return _edits; // 6,40ms
    }

    /// Option (B) (just a 1 liner)
    /// AOT Compiled Regexp is 6x times slower than JIT.
    /// https://github.com/dart-lang/sdk/issues/37785
    /// Option A or C (more code) are more consistent.
    String convertRegexp(String string) // 14ms
    {
        // 14ms JIT :)      71ms AOT :(
        return string.replaceAll(
            RegExp('(?<=^[$_indent]*?)$_indent', multiLine: true, caseSensitive: false),
            _tabChar);
    }

    /// Converts space indents to tabs.
    String convert()
    {
        // This split should be on the standard library, don't know why it isn't.
        final lineIter = const LineSplitter().splitOffset(_original);
        // Get lines start and end offsets (line ends when \n or \r\n is encountered).
        for (final line in lineIter)
        {
            // Skip empty lines
            if (line.start == line.end) continue;

            var lineOffset = line.start;
            // Check if we have an indent
            while (_original.startsWith(_indent, lineOffset))
            {
                //_edits.add(SourceEdit(lineOffset, _indent.length, _tabChar)); // Option (A)
                _addTabToBuffer(lineOffset, _tabChar, _indent.length); // Option (C)

                // Now check for next indent level.
                lineOffset += _indent.length;
            }
        }
        //return _applyEdits();   // Option (A)   21.00ms Benchmark (22k lines string)
        return _toString(); // Option (C)   18.63ms Benchmark (22k lines string)
    }

    /// Adds to buffer [insert] after _original[atOffset] replacing [zoneLength]
    ///
    /// In other words: if "(" is [_lastOffset] and ")" is [atOffset]
    /// and we want to replace "II".length positions with "T":
    ///  `"(123)II4567II..." + "T" => buffer += "123T"`
    /// and next time "(" will be at position ")" plus "II".length positions.
    /// `"123II(4567)II..." + "T" => buffer += "4567T"` and so on.
    ///
    /// We are always replacing the [zoneLength] with [insert] in the [_original] string,
    /// so we move [_lastOffset] [zoneLength] positions.
    void _addTabToBuffer(int atOffset, String insert, int zoneLength)
    {
        // substring has big performance overhead here but dart library doesn't offer inplace construction or performant slices.
        _buffer.write(
            "${_original.substring(_lastOffset, atOffset)}$insert"); // substring non inclusive end.
        _lastOffset = atOffset + zoneLength;
    }

    /// Option (A)
    /// used internally to test performance in case its needed.
    // ignore: unused_element
    String _applyEdits()
    {
        //Apply edits to buffer then return string.
        for (final edit in _edits)
            _addTabToBuffer(edit.offset, edit.replacement, edit.length);

        return _toString();
    }

    /// Option (C)
    String _toString()
    {
        // 18.63ms JIT :|   22ms AOT :|  with 22k lines string with 1-2-3-4 indentations levels
        // Write the last string remanent if any.
        _buffer.write(_original.substring(_lastOffset, _original.length));
        return _buffer.toString();
    }
}
