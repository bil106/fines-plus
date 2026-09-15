import CarPlay
import UIKit

/// Minimal CarPlay scene delegate — milestone 1 is just proving the CarPlay
/// Simulator connects and shows a template; the real fuel-purchase flow
/// (preset amounts, no free-text entry per CarPlay's driver-safety rules)
/// gets built on top of this once connectivity is confirmed.
class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
  var interfaceController: CPInterfaceController?

  func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didConnect interfaceController: CPInterfaceController
  ) {
    self.interfaceController = interfaceController

    let item = CPListItem(text: "Fines Plus", detailText: "CarPlay connected")
    let section = CPListSection(items: [item])
    let listTemplate = CPListTemplate(title: "Fines Plus", sections: [section])

    interfaceController.setRootTemplate(listTemplate, animated: true, completion: nil)
  }

  func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didDisconnectInterfaceController interfaceController: CPInterfaceController
  ) {
    self.interfaceController = nil
  }
}
