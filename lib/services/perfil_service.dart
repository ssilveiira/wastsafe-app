import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> obterMeuPerfil() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final perfil =
        await _supabase.from('profiles').select().eq('id', user.id).single();
    perfil['email'] = user.email;
    return perfil;
  }

  Future<void> atualizarPerfil({
    required String nome,
    required String telefone,
    required String cep,
    required String bairro,
    ({Uint8List bytes, String name})? novaFoto,
    bool removerFoto = false,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    String? fotoUrl;

    if (removerFoto) {
      fotoUrl = null;
    } else if (novaFoto != null) {
      final extensao = novaFoto.name.split('.').last.toLowerCase();
      final path =
          'perfis/${user.id}_${DateTime.now().millisecondsSinceEpoch}.$extensao';

      await _supabase.storage.from('imagens').uploadBinary(
            path,
            novaFoto.bytes,
            fileOptions:
                FileOptions(contentType: 'image/$extensao', upsert: true),
          );

      fotoUrl = await _supabase.storage
          .from('imagens')
          .createSignedUrl(path, 60 * 60 * 24 * 365);
    }

    final Map<String, dynamic> dadosAtualizados = {
      'nome': nome,
      'telefone': telefone,
      'cep': cep,
      'bairro': bairro,
    };

    if (novaFoto != null || removerFoto) {
      dadosAtualizados['foto_perfil'] = fotoUrl;
    }

    await _supabase.from('profiles').update(dadosAtualizados).eq('id', user.id);
  }

  Future<void> excluirMinhaConta() async {
    await _supabase.rpc('delete_user');
    await _supabase.auth.signOut();
  }
}
