import XCTest
import Capacitor
@testable import StripeTerminalPlugin

class StripeTerminalTests: XCTestCase {
    private struct Rejection {
        let method: String
        let perform: (CAPPluginCall) throws -> Void
        let options: JSObject
        let message: String
        var code: String?
    }

    func testBridgedPlugin() {
        let plugin = StripeTerminalPlugin()

        XCTAssertEqual("StripeTerminalPlugin", plugin.identifier)
        XCTAssertEqual("StripeTerminal", plugin.jsName)
        XCTAssertEqual(
            [
                "initialize", "setConnectionToken", "discoverReaders", "cancelDiscoverReaders", "connectReader",
                "getConnectedReader", "disconnectReader", "collectPaymentMethod", "cancelCollectPaymentMethod",
                "confirmPaymentIntent", "setSimulatorConfiguration", "installAvailableUpdate", "cancelInstallUpdate",
                "setReaderDisplay", "clearReaderDisplay", "rebootReader", "cancelReaderReconnection",
                "setTapToPayUxConfiguration", "isTapToPayAccountLinked"
            ],
            plugin.pluginMethods.map { $0.name })
        XCTAssertTrue(plugin.pluginMethods.allSatisfy { $0.returnType == .promise })
    }

    func testValidationThrowsWithTheSameMessages() {
        let plugin = StripeTerminalPlugin()
        let cases = [
            Rejection(method: "confirmPaymentIntent", perform: plugin.confirmPaymentIntent, options: [:],
                      message: "PaymentIntent not found for confirmPaymentIntent. Use collect method first and try again."),
            Rejection(method: "isTapToPayAccountLinked", perform: plugin.isTapToPayAccountLinked, options: [:],
                      message: "Stripe Terminal is not initialized. Call initialize() first."),
            Rejection(method: "setReaderDisplay", perform: plugin.setReaderDisplay, options: [:],
                      message: "You must provide a currency value"),
            Rejection(method: "setReaderDisplay", perform: plugin.setReaderDisplay, options: ["currency": "usd", "total": 100],
                      message: "You must provide a tax value"),
            Rejection(method: "setReaderDisplay", perform: plugin.setReaderDisplay, options: ["currency": "usd", "tax": 0],
                      message: "You must provide a total value"),
            Rejection(method: "setTapToPayUxConfiguration", perform: plugin.setTapToPayUxConfiguration, options: [:],
                      message: "not implemented", code: "UNIMPLEMENTED")
        ]
        for rejection in cases {
            XCTAssertThrowsError(try rejection.perform(unansweredCall(rejection.method, rejection.options)), rejection.method) { error in
                XCTAssertEqual((error as? CAPPluginError)?.message, rejection.message, rejection.method)
                XCTAssertEqual((error as? CAPPluginError)?.code, rejection.code, rejection.method)
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
