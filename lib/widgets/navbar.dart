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

class _WastSafeNavBarState extends State<WastSafeNavBar> {
  final AuthService _auth = AuthService();
  String? _fotoUrl;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
    _carregarFotoPerfil();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {});
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
    return Container(
      height: 68,
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  if (widget.activeRoute != '/') {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Image.asset('assets/logo.png', height: 42),
                ),
              ), 
            ],
          ),
          const SizedBox(width: 16),
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
                      _link(context, 'Meus Anúncios', '/meus-anuncios'),
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
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Icon(Icons.add_circle_outline, size: 16, color: Colors.white),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.2),
                  backgroundImage: _fotoUrl != null ? NetworkImage(_fotoUrl!) : null,
                  child: _fotoUrl == null 
                    ? const Icon(Icons.person, size: 18, color: AppTheme.primary) 
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
                    decorationColor: AppTheme.primary.withValues(alpha: 0.3),
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
                child: const Icon(Icons.logout, size: 16, color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }
}