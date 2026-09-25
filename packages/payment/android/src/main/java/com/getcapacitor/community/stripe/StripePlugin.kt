package com.getcapacitor.community.stripe

import android.content.ContentResolver
import android.net.Uri
import com.getcapacitor.JSObject
import com.getcapacitor.Logger
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginException
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.getcapacitor.community.stripe.googlepay.GooglePayExecutor
import com.getcapacitor.community.stripe.helper.MetaData
import com.getcapacitor.community.stripe.models.EventNotifier
import com.getcapacitor.community.stripe.paymentflow.PaymentFlowExecutor
import com.getcapacitor.community.stripe.paymentsheet.PaymentSheetExecutor
import com.stripe.android.PaymentConfiguration
import com.stripe.android.Stripe
import com.stripe.android.core.AppInfo
import com.stripe.android.googlepaylauncher.GooglePayLauncher
import com.stripe.android.paymentsheet.PaymentSheet
import com.stripe.android.paymentsheet.PaymentSheetResult

@CapacitorPlugin(name = "Stripe")
public class StripePlugin : Plugin() {
    private var publishableKey: String? = null
    private var paymentSheetCallbackId: String? = null
    private var paymentFlowCallbackId: String? = null
    private var googlePayCallbackId: String? = null

    private val identityVerificationCallbackId: String? = null

    private lateinit var metaData: MetaData

    private val paymentSheetExecutor = PaymentSheetExecutor(
        { this.context },
        { this.activity },
        EventNotifier { eventName, data, retainUntilConsumed ->
            this.notifyListeners(eventName, data, retainUntilConsumed)
        },
        logTag
    )

    private val paymentFlowExecutor = PaymentFlowExecutor(
        { this.context },
        { this.activity },
        EventNotifier { eventName, data, retainUntilConsumed ->
            this.notifyListeners(eventName, data, retainUntilConsumed)
        },
        logTag
    )

    private val googlePayExecutor = GooglePayExecutor(
        { this.context },
        { this.activity },
        EventNotifier { eventName, data, retainUntilConsumed ->
            this.notifyListeners(eventName, data, retainUntilConsumed)
        },
        logTag
    )

    override fun load() {
        this.metaData = MetaData { this.context }
        if (metaData.enableGooglePay) {
            this.publishableKey = metaData.publishableKey

            PaymentConfiguration.init(
                context,
                metaData.publishableKey!!,
                metaData.stripeAccount
            )

            Stripe.appInfo = AppInfo.create(APP_INFO_NAME)

            googlePayExecutor.googlePayLauncher = GooglePayLauncher(
                activity,
                GooglePayLauncher.Config(
                    metaData.googlePayEnvironment!!,
                    metaData.countryCode!!,
                    metaData.displayName!!,
                    metaData.emailAddressRequired!!,
                    GooglePayLauncher.BillingAddressConfig(
                        metaData.billingAddressRequired!!,
                        if (metaData.billingAddressFormat ==
                            "Full"
                        ) {
                            GooglePayLauncher.BillingAddressConfig.Format.Full
                        } else {
                            GooglePayLauncher.BillingAddressConfig.Format.Min
                        },
                        metaData.phoneNumberRequired!!
                    ),
                    metaData.existingPaymentMethodRequired!!
                ),
                { isReady: Boolean -> googlePayExecutor.isAvailable = isReady },
                { result: GooglePayLauncher.Result ->
                    googlePayExecutor.onGooglePayResult(
                        bridge,
                        googlePayCallbackId,
                        result
                    )
                }
            )
        } else {
            Logger.info("Plugin didn't prepare Google Pay.")
        }

        paymentSheetExecutor.paymentSheet = PaymentSheet(activity) { result: PaymentSheetResult ->
            paymentSheetExecutor.onPaymentSheetResult(bridge, paymentSheetCallbackId, result)
        }

        paymentFlowExecutor.flowController = PaymentSheet.FlowController.Builder(
            resultCallback = { result: PaymentSheetResult ->
                paymentFlowExecutor.onPaymentFlowResult(bridge, paymentFlowCallbackId, result)
            },
            paymentOptionResultCallback = { result ->
                paymentFlowExecutor.onPaymentOption(
                    bridge,
                    paymentFlowCallbackId,
                    result.paymentOption,
                    result.didCancel
                )
            }
        ).build(activity)

        if (metaData.enableIdentifier) {
            val resources = activity.applicationContext.resources
            val resourceId = resources.getIdentifier("ic_launcher", "mipmap", activity.packageName)
            val icon = Uri.Builder()
                .scheme(ContentResolver.SCHEME_ANDROID_RESOURCE)
                .authority(resources.getResourcePackageName(resourceId))
                .appendPath(resources.getResourceTypeName(resourceId))
                .appendPath(resources.getResourceEntryName(resourceId))
                .build()
        }
    }

    @PluginMethod
    public fun initialize(call: PluginCall) {
        val key = call.getString("publishableKey")
        publishableKey = key
        if (key == null || key == "") {
            throw PluginException("you must provide a valid key")
        }

        try {
            val stripeAccountId = call.getString("stripeAccount", null)

            PaymentConfiguration.init(context, key, stripeAccountId)
            Stripe.appInfo = AppInfo.create(APP_INFO_NAME)
        } catch (e: Exception) {
            throw PluginException("unable to set publishable key: " + e.localizedMessage, cause = e)
        }
        call.resolve()
    }

    @PluginMethod
    public fun createPaymentSheet(call: PluginCall) {
        paymentSheetExecutor.createPaymentSheet(call)
    }

    @PluginMethod
    public fun presentPaymentSheet(call: PluginCall) {
        paymentSheetCallbackId = call.callbackId
        bridge.saveCall(call)

        paymentSheetExecutor.presentPaymentSheet(call)
    }

    @PluginMethod
    public fun createPaymentFlow(call: PluginCall) {
        paymentFlowExecutor.createPaymentFlow(call)
    }

    @PluginMethod
    public fun presentPaymentFlow(call: PluginCall) {
        paymentFlowCallbackId = call.callbackId
        bridge.saveCall(call)

        paymentFlowExecutor.presentPaymentFlow(call)
    }

    @PluginMethod
    public fun confirmPaymentFlow(call: PluginCall) {
        paymentFlowCallbackId = call.callbackId
        bridge.saveCall(call)

        paymentFlowExecutor.confirmPaymentFlow(call)
    }

    @PluginMethod
    public fun isApplePayAvailable(call: PluginCall) {
        call.unimplemented("Not implemented on Android.")
    }

    @PluginMethod
    public fun createApplePay(call: PluginCall) {
        call.unimplemented("Not implemented on Android.")
    }

    @PluginMethod
    public fun presentApplePay(call: PluginCall) {
        call.unimplemented("Not implemented on Android.")
    }

    @PluginMethod
    public fun isGooglePayAvailable(call: PluginCall) {
        googlePayExecutor.isGooglePayAvailable(call)
    }

    @PluginMethod
    public fun createGooglePay(call: PluginCall) {
        googlePayExecutor.createGooglePay(call)
    }

    @PluginMethod
    public fun presentGooglePay(call: PluginCall) {
        googlePayCallbackId = call.callbackId
        bridge.saveCall(call)

        googlePayExecutor.presentGooglePay(call)
    }

    public companion object {
        private const val APP_INFO_NAME = "@capacitor-community/stripe"
    }
}
