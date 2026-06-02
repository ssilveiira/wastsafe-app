import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvaliacaoService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listarVendedores() async {
    final meuId = _supabase.auth.currentUser?.id;
    final response = await _supabase
        .from('profiles')
        .select('id, nome')
        .neq('id', meuId ?? '') 
        .order('nome');
    return response;
  }

  Future<void> criarAvaliacao({
    required String vendedorId,
    required String produtoNome,
    required int nota,
    required String comentario,
    Uint8List? imagemBytes,
    String? imagemExtensao,
  }) async {
    final meuId = _supabase.auth.currentUser?.id;
    if (meuId == null) throw Exception('Usuário não autenticado');

    String? imageUrl;

    if (imagemBytes != null && imagemExtensao != null) {
      final path = 'avaliacoes/${DateTime.now().microsecondsSinceEpoch}.$imagemExtensao';
      
      await _supabase.storage.from('imagens').uploadBinary(
        path, 
        imagemBytes,
        fileOptions: FileOptions(contentType: 'image/$imagemExtensao', upsert: false),
      );
      
      imageUrl = await _supabase.storage.from('imagens').createSignedUrl(path, 60 * 60 * 24 * 365);
    }

    await _supabase.from('avaliacoes').insert({
      'avaliador_id': meuId,
      'vendedor_id': vendedorId,
      'produto_nome': produtoNome,
      'nota': nota,
      'comentario': comentario,
      if (imageUrl != null) 'imagem': imageUrl,
    });
  }

  Future<List<Map<String, dynamic>>> listarAvaliacoes() async {
    final response = await _supabase
        .from('avaliacoes')
        .select('*, vendedor:profiles!vendedor_id(nome)')
        .order('created_at', ascending: false);
    return response;
  }
}