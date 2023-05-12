# Changelog
>A less opitionated Dart formatter based on the official Dart `dart_style` formatter.

## [Unreleased]

## [0.9.4] - 12/5/2023

### New
- Ability to export library to Node.js `dart-polisher` npm package.  
Library created using Dart `js` compiler.  
Typings for use in `typescript`.  
Compile with grinder: `dart run grinder node` (use `--help` for more info).  
Additional grinder node tools: `grinder benchmark` (10x times slower on avg using Dart 2.18).  
Import it using npm: [dart-polisher](https://www.npmjs.com/package/dart-polisher), or file: `dist/node/dart-polisher-*.tgz`.

### Upstream fixes
- Format unnamed libraries.
- Sync updates from upstream (records, patterns, class modifiers, switch cases)
- Keep using the old switch case style in Expanded Style.

### Fixes
- Grinder build task now accepts relative paths (builds are still relative to ./build dir)

## [0.9.2] - 10/10/2022
- `DartFormatter` constructor argument: `FormatterOptions` argument its now optional.
- Updated analyzer lib.
- Ported tests.
- Javascript build target. `dart run grinder node`
- Build task. `dart run grinder build --output=filename`

<br>

## [0.9.1] - 27/9/2022
- Option to use Spaces or Tabs when formatting (vscode extension should automatically support it based on editor settings)

<br>

## [0.9.0]
### Changed
- Small versioning changes.
- Fix try statements on Expanded Style

<br>

## [0.8.9]
### Changed
- Fix outer brace style. Its almost set.
- Small code refactoring, many more to fine-tune before release.

<br>

## [0.8.8]
### Added
- New tab size indent options
- New code style option to select a style from a list of predetermined profiles.
- New CLI format options.

### Changed
- Polished protocol error messages.
- Code refactoring to mirror upstream repo in preparation for 1.0.

<br>

## [0.0.5]
- Some refactoring

<br>

## [0.0.2]
### Added
- Custom Indents.
### Changed
### Removed

<br>

## [0.0.1]
- Initial version.


[Unreleased]: https://github.com/xnfo-dart/dart-polisher/compare/v0.9.4...HEAD
[0.9.4]: https://github.com/xnfo-dart/dart-polisher/releases/tag/v0.9.4
[0.9.2]: https://github.com/xnfo-dart/dart-polisher/releases/tag/v0.9.2
[0.9.1]: https://github.com/xnfo-dart/dart-polisher/releases/tag/v0.9.1
[0.9.0]: https://github.com/xnfo-dart/dart-polisher/releases/tag/v0.9.0
[0.8.9]: https://github.com/xnfo-dart/dart-polisher/releases/tag/v0.8.9
