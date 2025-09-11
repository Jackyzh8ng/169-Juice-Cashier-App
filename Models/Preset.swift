//
//  PresetItems.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-11.
//

import Foundation

struct Preset: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var cup: CupType
    var flavours: [Flavour]
    var addOns: [AddOn]

    init(id: UUID = .init(), name: String, cup: CupType, flavours: [Flavour], addOns: [AddOn]) {
        self.id = id
        self.name = name
        self.cup = cup
        self.flavours = flavours
        self.addOns = addOns
    }
}
