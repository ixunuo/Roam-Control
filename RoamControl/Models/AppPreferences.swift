import Foundation

enum AppAppearance: String, CaseIterable, Identifiable {
    case automatic
    case light
    case dark

    var id: Self { self }

    var title: String {
        switch self {
        case .automatic: LocalizedText.text("Auto")
        case .light: LocalizedText.text("Light")
        case .dark: LocalizedText.text("Dark")
        }
    }

    var systemImage: String {
        switch self {
        case .automatic: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }
}

enum MapDisplayStyle: String, CaseIterable, Identifiable {
    case standard
    case satellite
    case hybrid

    var id: Self { self }

    var title: String {
        switch self {
        case .standard: LocalizedText.text("Standard")
        case .satellite: LocalizedText.text("Satellite")
        case .hybrid: LocalizedText.text("Hybrid")
        }
    }
}
