# SmartLight Enterprise — Fase 2

Base Flutter con:

- Material Design 3.
- Riverpod.
- GoRouter con navegación inferior stateful.
- Tema claro/oscuro persistido con SharedPreferencesAsync.
- Modelos principales del dominio.
- AreaRepository + MockAreaRepository.
- IoTRepository + MockIoTRepository.
- MockIoTService con 15 luces, 6 PIR y 6 sensores de luminosidad.
- Simulación desiredState -> reportedState.
- Dashboard, Áreas, detalle de área, Alertas, Automatizaciones y Más.

## Crear el proyecto completo

1. Ejecutar:
   flutter create smartlight_enterprise
2. Reemplazar `pubspec.yaml`, `analysis_options.yaml` y la carpeta `lib/` por los archivos de este paquete.
3. Ejecutar:
   flutter pub get
4. Ejecutar:
   flutter analyze
5. Ejecutar:
   flutter run

Requiere Flutter >= 3.44 y Dart >= 3.12 por las versiones seleccionadas de Riverpod y GoRouter.
