import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'telas/tela_inicial.dart';
import 'telas/tela_marketplace.dart';
import 'telas/tela_avaliacao.dart';
import 'telas/tela_como_funciona.dart';
import 'telas/tela_sobre_nos.dart';
import 'telas/tela_login.dart';
import 'telas/tela_cadastro.dart';
import 'telas/tela_anunciar.dart';
import 'telas/tela_meus_anuncios.dart';
import 'telas/tela_lista_chats.dart';
import 'telas/tela_perfil.dart';
import 'telas/tela_comentarios.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const WastSafeApp());
}

class WastSafeApp extends StatelessWidget {
  const WastSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WastSafe',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final publicRoutes = [
          '/',
          '/login',
          '/cadastro',
          '/sobre',
          '/como-funciona'
        ];

        if (!publicRoutes.contains(settings.name)) {
          final session = Supabase.instance.client.auth.currentSession;
          if (session == null) {
            return MaterialPageRoute(
              builder: (_) => const TelaLogin(),
              settings: const RouteSettings(name: '/login'),
            );
          }
        }

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const TelaInicial());
          case '/marketplace':
            return MaterialPageRoute(builder: (_) => const TelaMarketplace());
          case '/avaliacao':
            return MaterialPageRoute(builder: (_) => const TelaAvaliacao());
          case '/como-funciona':
            return MaterialPageRoute(builder: (_) => const TelaComoFunciona());
          case '/sobre':
            return MaterialPageRoute(builder: (_) => const TelaSobreNos());
          case '/login':
            return MaterialPageRoute(builder: (_) => const TelaLogin());
          case '/cadastro':
            return MaterialPageRoute(builder: (_) => const TelaCadastro());
          case '/anunciar':
            return MaterialPageRoute(builder: (_) => const TelaAnunciar());
          case '/meus-anuncios':
            return MaterialPageRoute(builder: (_) => const TelaMeusAnuncios());
          case '/chats':
            return MaterialPageRoute(builder: (_) => const TelaListaChats());
          case '/perfil':
            return MaterialPageRoute(builder: (_) => const TelaPerfil());
          case '/meus-comentarios':
            return MaterialPageRoute(builder: (_) => const TelaComentarios());
          default:
            return MaterialPageRoute(builder: (_) => const TelaInicial());
        }
      },
    );
  }
}
