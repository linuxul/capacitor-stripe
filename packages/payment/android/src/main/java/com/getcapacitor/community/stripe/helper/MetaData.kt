package com.getcapacitor.community.stripe.helper

import android.content.Context
import android.content.pm.PackageManager
import androidx.core.util.Supplier
import com.getcapacitor.Logger
import com.stripe.android.googlepaylauncher.GooglePayEnvironment

public class MetaData(protected var contextSupplier: Supplier<Context>) {
    public var enableGooglePay: Boolean = false
    public var publishableKey: String? = null
    public var countryCode: String? = null
    public var displayName: String? = null
    public var stripeAccount: String? = null
    public var emailAddressRequired: Boolean? = null
    public var phoneNumberRequired: Boolean? = null
    public var billingAddressRequired: Boolean? = null
    public var billingAddressFormat: String? = null
    public var googlePayEnvironment: GooglePayEnvironment? = null

    public var existingPaymentMethodRequired: Boolean? = null

    public var enableIdentifier: Boolean = false

    init {
        try {
            val appInfo = contextSupplier
                .get()
                .packageManager
                .getApplicationInfo(contextSupplier.get().packageName, PackageManager.GET_META_DATA)

            enableGooglePay =
                appInfo.metaData.getBoolean("com.getcapacitor.community.stripe.enable_google_pay")
            publishableKey =
                appInfo.metaData.getString("com.getcapacitor.community.stripe.publishable_key")
            countryCode =
                appInfo.metaData.getString("com.getcapacitor.community.stripe.country_code")
            displayName =
                appInfo.metaData.getString("com.getcapacitor.community.stripe.merchant_display_name")
            stripeAccount =
                appInfo.metaData.getString("com.getcapacitor.community.stripe.stripe_account")
            emailAddressRequired =
                appInfo.metaData.getBoolean("com.getcapacitor.community.stripe.email_address_required")
            phoneNumberRequired =
                appInfo.metaData.getBoolean("com.getcapacitor.community.stripe.phone_number_required")
            billingAddressRequired =
                appInfo.metaData.getBoolean("com.getcapacitor.community.stripe.billing_address_required")
            billingAddressFormat =
                appInfo.metaData.getString("com.getcapacitor.community.stripe.billing_address_format")
            existingPaymentMethodRequired = appInfo.metaData.getBoolean(
                "com.getcapacitor.community.stripe.google_pay_existing_payment_method_required"
            )

            val isTest =
                appInfo.metaData.getBoolean("com.getcapacitor.community.stripe.google_pay_is_testing")
            googlePayEnvironment = if (isTest) {
                GooglePayEnvironment.Test
            } else {
                GooglePayEnvironment.Production
            }
        } catch (ignored: Exception) {
            Logger.info("MetaData didn't be prepare fore Google Pay.")
        }
    }
}
