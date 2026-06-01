import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  Future<void> enviarMensagem({required String anuncioId, required String remetenteId, required String destinatarioId, required String texto}) async {
    await _supabase.from('mensagens').insert({
      'anuncio_id': anuncioId, 'remetente_id': remetenteId, 'destinatario_id': destinatarioId, 'texto': texto,
    });
  }

  Stream<List<Map<String, dynamic>>> escutarMensagens(String anuncioId, String outroUsuarioId) {
    final controller = StreamController<List<Map<String, dynamic>>>();
    _carregarMensagens(anuncioId, outroUsuarioId).then((msgs) => controller.add(msgs));
    
    _channel = _supabase.channel('chat_$anuncioId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert, schema: 'public', table: 'mensagens', 
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'anuncio_id', value: anuncioId), 
        callback: (p) => _carregarMensagens(anuncioId, outroUsuarioId).then((m) => controller.add(m))
      ).subscribe();
      
    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> _carregarMensagens(String anuncioId, String outroId) async {
    final meuId = _supabase.auth.currentUser?.id;
    if (meuId == null) return [];
    
    final res = await _supabase.from('mensagens')
        .select('*, remetente:profiles!remetente_id(nome), destinatario:profiles!destinatario_id(nome)')
        .eq('anuncio_id', anuncioId)
        .order('created_at', ascending: true);
    
    return res.where((msg) {
        final sender = msg['remetente_id'].toString();
        final receiver = msg['destinatario_id'].toString();

        final isMyChat = (sender == meuId && receiver == outroId) || (sender == outroId && receiver == meuId);
        if (!isMyChat) return false;

        if (sender == meuId) return msg['apagado_por_remetente'] != true;
        return msg['apagado_por_destinatario'] != true;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> listarMinhasConversas() async {
    final meuId = _supabase.auth.currentUser?.id;
    if (meuId == null) return [];
    
    final res = await _supabase.from('mensagens').select('''
          anuncio_id, texto, created_at, remetente_id, destinatario_id,
          apagado_por_remetente, apagado_por_destinatario,
          anuncios (titulo), 
          remetente:profiles!remetente_id (nome, foto_perfil), 
          destinatario:profiles!destinatario_id (nome, foto_perfil)
        ''').or('remetente_id.eq.$meuId,destinatario_id.eq.$meuId').order('created_at', ascending: false);

    final Map<String, Map<String, dynamic>> map = {};
    for (var msg in res) {
      final id = msg['anuncio_id'].toString();
      final isMeRemetente = msg['remetente_id'] == meuId;
      
      if (isMeRemetente && msg['apagado_por_remetente'] == true) continue;
      if (!isMeRemetente && msg['apagado_por_destinatario'] == true) continue;

      final outroId = isMeRemetente ? msg['destinatario_id'].toString() : msg['remetente_id'].toString();
      final chatKey = '${id}_$outroId';

      if (!map.containsKey(chatKey)) {
        map[chatKey] = {
          'anuncio_id': id, 'outro_usuario_id': outroId,
          'titulo': msg['anuncios']?['titulo'] ?? 'Anúncio',
          'ultimo_texto': msg['texto'], 'data': msg['created_at'],
          'contato_nome': isMeRemetente ? msg['destinatario']['nome'] : msg['remetente']['nome'],
          'contato_foto': isMeRemetente ? msg['destinatario']['foto_perfil'] : msg['remetente']['foto_perfil'],
        };
      }
    }
    return map.values.toList();
  }

  Future<void> excluirConversaLocal(String anuncioId, String outroId) async {
    final meuId = _supabase.auth.currentUser?.id;
    if (meuId == null) return;
    
    await _supabase.from('mensagens').update({'apagado_por_remetente': true})
        .eq('anuncio_id', anuncioId).eq('remetente_id', meuId).eq('destinatario_id', outroId);
        
    await _supabase.from('mensagens').update({'apagado_por_destinatario': true})
        .eq('anuncio_id', anuncioId).eq('destinatario_id', meuId).eq('remetente_id', outroId);
  }

  void dispose() => _channel?.unsubscribe();
}