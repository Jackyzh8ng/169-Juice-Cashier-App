//
//  FlavourSelect.swift
//  169 Juice Cashir App
//

import SwiftUI

struct FlavourSelect: View {
    let flavours: [Flavour] = Flavour.allCases
    @Binding var selected: Set<Flavour>   // use a Set to prevent duplicates

    // 3 columns; adjust to 2 if you prefer bigger tiles
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(flavours, id: \.self) { flavour in
                button(for: flavour)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func button(for flavour: Flavour) -> some View {
        let isSelected = selected.contains(flavour)

        Button {
            if isSelected {
                selected.remove(flavour)
            } else {
                selected.insert(flavour)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                    .frame(height: 90)

                HStack(spacing: 8) {
                    Text(flavour.rawValue.capitalized)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.headline)
                            .transition(.scale)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(flavour.rawValue.capitalized))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview / Example usage
struct FlavourSelect_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var selected: Set<Flavour> = []
        var body: some View {
            FlavourSelect(selected: $selected)
        }
    }
    static var previews: some View { Wrapper() }
}
