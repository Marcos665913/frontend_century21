// lib/core/common_widgets/role_specific_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_crm_app/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_crm_app/core/constants/enums.dart';

class RoleSpecificWidget extends ConsumerWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? replacement; // Widget a mostrar si el rol no está permitido

  const RoleSpecificWidget({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.replacement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    
    if (authState.status == AuthStatus.authenticated && 
        authState.user != null &&
        allowedRoles.contains(userRoleFromString(authState.user!.role))) {
      return child;
    }
    return replacement ?? const SizedBox.shrink(); // No mostrar nada si no se provee reemplazo
  }
}