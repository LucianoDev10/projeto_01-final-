import 'package:flutter/material.dart';

import '../../model/entregas/entregas_modal.dart';
import '../pedidos_aceitos/pedidoAceitosENT_api.dart';

class PedidosRealizadosENTind extends StatefulWidget {
  final int entId;
  final String status;
  final Function() atualizarPedidos;

  PedidosRealizadosENTind({
    Key? key,
    required this.entId,
    required this.status,
    required this.atualizarPedidos,
  }) : super(key: key);

  @override
  _PedidosRealizadosENTindState createState() =>
      _PedidosRealizadosENTindState();
}

class _PedidosRealizadosENTindState extends State<PedidosRealizadosENTind> {
  late Future<Entregas?> _pedidoDetails;
  final PedidosAceitosENTapi apiService = PedidosAceitosENTapi();

  @override
  void initState() {
    super.initState();
    _pedidoDetails = PedidosAceitosENTapi.getPedidoInd(widget.entId);
  }

  Future<void> _refreshData() async {
    _pedidoDetails = PedidosAceitosENTapi.getPedidoInd(widget.entId);
  }

  Future<void> atualizarPedidos() async {
    _pedidoDetails = PedidosAceitosENTapi.getPedidoInd(widget.entId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Pedido'),
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
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                      child: const Text(
                        "Produtos a serem entregues:",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                    Expanded(
                        child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          margin:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
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
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color:
                                          Colors.black), // Estilo do texto fixo
                                  children: [
                                    const TextSpan(
                                      text: 'ID do pedido: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight
                                              .bold), // Estilo do texto fixo
                                    ),
                                    TextSpan(
                                      text:
                                          detalhes.entId.toString(), // Variável
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
                                      color:
                                          Colors.black), // Estilo do texto fixo
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
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal),
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
                                      color:
                                          Colors.black), // Estilo do texto fixo
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
                                      color:
                                          Colors.black), // Estilo do texto fixo
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
                            ],
                          ),
                        ),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.fromLTRB(
                                16.0, 16.0, 16.0, 0.0),
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
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors
                                            .black), // Estilo do texto fixo
                                    children: [
                                      const TextSpan(
                                        text: 'Valor da corrida: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight
                                                .bold), // Estilo do texto fixo
                                      ),
                                      TextSpan(
                                        text:
                                            'R\$ ${detalhes.entValorFrete!.toDouble()}', // Variável
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20), // Estilo da variável
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        color: Colors
                                            .black), // Estilo do texto fixo
                                    children: [
                                      const TextSpan(
                                        text: 'Tempo da corrida: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                16), // Estilo do texto fixo
                                      ),
                                      TextSpan(
                                        text:
                                            '${detalhes.entHoras}', // Variável
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 18), // Estilo da variável
                                      ),
                                      const TextSpan(
                                        text: ' min', // Variável
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 18), // Estilo da variável
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight
                                            .bold), // Estilo do texto fixo
                                    children: [
                                      const TextSpan(
                                        text: 'Status: ',
                                        style: TextStyle(
                                            color: Colors
                                                .black), // Estilo para o texto "Status: "
                                      ),
                                      TextSpan(
                                        text: detalhes.entStatusEntregador,
                                        style: const TextStyle(
                                            color: Colors
                                                .white, // Estilo para o valor da variável "Status"
                                            fontWeight: FontWeight.bold,
                                            backgroundColor: Colors.amberAccent,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text('ID´s dos registros',
                            textAlign: TextAlign.start),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            margin:
                                const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
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
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors
                                            .black), // Estilo do texto fixo
                                    children: [
                                      const TextSpan(
                                        text: 'ID do pedido: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight
                                                .bold), // Estilo do texto fixo
                                      ),
                                      TextSpan(
                                        text: '${detalhes.pedId}', // Variável
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            backgroundColor: Colors.blue,
                                            color: Colors.white,
                                            fontSize: 18), // Estilo da variável
                                        // Estilo da variável
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        color: Colors
                                            .black), // Estilo do texto fixo
                                    children: [
                                      const TextSpan(
                                        text: 'ID da entrega: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                16), // Estilo do texto fixo
                                      ),
                                      TextSpan(
                                        text: '${detalhes.entId}', // Variável
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            backgroundColor: Colors.blue,
                                            color: Colors.white,
                                            fontSize: 18), // Estilo da variável
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
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
                            '',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            child: const Text(
                              'Pedido Realizado com sucesso!',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            }));
  }
}
