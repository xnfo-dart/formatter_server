# Changelog
StdIO server for handling requests from IDEs using the Dart Xnfo Formatter.

----
## [Unreleased]

----
## 0.9.0
### Added
- New API for incremental file changes using overlays for file handling <br>
    (using analizer as a lib)
### Changed
- Small versioning changes.
- Listen API protocol bumped to listen/0.6.1
- Fix better error reporting messages on overlay range checks.

----
## 0.8.8
### Changed
- Polished protocol error messages.
- New API doc using analysis_server tools.
- Many code refactoring to mirror upstream repos in preparation for 1.0.

----
## 0.0.5
- Initial Stdio server implementation. (took some time to reverse engineer analysis_server)

- Some refactoring

[Unreleased]: https://github.com/tekert/dart_formatter/compare/v0.0.2...HEAD

[0.0.1]: https://github.com/tekert/dart_formatter/releases/tag/v0.0.1
