import SwiftUI

struct HomeView: View {
    enum Route: Hashable {
        case addOns(flavours: [Flavour], cup: CupType, flavoursLocked: Bool)
        case build(flavours: [Flavour], addOns: [AddOn], cup: CupType, flavoursLocked: Bool)
    }

    @State private var path: [Route] = []
    @State private var selectedFlavours: Set<Flavour> = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {

                // CUP -> FlavourSelect -> AddOns -> Build
                NavigationLink {
                    FlavourSelectView(
                        selected: $selectedFlavours,
                        onNext: { flavours in
                            path.append(.addOns(flavours: flavours, cup: .cup, flavoursLocked: false))
                        }
                    )
                    .navigationTitle("Pick Flavour(s)")
                } label: {
                    Label("Cup", systemImage: "cup.and.saucer")
                        .font(.title)
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }

                // PINEAPPLE -> FlavourSelect -> AddOns -> Build
                NavigationLink {
                    FlavourSelectView(
                        selected: $selectedFlavours,
                        onNext: { flavours in
                            path.append(.addOns(flavours: flavours, cup: .pshell, flavoursLocked: false))
                        }
                    )
                    .navigationTitle("Pick Flavour(s)")
                } label: {
                    Label("Pineapple Shell", systemImage: "leaf")
                        .font(.title)
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }

                // WATERMELON -> AddOns -> Build
                Button {
                    path.append(.addOns(flavours: [.watermelon], cup: .wshell, flavoursLocked: true))
                } label: {
                    Label("Watermelon Shell", systemImage: "leaf.fill")
                        .font(.title)
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("169 Juice")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case let .addOns(flavours, cup, locked):
                    AddOnsScreen(
                        flavours: flavours,
                        presetCup: cup,
                        flavoursLocked: locked,
                        initial: [],
                        onDone: { pickedAddOns in
                            path.append(.build(
                                flavours: flavours,
                                addOns: pickedAddOns,
                                cup: cup,
                                flavoursLocked: locked
                            ))
                        }
                    )
                    .navigationTitle("Select Add-Ons")

                case let .build(flavours, addOns, cup, locked):
                    BuildDrinkView(
                        flavours: flavours,
                        addOns: addOns,
                        presetCup: cup,
                        flavoursLocked: locked
                    )
                }
            }
        }
        // 🔑 Expose a reset closure so children can clear this stack
        .environment(\.resetOrderFlow, { path.removeAll() })
    }
}
