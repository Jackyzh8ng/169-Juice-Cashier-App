import SwiftUI

struct HomeView: View {
    enum Route: Hashable {
        case addOns(flavours: [Flavour], cup: CupType, flavoursLocked: Bool)
        case build(flavours: [Flavour], addOns: [AddOn], cup: CupType, flavoursLocked: Bool)
        case checkout
    }

    @EnvironmentObject private var cart: CartStore

    @State private var path: [Route] = []
    @State private var selectedFlavours: Set<Flavour> = []

    // Presets
    @StateObject private var presetStore = PresetStore()
    @State private var showAddPreset = false
    @State private var newName = ""
    @State private var newCup: CupType = .cup
    @State private var newFlavours: Set<Flavour> = []
    @State private var newAddOns: Set<AddOn> = []
    @State private var showPresetValidationAlert = false

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

                // ===== Presets bar =====
                presetsBar

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

                case .checkout:
                    CheckOutView(onAddMoreDrinks: { path.removeAll() })
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .environment(\.resetOrderFlow, { path.removeAll() })
        .sheet(isPresented: $showAddPreset, content: newPresetSheet)
    }

    // MARK: - Presets UI

    private var presetsBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Presets").font(.headline)
                Spacer()
                Button {
                    showAddPreset = true
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(presetStore.presets) { p in
                        Button {
                            addPresetToCartAndCheckout(p)
                        } label: {
                            Text(p.name)
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.secondary.opacity(0.15), in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("preset_\(p.id.uuidString)")
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func addPresetToCartAndCheckout(_ p: Preset) {
        let price = Pricing.price(cup: p.cup, addOns: p.addOns, flavours: p.flavours)
        let drink = Drink(selection: p.flavours, cupType: p.cup, addOns: p.addOns, price: price)
        cart.add(drink: drink, quantity: 1)
        path = [.checkout] // jump straight to checkout
    }

    // MARK: - New Preset Sheet

    @ViewBuilder
    private func newPresetSheet() -> some View {
        NavigationView {
            Form {
                Section("Name") {
                    TextField("e.g., Mango + Pineapple • Boba", text: $newName)
                }
                Section("Cup") {
                    Picker("Cup", selection: $newCup) {
                        ForEach(CupType.allCases, id: \.self) {
                            Text($0.rawValue.capitalized).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Flavours") {
                    ForEach(Flavour.allCases, id: \.self) { f in
                        Toggle(f.rawValue.capitalized,
                               isOn: containsBinding(f, in: $newFlavours))
                    }
                }
                Section("Add-Ons") {
                    ForEach(AddOn.allCases, id: \.self) { a in
                        Toggle(a.rawValue.capitalized,
                               isOn: containsBinding(a, in: $newAddOns))
                    }
                }
                Section {
                    Button {
                        // If no flavours, show alert and bail
                        guard newFlavours.isEmpty == false else {
                            showPresetValidationAlert = true
                            return
                        }
                        // If name left blank, auto-generate from selections
                        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                        let finalName = trimmed.isEmpty ? autoName(cup: newCup,
                                                                   flavours: Array(newFlavours),
                                                                   addOns: Array(newAddOns)) : trimmed

                        let preset = Preset(name: finalName,
                                            cup: newCup,
                                            flavours: Array(newFlavours),
                                            addOns: Array(newAddOns))
                        presetStore.add(preset)

                        // reset & close
                        newName = ""
                        newCup = .cup
                        newFlavours.removeAll()
                        newAddOns.removeAll()
                        showAddPreset = false
                    } label: {
                        Label("Save Preset", systemImage: "tray.and.arrow.down")
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("New Preset")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddPreset = false }
                }
            }
            .alert("Pick at least one flavour", isPresented: $showPresetValidationAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    // MARK: - Helper: fast, compiler-friendly toggle binding for Set<T>
    private func containsBinding<T: Hashable>(
        _ value: T,
        in set: Binding<Set<T>>
    ) -> Binding<Bool> {
        Binding<Bool>(
            get: { set.wrappedValue.contains(value) },
            set: { isOn in
                var copy = set.wrappedValue
                if isOn { copy.insert(value) } else { copy.remove(value) }
                set.wrappedValue = copy
            }
        )
    }

    // MARK: - Helper: auto-generate a readable preset name
    private func autoName(cup: CupType, flavours: [Flavour], addOns: [AddOn]) -> String {
        let flavoursText = flavours.map { $0.rawValue.capitalized }.joined(separator: " + ")
        let addOnsText = addOns.isEmpty ? "" : " • " + addOns.map { $0.rawValue.capitalized }.joined(separator: ", ")
        return "\(cup.rawValue.capitalized): \(flavoursText)\(addOnsText)"
    }
}
