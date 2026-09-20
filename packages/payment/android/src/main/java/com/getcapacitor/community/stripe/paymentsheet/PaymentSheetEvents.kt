package com.getcapacitor.community.stripe.paymentsheet

public enum class PaymentSheetEvents(public val webEventName: String) {
    Loaded("paymentSheetLoaded"),
    FailedToLoad("paymentSheetFailedToLoad"),
    Completed("paymentSheetCompleted"),
    Canceled("paymentSheetCanceled"),
    Failed("paymentSheetFailed")
}
