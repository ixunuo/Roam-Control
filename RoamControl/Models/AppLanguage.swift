import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case simplifiedChinese = "zh-Hans"

    static let defaultsKey = "appLanguage"
    static let appleLanguagesKey = "AppleLanguages"

    var id: Self { self }

    var title: String {
        switch self {
        case .system: LocalizedText.text("Follow System")
        case .english: "English"
        case .simplifiedChinese: "简体中文"
        }
    }

    /// The `AppleLanguages` override this choice applies, or `nil` to follow the system.
    var overriddenLanguageCode: String? {
        switch self {
        case .system: nil
        case .english, .simplifiedChinese: rawValue
        }
    }

    /// Takes effect the next time the app launches.
    func apply(to preferences: UserDefaults) {
        if let code = overriddenLanguageCode {
            preferences.set([code], forKey: Self.appleLanguagesKey)
        } else {
            preferences.removeObject(forKey: Self.appleLanguagesKey)
        }
    }

    /// The language the app would use if launched with this preference.
    func resolvedLanguageCode(preferredLanguageIdentifiers: [String] = Locale.preferredLanguages) -> String {
        if let code = overriddenLanguageCode {
            return code
        }

        let identifier = preferredLanguageIdentifiers.first ?? "en"
        return identifier.hasPrefix("zh-Hans") ? "zh-Hans" : "en"
    }

    static func effectiveLanguageCode(
        in preferences: UserDefaults,
        preferredLanguageIdentifiers: [String] = Locale.preferredLanguages
    ) -> String {
        let stored = AppLanguage(rawValue: preferences.string(forKey: defaultsKey) ?? "") ?? .system
        return stored.resolvedLanguageCode(
            preferredLanguageIdentifiers: preferredLanguageIdentifiers
        )
    }
}
