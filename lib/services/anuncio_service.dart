import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnuncioService {
  final _supabase = Supabase.instance.client;

  Future<void> criarAnuncio({
    required String titulo,
    required String descricao,
    required double preco,
    required String categoria,
    required String estado,
    required bool isDoacao,
    List<({Uint8List bytes, String name})> imagens = const [],
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    debugPrint('>>> Inserindo anúncio no banco...');
    final result = await _supabase
        .from('anuncios')
        .insert({
          'user_id': userId,
          'titulo': titulo,
          'descricao': descricao,
          'preco': isDoacao ? 0 : preco,
          'categoria': categoria,
          'estado': estado,
          'is_doacao': isDoacao,
        })
        .select('id')
        .single();

    final anuncioId = result['id'];
    debugPrint('>>> Anúncio criado com ID: $anuncioId');

    if (imagens.isNotEmpty) {
      debugPrint('>>> Iniciando upload de ${imagens.length} imagem(ns)');
      final List<String> urls = [];

      for (final imagem in imagens) {
        final extensao = imagem.name.split('.').last.toLowerCase();
        final path =
            'anuncios/$anuncioId/${DateTime.now().microsecondsSinceEpoch}.$extensao';

        try {
          await _supabase.storage.from('imagens').uploadBinary(
                path,
                imagem.bytes,
                fileOptions: FileOptions(
                  contentType: 'image/$extensao',
                  upsert: false,
                ),
              );

          final signedUrl = await _supabase.storage
              .from('imagens')
              .createSignedUrl(path, 60 * 60 * 24 * 365);
          urls.add(signedUrl);
        } catch (e) {
          debugPrint('>>> ERRO no upload: $e');
        }
      }

      if (urls.isNotEmpty) {
        await _supabase
            .from('anuncios')
            .update({'imagens': urls}).eq('id', anuncioId);
      }
    }
  }

  Future<void> atualizarAnuncio({
    required String id,
    required String titulo,
    required String descricao,
    required double preco,
    required String categoria,
    required String estado,
    required bool isDoacao,
    List<({Uint8List bytes, String name})>? novasImagens,
  }) async {
    await _supabase.from('anuncios').update({
      'titulo': titulo,
      'descricao': descricao,
      'preco': isDoacao ? 0 : preco,
      'categoria': categoria,
      'estado': estado,
      'is_doacao': isDoacao,
    }).eq('id', id);

    if (novasImagens != null && novasImagens.isNotEmpty) {
      final List<String> urls = [];
      for (final imagem in novasImagens) {
        final extensao = imagem.name.split('.').last.toLowerCase();
        final path =
            'anuncios/$id/${DateTime.now().microsecondsSinceEpoch}.$extensao';

        await _supabase.storage.from('imagens').uploadBinary(
              path,
              imagem.bytes,
              fileOptions:
                  FileOptions(contentType: 'image/$extensao', upsert: false),
            );

        final signedUrl = await _supabase.storage
            .from('imagens')
            .createSignedUrl(path, 60 * 60 * 24 * 365);
        urls.add(signedUrl);
      }
      await _supabase.from('anuncios').update({'imagens': urls}).eq('id', id);
    }
  }

  Future<List<Map<String, dynamic>>> listarAnuncios({
    String? busca,
    String? estado,
    String? categoria,
  }) async {
    var query =
        _supabase.from('anuncios').select('*, profiles(nome, foto_perfil)');

    if (busca != null && busca.isNotEmpty) {
      query = query.ilike('titulo', '%$busca%');
    }
    if (estado != null && estado != 'Todos') {
      query = query.eq('estado', estado);
    }
    if (categoria != null && categoria != 'Todas') {
      query = query.eq('categoria', categoria);
    }

    return await query.order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> listarMeusAnuncios() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    return await _supabase
        .from('anuncios')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  Future<void> alterarStatus(String anuncioId, String novoStatus) async {
    await _supabase
        .from('anuncios')
        .update({'status': novoStatus}).eq('id', anuncioId);
  }

  Future<void> deletarAnuncio(String id) async {
    final anuncio = await _supabase
        .from('anuncios')
        .select('imagens')
        .eq('id', id)
        .single();
    final imagens = anuncio['imagens'] as List<dynamic>?;

    if (imagens != null && imagens.isNotEmpty) {
      final paths = imagens.map((url) {
        final uri = Uri.parse(url as String);
        return uri.path.split('/imagens/').last;
      }).toList();

      await _supabase.storage.from('imagens').remove(paths);
    }

    await _supabase.from('anuncios').delete().eq('id', id);
  }
}
