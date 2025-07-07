import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/network/dio_client.dart';
import 'package:flutter_crm_app/features/clients/data/data_sources/client_remote_data_source.dart';
import 'package:flutter_crm_app/features/clients/data/models/client_model.dart';
import 'package:flutter_crm_app/features/clients/data/repositories/client_repository_impl.dart';
import 'package:flutter_crm_app/features/clients/data/repositories/client_repository.dart';
import 'package:flutter_crm_app/features/clients/presentation/providers/client_state.dart';
import 'package:url_launcher/url_launcher.dart'; 

// Importa AppConfig para acceder a la baseUrl
import 'package:flutter_crm_app/core/config/app_config.dart'; // <-- ¡Nueva importación!

// Eliminamos las importaciones de 'package:open_filex/open_filex.dart' y 'dart:io' que no se usan aquí.
// Si las usas en otras partes del archivo o proyecto, no las elimines.
// import 'package:open_filex/open_filex.dart';
// import 'dart:io';
import 'package:dio/dio.dart'; // Mantener si Dio se usa en otras partes

// Provider para ClientRemoteDataSource
final clientRemoteDataSourceProvider = Provider<ClientRemoteDataSource>((ref) {
  return ClientRemoteDataSourceImpl(ref.read(dioProvider), ref);
});

// Provider para ClientRepository
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepositoryImpl(ref.read(clientRemoteDataSourceProvider));
});

// Provider del Notifier
final clientNotifierProvider = StateNotifierProvider<ClientNotifier, ClientState>((ref) {
  return ClientNotifier(
    ref.read(clientRepositoryProvider),
    ref.read(dioProvider),
  );
});

class ClientNotifier extends StateNotifier<ClientState> {
  final ClientRepository _repository;
  final Dio _dio; 

  ClientNotifier(this._repository, this._dio) : super(const ClientState()) {
    fetchClients();
  }

  Future<void> fetchClients() async {
    state = state.copyWith(status: ClientStatus.loading);
    final result = await _repository.getClients();
    result.fold(
      (failure) {
        state = state.copyWith(status: ClientStatus.error, errorMessage: failure.message);
      },
      (clients) {
        state = state.copyWith(status: ClientStatus.loaded, clients: clients, clearErrorMessage: true);
      },
    );
  }

  Future<bool> addClient(Map<String, dynamic> clientFields) async {
    state = state.copyWith(status: ClientStatus.submitting);
    final result = await _repository.addClient(clientFields);
    return result.fold(
      (failure) {
        state = state.copyWith(status: ClientStatus.error, errorMessage: failure.message);
        return false;
      },
      (newClient) {
        final updatedList = List<ClientModel>.from(state.clients)..insert(0, newClient);
        state = state.copyWith(status: ClientStatus.loaded, clients: updatedList);
        return true;
      },
    );
  }

  Future<bool> updateClient(String clientId, Map<String, dynamic> clientFields) async {
    state = state.copyWith(status: ClientStatus.submitting);
    final result = await _repository.updateClient(clientId, clientFields);
      return result.fold(
      (failure) {
        state = state.copyWith(status: ClientStatus.error, errorMessage: failure.message);
        return false;
      },
      (updatedClient) {
        final index = state.clients.indexWhere((c) => c.id == clientId);
        if (index != -1) {
          final updatedList = List<ClientModel>.from(state.clients);
          updatedList[index] = updatedClient;
          state = state.copyWith(status: ClientStatus.loaded, clients: updatedList);
        } else {
          fetchClients();
        }
        return true;
      },
    );
  }

  Future<bool> deleteClient(String clientId) async {
      state = state.copyWith(status: ClientStatus.submitting);
      final result = await _repository.deleteClient(clientId);
      return result.fold(
      (failure) {
        state = state.copyWith(status: ClientStatus.error, errorMessage: failure.message);
        return false;
      },
      (_) {
        final updatedList = List<ClientModel>.from(state.clients)..removeWhere((c) => c.id == clientId);
        state = state.copyWith(status: ClientStatus.loaded, clients: updatedList);
        return true;
      },
    );
  }

 Future<String?> exportClientsToExcel() async {
  try {
    final response = await _dio.get('/clients/export-url'); 
    final String downloadUrl = response.data['downloadUrl']; 

    // --- AÑADE ESTE PRINT PARA DEPURACIÓN ---
    print('URL de descarga recibida del backend: $downloadUrl');
    // ----------------------------------------

    if (!await canLaunchUrl(Uri.parse(downloadUrl))) {
      return 'No se pudo abrir el enlace de descarga. Asegúrate de que la URL es válida.';
    }
    await launchUrl(Uri.parse(downloadUrl), mode: LaunchMode.externalApplication);
    return null;
  } catch (e) {
    print('Error en exportClientsToExcel: $e'); // Este print también es crucial
    return 'Ocurrió un error al intentar exportar el archivo.';
  }
}
}