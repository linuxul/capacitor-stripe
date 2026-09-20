package com.getcapacitor.community.stripe.googlepay

public enum class GooglePayEvents(public val webEventName: String) {
    Loaded("googlePayLoaded"),
    FailedToLoad("googlePayFailedToLoad"),
    Completed("googlePayCompleted"),
    Canceled("googlePayCanceled"),
    Failed("googlePayFailed")
}
