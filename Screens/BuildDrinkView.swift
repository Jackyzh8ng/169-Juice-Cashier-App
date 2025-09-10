import SwiftUI

struct BuildDrinkView: View {
    @EnvironmentObject var cart: CartStore
    @Environment(\.goToCheckout) private var goToCheckout
    @Environment(\.resetOrderFlow) private var resetOrderFlow   // <<< new

    let flavours: [Flavour]
    let addOns: [AddOn]
    let presetCup: CupType
    let flavoursLocked: Bool

    @State private var cup: CupType = .cup
    @State private var quantity: Int = 1

    init(flavours: [Flavour], addOns: [AddOn], presetCup: CupType, flavoursLocked: Bool) {
        self.flavours = flavours
        self.addOns = addOns
        self.presetCup = presetCup
        self.flavoursLocked = flavoursLocked
        _cup = State(initialValue: presetCup)
    }

    private var basePrice: Double {
        switch cup { case .cup: 10.00; case .pshell: 12.00; case .wshell: 15.00 }
    }
    private var addOnPrice: Double { addOns.contains(.boba) ? 0.0 : 0.0 } // adjust if needed
    private var unitPrice: Double { basePrice + addOnPrice }

    var body: some View {
        Form {
            Section(header: Text("Shell Type")) {
                Picker("Shell", selection: $cup) {
                    ForEach(CupType.allCases, id: \.self) { c in
                        Text(label(for: c)).tag(c)
                    }
                }
                .pickerStyle(.segmented)
                Text("Unit Price: \(unitPrice.asMoney)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section(header: Text("Flavour(s)")) {
                Text(flavours.map { $0.rawValue.capitalized }.joined(separator: " + "))
                    .foregroundStyle(flavoursLocked ? .secondary : .primary)
            }

            Section(header: Text("Add-ons")) {
                if addOns.isEmpty {
                    Text("No add-ons").foregroundStyle(.secondary)
                } else {
                    Text(addOns.map { $0.rawValue.capitalized }.joined(separator: ", "))
                }
            }

            Section(header: Text("Quantity")) {
                Stepper(value: $quantity, in: 1...99) {
                    Text("Qty: \(quantity)")
                }
            }

            Section {
                Button {
                    let drink = Drink(
                        selection: flavours,
                        cupType: cup,
                        addOns: addOns,
                        price: unitPrice
                    )
                    cart.add(drink: drink, quantity: quantity)
                    // Clear Order navigation so returning to Order shows the start,
                    // then switch to Checkout.
                    resetOrderFlow()
                    goToCheckout()
                } label: {
                    HStack {
                        Spacer()
                        Text("Add to Cart • \((unitPrice * Double(quantity)).asMoney)")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Build Drink")
    }

    private func label(for cup: CupType) -> String {
        switch cup {
        case .cup: "Cup"
        case .pshell: "Pineapple"
        case .wshell: "Watermelon"
        }
    }
}

private extension Numeric {
    var asMoney: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        f.locale = .current
        return f.string(for: self) ?? "$0.00"
    }
}
