package com.example.install_progress_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class ProgressReceiver(private val methodChannel: MethodChannel) : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val progress = intent.getIntExtra("progress", -1)
        Log.d("NLS_DEBUG", "Received progress: $progress")
        if (progress != -1) {
            // Flutterに進捗情報を送信
            methodChannel.invokeMethod("updateProgress", progress)
        }
        if (intent.action == "com.example.install_progress_app.COMPLETE_PROGRESS") {
            methodChannel.invokeMethod("completeProgress", null)
        }
        if (intent.action == "com.example.install_progress_app.CANCEL_PROGRESS") {
            methodChannel.invokeMethod("cancelProgress", null)
        }
    }
}
