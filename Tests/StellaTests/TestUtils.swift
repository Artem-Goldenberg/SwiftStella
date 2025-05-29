import Foundation
import Testing

let programsFolder = {
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

let okPrograms = getOkFiles(root: programsFolder, description: "Stella programs")

let badPrograms = getBadFiles(
    root: programsFolder,
    description: """
              erroneous Stella programs grouped in subfolders by the type of \
              semantic error they are emitting
              """
)

func getOkFiles(root folder: URL, description: String) -> [URL] {
    guard let result = try? listItems(of: folder.appending(component: "ok"))
    else {
        fatalError(
            "Resource folder `\(folder)` must include a subfolder `ok` with \(description)"
        )
    }
    return result
}

func getBadFiles(root folder: URL, description: String) -> [URL] {
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

func listItems(of folder: URL) throws -> [URL] {
    return try FileManager.default.contentsOfDirectory(
        at: folder, includingPropertiesForKeys: nil
    )
}


extension URL: @retroactive Comparable {
    public static func < (a: URL, b: URL) -> Bool {
        a.absoluteString < b.absoluteString
    }
}

extension URL: @retroactive CustomTestStringConvertible {
    public var testDescription: String {
        guard pathComponents.count >= 2 else {
            return lastPathComponent
        }
        return pathComponents.suffix(2).joined(separator: "/")
    }
}

extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
