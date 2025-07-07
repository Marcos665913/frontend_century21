// lib/features/users_management/presentation/widgets/assign_role_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_crm_app/core/constants/enums.dart';
import 'package:flutter_crm_app/features/auth/data/models/user_model.dart';

class AssignRoleDialog extends StatefulWidget {
  final UserModel user;
  final UserRole currentUserRole; // Rol del usuario que está haciendo la asignación
  final Function(String userId, String newRole) onRoleAssigned;

  const AssignRoleDialog({
    super.key,
    required this.user,
    required this.currentUserRole, // Se recibe el rol del usuario actual
    required this.onRoleAssigned,
  });

  @override
  State<AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends State<AssignRoleDialog> {
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = userRoleFromString(widget.user.role);
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE ROLES ASIGNABLES ---
    // Se determina qué roles se pueden asignar basado en el rol del usuario actual
    List<UserRole> assignableRoles = [];
    if (widget.currentUserRole == UserRole.master) {
      // Un master puede asignar cualquier rol.
      assignableRoles = [UserRole.normal, UserRole.privileged, UserRole.master];
    } else if (widget.currentUserRole == UserRole.privileged) {
      // Un privilegiado solo puede asignar normal o privilegiado.
      assignableRoles = [UserRole.normal, UserRole.privileged];
    }
    // Si es un rol normal, la lista queda vacía y no debería poder abrir este diálogo.
    // --- FIN DE LA LÓGICA ---

    return AlertDialog(
      title: Text('Asignar Rol a ${widget.user.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Selecciona el nuevo rol para este usuario.'),
          const SizedBox(height: 20),
          DropdownButtonFormField<UserRole>(
            value: _selectedRole,
            isExpanded: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onChanged: (UserRole? newValue) {
              if (newValue != null && assignableRoles.contains(newValue)) {
                setState(() {
                  _selectedRole = newValue;
                });
              }
            },
            items: assignableRoles.map<DropdownMenuItem<UserRole>>((UserRole value) {
              return DropdownMenuItem<UserRole>(
                value: value,
                child: Text(userRoleToString(value).toUpperCase()),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onRoleAssigned(widget.user.id, userRoleToString(_selectedRole));
            Navigator.of(context).pop();
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}