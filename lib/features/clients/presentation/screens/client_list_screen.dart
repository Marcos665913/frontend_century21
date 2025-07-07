// lib/features/clients/presentation/screens/client_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/common_widgets/error_display_widget.dart';
import 'package:flutter_crm_app/core/common_widgets/loading_indicator.dart';
import 'package:flutter_crm_app/core/constants/enums.dart'; // Importación necesaria para EstatusCliente
import 'package:flutter_crm_app/features/clients/presentation/providers/client_provider.dart';
import 'package:flutter_crm_app/features/clients/presentation/providers/client_state.dart';
import 'package:go_router/go_router.dart';

class ClientListScreen extends ConsumerStatefulWidget {
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(EstatusCliente? estado) {
    switch (estado) {
      case EstatusCliente.iniciado:
        return Colors.blue.shade100;
      case EstatusCliente.enCurso:
        return Colors.orange.shade100;
      case EstatusCliente.completado: 
        return Colors.green.shade100;
      case EstatusCliente.cancelado:
        return Colors.red.shade100;
      case EstatusCliente.standby:
        return Colors.purple.shade100;
      case EstatusCliente.citado: // Nuevo caso
        return Colors.lightGreen.shade100; // Un color para "citado"
      case EstatusCliente.rechazado: // Nuevo caso
        return Colors.deepOrange.shade100; // Un color para "rechazado"
      case EstatusCliente.sinComenzar: // Nuevo caso
        return Colors.teal.shade100; // Un color para "sin comenzar"
      case EstatusCliente.sinRespuesta: // Nuevo caso
        return Colors.brown.shade100; // Un color para "sin respuesta"
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientState = ref.watch(clientNotifierProvider);
    final allClients = clientState.clients;

    final query = _searchController.text.toLowerCase();
    final filteredClients = allClients.where((client) {
      if (query.isEmpty) {
        return true;
      }
      final name = client.nombre.toLowerCase();
      final phone = client.telefono.toLowerCase();
      final advisor = client.createdBy?.name.toLowerCase() ?? '';
      return name.contains(query) || phone.contains(query) || advisor.contains(query);
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre, teléfono o asesor',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (clientState.status == ClientStatus.loading && allClients.isEmpty) {
                  return const LoadingIndicator(message: 'Cargando clientes...');
                }
                if (clientState.status == ClientStatus.error && allClients.isEmpty) {
                  return ErrorDisplayWidget(
                    errorMessage: clientState.errorMessage ?? 'Error',
                    onRetry: () => ref.read(clientNotifierProvider.notifier).fetchClients(),
                  );
                }
                if (filteredClients.isEmpty && allClients.isNotEmpty) {
                  return const Center(child: Text('No se encontraron clientes.'));
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(clientNotifierProvider.notifier).fetchClients(),
                  child: ListView.builder(
                    itemCount: filteredClients.length,
                    itemBuilder: (context, index) {
                      final client = filteredClients[index];
                      return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(client.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(client.telefono),
                              const SizedBox(height: 2),
                              Text(
                                'Asesor: ${client.createdBy?.name ?? "No asignado"}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              client.estatus?.displayValue ?? 'Sin Estado',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            backgroundColor: _getStatusColor(client.estatus),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onTap: () => context.go('/clients/${client.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/clients/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}