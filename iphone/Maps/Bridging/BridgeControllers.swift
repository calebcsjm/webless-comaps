import SwiftUI
import UIKit

/// Class for accesing SwiftUI views from Objective-C code
@objc class BridgeControllers: NSObject {
    /// The `RoutingOptionsView` for presentation in an alert
    @objc static func routingOptions() -> UIViewController {
        let routinOptionsBridgeController = UIHostingController(rootView: RoutingOptionsView())
        routinOptionsBridgeController.view.backgroundColor = .systemGroupedBackground
        return routinOptionsBridgeController
    }
}



/// Class for using the SwiftUI `AboutView` in the interface builder
class AboutBridgeController: UIHostingController<AboutView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: AboutView())
    }
}



/// Class for using the SwiftUI `SettingsView` in the interface builder
class SettingsBridgeController: UIHostingController<SettingsView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SettingsView())
    }
}

