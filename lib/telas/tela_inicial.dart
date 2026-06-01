import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/tela_base.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});
  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      rotaAtiva: '/',
      corpo: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF003D33), Color(0xFF00695C), Color(0xFF004D40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800), // Texto centrado e legível
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.eco, color: AppTheme.primaryLight, size: 16),
                              SizedBox(width: 8),
                              Text('Economia Circular · Descarte Responsável', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Sua solução inteligente para\nComponentes Eletrônicos',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 48, height: 1.15),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Conectamos geradores de resíduos a recicladores.\nDescubra como é fácil descartar com responsabilidade.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.85), fontSize: 18, height: 1.6),
                        ),
                        const SizedBox(height: 48),
                        Wrap(
                          spacing: 20,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            _HeroButton(label: 'Explorar Materiais', icon: Icons.explore_outlined, onTap: () => Navigator.pushNamed(context, '/marketplace'), filled: true),
                            _HeroButton(label: 'Como Funciona', icon: Icons.info_outline, onTap: () => Navigator.pushNamed(context, '/como-funciona'), filled: false),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 60),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  Text('Como funciona', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  const SizedBox(height: 8),
                  Text('Três passos simples para transformar lixo eletrônico em oportunidade.', style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.textMuted), textAlign: TextAlign.center),
                  const SizedBox(height: 48),
                  Wrap(
                    spacing: 32,
                    runSpacing: 32,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildStep('1', Icons.add_box_outlined, 'Anuncie', 'Cadastre o material que deseja dar um destino.'),
                      _buildStep('2', Icons.people_outline, 'Conecte-se', 'Encontre recicladores ou interessados próximos a você.'),
                      _buildStep('3', Icons.local_shipping_outlined, 'Destine', 'Venda, doe ou recicle e faça parte desse impacto positivo!'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 80),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 1000),
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Center(
                child: Column(
                  children: [
                    Text('Pronto para fazer a diferença?', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textDark), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/anunciar'),
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text('Anunciar Material'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/marketplace'),
                          icon: const Icon(Icons.storefront_outlined, size: 20),
                          label: const Text('Ver Marketplace'),
                          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary, side: const BorderSide(color: AppTheme.primary, width: 1.5), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep(String number, IconData icon, String title, String description) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 8))]),
      child: Column(
        children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(color: AppTheme.primaryLight.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(icon, color: AppTheme.primary, size: 36)),
          const SizedBox(height: 20),
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text(description, style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMuted, height: 1.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _HeroButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _HeroButton({required this.label, required this.icon, required this.onTap, required this.filled});
  @override State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton> {
  bool _hovered = false;
  @override Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: BoxDecoration(
            color: widget.filled ? (_hovered ? AppTheme.primaryLight : Colors.white) : Colors.white.withValues(alpha: _hovered ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(30),
            border: widget.filled ? null : Border.all(color: Colors.white54, width: 1.5),
            boxShadow: widget.filled && _hovered ? [BoxShadow(color: Colors.white.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 6))] : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.filled ? (_hovered ? Colors.white : AppTheme.primary) : Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(widget.label, style: GoogleFonts.poppins(color: widget.filled ? (_hovered ? Colors.white : AppTheme.primary) : Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}