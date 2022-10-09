// The code was taken from dart_style package and modified by Xnfo.
// The dart_style package copyright notice is as follows:
//
// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:dart_polisher/dart_polisher.dart';
import 'package:dart_polisher/src/cli/cli_options.dart';
import 'package:dart_polisher/src/cli/options.dart';
import 'package:dart_polisher/src/cli/output.dart';
import 'package:dart_polisher/src/cli/show.dart';
import 'package:dart_polisher/src/cli/summary.dart';
import 'package:dart_polisher/src/cli/io.dart';

class FormatCommand extends Command<int>
{
    @override
    String get name => 'format';

    @override
    String get description =>
        "[${DPConst.VERSION}] Format Dart source code with custom styles and indents."
        " (Fork using dart_style ${DPConst.FORKED_FROM_DART_STYLE_VERSION})";

    @override
    String get invocation =>
        "${runner!.executableName} $name [options...] <files or directories...>";

    FormatCommand({bool verbose = false})
    {
        defineFormatOptions(argParser, verbose: verbose);
    }

    @override
    Future<int> run() async
    {
        var argResults = this.argResults!;

        if (argResults['version'])
        {
            print(DPConst.VERSION_STRING);
            return 0;
        }

        var show = const {
            'all': Show.all,
            'changed': Show.changed,
            'none': Show.none
        }[argResults['show']]!;

        var output = const {
            'write': Output.write,
            'show': Output.show,
            'none': Output.none,
            'json': Output.json,
        }[argResults['output']]!;

        var summary = Summary.none;
        switch (argResults['summary'] as String)
        {
            case 'line':
                summary = Summary.line();
                break;
            case 'profile':
                summary = Summary.profile();
                break;
        }

        // If the user is sending code through stdin, default the output to stdout.
        if (!argResults.wasParsed('output') && argResults.rest.isEmpty)
        {
            output = Output.show;
        }

        // If the user wants to print the code and didn't indicate how the files
        // should be printed, default to only showing the code.
        if (!argResults.wasParsed('show') &&
            (output == Output.show || output == Output.json))
        {
            show = Show.none;
        }

        // If the user wants JSON output, default to no summary.
        if (!argResults.wasParsed('summary') && output == Output.json)
        {
            summary = Summary.none;
        }

        // Can't use --verbose with anything but --help.
        if (argResults['verbose'] && !(argResults['help'] as bool))
        {
            usageException('Can only use --verbose with --help.');
        }

        // Can't use any summary with JSON output.
        if (output == Output.json && summary != Summary.none)
        {
            usageException('Cannot print a summary with JSON output.');
        }

        var pageWidth = int.tryParse(argResults['line-length']) ??
            usageException('--line-length must be an integer, was '
                '"${argResults['line-length']}".');

        var indent = int.tryParse(argResults['indent']) ??
            usageException('--indent must be an integer, was '
                '"${argResults['indent']}".');

        if (indent < 0)
        {
            usageException('--indent must be non-negative, was '
                '"${argResults['indent']}".');
        }

        CodeStyle codeStyle = const {
            '0': CodeStyle.DartStyle,
            '1': CodeStyle.ExpandedStyle,
            '2': CodeStyle.style2,
            '3': CodeStyle.style3,
        }[argResults['code-style']]!;

        int tabSize = int.tryParse(argResults['tab-size']) ??
            usageException('--tab-size must be an integer, was '
                '"${argResults['tab-size']}".');

        int? tabSizeExpression;
        int? tabSizeBlock;
        int? tabSizeCascade;
        int? tabSizeInitializer;
        if (argResults.wasParsed('tab-size-expression'))
        {
            tabSizeExpression = int.tryParse(argResults['tab-size-expression']) ??
                usageException('--tab-size-expression must be an integer, was '
                    '"${argResults['tab-size-expression']}".');
        }
        if (argResults.wasParsed('tab-size-block'))
        {
            tabSizeBlock = int.tryParse(argResults['tab-size-block']) ??
                usageException('--tab-size-block must be an integer, was '
                    '"${argResults['tab-size-block']}".');
        }
        if (argResults.wasParsed('tab-size-cascade'))
        {
            tabSizeCascade = int.tryParse(argResults['tab-size-cascade']) ??
                usageException('--tab-size-cascade must be an integer, was '
                    '"${argResults['tab-size-cascade']}".');
        }
        if (argResults.wasParsed('tab-size-initializer'))
        {
            tabSizeInitializer = int.tryParse(argResults['tab-size-initializer']) ??
                usageException('--tab-size-initializer must be an integer, was '
                    '"${argResults['tab-size-initializer']}".');
        }

        bool insertSpaces = !(argResults['insert-tabs'] as bool);

        var fixes = <StyleFix>[];
        if (argResults['fix']) fixes.addAll(StyleFix.all);
        for (var fix in StyleFix.all)
        {
            if (argResults['fix-${fix.name}'])
            {
                if (argResults['fix'])
                {
                    usageException('--fix-${fix.name} is redundant with --fix.');
                }

                fixes.add(fix);
            }
        }

        List<int>? selection;
        try
        {
            selection = parseSelection(argResults, optionName: 'selection');
        }
        on FormatException catch (exception)
        {
            usageException(exception.message);
        }

        var followLinks = argResults['follow-links'];
        var setExitIfChanged = argResults['set-exit-if-changed'] as bool;

        // If stdin isn't connected to a pipe, then the user is not passing
        // anything to stdin, so let them know they made a mistake.
        if (argResults.rest.isEmpty && stdin.hasTerminal)
        {
            usageException('Missing paths to code to format.');
            //stderr.writeln("(Press ctrl+z then enter to close stdin)");
        }

        if (argResults.rest.isEmpty && output == Output.write)
        {
            usageException('Cannot use --output=write when reading from stdin.');
        }

        if (argResults.wasParsed('stdin-name') && argResults.rest.isNotEmpty)
        {
            usageException('Cannot pass --stdin-name when not reading from stdin.');
        }
        var stdinName = argResults['stdin-name'] as String;

        var ind = CodeIndent(
            block: tabSizeBlock ?? tabSize,
            cascade: tabSizeCascade ?? tabSize,
            expression: tabSizeExpression ?? tabSize,
            constructorInitializer: tabSizeInitializer ?? tabSize);

        var fo = FormatterOptions(
            indent: indent,
            pageWidth: pageWidth,
            insertSpaces: insertSpaces,
            style: codeStyle,
            fixes: {...fixes},
            tabSizes: ind,
        );

        var options = CliOptions(
            foptions: fo,
            followLinks: followLinks,
            show: show,
            output: output,
            summary: summary,
            setExitIfChanged: setExitIfChanged);

        if (argResults.rest.isEmpty)
        {
            await formatStdin(options, selection, stdinName);
        }
        else
        {
            formatPaths(options, argResults.rest);
            options.summary.show();
        }

        // Return the exitCode explicitly for tools which embed dart_formatter
        // and set their own exitCode.
        return exitCode;
    }
}
