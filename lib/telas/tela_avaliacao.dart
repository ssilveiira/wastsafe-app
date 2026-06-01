import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/tela_base.dart';
import '../services/avaliacao_service.dart';

class TelaAvaliacao extends StatefulWidget {
  const TelaAvaliacao({super.key});
  @override
  State<TelaAvaliacao> createState() => _TelaAvaliacaoState();
}

class _TelaAvaliacaoState extends State<TelaAvaliacao> {
  final _formKey = GlobalKey<FormState>();
  final _produtoCtrl = TextEditingController();
  final _comentarioCtrl = TextEditingController();
  final _buscaVendedorCtrl =
      TextEditingController(); 

  List<Map<String, dynamic>> _avaliacoes = [];
  List<Map<String, dynamic>> _vendedores = [];
  String?
      _vendedorSelecionadoId; 
  int _nota = 5;

  Uint8List? _imagemBytes;
  String? _imagemExtensao;
  final ImagePicker _picker = ImagePicker();

  bool _loadingDados = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _loadingDados = true);

    final avService = AvaliacaoService();
    List<Map<String, dynamic>> vendedoresTemp = [];
    List<Map<String, dynamic>> avaliacoesTemp = [];

    try {
      vendedoresTemp = await avService.listarVendedores();
    } catch (e) {
      debugPrint('Erro ao carregar vendedores: $e');
    }

    try {
      avaliacoesTemp = await avService.listarAvaliacoes();
    } catch (e) {
      debugPrint('Erro ao carregar avaliações: $e');
    }

    if (mounted) {
      setState(() {
        _vendedores = vendedoresTemp;
        _avaliacoes = avaliacoesTemp;
        _loadingDados = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      setState(() {
        _imagemBytes = bytes;
        _imagemExtensao = ext;
      });
    }
  }

  Future<void> _enviarAvaliacao() async {
    if (!_formKey.currentState!.validate()) return;

    if (_vendedorSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor, busque e selecione um vendedor da lista.'),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() => _enviando = true);

    try {
      await AvaliacaoService().criarAvaliacao(
        vendedorId: _vendedorSelecionadoId!,
        produtoNome: _produtoCtrl.text.trim(),
        nota: _nota,
        comentario: _comentarioCtrl.text.trim(),
        imagemBytes: _imagemBytes,
        imagemExtensao: _imagemExtensao,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Avaliação enviada com sucesso!'),
              backgroundColor: Colors.green),
        );
        _formKey.currentState!.reset();
        _produtoCtrl.clear();
        _comentarioCtrl.clear();
        _buscaVendedorCtrl.clear();
        setState(() {
          _nota = 5;
          _imagemBytes = null;
          _imagemExtensao = null;
          _vendedorSelecionadoId = null;
        });
        _carregarDados();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao avaliar: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _produtoCtrl.dispose();
    _comentarioCtrl.dispose();
    _buscaVendedorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      rotaAtiva: '/avaliacao',
      showUserIcon: true,
      showAnunciarBtn: true,
      corpo: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text('Avaliações da Comunidade',
                        style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                    'Veja o que estão dizendo sobre os vendedores e materiais transacionados.',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppTheme.textMuted)),
                const SizedBox(height: 24),
                _loadingDados
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()))
                    : _avaliacoes.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                                child: Text(
                                    "Nenhuma avaliação encontrada ainda.")))
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 500,
                              mainAxisExtent: 175,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _avaliacoes.length,
                            itemBuilder: (context, index) =>
                                _buildCard(_avaliacoes[index]),
                          ),
                const SizedBox(height: 40),
                Container(height: 1, color: Colors.grey.shade200),
                const SizedBox(height: 40),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 750),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Deixe sua avaliação',
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark)),
                        const SizedBox(height: 4),
                        Text('Avalie o vendedor e o componente recebido.',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: AppTheme.textMuted)),
                        const SizedBox(height: 24),
                        _loadingDados
                            ? const CircularProgressIndicator()
                            : Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Wrap(
                                      spacing: 24,
                                      runSpacing: 16,
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          child: Autocomplete<
                                              Map<String, dynamic>>(
                                            displayStringForOption: (option) =>
                                                option['nome'],
                                            optionsBuilder: (TextEditingValue
                                                textEditingValue) {
                                              if (textEditingValue
                                                  .text.isEmpty) {
                                                return const Iterable<
                                                    Map<String,
                                                        dynamic>>.empty();
                                              }
                                              return _vendedores
                                                  .where((vendedor) {
                                                return vendedor['nome']
                                                    .toString()
                                                    .toLowerCase()
                                                    .contains(textEditingValue
                                                        .text
                                                        .toLowerCase());
                                              });
                                            },
                                            onSelected: (Map<String, dynamic>
                                                selection) {
                                              setState(() {
                                                _vendedorSelecionadoId =
                                                    selection['id'];
                                                _buscaVendedorCtrl.text =
                                                    selection['nome'];
                                              });
                                            },
                                            fieldViewBuilder: (context,
                                                controller,
                                                focusNode,
                                                onEditingComplete) {
                                              return TextFormField(
                                                controller: controller,
                                                focusNode: focusNode,
                                                onEditingComplete:
                                                    onEditingComplete,
                                                decoration: InputDecoration(
                                                  labelText: 'Buscar Vendedor',
                                                  hintText: 'Digite o nome...',
                                                  labelStyle:
                                                      GoogleFonts.poppins(
                                                          fontSize: 13,
                                                          color: AppTheme
                                                              .textMuted),
                                                  prefixIcon: const Icon(
                                                      Icons.search,
                                                      size: 18),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 14),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                ),
                                                onChanged: (value) {
                                                  if (value.isEmpty) {
                                                    setState(() =>
                                                        _vendedorSelecionadoId =
                                                            null);
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ),

                                        SizedBox(
                                          width: 250,
                                          child: TextFormField(
                                            controller: _produtoCtrl,
                                            validator: (v) => v!.isEmpty
                                                ? 'Obrigatório'
                                                : null,
                                            decoration: InputDecoration(
                                              labelText: 'Produto Comprado',
                                              labelStyle: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: AppTheme.textMuted),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Nota:',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade300),
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: DropdownButton<int>(
                                                value: _nota,
                                                underline: const SizedBox(),
                                                icon: const Icon(
                                                    Icons.star_rounded,
                                                    color: Colors.amber,
                                                    size: 20),
                                                items: [5, 4, 3, 2, 1]
                                                    .map((n) => DropdownMenuItem(
                                                        value: n,
                                                        child: Text(' $n',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600))))
                                                    .toList(),
                                                onChanged: (v) =>
                                                    setState(() => _nota = v!),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    TextFormField(
                                      controller: _comentarioCtrl,
                                      maxLines: 4,
                                      validator: (v) => v!.isEmpty
                                          ? 'Por favor, deixe um comentário'
                                          : null,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Conte como foi sua experiência...',
                                        hintStyle: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey.shade400),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Wrap(
                                      spacing: 24,
                                      runSpacing: 16,
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: _pickImage,
                                              icon: const Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 18),
                                              label:
                                                  const Text('Adicionar foto'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    AppTheme.primary,
                                                side: const BorderSide(
                                                    color:
                                                        AppTheme.primaryLight),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 14),
                                                textStyle: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            if (_imagemBytes != null) ...[
                                              const SizedBox(width: 16),
                                              Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: Image.memory(
                                                          _imagemBytes!,
                                                          width: 50,
                                                          height: 50,
                                                          fit: BoxFit.cover)),
                                                  Positioned(
                                                    top: -6,
                                                    right: -6,
                                                    child: GestureDetector(
                                                      onTap: () => setState(() {
                                                        _imagemBytes = null;
                                                        _imagemExtensao = null;
                                                      }),
                                                      child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          decoration:
                                                              const BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  shape: BoxShape
                                                                      .circle),
                                                          child: const Icon(
                                                              Icons.close,
                                                              size: 12,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: _enviando
                                              ? null
                                              : _enviarAvaliacao,
                                          icon: _enviando
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2))
                                              : const Icon(Icons.send_rounded,
                                                  size: 18),
                                          label: Text(_enviando
                                              ? 'Enviando...'
                                              : 'Enviar Avaliação'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primary,
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor:
                                                Colors.grey.shade300,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 32, vertical: 16),
                                            textStyle: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> av) {
    final date = DateTime.tryParse(av['created_at'].toString())?.toLocal() ??
        DateTime.now();
    final dataFormatada =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final vendedorNome = av['vendedor'] != null
        ? av['vendedor']['nome']
        : 'Usuário Desconhecido';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (av['imagem'] != null)
              ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(av['imagem'],
                      width: 70, height: 70, fit: BoxFit.cover))
            else
              Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.image_not_supported_outlined,
                      color: Colors.grey.shade400, size: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(av['produto_nome'] ?? 'Produto',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('Vendido por $vendedorNome',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 8),
                  Row(
                      children: List.generate(
                          5,
                          (i) => Icon(
                              i < (av['nota'] as int)
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 16))),
                  const SizedBox(height: 8),
                  if (av['comentario'] != null)
                    Expanded(
                        child: Text(av['comentario'],
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.textDark,
                                height: 1.3),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis)),
                  const SizedBox(height: 4),
                  Text(dataFormatada,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
