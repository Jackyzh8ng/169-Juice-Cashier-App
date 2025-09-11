//
//  PresetStore.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-11.
//

import Foundation
import Combine

final class PresetStore: ObservableObject {
    @Published var presets: [Preset] = []

    private let key = "presets.v1"

    init() { load() }

    func add(_ p: Preset) {
        presets.append(p)
        save()
    }
    func remove(at offsets: IndexSet) {
        presets.remove(atOffsets: offsets)
        save()
    }
    func replaceAll(_ arr: [Preset]) {
        presets = arr
        save()
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let arr = try? JSONDecoder().decode([Preset].self, from: data) {
            presets = arr
        } else {
            // Default examples — edit to your taste
            presets = [
                Preset(name: "Mango + Pineapple • Boba", cup: .cup,
                       flavours: [.mango, .pineapple], addOns: [.boba]),
                Preset(name: "Watermelon Shell", cup: .wshell,
                       flavours: [.watermelon], addOns: []),
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
