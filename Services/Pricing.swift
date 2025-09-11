//
//  Pricing.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-11.
//

import Foundation

enum Pricing {
    static let baseByCup: [CupType: Double] = [
        .cup:    10.00,
        .pshell: 12.00,
        .wshell: 15.00
    ]

    static func addOnPrice(_ addOn: AddOn) -> Double {
        switch addOn {
        case .boba:      return 0.00
        case .lessSugar, .noSugar, .lessIce, .noIce:
            return 0.00
        }
    }

    static func price(cup: CupType, addOns: [AddOn], flavours: [Flavour]) -> Double {
        let base = baseByCup[cup] ?? 0
        let extras = addOns.reduce(0) { $0 + addOnPrice($1) }
        return base + extras
    }
}
