// lib/features/clients/presentation/screens/client_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/common_widgets/loading_indicator.dart';
import 'package:flutter_crm_app/core/constants/enums.dart';
import 'package:flutter_crm_app/features/clients/data/models/client_model.dart';
import 'package:flutter_crm_app/features/clients/presentation/providers/client_provider.dart';
import 'package:flutter_crm_app/features/custom_fields/presentation/providers/custom_field_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_crm_app/core/network/dio_client.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  final String? clientId;
  const ClientFormScreen({super.key, this.clientId});

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _standardControllers = {};
  final Map<String, dynamic> _customControllers = {};
  
  final Map<String, dynamic> _dropdownValues = {};

  DateTime? _fechaContacto;
  DateTime? _fechaAsignacion;

  ClientModel? _editingClient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    Future.microtask(() => _loadInitialData());
  }

  void _initializeControllers() {
    final keys = [
      'nombre', 'telefono', 'correo', 'presupuesto', 'zona',
      'seguimiento', 'especificaciones', 'observaciones',
      'idOperacion',
      'idsRelacionados',
    ];
    for (var key in keys) {
      _standardControllers[key] = TextEditingController();
    }
  }

  Future<void> _loadInitialData() async {
    await ref.read(customFieldNotifierProvider.notifier).getCustomFields();

    if (widget.clientId != null) {
      try {
        _editingClient = ref.read(clientNotifierProvider).clients.firstWhere((c) => c.id == widget.clientId);

        _dropdownValues['asunto'] = _editingClient!.asunto;
        _dropdownValues['tipoInmueble'] = _editingClient!.tipoInmueble;
        _dropdownValues['origen'] = _editingClient!.origen;
        _dropdownValues['estatus'] = _editingClient!.estatus;
        _dropdownValues['tipoPago'] = _editingClient!.tipoPago;

        _fechaContacto = _editingClient!.fechaContacto;
        _fechaAsignacion = _editingClient!.fechaAsignacion;

        _standardControllers.forEach((key, controller) {
          controller.text = _editingClient!.fields[key]?.toString() ?? '';
        });

        _editingClient!.customFieldsData.forEach((key, value) {
          _customControllers[key] = TextEditingController(text: value?.toString() ?? '');
        });

      } catch (e) {
        if(mounted) Fluttertoast.showToast(msg: "Error: No se encontró el cliente.", backgroundColor: Colors.red);
      }
    } else {
      _fechaContacto = DateTime.now();
      _fechaAsignacion = DateTime.now();
      _dropdownValues['estatus'] = EstatusCliente.sinComenzar;
    }

    final customFieldDefs = ref.read(customFieldNotifierProvider).fields;
    for (var fieldDef in customFieldDefs) {
      if (!_customControllers.containsKey(fieldDef.key)) {
        _customControllers[fieldDef.key] = TextEditingController();
      }
    }

    if(mounted) setState(() { _isLoading = false; });
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime? initialDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final Map<String, dynamic> allData = {};

      _standardControllers.forEach((key, controller) {
        if (key == 'presupuesto') {
          allData[key] = num.tryParse(controller.text.replaceAll(',', '')) ?? 0;
        } else {
          allData[key] = controller.text.trim();
        }
      });

      _dropdownValues.forEach((key, value) {
        if (value != null && value is Enum) {
          allData[key] = (value as dynamic).backendValue;
        }
      });

      if (_fechaContacto != null) allData['fechaContacto'] = _fechaContacto!.toUtc().toIso8601String();
      if (_fechaAsignacion != null) allData['fechaAsignacion'] = _fechaAsignacion!.toUtc().toIso8601String();

      _customControllers.forEach((key, controller) {
        allData[key] = (controller as TextEditingController).text.trim();
      });

      bool success;
      if (widget.clientId == null) {
        success = await ref.read(clientNotifierProvider.notifier).addClient(allData);
      } else {
        success = await ref.read(clientNotifierProvider.notifier).updateClient(widget.clientId!, allData);
      }

      if(mounted) {
        setState(() { _isLoading = false; });
        final errorMessage = ref.read(clientNotifierProvider).errorMessage;
        Fluttertoast.showToast(
          msg: success ? 'Cambios guardados correctamente' : (errorMessage ?? 'Error desconocido'),
          backgroundColor: success ? Colors.green : Colors.red
        );

        if (success) {
          context.pop();
          if (widget.clientId != null) {
            context.pop();
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _standardControllers.forEach((_, controller) => controller.dispose());
    _customControllers.forEach((key, controller) {
      if (controller is TextEditingController) {
        controller.dispose();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customFieldsState = ref.watch(customFieldNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientId == null ? 'Nuevo Cliente' : 'Editar Cliente'),
        leading: const BackButton(),
      ),
      body: _isLoading
        ? const LoadingIndicator(message: 'Cargando formulario...')
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionTitle('Fechas Clave'),
                _buildDateTimePicker('Fecha de Contacto', _fechaContacto, (date) => setState(() => _fechaContacto = date)),
                _buildDateTimePicker('Fecha de Asignación', _fechaAsignacion, (date) => setState(() => _fechaAsignacion = date)),

                _buildSectionTitle('Información del Cliente'),
                _buildTextField(_standardControllers['nombre']!, 'Nombre Completo*'),
                _buildTextField(_standardControllers['telefono']!, 'Teléfono*', keyboardType: TextInputType.phone),
                _buildTextField(_standardControllers['correo']!, 'Correo Electrónico'),
                _buildDropdown<OrigenCliente>(OrigenCliente.values, 'origen', 'Origen*'),

                _buildSectionTitle('Detalles de la Operación'),
                _buildDropdown<AsuntoInmobiliario>(AsuntoInmobiliario.values, 'asunto', 'Asunto*'),
                _buildTextField(_standardControllers['idOperacion']!, 'ID Operación'),
                _buildTextField(_standardControllers['idsRelacionados']!, 'IDs Relacionados'),
                _buildDropdown<TipoInmueble>(TipoInmueble.values, 'tipoInmueble', 'Tipo de Inmueble'),
                _buildTextField(_standardControllers['presupuesto']!, 'Presupuesto*'),
                _buildDropdown<TipoPago>(TipoPago.values, 'tipoPago', 'Tipo de Pago*'),
                _buildTextField(_standardControllers['zona']!, 'Zona de Interés'),

                _buildSectionTitle('Estatus del Cliente'),
                _buildDropdown<EstatusCliente>(EstatusCliente.values, 'estatus', 'Estatus*'),

                _buildSectionTitle('Seguimiento'),
                _buildTextField(_standardControllers['seguimiento']!, 'Seguimiento', maxLines: 4),
                _buildTextField(_standardControllers['especificaciones']!, 'Especificaciones', maxLines: 3),
                _buildTextField(_standardControllers['observaciones']!, 'Observaciones', maxLines: 4),

                if (customFieldsState.status == CustomFieldStatus.loaded && customFieldsState.fields.isNotEmpty) ...[
                  const Divider(height: 32, thickness: 1),
                  Text('Información Adicional', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...customFieldsState.fields.map((fieldDef) {
                    return _buildTextField(
                      _customControllers[fieldDef.key]! as TextEditingController,
                      fieldDef.name,
                    );
                  }),
                ],

                const SizedBox(height: 32),
                _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(widget.clientId == null ? 'CREAR CLIENTE' : 'GUARDAR CAMBIOS'),
                    )
              ],
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildDateTimePicker(String label, DateTime? date, Function(DateTime) onDateSelected) {
    final format = DateFormat.yMMMMd('es_ES').add_jm();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () async {
          final selectedDate = await _pickDateTime(context, date);
          if (selectedDate != null) {
            onDateSelected(selectedDate);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(date != null ? format.format(date.toLocal()) : 'No seleccionada'),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType, int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (label.endsWith('*') && (value == null || value.isEmpty)) return 'Este campo es obligatorio';
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown<T extends Enum>(List<T> items, String formKey, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: _dropdownValues[formKey],
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: items.map((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text((value as dynamic).displayValue),
          );
        }).toList(),
        onChanged: (T? newValue) => setState(() => _dropdownValues[formKey] = newValue),
        validator: (value) {
          if (label.endsWith('*') && value == null) return 'Este campo es obligatorio';
          return null;
        },
      ),
    );
  }
}