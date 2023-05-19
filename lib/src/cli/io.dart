// The code was taken from dart_style package and modified by Xnfo.
// The dart_style package copyright notice is as follows:
//
// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:dart_polisher/src/cli/cli_options.dart';
import 'package:dart_polisher/src/dart_formatter.dart';
import 'package:dart_polisher/src/exceptions.dart';
import 'package:dart_polisher/src/source_code.dart';

/// Reads and formats input from stdin until closed.
Future<void> formatStdin(CliOptions options, List<int>? selection, String name) async
{
    var selectionStart = 0;
    var selectionLength = 0;

    if (selection != null)
    {
        selectionStart = selection[0];
        selectionLength = selection[1];
    }

    var completer = Completer<void>();
    var input = StringBuffer();
    stdin.transform(Utf8Decoder()).listen(input.write, onDone: ()
    {
        /*var fo = FormatterOptions(
        style: Style.style1,
        indent: options.indent,
        pageWidth: options.pageWidth,
        fixes: {...options.fixes});*/
        var formatter = DartFormatter(options.foptions);
        try
        {
            options.beforeFile(null, name);

            var source = SourceCode(input.toString(),
                uri: name,
                selectionStart: selectionStart,
                selectionLength: selectionLength);
            var output = formatter.formatSource(source);

            options.afterFile(null, name, output, changed: source.text != output.text);
        }
        on FormatterException catch (err)
        {
            stderr.writeln(err.message());
            exitCode = 65; // sysexits.h: EX_DATAERR
        }
        catch (err, stack)
        {
            stderr.writeln('''Hit a bug in the formatter when formatting stdin.
Please report at: https://github.com/xnfo-dart/dart_polisher/issues
$err
$stack''');
            exitCode = 70; // sysexits.h: EX_SOFTWARE
        }

        completer.complete();
    });

    return completer.future;
}

/// Formats all of the files and directories given by [paths].
void formatPaths(CliOptions options, List<String> paths)
{
    for (var path in paths)
    {
        var directory = Directory(path);
        if (directory.existsSync())
        {
            if (!processDirectory(options, directory))
            {
                exitCode = 65;
            }
            continue;
        }

        var file = File(path);
        if (file.existsSync())
        {
            if (!processFile(options, file))
            {
                exitCode = 65;
            }
        }
        else
        {
            stderr.writeln('No file or directory found at "$path".');
        }
    }
}

/// Runs the formatter on every .dart file in [path] (and its subdirectories),
/// and replaces them with their formatted output.
///
/// Returns `true` if successful or `false` if an error occurred in any of the
/// files.
bool processDirectory(CliOptions options, Directory directory)
{
    options.showDirectory(directory.path);

    var success = true;
    var shownHiddenPaths = <String>{};

    var entries = directory.listSync(recursive: true, followLinks: options.followLinks);
    entries.sort((a, b) => a.path.compareTo(b.path));

    for (var entry in entries)
    {
        var displayPath = options.show.displayPath(directory.path, entry.path);

        if (entry is Link)
        {
            options.showSkippedLink(displayPath);
            continue;
        }

        if (entry is! File || !entry.path.endsWith('.dart')) continue;

        // If the path is in a subdirectory starting with ".", ignore it.
        var parts = p.split(p.relative(entry.path, from: directory.path));
        int? hiddenIndex;
        for (var i = 0; i < parts.length; i++)
        {
            if (parts[i].startsWith('.'))
            {
                hiddenIndex = i;
                break;
            }
        }

        if (hiddenIndex != null)
        {
            // Since we'll hide everything inside the directory starting with ".",
            // show the directory name once instead of once for each file.
            var hiddenPath = p.joinAll(parts.take(hiddenIndex + 1));
            if (shownHiddenPaths.add(hiddenPath))
            {
                options.showHiddenPath(hiddenPath);
            }
            continue;
        }

        if (!processFile(options, entry, displayPath: displayPath)) success = false;
    }

    return success;
}

/// Runs the formatter on [file].
///
/// Returns `true` if successful or `false` if an error occurred.
bool processFile(CliOptions options, File file, {String? displayPath})
{
    displayPath ??= file.path;
/*
  var fo = FormatterOptions(
      style: Style.style0,
      indent: options.indent,
      pageWidth: options.pageWidth,
      fixes: {...options.fixes});
*/
    var formatter = DartFormatter(options.foptions);
    try
    {
        var source = SourceCode(file.readAsStringSync(), uri: file.path);
        options.beforeFile(file, displayPath);
        var output = formatter.formatSource(source);
        options.afterFile(file, displayPath, output, changed: source.text != output.text);
        return true;
    }
    on FormatterException catch (err)
    {
        var color = Platform.operatingSystem != 'windows' &&
            stdioType(stderr) == StdioType.terminal;

        stderr.writeln(err.message(color: color));
    }
    on UnexpectedOutputException catch (err)
    {
        stderr.writeln('''Hit a bug in the formatter when formatting $displayPath.
$err
Please report at https://github.com/xnfo-dart/dart_polisher/issues.''');
    }
    catch (err, stack)
    {
        stderr.writeln('''Hit a bug in the formatter when formatting $displayPath.
Please report at https://github.com/xnfo-dart/dart_polisher/issues.
$err
$stack''');
    }

    return false;
}
