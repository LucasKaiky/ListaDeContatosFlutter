class User {
  String nome;
  String telefone;
  String email;
  DateTime createdDate;
  List<String> endereco;

  User({
    required this.nome,
    required this.telefone,
    required this.email,
    required this.createdDate,
    required this.endereco,
  });
}
