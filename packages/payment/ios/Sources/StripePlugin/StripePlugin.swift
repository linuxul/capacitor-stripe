import Foundation
import Capacitor
import StripePaymentSheet
import StripeApplePay
import UIKit

@objc(StripePlugin)
public class StripePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "StripePlugin"
    public let jsName = "Stripe"
    public let pluginMethods: [CAPPluginMethod] = [
        .promise("initialize", StripePlugin.initialize),
        .promise("handleURLCallback", StripePlugin.handleURLCallback),
        .promise("createPaymentSheet", StripePlugin.createPaymentSheet),
        .promise("presentPaymentSheet", StripePlugin.presentPaymentSheet),
        .promise("createPaymentFlow", StripePlugin.createPaymentFlow),
        .promise("presentPaymentFlow", StripePlugin.presentPaymentFlow),
        .promise("confirmPaymentFlow", StripePlugin.confirmPaymentFlow),
        .promise("isApplePayAvailable", StripePlugin.isApplePayAvailable),
        .promise("createApplePay", StripePlugin.createApplePay),
        .promise("presentApplePay", StripePlugin.presentApplePay),
        .async("updateApplePaySheet", StripePlugin.updateApplePaySheet),
        .promise("isGooglePayAvailable", StripePlugin.isGooglePayAvailable),
        .promise("createGooglePay", StripePlugin.createGooglePay),
        .promise("presentGooglePay", StripePlugin.presentGooglePay)
    ]
    private let paymentSheetExecutor = PaymentSheetExecutor()
    private let paymentFlowExecutor = PaymentFlowExecutor()
    private let applePayExecutor = ApplePayExecutor()

    func initialize(_ call: CAPPluginCall) throws {
        self.paymentSheetExecutor.plugin = self
        self.paymentFlowExecutor.plugin = self
        self.applePayExecutor.plugin = self

        let publishableKey = call.getString("publishableKey") ?? ""

        if publishableKey == "" {
            throw CAPPluginError("you must provide publishableKey")
        }

        StripeAPI.defaultPublishableKey = publishableKey

        let stripeAccount = call.getString("stripeAccount") ?? ""

        if stripeAccount != "" {
            STPAPIClient.shared.stripeAccount = stripeAccount
        }

        STPAPIClient.shared.appInfo = STPAppInfo(name: "@capacitor-community/stripe", partnerId: nil, version: nil, url: nil)

        call.resolve()
    }

    func handleURLCallback(_ call: CAPPluginCall) throws {
        self.paymentSheetExecutor.plugin = self
        self.paymentFlowExecutor.plugin = self
        self.applePayExecutor.plugin = self

        let urlString = call.getString("url") ?? ""

        if urlString == "" {
            throw CAPPluginError("you must provide url returned from browser")
        }

        let url = URL(string: urlString)!
        DispatchQueue.main.async {
            let stripeHandled = StripeAPI.handleURLCallback(with: url)
            if !stripeHandled {
                call.reject("This was not a Stripe url – handle the URL normally as you would")
                return
            }
            call.resolve()
        }

    }

    func createPaymentSheet(_ call: CAPPluginCall) throws {
        try self.paymentSheetExecutor.createPaymentSheet(call)
    }

    // The payment sheets and Apple Pay answer in Stripe's completion handlers and delegate callbacks, after the user
    // closes them. The present and confirm methods stay synchronous: they present in DispatchQueue.main.async and
    // settle the call from those callbacks, as before.

    func presentPaymentSheet(_ call: CAPPluginCall) {
        self.paymentSheetExecutor.presentPaymentSheet(call)
    }

    func createPaymentFlow(_ call: CAPPluginCall) throws {
        try self.paymentFlowExecutor.createPaymentFlow(call)
    }

    func presentPaymentFlow(_ call: CAPPluginCall) {
        self.paymentFlowExecutor.presentPaymentFlow(call)
    }

    func confirmPaymentFlow(_ call: CAPPluginCall) {
        self.paymentFlowExecutor.confirmPaymentFlow(call)
    }

    func isApplePayAvailable(_ call: CAPPluginCall) throws {
        try self.applePayExecutor.isApplePayAvailable(call)
    }

    func createApplePay(_ call: CAPPluginCall) throws {
        try self.applePayExecutor.createApplePay(call)
    }

    func presentApplePay(_ call: CAPPluginCall) throws {
        try self.applePayExecutor.presentApplePay(call)
    }

    /// Answers the shipping contact update the Apple Pay sheet is waiting for. The pending handler belongs to the
    /// sheet's delegate callbacks on the main thread, so the method runs on the main actor.
    @MainActor
    func updateApplePaySheet(_ call: CAPPluginCall) async throws {
        try self.applePayExecutor.updateApplePaySheet(call)
    }

    func isGooglePayAvailable(_ call: CAPPluginCall) throws {
        throw CAPPluginError.unavailable("Not implemented on iOS.")
    }

    func createGooglePay(_ call: CAPPluginCall) throws {
        throw CAPPluginError.unavailable("Not implemented on iOS.")
    }

    func presentGooglePay(_ call: CAPPluginCall) throws {
        throw CAPPluginError.unavailable("Not implemented on iOS.")
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
