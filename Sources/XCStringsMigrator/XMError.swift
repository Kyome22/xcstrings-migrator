import Foundation

public enum XMError: LocalizedError {
    case none

    public var errorDescription: String? {
        switch self {
        case .none: "none"
        }
    }

    public var exitCode: Int32 {
        switch self {
        case .none: 1
        }
    }
}
