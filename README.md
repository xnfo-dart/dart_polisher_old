# Dart Polisher [![Formatter](https://shields.io/badge/dart-Formatter_(fork)-green?logo=dart&style=flat-square)](https://github.com/xnfo-dart/dart_polisher) ![Issues](https://img.shields.io/github/issues/xnfo-dart/dart_polisher)
> *Forked* Dart code formatter + CLI + custom styles

 - Customizable indent sizes *(tab sizes)*  
 - Use tab or spaces for indents  
 - Additional custom styles  
 - CLI for dir/file formatting as the original with added options.

## Download
- Commandline tool: [Releases](https://github.com/xnfo-dart/dart_polisher/releases)

## IDE Extensions
- [Link to VScode Extension](https://github.com/xnfo-dart/dart-polisher-vscode)


---

### Forked from
>Dart code formatter *forked* from [dart_style](https://github.com/dart-lang/dart_style)
<br> Receives patches from upstream.

---
## Build
> If executing on the command line, define a dartMain entry point in js, there is an example [here](tool\js_format_service.dart#142)

* Compile Executable:<br>
```dart run grinder build``` --output='name' (optional)<br>
* Compile Node.js:<br>
```dart run grinder node``` --output='name' (optional)<br>
* Compile Manually:<br>
```dart compile [options] ./bin/format.dart```
<br>
<br>
* (when releasing tag) Bump version (protocol, app, and dependencies)<br>
```dart run grinder bump```
---

## License
BSD-3-Clause license

Most of the code is originaly from Dart Authors.
