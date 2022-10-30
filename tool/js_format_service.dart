@JS()
library js_format_service;

import 'package:dart_polisher/dart_polisher.dart';
import 'package:js/js.dart';

/// Formatted result from a call to exports.formatCode
@JS()
@anonymous
abstract class FResult
{
    external factory FResult({String code /*, String? error*/, FRange selection});
    external String get code;
    external FRange get selection;
}

@JS()
@anonymous

/// Selection will be as close to matching the original as possible, but
/// whitespace at the beginning or end of the selected region will be ignored.
/// If preserving selection information is not required, null can be
/// specified for both the selection offset and selection length.
abstract class FRange
{
    external factory FRange({int? offset, int? length});

    /// The offset in [text] where the selection begins, or `null` if there is
    /// no selection.
    external int? get offset;

    /// The number of selected characters or `null` if there is no selection.
    external int? get length;
}

/// Indents javascript interface
@JS()
@anonymous
abstract class FIndent
{
    external factory FIndent(
        {int? block, int? cascade, int? expression, int? constructorInitializer});

    /// The number of spaces in a block or collection body.
    external int? get block;

    /// How much wrapped cascade sections indent.
    external int? get cascade;

    /// The number of spaces in a single level of expression nesting.
    external int? get expression;

    /// The ":" on a wrapped constructor initialization list.
    external int? get constructorInitializer;
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
        bool insertSpaces,
        FRange? selection});

    /// see [CodeStyle]
    external int? get style;

    /// Default tab size
    external FIndent? get tabSizes;

    /// The number of spaces of indentation to prefix the output with.
    /// note: this is for the whole page, meaning from column 1, like padding.
    /// for tab size see [tabSizes]
    external int? get indent;

    /// The number of columns that formatted output should be constrained to fit
    /// within.
    external int? get pageWidth;

    /// The string that newlines should use.
    ///
    /// If not explicitly provided, this is inferred from the source text. If the
    /// first newline is `\r\n` (Windows), it will use that. Otherwise, it uses
    /// Unix-style line endings (`\n`).
    external String? get lineEnding;

    /// The style fixes to apply while formatting.
    //external Set<StyleFix> fixes;

    /// Set type of tab to use [true] for space, [false] for tabs
    external bool get insertSpaces;

    /// Used for returning the final selected range after code is formatted.
    external FRange? get selection;
}

@JS('exports.formatCode')
external set formatCode(Function formatter);

@JS()
@anonymous
abstract class FException implements Exception
{
    external factory FException(
        {required String code,
        required String message,
        required Exception originalException});

    // TODO(tekert): can't define body of toString because is external,
    // the wrapped exception from js (Error.message) will not point to this.dartException.toString()
    // for now is doesn't matter because if FException is caught the client gets it from 'Error.dartException.message' directly.
    @override
    external String toString();

    external String get code;
    external String get message;
    external Exception get originalException;
}

//! fields except message wont get converted to js. Use FException with its caveats.
class FException2 implements Exception
{
    final String code;
    final String message;
    final Exception originalException;

    @override
    String toString() => message;

    const FException2(
        {required this.code, required this.originalException, required this.message});
}

/*
Usage example from generated javascript:

  function dartMainRunner(main, args) {
    main(process.argv.slice(2));

    let sel = {offset: 8, length: 5}
    let ind = {block: 9, cascade: 9,  expression: 9, constructorInitializer: 9};
    let opt = {style: 1, tabSizes: i, indent: 0, pageWidth: 80, insertSpaces: true, selection: sel};
    result = exports.formatCode("void a(){int a;}", opt);

    console.log(result.code);
    console.log(result.selection); // will be null if selection was not given in opt
  }
*/

// Acording to benchmarks, js version runs 10x Slower than Dart.
void main()
{
    // [compilationUnit] is true if the source string is the whole file or false if is a subsection.
    formatCode =
        allowInterop((String source, [FOptions? options, bool isCompilationUnit = true])
    {
        final style = CodeStyle.getStyleFromCode(options?.style);

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

        try
        {
            // NOTE: web formatting can work by giving it the entire string (compilation unit)
            // or part of it, (text with only a {block} statement)
            // for format to work on any range of text we have to use selection offsets over the entire string,
            // wich are only available in SourceCode as selections, making format() and formatStatement() redundant.

            // NOTE: Don't use formatStatement as there is no need if using range offsets (SourceCode selections),
            // conceptually is the almost same thing and causes confusion with source termination.

            var unformattedCode = SourceCode(source,
                isCompilationUnit: isCompilationUnit,
                selectionStart: options?.selection?.offset,
                selectionLength: options?.selection?.length);

            var formattedCode = formatter.formatSource(unformattedCode);
            var range = FRange(
                offset: formattedCode.selectionStart,
                length: formattedCode.selectionLength);

            return FResult(code: formattedCode.text, selection: range);
        }
        on FormatterException catch (err)
        {
            throw FException(
                code: "FORMAT_WITH_ERRORS",
                originalException: err,
                message: err.message());
        }
        on ArgumentError catch (err)
        {
            throw FException(
                code: "FORMAT_RANGE_ERROR",
                originalException: Exception(err.message),
                message: err.message as String);
        }
    });
}
