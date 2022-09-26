# Dart Formatter Server [![Formatter](https://shields.io/badge/dart-Formatter_Server-green?logo=dart&style=flat-square)](https://github.com/tekert/dart-formatter) ![Issues](https://img.shields.io/github/issues/tekert/dart_formatter)
 `stdio` Dart formatter server using [Xnfo Formatter] over an [API] Protocol
 
For use in IDE integration.


## Download
- From [Releases](https://github.com/xnfo-dart/formatter_server/releases)
 ## IDE Extensions
- [VScode Extension](https://github.com/xnfo-dart/dart-format-vscode)


## Build
> Until i finish the v1.0.0 release and update the grinder for better quality of life building, i do every step separately fow now.

1. (optional) Protocol spec and version is defined in<br>
```./tool/protocol_spec/spec-input.html```

2. (optional) Update protocol files and doc using spec-input.html<br>
```dart run ./tool/protocol_spec/generate.dart```

3. (when releasing tag) Bump version (protocol, app, and dependencies)<br>
```dart run grinder bump```

4. Compile<br>
```dart compile [options] ./bin/listen.dart```


### Forked from
>Server *forked* from [analysis_server](https://github.com/dart-lang/sdk/tree/main/pkg/analysis_server) (barebones stdio server and protocol only)


## License
BSD-3-Clause license

Most of the code is originaly from Dart Authors.

[API]: https://htmlpreview.github.io/?https://github.com/xnfo-dart/formatter_server/blob/master/doc/api.html

[Xnfo Formatter]: https://github.com/xnfo-dart/xnfo_formatter
