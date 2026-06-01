import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/tela_base.dart';

class TelaSobreNos extends StatelessWidget {
  const TelaSobreNos({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      rotaAtiva: '/sobre',
      showUserIcon: true,
      showAnunciarBtn: true,
      corpo: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003D33), Color(0xFF00695C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 15)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco, size: 64, color: AppTheme.primaryLight),
                    const SizedBox(height: 24),
                    Text('A Nossa Missão', style: GoogleFonts.poppins(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 32)),
                    const SizedBox(height: 32),
                    Text(
                      'A WastSafe é uma iniciativa que promove a economia circular no setor de resíduos eletrônicos.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.w700, fontSize: 20, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Container(height: 4, width: 60, color: AppTheme.primaryLight),
                    const SizedBox(height: 24),
                    Text(
                      'Nosso objetivo principal é conectar geradores e recicladores de forma inteligente, simplificando a logística reversa e garantindo que o descarte de componentes eletrônicos seja feito de forma 100% segura, eficiente e com impacto ambiental positivo.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: AppTheme.textMuted, fontWeight: FontWeight.w500, fontSize: 16, height: 1.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}