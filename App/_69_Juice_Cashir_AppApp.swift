//
//  _69_Juice_Cashir_AppApp.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-09.
//

import SwiftUI

@main
struct _69_Juice_Cashir_AppApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    HomeView()
                }
                .tabItem {
                    Image (systemName: "square.and.pencil")
                    Text ("Order")
                }
                StatsView ()
                    .tabItem {
                        Image (systemName: "chart.bar.fill")
                        Text ("Stats")
                    }
            }
            
        }
    }
}
