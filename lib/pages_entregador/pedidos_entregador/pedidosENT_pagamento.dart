import 'package:flutter/material.dart';
import 'package:projeto_01_teste/model/entregas/rotas_modal.dart';
import 'package:projeto_01_teste/pages_entregador/pedidos_entregador/pedidosENT_api.dart';
import 'package:url_launcher/url_launcher.dart';

class PedidosENTpag extends StatefulWidget {
  final String usuarioCep;
  final int pedidoId;
  final Function() atualizarPedidos;

  PedidosENTpag({
    Key? key,
    required this.usuarioCep,
    required this.pedidoId,
    required this.atualizarPedidos,
  }) : super(key: key);

  @override
  _PedidosENTpagState createState() => _PedidosENTpagState();
}

class _PedidosENTpagState extends State<PedidosENTpag> {
  late Future<Rota?> _rotaDetails;
  final PedidosENTapi apiService = PedidosENTapi();
  TextEditingController _minutosController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _rotaDetails = PedidosENTapi.calcularRota(
      widget.usuarioCep,
    );
  }

  String? _validarMin(String? text) {
    if (text!.isEmpty) {
      return "Digite seu Nome Completo";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valores da entrega'),
      ),
      body: FutureBuilder<Rota?>(
        future: _rotaDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (!snapshot.hasData) {
            return const Text('Nenhum detalhe encontrado');
          } else {
            Rota rotas = snapshot.data!;

            return Column(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                      child: const Text(
                        "Mais informações sobre a entrega:",
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
                                  fontSize: 18,
                                  color: Colors.black), // Estilo do texto fixo
                              children: [
                                const TextSpan(
                                  text: 'Valor da corrida: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight
                                          .bold), // Estilo do texto fixo
                                ),
                                TextSpan(
                                  text:
                                      'R\$ ${rotas.price!.toDouble()}', // Variável
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
                                  color: Colors.black), // Estilo do texto fixo
                              children: [
                                const TextSpan(
                                  text: 'Distância da corrida: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18), // Estilo do texto fixo
                                ),
                                TextSpan(
                                  text: '${rotas.distance!}', // Variável
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18), // Estilo da variável
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
                        margin:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
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
                          children: [
                            const Text(
                                'Digite aqui em minutos qual tempo para entrega:'),
                            const SizedBox(
                              height: 16,
                            ),
                            Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: _minutosController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  hintText: 'Digite os minutos',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Este campo é obrigatório';
                                  }
                                  return null;
                                },
                              ),
                            )
                          ],
                        )),
                    const SizedBox(
                      height: 14,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String mapUrl = rotas.mapUrl ?? "";
                        _launchMapsUrlInBrowser(mapUrl);
                      },
                      child: const Text('Rota da entrega'),
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
                        'Deseja aceitar essa entrega ?',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight
                              .bold, // Pode ser FontWeight.bold para negrito, se desejar
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // O formulário é válido, prossiga com o envio dos dados.
                            String minutosInseridos = _minutosController.text;
                            final classe = PedidosENTapi();
                            await classe.aceitarEntrega(widget.pedidoId,
                                int.parse(minutosInseridos), rotas.price!);

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Entrega aceita com sucesso'),
                                  content: Text(
                                      'Clique em OK para voltar ao seu pedido.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () async {
                                        widget.atualizarPedidos();
                                        Navigator.pop(context, true);
                                        Navigator.pop(context, true);
                                        Navigator.pop(context, true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Adicione os dados faltantes'),
                                  content: Text(
                                      'Clique em OK para voltar ao seu pedido.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () async {
                                        Navigator.pop(context, true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text(
                          'Aceitar Entrega',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
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

  Future<void> _launchMapsUrlInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o link: $url';
    }
  }
}
