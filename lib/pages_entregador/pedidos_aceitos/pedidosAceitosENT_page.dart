import 'package:flutter/material.dart';
import 'package:projeto_01_teste/pages_entregador/pedidos_aceitos/pedidosAceitosENT_bloc.dart';
import 'package:projeto_01_teste/pages_entregador/pedidos_aceitos/pedidosAceitosENT_ind.dart';

import '../../model/entregas/entregas_modal.dart';
import '../pedidos_entregador/pedidosENT_ind.dart';

class PedidosAceitosENTPage extends StatefulWidget {
  const PedidosAceitosENTPage({super.key});

  @override
  State<PedidosAceitosENTPage> createState() => _PedidosAceitosENTPageState();
}

class _PedidosAceitosENTPageState extends State<PedidosAceitosENTPage> {
  final PedidosAceitosBlocENT _pedidosBloc = PedidosAceitosBlocENT();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _pedidosBloc.fetchPedidoAceitos();
  }

  Future<void> _refreshData() async {
    await _pedidosBloc.fetchPedidoAceitos();
  }

  Future<void> atualizaPedidos() async {
    await _pedidosBloc.fetchPedidoAceitos(); // Atualize os dados dos pedidos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos de Entregas'),
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshData,
        child: StreamBuilder<List<Entregas>>(
          stream: _pedidosBloc.streamPedidos,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            List<Entregas> entregas = snapshot.data!;

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                  child: const Text(
                      'Suas entregas aceitas que estão em andamento:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: entregas.length,
                    itemBuilder: (context, index) {
                      Entregas entrega = entregas[index];
                      return GestureDetector(
                        onTap: () async {
                          final success = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PedidosAceitosENTind(
                                entId: entrega.entId!,
                                status: entrega.entStatusEntregador!,
                                atualizarPedidos: atualizaPedidos,
                              ),
                            ),
                          );
                          if (success == true) {
                            await _refreshData();
                          }
                        },
                        child: Container(
                          margin:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white, // Cor de fundo
                            borderRadius: BorderRadius.circular(
                                10.0), // Borda arredondada
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3), // Sombra
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID da entrega:  ${entrega.entId.toString()}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Status: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors
                                              .black), // Estilo para o texto "Status: "
                                    ),
                                    TextSpan(
                                      text: entrega.entStatusEntregador,
                                      style: const TextStyle(
                                          color: Colors
                                              .white, // Estilo para o valor da variável "Status"
                                          fontWeight: FontWeight.bold,
                                          backgroundColor: Colors.green,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
