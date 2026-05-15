import SwiftUI

struct FilterBarView: View {
    @Binding var criteria: FilterCriteria

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // Sort order chips
                ForEach(SortOrder.allCases) { order in
                    filterChip(
                        label: order.rawValue,
                        isSelected: criteria.sortOrder == order
                    ) {
                        criteria.sortOrder = order
                    }
                }

                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 4)

                // Media type chips
                ForEach(MediaType.allCases) { type in
                    filterChip(
                        label: type.rawValue,
                        isSelected: criteria.mediaType == type
                    ) {
                        criteria.mediaType = type
                    }
                }

                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 4)

                // Provider chips
                ForEach(StreamingProvider.allCases.filter { $0 != .unknown }) { provider in
                    filterChip(
                        label: provider.displayName,
                        icon: provider.systemImageName,
                        isSelected: criteria.providers.contains(provider)
                    ) {
                        if criteria.providers.contains(provider) {
                            criteria.providers.remove(provider)
                        } else {
                            criteria.providers.insert(provider)
                        }
                    }
                }
            }
            .padding(.horizontal, 60)
            .padding(.vertical, 12)
        }
        .focusSection()
    }

    private func filterChip(
        label: String,
        icon: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.callout)
                }
                Text(label)
                    .font(.callout)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 20)
            .frame(minWidth: 120, minHeight: 60)
            .background(isSelected ? Color.white.opacity(0.2) : Color.clear)
            .glassmorphism(cornerRadius: 30)
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(isSelected ? Color.white.opacity(0.6) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.card)
    }
}
