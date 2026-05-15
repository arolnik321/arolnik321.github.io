import SwiftUI

struct PlatformBadgeView: View {
    let provider: StreamingProvider

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: provider.systemImageName)
                .font(.caption)
            Text(provider.displayName)
                .font(.caption2)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .glassmorphism(cornerRadius: 6)
        .frame(height: 28)
    }
}

struct PlatformBadgeStripView: View {
    let providers: [StreamingProvider]

    var body: some View {
        if !providers.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(providers.prefix(4)) { provider in
                        PlatformBadgeView(provider: provider)
                    }
                }
            }
        }
    }
}
