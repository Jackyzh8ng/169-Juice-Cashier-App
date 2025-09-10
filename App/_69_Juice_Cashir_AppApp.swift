import SwiftUI

@main
struct _69_Juice_Cashir_AppApp: App {
    @StateObject private var cart = CartStore()
    @State private var tab: Tab = .order

    enum Tab { case order, checkout, stats }

    var body: some Scene {
        WindowGroup {
            TabView(selection: $tab) {

                // ORDER TAB (Home) — no extra NavigationStack here
                HomeView()
                    .tabItem {
                        Image(systemName: "square.and.pencil")
                        Text("Order")
                    }
                    .tag(Tab.order)
                    .if(!cart.items.isEmpty) { view in
                        view.badge(cart.items.count)
                    }

                // CHECKOUT TAB
                NavigationStack {
                    CheckOutView(onAddMoreDrinks: {
                        // When user wants to add more, reset Order flow and switch tab
                        resetOrderFlow()    // env closure provided below
                        tab = .order
                    })
                    .navigationTitle("Checkout")
                }
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Checkout")
                }
                .tag(Tab.checkout)
                .badge(cart.items.isEmpty ? nil : String(cart.items.count))

                // STATS TAB
                StatsView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Stats")
                    }
                    .tag(Tab.stats)
            }
            .environmentObject(cart)
            // 🔑 Provide tab switcher to go straight to checkout
            .environment(\.goToCheckout, { tab = .checkout })
            // 🔑 Bridge to call HomeView’s reset closure even from other tabs
            .environment(\.resetOrderFlow, resetOrderFlow)
        }
    }

    // MARK: - Tiny helper to pull the reset closure from the environment and call it
    @Environment(\.resetOrderFlow) private var _resetOrderFlow

    private func resetOrderFlow() {
        _resetOrderFlow()
    }
}

// MARK: - Conditional modifier helper
private extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool,
                             transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}
