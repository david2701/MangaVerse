// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: ListTile(
        title: Text('Modo Oscuro'),
        trailing: Switch(
          value: isDarkMode,
          onChanged: (val) {
            ref.read(settingsProvider.notifier).toggleDarkMode(val);
          },
        ),
      ),
    );
  }
}