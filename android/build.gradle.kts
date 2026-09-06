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
    // flutter_timezone (via cc_core's notifications module) compiles
    // Java at 11 but Kotlin at 1.8; raise ITS Kotlin target only
    // (the Back Forty Phase G finding, from the fleet ledger).
    if (name == "flutter_timezone") {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>()
            .configureEach {
                compilerOptions.jvmTarget
                    .set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
            }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
