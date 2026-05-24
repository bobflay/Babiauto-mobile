import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/flow_shell.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class BabiautoApp extends StatelessWidget {
  const BabiautoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..bootstrap(),
      child: MaterialApp(
        title: 'Babiauto',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: const FlowShell(),
      ),
    );
  }
}
