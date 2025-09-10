//
//  PaymentMethod.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-10.
//

// Models/PaymentMethod.swift
import Foundation

public enum PaymentMethod: String, Codable, CaseIterable, Hashable {
    case cash, card
}

