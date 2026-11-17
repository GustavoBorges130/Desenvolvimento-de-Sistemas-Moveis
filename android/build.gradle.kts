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

// Compatibilidade com plugins antigos.
// O geocoding ^2.1.1 (versão pedida no desafio) usa o geocoding_android 3.x,
// que compila com o compileSdk 33. As bibliotecas AndroidX usadas pelo Flutter
// atual exigem compileSdk 34 ou maior, então as bibliotecas que estiverem
// abaixo do compileSdk do app passam a usar o mesmo valor dele.
// Precisa ficar antes do bloco com evaluationDependsOn(":app").
subprojects {
    afterEvaluate {
        val library = extensions.findByType(
            com.android.build.api.dsl.LibraryExtension::class.java,
        ) ?: return@afterEvaluate

        val appCompileSdk = rootProject.findProject(":app")
            ?.extensions
            ?.findByType(com.android.build.api.dsl.ApplicationExtension::class.java)
            ?.compileSdk
            ?: return@afterEvaluate

        if ((library.compileSdk ?: 0) < appCompileSdk) {
            library.compileSdk = appCompileSdk
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
