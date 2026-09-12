allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Force Kotlin a 17 sur TOUS les sous-projets, y compris les plugins
// Flutter tiers (home_widget, device_info_plus...) qui codent en dur des
// couples Java/Kotlin incoherents dans LEUR PROPRE build.gradle.
//
// Historique des echecs qui ont mene a cette solution :
// 1) Forcer Java a 17 pour ces modules (via `android.compileOptions` ou via
//    `tasks.withType<JavaCompile>().configureEach{}`) ECHOUE de maniere
//    fiable et reproductible : le plugin ecrit sa propre valeur (1.8) apres
//    coup dans son propre script, et gagne la course "dernier ecrit gagne".
// 2) A l'inverse, aligner Kotlin DYNAMIQUEMENT sur le Java (bas) de chaque
//    module (lu paresseusement) fonctionne pour la VALIDATION de coherence,
//    mais casse la COMPILATION reelle : le Kotlin de home_widget contient
//    un `inline fun` qui reference du bytecode d'une dependance compilee en
//    JVM target 11 (`HomeWidgetBackgroundWorker.kt`) -- impossible a
//    inliner dans du bytecode cible 1.8. Kotlin doit rester a une valeur
//    HAUTE, jamais suivre le Java bas d'un plugin tiers.
// Cote Kotlin, `tasks.withType<KotlinCompile>().configureEach{}` gagne de
// maniere fiable (execution differee, apres l'evaluation complete du
// script du sous-projet) -- donc on fixe Kotlin a 17 partout, et on laisse
// chaque module garder SON PROPRE Java (parfois 1.8, parfois 17) : la
// VALIDATION de coherence Java/Kotlin (un garde-fou, pas une vraie
// incompatibilite binaire) est desactivee via
// `kotlin.jvm.target.validation.mode=warning` dans gradle.properties.
subprojects {
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
