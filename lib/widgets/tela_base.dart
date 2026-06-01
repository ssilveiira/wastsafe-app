import 'package:flutter/material.dart';
import 'navbar.dart';
import 'footer.dart';

class TelaBase extends StatelessWidget {
  final Widget corpo;
  final String rotaAtiva;
  final bool showUserIcon;
  final bool showAnunciarBtn;

  const TelaBase({
    super.key,
    required this.corpo,
    required this.rotaAtiva,
    this.showUserIcon = false,
    this.showAnunciarBtn = false,
  });

  @override
  Widget build(BuildContext context) {
    const double alturaAppBar = 68;
    final double alturaDisponivel = MediaQuery.of(context).size.height -
        alturaAppBar -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: WastSafeNavBar(
        activeRoute: rotaAtiva,
        showUserIcon: showUserIcon,
        showAnunciarBtn: showAnunciarBtn,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: alturaDisponivel),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              corpo,
              const WastSafeFooter(),
            ],
          ),
        ),
      ),
    );
  }
}