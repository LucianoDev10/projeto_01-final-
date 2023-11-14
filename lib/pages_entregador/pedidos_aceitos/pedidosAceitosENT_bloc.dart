import 'dart:async';

import 'package:projeto_01_teste/pages_entregador/pedidos_aceitos/pedidoAceitosENT_api.dart';

import '../../model/entregas/entregas_modal.dart';

class PedidosAceitosBlocENT {
  final _streamControllerPedidosAceitos =
      StreamController<List<Entregas>>.broadcast();
  Stream<List<Entregas>> get streamPedidos =>
      _streamControllerPedidosAceitos.stream;

  fetchPedidoAceitos() async {
    try {
      List<Entregas> teste = await PedidosAceitosENTapi.getPedidosAceitos();
      _streamControllerPedidosAceitos.add(teste);
    } catch (e) {
      _streamControllerPedidosAceitos.addError(e);
    }
  }

  void dispose() {
    _streamControllerPedidosAceitos.close();
  }
}
