import Testing
import Foundation

@testable import Stella

struct ParserTests {
    static let programsFolder = {
        guard let result = Bundle.module.url(forResource: "stella-tests", withExtension: nil)
        else {
            fatalError(
                """
                Cannot find the `stella-tests` repository folder, \
                make sure to load the git submodule with this repository
                """
            )
        }
        return result
    }()

    static let okPrograms = getOkFiles(root: programsFolder, description: "Stella programs")

    static let badPrograms = getBadFiles(
        root: programsFolder,
        description: """
            erroneous Stella programs grouped in subfolders by the type of \
            semantic error they are emitting
            """
    )

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
        "Parser test",
        arguments: zip(
            (okPrograms + badPrograms).sorted(),
            (okTrees + badTrees).sorted()
        )
    )
    func compareParsing(sourceURL: URL, treeURL: URL) async throws {
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

    // MARK: - Utils

    static func listItems(of folder: URL) throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(
            at: folder, includingPropertiesForKeys: nil
        )
    }

    static func getOkFiles(root folder: URL, description: String) -> [URL] {
        guard let result = try? listItems(of: folder.appending(component: "ok"))
        else {
            fatalError(
                "Resource folder `\(folder)` must include a subfolder `ok` with \(description)"
            )
        }
        return result
    }

    static func getBadFiles(root folder: URL, description: String) -> [URL] {
        guard let folders = try? listItems(of: folder.appending(component: "bad"))
        else {
            fatalError(
                "Resource folder `\(folder)` must include a subfolder `bad` with \(description)"
            )
        }
        return folders.flatMap { folder in
            guard folder.isDirectory else {
                print("Skipping \(folder)")
                return [URL]()
            }
            guard let programs = try? listItems(of: folder) else {
               fatalError("Failed to list the items of a `\(folder)`")
            }
            return programs
        }
    }

}

extension URL: @retroactive Comparable {
    public static func < (a: URL, b: URL) -> Bool {
        a.absoluteString < b.absoluteString
    }
}

extension URL: @retroactive CustomTestStringConvertible {
    public var testDescription: String {
        lastPathComponent
    }
}

extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
