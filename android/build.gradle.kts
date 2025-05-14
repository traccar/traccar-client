allprojects {
    ext {
        set("appCompatVersion", "1.7.0")
        set("playServicesLocationVersion", "21.3.0")
        // Test logging crash
        set("logbackVersion", "1.3.0-3")
        set("slf4jVersion", "1.7.25")
    }
    repositories {
        google()
        mavenCentral()
        // [required] background_geolocation
        maven(url = "${project(":flutter_background_geolocation").projectDir}/libs")
        // [required] background_fetch
        maven(url = "${project(":background_fetch").projectDir}/libs")
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
