# Changelog
Stdio server for handling requests from IDEs using the Dart Polisher formatter.

## [Unreleased]


## [0.9.1-beta3] - 8/10/2022
- Refactor The way Handlers are called from Requests, cleaner execution and error handling.
- Protocol traffic is now logged when using --intrumentation-log-file 'path'.
- Imported and adjusted integration and basic tests from analysis_server.
- API call server.getversion now returns SERVER and API protocol versions.

## [0.9.0] - 27/9/2022
### Added
- New API for incremental file changes using overlays for file handling (using analizer as a lib)
### Changed
- Small versioning changes.
- Listen API protocol bumped to listen/0.6.1
- Fix better error reporting messages on overlay range checks.
- Updated dependencies.

## [0.8.8]
### Changed
- Polished protocol error messages.
- New API doc using analysis_server tools.
- Many code refactoring to mirror upstream repos in preparation for 1.0.

## [0.0.5]
- Initial Stdio server implementation. (took some time to reverse engineer analysis_server)

- Some refactoring

[Unreleased]: https://github.com/xnfo-dart/formatter_server/compare/v0.9.0...HEAD
[0.9.1]: https://github.com/xnfo-dart/formatter_server/releases/tag/v0.9.1
[0.9.0]: https://github.com/xnfo-dart/formatter_server/releases/tag/v0.9.0
[0.8.8]: https://github.com/xnfo-dart/formatter_server/releases/tag/v0.8.8
