import Stella
import Foundation

let args = CommandLine.arguments

guard args.count == 2 else {
    print(
        """
        Usage:
        swift run QuickParse <stella source file>
        """
    )
    exit(EXIT_FAILURE)
}

let filename = args[1]

let sourceText = try String(contentsOfFile: filename, encoding: .utf8)

let parsed = try Program.parser.run(sourceName: filename, input: sourceText)

dump(parsed)
