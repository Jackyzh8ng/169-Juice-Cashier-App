//
//  AddOnsView.swift
//  169 Juice Cashir App
//

import SwiftUI

struct AddOnsView: View {
    // MARK: - Flow inputs (unchanged)
    let flavours: [Flavour]
    let presetCup: CupType
    let flavoursLocked: Bool

    // MARK: - Data
    let addOns: [AddOn] = AddOn.allCases
    @Binding var selected: Set<AddOn>

    /// Parent decides navigation (modern NavigationStack pattern)
    var onNext: (_ addOns: [AddOn]) -> Void = { _ in }

    // MARK: - Layout
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(addOns, id: \.self) { addOn in
                    addOnButton(for: addOn)
                }
            }
            .padding()
            .padding(.bottom, 80) // space for Next bar

            nextBar
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding([.horizontal, .bottom])
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.85), value: selected)
        .navigationTitle("Select Add-Ons")
    }

    // MARK: - Components
    @ViewBuilder
    private func addOnButton(for addOn: AddOn) -> some View {
        let isSelected = selected.contains(addOn)

        Button {
            selected.formSymmetricDifference([addOn]) // toggle
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                    .frame(height: 120)

                HStack(spacing: 10) {
                    Text(addOn.rawValue.capitalized)
                        .font(.title3).fontWeight(.semibold)
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
        .accessibilityLabel(Text(addOn.rawValue.capitalized))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var nextBar: some View {
        Button {
            let picked = selected.sorted { $0.rawValue < $1.rawValue }
            onNext(picked) // let parent push BuildDrinkView
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
