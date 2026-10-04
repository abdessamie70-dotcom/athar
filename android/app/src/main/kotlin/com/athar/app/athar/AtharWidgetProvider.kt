package com.athar.app.athar

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class AtharWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.athar_widget_layout).apply {
                // Lasting minutes today
                val minutesText = widgetData.getString("lasting_minutes", "0 دقيقة") ?: "0 دقيقة"
                setTextViewText(R.id.widget_lasting_minutes, minutesText)

                // Daily spiritual deed quote/idea
                val dailyQuote = widgetData.getString(
                    "daily_quote",
                    "سقيا ماء أو بذل صدقة خفية أثر يمتد ولا ينقطع."
                ) ?: "سقيا ماء أو بذل صدقة خفية أثر يمتد ولا ينقطع."
                setTextViewText(R.id.widget_quote, dailyQuote)

                // Last updated timestamp
                val lastUpdated = widgetData.getString("last_updated", "اليوم") ?: "اليوم"
                setTextViewText(R.id.widget_last_updated, lastUpdated)

                // 1-Tap Voice Action shortcut via Deep Link (athar://voice_action)
                val voiceUri = Uri.parse("athar://voice_action")
                val voicePendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    voiceUri
                )
                setOnClickPendingIntent(R.id.widget_mic_btn, voicePendingIntent)

                // Main widget body opens the application
                val mainPendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, mainPendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
