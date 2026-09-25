import XCTest
import Capacitor
@testable import StripeIdentityPlugin

class StripeIdentityTests: XCTestCase {
    func testBridgedPlugin() {
        let plugin = StripeIdentityPlugin()

        XCTAssertEqual("StripeIdentityPlugin", plugin.identifier)
        XCTAssertEqual("StripeIdentity", plugin.jsName)
        XCTAssertEqual(["initialize", "create", "present"], plugin.pluginMethods.map { $0.name })
        XCTAssertEqual([.promise, .promise, .promise], plugin.pluginMethods.map { $0.returnType })
    }

    func testCreateWithoutTheSessionThrows() {
        for options: JSObject in [[:], ["verificationId": "vs_123"], ["ephemeralKeySecret": "ek_123"]] {
            XCTAssertThrowsError(try StripeIdentityPlugin().create(unansweredCall("create", options))) { error in
                XCTAssertEqual(
                    (error as? CAPPluginError)?.message,
                    "Invalid Params. this method require verificationId or ephemeralKeySecret.")
                XCTAssertNil((error as? CAPPluginError)?.code)
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
