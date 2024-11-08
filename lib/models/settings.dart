// lib/models/settings.dart
class Settings {
  bool isDarkMode;

  Settings({this.isDarkMode = false});

  // Método para convertir Settings a Map
  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
    };
  }

  // Método para crear Settings desde Map
  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      isDarkMode: map['isDarkMode'] ?? false,
    );
  }
}