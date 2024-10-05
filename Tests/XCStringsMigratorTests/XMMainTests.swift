import XCTest

@testable import XCStringsMigrator

final class XMMainTests: XCTestCase {
    func test_extractKeyValue() throws {
        try XCTContext.runActivity(named: "If the URL is invalid, nil will be returned.") { _ in
            let sut = XMMain(sourceLanguage: "", paths: [], outputPath: "", verbose: false)
            let url = try XCTUnwrap(Bundle.module.resourceURL).appending(path: "not-exist.strings")
            let actual = sut.extractKeyValue(from: url)
            XCTAssertNil(actual)
        }
        try XCTContext.runActivity(named: "If strings file is valid, dictionary will be returned.") { _ in
            let sut = XMMain(sourceLanguage: "", paths: [], outputPath: "", verbose: false)
            let url = try XCTUnwrap(Bundle.module.url(forResource: "Localizable", withExtension: "strings"))
            let actual = sut.extractKeyValue(from: url)
            let expect = [
                "key1": "value1",
                "key2": "value2",
                "key3": "value3",
                "key4": "value4",
            ]
            XCTAssertEqual(actual, expect)
        }
    }

    func test_extractStringsData() throws {
        XCTContext.runActivity(named: "If paths is empty, empty array is returned.") { _ in
            let sut = XMMain(sourceLanguage: "", paths: [], outputPath: "", verbose: false)
            let actual = sut.extractStringsData()
            XCTAssertEqual(actual, [])
        }
        try XCTContext.runActivity(named: "If path extension is not lproj, empty array is returned.") { _ in
            let url = try XCTUnwrap(Bundle.module.url(forResource: "dummy", withExtension: nil))
            let sut = XMMain(sourceLanguage: "", paths: [url.path()], outputPath: "", verbose: false)
            let actual = sut.extractStringsData()
            XCTAssertEqual(actual, [])
        }
        try XCTContext.runActivity(named: "If path extension is lproj but file does not exist, empty array is returned.") { _ in
            let url = try XCTUnwrap(Bundle.module.resourceURL).appending(path: "not-exist.lproj")
            let sut = XMMain(sourceLanguage: "", paths: [url.path()], outputPath: "", verbose: false)
            let actual = sut.extractStringsData()
            XCTAssertEqual(actual, [])
        }
        try XCTContext.runActivity(named: "If path extension is lproj and file exists but contains no strings files, empty array is returned.") { _ in
            let url = try XCTUnwrap(Bundle.module.url(forResource: "dummy", withExtension: "lproj"))
            let sut = XMMain(sourceLanguage: "", paths: [url.path()], outputPath: "", verbose: false)
            let actual = sut.extractStringsData()
            XCTAssertEqual(actual, [])
        }
        try XCTContext.runActivity(named: "If path extension is lproj and file exists and contains some strings files, array with elements is returned.") { _ in
            let url = try XCTUnwrap(Bundle.module.url(forResource: "en", withExtension: "lproj"))
            let sut = XMMain(sourceLanguage: "", paths: [url.path()], outputPath: "", verbose: false)
            let actual = sut.extractStringsData()
            let expect = [
                StringsData(
                    tableName: "Localizable",
                    language: "en",
                    values: [
                        "key1": "value1",
                        "key2": "value2",
                        "key3": "value3",
                        "key4": "value4",
                    ]
                )
            ]
            XCTAssertEqual(actual, expect)
        }
    }

    func test_classifyStringsData() throws {
        XCTContext.runActivity(named: "StringData array is classified by table name.") { _ in
            let sut = XMMain(sourceLanguage: "", paths: [], outputPath: "", verbose: false)
            let input: [StringsData] = [
                StringsData(tableName: "Module1", language: "en", values: [:]),
                StringsData(tableName: "Module1", language: "ja", values: [:]),
                StringsData(tableName: "Module2", language: "en", values: [:]),
                StringsData(tableName: "Module2", language: "ja", values: [:]),
            ]
            let actual = sut.classifyStringsData(with: input)
            let expect = [
                "Module1": [
                    StringsData(tableName: "Module1", language: "en", values: [:]),
                    StringsData(tableName: "Module1", language: "ja", values: [:]),
                ],
                "Module2": [
                    StringsData(tableName: "Module2", language: "en", values: [:]),
                    StringsData(tableName: "Module2", language: "ja", values: [:]),
                ]
            ]
            XCTAssertEqual(actual, expect)
        }
    }

    func test_convertToXCStrings() throws {
        XCTContext.runActivity(named: "StringData array is converted to XCStrings object.") { _ in
            let sut = XMMain(sourceLanguage: "en", paths: [], outputPath: "", verbose: false)
            let input: [StringsData] = [
                StringsData(tableName: "Module1", language: "en", values: ["key": "English"]),
                StringsData(tableName: "Module1", language: "ja", values: ["key": "Japanese"]),
            ]
            let actual = sut.convertToXCStrings(from: input)
            let expect = XCStrings(
                sourceLanguage: "en",
                strings: ["key": Strings(localizations: [
                    "en": Localization(stringUnit: StringUnit(value: "English")),
                    "ja": Localization(stringUnit: StringUnit(value: "Japanese")),
                ])],
                version: "1.0"
            )
            XCTAssertEqual(actual, expect)
        }
    }

    func test_exportXCStringsFile() throws {
        try XCTContext.runActivity(named: "If the XCStrings object is valid and verbose is false, the file is successfully exported without outputting details.") { _ in
            var sut = XMMain(sourceLanguage: "en", paths: [], outputPath: "", verbose: false)
            var standardOutputs = [String]()
            sut.standardOutput = { items in
                standardOutputs.append(contentsOf: items.map({ "\($0)" }))
            }
            let input = XCStrings(
                sourceLanguage: "en",
                strings: ["key": Strings(localizations: [
                    "en": Localization(stringUnit: StringUnit(value: "English")),
                    "ja": Localization(stringUnit: StringUnit(value: "Japanese")),
                ])],
                version: "1.0"
            )
            try sut.exportXCStringsFile(name: "Localizable", input)
            let expect = ["Succeeded to export xcstrings files."]
            XCTAssertEqual(standardOutputs, expect)
        }
        try XCTContext.runActivity(named: "If the XCStrings object is valid and verbose is true, the file is successfully exported with outputting details.") { _ in
            var sut = XMMain(sourceLanguage: "en", paths: [], outputPath: "", verbose: true)
            var standardOutputs = [String]()
            sut.standardOutput = { items in
                standardOutputs.append(contentsOf: items.map({ "\($0)" }))
            }
            let input = XCStrings(
                sourceLanguage: "en",
                strings: ["key": Strings(localizations: [
                    "en": Localization(stringUnit: StringUnit(value: "English")),
                    "ja": Localization(stringUnit: StringUnit(value: "Japanese")),
                ])],
                version: "1.0"
            )
            try sut.exportXCStringsFile(name: "Localizable", input)
            let details = """
               {
                 "sourceLanguage" : "en",
                 "strings" : {
                   "key" : {
                     "localizations" : {
                       "en" : {
                         "stringUnit" : {
                           "state" : "translated",
                           "value" : "English"
                         }
                       },
                       "ja" : {
                         "stringUnit" : {
                           "state" : "translated",
                           "value" : "Japanese"
                         }
                       }
                     }
                   }
                 },
                 "version" : "1.0"
               }
               """
            let expect = [details, "Succeeded to export xcstrings files."]
            XCTAssertEqual(standardOutputs, expect)
        }
    }
}
