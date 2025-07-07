import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/common_widgets/role_specific_widget.dart';
import 'package:flutter_crm_app/core/constants/enums.dart';
import 'package:flutter_crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_crm_app/features/clients/presentation/providers/client_provider.dart';
import 'package:flutter_crm_app/features/clients/presentation/screens/client_list_screen.dart';
import 'package:flutter_crm_app/features/reminders/presentation/screens/reminder_list_screen.dart';
import 'package:flutter_crm_app/features/users_management/presentation/screens/user_list_screen.dart';
import 'package:flutter_crm_app/features/users_management/presentation/screens/user_profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _isExporting = false; // Estado para mostrar un indicador de carga

  static const List<Widget> _widgetOptions = <Widget>[
    ClientListScreen(),
    ReminderListScreen(),
    UserListScreen(),
    UserProfileScreen(),
  ];

  static const List<String> _appBarTitles = <String>[
    'Clientes',
    'Recordatorios',
    'Gestión de Usuarios',
    'Mi Perfil',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        actions: const [],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(user?.email ?? 'email@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                  style: TextStyle(fontSize: 40.0, color: Theme.of(context).primaryColor),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            // --- INICIO DE NUEVO BOTÓN ---
            ListTile(
              leading: _isExporting 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))
                  : const Icon(Icons.download_for_offline_outlined),
              title: const Text('Descargar Mis Clientes'),
              onTap: _isExporting ? null : () async {
                setState(() => _isExporting = true);
                
                final errorMessage = await ref.read(clientNotifierProvider.notifier).exportClientsToExcel();
                
                if (mounted) {
                  setState(() => _isExporting = false);
                  if (errorMessage != null) {
                    Fluttertoast.showToast(msg: errorMessage, backgroundColor: Colors.red);
                  } else {
                    Fluttertoast.showToast(msg: "Archivo guardado en Descargas.", toastLength: Toast.LENGTH_LONG);
                  }
                  Navigator.pop(context); // Cierra el drawer
                }
              },
            ),
            // --- FIN DE NUEVO BOTÓN ---

            RoleSpecificWidget(
              allowedRoles: const [UserRole.master],
              child: ListTile(
                leading: const Icon(Icons.add_comment_outlined),
                title: const Text('Gestionar Campos'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/manage-custom-fields');
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () async {
                await ref.read(authNotifierProvider.notifier).logout();
                if (mounted) {
                  context.go('/login'); 
                }
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clientes'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Recordatorios'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Usuarios'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
      ),
    );
  }
}
