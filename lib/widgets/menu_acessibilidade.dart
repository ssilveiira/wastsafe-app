import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AccessibilityController extends ChangeNotifier {
  static final AccessibilityController _instance = AccessibilityController._();
  factory AccessibilityController() => _instance;
  AccessibilityController._();

  double _fontScale = 1.0;
  bool _highContrast = false;
  bool _reduceMotion = false;

  double get fontScale => _fontScale;
  bool get highContrast => _highContrast;
  bool get reduceMotion => _reduceMotion;

  void increaseFontSize() {
    if (_fontScale < 1.5) {
      _fontScale += 0.1;
      notifyListeners();
    }
  }

  void decreaseFontSize() {
    if (_fontScale > 0.8) {
      _fontScale -= 0.1;
      notifyListeners();
    }
  }

  void resetFontSize() {
    _fontScale = 1.0;
    notifyListeners();
  }

  void toggleHighContrast() {
    _highContrast = !_highContrast;
    notifyListeners();
  }

  void toggleReduceMotion() {
    _reduceMotion = !_reduceMotion;
    notifyListeners();
  }
}

final accessibility = AccessibilityController();

class AccessibilityMenu extends StatefulWidget {
  const AccessibilityMenu({super.key});

  @override
  State<AccessibilityMenu> createState() => _AccessibilityMenuState();
}

class _AccessibilityMenuState extends State<AccessibilityMenu>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Botão principal
        Tooltip(
          message: 'Acessibilidade',
          child: GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.accessibility_new,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
        // Painel do menu
        if (_open)
          Positioned(
            bottom: 60,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                alignment: Alignment.bottomRight,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 290,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.primaryLight.withValues(alpha: 0.25),
                      ),
                    ),
                    child: ListenableBuilder(
                      listenable: accessibility,
                      builder: (context, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.accessibility_new,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Acessibilidade',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _toggle,
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _sectionLabel('Tamanho do texto'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _circleBtn(
                                  Icons.text_decrease,
                                  () => accessibility.decreaseFontSize(),
                                  tooltip: 'Diminuir texto',
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '${(accessibility.fontScale * 100).round()}%',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _circleBtn(
                                  Icons.text_increase,
                                  () => accessibility.increaseFontSize(),
                                  tooltip: 'Aumentar texto',
                                ),
                                const SizedBox(width: 6),
                                _circleBtn(
                                  Icons.refresh,
                                  () => accessibility.resetFontSize(),
                                  tooltip: 'Resetar',
                                  small: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _divider(),
                            const SizedBox(height: 10),
                            _toggleRow(
                              icon: Icons.contrast,
                              label: 'Alto contraste',
                              subtitle: 'Inverte as cores da tela',
                              value: accessibility.highContrast,
                              onChanged: (_) =>
                                  accessibility.toggleHighContrast(),
                            ),
                            const SizedBox(height: 8),
                            _toggleRow(
                              icon: Icons.motion_photos_off_outlined,
                              label: 'Reduzir animações',
                              subtitle: 'Menos efeitos de movimento',
                              value: accessibility.reduceMotion,
                              onChanged: (_) =>
                                  accessibility.toggleReduceMotion(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _divider() {
    return Container(height: 1, color: Colors.grey.shade200);
  }

  Widget _circleBtn(
    IconData icon,
    VoidCallback onTap, {
    bool small = false,
    String? tooltip,
  }) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(small ? 6 : 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surface,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: small ? 14 : 18, color: AppTheme.primary),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip, child: btn) : btn;
  }

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primaryLight,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
