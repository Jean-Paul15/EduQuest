package edu.ruachnova.com

import android.content.SharedPreferences

/** Face « focus » du widget : puce + phrase + barre XP visible ou non. */
data class WidgetFocus(
    val kicker: String,
    val primary: String,
    val showXp: Boolean,
    val urgent: Boolean,
)

/**
 * Choisit la face de focus selon l'heure locale et l'urgence.
 * Ticket qui expire sous 3 jours -> priorité absolue. Sinon : le soir on met en
 * avant la série si elle est active, autrement la quête du jour, autrement la
 * progression vers le niveau suivant. La citation, elle, est toujours la 2e face
 * du fondu enchaîné.
 */
fun pickWidgetFocus(d: SharedPreferences, hour: Int): WidgetFocus {
    val ticketDays = d.getInt("w_ticket_days", -1)
    val ticketTier = d.getString("w_ticket_tier", "").orEmpty()
    if (ticketTier.isNotBlank() && ticketDays in 0..3) {
        val txt = if (ticketDays == 0) {
            "Ton ticket expire aujourd'hui"
        } else {
            "Ton ticket expire dans $ticketDays jour" + if (ticketDays > 1) "s" else ""
        }
        return WidgetFocus("Ticket $ticketTier", txt, showXp = false, urgent = true)
    }

    val questLabel = d.getString("w_quest_label", "").orEmpty()
    val questValue = d.getString("w_quest_value", "").orEmpty()
    val hasQuest = questLabel.isNotBlank() && questValue.isNotBlank()
    val streak = d.getInt("w_streak", 0)
    val level = d.getInt("w_level", 1)
    val xp = d.getInt("w_xp", 0).coerceIn(0, 100)

    val quest = WidgetFocus(questLabel, questValue, showXp = true, urgent = false)
    val progress = WidgetFocus(
        "Progression",
        "Niveau $level · plus que ${100 - xp} % pour le prochain",
        showXp = true,
        urgent = false,
    )
    val streakFocus = WidgetFocus(
        "Série",
        "$streak jour" + (if (streak > 1) "s" else "") + " d'affilée, continue !",
        showXp = true,
        urgent = false,
    )

    return when {
        hour in 18..22 && streak > 0 -> streakFocus
        hasQuest -> quest
        else -> progress
    }
}
