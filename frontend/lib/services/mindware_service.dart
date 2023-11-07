import 'package:auto_gpt_flutter_client/models/benchmark/api_type.dart';
import 'package:auto_gpt_flutter_client/utils/rest_api_utility.dart';

class MindwareService {
  final RestApiUtility api;

  MindwareService(this.api);

  Future<dynamic> getPlugins() async {
    try {
      return await api.get(
        'api/plugins/autogpt',
        apiType: ApiType.mindware,
      );
    } catch (e) {
      throw Exception('Failed to get plugins from Mindware: $e');
    }
  }
}
