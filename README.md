# flutter_temporizer

Aplicación web de temporizador de entrenamiento (timer) de alto contraste en español, construida con Flutter.

## Características

✅ **Dos Modos de Configuración:**
- **Sets Fijos:** Configura un número específico de sets con los mismos tiempos de trabajo y descanso
- **Sets Variables:** Personaliza cada set individualmente con sus propios tiempos

✅ **Temporizador de Alto Contraste:**
- 🟣 Púrpura eléctrico (#6C63FF) durante el trabajo con gradiente dinámico
- 🔵 Turquesa vibrante (#4ECDC4) durante el descanso con gradiente relajante
- 🌸 Rosa fuerte (#FF6AB7) durante la pausa con gradiente llamativo
- 🌊 Azul océano (#45B7D1) al finalizar con gradiente de logro
- ✨ Efectos glassmorphism en botones y tarjetas
- 🎨 Gradientes suaves y sombras modernas tipo "Hello UI"

✅ **Funcionalidades Avanzadas:**
- Pausa y reanudación del entrenamiento
- Persistencia de estado (mantiene el progreso al cambiar de app)
- Ajuste dinámico del tiempo de descanso durante el entrenamiento
- Visualización del tiempo total de entrenamiento
- Contador de sets actual y total

✅ **Gestión de Estado:**
- Riverpod para state management
- SharedPreferences para persistencia local
- Soporte para ejecutar en segundo plano

## Instalación

```bash
# Clonar el repositorio (si aplica)
# git clone <repository-url>
# cd flutter_temporizer

# Instalar dependencias
flutter pub get
```

## Dependencias Principales

- `flutter_riverpod`: State management
- `shared_preferences`: Persistencia de estado local

## Uso de la Aplicación

### Configuración de Entrenamiento

1. **Selecciona el modo:**
   - **Sets Fijos:** Define número de sets y tiempos uniformes
   - **Sets Variables:** Crea sets personalizados con tiempos individuales

2. **Configura los tiempos:**
   - Tiempo de Trabajo (minutos y segundos)
   - Tiempo de Descanso (minutos y segundos)

3. **Presiona "COMENZAR ENTRENAMIENTO"**

### Durante el Entrenamiento

- **TRABAJO** (fondo púrpura con gradiente): Tiempo de ejercicio activo
- **DESCANSO** (fondo turquesa con gradiente): Tiempo de recuperación
- **Pausar:** Detén temporalmente el entrenamiento
- **Ajustar Descanso:** Durante el descanso, puedes modificar el tiempo restante
- **Reiniciar:** Vuelve a la configuración inicial

### Características Especiales

- El estado se guarda automáticamente (puedes cambiar de app sin perder el progreso)
- Se muestra el tiempo total transcurrido vs. tiempo total del entrenamiento
- Contador visual del set actual



## Development Commands

Below are useful commands and tips for developing this Flutter project locally (macOS). Wrap commands in a terminal inside the project root.

### General Flutter

- Install packages: `flutter pub get`
- Run on the default device: `flutter run`
- Hot reload / restart while running: press `r` (hot reload) or `R` (full restart) in the `flutter run` terminal
- Run in profile/release: `flutter run --profile` / `flutter run --release`
- Build APK / App Bundle:
	- `flutter build apk --split-per-abi`
	- `flutter build appbundle`
- Analyze & format:
	- `flutter analyze`
	- `flutter format .`
- List devices: `flutter devices`

### Web (Chrome) development

- Run on Chrome: `flutter run -d chrome`
- Run headless web server (access from other devices):
	- `flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0`
- Build web release: `flutter build web`

### Android Studio / Emulator (virtual device)

You can start Android virtual devices either from Android Studio (AVD Manager) or from the command line. Typical SDK paths on macOS are under `~/Library/Android/sdk`.

- Ensure SDK env vars (example for zsh):
	- ``export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"``
	- ``export PATH="$PATH:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools/bin"``

- List available AVDs (emulators):
	- `emulator -list-avds`
	- or `avdmanager list avd`
flu
- Start an emulator by name (runs in background):
  - `emulator -avd <AVD_NAME> &`
  - Example (explicit path): `"$ANDROID_SDK_ROOT"/emulator/emulator -avd Pixel_3a_API_30_x86 &`
  - The `&` runs it in the background, freeing your terminal

- Use Flutter's emulator helper (launches and detaches automatically):
  - `flutter emulators`                        # list emulators
  - `flutter emulators --launch <emulator_id>` # starts emulator in background

- List connected Android devices (including emulators): `adb devices`
  - Check if your emulator is already running before launching again (avoid "Running multiple emulators" error)
- Run the app on a specific device id: `flutter run -d <device-id>` (e.g. `emulator-5554`)

- Start Android Studio from terminal (macOS): `open -a "Android Studio"`

Notes:
- If `emulator` or `avdmanager` commands are not found, verify your `ANDROID_SDK_ROOT`/`ANDROID_HOME` and PATH.
- You can also manage and start AVDs from Android Studio → Tools → AVD Manager.
