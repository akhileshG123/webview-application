import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_application/widgets/providers/webview_provider.dart';
import 'package:webview_application/widgets/screens/main_screen.dart';
import 'package:webview_application/repositories/platform_repository.dart';

void main() {
  final platforms = PlatformRepository().getPlatforms();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WebViewProvider(platforms)),
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gaming Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}