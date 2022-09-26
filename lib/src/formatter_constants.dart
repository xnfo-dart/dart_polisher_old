// ignore_for_file: constant_identifier_names
import 'package:xnfo_formatter/src/dart_formatter/dart_formatter_options.dart'
    show CodeStyle;

// Note: The following line of code is modified by tool/grind.dart.
const String XNFOFMT_VERSION = "0.9.1";
// Note: The following line of code is modified by tool/grind.dart.
// (it's based on the dependancy used when building this app.)
const String DART_STYLE_DEP_VERSION = "2.2.4";

// Version string
const String XNFOFMT_VERSION_STRING = "Formatter version: $XNFOFMT_VERSION"
    " (based on dart_style: $FORKED_FROM_DART_STYLE_VERSION)";

// The last merge from dart_style
// Note: Change this manually only when merging all changes from upstream up to *this version
const String FORKED_FROM_DART_STYLE_VERSION = "2.2.4";
const String FORKED_FROM_DART_STYLE_COMMIT = "https://github.com/dart-lang/dart_style/commit/dec7e72856a6b693d7f23a6a904bfe23d32b3ad4";

// Default values
const int DEFAULT_BLOCK_INDENT = 4;
const int DEFAULT_CASCADE_INDENT = 4;
const int DEFAULT_EXPRESSION_INDENT = 4;
const int DEFAULT_CONSTRUCTOR_INITIALIZER_INDENT = 4;
const int DEFAULT_PAGEWIDTH = 90;
const bool DEFAULT_INSERTSPACES = true;
const CodeStyle DEFAULT_STYLE = CodeStyle.DartStyle;
