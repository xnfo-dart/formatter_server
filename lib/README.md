# Stdio server and protocol 
> Extracted from Dart SDK pkg [Analysis server](https://github.com/dart-lang/sdk/tree/main/pkg/analysis_server/) master branch prior to the '8 ago 2022' lsp refactor.

> Post refactor the DAS is named [LegacyAnalysisServer](https://github.com/dart-lang/sdk/tree/main/pkg/analysis_server/lib/src/legacy_analysis_server.dart)

The interesting part is in [./src/handler/edit_format.dart]

    Only a subset of functionality was taken from analysis_server, wich is the base API protocol using JSON as RPC over stdio.

    analysis_plugin has some common API definitions used by the analysis_server

    package:analyzer_plugin/src/protocol/protocol_internal.dart 
    (Utils for JSON validations methods)

    package:analyzer_plugin/protocol/protocol_common.dart 
    (Protocol definitions)
***
## Analyzer notes

The analyzer has some classes totally abstracted from the analysis side, for example the one for handling `File overlays` (it would make a nice library if expanded)

>The reason for using analysis_server is that it was already done, tested, so it was not needed to reinvent anything. Saves time.

This had to be done because the analysis_plugin doesn't hook in edit.format requests, so forking the stdio server seemed like a balanced aproach.
the analysis_server now uses [Language Server Provider](https://microsoft.github.io/language-server-protocol/).

Using the LSP only for formatting was not feasible, if this server gets more functionality we may change to use the LSP protocol (its already done in the analysis_server, only importing, refactoring and testing is requiered).
***
## API and tool/protocol_spec

`API` is in [API]

>API was generated using the analysis_server spec tools.

The tool is similar to a protocol_buffer using html as input (very nice) and outputs dart code to handle messages that contain json, generates parsing and errors for each RPC method, its mostly unused as they have now moved to LSP but it's a nice tool for use in this simple server.

## Errors Zones
There are 3 error zone layers to error handling, from the inner to outer layer:

* Handler Zone

    Catchs any unhandled async or sync errors when handling a client request on the io stream.<br>
    A Response is sent to the client with an error field by protocol spec Response(id, error: [RequestError]).<br>
    Only erors that are not [RequestError] are logeed to an intrumentation file provided by the user.<br>

* IO Stream Zone

    Catchs the stream async or sync errors (with onError: on listen after all stream tranforms).<br>
    This is where Requests are read and then distributed to the Handle layer.<br>
    A [Error Notification] is sent to the client and the exception logeed to an intrumentation file provided by the user.<br>

* Server Zone

    Inside the Driver class handling server errors.<br>
    Handles any async or sync error ocurred that where not handled anywhere.<br>
    Logs it to an intrumentation file and retrows the exception to crash the server with an error.<br>



[API]: (https://htmlpreview.github.io/?https://github.com/xnfo-dart/formatter_server/blob/master/doc/api.html)
[RequestError]: https://htmlpreview.github.io/?https://github.com/xnfo-dart/formatter_server/blob/master/doc/api.html#type_RequestError
[Error Notification]: https://htmlpreview.github.io/?https://github.com/xnfo-dart/formatter_server/blob/master/doc/api.html#notification_server.error