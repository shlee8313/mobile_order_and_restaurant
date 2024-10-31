// package com.example.mobile_order


// class MainActivity: FlutterActivity()


package com.example.mobile_order

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.os.Build
import android.os.Bundle
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import androidx.core.app.NotificationCompat
import java.io.File

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val soundPath = "${android.os.Environment.getExternalStorageDirectory()}/raw/ding_dong.mp3"
                val soundFile = File(soundPath)
                val soundUri = android.net.Uri.fromFile(soundFile)
                
                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()

                val channel = NotificationChannel(
                    "order_ready_channel",
                    "Order Notifications",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "This channel is used for order notifications."
                    setSound(soundUri, audioAttributes)
                    enableVibration(true)
                    enableLights(true)
                }

                val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.createNotificationChannel(channel)
                
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}