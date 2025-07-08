// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/navigation/app_router.dart';
import 'package:flutter_crm_app/core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_crm_app/core/services/firebase_messaging_service.dart';
import 'firebase_options.dart';
import 'package:flutter_crm_app/core/config/app_config.dart'; // Importar AppConfig para el log de inicio
import 'package:flutter_crm_app/core/network/dio_client.dart'; // Importar AppLogger

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- Nuevo Log de Inicio ---
  AppLogger.log('App START: AppConfig.baseUrl al inicio: ${AppConfig.baseUrl}');
  // -------------------------

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await FirebaseMessagingService().initialize();

  await initializeDateFormatting('es_ES', null);  
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Century 21 CRM',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}