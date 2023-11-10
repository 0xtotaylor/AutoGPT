import 'package:auto_gpt_flutter_client/viewmodels/plugins_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PluginsView extends StatelessWidget {
  final PluginsViewModel viewModel;

  const PluginsView({Key? key, required this.viewModel}) : super(key: key);

  void _launchURL(String urlString) async {
    var url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

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
                                      child: Row(
                                        children: [
                                          if (viewModel.installedPlugin !=
                                              plugin['link'])
                                            ElevatedButton(
                                              onPressed: () {
                                                viewModel.installPlugin(
                                                    plugin['link']);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  foregroundColor:
                                                      Colors.white),
                                              child: const Text('Install'),
                                            ),
                                          if (viewModel.installedPlugin ==
                                              plugin['link'])
                                            ElevatedButton(
                                              onPressed: () {
                                                viewModel.installPlugin(
                                                    plugin['link']);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor:
                                                      Colors.white),
                                              child: const Text('Uninstall'),
                                            ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              _launchURL(plugin['link']);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey,
                                                foregroundColor: Colors.white),
                                            child: const Text('Details'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (viewModel.installedPlugin ==
                                        plugin['link'])
                                      Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, bottom: 5),
                                        child: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Plugin Installed',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green),
                                            ),
                                            Text(
                                              'Add required environment variables and restart AutoGPT for the changes to take effect',
                                              style: TextStyle(fontSize: 12),
                                            )
                                          ],
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
