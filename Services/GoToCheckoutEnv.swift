import SwiftUI

private struct GoToCheckoutKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}
private struct ResetOrderFlowKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var goToCheckout: () -> Void {
        get { self[GoToCheckoutKey.self] }
        set { self[GoToCheckoutKey.self] = newValue }
    }
    var resetOrderFlow: () -> Void {
        get { self[ResetOrderFlowKey.self] }
        set { self[ResetOrderFlowKey.self] = newValue }
    }
}
