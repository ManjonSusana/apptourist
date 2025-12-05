# 🔧 Corrección de Errores: Guardar Itinerario en Favoritos

## Errores Encontrados

### Error 1: `type 'Null' is not a subtype of type 'int'`
**Causa**: El backend devuelve la respuesta dentro de un campo `data`, pero el código intentaba acceder directamente al `id`.

### Error 2: `404 Not Found` en `/api/itinerarios/{id}/favorito`
**Causa**: Este endpoint no existe en el backend. El endpoint correcto es `/api/favoritos` con `favoritable_type` y `favoritable_id`.

---

## Respuestas del Backend

### Guardar Itinerario: `POST /api/itinerarios`
```json
{
  "message": "Itinerario creado exitosamente",
  "data": {
    "id": 4,
    "user_id": 1,
    "itinerario_data": {...},
    "created_at": "2025-12-05T12:38:16.000000Z",
    "updated_at": "2025-12-05T12:38:16.000000Z"
  }
}
```
**ID del itinerario está en**: `response['data']['id']` ✅

### Agregar a Favoritos: `POST /api/favoritos`
```json
{
  "favoritable_type": "App\\Models\\Itinerario",
  "favoritable_id": 4
}
```
**Endpoint correcto**: `/api/favoritos` (no `/api/itinerarios/4/favorito`) ✅

---

## Cambios Realizados

### 1. Método `guardarItinerario()` - `backend_api_service.dart` línea ~345

**ANTES** ❌:
```dart
final data = jsonDecode(resp.body);
return Map<String, dynamic>.from(data);
```

**DESPUÉS** ✅:
```dart
final data = jsonDecode(resp.body);

// El backend devuelve: {"message": "...", "data": {...}}
// Extraer el objeto del campo 'data'
if (data is Map && data['data'] != null) {
  return Map<String, dynamic>.from(data['data']);
} else if (data is Map) {
  return Map<String, dynamic>.from(data);
}

return {};
```

**Explicación**: Ahora extrae correctamente el `id` del campo `data.id` en lugar de buscar directamente en la raíz.

---

### 2. Método `agregarItinerarioAFavoritos()` - `backend_api_service.dart` línea ~382

**ANTES** ❌:
```dart
final uri = Uri.parse('$_baseUrl/itinerarios/$itinerarioId/favorito');

final resp = await http.post(
  uri,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_jwtToken',
  },
);
```

**DESPUÉS** ✅:
```dart
// Usar el endpoint /api/favoritos con el tipo Itinerario
final uri = Uri.parse('$_baseUrl/favoritos');

final resp = await http.post(
  uri,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_jwtToken',
  },
  body: jsonEncode({
    'favoritable_type': 'App\\Models\\Itinerario',
    'favoritable_id': itinerarioId,
  }),
);
```

**Explicación**: 
- Cambiado de `/api/itinerarios/{id}/favorito` → `/api/favoritos`
- Agregado body con `favoritable_type` y `favoritable_id`
- Usa el mismo endpoint que los otros favoritos (lugares, bares, restaurantes)

---

### 3. Método `_toggleItinerarioFavorito()` - `recomendaciones_page.dart` línea ~207

**ANTES** ❌:
```dart
final response = await BackendApiService.instance.guardarItinerario(
  itinerarioData: itinerarioData,
);
final itinerarioId = response['id']; // ❌ response['id'] es null
```

**DESPUÉS** ✅:
```dart
final response = await BackendApiService.instance.guardarItinerario(
  itinerarioData: itinerarioData,
);

// Extraer ID del itinerario guardado
final itinerarioId = response['id'] as int?;

if (itinerarioId == null) {
  throw Exception('No se pudo obtener el ID del itinerario guardado');
}
```

**Explicación**: Valida que el `id` no sea null antes de usarlo, y lanza un error descriptivo si falla.

---

## Flujo Correcto Ahora

```
1. Usuario presiona ❤️
   ↓
2. POST /api/itinerarios
   Body: { "itinerario_data": {...} }
   ↓
3. Backend responde:
   {
     "message": "Itinerario creado exitosamente",
     "data": {
       "id": 4,  ← Extraemos este ID
       ...
     }
   }
   ↓
4. POST /api/favoritos
   Body: {
     "favoritable_type": "App\\Models\\Itinerario",
     "favoritable_id": 4
   }
   ↓
5. Backend responde:
   {
     "message": "Favorito agregado",
     "data": {...}
   }
   ↓
6. ✅ Corazón se llena, SnackBar verde
```

---

## Prueba Manual

### Paso 1: Generar Itinerario
```
1. Abre la app
2. Ve a "Itinerario Personalizado"
3. Selecciona preferencias, fecha y días
4. Presiona "GENERAR ITINERARIO"
```

### Paso 2: Guardar en Favoritos
```
5. Presiona el corazón ❤️ a la derecha del título
6. Espera el spinner rosa
```

### Paso 3: Verificar Éxito
```
✅ Corazón cambia a rosa y se llena
✅ SnackBar verde: "¡Itinerario guardado en favoritos!"
✅ Sin errores en consola
```

### Paso 4: Verificar en Backend
```bash
# Ver itinerarios guardados
curl -X GET http://localhost:8000/api/itinerarios \
  -H "Authorization: Bearer [TU_TOKEN]"

# Ver favoritos
curl -X GET http://localhost:8000/api/favoritos \
  -H "Authorization: Bearer [TU_TOKEN]"
```

**Esperado**:
- Lista de itinerarios con el nuevo
- Lista de favoritos incluyendo `favoritable_type: "App\\Models\\Itinerario"`

---

## Comparación de Endpoints

| Tipo | Endpoint Anterior | Endpoint Correcto |
|------|------------------|-------------------|
| Guardar Itinerario | ✅ `/api/itinerarios` | ✅ `/api/itinerarios` |
| Agregar a Favoritos | ❌ `/api/itinerarios/{id}/favorito` | ✅ `/api/favoritos` |

---

## Estructura de la Tabla `favoritos` (Backend)

Basado en tu código de `db_service.dart`:

```sql
CREATE TABLE favoritos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  usuarioId INTEGER NOT NULL,        -- user_id en Laravel
  lugarId INTEGER NOT NULL,          -- favoritable_id en Laravel
  tipo TEXT DEFAULT 'lugar'          -- favoritable_type en Laravel
);
```

**Ejemplo de fila guardada**:
```
id: 1
usuarioId: 1
lugarId: 4  (ID del itinerario)
tipo: 'App\Models\Itinerario'
```

---

## Resumen de Cambios

| Archivo | Método | Cambio |
|---------|--------|--------|
| `backend_api_service.dart` | `guardarItinerario()` | Extrae `id` de `data['id']` |
| `backend_api_service.dart` | `agregarItinerarioAFavoritos()` | Cambia endpoint a `/api/favoritos` |
| `recomendaciones_page.dart` | `_toggleItinerarioFavorito()` | Valida que `id` no sea null |

---

## Estado Actual

✅ **Error 1 Resuelto**: `type 'Null' is not a subtype of type 'int'`
✅ **Error 2 Resuelto**: `404 Not Found` en endpoint incorrecto
✅ **Compilación**: Sin errores
🧪 **Listo para Testing**: Puede probarse con backend real

---

**Fecha de Corrección**: 05/12/2025
**Archivos Modificados**: 2 (backend_api_service.dart, recomendaciones_page.dart)
**Estado**: ✅ LISTO
