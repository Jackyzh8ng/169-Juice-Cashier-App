//
//  CartStore.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-10.
//

import Foundation
import Combine

public final class CartStore: ObservableObject {
    @Published public private(set) var items: [OrderItem] = []

//    public var taxRate: Double = 0.13

    public init(items: [OrderItem] = []) {
        self.items = items
    }

    // MARK: - Mutations
     func add(drink: Drink, quantity: Int = 1) {
        // Optional merge logic: same drink, same add-ons, same cup → combine
        if let idx = items.firstIndex(where: { $0.drink == drink }) {
            items[idx].quantity = max(1, items[idx].quantity + quantity)
        } else {
            items.append(OrderItem(drink: drink, quantity: max(1, quantity)))
        }
    }

    public func add(_ item: OrderItem) {
        add(drink: item.drink, quantity: item.quantity)
    }

    public func remove(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    public func remove(id: OrderItem.ID) {
        items.removeAll { $0.id == id }
    }

    public func setQuantity(_ qty: Int, for id: OrderItem.ID) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].quantity = max(1, qty)
    }

    public func increment(_ id: OrderItem.ID) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].quantity += 1
    }

    public func decrement(_ id: OrderItem.ID) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].quantity = max(1, items[i].quantity - 1)
    }

    public func clear() { items.removeAll() }

    // MARK: - Totals
    public var total: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }
//    public var tax: Double { subtotal * taxRate }
//    public var total: Double { subtotal + tax }

    // MARK: - Checkout snapshot
    /// Convert the current cart to your existing `Order` model.
    /// By default this flattens quantities into repeated drinks in the Order.drinks array
    /// so it fits your `Order` shape exactly.
     func makeOrderSnapshot(timestamp: Date = .init()) -> Order {
        let flattened: [Drink] = items.flatMap { item in
            Array(repeating: item.drink, count: item.quantity)
        }
        return Order(drinks: flattened, timestamp: timestamp)
    }
}
