import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:formatter_server/src/constants.dart';
import 'package:formatter_server/starter.dart';
import 'package:formatter_server/src/server/driver.dart';

class ListenCommand extends Command<int>
{
    @override
    String get name => 'listen';

    @override
    String get description =>
        '[$LISTEN_PROTOCOL_VERSION] (Developer option) Open a server using a specific channel [stdio, socket] for handling IDE requests';

    @override
    String get invocation => '${runner!.executableName} $name [options...] <>';

    ListenCommand()
    {
        var parser = argParser;

        parser.addFlag('version', negatable: false, help: 'Show API version.');

        parser.addSeparator('Listen options:');

        // TODO (tekert): stdout blocking vs nonbloling, logs, paths, modes, etc.
        parser.addOption('channel',
            abbr: 'c',
            help: 'Set listen channel.',
            allowed: ['stdio', 'http'],
            allowedHelp: {
                'stdio': 'Open a channel using stdio for communication',
                'http': '[Not implemented yet.]'
            },
            defaultsTo: 'stdio');

        //parser.addSeparator('Options when formatting from stdout:');

        parser.addSeparator('To be set by clients:');

        parser.addOption(Driver.CLIENT_ID,
            valueHelp: 'name', help: 'An identifier for the format server client.');
        parser.addOption(Driver.CLIENT_VERSION,
            valueHelp: 'version', help: 'The version of the format server client.');

        parser.addSeparator('Server diagnostics:');

        parser.addOption(Driver.PROTOCOL_TRAFFIC_LOG,
            valueHelp: 'file path',
            help: 'Write server protocol traffic to the given file.');
        parser.addOption(Driver.PROTOCOL_TRAFFIC_LOG_ALIAS, hide: true);
    }

    @override
    Future<int> run() async
    {
        var argResults = this.argResults!;

        var starter = ServerStarter();
        starter.start(argResults);

        //TODO (tekert): start() already exits(0) when shutdown
        // Return the exitCode explicitly for tools which embed dart_formatter
        // and set their own exitCode.
        return exitCode;
    }
}
