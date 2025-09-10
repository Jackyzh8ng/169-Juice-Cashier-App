//
//  Sale.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-10.
//

// Models/Sale.swift
import Foundation

/// A persisted transaction that wraps your existing `Order`.
public struct Sale: Identifiable, Codable, Hashable {
    public let id: UUID
    let order: Order           // your existing struct
    public let payment: PaymentMethod
    public let festivalWeekId: UUID?  // link to FestivalWeek (optional)

    // Cached totals (computed at save time)
    public let subtotal: Double
    public let surcharge: Double
    public let total: Double

    init(
        id: UUID = .init(),
        order: Order,
        payment: PaymentMethod,
        festivalWeekId: UUID?
    ) {
        self.id = id
        self.order = order
        self.payment = payment
        self.festivalWeekId = festivalWeekId

        // Subtotal: sum of drink.price for all drinks in order
        let sub = order.drinks.reduce(0.0) { $0 + $1.price }

        // $1 per drink WHEN card, EXCEPT Watermelon Shell (cupType == .wshell)
        let nonExemptCount = order.drinks.filter { $0.cupType != .wshell }.count
        let surcharge = (payment == .card) ? Double(nonExemptCount) * 1.0 : 0.0

        self.subtotal = sub
        self.surcharge = surcharge
        self.total = sub + surcharge
    }

    public var timestamp: Date { order.timestamp }
}
