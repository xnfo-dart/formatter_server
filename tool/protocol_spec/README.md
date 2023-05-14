## Protocol Classes & API Doc generation tool

Tool taken from:

[analysis_server/tool/spec](https://github.com/dart-lang/sdk/tree/main/pkg/analysis_server/tool/spec)

[analyzer_utilities](https://github.com/dart-lang/sdk/tree/main/pkg/analyzer_utilities) (unpublished dependency)

Its used to generate request/response protocol classes from a central html API file [spec_input.html](./spec_input.html)

generate.dart outputs:
- /generated/api.html  (nice looking api file)
- /generated/server/protocol_constants.dart (protocol constants for method/params)
- /generated/server/protocol_generated.dart (serializable api method/params dart classes for response/request protocol messages)

`/generated/server/*` files are to be transfered to `package:formatter_server/protocol/`

`/generated/api.html` file is to be transfered to `package:formatter_server/doc/`
