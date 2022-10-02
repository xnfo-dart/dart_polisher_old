// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS()
library node_format_service;

import 'dart:math' as math;

import 'package:dart_polisher/dart_polisher.dart';
import 'package:js/js.dart';

//TODO (tekert): Expose formatter options

@JS()
@anonymous
class FResult
{
    external factory FResult({String code, String error});
    external String get code;
    external String get error;
}

@JS()
@anonymous
class FOptions
{
    external factory FOptions({int style, int tabSize});
    external int get style;
    external int get tabSize;
}

@JS('exports.formatCode')
external set formatCode(Function formatter);

/*
Usage example from generated javascript:

  function dartMainRunner(main, args) {
    main(process.argv.slice(2));
    var o = {style: 1, tabSize: 4};
    result = exports.formatCode("void a(){int a;}", o);

    console.log(result.code);
    console.log(result.error);
  }
*/

void main()
{
    formatCode = allowInterop((String source, [FOptions? options])
    {
        final style = CodeStyle.getEnum(options?.style);
        final tabSize = CodeIndent.opt(
            block: options?.tabSize,
            expression: options?.tabSize,
            cascade: options?.tabSize,
            constructorInitializer: options?.tabSize);
        var formatter = DartFormatter(FormatterOptions(style: style, tabSizes: tabSize));

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
