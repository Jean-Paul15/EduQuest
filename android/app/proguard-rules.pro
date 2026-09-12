# Widget écran d'accueil : le provider natif et le plugin home_widget sont
# référencés uniquement via le manifeste / des method channels. Sans ces règles,
# une future activation de la minification les supprimerait et « Impossible de
# charger le widget » reviendrait.
-keep class edu.ruachnova.com.EduQuestHomeWidgetProvider { *; }
-keep class es.antonborri.home_widget.** { *; }

# La chaîne Glance / compose-remote n'est tirée qu'en transitif par home_widget
# et n'est jamais appelée par notre code ; on coupe seulement les avertissements.
-dontwarn androidx.glance.**
-dontwarn androidx.compose.remote.**
