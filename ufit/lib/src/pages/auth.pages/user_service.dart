import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ufit/src/pages/register_pages/register_user_page.dart';

class UserService {
  static const String _userDataKey = 'user_registration_data';

  // Salva todas as preferencias do usuario no SharedPreferences
  static Future<void> saveUserData(UserRegistrationData userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataMap = {
      'nome': userData.nome,
      'sobrenome': userData.sobrenome,
      'email': userData.email,
      'cpf': userData.cpf,
      'idade': userData.idade,
      'endereco': userData.endereco,
      'genero': userData.genero,
      'objetivo': userData.objetivo,
      'metas': userData.metas,
      'biotipo': userData.biotipo,
      'peso': userData.peso,
      'altura': userData.altura,
      'localTreino': userData.localTreino,
    };
    
    final userDataJson = jsonEncode(userDataMap);
    await prefs.setString(_userDataKey, userDataJson);
  }

  
  static Future<UserRegistrationData?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_userDataKey);
    
    if (userDataJson != null) {
      final userDataMap = jsonDecode(userDataJson) as Map<String, dynamic>;
      final userData = UserRegistrationData();
      
      userData.nome = userDataMap['nome'] ?? '';
      userData.sobrenome = userDataMap['sobrenome'] ?? '';
      userData.email = userDataMap['email'] ?? '';
      userData.cpf = userDataMap['cpf'] ?? '';
      userData.idade = userDataMap['idade'] ?? '';
      userData.endereco = userDataMap['endereco'] ?? '';
      userData.genero = userDataMap['genero'] ?? '';
      userData.objetivo = userDataMap['objetivo'] ?? '';
      userData.metas = List<String>.from(userDataMap['metas'] ?? []);
      userData.biotipo = userDataMap['biotipo'] ?? '';
      userData.peso = userDataMap['peso'] ?? '';
      userData.altura = userDataMap['altura'] ?? '';
      userData.localTreino = userDataMap['localTreino'] ?? '';
      
      return userData;
    }
    
    return null;
  }
  
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }
}

