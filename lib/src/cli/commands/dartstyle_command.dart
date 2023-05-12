// ignore: implementation_imports
import 'package:dart_style/src/cli/format_command.dart' as dart_style;
// ignore: implementation_imports
import 'package:dart_style/src/cli/formatter_options.dart' as dart_style;
// import 'package:dart_polisher/src/formatter_constants.dart';

/// Uses the Original dart_style command line options [FormatCommand]
/// and runs the original dart_style code
class DartStyleCommand extends dart_style.FormatCommand
{
    @override
    String get name => 'dart_style';

    @override
    String get description =>
        'Use the official Dart style formatter library. [${dart_style.dartStyleVersion}] ';

    DartStyleCommand({bool verbose = true}) : super(verbose: verbose);
}
