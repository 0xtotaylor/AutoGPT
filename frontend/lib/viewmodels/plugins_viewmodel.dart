import 'package:auto_gpt_flutter_client/services/plugin_service.dart';
import 'package:auto_gpt_flutter_client/services/task_service.dart';
import 'package:flutter/material.dart';

class PluginsViewModel extends ChangeNotifier {
  final PluginService pluginService;
  final TaskService taskService;
  String installedPlugin = '';

  PluginsViewModel(this.pluginService, this.taskService);

  Future<List<dynamic>> getPlugins() async {
    final List<dynamic> plugins = await pluginService.getPlugins();
    return plugins;
  }

  Future installPlugin(String pluginUrl) async {
    await taskService.installPlugin(pluginUrl);
    installedPlugin = pluginUrl;
    notifyListeners();
  }
}
