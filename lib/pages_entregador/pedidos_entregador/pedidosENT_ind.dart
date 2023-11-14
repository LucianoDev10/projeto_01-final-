import 'package:flutter/material.dart';
import 'package:projeto_01_teste/pages_entregador/pedidos_entregador/pedidosENT_api.dart';

import '../../model/entregas/entregas_modal.dart';
import '../../model/entregas/rotas_modal.dart';
import 'pedidosENT_pagamento.dart';

class PedidosENTind extends StatefulWidget {
  final int entId;
  final String status;
  final Function() atualizarPedidos;

  PedidosENTind({
    Key? key,
    required this.entId,
    required this.status,
    required this.atualizarPedidos,
  }) : super(key: key);

  @override
  _PedidosENTindState createState() => _PedidosENTindState();
}

class _PedidosENTindState extends State<PedidosENTind> {
  late Future<Entregas?> _pedidoDetails;
  final PedidosENTapi apiService = PedidosENTapi();

  @override
  void initState() {
    super.initState();
    _pedidoDetails = PedidosENTapi.getPedidoIndividual(widget.entId);
  }

  Future<void> _refreshData() async {
    _pedidoDetails = PedidosENTapi.getPedidoIndividual(widget.entId);
  }

  Future<void> atualizarPedidos() async {
    _pedidoDetails = PedidosENTapi.getPedidoIndividual(widget.entId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da entrega'),
      ),
      body: FutureBuilder<Entregas?>(
        future: _pedidoDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (!snapshot.hasData) {
            return const Text('Nenhum detalhe encontrado');
          } else {
            Entregas detalhes = snapshot.data!;

            return Column(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                      child: const Text(
                        "Informações sobre a entrega:",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // Cor de fundo
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black), // Estilo do texto fixo
                              children: [
                                const TextSpan(
                                  text: 'ID do pedido: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight
                                          .bold), // Estilo do texto fixo
                                ),
                                TextSpan(
                                  text: detalhes.entId.toString(), // Variável
                                  style: const TextStyle(
                                      fontWeight: FontWeight
                                          .normal), // Estilo da variável
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black), // Estilo do texto fixo
                              children: [
                                const TextSpan(
                                  text: 'CEP: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight
                                          .bold), // Estilo do texto fixo
                                ),
                                TextSpan(
                                  text: detalhes.usuCep, // Variável
                                  style: const TextStyle(
                                      fontWeight: FontWeight
                                          .normal), // Estilo da variável
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          RichText(
                            text: TextSpan(
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                              children: <TextSpan>[
                                const TextSpan(
                                  text: 'Rua: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: detalhes.usuEndereco ?? 'N/A',
                                ),
                                TextSpan(
                                  text: ', ${detalhes.usuNumero ?? 'N/A'}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black), // Estilo do texto fixo
                              children: [
                                const TextSpan(
                                  text: 'Nome do cliente: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight
                                          .bold), // Estilo do texto fixo
                                ),
                                TextSpan(
                                  text: detalhes.usuNome, // Variável
                                  style: const TextStyle(
                                      fontWeight: FontWeight
                                          .normal), // Estilo da variável
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black), // Estilo do texto fixo
                              children: [
                                const TextSpan(
                                  text: 'Telefone do cliente: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight
                                          .bold), // Estilo do texto fixo
                                ),
                                TextSpan(
                                  text: detalhes.usuTelefone, // Variável
                                  style: const TextStyle(
                                      fontWeight: FontWeight
                                          .normal), // Estilo da variável
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black), // Estilo do texto fixo
                              children: [
                                TextSpan(
                                  text: 'Status do supermercado: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight
                                          .bold), // Estilo do texto fixo
                                ),
                                TextSpan(
                                  text: 'Despachado',
                                  style: TextStyle(
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
                  ],
                )),
                Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 8, 12, 16),
                  color: Colors.white,
                  // Defina a cor de fundo desejada
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Clique para saber os valores:',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight
                              .bold, // Pode ser FontWeight.bold para negrito, se desejar
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final sucess = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PedidosENTpag(
                                usuarioCep: detalhes.usuCep!,
                                pedidoId: detalhes.entId!,
                                atualizarPedidos: widget.atualizarPedidos,
                              ),
                            ),
                          );
                          if (sucess == true) {
                            await _refreshData();
                          }
                        },
                        child: const Text(
                          'Aceitar Entrega',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight
                                .bold, // Pode ser FontWeight.bold para negrito, se desejar
                            // Cor do texto
                            // Outras propriedades de estilo de fonte podem ser adicionadas aqui
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
