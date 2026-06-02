import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class WastSafeNavBar extends StatefulWidget implements PreferredSizeWidget {
  final String activeRoute;
  final bool showUserIcon;
  final bool showAnunciarBtn;

  const WastSafeNavBar({
    super.key,
    required this.activeRoute,
    this.showUserIcon = false,
    this.showAnunciarBtn = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  State<WastSafeNavBar> createState() => _WastSafeNavBarState();
}

class _WastSafeNavBarState extends State<WastSafeNavBar>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  String? _fotoUrl;
  bool _menuAberto = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Breakpoint: abaixo disso usa menu mobile
  static const double _breakpoint = 720;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
    _carregarFotoPerfil();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _animCtrl.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {});
  }

  void _toggleMenu() {
    setState(() => _menuAberto = !_menuAberto);
    _menuAberto ? _animCtrl.forward() : _animCtrl.reverse();
  }

  void _fecharMenu() {
    if (_menuAberto) {
      setState(() => _menuAberto = false);
      _animCtrl.reverse();
    }
  }

  Future<void> _carregarFotoPerfil() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final perfil = await Supabase.instance.client
            .from('profiles')
            .select('foto_perfil')
            .eq('id', user.id)
            .single();

        if (mounted && perfil['foto_perfil'] != null) {
          setState(() {
            _fotoUrl = perfil['foto_perfil'];
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar foto na Navbar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < _breakpoint;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Barra principal ──────────────────────────────────────
        Container(
          height: 68,
          color: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Logo
              InkWell(
                onTap: () {
                  _fecharMenu();
                  if (widget.activeRoute != '/') {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  child: Image.asset('assets/logo.png', height: 42),
                ),
              ),
              const SizedBox(width: 16),

              if (isMobile) ...[
                // Mobile: espaço + hamburguer
                const Spacer(),
                if (_auth.isLoggedIn) ...[
                  CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        AppTheme.primaryLight.withValues(alpha: 0.2),
                    backgroundImage:
                        _fotoUrl != null ? NetworkImage(_fotoUrl!) : null,
                    child: _fotoUrl == null
                        ? const Icon(Icons.person,
                            size: 18, color: AppTheme.primary)
                        : null,
                  ),
                  const SizedBox(width: 10),
                ],
                IconButton(
                  onPressed: _toggleMenu,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _menuAberto ? Icons.close : Icons.menu,
                      key: ValueKey(_menuAberto),
                      color: AppTheme.primary,
                      size: 26,
                    ),
                  ),
                  tooltip: 'Menu',
                ),
              ] else ...[
                // Desktop: links centralizados + área logado
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _link(context, 'Início', '/'),
                          _link(context, 'Marketplace', '/marketplace'),
                          _link(context, 'Avaliações', '/avaliacao'),
                          if (_auth.isLoggedIn) ...[
                            _link(context,
                                'Meus Anúncios', '/meus-anuncios'),
                            _link(context, 'Mensagens', '/chats'),
                          ],
                          _anunciarBtn(context),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_auth.isLoggedIn) _areaLogado(context),
              ],
            ],
          ),
        ),

        // ── Dropdown mobile ──────────────────────────────────────
        if (isMobile && _menuAberto)
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(height: 1, color: Color(0xFFE8F5E9)),
                    _menuItem(context, 'Início', '/', Icons.home_outlined),
                    _menuItem(context, 'Marketplace', '/marketplace',
                        Icons.storefront_outlined),
                    _menuItem(context, 'Avaliações', '/avaliacao',
                        Icons.star_outline_rounded),
                    if (_auth.isLoggedIn) ...[
                      _menuItem(context, 'Meus Anúncios', '/meus-anuncios',
                          Icons.inventory_2_outlined),
                      _menuItem(context, 'Mensagens', '/chats',
                          Icons.chat_bubble_outline),
                    ],
                    const Divider(height: 1, color: Color(0xFFE8F5E9)),
                    // Botão Anunciar destacado
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: InkWell(
                        onTap: () {
                          _fecharMenu();
                          if (widget.activeRoute != '/anunciar') {
                            Navigator.pushReplacementNamed(
                                context, '/anunciar');
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.activeRoute == '/anunciar'
                                  ? [
                                      AppTheme.primaryLight,
                                      AppTheme.primary
                                    ]
                                  : [
                                      AppTheme.primary,
                                      AppTheme.primaryLight
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Anunciar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Área logado no mobile
                    if (_auth.isLoggedIn) ...[
                      const Divider(height: 1, color: Color(0xFFE8F5E9)),
                      ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              AppTheme.primaryLight.withValues(alpha: 0.2),
                          backgroundImage: _fotoUrl != null
                              ? NetworkImage(_fotoUrl!)
                              : null,
                          child: _fotoUrl == null
                              ? const Icon(Icons.person,
                                  size: 18, color: AppTheme.primary)
                              : null,
                        ),
                        title: Text(
                          _auth.userName ?? 'Usuário',
                          style: GoogleFonts.poppins(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.logout, color: Colors.red),
                          tooltip: 'Sair',
                          onPressed: () {
                            _fecharMenu();
                            _auth.logout();
                            Navigator.pushReplacementNamed(context, '/');
                          },
                        ),
                        onTap: () {
                          _fecharMenu();
                          if (widget.activeRoute != '/perfil') {
                            Navigator.pushReplacementNamed(
                                context, '/perfil');
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Widgets auxiliares ───────────────────────────────────────

  Widget _menuItem(BuildContext context, String label, String route,
      IconData icon) {
    final isActive = widget.activeRoute == route;
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppTheme.primary : AppTheme.textMuted,
        size: 22,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? AppTheme.primary : AppTheme.textDark,
          fontSize: 15,
        ),
      ),
      tileColor: isActive
          ? AppTheme.primary.withValues(alpha: 0.05)
          : Colors.transparent,
      onTap: () {
        _fecharMenu();
        if (!isActive) Navigator.pushReplacementNamed(context, route);
      },
    );
  }

  Widget _link(BuildContext context, String label, String route) {
    final isActive = widget.activeRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () {
          if (isActive) return;
          Navigator.pushReplacementNamed(context, route);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppTheme.primary : AppTheme.textDark,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _anunciarBtn(BuildContext context) {
    final isActive = widget.activeRoute == '/anunciar';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {
          if (isActive) return;
          Navigator.pushReplacementNamed(context, '/anunciar');
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isActive
                  ? [AppTheme.primaryLight, AppTheme.primary]
                  : [AppTheme.primary, AppTheme.primaryLight],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline,
                  size: 16, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Anunciar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _areaLogado(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (widget.activeRoute != '/perfil') {
              Navigator.pushReplacementNamed(context, '/perfil');
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      AppTheme.primaryLight.withValues(alpha: 0.2),
                  backgroundImage:
                      _fotoUrl != null ? NetworkImage(_fotoUrl!) : null,
                  child: _fotoUrl == null
                      ? const Icon(Icons.person,
                          size: 18, color: AppTheme.primary)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  _auth.userName ?? 'Usuário',
                  style: GoogleFonts.poppins(
                    color: widget.activeRoute == '/perfil'
                        ? AppTheme.primaryLight
                        : AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationColor:
                        AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: 'Sair',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _auth.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.logout,
                    size: 16, color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }
}