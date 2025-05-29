import Testing
import Foundation

@testable import Stella

struct PrinterTests {
    @Test(
        "Printer soundness test",
        arguments: (okPrograms + badPrograms).sorted()
    )
    func printerCorrectness(sourceURL: URL) async throws {
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)

        let controlProgram = try Program.parser.run(
            sourceName: sourceURL.lastPathComponent,
            input: sourceText
        )

        let prettyPrintedText = controlProgram.code

        var controlTreeText = String()
        dump(controlProgram, to: &controlTreeText)

        let program = try Program.parser.run(
            sourceName: "pretty-printed source",
            input: prettyPrintedText
        )

        var treeText = String()
        dump(program, to: &treeText)

        // expect the ast from source and pretty-print are the same
        #expect(treeText == controlTreeText)
    }

    static let codeFolder = {
        guard let result = Bundle.module.url(
            forResource: "printed-code", withExtension: nil
        ) else {
            fatalError(
                """
                Folder `printed-code` which includes pretty-printed programs from the \
                the `stella-tests` repository must be included into the test resources.
                """
            )
        }
        return result
    }()

    static let okReprintedPrograms = getOkFiles(
        root: codeFolder,
        description: """
            pretty-printed code corresponding to the sources from the \
            same folder inside the `stella-tests` repository
            """
    )

    static let badReprintedPrograms = getBadFiles(
        root: codeFolder,
        description: """
            pretty-printed code corresponding to the sources from the \
            same folder inside the `stella-tests` repository
            """
    )

    @Test(
        "Printer stability test",
        arguments: zip(
            (okPrograms + badPrograms).sorted(),
            (okReprintedPrograms + badReprintedPrograms).sorted()
        )
    )
    func printerStability(sourceURL: URL, reprintURL: URL) async throws {
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        let controlReprintText = try String(contentsOf: reprintURL, encoding: .utf8)

        let program = try Program.parser.run(
            sourceName: sourceURL.lastPathComponent,
            input: sourceText
        )

        let reprintText = program.code

        #expect(reprintText == controlReprintText)
    }

}
