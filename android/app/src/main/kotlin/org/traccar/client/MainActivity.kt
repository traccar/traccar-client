package org.traccar.client

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "org.traccar.client/intent"

    private fun handleIntent(action: String?) {
        if (action == null) return
        val engine = flutterEngine ?: return
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
            .invokeMethod("action", action)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent?.action)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent.action)
    }
}
