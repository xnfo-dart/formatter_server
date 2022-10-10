# Stdio server and protocol 
> Extracted from Dart SDK pkg [Analysis server](https://github.com/dart-lang/sdk/tree/main/pkg/analysis_server/)

The interesting part is only in [./src/handler/edit_format.dart]

    Only a subset of functionality was taken from analysis_server, wich is the base API protocol using JSON as RPC over stdio.

    analysis_plugin has some common API definitions used by the analysis_server

    package:analyzer_plugin/src/protocol/protocol_internal.dart 
    (Utils for JSON validations methods)

    package:analyzer_plugin/protocol/protocol_common.dart 
    (Protocol definitions)
***
## Analyzer notes

The analyzer has handly classes totally abstracted from the analysis side, for handling `File overlays` (it would make a nice library if expanded)

>It was already done, tested, so no need to reinvent anything. Saves time.

This had to be done because the analysis_plugin doesn't hook in edit.format requests, so forking the stdio server seemed like a balanced aproach.
the analysis_server now uses [Language Server Provider](https://microsoft.github.io/language-server-protocol/).

Using the LSP only for formatting was not feasible, if this server gets more functionality we may change to use the LSP protocol (its already done in the analysis_server, only importing, refactoring and testing is requiered).
***
## API and tool/protocol_spec

`API` is in [./doc/api.html](https://htmlpreview.github.io/?https://github.com/xnfo-dart/formatter_server/blob/master/doc/api.html)

>API was generated using the analysis_server spec tools.

The tool is similar to a protocol_buffer using html as input (very nice) and outputs dart code to handle messages that carry json, generates parsing and errors for each RPC method, its mostly unused as they have now moved to LSP mostly.
