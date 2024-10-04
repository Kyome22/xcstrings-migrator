import Foundation

public enum XMError: LocalizedError {
    case failedToExport

    public var errorDescription: String? {
        switch self {
        case .failedToExport: "Failed to export xcstrings files."
        }
    }

    public var exitCode: Int32 {
        switch self {
        case .failedToExport: 1
        }
    }
}
