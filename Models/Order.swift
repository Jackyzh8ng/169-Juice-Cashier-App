//
//  Order.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-09.
//

import Foundation

struct Order: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var drinks: [Drink]
    var timestamp: Date = Date()
}
struct Drink: Codable, Hashable {
    var selection: [Flavour]       // single or 50/50 mix
    var cupType: CupType                  // cup / pshell / wshell
    var addOns: [AddOn]
    var price: Double
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

// Models/AddOn.swift

public enum AddOn: String, Codable, CaseIterable, Hashable {
    case boba
    case lessSugar
    case noSugar
    case lessIce
    case noIce
}

