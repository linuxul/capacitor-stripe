import Foundation
import StripeTerminal
import Capacitor
import PassKit

@objc(StripeTerminalPlugin)
public class StripeTerminalPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "StripeTerminalPlugin"
    public let jsName = "StripeTerminal"
    public let pluginMethods: [CAPPluginMethod] = [
        .promise("initialize", StripeTerminalPlugin.initialize),
        .promise("setConnectionToken", StripeTerminalPlugin.setConnectionToken),
        .promise("discoverReaders", StripeTerminalPlugin.discoverReaders),
        .promise("cancelDiscoverReaders", StripeTerminalPlugin.cancelDiscoverReaders),
        .promise("connectReader", StripeTerminalPlugin.connectReader),
        .promise("getConnectedReader", StripeTerminalPlugin.getConnectedReader),
        .promise("disconnectReader", StripeTerminalPlugin.disconnectReader),
        .promise("collectPaymentMethod", StripeTerminalPlugin.collectPaymentMethod),
        .promise("cancelCollectPaymentMethod", StripeTerminalPlugin.cancelCollectPaymentMethod),
        .promise("confirmPaymentIntent", StripeTerminalPlugin.confirmPaymentIntent),
        .promise("setSimulatorConfiguration", StripeTerminalPlugin.setSimulatorConfiguration),
        .promise("installAvailableUpdate", StripeTerminalPlugin.installAvailableUpdate),
        .promise("cancelInstallUpdate", StripeTerminalPlugin.cancelInstallUpdate),
        .promise("setReaderDisplay", StripeTerminalPlugin.setReaderDisplay),
        .promise("clearReaderDisplay", StripeTerminalPlugin.clearReaderDisplay),
        .promise("rebootReader", StripeTerminalPlugin.rebootReader),
        .promise("cancelReaderReconnection", StripeTerminalPlugin.cancelReaderReconnection),
        .promise("setTapToPayUxConfiguration", StripeTerminalPlugin.setTapToPayUxConfiguration),
        .promise("isTapToPayAccountLinked", StripeTerminalPlugin.isTapToPayAccountLinked)
    ]
    private let implementation = StripeTerminal()

    override public func load() {
        super.load()
        self.implementation.plugin = self
        // TODO: add STPAPIClient.shared.appInfo
    }

    // Every method stays synchronous on the bridge queue. Reader discovery, connection, collection and confirmation
    // are Stripe Terminal operations that answer in the SDK's completion handlers and delegate callbacks, and that
    // JavaScript runs in order; async methods would not keep that order.

    func initialize(_ call: CAPPluginCall) {
        self.implementation.initialize(call)
    }

    func setConnectionToken(_ call: CAPPluginCall) {
        self.implementation.setConnectionToken(call)
    }

    func discoverReaders(_ call: CAPPluginCall) {
        do {
            try self.implementation.discoverReaders(call)
        } catch {
            call.reject("discoverReaders throw error.")
        }
    }

    func setSimulatorConfiguration(_ call: CAPPluginCall) {
        self.implementation.setSimulatorConfiguration(call)
    }

    func cancelDiscoverReaders(_ call: CAPPluginCall) {
        self.implementation.cancelDiscoverReaders(call)
    }

    func connectReader(_ call: CAPPluginCall) {
        self.implementation.connectReader(call)
    }

    func getConnectedReader(_ call: CAPPluginCall) {
        self.implementation.getConnectedReader(call)
    }

    func disconnectReader(_ call: CAPPluginCall) {
        self.implementation.disconnectReader(call)
    }

    func collectPaymentMethod(_ call: CAPPluginCall) {
        self.implementation.collectPaymentMethod(call)
    }

    func cancelCollectPaymentMethod(_ call: CAPPluginCall) {
        self.implementation.cancelCollectPaymentMethod(call)
    }

    func confirmPaymentIntent(_ call: CAPPluginCall) throws {
        try self.implementation.confirmPaymentIntent(call)
    }

    func installAvailableUpdate(_ call: CAPPluginCall) {
        self.implementation.installAvailableUpdate(call)
    }

    func cancelInstallUpdate(_ call: CAPPluginCall) {
        self.implementation.cancelInstallUpdate(call)
    }

    func setReaderDisplay(_ call: CAPPluginCall) throws {
        try self.implementation.setReaderDisplay(call)
    }

    func clearReaderDisplay(_ call: CAPPluginCall) {
        self.implementation.clearReaderDisplay(call)
    }

    func rebootReader(_ call: CAPPluginCall) {
        self.implementation.rebootReader(call)
    }

    func cancelReaderReconnection(_ call: CAPPluginCall) {
        self.implementation.cancelReaderReconnection(call)
    }
    
    func setTapToPayUxConfiguration(_ call: CAPPluginCall) throws {
        throw CAPPluginError.unimplemented()
    }

    func isTapToPayAccountLinked(_ call: CAPPluginCall) throws {
        try self.implementation.isTapToPayAccountLinked(call)
    }
}
