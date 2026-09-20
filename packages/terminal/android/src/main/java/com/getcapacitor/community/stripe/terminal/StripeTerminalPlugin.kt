package com.getcapacitor.community.stripe.terminal

import android.Manifest
import android.util.Log
import com.getcapacitor.JSObject
import com.getcapacitor.PermissionState
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.getcapacitor.annotation.Permission
import com.getcapacitor.annotation.PermissionCallback
import com.getcapacitor.community.stripe.terminal.models.EventNotifier
import com.stripe.stripeterminal.external.models.TerminalException

@CapacitorPlugin(
    name = "StripeTerminal",
    permissions = [
        Permission(
            alias = "location",
            strings = [Manifest.permission.ACCESS_FINE_LOCATION]
        ), Permission(
            alias = "bluetooth_old",
            strings = [Manifest.permission.BLUETOOTH, Manifest.permission.BLUETOOTH_ADMIN]
        ), Permission(
            alias = "bluetooth",
            strings = [Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT, Manifest.permission.BLUETOOTH_ADVERTISE]
        )
    ]
)
public class StripeTerminalPlugin : Plugin() {
    private val implementation = StripeTerminal(
        { this.context },
        { this.activity },
        EventNotifier { eventName, data, retainUntilConsumed ->
            this.notifyListeners(eventName, data, retainUntilConsumed)
        },
        logTag
    )

    @PluginMethod
    @Throws(TerminalException::class)
    public fun initialize(call: PluginCall) {
        this.initializeWhenPermitted(call)
    }

    @PluginMethod
    public fun setConnectionToken(call: PluginCall) {
        implementation.setConnectionToken(call)
    }

    @PluginMethod
    public fun setSimulatorConfiguration(call: PluginCall) {
        implementation.setSimulatorConfiguration(call)
    }

    @PermissionCallback
    @Throws(TerminalException::class)
    private fun locationPermsCallback(call: PluginCall) {
        if (getPermissionState("location") == PermissionState.GRANTED) {
            this.initializeWhenPermitted(call)
        } else {
            requestPermissionForAlias("location", call, "locationPermsCallback")
        }
    }

    @PermissionCallback
    @Throws(TerminalException::class)
    private fun bluetoothPermsCallback(call: PluginCall) {
        if (getPermissionState("bluetooth") == PermissionState.GRANTED) {
            if (call.methodName == "discoverReaders") {
                this.discoverReaders(call)
            } else {
                this.connectReader(call)
            }
        } else {
            requestPermissionForAlias("bluetooth", call, "bluetoothPermsCallback")
        }
    }

    @Throws(TerminalException::class)
    private fun initializeWhenPermitted(call: PluginCall) {
        if (getPermissionState("location") != PermissionState.GRANTED) {
            requestPermissionForAlias("location", call, "locationPermsCallback")
        } else {
            Log.d("Capacitor:permission location", getPermissionState("location").toString())
            implementation.initialize(call)
        }
    }

    @PluginMethod
    public fun discoverReaders(call: PluginCall) {
        if (call.getString("type") == TerminalConnectTypes.Bluetooth.webEventName || call.getString(
                "type"
            ) == TerminalConnectTypes.Simulated.webEventName
        ) {
            if (getPermissionState("bluetooth") != PermissionState.GRANTED) {
                requestPermissionForAlias("bluetooth", call, "bluetoothPermsCallback")
            } else {
                implementation.onDiscoverReaders(call)
            }
        } else {
            implementation.onDiscoverReaders(call)
        }
    }

    @PluginMethod
    public fun cancelDiscoverReaders(call: PluginCall) {
        implementation.cancelDiscoverReaders(call)
    }

    @PluginMethod
    public fun connectReader(call: PluginCall) {
        if (call.getString("type") == TerminalConnectTypes.Bluetooth.webEventName) {
            Log.d(
                "Capacitor:permission bluetooth_old",
                getPermissionState("bluetooth_old").toString()
            )
            Log.d("Capacitor:permission bluetooth", getPermissionState("bluetooth").toString())
            if (getPermissionState("bluetooth") != PermissionState.GRANTED) {
                requestPermissionForAlias("bluetooth", call, "bluetoothPermsCallback")
            } else {
                implementation.connectReader(call)
            }
        } else {
            implementation.connectReader(call)
        }
    }

    @PluginMethod
    public fun getConnectedReader(call: PluginCall) {
        implementation.getConnectedReader(call)
    }

    @PluginMethod
    public fun disconnectReader(call: PluginCall) {
        implementation.disconnectReader(call)
    }

    @PluginMethod
    public fun collectPaymentMethod(call: PluginCall) {
        implementation.collectPaymentMethod(call)
    }

    @PluginMethod
    public fun cancelCollectPaymentMethod(call: PluginCall) {
        implementation.cancelCollectPaymentMethod(call)
    }

    @PluginMethod
    public fun confirmPaymentIntent(call: PluginCall) {
        implementation.confirmPaymentIntent(call)
    }

    @PluginMethod
    public fun installAvailableUpdate(call: PluginCall) {
        implementation.installAvailableUpdate(call)
    }

    @PluginMethod
    public fun cancelInstallUpdate(call: PluginCall) {
        implementation.cancelInstallUpdate(call)
    }

    @PluginMethod
    public fun setReaderDisplay(call: PluginCall) {
        implementation.setReaderDisplay(call)
    }

    @PluginMethod
    public fun clearReaderDisplay(call: PluginCall) {
        implementation.clearReaderDisplay(call)
    }

    @PluginMethod
    public fun rebootReader(call: PluginCall) {
        implementation.rebootReader(call)
    }

    @PluginMethod
    public fun cancelReaderReconnection(call: PluginCall) {
        implementation.cancelReaderReconnection(call)
    }

    @PluginMethod
    public fun setTapToPayUxConfiguration(call: PluginCall) {
        implementation.setTapToPayUxConfiguration(call)
    }

    @PluginMethod
    public fun isTapToPayAccountLinked(call: PluginCall) {
        call.unimplemented("isTapToPayAccountLinked is only supported on iOS.")
    }
}
