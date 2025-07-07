// lib/features/custom_fields/presentation/screens/manage_custom_fields_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/common_widgets/error_display_widget.dart';
import 'package:flutter_crm_app/core/common_widgets/loading_indicator.dart';
import 'package:flutter_crm_app/features/custom_fields/presentation/providers/custom_field_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ManageCustomFieldsScreen extends ConsumerStatefulWidget {
  const ManageCustomFieldsScreen({super.key});

  @override
  ConsumerState<ManageCustomFieldsScreen> createState() => _ManageCustomFieldsScreenState();
}

class _ManageCustomFieldsScreenState extends ConsumerState<ManageCustomFieldsScreen> {
  
  @override
  void initState() {
    super.initState();
    // Cargar los campos al iniciar la pantalla
    Future.microtask(() => ref.read(customFieldNotifierProvider.notifier).getCustomFields());
  }

  void _showCreateFieldDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Nuevo Campo'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nombre del Campo (ej. "Fuente de Referencia")'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                final success = await ref
                    .read(customFieldNotifierProvider.notifier)
                    .createCustomField(nameController.text.trim());
                
                if (mounted) {
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: success ? 'Campo creado con éxito' : 'Error al crear el campo',
                    backgroundColor: success ? Colors.green : Colors.red,
                  );
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String fieldId, String fieldName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Seguro que quieres eliminar el campo "$fieldName"? Esta acción es irreversible.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                final success = await ref
                    .read(customFieldNotifierProvider.notifier)
                    .deleteCustomField(fieldId);

                if (mounted) {
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: success ? 'Campo eliminado con éxito' : 'Error al eliminar el campo',
                     backgroundColor: success ? Colors.green : Colors.red,
                  );
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customFieldNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Campos'),
        leading: const BackButton(), // <-- AÑADE ESTA LÍNEA
        ),
      body: Builder(
        builder: (context) {
          if (state.status == CustomFieldStatus.loading) {
            return const LoadingIndicator(message: 'Cargando campos...');
          }
          if (state.status == CustomFieldStatus.error) {
            return ErrorDisplayWidget(
              errorMessage: state.errorMessage ?? 'Ocurrió un error',
              onRetry: () => ref.read(customFieldNotifierProvider.notifier).getCustomFields(),
            );
          }
          if (state.fields.isEmpty) {
            return const Center(child: Text('No hay campos personalizados. ¡Crea el primero!'));
          }

          return ListView.builder(
            itemCount: state.fields.length,
            itemBuilder: (context, index) {
              final field = state.fields[index];
              return ListTile(
                title: Text(field.name),
                subtitle: Text('Clave interna: ${field.key}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteConfirmationDialog(field.id, field.name),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateFieldDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}