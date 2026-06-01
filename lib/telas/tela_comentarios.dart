import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../theme/app_theme.dart';

class TelaComentarios extends StatefulWidget {
  const TelaComentarios({super.key});

  @override
  State<TelaComentarios> createState() => _TelaComentariosState();
}

class _TelaComentariosState extends State<TelaComentarios> {
  List<Map<String, dynamic>> _comentarios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarMeusComentarios();
  }

  Future<void> _carregarMeusComentarios() async {
    try {
      final meuId = Supabase.instance.client.auth.currentUser?.id;
      if (meuId == null) return;

      final res = await Supabase.instance.client
          .from('avaliacoes')
          .select()
          .eq('vendedor_id', meuId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _comentarios = List<Map<String, dynamic>>.from(res);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar comentários: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const WastSafeNavBar(
          activeRoute: '/meus-anuncios', showUserIcon: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: AppTheme.textDark),
                            tooltip: 'Voltar',
                          ),
                          const SizedBox(width: 8),
                          Text('Meus Comentários',
                              style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 48),
                        child: Text(
                            'Veja o feedback detalhado dos recicladores e compradores sobre você.',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: AppTheme.textMuted)),
                      ),
                      const SizedBox(height: 32),
                      _loading
                          ? const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator()))
                          : _comentarios.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _comentarios.length,
                                  itemBuilder: (context, index) =>
                                      _buildComentarioCard(_comentarios[index]),
                                ),
                    ],
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Nenhuma avaliação recebida',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text(
              'Quando os usuários avaliarem suas negociações, elas aparecerão aqui.',
              style: GoogleFonts.poppins(color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildComentarioCard(Map<String, dynamic> av) {
    final date = DateTime.tryParse(av['created_at'].toString())?.toLocal() ??
        DateTime.now();
    final dataFormatada =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (av['imagem'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(av['imagem'],
                  width: 80, height: 80, fit: BoxFit.cover),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.image_not_supported_outlined,
                  color: Colors.grey.shade300, size: 32),
            ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(av['produto_nome'] ?? 'Produto',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark)),
                    Text(dataFormatada,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                      5,
                      (i) => Icon(
                            i < (av['nota'] as int)
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 18,
                          )),
                ),
                const SizedBox(height: 12),
                if (av['comentario'] != null && strNotEmpty(av['comentario']))
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200)),
                    child: Text('"${av['comentario']}"',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            fontStyle: FontStyle.italic)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool strNotEmpty(dynamic str) {
    return str != null && str.toString().trim().isNotEmpty;
  }
}
