# ESPECIFICACIONES DE VERSIONES PARA AGENTES IA

## 📋 **VERSIONES EXACTAS DEL PROYECTO**

### **Entorno Base**
- **Flutter**: `3.35.1` (stable channel)
- **Dart**: `3.9.0`
- **Dart SDK**: `^3.9.0` (pubspec.yaml)

### **Dependencias Principales**

#### **Backend y Base de Datos**
- **supabase_flutter**: `^2.8.0`
  - ⚠️ **CRÍTICO**: Usar método `.isFilter()` NO `.is_()`
  - ⚠️ **CRÍTICO**: PostgrestFilterBuilder API cambió en v2.x

#### **Gestión de Estado**
- **flutter_bloc**: `^8.1.6`
- **equatable**: `^2.0.5`

#### **Navegación**
- **go_router**: `^14.6.1`
  - ⚠️ **CRÍTICO**: Usar sintaxis GoRouter v14+ con `GoRoute`

#### **UI y Formularios**
- **flutter_form_builder**: `^10.2.0`
- **form_builder_validators**: `^11.0.0`

## 🚫 **ERRORES COMUNES DE VERSIONES**

### **1. Supabase API (CRÍTICO)**
```dart
// ❌ INCORRECTO (versión antigua)
.is_('campo', valor)

// ✅ CORRECTO (v2.8.0)
.isFilter('campo', valor)
```

### **2. Flutter Syntax (Dart 3.9.0)**
```dart
// ❌ INCORRECTO - Spread operator mal usado
if (condition) ...[
  widget1,
  widget2,
  // Falta cierre correcto

// ✅ CORRECTO - Spread operator bien usado
if (condition) ...[
  widget1,
  widget2,
], // Cierre explícito del spread
```

### **3. Null Safety (Dart 3.9.0)**
```dart
// ❌ INCORRECTO - Null safety no considerado
String? valor = getData();
return valor.length; // Error

// ✅ CORRECTO - Null safety respetado
String? valor = getData();
return valor?.length ?? 0;
```

## 🎯 **DIRECTIVAS PARA AGENTES IA**

### **SUPABASE OPERATIONS**
```dart
// Query básica
final response = await supabase
    .from('tabla')
    .select('*')
    .eq('campo', valor);

// Query con filtro null
final response = await supabase
    .from('tabla')
    .select('*')
    .isFilter('campo_opcional', null);

// Insert con select
final response = await supabase
    .from('tabla')
    .insert(data)
    .select()
    .single();
```

### **BLOC PATTERNS (v8.1.6)**
```dart
// Event handler correcto
Future<void> _onEventName(
  EventName event,
  Emitter<StateType> emit,
) async {
  try {
    emit(LoadingState());
    final result = await repository.method();
    emit(LoadedState(data: result));
  } catch (e) {
    emit(ErrorState(message: e.toString()));
  }
}
```

### **GOROUTER NAVIGATION (v14.6.1)**
```dart
// Definición de rutas
GoRoute(
  path: '/path',
  name: 'route_name',
  builder: (context, state) => const Widget(),
  routes: [
    GoRoute(
      path: 'subroute',
      name: 'subroute_name',
      builder: (context, state) => const SubWidget(),
    ),
  ],
)

// Navegación
context.go('/path/subroute');
context.goNamed('route_name');
```

### **FLUTTER WIDGETS (v3.35.1)**
```dart
// Spread operator correcto
Column(
  children: [
    CommonWidget(),
    if (condition) ...[
      ConditionalWidget1(),
      ConditionalWidget2(),
    ],
    AnotherWidget(),
  ],
)

// ListView.builder moderno
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ListTile(
      title: Text(item.name),
      onTap: () => onItemTap(item),
    );
  },
)
```

## 📚 **PATRONES ESPECÍFICOS DEL PROYECTO**

### **Repository Pattern**
```dart
class ExampleRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Model>> getItems() async {
    try {
      final response = await _client
          .from('tabla')
          .select('*')
          .order('created_at');

      return (response as List)
          .map((json) => Model.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
```

### **Model Classes**
```dart
class ExampleModel extends Equatable {
  final String id;
  final String name;
  final bool active;
  final DateTime createdAt;

  const ExampleModel({
    required this.id,
    required this.name,
    required this.active,
    required this.createdAt,
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      active: json['active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'active': active,
    };
  }

  @override
  List<Object?> get props => [id, name, active, createdAt];
}
```

## 🔧 **DEBUGGING Y VERIFICACIÓN**

### **Comandos de Verificación**
```bash
# Verificar versiones
flutter --version
dart --version

# Limpiar y regenerar
flutter clean
flutter pub get

# Verificar dependencias
flutter pub deps
flutter pub outdated
```

### **Errores Comunes y Soluciones**
1. **Error de compilación**: Verificar sintaxis Dart 3.9.0
2. **Error Supabase**: Verificar métodos API v2.8.0
3. **Error BLoC**: Verificar event handlers v8.1.6
4. **Error Router**: Verificar rutas GoRouter v14.6.1

## ⚠️ **ADVERTENCIAS CRÍTICAS**

1. **NUNCA usar métodos deprecated** de versiones anteriores
2. **SIEMPRE verificar** null safety en Dart 3.9.0
3. **SIEMPRE usar** async/await correctamente
4. **SIEMPRE cerrar** spread operators correctamente
5. **SIEMPRE manejar** excepciones en repository patterns

## 📝 **ACTUALIZACIONES**

- **Fecha**: 2025-09-19
- **Flutter**: 3.35.1
- **Dart**: 3.9.0
- **Supabase**: 2.8.0
- **Última verificación**: Proyecto retail-manager-system

---

**TODOS LOS AGENTES IA DEBEN SEGUIR ESTAS ESPECIFICACIONES EXACTAS**