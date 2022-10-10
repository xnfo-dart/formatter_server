# Dart Formatter Server [![Formatter](https://shields.io/badge/dart-Formatter_Server-green?logo=dart&style=flat-square)](https://github.com/xnfo-dart/formatter_server) ![Issues](https://img.shields.io/github/issues/xnfo-dart/formatter_server)
 `stdio` Dart formatter server using [Dart Polisher] over an [API] Protocol
 
For IDE integration.


## Download
- From [Releases](https://github.com/xnfo-dart/formatter_server/releases)
 ## IDE Extensions
- [VScode Extension]


## Build
> Until i finish the v1.0.0 release and update the grinder for better quality of life building, i do every step separately fow now.

1. (optional) Protocol spec and version is defined in<br>
```./tool/protocol_spec/spec-input.html```

2. Update protocol files and doc using spec-input.html<br>
```dart run grinder generate```

3. (when releasing tag) Bump version (protocol, app, and dependencies)<br>
```dart run grinder bump```

4. Compile<br>
```dart compile exe ./bin/listen.dart```


the resulting executable is usually used as a daemon for IDE extensions, for example the [VScode Extension] loads this daemon from `/bin`.

### Forked from
Server *forked* from [analysis_server](https://github.com/dart-lang/sdk/tree/main/pkg/analysis_server) (base stdio server and protocol only)  

## License
BSD-3-Clause license

Most of the code is originaly from the Dart Authors.

[API]: https://htmlpreview.github.io/?https://github.com/xnfo-dart/formatter_server/blob/master/doc/api.html

[Dart Polisher]: https://github.com/xnfo-dart/dart_polisher

[VScode Extension]: https://github.com/xnfo-dart/dart-polisher-vscode
