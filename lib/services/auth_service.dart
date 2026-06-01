import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  final _supabase = Supabase.instance.client;

  String? _userName;
  String? _userEmail;

  bool get isLoggedIn => _supabase.auth.currentSession != null;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  
  // NOVO GETTER
  String? get userId => _supabase.auth.currentUser?.id;

  AuthService._() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      _userEmail = session?.user.email;
      if (session != null) {
        _loadProfile(session.user.id);
      } else {
        _userName = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('nome')
          .eq('id', userId)
          .maybeSingle();
      _userName = data != null ? data['nome'] : 'Usuário';
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao carregar perfil: $e");
    }
  }

  Future<void> signUp({
    required String email,
    required String senha,
    required String nome,
    required String cpf,
    required String telefone,
    required String bairro,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: senha,
    );

    if (response.user == null) {
      throw Exception('Falha ao criar usuário');
    }

    final existe = await _supabase
        .from('profiles')
        .select('id')
        .eq('id', response.user!.id)
        .maybeSingle();

    if (existe == null) {
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'nome': nome,
        'cpf_cnpj': cpf,
        'telefone': telefone,
        'bairro': bairro,
      });
    } else {
      await _supabase.from('profiles').update({
        'nome': nome,
        'cpf_cnpj': cpf,
        'telefone': telefone,
        'bairro': bairro,
      }).eq('id', response.user!.id);
    }
  }

  Future<void> login({
    required String email,
    required String senha,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: senha,
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}