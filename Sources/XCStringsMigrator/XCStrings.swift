import Foundation

struct XCStrings: Codable {
    var sourceLanguage: String
    var strings: [String: Strings]
    var version: String
}

struct Strings: Codable {
    var localizations: [String: Localization]
}

struct Localization: Codable {
    var stringUnit: StringUnit
}

struct StringUnit: Codable {
    var state: String
    var value: String

    init(state: String = "translated", value: String) {
        self.state = state
        self.value = value
    }
}
