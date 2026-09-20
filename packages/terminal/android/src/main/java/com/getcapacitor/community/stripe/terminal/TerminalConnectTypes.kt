package com.getcapacitor.community.stripe.terminal

public enum class TerminalConnectTypes(public val webEventName: String) {
    Simulated("simulated"),
    Internet("internet"),
    Bluetooth("bluetooth"),
    Usb("usb"),
    TapToPay("tap-to-pay"),
    HandOff("hand-off")
}
