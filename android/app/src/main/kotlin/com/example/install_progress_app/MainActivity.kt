package com.example.install_progress_app

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.install_progress_app/progress"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getProgress") {
                val progress = NotificationServiceListener.progress
                result.success(progress)
            }
        }
    }
}

class NotificationServiceListener : NotificationListenerService() {
    companion object {
        var progress: Int = -1
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val notification: Notification = sbn.notification
        // ここでインストール進捗を解析
        val progressValue = extractProgress(notification)
        progress = progressValue
    }

    private fun extractProgress(notification: Notification): Int {
        // 通知からインストール進捗を抽出するロジック
        val extras = notification.extras
        if (extras.containsKey(Notification.EXTRA_PROGRESS)) {
            return extras.getInt(Notification.EXTRA_PROGRESS)
        }
        return -1 // 仮の値、実際の進捗を返すように実装
    }
}
