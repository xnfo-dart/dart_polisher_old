// The code was taken from dart_style package and modified by Xnfo.
// The dart_style package copyright notice is as follows:
//
// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:args/args.dart';

import 'package:dart_polisher/src/dart_formatter/style_fix.dart';
import 'package:dart_polisher/src/dp_constants.dart';

void defineFormatOptions(ArgParser parser, {bool verbose = false})
{
    parser.addFlag('verbose',
        abbr: 'v', negatable: false, help: 'Show all options and flags with --help.');

    if (verbose) parser.addSeparator('Output options:');

    parser.addOption('output',
        abbr: 'o',
        help: 'Set where to write formatted output.',
        allowed: ['write', 'show', 'json', 'none'],
        allowedHelp: {
            'write': 'Overwrite formatted files on disk.',
            'show': 'Print code to terminal.',
            'json': 'Print code and selection as JSON.',
            'none': 'Discard output.'
        },
        defaultsTo: 'write');

    parser.addOption('show',
        help: 'Set which filenames to print.',
        allowed: ['all', 'changed', 'none'],
        allowedHelp: {
            'all': 'All visited files and directories.',
            'changed': 'Only the names of files whose formatting is changed.',
            'none': 'No file names or directories.',
        },
        defaultsTo: 'changed',
        hide: !verbose);

    parser.addOption('summary',
        help: 'Show the specified summary after formatting.',
        allowed: ['line', 'profile', 'none'],
        allowedHelp: {
            'line': 'Single-line summary.',
            'profile': 'How long it took for format each file.',
            'none': 'No summary.'
        },
        defaultsTo: 'line',
        hide: !verbose);

    parser.addFlag('set-exit-if-changed',
        negatable: false,
        help: 'Return exit code 1 if there are any formatting changes.');

    if (verbose) parser.addSeparator('Non-whitespace fixes (off by default):');

    parser.addFlag('fix', negatable: false, help: 'Apply all style fixes.');
    for (var fix in StyleFix.all)
    {
        // TODO(rnystrom): Allow negating this if used in concert with "--fix"?
        parser.addFlag('fix-${fix.name}',
            negatable: false, help: fix.description, hide: !verbose);
    }

    if (verbose) parser.addSeparator('Formatting options:');

    parser.addOption('line-length',
        abbr: 'l',
        help: 'Wrap lines longer than this.',
        defaultsTo: DefaultValue.DEFAULT_PAGEWIDTH.toString());

    parser.addOption('indent',
        abbr: 'i',
        help: 'Add this many spaces of leading indentation.',
        defaultsTo: '0',
        hide: !verbose);

    parser.addOption('code-style',
        abbr: 's',
        help: 'Code style to use',
        allowed: ['0', '1', '2'],
        allowedHelp: {
            '0': 'Dart style: with customizable indents.',
            '1': '[beta] Dart Expanded style: with outer {braces} on block like nodes',
            '2': '[not available yet]'
        },
        defaultsTo: '0');

    parser.addOption('tab-size',
        abbr: 't',
        help: 'Sets space indentation\n'
            'to see additional settings use --verbose flag',
        defaultsTo: '4');

    parser.addOption('tab-size-expression',
        help: 'The number of spaces in a single level of expression nesting.\n'
            '(defaults to <tab-size>)',
        hide: !verbose);

    parser.addOption('tab-size-block',
        help: 'The number of spaces in a block or collection body.\n'
            '(defaults to <tab-size>)',
        hide: !verbose);

    parser.addOption('tab-size-cascade',
        help: 'How much wrapped cascade sections indent.\n'
            '(defaults to <tab-size>)',
        hide: !verbose);

    parser.addOption('tab-size-initializer',
        help: 'The ":" on a wrapped constructor initialization list.\n'
            '(defaults to <tab-size>)',
        hide: !verbose);

    parser.addFlag('insert-tabs',
        negatable: false,
        help: 'Use tabs instead of spaces for indentation\n'
            '(internally it converts space indents to tabs\n'
            'uses <tab-size-block> or <tab-size> to detect indent levels for conversion)',
        defaultsTo: false,
        hide: !verbose);

    parser.addFlag('follow-links',
        negatable: false,
        help: 'Follow links to files and directories.\n'
            'If unset, links will be ignored.',
        hide: !verbose);
    parser.addFlag('version',
        negatable: false, help: 'Show dart_formatter version.', hide: !verbose);

    if (verbose) parser.addSeparator('Options when formatting from stdin:');

    parser.addOption('selection',
        help: 'Track selection (given as "start:length") through formatting.',
        hide: !verbose);
    parser.addOption('stdin-name',
        help: 'Use this path in error messages when input is read from stdin.',
        defaultsTo: 'stdin',
        hide: !verbose);
}

/// Used to parse text selection options.
List<int>? parseSelection(ArgResults argResults, {String optionName = 'selection'})
{
    var option = argResults[optionName] as String?;
    if (option == null) return null;

    // Can only preserve a selection when parsing from stdin.
    if (argResults.rest.isNotEmpty)
    {
        throw FormatException('Can only use --$optionName when reading from stdin.');
    }

    try
    {
        var coordinates = option.split(':');
        if (coordinates.length != 2)
        {
            throw FormatException(
                'Selection should be a colon-separated pair of integers, "123:45".');
        }

        return coordinates.map<int>((coord) => int.parse(coord.trim())).toList();
    }
    on FormatException catch (_)
    {
        throw FormatException(
            '--$optionName must be a colon-separated pair of integers, was '
            '"${argResults[optionName]}".');
    }
}
