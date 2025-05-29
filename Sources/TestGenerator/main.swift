import Foundation
import Stella

let fm = FileManager.default

do {
    try generate()
} catch let error as StellaParseError {
    quit(with: error.description)
} catch let error {
    quit(with: error.localizedDescription)
}

@MainActor func generate() throws {
    guard fm.changeCurrentDirectoryPath("Tests/StellaTests/Resources") else {
        quit(with: "Failed to go to the resource directory")
    }

    let goodSources = try fm.contentsOfDirectory(atPath: "stella-tests/ok")
    let errorFolders = try fm.contentsOfDirectory(atPath: "stella-tests/bad")

    if fm.fileExists(atPath: "printed-trees") {
        try fm.removeItem(atPath: "printed-trees")
    }
    if fm.fileExists(atPath: "printed-code") {
        try fm.removeItem(atPath: "printed-code")
    }

    try fm.createDirectory(
        atPath: "printed-trees/ok",
        withIntermediateDirectories: true
    )
    try fm.createDirectory(
        atPath: "printed-trees/bad",
        withIntermediateDirectories: false
    )
    try fm.createDirectory(
        atPath: "printed-code/ok",
        withIntermediateDirectories: true
    )
    try fm.createDirectory(
        atPath: "printed-code/bad",
        withIntermediateDirectories: false
    )

    for source in goodSources {
        try parseFile(at: "ok/\(source)")
    }

    for folder in errorFolders {
        if !folder.allSatisfy({ $0.isUppercase || $0 == "_" }) {
            print("Skipping \(folder)")
            continue
        }
        try fm.createDirectory(
            atPath: "printed-trees/bad/\(folder)",
            withIntermediateDirectories: false
        )
        try fm.createDirectory(
            atPath: "printed-code/bad/\(folder)",
            withIntermediateDirectories: false
        )
        for source in try fm.contentsOfDirectory(
            atPath: "stella-tests/bad/\(folder)"
        ) {
            try parseFile(at: "bad/\(folder)/\(source)")
        }
    }

    print("All Done ✅")
}

@MainActor func parseFile(at relativePath: String) throws {
    if !relativePath.contains(".st") && relativePath != "ok/infer_cons" {
        print("Skipping '\(relativePath)'")
        return
    }

    let text = try String(
        contentsOfFile: "stella-tests/\(relativePath)",
        encoding: .utf8
    )

    let tree = try Program.parser.run(sourceName: relativePath, input: text)

    let treeText = {
        var result = String()
        dump(tree, to: &result)
        return result.data(using: .utf8)
    }()

    do { // save ast
        let ok = fm.createFile(
            atPath: "printed-trees/\(relativePath).txt",
            contents: treeText
        )

        if ok {
            print("Saved parse-tree for: \(relativePath)")
        } else {
            print("⚠️ Failed to save parse-tree for: \(relativePath)")
        }
    }

    do { // save pretty-printed code
        let ok = fm.createFile(
            atPath: "printed-code/\(relativePath)",
            contents: tree.code.data(using: .utf8)
        )

        if ok {
            print("Saved reprinted source code for: \(relativePath)")
        } else {
            print("⚠️ Failed to save reprinted source code for: \(relativePath)")
        }
    }
}

func quit(with message: String) -> Never {
    print(message)
    exit(EXIT_FAILURE)
}
