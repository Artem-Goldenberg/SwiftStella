import Testing
import Foundation

@testable import Stella

struct ParserTests {
    static let treesFolder = {
        guard let result = Bundle.module.url(
            forResource: "printed-trees", withExtension: nil
        ) else {
            fatalError(
                """
                Folder `printed-trees` which includes serialized program trees, \
                obtained by parsing corresponding source files from the `stella-tests` 
                repository, must be included into the test resources
                """
            )
        }
        return result
    }()

    static let okTrees = getOkFiles(
        root: treesFolder,
        description: """
            parse trees corresponding to the sources from the \
            same folder inside the `stella-tests` repository
            """
    )

    static let badTrees = getBadFiles(
        root: treesFolder,
        description: """
            parse trees corresponding to the sources from the \
            same folder inside the `stella-tests` repository
            """
    )

    @Test(
        "Parser stability test",
        arguments: zip(
            (okPrograms + badPrograms).sorted(),
            (okTrees + badTrees).sorted()
        )
    )
    func parserStability(sourceURL: URL, treeURL: URL) async throws {
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        let controlTreeText = try String(contentsOf: treeURL, encoding: .utf8)

        let program = try Program.parser.run(
            sourceName: sourceURL.lastPathComponent,
            input: sourceText
        )

        var treeText = String()
        dump(program, to: &treeText)

        #expect(treeText == controlTreeText)
    }

}
