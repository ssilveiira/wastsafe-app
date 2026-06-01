import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/tela_base.dart';
import '../services/anuncio_service.dart';

class TelaAnunciar extends StatefulWidget {
  final Map<String, dynamic>? anuncioParaEditar;

  const TelaAnunciar({super.key, this.anuncioParaEditar});

  @override
  State<TelaAnunciar> createState() => _TelaAnunciarState();
}

class _TelaAnunciarState extends State<TelaAnunciar> {
  final _formKey = GlobalKey<FormState>();
  
  String _categoria = 'Categoria';
  String _estado = 'Seminovo';
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _precoCtrl = TextEditingController();
  
  bool _isDoacao = false;
  bool _loading = false;

  final List<({Uint8List bytes, String name})> _imagens = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _listaCategorias = [
    'Categoria',
    'Smartphones & Tablets',
    'Computadores & Notebooks',
    'Componentes (Hardware)',
    'Periféricos (Teclado/Mouse)',
    'Monitores & TVs',
    'Eletrodomésticos',
    'Áudio & Vídeo',
    'Acessórios & Cabos',
    'Outros'
  ];

  bool get _modoEdicao => widget.anuncioParaEditar != null;

  @override
  void initState() {
    super.initState();
    if (_modoEdicao) {
      final a = widget.anuncioParaEditar!;
      _tituloCtrl.text = a['titulo'] ?? '';
      _descCtrl.text = a['descricao'] ?? '';
      
      if (_listaCategorias.contains(a['categoria'])) {
        _categoria = a['categoria'];
      }
      
      if (['Novo', 'Seminovo', 'Descarte'].contains(a['estado'])) {
        _estado = a['estado'];
      }
      
      final preco = (a['preco'] as num?)?.toDouble() ?? 0.0;
      if (preco == 0 && a['is_doacao'] == true) {
        _isDoacao = true;
        _precoCtrl.clear();
      } else {
        _isDoacao = false;
        _precoCtrl.text = preco > 0 ? preco.toStringAsFixed(2) : '';
      }
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _precoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 1200);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imagens.add((bytes: bytes, name: picked.name)));
    }
  }

  void _removerImagem(int index) => setState(() => _imagens.removeAt(index));
Future<void> _realizarPublicacao() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);

    try {
      if (_modoEdicao) {
        await AnuncioService().atualizarAnuncio(
          id: widget.anuncioParaEditar!['id'] as String,
          titulo: _tituloCtrl.text.trim(),
          descricao: _descCtrl.text.trim(),
          preco: double.tryParse(_precoCtrl.text.replaceAll(',', '.')) ?? 0.0,
          categoria: _categoria,
          estado: _estado,
          isDoacao: _isDoacao,
          novasImagens: _imagens.isNotEmpty ? _imagens : null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anúncio atualizado com sucesso!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); 
        }
      } else {
        await AnuncioService().criarAnuncio(
          titulo: _tituloCtrl.text.trim(),
          descricao: _descCtrl.text.trim(),
          preco: double.tryParse(_precoCtrl.text.replaceAll(',', '.')) ?? 0.0,
          categoria: _categoria,
          estado: _estado,
          isDoacao: _isDoacao,
          imagens: _imagens,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anúncio publicado com sucesso!'), backgroundColor: AppTheme.primaryLight),
          );
          Navigator.pushReplacementNamed(context, '/meus-anuncios');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tituloPagina = _modoEdicao ? 'Editar Anúncio' : 'Criar Anúncio';
    final textoBotao = _modoEdicao ? 'Salvar Alterações' : 'Publicar Anúncio';
    final iconeBotao = _modoEdicao ? Icons.save_outlined : Icons.check_circle_outline;

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
    );

    return TelaBase(
      rotaAtiva: _modoEdicao ? '/meus-anuncios' : '/anunciar',
      showUserIcon: true,
      showAnunciarBtn: false,
      corpo: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_modoEdicao) 
                      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                    Text(tituloPagina, style: GoogleFonts.poppins(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 36)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Preencha os detalhes do componente eletrônico.', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 15)),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Wrap(
                    spacing: 48,
                    runSpacing: 40,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fotos do Produto', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                            const SizedBox(height: 6),
                            Text(
                              _modoEdicao 
                                ? 'Deixe vazio para manter as fotos atuais. Adicionar novas fotos irá substituir as antigas.' 
                                : 'Adicione imagens nítidas do componente.', 
                              style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMuted)
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => _pickImage(ImageSource.gallery),
                              child: Container(
                                width: double.infinity,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.4), width: 2, style: BorderStyle.solid),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppTheme.primary),
                                    const SizedBox(height: 8),
                                    Text('Selecionar Foto', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_imagens.isNotEmpty)
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: _imagens.asMap().entries.map((e) => Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.memory(e.value.bytes, fit: BoxFit.cover),
                                      ),
                                    ),
                                    Positioned(
                                      top: -6, right: -6,
                                      child: GestureDetector(
                                        onTap: () => _removerImagem(e.key),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                )).toList(),
                              ),
                          ],
                        ),
                      ),

                      Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Detalhes', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _tituloCtrl,
                                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                                style: GoogleFonts.poppins(fontSize: 14),
                                decoration: inputDecoration.copyWith(labelText: 'Título do Anúncio'),
                              ),
                              const SizedBox(height: 16),
                              
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _categoria,
                                      isExpanded: true, 
                                      decoration: inputDecoration.copyWith(labelText: 'Categoria'),
                                      items: _listaCategorias
                                          .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(
                                                  e,
                                                  overflow: TextOverflow.ellipsis, 
                                                  style: GoogleFonts.poppins(fontSize: 13), 
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (v) => setState(() => _categoria = v!),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _estado,
                                      isExpanded: true, 
                                      decoration: inputDecoration.copyWith(labelText: 'Estado'),
                                      items: ['Novo', 'Seminovo', 'Descarte']
                                          .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(
                                                  e,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(fontSize: 13),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (v) => setState(() => _estado = v!),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: _precoCtrl,
                                      keyboardType: TextInputType.number,
                                      enabled: !_isDoacao,
                                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _isDoacao ? Colors.grey : AppTheme.primary),
                                      decoration: inputDecoration.copyWith(
                                        labelText: _isDoacao ? 'Gratuito (Doação)' : 'Preço (R\$)',
                                        prefixIcon: !_isDoacao ? const Icon(Icons.attach_money, color: AppTheme.primary) : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Text('É Doação?', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted)),
                                        Switch(
                                          value: _isDoacao,
                                          activeTrackColor: AppTheme.primaryLight,
                                          activeThumbColor: AppTheme.primary,
                                          onChanged: (v) => setState(() {
                                            _isDoacao = v;
                                            if (v) _precoCtrl.clear();
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descCtrl,
                                maxLines: 4,
                                style: GoogleFonts.poppins(fontSize: 14),
                                decoration: inputDecoration.copyWith(labelText: 'Descrição', alignLabelWithHint: true),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _loading ? null : _realizarPublicacao,
                                  icon: _loading 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Icon(iconeBotao, size: 20),
                                  label: Text(_loading ? (_modoEdicao ? 'Salvando...' : 'Publicando...') : textoBotao),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
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
    );
  }
}