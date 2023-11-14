import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projeto_01_teste/model/usuarios/usuario2_model.dart';

import '../../model/entregas/entregas_modal.dart';
import '../../utils/url.dart';

class PedidosAceitosENTapi {
  static Future<List<Entregas>> getPedidosAceitos() async {
    var user = await Usuario2.get();
    var url = ('$apiUrl/entregas/entregador/entregasAceitas/${user!.usuId}');
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

  static Future<Entregas> getPedidoInd(int entId) async {
    final url = Uri.parse('$apiUrl/entregas/entregador/entregasInd/$entId');

    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 401) {
        print('Erro 401: Não autorizado');
        throw Exception('Erro 401: Não autorizado');
      } else if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.isNotEmpty) {
          Entregas entrega = Entregas.fromJson(jsonResponse['response'][0]);
          return entrega;
        } else {
          throw Exception('Resposta JSON inválida: não há dados de entrega');
        }
      } else {
        print('Erro ${response.statusCode}: ${response.reasonPhrase}');
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
      throw Exception('Erro na requisição: $e');
    }
  }

  Future<bool?> PedidoRealizado(int entregaId) async {
    var url = ('$apiUrl/entregas/entregador/realizada/$entregaId');

    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    try {
      var response = await http.post(Uri.parse(url), headers: headers);
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 401) {
        print('Erro 401: Não autorizado');
        return false; // Retorna uma lista vazia em caso de erro
      }
      if (response.statusCode == 400) {
        print('O pedido já está encerrado');
        return false; // Retorna uma lista vazia em caso de erro
      }
      if (response.statusCode == 200) {
        return true;
      }

      print('Erro ${response.statusCode}: ${response.reasonPhrase}');
      return false; // Retorna uma lista vazia em caso de erro
    } catch (e) {
      print('Erro na requisição: $e');
      return false; // Retorna uma lista vazia em caso de exceção
    }
  }
}
