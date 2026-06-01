import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/tela_base.dart';

class TelaComoFunciona extends StatelessWidget {
  const TelaComoFunciona({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'num': '1',
        'icon': Icons.add_box_outlined,
        'titulo': 'Anuncie o Material',
        'desc': 'Cadastre o tipo e a quantidade de componentes eletrônicos sem uso que você deseja descartar, doar ou vender.'
      },
      {
        'num': '2',
        'icon': Icons.people_outline,
        'titulo': 'Conecte-se a Recicladores',
        'desc': 'Nosso sistema encontra automaticamente recicladores, compradores e cooperativas próximos a você.'
      },
      {
        'num': '3',
        'icon': Icons.local_shipping_outlined,
        'titulo': 'Destino Responsável',
        'desc': 'Acompanhe a coleta, a entrega e faça relatórios que mostram todo o impacto positivo.'
      },
    ];

    return TelaBase(
      rotaAtiva: '/como-funciona',
      showUserIcon: true,
      showAnunciarBtn: true,
      corpo: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Column(
          children: [
            Text('Como Funciona', style: GoogleFonts.poppins(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 40)),
            const SizedBox(height: 12),
            Text('Três passos simples para transformar o lixo eletrônico em oportunidade.',
                style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 16)),
            const SizedBox(height: 60),
            Wrap(
              spacing: 32,
              runSpacing: 32,
              alignment: WrapAlignment.center,
              children: steps.map((step) {
                return Container(
                  width: 340,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
                    border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppTheme.primaryLight.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: Icon(step['icon'] as IconData, size: 48, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 24),
                      Text('Passo ${step['num']}',
                          style: GoogleFonts.poppins(color: AppTheme.primaryLight, fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(step['titulo'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.w800, fontSize: 20)),
                      const SizedBox(height: 16),
                      Text(step['desc'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: AppTheme.textMuted, fontWeight: FontWeight.w500, fontSize: 15, height: 1.6)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}