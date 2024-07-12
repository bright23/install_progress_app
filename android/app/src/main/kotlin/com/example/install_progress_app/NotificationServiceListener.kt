package com.example.install_progress_app

import android.app.Notification
import android.content.Context
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class NotificationServiceListener : NotificationListenerService() {
    companion object {
        var progress: Int = -1
        private const val TAG = "NLS_DEBUG"
        private var lastProgress: Int = -1

        fun startService(context: Context) {
            val intent = Intent(context, NotificationServiceListener::class.java)
            context.startService(intent)
        }

        fun stopService(context: Context) {
            val intent = Intent(context, NotificationServiceListener::class.java)
            context.stopService(intent)
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        Log.d(TAG, "Notification posted from package: ${sbn.packageName}")
        val notification: Notification = sbn.notification
        if (sbn.packageName == "com.android.vending") {
            val progressValue = extractProgress(notification)
            if (progressValue != -1) {
                lastProgress = progressValue
                progress = progressValue
                Log.d(TAG, "Progress updated to: $progress")
                if (progress >= 100) {
                    completeInstallation()
                }
            } else {
                progress = lastProgress
                Log.d(TAG, "Using last known progress: $progress")
            }
            Log.d(TAG, "Extracted progress: $progressValue")
        } else {
            Log.d(TAG, "Received notification from package: ${sbn.packageName}, not from Google Play")
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        Log.d(TAG, "Notification removed from package: ${sbn.packageName}")
    }

    private fun extractProgress(notification: Notification): Int {
        val extras = notification.extras
        val progress = extras.getInt(Notification.EXTRA_PROGRESS, -1)
        val maxProgress = extras.getInt(Notification.EXTRA_PROGRESS_MAX, 100)
        if (progress != -1 && maxProgress > 0) {
            return (progress.toFloat() / maxProgress * 100).toInt()
        }
        return -1
    }

    private fun completeInstallation() {
        Log.d(TAG, "Installation completed.")
        sendMessageToFlutter("completeProgress")
    }

    private fun sendMessageToFlutter(method: String) {
        val flutterEngine = FlutterEngine(this)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.install_progress_app/progress")
        channel.invokeMethod(method, null)
    }
}
