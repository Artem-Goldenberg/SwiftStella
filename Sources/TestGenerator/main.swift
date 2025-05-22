import Foundation
import Stella

let fm = FileManager.default

guard fm.changeCurrentDirectoryPath("Tests/StellaTests/Resources") else {
    print("Failed to go to the resource directory")
    exit(EXIT_FAILURE)
}

let goodSources = try fm.contentsOfDirectory(atPath: "stella-tests/ok")
let errorFolders = try fm.contentsOfDirectory(atPath: "stella-tests/bad")

if fm.fileExists(atPath: "printed-trees") {
    try fm.removeItem(atPath: "printed-trees")
}

try fm.createDirectory(
    atPath: "printed-trees/ok",
    withIntermediateDirectories: true
)
try fm.createDirectory(
    atPath: "printed-trees/bad",
    withIntermediateDirectories: false
)

for source in goodSources {
    try parseFile(at: "ok/\(source)")
}

for folder in errorFolders {
    let path = "printed-trees/bad/\(folder)"
    if !folder.allSatisfy({ $0.isUppercase || $0 == "_" }) {
        print("Skipping \(folder)")
        continue
    }
    try fm.createDirectory(
        atPath: path,
        withIntermediateDirectories: false
    )
    for source in try fm.contentsOfDirectory(
        atPath: "stella-tests/bad/\(folder)"
    ) {
        try parseFile(at: "bad/\(folder)/\(source)")
    }
}

print("All Done ✅")

func parseFile(at relativePath: String) throws {
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

    let ok = fm.createFile(atPath: "printed-trees/\(relativePath).txt", contents: treeText)

    if ok {
        print("Saved parse-tree for: \(relativePath)")
    } else {
        print("Failed to save parse-tree for: \(relativePath)")
    }
}
