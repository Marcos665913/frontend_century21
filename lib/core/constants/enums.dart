// lib/core/constants/enums.dart

// Roles de Usuario
enum UserRole {
  normal,
  privileged,
  master,
  unknown
}

UserRole userRoleFromString(String? roleString) {
  switch (roleString?.toLowerCase()) {
    case 'normal':
      return UserRole.normal;
    case 'privileged':
      return UserRole.privileged;
    case 'master':
      return UserRole.master;
    default:
      return UserRole.unknown;
  }
}

String userRoleToString(UserRole role) {
  return role.name; // Usamos .name que es más seguro y moderno
}

// --- ENUMS PARA CLIENTE ACTUALIZADOS ---

enum AsuntoInmobiliario {
  compra('COMPRA', 'Compra'),
  venta('VENTA', 'Venta'),
  renta('RENTA', 'Renta'),
  darEnRenta('DAR A RENTA', 'Dar en Renta'),
  asesorExterno('ASESOR EXTERNO', 'Asesor Externo'),
  asesoria('ASESORIA', 'Asesoría');

  const AsuntoInmobiliario(this.backendValue, this.displayValue);
  final String backendValue;
  final String displayValue;
}

enum TipoInmueble {
  casa('CASA', 'Casa'),
  departamento('DEPARTAMENTO', 'Departamento'),
  bodega('BODEGA', 'Bodega'),
  terreno('TERRENO', 'Terreno'),
  local('LOCAL', 'Local'),
  naveIndustrial('NAVE INDUSTRIAL', 'Nave Industrial');

  const TipoInmueble(this.backendValue, this.displayValue);
  final String backendValue;
  final String displayValue;
}

enum OrigenCliente {
  amigoConocido('AMIGO/CONOCIDO', 'Amigo/Conocido'),
  esferaInfluencia('ESFERA DE INFLUENCIA', 'Esfera de Influencia'),
  lonasRotulo('LONAS O ROTULO', 'Lonas o Rótulo'),
  tarjetas('TARJETAS', 'Tarjetas'),
  whatsapp('WHATSAPP', 'WhatsApp'),
  facebook('FACEBOOK', 'Facebook'),
  paginaWebC21Global('PAGINA WEB C21 GLOBAL', 'Página Web C21 Global'),
  propiedadesCom('PROPIEDADES.COM', 'Propiedades.com'),
  inmuebles24('INMUEBLES 24', 'Inmuebles 24'),
  c21Mexico('C21 MEXICO', 'C21 México'),
  instagram('INSTAGRAM', 'Instagram'),
  googleAds('GOOGLE ADS', 'Google Ads'),
  tikTok('TIK TOK', 'TikTok'),
  youtube('YOUTUBE', 'YouTube'),
  telefonoOficina('TELEFONO OFICINA', 'Teléfono Oficina');

  const OrigenCliente(this.backendValue, this.displayValue);
  final String backendValue;
  final String displayValue;
}

enum EstatusCliente {
  sinComenzar('SIN COMENZAR', 'Sin Comenzar'),
  iniciado('INICIADO', 'Iniciado'),
  enCurso('EN CURSO', 'En Curso'),
  completado('COMPLETADO', 'Completado'),
  standby('STANDBY (EN ESPERA)', 'Standby (En Espera)'),
  cancelado('CANCELADO', 'Cancelado'),
  rechazado('RECHAZADO', 'Rechazado'),
  citado('CITADO', 'Citado'),
  sinRespuesta('SIN RESPUESTA', 'Sin Respuesta');

  const EstatusCliente(this.backendValue, this.displayValue);
  final String backendValue;
  final String displayValue;
}

enum TipoPago {
  efectivo('EFECTIVO', 'Efectivo'),
  bancario('BANCARIO', 'Bancario'),
  infonavit('INFONAVIT', 'Infonavit'),
  fovissste('FOVISSTE', 'Fovissste');

  const TipoPago(this.backendValue, this.displayValue);
  final String backendValue;
  final String displayValue;
}

// --- FUNCIONES DE AYUDA ---

/// Convierte un valor de texto del backend al Enum correspondiente.
T? enumFromString<T>(List<T> values, String? value) {
  if (value == null) return null;
  try {
    // Para enums con 'backendValue'
    return values.firstWhere((type) => (type as dynamic).backendValue == value);
  } catch (e) {
    // Para enums simples como UserRole
    try {
      return values.firstWhere((type) => type.toString().split('.').last == value);
    } catch (e) {
      return null;
    }
  }
}

/// Convierte un objeto Enum a su valor de texto para el backend.
String? enumToBackendValue(dynamic enumValue) {
  if (enumValue == null) return null;
  try {
    // Intenta acceder a backendValue
    return (enumValue as dynamic).backendValue as String?;
  } catch (e) {
    // Si falla, es un enum simple, usa su nombre
    return enumValue.name;
  }
}