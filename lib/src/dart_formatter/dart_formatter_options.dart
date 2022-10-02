// ignore_for_file: constant_identifier_names

import 'package:dart_polisher/src/dart_formatter/style_fix.dart';
import 'package:dart_polisher/src/constants.dart';
import 'package:dart_polisher/src/dart_formatter/utils/bitmasks.dart';

/// Styles can have each different tab modes and indents.
enum CodeStyle {
    DartStyle("Dart  Style", "Google 'dart' style [custom tab indents & tab mode]", 0, 0),
    ExpandedStyle(
        "ExpandedSetyle",
        "dart_style with outer braces on block-like nodes",
        1,
        BodyOpt.outerBracesOnBlockLike |
            BodyOpt.outerBracesOnEnumSmart |
            BodyOpt.outerTryStatementClause |
            BodyOpt.outerIfStatementElse),
    style2("**", "****", 2, 0),
    style3(".", "...", 3, 0),
    ;


    /// Get the enum corresponding to [styleCode],
    /// returns the default enum if there is no match or if [styleCode] is null.
    static CodeStyle getEnum(int? styleCode)
    {
        return CodeStyle.values.firstWhere((element) => element.styleCode == styleCode,
            orElse: () => CodeStyle.DartStyle);
    }

    const CodeStyle(this.styleName, this.styleDescription, this.styleCode, this.mask);

    final String styleName;
    final String styleDescription;
    final int styleCode;
    final int mask;
}

/// Class with bit values representing Formatting options for Body-like sintaxes
///
/// Its used to build bitmasks: bitmask = option1 | option2;
///
/// These options are used internally by the formatter to format code.
///
/// Bracket can be '{}' or '()' or '[]'
/// Here are the brackets applicable on Body.
///
/// Bracket=>Body=> (Block-like sintax)
///  Block | ClassDeclaration | ExtensionDeclaration | MixinDeclaration | EnumDeclaration
///
/// Bracket=>CollectionLiteral=> (Collections-like sintax)
///  ArgumentList | AssertInitializer | AssertStatement | ListLiteral | SetOrMapLiteral
///
/// Block means:
/// block ::= '{' statement* '}'
/// statement ::= Block | VariableDeclarationStatement | ForStatement | ForEachStatement |
///  WhileStatement | DoStatement | SwitchStatement | IfStatement | TryStatement |
///  BreakStatement | ContinueStatement | ReturnStatement | ExpressionStatement |
///  FunctionDeclarationStatement
///
/// Clients may not extend, implement or mix-in this class.
class BodyOpt
{
    /// Braces '{}' on Block-like Bodys
    ///
    /// These are always newlined.
    /// Includes: ClassDeclaration | ExtensionDeclaration | MixinDeclaration | SwitchStatement
    ///
    /// Excludes: TypedLiteral | EnumDeclaration (These are handled in other options)
    static const int outerBracesOnBlockLike = CompatibleBits.bit1;

    /// Outer braces on collection literals
    /// If they split, they become difficult to distinguish between blocks and collections.
    /// It's folded if it can fit inside linelengt and split if not.
    ///
    ///! NOT IMPLEMENTED.
    static const int outerBracesOnCollectionLiteralsSmart = CompatibleBits.bit2;

    /// Enum is a specials case, can look good folded if it fits in lineLenght.
    /// true means split '{' if contents split, remain folded if not.
    /// same case with collection literals, looks better if its folded.
    /// that way it can be better distinguished between block-like nodes.
    // TODO (tekert): check if it looks good.
    static const int outerBracesOnEnumSmart = CompatibleBits.bit3;

    // The stataments that follow a '}' like: else/else if/catch/on/finally

    /// Puts clause within a [TryStatement] clause on newline
    static const int outerTryStatementClause = CompatibleBits.bit4;

    /// Puts else [Statement]s on newline, uses space if not set.
    static const int outerIfStatementElse = CompatibleBits.bit5;

    const BodyOpt();

    static int getExpandedBody()
    {
        return outerBracesOnBlockLike |
            outerBracesOnEnumSmart |
            outerTryStatementClause |
            outerIfStatementElse;
    }
}

/// Constants for the number of spaces in various kinds of indentation.
class CodeIndent
{
    /// The number of spaces in a block or collection body.
    final int block;

    /// How much wrapped cascade sections indent.
    final int cascade;

    /// The number of spaces in a single level of expression nesting.
    final int expression;

    /// The ":" on a wrapped constructor initialization list.
    final int constructorInitializer;

    // If a parameter is ommited a default value is asigned.
    const CodeIndent(
        {this.block = DEFAULT_BLOCK_INDENT,
        this.cascade = DEFAULT_CASCADE_INDENT,
        this.expression = DEFAULT_EXPRESSION_INDENT,
        this.constructorInitializer = DEFAULT_CONSTRUCTOR_INITIALIZER_INDENT});

    // If a parameter is ommited or null a default value is asigned.
    const CodeIndent.opt(
        {int? block, int? cascade, int? expression, int? constructorInitializer})
        : block = block ?? DEFAULT_BLOCK_INDENT,
          cascade = cascade ?? DEFAULT_CASCADE_INDENT,
          expression = expression ?? DEFAULT_EXPRESSION_INDENT,
          constructorInitializer =
              constructorInitializer ?? DEFAULT_CONSTRUCTOR_INITIALIZER_INDENT;
}

/// Options that control how the code will be formattend
/// these are used as an argument for [DartFormatter]
class FormatterOptions
{
    /// The number of spaces of indentation to prefix the output with.
    /// note: this is for the whole page, meaning from column 1, like padding.
    /// for tab size see [tabSizes]
    final int indent;

    /// The number of columns that formatted output should be constrained to fit
    /// within.
    final int pageWidth;

    /// The string that newlines should use.
    ///
    /// If not explicitly provided, this is inferred from the source text. If the
    /// first newline is `\r\n` (Windows), it will use that. Otherwise, it uses
    /// Unix-style line endings (`\n`).
    final String? lineEnding;

    /// The style fixes to apply while formatting.
    final Set<StyleFix> fixes;

    /// Space indents for expressions, blocks, cascade and constructor initializer
    final CodeIndent tabSizes;

    /// Set type of tab to use [true] for space, [false] for tabs
    final bool insertSpaces;

    /// Style to use for source code formatting
    /// based on a modified sets of rules derived from the original dart_style classes.
    final CodeStyle style;

    const FormatterOptions(
        {this.lineEnding,
        this.indent = 0,
        this.pageWidth = DEFAULT_PAGEWIDTH,
        this.insertSpaces = DEFAULT_INSERTSPACES,
        this.style = DEFAULT_STYLE,
        this.fixes = const {},
        this.tabSizes = const CodeIndent()});

    /// Accepts null values.
    const FormatterOptions.opt(
        {this.lineEnding,
        int? indent,
        int? pageWidth,
        bool? insertSpaces,
        CodeStyle? style,
        Set<StyleFix>? fixes,
        CodeIndent? tabSizes})
        : indent = indent ?? 0,
          pageWidth = pageWidth ?? DEFAULT_PAGEWIDTH,
          insertSpaces = insertSpaces ?? DEFAULT_INSERTSPACES,
          style = style ?? DEFAULT_STYLE,
          fixes = fixes ?? const {},
          tabSizes = tabSizes ?? const CodeIndent();
}
