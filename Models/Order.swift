//
//  Order.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-09.
//

import Foundation

struct Order: Identifiable, Codable, Hashable {
    var id: UUID = UUID()                 // unique ID
    var selection: [Flavour]       // single or 50/50 mix
    var cupType: CupType                  // cup / pshell / wshell
    var addOns: [AddOn] = []
    var quantity: Int = 1
    var price: Double
    var timestamp: Date = Date()
    var flavourList: String {
        selection.map { $0.rawValue.capitalized }.joined(separator: " + ")
    }
}

enum Flavour: String, Codable, CaseIterable, Hashable {
    case mango, pineapple, watermelon, strawberry, banana, coconut, taro
}

enum CupType: String, Codable, CaseIterable, Hashable {
    case cup, pshell, wshell
}

enum AddOn: String, Codable, CaseIterable, Hashable {
    case boba, extraSugar, noIce, proteinBoost
}
