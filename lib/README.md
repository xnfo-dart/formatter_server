# Stdio server and protocol 
> Extracted from Dart SDK pkg [Analysis server](https://github.com/dart-lang/sdk/tree/main/pkg/analysis_server/)

The interesting part is only in [./src/handler/format_handler.dart]

    Only a subset of functionality was taken from analysis_server, wich is the base API protocol using JSON as RPC over stdio.

    analysis_plugin has some common API definitions used by the analysis_server

    package:analyzer_plugin/src/protocol/protocol_internal.dart 
    (Utils for JSON validations methods)

    package:analyzer_plugin/protocol/protocol_common.dart 
    (Protocol definitions)
***
## Analyzer notes

The analizer has a very handly classes totally abstracted from the analysis side, for handling `File overlays` (it would make a handly library if expanded)

>It was already done, tested, so no need to reinvent anything. Saves time.

This had to be done because the analysis_plugin doesn't hook in edit.format requests, so forking the stdio server seemed like a balanced aproach.
the analysis_server now uses [Language Server Provider](https://microsoft.github.io/language-server-protocol/).
***
## API and tool/protocol_spec

`API` is in [./doc/api.html](https://htmlpreview.github.io/?https://github.com/xnfo-dart/formatter_server/blob/master/doc/api.html)

>API was generated using the analysis_server spec tools.

The tool is similar to a protocol_buffer using html as input (very nice) and outputs dart code to handle messages that carry json and come with parsing and errors for each RPC method, its mostly unused as the have moved to using LSP

We only use server output, as the client is in typescript normally and the protocol is small enough to just manually translate it) plus nice html api doc, it would make a really good library, wonder why they dont do it.
