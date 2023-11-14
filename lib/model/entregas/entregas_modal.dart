class Entregas {
  int? entId;
  String? entStatusAdmin;
  String? entStatusEntregador;
  int? entHoras;
  double? entValorFrete;
  int? usuId;
  int? pedId;
  String? usuCep;
  String? usuTelefone;
  String? usuEndereco;
  String? usuNumero;
  String? usuNome;
  String? valorTotal;
  String? valorTotalMes;

  Entregas(
      {this.entId,
      this.entStatusAdmin,
      this.entStatusEntregador,
      this.entHoras,
      this.entValorFrete,
      this.usuId,
      this.pedId,
      this.usuCep,
      this.usuTelefone,
      this.usuEndereco,
      this.usuNumero,
      this.usuNome,
      this.valorTotal,
      this.valorTotalMes});

  Entregas.fromJson(Map<String, dynamic> json) {
    entId = json['ent_id'];
    entStatusAdmin = json['ent_status_admin'];
    entStatusEntregador = json['ent_status_entregador'];
    entHoras = json['ent_minutos'];
    entValorFrete = json['ent_valorFrete'] != null
        ? double.parse(json['ent_valorFrete'])
        : null;
    usuId = json['usu_id'];
    pedId = json['ped_id'];
    usuCep = json['usu_cep'];
    usuTelefone = json['usu_telefone'];
    usuEndereco = json['usu_endereco'];
    usuNumero = json['usu_numero'];
    usuNome = json['usu_nome'];
    valorTotal = json['valor_total'];
    valorTotalMes = json['valor_total_mes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ent_id'] = this.entId;
    data['ent_status_admin'] = this.entStatusAdmin;
    data['ent_status_entregador'] = this.entStatusEntregador;
    data['ent_minutos'] = this.entHoras;
    data['ent_valorFrete'] = this.entValorFrete;
    data['usu_id'] = this.usuId;
    data['ped_id'] = this.pedId;
    data['usu_cep'] = this.usuCep;
    data['usu_telefone'] = this.usuTelefone;
    data['usu_endereco'] = this.usuEndereco;
    data['usu_numero'] = this.usuNumero;
    data['usu_nome'] = this.usuNome;
    data['valor_total'] = this.valorTotal;
    data['valor_total_mes'] = this.valorTotalMes;
    return data;
  }
}
