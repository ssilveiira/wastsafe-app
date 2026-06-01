import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../services/perfil_service.dart';
import '../theme/app_theme.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();

  final _perfilService = PerfilService();
  final ImagePicker _picker = ImagePicker();

  bool _loading = true;
  bool _salvando = false;
  bool _buscandoCep = false;

  String? _fotoUrlAtual;
  ({Uint8List bytes, String name})? _novaFotoBytes;
  bool _removerFoto = false;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    try {
      final perfil = await _perfilService.obterMeuPerfil();
      if (perfil != null && mounted) {
        setState(() {
          _nomeCtrl.text = perfil['nome'] ?? '';
          _emailCtrl.text = perfil['email'] ?? '';
          _telefoneCtrl.text = perfil['telefone'] ?? '';
          _cepCtrl.text = perfil['cep'] ?? '';
          _bairroCtrl.text = perfil['bairro'] ?? '';
          _fotoUrlAtual = perfil['foto_perfil'];
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _escolherFoto() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 500, maxHeight: 500);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _novaFotoBytes = (bytes: bytes, name: picked.name);
        _removerFoto = false;
      });
    }
  }

  void _apagarFoto() {
    setState(() {
      _novaFotoBytes = null;
      _removerFoto = true;
      _fotoUrlAtual = null;
    });
  }

  ImageProvider<Object>? _obterImagem() {
    if (_novaFotoBytes != null) {
      return MemoryImage(_novaFotoBytes!.bytes);
    } else if (_fotoUrlAtual != null && _fotoUrlAtual!.isNotEmpty) {
      return NetworkImage(_fotoUrlAtual!);
    }
    return null;
  }

  Future<void> _consultarCep(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length != 8) return;

    setState(() => _buscandoCep = true);
    try {
      final response =
          await http.get(Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'));
      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);
        if (dados['bairro'] != null && mounted) {
          setState(() {
            _bairroCtrl.text = dados['bairro'];
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar CEP: $e');
    } finally {
      if (mounted) setState(() => _buscandoCep = false);
    }
  }

  Future<void> _salvarDados() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      await _perfilService.atualizarPerfil(
        nome: _nomeCtrl.text.trim(),
        telefone: _telefoneCtrl.text.trim(),
        cep: _cepCtrl.text.trim(),
        bairro: _bairroCtrl.text.trim(),
        novaFoto: _novaFotoBytes,
        removerFoto: _removerFoto,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: Colors.green),
        );

        await _carregarPerfil();

        setState(() {
          _novaFotoBytes = null;
          _removerFoto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao atualizar: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text('Atenção',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
        content: Text(
          'Certeza que deseja fazer a exclusão?\nEsta ação apagará todos os seus anúncios, avaliações e mensagens de forma irreversível.',
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Não, cancelar',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _realizarExclusao();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Sim, excluir',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _realizarExclusao() async {
    setState(() => _loading = true);
    try {
      await _perfilService.excluirMinhaConta();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sua conta e todos os seus dados foram excluídos.'),
              backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      debugPrint('Erro ao excluir conta: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao excluir conta: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    _cepCtrl.dispose();
    _bairroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const WastSafeNavBar(activeRoute: '/perfil', showUserIcon: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _loading
                            ? const Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator())
                            : Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 50,
                                                backgroundColor: AppTheme
                                                    .primaryLight
                                                    .withValues(alpha: 0.1),
                                                backgroundImage: _obterImagem(),
                                                child: _obterImagem() == null
                                                    ? const Icon(Icons.person,
                                                        size: 50,
                                                        color: AppTheme.primary)
                                                    : null,
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: _escolherFoto,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                        color: AppTheme.primary,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 2)),
                                                    child: const Icon(
                                                        Icons.camera_alt,
                                                        size: 16,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (_novaFotoBytes != null ||
                                              _fotoUrlAtual != null) ...[
                                            const SizedBox(height: 8),
                                            TextButton.icon(
                                              onPressed: _apagarFoto,
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 16,
                                                  color: Colors.red),
                                              label: Text('Remover foto',
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.red,
                                                      fontSize: 12)),
                                            ),
                                          ] else ...[
                                            const SizedBox(height: 16),
                                          ]
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 40),
                                    Text('Nome Completo',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: AppTheme.textDark)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _nomeCtrl,
                                      validator: (v) =>
                                          v!.isEmpty ? 'Obrigatório' : null,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 14),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text('E-mail institucional/pessoal',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: AppTheme.textDark)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _emailCtrl,
                                      readOnly: true,
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade50,
                                        filled: true,
                                        prefixIcon: const Icon(
                                            Icons.lock_outline,
                                            size: 16),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 14),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Telefone / WhatsApp',
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                      color:
                                                          AppTheme.textDark)),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller: _telefoneCtrl,
                                                validator: (v) => v!.isEmpty
                                                    ? 'Obrigatório'
                                                    : null,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('CEP',
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                      color:
                                                          AppTheme.textDark)),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller: _cepCtrl,
                                                validator: (v) => v!.isEmpty
                                                    ? 'Obrigatório'
                                                    : null,
                                                onChanged: _consultarCep,
                                                decoration: InputDecoration(
                                                  suffixIcon: _buscandoCep
                                                      ? const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  12),
                                                          child:
                                                              CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2))
                                                      : const Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 18),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Text('Bairro',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: AppTheme.textDark)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _bairroCtrl,
                                      validator: (v) =>
                                          v!.isEmpty ? 'Obrigatório' : null,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 14),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            _salvando ? null : _salvarDados,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        child: _salvando
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2))
                                            : Text('Salvar Alterações',
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.w600)),
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    const Divider(),
                                    const SizedBox(height: 40),
                                    Text('Zona de Perigo',
                                        style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                    const SizedBox(height: 8),
                                    Text(
                                        'A exclusão da conta é permanente e removerá todas as suas credenciais, materiais anunciados e chats históricos.',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: AppTheme.textMuted)),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: _confirmarExclusao,
                                        icon: const Icon(Icons.delete_forever,
                                            size: 20),
                                        label: Text(
                                            'Excluir minha conta permanentemente',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600)),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                              color: Colors.red),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const WastSafeFooter(),
        ],
      ),
    );
  }
}
