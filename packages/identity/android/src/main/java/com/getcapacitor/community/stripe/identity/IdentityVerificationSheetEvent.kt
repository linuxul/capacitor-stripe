package com.getcapacitor.community.stripe.identity

public enum class IdentityVerificationSheetEvent(public val webEventName: String) {
    Loaded("identityVerificationSheetLoaded"),
    FailedToLoad("identityVerificationSheetFailedToLoad"),
    Completed("identityVerificationSheetCompleted"),
    Canceled("identityVerificationSheetCanceled"),
    Failed("identityVerificationSheetFailed"),
    VerificationResult("identityVerificationResult")
}
