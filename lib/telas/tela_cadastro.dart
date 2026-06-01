import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/tela_base.dart';
import '../widgets/transicao_pagina.dart';
import '../services/auth_service.dart';
import 'tela_login.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});
  @override 
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  
  bool _buscandoCep = false;
  bool _loading = false;

  @override 
  void dispose() {
    _nomeCtrl.dispose(); _emailCtrl.dispose(); _cpfCtrl.dispose();
    _cepCtrl.dispose(); _senhaCtrl.dispose(); _bairroCtrl.dispose();
    _telefoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscarCep(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length != 8) return;
    setState(() => _buscandoCep = true);
    try {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == null) {
          setState(() => _bairroCtrl.text = data['bairro'] ?? '');
        }
      }
    } catch (e) {
      debugPrint('Erro: $e');
    } finally {
      if (mounted) setState(() => _buscandoCep = false);
    }
  }

  Future<void> _realizarCadastro() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    try {
      await AuthService().signUp(
        email: _emailCtrl.text.trim(),
        senha: _senhaCtrl.text,
        nome: _nomeCtrl.text.trim(),
        cpf: _cpfCtrl.text.trim(),
        telefone: _telefoneCtrl.text.trim(),
        bairro: _bairroCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conta criada com sucesso!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        Navigator.pushReplacement(context, FadePageRoute(page: const TelaLogin()));
      }
    } catch (e) {
      if (mounted) {
        String mensagem = e.toString();
        if (e is AuthApiException) {
          mensagem = e.message;
          if (mensagem.contains('Password should be at least')) {
            mensagem = 'Sua senha deve ter pelo menos 6 caracteres.';
          } else if (mensagem.contains('User already registered')) {
            mensagem = 'Este e-mail já está cadastrado.';
          }
        }
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Erro no cadastro'),
            content: Text(mensagem),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override 
  Widget build(BuildContext context) {
    return TelaBase(
      rotaAtiva: '/cadastro',
      corpo: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF004D40), Color(0xFF00796B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text('Criar Conta', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF004D40))),
                  const SizedBox(height: 30),
                  Wrap(spacing: 20, runSpacing: 20, alignment: WrapAlignment.center, children: [
                    _campo(_nomeCtrl, 'Nome Completo', Icons.person_outline),
                    _campo(_emailCtrl, 'E-mail', Icons.email_outlined),
                    _campo(_cpfCtrl, 'CPF/CNPJ', Icons.badge_outlined),
                    _campo(_telefoneCtrl, 'Telefone', Icons.phone_outlined),
                    
                    _campo(_cepCtrl, 'CEP', Icons.location_on_outlined, onChanged: (v) { 
                      if (v.replaceAll(RegExp(r'[^0-9]'), '').length == 8) _buscarCep(v); 
                    }),
                    
                    _campo(_bairroCtrl, 'Bairro', Icons.map_outlined),
                    _campo(_senhaCtrl, 'Senha (mínimo 6 caracteres)', Icons.lock_outline, obscure: true),
                  ]),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _realizarCadastro,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _loading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Text('Cadastrar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Já tem conta?', style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context, FadePageRoute(page: const TelaLogin())),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Text('Entrar', style: GoogleFonts.poppins(color: const Color(0xFF004D40), fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String hint, IconData icon, {bool obscure = false, Function(String)? onChanged}) {
    return SizedBox(
      width: 350, 
      child: TextFormField(
        controller: ctrl, 
        obscureText: obscure, 
        onChanged: onChanged,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
          if (obscure && v.length < 6) return 'A senha deve ter no mínimo 6 caracteres';
          return null;
        },
        decoration: InputDecoration(
          hintText: hint, 
          filled: true, 
          fillColor: Colors.grey.shade100,
          prefixIcon: Icon(icon, color: const Color(0xFF004D40)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        ),
      )
    );
  }
}