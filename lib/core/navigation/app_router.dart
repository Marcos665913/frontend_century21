// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_crm_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_crm_app/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_crm_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_crm_app/features/clients/presentation/screens/client_list_screen.dart';
import 'package:flutter_crm_app/features/clients/presentation/screens/client_form_screen.dart';
import 'package:flutter_crm_app/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:flutter_crm_app/features/users_management/presentation/screens/user_list_screen.dart';
import 'package:flutter_crm_app/features/users_management/presentation/screens/user_profile_screen.dart';
import 'package:flutter_crm_app/features/custom_fields/presentation/screens/manage_custom_fields_screen.dart';
import 'package:flutter_crm_app/features/reminders/presentation/screens/reminder_list_screen.dart';
import 'package:flutter_crm_app/features/reminders/presentation/screens/schedule_reminder_screen.dart';
import 'package:flutter_crm_app/core/network/dio_client.dart'; // Para AppLogger

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/manage-custom-fields',
        builder: (context, state) => const ManageCustomFieldsScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // --- INICIO DE LA CORRECCIÓN: Rutas de Clientes ---
          // Usaremos rutas con nombres para una navegación más clara y controlada
          GoRoute(
            path: 'clients',
            name: 'clientsList', // Nombre de la ruta para la lista de clientes
            builder: (context, state) => const ClientListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'newClient', // Nombre de la ruta para nuevo cliente
                builder: (context, state) => const ClientFormScreen(),
              ),
              GoRoute(
                path: ':clientId',
                name: 'clientDetail', // Nombre de la ruta para detalle de cliente
                builder: (context, state) {
                  final clientId = state.pathParameters['clientId']!;
                  return ClientDetailScreen(clientId: clientId);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'editClient', // Nombre de la ruta para editar cliente
                    builder: (context, state) {
                      final clientId = state.pathParameters['clientId']!;
                      return ClientFormScreen(clientId: clientId);
                    },
                  ),
                ]
              ),
            ]
          ),
          // --- FIN DE LA CORRECCIÓN: Rutas de Clientes ---

          GoRoute(
            path: 'users',
            builder: (context, state) => const UserListScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const UserProfileScreen(),
          ),
          
          // --- RUTAS DE RECORDATORIOS ACTIVADAS ---
          GoRoute(
            path: 'reminders',
            builder: (context, state) => const ReminderListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) {
                  final clientId = state.uri.queryParameters['clientId'];
                  return ScheduleReminderScreen(clientId: clientId);
                },
              ),
            ]
          ),
        ]
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authState.status == AuthStatus.authenticated;
      final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!loggedIn && !loggingIn) {
        AppLogger.log('GoRouter Redirect: No logueado, redirigiendo a /login');
        return '/login';
      }
      if (loggedIn && loggingIn) {
        AppLogger.log('GoRouter Redirect: Logueado, redirigiendo a /');
        return '/';
      }
      AppLogger.log('GoRouter Redirect: No se necesita redirección.');
      return null;
    },
  );
});