import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_polisher/src/cli/commands/dartstyle_command.dart';
import 'package:dart_polisher/src/cli/commands/formatter_command.dart';
import 'package:dart_polisher/src/constants.dart';

class CLIRunner<T> extends CommandRunner<T>
{
    CLIRunner(super.executableName, super.description);

    @override
    Future<T?> runCommand(ArgResults topLevelResults) async
    {
        if (topLevelResults.command == null)
        {
            if (topLevelResults['version'])
            {
                print("Formatter version: $XNFOFMT_VERSION"
                    " (based on dart_style: $FORKED_FROM_DART_STYLE_VERSION)");
                return null;
            }
        }
        return super.runCommand(topLevelResults);
    }
}

void main(List<String> args) async
{
    bool verbose = args.contains("--verbose") || args.contains("-v");
    var runner = CLIRunner<int>("dartcfmt", "A dart customization of dart_style formatter.")
        /*..argParser.addFlag('verbose',
                abbr: 'v',
                help: 'Show additional options..',
                defaultsTo: false,
                negatable: false,)*/
        ..argParser.addFlag(
            'version',
            negatable: false,
            help: 'Show Dart Formatter versions.',
        )
        ..addCommand(DartStyleCommand(verbose: verbose))
        ..addCommand(FormatCommand(verbose: verbose));

    try
    {
        await runner.run(args);
    }
    on UsageException catch (err)
    {
        print(err);
    }
}
