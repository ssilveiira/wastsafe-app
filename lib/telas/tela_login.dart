import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../theme/app_theme.dart';
import '../widgets/tela_base.dart';
import '../widgets/transicao_pagina.dart';
import '../services/auth_service.dart';
import 'tela_cadastro.dart';
import 'tela_inicial.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});
  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthService().login(email: _emailCtrl.text, senha: _senhaCtrl.text);
      if (mounted) {
        Navigator.pushReplacement(context, FadePageRoute(page: const TelaInicial()));
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().contains("não possui perfil")
            ? "Acesso negado: Perfil não encontrado."
            : "E-mail ou senha inválidos.";
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      rotaAtiva: '/login',
      corpo: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004D40), Color(0xFF00796B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(0, 10))],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryLight.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.person_outline, size: 48, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 32),
                  Text('Bem-vindo de volta!', style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.w800, fontSize: 28)),
                  const SizedBox(height: 8),
                  Text('Faça login para continuar.', style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 14)),
                  const SizedBox(height: 40),
                  
                  _buildField(_emailCtrl, 'E-mail', Icons.email_outlined),
                  const SizedBox(height: 16),
                  _buildField(_senhaCtrl, 'Senha', Icons.lock_outline, obscure: true),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : Text('Entrar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Não tem conta?', style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 14)),
                      TextButton(
                        onPressed: () => Navigator.push(context, FadePageRoute(page: const TelaCadastro())),
                        child: Text('Cadastre-se', style: GoogleFonts.poppins(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
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

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
      prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool obscure = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
      style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textDark),
      decoration: _inputDeco(hint, icon),
    );
  }
}