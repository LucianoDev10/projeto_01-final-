import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/entregas/entregas_modal.dart';
import '../../model/entregas/rotas_modal.dart';
import '../../model/usuarios/usuario2_model.dart';
import '../../utils/url.dart';

//    PEGAR O USUARIO var user = await Usuario2.get();

class PedidosENTapi {
  static Future<List<Entregas>> getPedidos() async {
    var url = ('$apiUrl/entregas/entregador');
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
        print(data);

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

  static Future<Entregas?> getPedidoIndividual(int entId) async {
    var url = ('$apiUrl/entregas/entregador/entregaInd/$entId');
    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 401) {
        print('Erro 401: Não autorizado');
        return null; // Retorna null em caso de erro
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        Map<String, dynamic> data =
            jsonResponse['response'][0]; // Obtenha o primeiro objeto no array

        print(data);

        Entregas entrega = Entregas.fromJson(data);

        return entrega;
      }

      print('Erro ${response.statusCode}: ${response.reasonPhrase}');
      return null; // Retorna null em caso de erro
    } catch (e) {
      print('Erro na requisição: $e');
      return null; // Retorna null em caso de exceção
    }
  }

  static Future<Rota?> calcularRota(String segundoEndereco) async {
    final url = '$apiUrl/frete';
    var user = await Usuario2.get();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, String> queryParameters = {
      'PrimeiroEndereco': user!.cep ?? "",
      'SegundoEndereco': segundoEndereco,
    };

    try {
      String requestBodyJson = json.encode(queryParameters);
      final response = await http.post(Uri.parse(url),
          body: requestBodyJson, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Rota.fromJson(jsonResponse);
      } else {
        print('Erro ${response.statusCode}: ${response.reasonPhrase}');
        // Retorna uma instância vazia de Rota em caso de erro
        return Rota(distance: null, price: null, mapUrl: null);
      }
    } catch (e) {
      print('Erro na requisição: $e');
      // Retorna uma instância vazia de Rota em caso de exceção
      return Rota(distance: null, price: null, mapUrl: null);
    }
  }

  Future<Map<String, dynamic>> aceitarEntrega(
      int pedidoId, int minutos, int frete) async {
    var user = await Usuario2.get();
    final String url =
        '$apiUrl/entregas/dados/$pedidoId/${user!.usuId}/$minutos/$frete';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, int> params = {
      'ped_id': pedidoId,
      'usu_id': user.usuId!, //verificar se da pau
      'ent_minutos': minutos,
      'ent_valorFrete': frete,
    };

    try {
      String requestBodyJson = json.encode(params);
      final response = await http.post(Uri.parse(url),
          body: requestBodyJson, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        print('Erro ${response.statusCode}: ${response.reasonPhrase}');
        return {
          'mensagem': 'Erro na requisição',
          'pedido': null,
        };
      }
    } catch (e) {
      print('Erro na requisição: $e');
      return {
        'mensagem': 'Erro na requisição',
        'pedido': null,
      };
    }
  }
}
