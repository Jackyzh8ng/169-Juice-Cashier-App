import SwiftUI

/// Wraps your adapted AddOnsView by providing local @State and forwarding flow inputs.
struct AddOnsScreen: View {
    // Flow inputs
    let flavours: [Flavour]
    let presetCup: CupType
    let flavoursLocked: Bool

    // Callback
    var onDone: ([AddOn]) -> Void

    // Local selection state
    @State private var selected: Set<AddOn>

    init(
        flavours: [Flavour],
        presetCup: CupType,
        flavoursLocked: Bool,
        initial: Set<AddOn> = [],
        onDone: @escaping ([AddOn]) -> Void
    ) {
        self.flavours = flavours
        self.presetCup = presetCup
        self.flavoursLocked = flavoursLocked
        self.onDone = onDone
        _selected = State(initialValue: initial)
    }

    var body: some View {
        AddOnsView(
            flavours: flavours,
            presetCup: presetCup,
            flavoursLocked: flavoursLocked,
            selected: $selected,
            onNext: { picked in onDone(picked) }
        )
    }
}
