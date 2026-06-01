import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/tela_base.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import 'tela_chat.dart';

class TelaListaChats extends StatefulWidget {
  const TelaListaChats({super.key});
  @override
  State<TelaListaChats> createState() => _TelaListaChatsState();
}

class _TelaListaChatsState extends State<TelaListaChats> {
  List<Map<String, dynamic>> _conversas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarConversas();
  }

  Future<void> _carregarConversas() async {
    setState(() => _loading = true);
    final lista = await ChatService().listarMinhasConversas();
    if (mounted) setState(() { _conversas = lista; _loading = false; });
  }

  Future<void> _excluirConversa(String id, String outroId, int index) async {
    final conversaRemovida = _conversas[index];
    setState(() => _conversas.removeAt(index));
    try {
      await ChatService().excluirConversaLocal(id, outroId);
      await _carregarConversas(); 
    } catch (e) {
      setState(() => _conversas.insert(index, conversaRemovida));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro interno. Verifique as colunas no Supabase.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      rotaAtiva: '/chats',
      showUserIcon: true,
      corpo: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mensagens', style: GoogleFonts.poppins(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 32)),
                const SizedBox(height: 8),
                Text('Suas negociações e conversas com outros usuários Wastsafe. Utilize as opções para excluir.', style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 15)),
                const SizedBox(height: 32),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _conversas.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _conversas.length,
                            itemBuilder: (context, index) {
                              final chat = _conversas[index];
                              final date = DateTime.tryParse(chat['data'].toString())?.toLocal() ?? DateTime.now();
                              final horaFormatada = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                              final fotoUrl = chat['contato_foto'];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.1),
                                    radius: 28,
                                    backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
                                    child: fotoUrl == null ? const Icon(Icons.person, color: AppTheme.primary) : null,
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(chat['contato_nome'] ?? 'Usuário', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                                      Text(horaFormatada, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400)),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      Text(chat['titulo'] ?? 'Anúncio', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text(chat['ultimo_texto'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMuted)),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                                    onSelected: (value) {
                                      if (value == 'excluir') _excluirConversa(chat['anuncio_id'].toString(), chat['outro_usuario_id'].toString(), index);
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(value: 'excluir', child: Row(children: [const Icon(Icons.delete_outline, color: Colors.red, size: 20), const SizedBox(width: 8), Text('Excluir conversa', style: GoogleFonts.poppins(fontSize: 14))])),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => TelaChat(anuncio: chat))).then((_) => _carregarConversas());
                                  },
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300), const SizedBox(height: 24),
          Text('Nenhuma conversa ainda', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)), const SizedBox(height: 8),
          Text('Seus chats aparecerão aqui.', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}