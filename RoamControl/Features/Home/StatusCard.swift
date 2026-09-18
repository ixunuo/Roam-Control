import SwiftUI

struct StatusCard: View {
    let state: ConnectionState

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(tint)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private var title: String {
        switch state {
        case .notConfigured: LocalizedText.text("Not configured")
        case .ready: LocalizedText.text("Ready")
        case .connecting: LocalizedText.text("Connecting")
        case .active: LocalizedText.text("Location session active")
        case .failed: LocalizedText.text("Connection error")
        }
    }

    private var detail: String {
        switch state {
        case .notConfigured: LocalizedText.text("Pairing support has not been added yet.")
        case .ready: LocalizedText.text("The paired device is available.")
        case .connecting: LocalizedText.text("Roam Control is preparing the secure device session.")
        case .active: LocalizedText.text("Roam Control is controlling the session.")
        case .failed(let message): LocalizedText.text(message)
        }
    }

    private var iconName: String {
        switch state {
        case .notConfigured: "circle.dashed"
        case .ready: "checkmark.circle.fill"
        case .connecting: "arrow.triangle.2.circlepath"
        case .active: "location.fill"
        case .failed: "exclamationmark.triangle.fill"
        }
    }

    private var tint: Color {
        switch state {
        case .notConfigured: .secondary
        case .ready: .green
        case .connecting: .blue
        case .active: .blue
        case .failed: .red
        }
    }
}
