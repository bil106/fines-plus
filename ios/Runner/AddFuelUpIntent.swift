import AppIntents
import app_links
import Foundation

/// Shortcuts / Siri action "Add fuel-up": opens the app on the fuel-up form
/// with the paid amount pre-filled, so the user only confirms. Meant for the
/// iOS 17+ Shortcuts "Transaction" automation (fires on an Apple Pay payment
/// at chosen merchants), which hands over the payment's Amount.
///
/// The amount reaches Flutter as the same `<bundle id>://fuel?amount=` link a
/// plain "Open URL" action would open, through app_links - so there's one
/// Dart-side path for both (see `FuelPaymentLink`).
@available(iOS 16.0, *)
struct AddFuelUpIntent: AppIntent {
  static var title: LocalizedStringResource = "Add fuel-up"
  static var description = IntentDescription("Opens the fuel-up form with the paid amount filled in.")
  static var openAppWhenRun = true

  @Parameter(title: "Amount")
  var amount: Double?

  @MainActor
  func perform() async throws -> some IntentResult {
    guard let scheme = Bundle.main.bundleIdentifier,
          var components = URLComponents(string: "\(scheme)://fuel") else {
      return .result()
    }
    if let amount {
      components.queryItems = [URLQueryItem(name: "amount", value: String(amount))]
    }
    if let url = components.url {
      AppLinks.shared.handleLink(url: url)
    }
    return .result()
  }
}

/// Makes the action show up under the app in Shortcuts (and for Siri)
/// without the user having to add it first.
@available(iOS 16.0, *)
struct FuelShortcutsProvider: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: AddFuelUpIntent(),
      phrases: ["Add fuel-up in \(.applicationName)"]
    )
  }
}
