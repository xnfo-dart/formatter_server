import 'package:dart_polisher/dart_polisher.dart';

import 'package:analyzer_utilities/tools.dart' as autools;
export 'package:analyzer_utilities/tools.dart' hide GeneratedFile;

/// Class representing a single output file (either generated code or generated
/// HTML).
///
/// (Hooked class to generate formatted code using polisher)
class GeneratedFile extends autools.GeneratedFile
{
    GeneratedFile(super.outputPath, super.computeContents);

    @override
    Future<void> generate(String pkgPath) async
    {
        var outputFile = output(pkgPath);
        print('  ${outputFile.path}');
        var contents = await computeContents(pkgPath);
        if (isDartFile)
        {
            // Format Source using polisher instead of the dart formatter in [autools.GeneratedFile].
            var polisher = DartFormatter(
                FormatterOptions(style: CodeStyle.ExpandedStyle, pageWidth: 90));
            contents = polisher.format(contents);
        }
        outputFile.writeAsStringSync(contents);
    }
}
