//
//  CheckOutView.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-10.
//

import SwiftUI

// MARK: - Currency helper
private extension Numeric {
    var money: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        f.locale = .current
        return f.string(for: self) ?? "$0.00"
    }
}

// MARK: - AddOn pretty print
private extension Array where Element == AddOn {
    var pretty: String {
        guard !isEmpty else { return "No add-ons" }
        return map { $0.rawValue.capitalized }.joined(separator: ", ")
    }
}

// MARK: - Checkout View
struct CheckOutView: View {
    @EnvironmentObject var cart: CartStore
    @Environment(\.dismiss) private var dismiss

    /// Provide this from the parent to navigate back to your Home flow.
    var onAddMoreDrinks: (() -> Void)?

    // Card fee: $1.00 per drink EXCEPT Watermelon shell (wshell)
    private var nonWatermelonQuantity: Int {
        cart.items.reduce(0) { partial, item in
            partial + (item.drink.cupType == .wshell ? 0 : item.quantity)
        }
    }
    private let cardFeePerItem: Double = 1.00
    private var cardSurcharge: Double { Double(nonWatermelonQuantity) * cardFeePerItem }
    private var cardTotal: Double { cart.total + cardSurcharge }

    var body: some View {
        VStack(spacing: 0) {
            if cart.items.isEmpty {
                emptyState
            } else {
                List {
                    Section("Your Order") {
                        ForEach(cart.items) { item in
                            ItemRow(
                                item: item,
                                onSetQuantity: { qty in cart.setQuantity(qty, for: item.id) },
                                onDelete: { cart.remove(id: item.id) }
                            )
                        }
                        .onDelete(perform: cart.remove) // swipe-to-delete still works
                    }
                }
                .listStyle(.insetGrouped)

                totalsBar
            }
        }
        .navigationTitle("Checkout")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    onAddMoreDrinks?()
                } label: {
                    Label("Add Drink", systemImage: "plus.circle")
                }
                .accessibilityIdentifier("checkout_add_more")
            }

            if !cart.items.isEmpty {
                ToolbarItem(placement: .bottomBar) {
                    HStack(spacing: 12) {
                        // Cash
                        Button {
                            let order = cart.makeOrderSnapshot()
                            print("Order placed (CASH):", order, "Total:", cart.total)
                            cart.clear()
                            onAddMoreDrinks?()
                        } label: {
                            Text("Cash • \(cart.total.money)")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("checkout_cash")

                        // Card (+$1 per non-watermelon drink)
                        Button {
                            let order = cart.makeOrderSnapshot()
                            print("Order placed (CARD):", order, "Total:", cardTotal, "Surcharge:", cardSurcharge)
                            cart.clear()
                            onAddMoreDrinks?()
                        } label: {
                            Text("Card • \(cardTotal.money)")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("checkout_card")
                    }
                }
            }
        }
    }

    // MARK: - Views

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 44, weight: .semibold))
                .padding(.top, 24)
            Text("Your cart is empty")
                .font(.title3).bold()
            Text("Start by choosing a cup, then a flavour like Pineapple or Watermelon.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button {
                onAddMoreDrinks?()
            } label: {
                Label("Add a Drink", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)

            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var totalsBar: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Total (Cash)")
                Spacer()
                Text(cart.total.money)
                    .font(.headline)
                    .monospacedDigit()
            }
            HStack {
                Text("Total (Card, +$1 each non-Watermelon)")
                Spacer()
                Text(cardTotal.money)
                    .font(.headline)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Item Row

private struct ItemRow: View {
    let item: OrderItem
    var onSetQuantity: (Int) -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title row: flavours + unit price + delete button
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(item.drink.flavourList)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                Text(item.unitPrice.money)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .imageScale(.medium)
                        .font(.body)
                        .padding(.leading, 4)
                        .accessibilityLabel("Delete item")
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("checkout_delete_\(item.id)")
            }

            // Subtitle: cup + add-ons
            Text("\(item.drink.cupType.rawValue.capitalized) • \(item.drink.addOns.pretty)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            // Quantity + line total
            HStack {
                Stepper(value: Binding(
                    get: { item.quantity },
                    set: { onSetQuantity(max(1, $0)) }
                ), in: 1...99) {
                    Text("Qty: \(item.quantity)")
                        .font(.subheadline)
                }
                .accessibilityIdentifier("checkout_stepper_\(item.id)")

                Spacer()

                Text(item.lineTotal.money)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 6)
    }
}
