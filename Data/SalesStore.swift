//
//  SalesStore.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-10.
//

// Data/SalesStore.swift
import Foundation
import Combine

final class SalesStore: ObservableObject {
    @Published private(set) var weeks: [FestivalWeek] = []
    @Published private(set) var sales: [Sale] = []

    static let shared = SalesStore() // simple singleton
    private init() { loadAll() }

    // MARK: - Public API

    func createWeek(locationName: String, at date: Date = Date()) -> FestivalWeek {
        let week = FestivalWeek(locationName: locationName, weekStart: date)
        weeks.insert(week, at: 0)
        saveWeeks()
        return week
    }

    func record(order: Order, payment: PaymentMethod, festivalWeek: FestivalWeek?) {
        let sale = Sale(order: order, payment: payment, festivalWeekId: festivalWeek?.id)
        sales.insert(sale, at: 0)
        saveSales()
    }

    func week(for id: UUID?) -> FestivalWeek? {
        guard let id else { return nil }
        return weeks.first { $0.id == id }
    }

    // MARK: - Disk I/O

    private let fm = FileManager.default
    private var baseURL: URL {
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("com.169juice.cashir", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    private var weeksURL: URL { baseURL.appendingPathComponent("festival_weeks.json") }
    private var salesURL: URL { baseURL.appendingPathComponent("sales.json") }

    private func loadAll() {
        weeks = (try? Data(contentsOf: weeksURL))
            .flatMap { try? JSONDecoder().decode([FestivalWeek].self, from: $0) } ?? []
        sales = (try? Data(contentsOf: salesURL))
            .flatMap { try? JSONDecoder().decode([Sale].self, from: $0) } ?? []
    }

    private func saveWeeks() {
        if let data = try? JSONEncoder().encode(weeks) {
            try? data.write(to: weeksURL, options: .atomic)
        }
    }

    private func saveSales() {
        if let data = try? JSONEncoder().encode(sales) {
            try? data.write(to: salesURL, options: .atomic)
        }
    }
}
