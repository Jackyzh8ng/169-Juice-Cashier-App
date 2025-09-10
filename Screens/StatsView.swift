//
//  StatsView.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-10.
//

import SwiftUI
import Charts

// MARK: - Shared types

enum StatsRange: String, CaseIterable, Hashable {
    case daily = "Daily", weekly = "Weekly", monthly = "Monthly", yearly = "Yearly"
}

private extension Numeric {
    var money: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        f.locale = .current
        return f.string(for: self) ?? "$0.00"
    }
}

private let isoCal = Calendar(identifier: .iso8601)

private func startOfDay(_ d: Date) -> Date { isoCal.startOfDay(for: d) }
private func endOfDay(_ d: Date) -> Date {
    isoCal.date(byAdding: .day, value: 1, to: startOfDay(d))!.addingTimeInterval(-1)
}
private func startOfWeek(_ d: Date) -> Date {
    isoCal.date(from: isoCal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: d)) ?? d
}
private func endOfWeek(_ d: Date) -> Date {
    isoCal.date(byAdding: DateComponents(day: 7, second: -1), to: startOfWeek(d)) ?? d
}
private func startOfMonth(_ d: Date) -> Date {
    isoCal.date(from: isoCal.dateComponents([.year, .month], from: d)) ?? d
}
private func endOfMonth(_ d: Date) -> Date {
    isoCal.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth(d)) ?? d
}
private func startOfYear(_ d: Date) -> Date {
    isoCal.date(from: isoCal.dateComponents([.year], from: d)) ?? d
}
private func endOfYear(_ d: Date) -> Date {
    isoCal.date(byAdding: DateComponents(year: 1, second: -1), to: startOfYear(d)) ?? d
}

// MARK: - Root StatsView with tabs

struct StatsView: View {
    @State private var tab: Tab = .recent
    enum Tab: String, CaseIterable { case recent = "Recent", revenue = "Revenue", drinks = "Drink Data" }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Tab", selection: $tab) {
                ForEach(Tab.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding()

            switch tab {
            case .recent: RecentTransactionsTab()
            case .revenue: RevenueTab()
            case .drinks: DrinkDataTab()
            }
        }
        .navigationTitle("Stats")
    }
}

// MARK: - 1) Recent transactions

private struct RecentTransactionsTab: View {
    @StateObject private var store = SalesStore.shared
    @State private var filterWeek: FestivalWeek? = nil
    @State private var span: ClosedRange<Date> = {
        let end = Date()
        let start = isoCal.date(byAdding: .month, value: -1, to: end)!
        return start...end
    }()

    var filtered: [Sale] {
        store.sales
            .filter { span.contains($0.timestamp) }
            .filter { filterWeek == nil ? true : $0.festivalWeekId == filterWeek!.id }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        VStack(spacing: 12) {
            headerFilters(weeks: store.weeks, filterWeek: $filterWeek, span: $span)

            if filtered.isEmpty {
                ContentUnavailableView("No transactions", systemImage: "list.bullet.rectangle.portrait", description: Text("Try expanding the date range or selecting a different location."))
                    .padding()
            } else {
                List(filtered, id: \.id) { sale in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sale.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.headline)
                            Text("\(store.week(for: sale.festivalWeekId)?.locationName ?? "No location") • \(sale.payment.rawValue.capitalized)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            if sale.surcharge > 0 {
                                Text("Surcharge: \(sale.surcharge.money)").font(.caption2).foregroundStyle(.secondary)
                            }
                            Text(sale.total.money).font(.headline).monospacedDigit()
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
    }
}

// MARK: - 2) Revenue tab with chart

private struct RevenuePoint: Identifiable, Hashable {
    let id = UUID()
    let bucketStart: Date
    let label: String
    let total: Double
}

private struct RevenueTab: View {
    @StateObject private var store = SalesStore.shared
    @State private var filterWeek: FestivalWeek? = nil
    @State private var span: ClosedRange<Date> = {
        let end = Date()
        let start = isoCal.date(byAdding: .month, value: -2, to: end)!
        return start...end
    }()
    @State private var range: StatsRange = .weekly

    @State private var series: [RevenuePoint] = []
    @State private var grandTotal: Double = 0

    var body: some View {
        VStack(spacing: 12) {
            headerFilters(weeks: store.weeks, filterWeek: $filterWeek, span: $span)

            Picker("Range", selection: $range) {
                ForEach(StatsRange.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if series.isEmpty {
                ContentUnavailableView("No revenue data", systemImage: "chart.bar.doc.horizontal", description: Text("Adjust date range or location."))
                    .padding()
            } else {
                Chart(series) { point in
                    BarMark(
                        x: .value("Bucket", point.label),
                        y: .value("Revenue", point.total)
                    )
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 260)
                .padding(.horizontal)

                List {
                    Section("Totals") {
                        HStack {
                            Text("Grand Total")
                            Spacer()
                            Text(grandTotal.money).bold()
                        }
                    }
                    Section("Buckets") {
                        ForEach(series) { p in
                            HStack {
                                Text(p.label)
                                Spacer()
                                Text(p.total.money).monospacedDigit()
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .task(id: range) { await recompute() }
        .task(id: span) { await recompute() }
        .task(id: filterWeek?.id) { await recompute() }
        .onAppear { Task { await recompute() } }
    }

    private func recompute() async {
        let sales = store.sales
            .filter { span.contains($0.timestamp) }
            .filter { filterWeek == nil ? true : $0.festivalWeekId == filterWeek!.id }

        var buckets: [String: (Date, Double)] = [:]

        for s in sales {
            let (start, end, label): (Date, Date, String)
            switch range {
            case .daily:
                start = startOfDay(s.timestamp); end = endOfDay(s.timestamp)
                label = start.formatted(date: .abbreviated, time: .omitted)
            case .weekly:
                start = startOfWeek(s.timestamp); end = endOfWeek(s.timestamp)
                let w = isoCal.component(.weekOfYear, from: start)
                let y = isoCal.component(.yearForWeekOfYear, from: start)
                let loc = store.week(for: s.festivalWeekId)?.locationName
                label = loc == nil ? "\(y)-W\(w)" : "\(y)-W\(w) – \(loc!)"
            case .monthly:
                start = startOfMonth(s.timestamp); end = endOfMonth(s.timestamp)
                label = start.formatted(.dateTime.year().month(.abbreviated))
            case .yearly:
                start = startOfYear(s.timestamp); end = endOfYear(s.timestamp)
                label = start.formatted(.dateTime.year())
            }

            let key = "\(label)|\(start.timeIntervalSince1970)"
            let v = buckets[key] ?? (start, 0)
            buckets[key] = (v.0, v.1 + s.total)
        }

        let points = buckets
            .map { (k, v) in RevenuePoint(bucketStart: v.0, label: k.components(separatedBy: "|").first ?? "", total: v.1) }
            .sorted { $0.bucketStart < $1.bucketStart }

        series = points
        grandTotal = points.reduce(0) { $0 + $1.total }
    }
}

// MARK: - 3) Drink Data tab with fractional counts

private struct FlavourCount: Identifiable, Hashable {
    let id = UUID()
    let flavour: Flavour
    let cups: Double   // can be fractional (0.5, 0.33, etc.)
}

private struct DrinkDataTab: View {
    @StateObject private var store = SalesStore.shared
    @State private var filterWeek: FestivalWeek? = nil
    @State private var span: ClosedRange<Date> = {
        let end = Date()
        let start = isoCal.date(byAdding: .month, value: -1, to: end)!
        return start...end
    }()
    @State private var range: StatsRange = .weekly

    @State private var totals: [FlavourCount] = []
    @State private var grandCups: Double = 0

    var body: some View {
        VStack(spacing: 12) {
            headerFilters(weeks: store.weeks, filterWeek: $filterWeek, span: $span)

            Picker("Granularity", selection: $range) {
                ForEach(StatsRange.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if totals.isEmpty {
                ContentUnavailableView("No drink data", systemImage: "cup.and.saucer", description: Text("Change date range or location."))
                    .padding()
            } else {
                // Horizontal bar chart of totals per flavour over the whole span (per selected granularity)
                Chart(totals.sorted { $0.cups > $1.cups }) { row in
                    BarMark(
                        x: .value("Cups", row.cups),
                        y: .value("Flavour", row.flavour.rawValue.capitalized)
                    )
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .frame(height: 260)
                .padding(.horizontal)

                List {
                    Section("Totals (sum over selected period)") {
                        HStack {
                            Text("All Flavours")
                            Spacer()
                            Text(String(format: "%.2f cups", grandCups))
                                .bold()
                        }
                    }
                    Section("By Flavour") {
                        ForEach(totals.sorted { $0.cups > $1.cups }) { row in
                            HStack {
                                Text(row.flavour.rawValue.capitalized)
                                Spacer()
                                Text(String(format: "%.2f cups", row.cups))
                                    .monospacedDigit()
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .task(id: range) { await recompute() }
        .task(id: span) { await recompute() }
        .task(id: filterWeek?.id) { await recompute() }
        .onAppear { Task { await recompute() } }
    }

    private func recompute() async {
        // 1) Filter sales by span + week
        let sales = store.sales
            .filter { span.contains($0.timestamp) }
            .filter { filterWeek == nil ? true : $0.festivalWeekId == filterWeek!.id }

        // 2) Optional: If you wanted to break by day/week/month/year buckets,
        //    you could compute a time series. For now, we sum over the selected span,
        //    respecting the chosen granularity only as a "reporting lens".
        //    (If you want per-bucket series, say the word and I’ll add it.)

        // 3) Fractional flavour counting: each drink contributes 1 / selection.count to each flavour
        var map: [Flavour: Double] = [:]
        for sale in sales {
            for drink in sale.order.drinks {
                let n = max(1, drink.selection.count)
                let per = 1.0 / Double(n)
                for flav in drink.selection {
                    map[flav, default: 0] += per
                }
            }
        }

        let rows = Flavour.allCases.map { flav in
            FlavourCount(flavour: flav, cups: map[flav, default: 0])
        }

        totals = rows
        grandCups = rows.reduce(0) { $0 + $1.cups }
    }
}

// MARK: - Shared header controls (location picker + date range)

@ViewBuilder
private func headerFilters(
    weeks: [FestivalWeek],
    filterWeek: Binding<FestivalWeek?>,
    span: Binding<ClosedRange<Date>>
) -> some View {
    HStack(spacing: 12) {
        Menu {
            Button("All locations") { filterWeek.wrappedValue = nil }
            if weeks.isEmpty == false {
                Section("Festival weeks") {
                    ForEach(weeks) { fw in
                        Button("\(fw.locationName) — \(fw.weekStart.formatted(date: .abbreviated, time: .omitted))") {
                            filterWeek.wrappedValue = fw
                        }
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text(filterWeek.wrappedValue?.locationName ?? "All locations")
            }
            .padding(8)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
        }

        Spacer()

        DatePicker(
            "From",
            selection: Binding(
                get: { span.wrappedValue.lowerBound },
                set: { span.wrappedValue = $0...span.wrappedValue.upperBound }
            ),
            displayedComponents: .date
        )
        .labelsHidden()

        DatePicker(
            "To",
            selection: Binding(
                get: { span.wrappedValue.upperBound },
                set: { span.wrappedValue = span.wrappedValue.lowerBound...$0 }
            ),
            displayedComponents: .date
        )
        .labelsHidden()
    }
    .padding(.horizontal)
}
