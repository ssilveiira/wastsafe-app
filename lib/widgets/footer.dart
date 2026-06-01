import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class WastSafeFooter extends StatelessWidget {
  const WastSafeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE8F5E9),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 12,
            children: [
              _footerLink(context, 'Início', '/'),
              _footerLink(context, 'Marketplace', '/marketplace'),
              _footerLink(context, 'Avaliações', '/avaliacao'),
              _footerLink(context, 'Como Funciona', '/como-funciona'),
              _footerLink(context, 'Sobre Nós', '/sobre'),
              _footerLink(context, 'Anunciar', '/anunciar'),
              _footerLink(context, 'Meu Perfil', '/perfil'),
              _footerLink(context, 'Login', '/login'),
              _footerLink(context, 'Cadastro', '/cadastro'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'WastSafe © 2026',
            style: GoogleFonts.poppins(
              color: const Color(0xFF2E7D32),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Economia Circular · Descarte Responsável',
            style: GoogleFonts.poppins(
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.w400,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(BuildContext context, String label, String route) {
    return InkWell(
      onTap: () {
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: AppTheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
