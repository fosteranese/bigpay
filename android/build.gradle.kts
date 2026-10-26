allprojects {
    repositories {
        google()
        mavenCentral()
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

// tflite_flutter (pulled in transitively by kyc_face_capture, added for the
// KYC face-capture step) doesn't pin its own Kotlin JVM target, so it
// defaults to a different JDK release than its own Java compile tasks
// (Java 17, Kotlin 21) and fails with "Inconsistent JVM Target Compatibility
// Between Java and Kotlin Tasks". Scoped to just this module — other plugins
// with the same warning (flutter_udid, freerasp, flutter_libphonenumber_android)
// already build fine on their own settings; a blanket override broke
// flutter_udid's (deliberately older, Java 11) target instead of fixing
// anything.
subprojects {
    if (project.name == "tflite_flutter") {
        plugins.withId("org.jetbrains.kotlin.android") {
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
