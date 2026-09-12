package edu.ruachnova.com

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import java.util.Calendar

/**
 * Widget écran d'accueil RuachEdu. `AppWidgetProvider` autonome : aucune
 * dépendance native au plugin `home_widget` (dont la chaîne Glance /
 * compose-remote-beta faisait échouer le chargement). On lit simplement le
 * `SharedPreferences` que le plugin écrit côté Dart et on compose des
 * `RemoteViews`. Contenu contextuel selon l'heure ; fondu focus <-> citation
 * assuré par le `ViewFlipper` du layout.
 *
 * Couleurs clair/sombre : uniquement via `@color/ruach_w_*` (values / values-night)
 * référencés dans le layout — jamais posées ici par `setTextColor`. Le lanceur
 * résout alors texte ET fond par le même chemin au même instant, ce qui évite la
 * désynchro qui rendait le widget illisible après un changement de thème sans
 * rouvrir l'app.
 */
class EduQuestHomeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, mgr: AppWidgetManager, ids: IntArray) {
        val d = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val views = render(context, d)
        for (id in ids) mgr.updateAppWidget(id, views)
    }

    private fun render(context: Context, d: SharedPreferences): RemoteViews {
        val v = RemoteViews(context.packageName, R.layout.ruach_home_widget)
        val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)

        val name = d.getString("w_name", "").orEmpty()
        val greet = when {
            hour < 12 -> "Bonjour"
            hour < 18 -> "Bon après-midi"
            else -> "Bonsoir"
        }
        v.setTextViewText(R.id.w_greeting, if (name.isBlank()) greet else "$greet, $name")

        val streak = d.getInt("w_streak", 0)
        v.setViewVisibility(R.id.w_streak, if (streak > 0) View.VISIBLE else View.GONE)
        v.setTextViewText(R.id.w_streak, "🔥 $streak")

        val focus = pickWidgetFocus(d, hour)
        v.setTextViewText(R.id.w_kicker, focus.kicker)
        v.setTextViewText(R.id.w_primary, focus.primary)
        v.setViewVisibility(R.id.w_xp_row, if (focus.showXp) View.VISIBLE else View.GONE)
        v.setProgressBar(R.id.w_xp, 100, d.getInt("w_xp", 0).coerceIn(0, 100), false)
        v.setTextViewText(R.id.w_xp_hint, d.getString("w_xp_label", "").orEmpty())

        val quote = d.getString("w_quote", "").orEmpty()
        val author = d.getString("w_quote_author", "").orEmpty()
        v.setTextViewText(R.id.w_quote, if (quote.isBlank()) "" else "« $quote »")
        v.setTextViewText(R.id.w_quote_author, if (author.isBlank()) "" else "— $author")

        val startOnQuote = !focus.urgent && (hour in 11..13 || hour >= 22 || hour < 5)
        v.setDisplayedChild(R.id.w_flipper, if (startOnQuote) 1 else 0)

        v.setOnClickPendingIntent(R.id.w_root, openApp(context))
        return v
    }

    private fun openApp(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).setPackage(context.packageName)
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }
}
