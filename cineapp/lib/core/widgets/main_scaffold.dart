import 'package:flutter/material.dart';
import 'app_bottom_nav.dart';

/// Wrapper do ShellRoute — mantém o [AppBottomNav] persistente
/// enquanto as tabs (Home, Busca, Bilhetes, Perfil) são trocadas.
/// Referenciado no GoRouter:
///   ShellRoute(builder: (ctx, state, child) => MainScaffold(child: child))
class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}