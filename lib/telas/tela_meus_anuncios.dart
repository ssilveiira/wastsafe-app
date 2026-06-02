import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/tela_base.dart';
import '../services/anuncio_service.dart';
import '../theme/app_theme.dart';
import 'tela_anunciar.dart';

class TelaMeusAnuncios extends StatefulWidget {
  const TelaMeusAnuncios({super.key});

  @override
  State<TelaMeusAnuncios> createState() => _TelaMeusAnunciosState();
}

class _TelaMeusAnunciosState extends State<TelaMeusAnuncios> {
  List<Map<String, dynamic>> _anuncios = [];
  bool _loading = true;

  int _totalAvaliacoes = 0;
  double _notaMedia = 0.0;

  @override
  void initState() {
    super.initState();
    _carregarDadosCompletos();
  }

  Future<void> _carregarDadosCompletos() async {
    setState(() {
      _loading = true;
    });
    try {
      final lista = await AnuncioService().listarMeusAnuncios();

      final meuId = Supabase.instance.client.auth.currentUser?.id;
      if (meuId != null) {
        final resAvaliacoes = await Supabase.instance.client
            .from('avaliacoes')
            .select('nota')
            .eq('vendedor_id', meuId);

        int totalNotas = 0;
        for (var av in resAvaliacoes) {
          totalNotas += av['nota'] as int;
        }

        if (mounted) {
          setState(() {
            _anuncios = lista;
            _totalAvaliacoes = resAvaliacoes.length;
            _notaMedia = resAvaliacoes.isEmpty
                ? 0.0
                : (totalNotas / resAvaliacoes.length);
            _loading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pausarOuAtivar(Map<String, dynamic> anuncio) async {
    final novoStatus = anuncio['status'] == 'ativo' ? 'pausado' : 'ativo';
    final id = anuncio['id'].toString();

    try {
      await AnuncioService().alterarStatus(id, novoStatus);
      _carregarDadosCompletos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao pausar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _excluirAnuncio(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Excluir anúncio',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
            'Tem certeza que deseja excluir este anúncio permanentemente?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, elevation: 0),
            child: Text('Excluir',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await AnuncioService().deletarAnuncio(id);
        _carregarDadosCompletos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Anúncio excluído com sucesso!'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildDashboardMetricas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;

        final metricasBloco = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child:
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 40),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reputação',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(_notaMedia.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark)),
                    const SizedBox(width: 8),
                    Text('/ 5.0',
                        style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 24),
            Container(height: 50, width: 1, color: Colors.grey.shade200),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Avaliações',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: AppTheme.textMuted)),
                Text('$_totalAvaliacoes comentários',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary)),
              ],
            ),
          ],
        );

        final botaoLerComentarios = OutlinedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/meus-comentarios');
          },
          icon: const Icon(Icons.forum_outlined, size: 18),
          label: Text('Ler Comentários',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary,
            side: const BorderSide(color: AppTheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: metricasBloco,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, child: botaoLerComentarios),
                  ],
                )
              : Row(
                  children: [
                    metricasBloco,
                    const Spacer(),
                    botaoLerComentarios,
                  ],
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      rotaAtiva: '/meus-anuncios',
      showUserIcon: true,
      showAnunciarBtn: true,
      corpo: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // CABEÇALHO CORRIGIDO: Título e Botão separados
                // ==========================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text('Meus Anúncios',
                          style: GoogleFonts.poppins(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 32)),
                    ),
                    const SizedBox(width: 16), // Espaço garantido entre o título e o botão
                    if (!_loading && _anuncios.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/anunciar'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Novo Anúncio'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    'Gerencie seus produtos e veja sua reputação na plataforma.',
                    style: GoogleFonts.poppins(
                        color: AppTheme.textMuted, fontSize: 15)),
                const SizedBox(height: 32),
                if (!_loading) _buildDashboardMetricas(),
                _loading
                    ? const Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(child: CircularProgressIndicator()))
                    : _anuncios.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _anuncios.length,
                            itemBuilder: (context, index) =>
                                _buildAnuncioCard(_anuncios[index]),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text('Nenhum anúncio encontrado',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text('Você ainda não cadastrou nenhum componente.',
              style:
                  GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMuted)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/anunciar'),
            icon: const Icon(Icons.add),
            label: Text('Criar Meu Primeiro Anúncio',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }

  Widget _buildAnuncioCard(Map<String, dynamic> anuncio) {
    final status = anuncio['status'] ?? 'ativo';
    final isActive = status == 'ativo';
    final preco = (anuncio['preco'] as num?)?.toDouble() ?? 0.0;
    final isDoacao = anuncio['is_doacao'] == true || preco == 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        final acoesBotoes = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'Editar Anúncio',
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TelaAnunciar(anuncioParaEditar: anuncio)))
                      .then((atualizou) {
                    if (atualizou == true) {
                      _carregarDadosCompletos();
                    }
                  });
                },
                icon: Icon(Icons.edit_outlined, color: Colors.blue.shade600),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade50),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: isActive
                  ? 'Pausar (Tirar do ar)'
                  : 'Reativar (Voltar pra vitrine)',
              child: IconButton(
                onPressed: () => _pausarOuAtivar(anuncio),
                icon: Icon(
                    isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    color: Colors.orange.shade600),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.orange.shade50),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Excluir Anúncio',
              child: IconButton(
                onPressed: () => _excluirAnuncio(anuncio['id'].toString()),
                icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
                style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
              ),
            ),
          ],
        );

        final infoProduto = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    isActive
                        ? 'ATIVO NO MARKETPLACE'
                        : 'PAUSADO / NEGOCIADO',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? Colors.green.shade700
                            : Colors.orange.shade700),
                  ),
                ),
                Text(anuncio['categoria'] ?? 'Componente',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              anuncio['titulo'] ?? 'Sem título',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isActive ? AppTheme.textDark : Colors.grey.shade500,
                decoration: isActive
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isDoacao
                  ? 'Doação (Gratuito)'
                  : 'R\$ ${preco.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDoacao
                      ? Colors.green
                      : (isActive ? AppTheme.primary : Colors.grey)),
            ),
          ],
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Opacity(
                            opacity: isActive ? 1.0 : 0.5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: (anuncio['imagens'] != null &&
                                      (anuncio['imagens'] as List).isNotEmpty)
                                  ? Image.network(
                                      (anuncio['imagens'] as List).first as String,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _fallbackImage(),
                                    )
                                  : _fallbackImage(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: infoProduto),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: acoesBotoes,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: isActive ? 1.0 : 0.5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: (anuncio['imagens'] != null &&
                                  (anuncio['imagens'] as List).isNotEmpty)
                              ? Image.network(
                                  (anuncio['imagens'] as List).first as String,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _fallbackImage(),
                                )
                              : _fallbackImage(),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(child: infoProduto),
                      acoesBotoes,
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _fallbackImage() {
    return Container(
        width: 100,
        height: 100,
        color: Colors.grey.shade100,
        child: Icon(Icons.image_not_supported_outlined,
            color: Colors.grey.shade400, size: 32));
  }
}