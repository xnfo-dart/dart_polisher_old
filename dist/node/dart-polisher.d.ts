// https://www.typescriptlang.org/docs/handbook/modules.html
// https://www.typescriptlang.org/docs/handbook/declaration-files/templates/module-d-ts.html
//declare module "dart-polisher" {

	interface FIndent {
		/// The number of spaces in a block or collection body.
		block?: number; // (4)

		/// How much wrapped cascade sections indent.
		cascade?: number; // (4)

		/// The number of spaces in a single level of expression nesting.
		expression?: number; // (4)

		/// The ":" on a wrapped constructor initialization list.
		constructorInitializer?: number; // (4)

	}

	interface FRange
	{
		/// The offset where the selection starts.
		offset?: number;

		/// The number of selected characters.
		length?: number;
	}

	interface FOptions {
		/// Style [0 = dart_style, 1 = expanded_style]
		style?: number; // (0)

		/// Indents
		tabSizes?: FIndent; // (4,4,4,4)

		/// The number of spaces of indentation to prefix the output with.
		/// note: this is for the whole page, meaning from column 1, like padding.
		/// for tab size see [tabSizes]
		indent?: number; // (0)

		/// The number of columns that formatted output should be constrained to fit within.
		pageWidth?: number; // (90)

		/// The string that newlines should use.
		///
		/// If not explicitly provided, this is inferred from the source text. If the
		/// first newline is `\r\n` (Windows), it will use that. Otherwise, it uses
		/// Unix-style line endings (`\n`).
		lineEnding?: string; // (null)

		//Set<StyleFix> fixes,

		/// Set type of tab to use [true] for space, [false] for tabs
		insertSpaces: boolean; // (true)

		/// Selected region of text. (used for returning the final selected region after code is formatted)
		/// `undefined` if there is no selection.
		selection? : FRange; // (null)
	}

	export interface FException
	{
		code: string;
		message: string;
		originalException : any; // Dart FormatterException or ArgumentError converted to Exception.
	}

	/// [code] has the formatted source code.
	/// if error is not null, then [code] is not formatted and [error] explains why.
	interface FResult
	{
		code: string;
		selection: FRange;
	}

	// interface DartPolisherFormatSource {
	// 	(code: string, options?: FOptions, isCompilationUnit?: boolean): FResult;
	// }

	// export var formatCode: DartPolisherFormatSource;

	export function formatCode(code: string, options?: FOptions, compilationUnit?: boolean): FResult;
//}

declare namespace Dart {
	/*
		Dart2js Exceptions are wrapped in javascript Error objects.
		An aditional dartException property is defined in the Error object.
		This is defined in dart-polisher typings in the Dart namespace as 'interface Exception'.

		So an thrown object from Dart looks like this: (extends from Error)
		interface Exception {
			name: string, 		// inherited from Error
			message: string, 	// inherited from Error
			stack?: string, 	// inherited from Error
			dartException: any
		}

		Exception.message is hooked to dartException.toString() method.
		If the Dart Exception has no defined toString method, message will return an object type only.

		'dartException: any' can be a DartPolisher FException wich looks like this:
		interface FException
		{
			code: string;
			message: string;
			originalException: any;
		}

	*/
	export interface Exception extends Error
	{
		dartException : any;
	}
}
