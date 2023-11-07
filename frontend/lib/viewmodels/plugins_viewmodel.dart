import 'package:auto_gpt_flutter_client/services/mindware_service.dart';
import 'package:flutter/material.dart';

class PluginsViewModel extends ChangeNotifier {
  final MindwareService mindwareService;

  PluginsViewModel(this.mindwareService);

  Future<List<dynamic>> getPlugins() async {
    final List<dynamic> plugins = await mindwareService.getPlugins();
    return plugins;
  }
}
