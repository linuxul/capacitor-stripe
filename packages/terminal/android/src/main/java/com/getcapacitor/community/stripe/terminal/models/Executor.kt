package com.getcapacitor.community.stripe.terminal.models

import android.app.Activity
import android.content.Context
import androidx.core.util.Supplier
import com.getcapacitor.JSObject

public fun interface EventNotifier {
    public fun accept(eventName: String, data: JSObject, retainUntilConsumed: Boolean)

    public fun accept(eventName: String, data: JSObject) {
        accept(eventName, data, false)
    }
}

public abstract class Executor(
    protected var contextSupplier: Supplier<Context>,
    protected val activitySupplier: Supplier<Activity>,
    protected var notifyListenersFunction: EventNotifier,
    pluginLogTag: String,
    executorTag: String
) {
    protected val logTag: String = "$pluginLogTag|$executorTag"

    protected fun notifyListeners(eventName: String, data: JSObject, retainUntilConsumed: Boolean = false) {
        notifyListenersFunction.accept(eventName, data, retainUntilConsumed)
    }
}
