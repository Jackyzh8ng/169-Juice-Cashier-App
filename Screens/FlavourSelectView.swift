//
//  FlavourSelect.swift
//  169 Juice Cashir App
//

import SwiftUI

struct FlavourSelectView: View {
    // MARK: - Data
    let flavours: [Flavour] = Flavour.allCases
    @Binding var selected: Set<Flavour>

    /// Emits the chosen flavours as `[Flavour]` (sorted) so the parent can build a `Drink`.
    var onNext: (_ flavours: [Flavour]) -> Void = { _ in }

    // MARK: - Layout
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            // Grid of flavour buttons
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(flavours, id: \.self) { flavour in
                    flavourButton(for: flavour)
                }
            }
            .padding()
            .padding(.bottom, 80) // space for the Next bar when visible

            // Next bar (only when selection is not empty)
            if !selected.isEmpty {
                nextBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding([.horizontal, .bottom])
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.85), value: selected)
    }

    // MARK: - Components
    @ViewBuilder
    private func flavourButton(for flavour: Flavour) -> some View {
        let isSelected = selected.contains(flavour)

        Button {
            selected.formSymmetricDifference([flavour]) // toggle membership
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                    .frame(height: 120)

                HStack(spacing: 10) {
                    Text(flavour.rawValue.capitalized)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .primary)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .transition(.scale)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(flavour.rawValue.capitalized))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var nextBar: some View {
        Button {
            // Convert Set -> sorted Array for stable ordering
            let picked = selected.sorted { $0.rawValue < $1.rawValue }
            onNext(picked)
        } label: {
            HStack(spacing: 12) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("(\(selected.count))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Color.blue)
            .cornerRadius(16)
            .shadow(radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Next, \(selected.count) selected"))
    }
}
