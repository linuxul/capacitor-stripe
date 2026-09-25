import Foundation
import Capacitor
import StripeIdentity
import PassKit
import UIKit

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(StripeIdentityPlugin)
public class StripeIdentityPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "StripeIdentityPlugin"
    public let jsName = "StripeIdentity"
    public let pluginMethods: [CAPPluginMethod] = [
        .promise("initialize", StripeIdentityPlugin.initialize),
        .promise("create", StripeIdentityPlugin.create),
        .promise("present", StripeIdentityPlugin.present)
    ]
    private let implementation = StripeIdentity()

    override public func load() {
        super.load()
        self.implementation.plugin = self
        STPAPIClient.shared.appInfo = STPAppInfo(name: "@capacitor-community/stripe-identity", partnerId: nil, version: nil, url: nil)
    }

    func initialize(_ call: CAPPluginCall) {
        self.implementation.initialize(call)
    }

    func create(_ call: CAPPluginCall) throws {
        try self.implementation.create(call)
    }

    // The verification sheet answers in its completion handler, which Stripe calls after the sheet is dismissed.
    // present stays a synchronous method that presents the sheet in DispatchQueue.main.async and resolves from that
    // handler.
    func present(_ call: CAPPluginCall) {
        self.implementation.present(call)
    }

    func getRootVC() -> UIViewController? {
        var window: UIWindow? = UIApplication.shared.delegate?.window ?? nil

        if window == nil {
            let scene: UIWindowScene? = UIApplication.shared.connectedScenes.first as? UIWindowScene
            window = scene?.windows.filter({$0.isKeyWindow}).first
            if window == nil {
                window = scene?.windows.first
            }
        }
        return window?.rootViewController
    }
}
