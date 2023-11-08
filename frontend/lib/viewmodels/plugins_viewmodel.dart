import 'package:auto_gpt_flutter_client/services/plugin_service.dart';
import 'package:flutter/material.dart';

class PluginsViewModel extends ChangeNotifier {
  final PluginService pluginService;

  PluginsViewModel(this.pluginService);

  Future<List<dynamic>> getPlugins() async {
    final List<dynamic> plugins = await pluginService.getPlugins();
    return plugins;
  }
}
