import Foundation
import Stella

func quit(with message: String) -> Never {
    print(message)
    exit(EXIT_FAILURE)
}

let args = CommandLine.arguments

guard args.count == 2 else {
    quit(with:
        """
        Usage:
        swift run QuickParse <stella source file>
        """
    )
}

let filename = args[1]

let sourceText = try? String(contentsOfFile: filename, encoding: .utf8)

guard let sourceText else {
    quit(with: "Failed to read '\(filename)'")
}

let parsed: Program
do {
    parsed = try Program.parser.run(sourceName: filename, input: sourceText)
} catch let error as StellaParseError {
    quit(with: error.description)
} catch let error {
    quit(with: error.localizedDescription)
}

print("                        Program Syntax Tree                            ")
print("=====================================================================\n")

dump(parsed)

print("\n")
print("                        Reprinted Source Code                         ")
print("=====================================================================\n")

print(parsed.code)

print("\n=====================================================================\n")
