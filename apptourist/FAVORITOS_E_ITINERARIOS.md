# Gestión de Favoritos e Itinerarios

## Nuevas Funcionalidades Agregadas

### IMPORTANTE: Nuevo Flujo de Guardar Itinerario a Favoritos

El flujo ahora es **de dos pasos**:

1. **Paso 1**: Guardar el itinerario en la tabla `itinerarios` con campos:
   - `user_id`: ID del usuario autenticado
   - `itinerario_data`: JSON del itinerario completo

2. **Paso 2**: Agregar el itinerario guardado a favoritos

**Esto se ejecuta al presionar el botón de corazón ❤️**

### 1. Guardar Itinerario en BD

```dart
import 'services/backend_api_service.dart';

// Después de generar el itinerario con IA
final itinerarioGenerado = await ItinerarioAIService.instance.generarItinerarioConIA(
  fechaInicio: DateTime(2025, 12, 20),
  dias: 5,
  preferencias: ['Histórico', 'Gastronomía'],
  usuario: usuarioActual,
);

// PASO 1: Guardar en la BD tabla itinerarios
final itinerarioGuardado = await BackendApiService.instance.guardarItinerario(
  itinerarioData: itinerarioGenerado,
);

// Obtener el ID del itinerario guardado
final itinerarioId = itinerarioGuardado['id'];

print('✅ Itinerario guardado con ID: $itinerarioId');
```

**Endpoint**: `POST /api/itinerarios`
**Campos guardados en BD**:
- `user_id`: Automático (del JWT)
- `itinerario_data`: JSON del itinerario

### 2. Agregar a Favoritos

```dart
// PASO 2: Agregar el itinerario a favoritos
final resultado = await BackendApiService.instance.agregarItinerarioAFavoritos(
  itinerarioId: itinerarioId,
);

print('✅ Agregado a favoritos: $resultado');
```

**Endpoint**: `POST /api/itinerarios/{id}/favorito`

### Flujo Completo (Ejemplo de Botón de Corazón)

```dart
Future<void> _toggleItinerarioFavorito() async {
  if (usuario == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Debes iniciar sesión")),
    );
    return;
  }

  setState(() => cargandoFavorito = true);

  try {
    // PASO 1: Guardar itinerario en la BD
    print('📌 Paso 1: Guardando itinerario en la BD...');
    final respuestaGuardado = await BackendApiService.instance.guardarItinerario(
      itinerarioData: itinerarioGenerado,
    );

    final itinerarioId = respuestaGuardado['id'];
    print('✅ Itinerario guardado con ID: $itinerarioId');

    // PASO 2: Agregar a favoritos
    print('📌 Paso 2: Agregando a favoritos...');
    await BackendApiService.instance.agregarItinerarioAFavoritos(
      itinerarioId: itinerarioId,
    );

    setState(() {
      esItinerarioFavorito = true;
      cargandoFavorito = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Itinerario guardado y agregado a favoritos!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    setState(() => cargandoFavorito = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
```

### Botón en UI

```dart
// Botón de corazón para agregar a favoritos
cargandoFavorito
    ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    : IconButton(
        icon: Icon(
          esItinerarioFavorito ? Icons.favorite : Icons.favorite_border,
          color: esItinerarioFavorito ? Colors.red : Colors.grey,
          size: 30,
        ),
        onPressed: _toggleItinerarioFavorito,
        tooltip: 'Agregar a favoritos',
      ),
```

---

## Favoritos por Categoría

### 1. Obtener Favoritos de una Categoría

```dart
// Obtener favoritos de bares
final bares = await BackendApiService.instance.obtenerFavoritosPorTipo('Bar');

// Obtener favoritos de restaurantes
final restaurantes = await BackendApiService.instance.obtenerFavoritosPorTipo('Restaurante');

// Obtener favoritos de lugares
final lugares = await BackendApiService.instance.obtenerFavoritosPorTipo('Lugar');
```

**Formato de respuesta:**
```dart
[
  {
    "id": 1,
    "user_id": 1,
    "favoritable_type": "Bar",
    "favoritable_id": 1,
    "favoritable": {
      "id": 1,
      "nombre": "GastroBar El Mercado",
      "descripcion": "...",
      "direccion": "...",
    }
  }
]
```

---

## Obtener Itinerarios Favoritos

### Recuperar todos los itinerarios guardados

```dart
try {
  final itinerarios = await BackendApiService.instance.obtenerItinerariosFavoritos();
  
  for (final itinerario in itinerarios) {
    print('${itinerario['nombre']} - ${itinerario['descripcion']}');
  }
} catch (e) {
  print('Error: $e');
}
```

---

## Eliminar Itinerario Favorito

### Eliminar un itinerario guardado

```dart
try {
  await BackendApiService.instance.eliminarItinerarioFavorito(itinerarioId);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Itinerario eliminado')),
  );
} catch (e) {
  print('Error: $e');
}
```

---

## Métodos Disponibles en BackendApiService

```dart
// ITINERARIOS
guardarItinerario({required Map<String, dynamic> itinerarioData})
agregarItinerarioAFavoritos({required int itinerarioId})
obtenerItinerariosFavoritos()
eliminarItinerarioFavorito(int id)

// FAVORITOS
toggleFavorito({required String favoritableType, required int favoritableId})
obtenerFavoritosPorTipo(String tipo)
obtenerFavoritos()
```

---

## Endpoints del Backend

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/itinerarios` | Guardar itinerario en BD |
| POST | `/api/itinerarios/{id}/favorito` | Agregar itinerario a favoritos |
| GET | `/api/itinerarios/favoritos` | Obtener todos los itinerarios favoritos |
| DELETE | `/api/itinerarios/favoritos/{id}` | Eliminar itinerario de favoritos |
| GET | `/api/favoritos/tipo/{tipo}` | Obtener favoritos de una categoría |
| POST | `/api/favoritos` | Toggle favorito de lugar/bar/restaurante |

---

## Ver Ejemplo Completo

Consulta el archivo `EJEMPLO_ITINERARIO_FAVORITOS.dart` para ver la implementación completa de una página con:
- Generación de itinerario
- Botón de corazón para agregar a favoritos
- Flujo de dos pasos (guardar en BD + agregar a favoritos)
- Visualización del itinerario con actividades por hora

