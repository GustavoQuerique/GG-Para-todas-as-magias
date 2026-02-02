import 'dart:convert';
import 'package:http/http.dart' as http;

class DndApiService {
  Future<List<dynamic>> fetchSpells({
    String? className,
    String? school,
    int? level,
  }) async {
    final query = <String, String>{};

    if (className != null) query['class'] = className;
    if (school != null) query['school'] = school;
    if (level != null) query['level'] = level.toString();

    final uri = Uri.parse('$baseUrl/spells').replace(queryParameters: query);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Erro ao carregar magias');
    }
  }

  static const String baseUrl = 'https://www.dnd5eapi.co/api';

  Future<Map<String, dynamic>> fetchSpellsDetail(String index) async {
    final response = await http.get(
      Uri.parse('$baseUrl/spells/$index'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar detalhes da magia');
    }
  }
}
