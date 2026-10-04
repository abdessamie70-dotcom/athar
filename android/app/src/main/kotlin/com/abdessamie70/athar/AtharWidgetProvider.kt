package com.abdessamie70.athar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews

class AtharWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.athar_widget_layout).apply {
                // Lasting minutes today
                val minutesText = prefs.getString("flutter.lasting_minutes", null)
                    ?: prefs.getString("lasting_minutes", "0 دقيقة")
                    ?: "0 دقيقة"
                setTextViewText(R.id.widget_lasting_minutes, minutesText)

                // Daily spiritual deed quote/idea
                val dailyQuote = prefs.getString("flutter.daily_quote", null)
                    ?: prefs.getString("daily_quote", "سقيا ماء أو بذل صدقة خفية أثر يمتد ولا ينقطع.")
                    ?: "سقيا ماء أو بذل صدقة خفية أثر يمتد ولا ينقطع."
                setTextViewText(R.id.widget_quote, dailyQuote)

                // Last updated timestamp
                val lastUpdated = prefs.getString("flutter.last_updated", null)
                    ?: prefs.getString("last_updated", "اليوم")
                    ?: "اليوم"
                setTextViewText(R.id.widget_last_updated, lastUpdated)

                // 1-Tap Voice Action shortcut via Deep Link (athar://voice_action)
                val voiceIntent = Intent(Intent.ACTION_VIEW, Uri.parse("athar://voice_action")).apply {
                    `package` = context.packageName
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val voicePendingIntent = PendingIntent.getActivity(
                    context,
                    101,
                    voiceIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_mic_btn, voicePendingIntent)

                // Main widget body opens the application
                val mainIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                if (mainIntent != null) {
                    val mainPendingIntent = PendingIntent.getActivity(
                        context,
                        102,
                        mainIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    setOnClickPendingIntent(R.id.widget_root, mainPendingIntent)
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
