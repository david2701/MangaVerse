// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:device_info_plus/src/device_info_plus_web.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:pdf_render/src/web/pdf_render_web_plugin.dart';
import 'package:pdfx/src/renderer/web/pdfx_plugin.dart';
import 'package:permission_handler_html/permission_handler_html.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  DeviceInfoPlusWebPlugin.registerWith(registrar);
  FilePickerWeb.registerWith(registrar);
  ImagePickerPlugin.registerWith(registrar);
  PdfRenderWebPlugin.registerWith(registrar);
  PdfxPlugin.registerWith(registrar);
  WebPermissionHandler.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
