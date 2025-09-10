//
//  FestivalWeek.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-10.
//

// Models/FestivalWeek.swift
import Foundation

public struct FestivalWeek: Identifiable, Codable, Hashable {
    public let id: UUID
    public var locationName: String
    public var weekStart: Date   // start of ISO week (Mon)
    public var weekEnd: Date     // end of week (Sun 23:59:59)

    public init(id: UUID = .init(), locationName: String, weekStart: Date) {
        let cal = Calendar(identifier: .iso8601)
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStart)) ?? weekStart
        let end = cal.date(byAdding: DateComponents(day: 7, second: -1), to: start) ?? start
        self.id = id
        self.locationName = locationName
        self.weekStart = start
        self.weekEnd = end
    }
}
