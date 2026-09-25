import XCTest
import Capacitor
@testable import StripePlugin

class StripeTests: XCTestCase {
    func testBridgedPlugin() {
        let plugin = StripePlugin()

        XCTAssertEqual("StripePlugin", plugin.identifier)
        XCTAssertEqual("Stripe", plugin.jsName)
        XCTAssertEqual(
            [
                "initialize", "handleURLCallback", "createPaymentSheet", "presentPaymentSheet", "createPaymentFlow",
                "presentPaymentFlow", "confirmPaymentFlow", "isApplePayAvailable", "createApplePay", "presentApplePay",
                "updateApplePaySheet", "isGooglePayAvailable", "createGooglePay", "presentGooglePay"
            ],
            plugin.pluginMethods.map { $0.name })
        XCTAssertTrue(plugin.pluginMethods.allSatisfy { $0.returnType == .promise })
    }

    private struct Rejection {
        let method: String
        let perform: (CAPPluginCall) throws -> Void
        let options: JSObject
        let message: String
    }

    func testValidationThrowsWithTheSameMessages() {
        let plugin = StripePlugin()
        let missingIntent = "Invalid Params. this method require paymentIntentClientSecret or setupIntentClientSecret."
        let missingKey = "Invalid Params. When you set customerId, you must set customerEphemeralKeySecret."
        let cases = [
            Rejection(method: "initialize", perform: plugin.initialize, options: [:], message: "you must provide publishableKey"),
            Rejection(method: "handleURLCallback", perform: plugin.handleURLCallback, options: [:],
                      message: "you must provide url returned from browser"),
            Rejection(method: "createPaymentSheet", perform: plugin.createPaymentSheet, options: [:], message: missingIntent),
            Rejection(method: "createPaymentSheet", perform: plugin.createPaymentSheet,
                      options: ["paymentIntentClientSecret": "pi_secret", "customerId": "cus_1"], message: missingKey),
            Rejection(method: "createPaymentFlow", perform: plugin.createPaymentFlow, options: [:], message: missingIntent),
            Rejection(method: "createPaymentFlow", perform: plugin.createPaymentFlow,
                      options: ["setupIntentClientSecret": "seti_secret", "customerId": "cus_1"], message: missingKey),
            Rejection(method: "createApplePay", perform: plugin.createApplePay, options: [:],
                      message: "Invalid Params. this method require paymentIntentClientSecret"),
            Rejection(method: "createApplePay", perform: plugin.createApplePay, options: ["paymentIntentClientSecret": "pi_secret"],
                      message: "Invalid Params. this method require paymentSummaryItems"),
            Rejection(method: "presentApplePay", perform: plugin.presentApplePay, options: [:],
                      message: "You should run createApplePay befor presentApplePay")
        ]
        for rejection in cases {
            XCTAssertThrowsError(try rejection.perform(unansweredCall(rejection.method, rejection.options)), rejection.method) { error in
                XCTAssertEqual((error as? CAPPluginError)?.message, rejection.message, rejection.method)
                XCTAssertNil((error as? CAPPluginError)?.code, rejection.method)
            }
        }
    }

    func testGooglePayIsUnavailable() {
        let plugin = StripePlugin()
        let methods: [(String, (CAPPluginCall) throws -> Void)] = [
            ("isGooglePayAvailable", plugin.isGooglePayAvailable),
            ("createGooglePay", plugin.createGooglePay),
            ("presentGooglePay", plugin.presentGooglePay)
        ]
        for (method, perform) in methods {
            XCTAssertThrowsError(try perform(unansweredCall(method, [:])), method) { error in
                XCTAssertEqual((error as? CAPPluginError)?.message, "Not implemented on iOS.", method)
                XCTAssertEqual((error as? CAPPluginError)?.code, "UNAVAILABLE", method)
            }
        }
    }

    @MainActor
    func testUpdateApplePaySheetWithoutAPendingUpdateThrows() async {
        let cases: [(JSObject, String)] = [
            ([:], "Invalid Params. this method requires updateId"),
            (["updateId": ""], "Invalid Params. this method requires updateId"),
            (["updateId": "update-1"], "No pending shipping update")
        ]
        for (options, message) in cases {
            do {
                try await StripePlugin().updateApplePaySheet(unansweredCall("updateApplePaySheet", options))
                XCTFail("updateApplePaySheet should throw for \(options)")
            } catch let error as CAPPluginError {
                XCTAssertEqual(error.message, message)
                XCTAssertNil(error.code)
            } catch {
                XCTFail("unexpected error \(error)")
            }
        }
    }

    private func unansweredCall(_ method: String, _ options: JSObject) -> CAPPluginCall {
        return CAPPluginCall(callbackId: "test", methodName: method, options: options, success: { _, _ in
            XCTFail("\(method) answers by throwing")
        }, error: { _ in
            XCTFail("\(method) answers by throwing")
        })
    }
}
