import SwiftUI

struct GlassmorphismModifier: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}

extension View {
    func glassmorphism(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassmorphismModifier(cornerRadius: cornerRadius))
    }
}
