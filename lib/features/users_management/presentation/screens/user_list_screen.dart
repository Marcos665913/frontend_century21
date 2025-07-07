import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/common_widgets/error_display_widget.dart';
import 'package:flutter_crm_app/core/common_widgets/loading_indicator.dart';
import 'package:flutter_crm_app/core/constants/enums.dart';
import 'package:flutter_crm_app/features/auth/data/models/user_model.dart';
import 'package:flutter_crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_crm_app/features/users_management/presentation/providers/user_management_provider.dart';
import 'package:flutter_crm_app/features/users_management/presentation/providers/user_management_state.dart';
import 'package:flutter_crm_app/features/users_management/presentation/widgets/assign_role_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userManagementNotifierProvider.notifier).fetchUsers());
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAssignRoleDialog(UserModel userToEdit, UserRole currentUserRole) {
    showDialog(
      context: context,
      builder: (context) => AssignRoleDialog(
        user: userToEdit,
        currentUserRole: currentUserRole,
        onRoleAssigned: (userId, newRole) async {
          final success = await ref.read(userManagementNotifierProvider.notifier).assignRole(userId, newRole);
          if (mounted) {
            Fluttertoast.showToast(msg: success ? 'Rol asignado' : (ref.read(userManagementNotifierProvider).errorMessage ?? 'Error'));
          }
        },
      ),
    );
  }

  void _showDeactivateConfirmationDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Desactivar a ${user.name}'),
        content: const Text('Esta cuenta no podrá iniciar sesión. ¿Estás seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(userManagementNotifierProvider.notifier).deactivateUser(user.id);
            },
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  void _showReactivateConfirmationDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reactivar a ${user.name}'),
        content: const Text('Esta cuenta podrá volver a iniciar sesión. ¿Estás seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(userManagementNotifierProvider.notifier).reactivateUser(user.id);
            },
            child: const Text('Reactivar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userManagementNotifierProvider);
    final currentUser = ref.watch(authNotifierProvider).user;
    final query = _searchController.text.toLowerCase();

    final filteredUsers = state.users.where((user) {
      if (query.isEmpty) return true;
      return user.name.toLowerCase().contains(query) || user.email.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre o email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(userManagementNotifierProvider.notifier).fetchUsers(),
              child: Builder(
                builder: (context) {
                  if (state.status == UserManagementStatus.loading && state.users.isEmpty) {
                    return const LoadingIndicator();
                  }
                  if (state.status == UserManagementStatus.error && state.users.isEmpty) {
                    return ErrorDisplayWidget(
                      errorMessage: state.errorMessage!,
                      onRetry: () => ref.read(userManagementNotifierProvider.notifier).fetchUsers(),
                    );
                  }
                  if (filteredUsers.isEmpty) {
                    return Center(child: Text(query.isEmpty ? 'No hay usuarios.' : 'No se encontraron resultados.'));
                  }

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final bool isInactive = !user.isActive;

                      bool canEditRole = false;
                      if (currentUser?.userRoleEnum == UserRole.master && user.id != currentUser?.id) {
                        canEditRole = true;
                      } else if (currentUser?.userRoleEnum == UserRole.privileged && user.userRoleEnum == UserRole.normal) {
                        canEditRole = true;
                      }

                      return Card(
                        color: isInactive ? Colors.grey.shade300 : null,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isInactive
                                ? Colors.grey.shade500
                                : Theme.of(context).colorScheme.secondary.withAlpha(77), // Corrección de withOpacity
                            child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
                          ),
                          title: Text(user.name, style: TextStyle(decoration: isInactive ? TextDecoration.lineThrough : null)),
                          subtitle: Text(user.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(isInactive ? 'INACTIVO' : user.role.toUpperCase()),
                                backgroundColor: isInactive ? Colors.grey.shade500 : Colors.black12,
                              ),
                              if (canEditRole)
                                IconButton(
                                  icon: const Icon(Icons.edit_note),
                                  tooltip: 'Editar Rol',
                                  onPressed: () => _showAssignRoleDialog(user, currentUser!.userRoleEnum),
                                ),
                              if (currentUser?.userRoleEnum == UserRole.master && user.id != currentUser?.id)
                                isInactive
                                  ? IconButton(
                                      icon: const Icon(Icons.undo, color: Colors.green),
                                      tooltip: 'Reactivar Usuario',
                                      onPressed: () => _showReactivateConfirmationDialog(user),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.power_settings_new, color: Colors.red),
                                      tooltip: 'Desactivar Usuario',
                                      onPressed: () => _showDeactivateConfirmationDialog(user),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
