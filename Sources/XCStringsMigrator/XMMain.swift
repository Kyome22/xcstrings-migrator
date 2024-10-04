import Foundation

public struct XMMain {
    public static func run(
        sourceLanguage: String,
        paths: [String],
        outputPath: String,
        verbose: Bool
    ) throws {
        let xm = XMMain()
        let stringsDataTable = xm.extractStringsData(paths)
        try stringsDataTable.forEach { item in
            let xcstrings = xm.convertXCStrings(sourceLanguage, item.value)
            try xm.exportXCStringsFile(item.key, xcstrings, outputPath, verbose)
        }
    }

    func extractKeyValue(url: URL) -> [String: String]? {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        let values: [String: String] = text
            .components(separatedBy: .newlines)
            .compactMap { item -> (String, String)? in
                let regex = /"(.+)" = "(.+)";/
                guard let match = item.wholeMatch(of: regex) else { return nil }
                return (String(match.1), String(match.2))
            }
            .reduce(into: [:]) { partialResult, tuple in
                partialResult[tuple.0] = tuple.1
            }
        return values
    }

    func extractStringsData(_ paths: [String]) -> [String: [StringsData]] {
        let stringsFiles = paths
            .map { URL(filePath: $0) }
            .filter { url in
                url.pathExtension == "lproj" && FileManager.default.fileExists(atPath: url.path())
            }
            .map { url -> (String, [URL]) in
                let language = url.deletingPathExtension().lastPathComponent
                guard let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path()) else {
                    return (language, [])
                }
                let urls = contents
                    .map { url.appending(component: $0) }
                    .filter { $0.pathExtension == "strings" }
                return (language, urls)
            }
        var tables = [String: [StringsData]]()
        stringsFiles.forEach { item in
            item.1.forEach { url in
                let tableName = url.deletingPathExtension().lastPathComponent
                if let dict = extractKeyValue(url: url) {
                    if tables.keys.contains(tableName) {
                        tables[tableName]?.append(StringsData(language: item.0, values: dict))
                    } else {
                        tables[tableName] = [StringsData(language: item.0, values: dict)]
                    }
                }
            }
        }
        return tables
    }

    func convertXCStrings(_ sourceLanguage: String, _ stringsData: [StringsData]) -> XCStrings {
        var strings = [String: Strings]()
        stringsData.forEach { item in
            item.values.forEach { keyValue in
                if strings.keys.contains(keyValue.key) {
                    strings[keyValue.key]?.localizations[item.language] = Localization(stringUnit: StringUnit(value: keyValue.value))
                } else {
                    strings[keyValue.key] = Strings(
                        localizations: [
                            item.language: Localization(stringUnit: StringUnit(value: keyValue.value))
                        ]
                    )
                }
            }
        }
        return XCStrings(
            sourceLanguage: sourceLanguage,
            strings: strings,
            version: "1.0"
        )
    }

    func exportXCStringsFile(_ tableName: String, _ xcstrings: XCStrings, _ outputPath: String, _ verbose: Bool) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(xcstrings)
        if verbose, let jsonString = String(data: data, encoding: .utf8) {
            Swift.print(jsonString)
        }
        let outputURL = URL(filePath: outputPath)
            .appending(path: tableName)
            .appendingPathExtension("xcstrings")
        try data.write(to: outputURL)
    }
}
