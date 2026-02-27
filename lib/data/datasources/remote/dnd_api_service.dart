import 'dart:convert';
import 'package:guia_de_garlou_para_todas_as_magias/models/dnd_class.dart';
import 'package:http/http.dart' as http;

class DndApiService {
  static const String baseUrl = 'https://www.dnd5eapi.co/api';

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

  Future<List<DndClass>> fetchClasses() async {
    final response = await http.get(Uri.parse("$baseUrl/classes"));

    final data = jsonDecode(response.body);
    final List results = data["results"];

    return results.map((item) {
      return DndClass(
        index: item["index"],
        name: item["name"],
      );
    }).toList();
  }

  Future<List<dynamic>> fetchLevelsForClass(String classIndex) async {
    final response = await http.get(
      Uri.parse("$baseUrl/classes/$classIndex/levels"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao carregar níveis da classe");
    }
  }
}
