import 'package:flutter/material.dart';
import 'package:projeto_01_teste/pages_entregador/pedidos_realizados/pedidosRealizadosENT_api.dart';
import 'package:projeto_01_teste/pages_entregador/pedidos_realizados/pedidosRealizadosENT_bloc.dart';

import '../../model/entregas/entregas_modal.dart';
import 'pedidosRealizadosENT_ind.dart';

class PedidosRealizadosENTPage extends StatefulWidget {
  const PedidosRealizadosENTPage({super.key});

  @override
  State<PedidosRealizadosENTPage> createState() =>
      _PedidosRealizadosENTPageState();
}

class _PedidosRealizadosENTPageState extends State<PedidosRealizadosENTPage> {
  final PedidosRealizadosBlocENT _pedidosBloc = PedidosRealizadosBlocENT();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  Entregas? dadosEntregas;

  @override
  void initState() {
    super.initState();
    _pedidosBloc.fetchPedidoRealizados();
    _atualizaValor();
  }

  Future<void> _refreshData() async {
    await _pedidosBloc.fetchPedidoRealizados();
  }

  Future<void> atualizaPedidos() async {
    await _pedidosBloc.fetchPedidoRealizados(); // Atualize os dados dos pedidos
  }

  Future<void> _atualizaValor() async {
    try {
      Entregas dados = await PedidosRealizadosENTapi.ValorTotal();
      setState(() {
        dadosEntregas = dados;
      });
    } catch (e) {
      print('Erro ao obter os dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos de Entregas'),
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshData,
        child: StreamBuilder<List<Entregas>>(
          stream: _pedidosBloc.streamRealizados,
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
                  child: const Text('Suas entregas Realizadas:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 14.0, 0.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green, // Cor de fundo
                        borderRadius:
                            BorderRadius.circular(10.0), // Borda arredondada
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // Sombra
                          ),
                        ],
                      ),
                      child: Text(
                        'Valor Total: R\$${dadosEntregas?.valorTotal == null ? 'N/A' : (double.tryParse(dadosEntregas!.valorTotal!) ?? 0.0).toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(14.0, 16.0, 16.0, 0.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green, // Cor de fundo
                        borderRadius:
                            BorderRadius.circular(10.0), // Borda arredondada
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // Sombra
                          ),
                        ],
                      ),
                      child: Text(
                        'Valor Mês: R\$${dadosEntregas?.valorTotalMes == null ? 'N/A' : (double.tryParse(dadosEntregas!.valorTotalMes!) ?? 0.0).toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 18,
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
                              builder: (context) => PedidosRealizadosENTind(
                                entId: entrega.entId!,
                                status: entrega.entStatusAdmin!,
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
                                'ID do pedido:  ${entrega.entId.toString()}',
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
                                          backgroundColor: Colors.blue,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
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
