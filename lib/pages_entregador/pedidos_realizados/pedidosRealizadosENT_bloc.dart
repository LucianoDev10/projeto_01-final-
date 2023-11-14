import 'dart:async';

import 'package:projeto_01_teste/pages_entregador/pedidos_realizados/pedidosRealizadosENT_api.dart';

import '../../model/entregas/entregas_modal.dart';

class PedidosRealizadosBlocENT {
  final _streamControllerPedidosRealizados =
      StreamController<List<Entregas>>.broadcast();
  Stream<List<Entregas>> get streamRealizados =>
      _streamControllerPedidosRealizados.stream;

  fetchPedidoRealizados() async {
    try {
      List<Entregas> teste =
          await PedidosRealizadosENTapi.getPedidosRealizados();
      _streamControllerPedidosRealizados.add(teste);
    } catch (e) {
      _streamControllerPedidosRealizados.addError(e);
    }
  }

  void dispose() {
    _streamControllerPedidosRealizados.close();
  }
}
