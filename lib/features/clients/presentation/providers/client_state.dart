// lib/features/clients/presentation/providers/client_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_crm_app/features/clients/data/models/client_model.dart';

enum ClientStatus { initial, loading, loaded, error, submitting }

class ClientState extends Equatable {
  final ClientStatus status;
  final List<ClientModel> clients;
  final String? errorMessage;

  const ClientState({
    this.status = ClientStatus.initial,
    this.clients = const [],
    this.errorMessage,
  });
  
  ClientState copyWith({
    ClientStatus? status,
    List<ClientModel>? clients,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ClientState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, clients, errorMessage];
}