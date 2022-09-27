import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'package:formatter_server/src/server/listen_command.dart';
import 'package:formatter_server/src/constants.dart'; // Replace with github import.

import "package:xnfo_formatter/xnfo_formatter.dart";

class CLIRunner<T> extends CommandRunner<T>
{
    CLIRunner(super.executableName, super.description);

    @override
    Future<T?> runCommand(ArgResults topLevelResults) async
    {
        if (topLevelResults.command == null)
        {
            if (topLevelResults['version'] as bool)
            {
                print("Server / API: $FORMATTER_SERVER_VERSION / $LISTEN_PROTOCOL_VERSION");
                print(XNFOFMT_VERSION_STRING);
                return null;
            }
        }
        return super.runCommand(topLevelResults);
    }
}

void main(List<String> args) async
{
    var runner = CLIRunner<int>("dartcfmtd", "Formatting Server using Dart Xnfo formatter")
        /*..argParser.addFlag('verbose',
                abbr: 'v',
                help: 'Show additional options..',
                defaultsTo: false,
                negatable: false,)*/
        ..argParser.addFlag(
            'version',
            negatable: false,
            help: 'Show Dart Formatter server versions.',
        )
        ..addCommand(ListenCommand());

    try
    {
        await runner.run(args);
    }
    on UsageException catch (err)
    {
        print(err);
    }
}
