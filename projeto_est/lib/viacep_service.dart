import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user.dart';

class ViaCepService {
  static Future<Contact> fetchContactAddress(String cep) async {
    final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final address = '${jsonData['logradouro']}, ${jsonData['bairro']}, ${jsonData['localidade']}/${jsonData['uf']}';
      return Contact(name: '', address: address, email: '', phone: '', createdDate: DateTime.now(),);
    } else {
      throw Exception('Erro!');
    }
  }
}