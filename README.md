MOVED to https://github.com/xnfo-dart/dart_polisher as a fork or the google repo for better tracking and maintenance of changes upstream.

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
## Build
> If executing on the command line, define a dartMain entry point in js, there is an example [here](tool\js_format_service.dart#142)

* Compile to Executable:<br>
```sh 
dart run grinder build [--output='name'] #defaults to 'build/dartpolish'
```
* Compile to Node.js:

```sh 
dart run grinder node``` #outputs in 'dist/node/'
```

---

>Dart code formatter *forked* from [dart_style](https://github.com/dart-lang/dart_style)

## License
BSD-3-Clause license

Most of the code is originaly from Dart Authors.
