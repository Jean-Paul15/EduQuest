package com.tgeduquest.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class EduQuestHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.eduquest_home_widget).apply {
                val title = widgetData.getString("eduquest_title", "RuachNova") ?: "RuachNova"
                val focusLabel = widgetData.getString("eduquest_focus_label", "Niveau") ?: "Niveau"
                val focusValue = widgetData.getString("eduquest_focus_value", "-") ?: "-"
                val footer = widgetData.getString("eduquest_footer", "") ?: ""
                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_focus_label, focusLabel)
                setTextViewText(R.id.widget_focus_value, focusValue)
                setTextViewText(R.id.widget_footer, footer)
                setViewVisibility(R.id.widget_footer, if (footer.isBlank()) View.GONE else View.VISIBLE)
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
