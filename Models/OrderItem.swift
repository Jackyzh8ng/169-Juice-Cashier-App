//
//  OrderItem.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-10.
//

import Foundation

/// A line item in the cart that references your existing `Drink` model.
public struct OrderItem: Identifiable, Codable, Hashable {
     public let id: UUID
     var drink: Drink
     var quantity: Int

     init(id: UUID = .init(), drink: Drink, quantity: Int = 1) {
        self.id = id
        self.drink = drink
        self.quantity = max(1, quantity)
    }

    /// Per-unit price uses your Drink.price
     var unitPrice: Double { drink.price }

    /// Line total = unitPrice * quantity
     var lineTotal: Double { Double(quantity) * drink.price }
}
