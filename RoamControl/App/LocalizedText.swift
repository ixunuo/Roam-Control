import Foundation

/// Localizes strings that are built at runtime, which SwiftUI cannot resolve automatically.
enum LocalizedText {
    static func text(_ source: String) -> String {
        NSLocalizedString(source, tableName: nil, bundle: .main, value: source, comment: "")
    }

    static func format(_ source: String, _ arguments: CVarArg...) -> String {
        format(source, arguments: arguments)
    }

    static func format(_ source: String, arguments: [CVarArg]) -> String {
        String(
            format: NSLocalizedString(
                source,
                tableName: nil,
                bundle: .main,
                value: source,
                comment: ""
            ),
            locale: .current,
            arguments: arguments
        )
    }
}
