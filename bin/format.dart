import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_polisher/src/cli/commands/dartstyle_command.dart';
import 'package:dart_polisher/src/cli/commands/format_command.dart';
import 'package:dart_polisher/src/dp_constants.dart';

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
                print(DPConst.VERSION_STRING);
                return null;
            }
        }
        return super.runCommand(topLevelResults);
    }
}

void main(List<String> args) async
{
    bool verbose = args.contains("--verbose") || args.contains("-v");
    var runner = CLIRunner<int>("dartpolish", "A custom dart formatter based on dart_style.")
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
        stderr.writeln(err);
        exit(64);
    }
}
