import 'dart:async';

import 'package:projeto_01_teste/pages_entregador/pedidos_entregador/pedidosENT_api.dart';

import '../../model/entregas/entregas_modal.dart';

class PedidosBlocENT {
  final _streamControllerPedidos = StreamController<List<Entregas>>.broadcast();
  Stream<List<Entregas>> get streamNotDestaque =>
      _streamControllerPedidos.stream;

  fetchPedidos() async {
    try {
      List<Entregas> pedidos = await PedidosENTapi.getPedidos();
      _streamControllerPedidos.add(pedidos);
    } catch (e) {
      _streamControllerPedidos.addError(e);
    }
  }

  void dispose() {
    _streamControllerPedidos.close();
  }
}
