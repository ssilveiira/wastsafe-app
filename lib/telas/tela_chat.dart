import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/navbar.dart';
import '../theme/app_theme.dart';
import '../services/chat_service.dart';

class TelaChat extends StatefulWidget {
  final Map<String, dynamic> anuncio;
  const TelaChat({super.key, required this.anuncio});

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final _textoCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _chatService = ChatService();
  List<Map<String, dynamic>> _mensagens = [];

  final meuId = Supabase.instance.client.auth.currentUser?.id;
  String _destinatarioId = '';
  String _anuncioId = '';

  @override
  void initState() {
    super.initState();

    _anuncioId = (widget.anuncio['anuncio_id']
            ?? widget.anuncio['id']
            ?? '')
        .toString();

    _destinatarioId = (widget.anuncio['outro_usuario_id']
            ?? widget.anuncio['user_id']
            ?? widget.anuncio['vendedor_id']
            ?? '')
        .toString();

    _chatService.escutarMensagens(_anuncioId, _destinatarioId).listen((msgs) {
      if (mounted) {
        setState(() => _mensagens = msgs);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _textoCtrl.dispose();
    _scrollCtrl.dispose();
    _chatService.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _textoCtrl.text.trim();
    if (texto.isEmpty || meuId == null || _destinatarioId.isEmpty) return;

    final mensagemLocal = {
      'remetente_id': meuId,
      'destinatario_id': _destinatarioId,
      'texto': texto,
      'created_at': DateTime.now().toIso8601String()
    };
    setState(() => _mensagens.add(mensagemLocal));
    _textoCtrl.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      await _chatService.enviarMensagem(
        anuncioId: _anuncioId,
        remetenteId: meuId!,
        destinatarioId: _destinatarioId,
        texto: texto,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A mensagem não foi enviada.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _mensagens.remove(mensagemLocal));
      }
    }
  }

  String _formatarDataSeparador(DateTime date) {
    final now = DateTime.now();
    final hoje = DateTime(now.year, now.month, now.day);
    final ontem = hoje.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == hoje) return 'Hoje';
    if (msgDate == ontem) return 'Ontem';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final vendedor =
        widget.anuncio['vendedor'] ?? widget.anuncio['contato_nome'] ?? 'Usuário';
    final produto =
        widget.anuncio['nome'] ?? widget.anuncio['titulo'] ?? 'Produto';
    final vendedorFoto =
        widget.anuncio['vendedor_foto'] ?? widget.anuncio['contato_foto'];

    return Scaffold(
      appBar: const WastSafeNavBar(activeRoute: '/chat', showUserIcon: true),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      AppTheme.primaryLight.withValues(alpha: 0.2),
                  backgroundImage:
                      vendedorFoto != null ? NetworkImage(vendedorFoto) : null,
                  child: vendedorFoto == null
                      ? const Icon(Icons.person, color: AppTheme.primary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendedor,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600)),
                      Text(produto,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/fundo_chat.png',
                    fit: BoxFit.cover,
                    color: const Color(0xFFF9FAFB).withValues(alpha: 0.85),
                    colorBlendMode: BlendMode.lighten,
                  ),
                ),
                ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: _mensagens.length,
                  itemBuilder: (context, index) {
                    final msg = _mensagens[index];
                    final isMe = msg['remetente_id'] == meuId;
                    final date =
                        DateTime.tryParse(msg['created_at'].toString())
                                ?.toLocal() ??
                            DateTime.now();
                    final horaFormatada =
                        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                    bool showDateHeader = index == 0;
                    if (index > 0) {
                      final prevDate = DateTime.tryParse(
                                  _mensagens[index - 1]['created_at']
                                      .toString())
                              ?.toLocal() ??
                          DateTime.now();
                      if (date.year != prevDate.year ||
                          date.month != prevDate.month ||
                          date.day != prevDate.day){
                            showDateHeader = true;
                          } 
                    }

                    return Column(
                      children: [
                        if (showDateHeader)
                          Container(
                            margin:
                                const EdgeInsets.symmetric(vertical: 16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.05),
                                    blurRadius: 2)
                              ],
                            ),
                            child: Text(
                              _formatarDataSeparador(date),
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width *
                                        0.75),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? AppTheme.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe
                                    ? const Radius.circular(16)
                                    : const Radius.circular(4),
                                bottomRight: isMe
                                    ? const Radius.circular(4)
                                    : const Radius.circular(16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['texto'] ?? '',
                                  style: GoogleFonts.poppins(
                                      color: isMe
                                          ? Colors.white
                                          : AppTheme.textDark,
                                      fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  horaFormatada,
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: isMe
                                          ? Colors.white70
                                          : Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textoCtrl,
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _enviar(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: _enviar,
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}