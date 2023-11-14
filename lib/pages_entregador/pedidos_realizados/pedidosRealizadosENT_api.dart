import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projeto_01_teste/model/usuarios/usuario2_model.dart';

import '../../model/entregas/entregas_modal.dart';
import '../../utils/url.dart';

class PedidosRealizadosENTapi {
  static Future<List<Entregas>> getPedidosRealizados() async {
    var user = await Usuario2.get();
    var url = ('$apiUrl/entregas/entregador/entregasRealizadas/${user!.usuId}');
    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 401) {
        print('Erro 401: Não autorizado');
        return []; // Retorna uma lista vazia em caso de erro
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['response'];

        List<Entregas> produtosList = List<Entregas>.from(
            data.map((produto) => Entregas.fromJson(produto)));

        return produtosList;
      }

      print('Erro ${response.statusCode}: ${response.reasonPhrase}');
      return []; // Retorna uma lista vazia em caso de erro
    } catch (e) {
      print('Erro na requisição: $e');
      return []; // Retorna uma lista vazia em caso de exceção
    }
  }

  static Future<Entregas> ValorTotal() async {
    var user = await Usuario2.get();
    var url = ('$apiUrl/entregas/entregador/ValorTotal/${user!.usuId}');
    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 401) {
        print('Erro 401: Não autorizado');
        throw Exception('Erro 401: Não autorizado');
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        Map<String, dynamic> data = jsonResponse['response'];

        Entregas dadosEntregas = Entregas.fromJson(data);

        return dadosEntregas;
      }

      print('Erro ${response.statusCode}: ${response.reasonPhrase}');
      throw Exception('Erro na requisição: ${response.statusCode}');
    } catch (e) {
      print('Erro na requisição: $e');
      throw Exception('Erro na requisição: $e');
    }
  }
}
