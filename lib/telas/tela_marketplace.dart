import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../theme/app_theme.dart';
import '../services/anuncio_service.dart';
import 'tela_chat.dart';

class TelaMarketplace extends StatefulWidget {
  const TelaMarketplace({super.key});
  @override
  State<TelaMarketplace> createState() => _TelaMarketplaceState();
}

class _TelaMarketplaceState extends State<TelaMarketplace> {
  final _searchCtrl = TextEditingController();
  String _filtroEstado = 'Todos';
  String _filtroCategoria = 'Todas';
  int _paginaAtual = 1;
  static const int _itensPorPagina = 8;
  String? _produtoZoom;

  List<Map<String, dynamic>> _todosProdutos = [];
  bool _loading = true;

  final List<String> _categoriasFiltro = [
    'Todas',
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

  @override
  void initState() {
    super.initState();
    _carregarAnuncios();
  }

  Future<void> _carregarAnuncios() async {
    setState(() {
      _loading = true;
    });
    try {
      final anuncios = await AnuncioService().listarAnuncios();
      final convertidos = anuncios.map((a) {
        final imagens = a['imagens'] as List<dynamic>?;
        return {
          'id': a['id'],
          'nome': a['titulo'] ?? 'Sem título',
          'preco': 'R\$ ${(a['preco'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
          'imagem': (imagens != null && imagens.isNotEmpty)
              ? imagens.first as String
              : null,
          'categoria': a['categoria'] ?? 'Outros',
          'estado': a['estado'] ?? 'Seminovo',
          'vendedor': (a['profiles'] != null)
              ? (a['profiles']['nome'] ?? 'Anônimo')
              : 'Anônimo',
          'vendedor_foto':
              (a['profiles'] != null) ? a['profiles']['foto_perfil'] : null,
          'descricao': a['descricao'] ?? '',
          'user_id': a['user_id'],
          'status': a['status'] ?? 'ativo',
        };
      }).toList();

      setState(() {
        _todosProdutos = convertidos;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar anúncios: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _produtosFiltrados {
    return _todosProdutos.where((p) {
      final matchSearch = _searchCtrl.text.isEmpty ||
          (p['nome'] as String)
              .toLowerCase()
              .contains(_searchCtrl.text.toLowerCase());
      final matchEstado =
          _filtroEstado == 'Todos' || p['estado'] == _filtroEstado;
      final matchCategoria =
          _filtroCategoria == 'Todas' || p['categoria'] == _filtroCategoria;
      return matchSearch && matchEstado && matchCategoria;
    }).toList();
  }

  int get _totalPaginas => (_produtosFiltrados.length / _itensPorPagina).ceil();

  List<Map<String, dynamic>> get _produtosPagina {
    final inicio = (_paginaAtual - 1) * _itensPorPagina;
    final fim = inicio + _itensPorPagina;
    return _produtosFiltrados.sublist(
      inicio,
      fim > _produtosFiltrados.length ? _produtosFiltrados.length : fim,
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) {
                setState(() {
                  _paginaAtual = 1;
                });
              },
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Pesquisar materiais...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.primaryLight),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filtroCategoria,
                  isExpanded: true,
                  icon: const Icon(Icons.layers_outlined,
                      color: AppTheme.primary, size: 20),
                  style: GoogleFonts.poppins(
                      color: AppTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  items: _categoriasFiltro
                      .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _filtroCategoria = v!;
                      _paginaAtual = 1;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filtroEstado,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: AppTheme.primary),
                  style: GoogleFonts.poppins(
                      color: AppTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  items: ['Todos', 'Novo', 'Seminovo', 'Descarte']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _filtroEstado = v!;
                      _paginaAtual = 1;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraPaginacao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _paginaAtual > 1
              ? () {
                  setState(() {
                    _paginaAtual--;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        ...List.generate(_totalPaginas, (i) {
          final pagina = i + 1;
          return GestureDetector(
            onTap: () {
              setState(() {
                _paginaAtual = pagina;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _paginaAtual == pagina
                    ? AppTheme.primary
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$pagina',
                style: GoogleFonts.poppins(
                    color: _paginaAtual == pagina
                        ? Colors.white
                        : AppTheme.textDark,
                    fontWeight: FontWeight.w600),
              ),
            ),
          );
        }),
        IconButton(
          onPressed: _paginaAtual < _totalPaginas
              ? () {
                  setState(() {
                    _paginaAtual++;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _produtoCard(Map<String, dynamic> produto) {
    return _CardWidget(
      produto: produto,
      onTap: () => _abrirDetalhes(produto),
      onZoom: () {
        setState(() {
          _produtoZoom = produto['imagem'];
        });
      },
      onUpdate: _carregarAnuncios,
    );
  }

  void _abrirDetalhes(Map<String, dynamic> produto) {
    final bool isPausado = produto['status'] == 'pausado';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SizedBox(
          width: 600,
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (produto['imagem'] != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _produtoZoom = produto['imagem'];
                            });
                          },
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24)),
                            child: Image.network(
                              produto['imagem'],
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              color: isPausado
                                  ? Colors.black.withValues(alpha: 0.5)
                                  : null,
                              colorBlendMode:
                                  isPausado ? BlendMode.darken : null,
                              errorBuilder: (_, __, ___) => Container(
                                height: 200,
                                color: Colors.grey.shade100,
                                child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 48,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _corEstado(produto['estado'])
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    produto['estado'],
                                    style: GoogleFonts.poppins(
                                        color: _corEstado(produto['estado']),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  produto['preco'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: isPausado
                                        ? Colors.grey
                                        : AppTheme.primary,
                                    decoration: isPausado
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              produto['nome'],
                              style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Categoria: ${produto['categoria']}',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              produto['descricao'] ?? '',
                              style: GoogleFonts.poppins(
                                  color: AppTheme.textMuted,
                                  height: 1.6,
                                  fontSize: 14),
                            ),
                            if (isPausado) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded,
                                        color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text(
                                            'Este material foi pausado pelo vendedor e não está mais aceitando propostas.',
                                            style: GoogleFonts.poppins(
                                                color: Colors.orange.shade800,
                                                fontSize: 12))),
                                  ],
                                ),
                              )
                            ],
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // RODAPÉ FIXO DO MODAL (COM FOTO DO VENDEDOR)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4))
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          AppTheme.primaryLight.withValues(alpha: 0.2),
                      backgroundImage: produto['vendedor_foto'] != null
                          ? NetworkImage(produto['vendedor_foto'])
                          : null,
                      child: produto['vendedor_foto'] == null
                          ? const Icon(Icons.person,
                              color: AppTheme.primary, size: 24)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vendedor: ${produto['vendedor']}',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark),
                              overflow: TextOverflow.ellipsis),
                          Text(
                              isPausado
                                  ? 'Negociação Encerrada'
                                  : 'Clique para conversar',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: isPausado
                          ? null
                          : () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          TelaChat(anuncio: produto)));
                            },
                      icon: Icon(
                          isPausado ? Icons.block : Icons.chat_bubble_outline,
                          size: 18),
                      label: Text(isPausado ? 'Pausado' : 'Conversar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isPausado ? Colors.grey.shade300 : AppTheme.primary,
                        foregroundColor:
                            isPausado ? Colors.grey.shade600 : Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _corEstado(String estado) {
    switch (estado) {
      case 'Novo':
        return Colors.green;
      case 'Seminovo':
        return Colors.orange;
      case 'Descarte':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Widget? paginacao = _totalPaginas > 1 ? _barraPaginacao() : null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const WastSafeNavBar(activeRoute: '/marketplace'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Marketplace',
                                style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary)),
                            const SizedBox(height: 24),
                            _buildFiltros(),
                            const SizedBox(height: 16),
                            Text(
                                '${_produtosFiltrados.length} produto(s) encontrado(s)',
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: AppTheme.textMuted)),
                            const SizedBox(height: 24),
                            _produtosFiltrados.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 60),
                                      child: Column(
                                        children: [
                                          Icon(Icons.search_off_outlined,
                                              size: 64,
                                              color: Colors.grey.shade300),
                                          const SizedBox(height: 16),
                                          Text('Nenhum material encontrado.',
                                              style: GoogleFonts.poppins(
                                                  color: AppTheme.textMuted,
                                                  fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 280,
                                            mainAxisExtent: 360,
                                            crossAxisSpacing: 24,
                                            mainAxisSpacing: 24),
                                    itemCount: _produtosPagina.length,
                                    itemBuilder: (context, index) =>
                                        _produtoCard(_produtosPagina[index]),
                                  ),
                            if (paginacao != null) ...[
                              const SizedBox(height: 40),
                              paginacao
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                  const WastSafeFooter(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _produtoZoom != null
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _produtoZoom = null;
                });
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.close, color: Colors.black),
            )
          : null,
    );
  }
}

class _CardWidget extends StatefulWidget {
  final Map<String, dynamic> produto;
  final VoidCallback onTap;
  final VoidCallback onZoom;
  final VoidCallback onUpdate;

  const _CardWidget({
    required this.produto,
    required this.onTap,
    required this.onZoom,
    required this.onUpdate,
  });

  @override
  State<_CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<_CardWidget> {
  bool _hovered = false;

  Color _corEstado(String estado) {
    switch (estado) {
      case 'Novo':
        return Colors.green;
      case 'Seminovo':
        return Colors.orange;
      case 'Descarte':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPausado = widget.produto['status'] == 'pausado';

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _hovered
              ? (Matrix4.identity()..setTranslationRaw(0, -6, 0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _hovered && !isPausado
                    ? AppTheme.primaryLight
                    : Colors.transparent,
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: _hovered ? 0.12 : 0.04),
                  blurRadius: _hovered ? 20 : 10,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  children: [
                    Opacity(
                      opacity: isPausado ? 0.5 : 1.0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                        child: widget.produto['imagem'] != null
                            ? Image.network(
                                widget.produto['imagem'] as String,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade100,
                                    child: const Center(
                                        child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: Colors.grey))),
                              )
                            : Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                    child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey))),
                      ),
                    ),
                    if (widget.produto['imagem'] != null && !isPausado)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: widget.onZoom,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.zoom_in,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color:
                                _corEstado(widget.produto['estado'] as String),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(widget.produto['estado'] as String,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    if (isPausado)
                      Positioned(
                        top: 75,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.8),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          alignment: Alignment.center,
                          child: Text('PAUSADO',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                  fontSize: 14)),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.produto['nome'] as String,
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isPausado ? Colors.grey : AppTheme.textDark,
                            decoration:
                                isPausado ? TextDecoration.lineThrough : null),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(widget.produto['categoria'] as String,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 9,
                            backgroundColor:
                                AppTheme.primaryLight.withValues(alpha: 0.2),
                            backgroundImage: widget.produto['vendedor_foto'] !=
                                    null
                                ? NetworkImage(widget.produto['vendedor_foto'])
                                : null,
                            child: widget.produto['vendedor_foto'] == null
                                ? const Icon(Icons.person,
                                    size: 12, color: AppTheme.primary)
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(widget.produto['vendedor'] as String,
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: AppTheme.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        widget.produto['preco'] as String,
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isPausado ? Colors.grey : AppTheme.primary,
                            decoration:
                                isPausado ? TextDecoration.lineThrough : null),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
