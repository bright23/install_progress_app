package com.example.install_progress_app

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class NotificationServiceListener : NotificationListenerService() {
    companion object {
        var progress: Int = -1 // 進捗を格納する変数
        private const val TAG = "NLS_DEBUG" // 統一されたログタグ
        private var lastProgress: Int = -1 // 直前の進捗を保持する変数
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        Log.d(TAG, "Notification posted from package: ${sbn.packageName}")
        val notification: Notification = sbn.notification
        Log.d(TAG, "Notification: $notification")
        if (sbn.packageName == "com.android.vending") { // Google Playからの通知を処理
            Log.d(TAG, "Processing Google Play notification")
            val progressValue = extractProgress(notification)
            Log.d(TAG, "Progress extracted: $progressValue") // 抽出された進捗をログ出力
            if (progressValue != -1) {
                lastProgress = progressValue // 有効な進捗値があれば更新
                progress = progressValue
                Log.d(TAG, "Progress updated to: $progress") // 進捗値をログ出力
            } else {
                progress = lastProgress
                Log.d(TAG, "Using last known progress: $progress") // 最後の進捗値をログ出力
            }
            Log.d(TAG, "Extracted progress from notification: $progressValue") // デバッグ用ログ出力
            Log.d(TAG, "Updated progress: $progress") // デバッグ用ログ出力
        } else {
            Log.d(TAG, "Received notification from package: ${sbn.packageName}, not from Google Play")
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        Log.d(TAG, "Notification removed from package: ${sbn.packageName}")
    }

    private fun extractProgress(notification: Notification): Int {
        val extras = notification.extras
        Log.d(TAG, "Notification extras: $extras") // デバッグ用ログ出力
        for (key in extras.keySet()) {
            Log.d(TAG, "extras key: $key, value: ${extras.get(key)}") // すべてのキーと値をログに出力
        }
        val progress = extras.getInt(Notification.EXTRA_PROGRESS, -1)
        val maxProgress = extras.getInt(Notification.EXTRA_PROGRESS_MAX, 100) // デフォルト値を100に設定
        Log.d(TAG, "EXTRA_PROGRESS: $progress, EXTRA_PROGRESS_MAX: $maxProgress") // デバッグ用ログ出力
        if (progress != -1 && maxProgress > 0) {
            val percent = (progress.toFloat() / maxProgress * 100).toInt() // 進捗をパーセンテージで返す
            Log.d(TAG, "Calculated progress percent: $percent") // デバッグ用ログ出力
            return percent
        }
        Log.d(TAG, "No valid progress found in notification") // デバッグ用ログ出力
        return -1 // 進捗がない場合のデフォルト値
    }
}
