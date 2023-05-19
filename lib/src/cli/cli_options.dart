// The code was taken from dart_style package and modified by Xnfo.
// The dart_style package copyright notice is as follows:
//
// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dart_polisher/dart_polisher.dart';

import 'package:dart_polisher/src/cli/output.dart';
import 'package:dart_polisher/src/cli/show.dart';
import 'package:dart_polisher/src/cli/summary.dart';

const dartFormatterVersion = DPConst.VERSION;

/// Global options that affect how the formatter produces and uses its outputs.
/// [foptions] field has options that specify how source code will be formatted
/// the other fields specify how the cli will deal with files and outputs.
class CliOptions
{
    /// Options for the dart-formatter that specify how source code will be formatted.
    final FormatterOptions foptions;

    /// Whether symlinks should be traversed when formatting a directory.
    final bool followLinks;

    /// Which affected files should be shown.
    final Show show;

    /// Where formatted code should be output.
    final Output output;

    final Summary summary;

    /// Sets the exit code to 1 if any changes are made.
    final bool setExitIfChanged;

    CliOptions(
        {this.foptions = const FormatterOptions(),
        this.followLinks = false,
        this.show = Show.changed,
        this.output = Output.write,
        Summary? summary,
        this.setExitIfChanged = false})
        : summary = summary ?? Summary.profile();

    /// Called when [file] is about to be formatted.
    ///
    /// If stdin is being formatted, then [file] is `null`.
    void beforeFile(File? file, String label)
    {
        summary.beforeFile(file, label);
    }

    /// Describe the processed file at [path] with formatted [result]s.
    ///
    /// If the contents of the file are the same as the formatted output,
    /// [changed] will be false.
    ///
    /// If stdin is being formatted, then [file] is `null`.
    void afterFile(File? file, String displayPath, SourceCode result,
        {required bool changed})
    {
        summary.afterFile(this, file, displayPath, result, changed: changed);

        // Save the results to disc.
        var overwritten = false;
        if (changed)
        {
            overwritten = output.writeFile(file, displayPath, result);
        }

        // Show the user.
        if (show.file(displayPath, changed: changed, overwritten: overwritten))
        {
            output.showFile(displayPath, result);
        }

        // Set the exit code.
        if (setExitIfChanged && changed) exitCode = 1;
    }

    /// Describes the directory whose contents are about to be processed.
    void showDirectory(String path)
    {
        if (output != Output.json)
        {
            show.directory(path);
        }
    }

    /// Describes the symlink at [path] that wasn't followed.
    void showSkippedLink(String path)
    {
        show.skippedLink(path);
    }

    /// Describes the hidden [path] that wasn't processed.
    void showHiddenPath(String path)
    {
        show.hiddenPath(path);
    }
}
