import 'package:auto_gpt_flutter_client/viewmodels/plugins_viewmodel.dart';
import 'package:flutter/material.dart';

class PluginsView extends StatelessWidget {
  final PluginsViewModel viewModel;

  const PluginsView({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        foregroundColor: Colors.black,
        title: const Text('Plugins'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: viewModel.getPlugins(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: ListView(
                      children: snapshot.data!
                          .map((plugin) => ListTile(
                                title: Text(plugin['name']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plugin['description'],
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, bottom: 5),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // TODO: Install plugin
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white),
                                        child: const Text('Install'),
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
