// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS()
library node_format_service;

import 'dart:math' as math;

import 'package:dart_polisher/dart_polisher.dart';
import 'package:js/js.dart';

/// Formatted result from a call to exports.formatCode
@JS()
@anonymous
abstract class FResult
{
    external factory FResult({String code, String error});
    external String get code;
    external String get error;
}

/// Indents javascript interface
@JS()
@anonymous
abstract class FIndent
{
    /// The number of spaces in a block or collection body.
    external int? get block;

    /// How much wrapped cascade sections indent.
    external int? get cascade;

    /// The number of spaces in a single level of expression nesting.
    external int? get expression;

    /// The ":" on a wrapped constructor initialization list.
    external int? get constructorInitializer;

    external factory FIndent(
        {int? block, int? cascade, int? expression, int? constructorInitializer});
}

/// Formatter javascript interface
@JS()
@anonymous
abstract class FOptions
{
    external factory FOptions(
        {int? style,
        FIndent? tabSizes,
        int? indent,
        int? pageWidth,
        String? lineEnding,
        //Set<StyleFix> fixes,
        bool insertSpaces});

    /// see [CodeStyle]
    external int? get style;

    /// Default tab size
    external FIndent? get tabSizes;

    /// The number of spaces of indentation to prefix the output with.
    /// note: this is for the whole page, meaning from column 1, like padding.
    /// for tab size see [tabSizes]
    external int? indent;

    /// The number of columns that formatted output should be constrained to fit
    /// within.
    external int? pageWidth;

    /// The string that newlines should use.
    ///
    /// If not explicitly provided, this is inferred from the source text. If the
    /// first newline is `\r\n` (Windows), it will use that. Otherwise, it uses
    /// Unix-style line endings (`\n`).
    external String? lineEnding;

    /// The style fixes to apply while formatting.
    //external Set<StyleFix> fixes;

    /// Set type of tab to use [true] for space, [false] for tabs
    external bool insertSpaces;
}

@JS('exports.formatCode')
external set formatCode(Function formatter);

/*
Usage example from generated javascript:

  function dartMainRunner(main, args) {
    main(process.argv.slice(2));

    let i = {block: 9, cascade: 9,  expression: 9, constructorInitializer: 9};
    let o = {style: 1, tabSizes: i, indent: 0, pageWidth: 80, insertSpaces: true};
    result = exports.formatCode("void a(){int a;}", o);

    console.log(result.code);
    console.log("ERROR: " + result.error);
  }
*/

// Acording to benchmarks js version runs 10x Slower than Dart.
void main()
{
    formatCode = allowInterop((String source, [FOptions? options])
    {
        final style = CodeStyle.getEnum(options?.style);

        final tabSize = CodeIndent.opt(
            block: options?.tabSizes?.block,
            expression: options?.tabSizes?.expression,
            cascade: options?.tabSizes?.cascade,
            constructorInitializer: options?.tabSizes?.constructorInitializer,
        );

        final o = FormatterOptions.opt(
            style: style,
            tabSizes: tabSize,
            indent: options?.indent,
            insertSpaces: options?.insertSpaces,
            pageWidth: options?.pageWidth,
            lineEnding: options?.lineEnding,
            //fixes: options?.fixes,
        );

        var formatter = DartFormatter(o);

        FormatterException exception;
        try
        {
            return FResult(code: formatter.format(source));
        }
        on FormatterException catch (err)
        {
            // Couldn't parse it as a compilation unit.
            exception = err;
        }

        // Maybe it's a statement.
        try
        {
            return FResult(code: formatter.formatStatement(source));
        }
        on FormatterException catch (err)
        {
            // There is an error when parsing it both as a compilation unit and a
            // statement, so we aren't sure which one the user intended. As a
            // heuristic, we'll choose that whichever one we managed to parse more of
            // before hitting an error is probably the right one.
            if (_firstOffset(exception) < _firstOffset(err))
            {
                exception = err;
            }
        }

        // If we get here, it couldn't be parsed at all.
        return FResult(code: source, error: '$exception');
    });
}

/// Returns the offset of the error nearest the beginning of the file out of
/// all the errors in [exception].
int _firstOffset(FormatterException exception) =>
    exception.errors.map((error) => error.offset).reduce(math.min);
