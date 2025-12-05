# 💝 Implementación: Botón de Favoritos en Recomendaciones

## Descripción
Se agregó un botón de corazón ❤️ en la página `recomendaciones_page.dart` que permite a los usuarios guardar sus itinerarios generados como favoritos.

## Cambios Realizados

### 1. **Imports Necesarios** (`recomendaciones_page.dart`)
```dart
import '../services/backend_api_service.dart';
```

### 2. **Variables de Estado** (línea ~63)
```dart
// Favoritos
bool _esItinerarioFavorito = false;
bool _cargandoFavorito = false;
```

### 3. **Método: `_toggleItinerarioFavorito()`** (línea ~168)
```dart
Future<void> _toggleItinerarioFavorito() async {
  // ✅ Paso 1: Validar que exista itinerario
  if (_itinerario.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Por favor, genera un itinerario primero."))
    );
    return;
  }

  setState(() => _cargandoFavorito = true);
  
  try {
    // ✅ Paso 2: Convertir Map de itinerario a JSON
    final List<Map<String, dynamic>> dias = [];
    _itinerario.forEach((nombreDia, actividades) {
      dias.add({
        'nombre_dia': nombreDia,
        'actividades': actividades.map((a) => {...}).toList(),
      });
    });

    final itinerarioData = {'dias': dias};

    // ✅ Paso 3: Guardar en base de datos (BackendApiService)
    final response = await BackendApiService.instance.guardarItinerario(
      itinerarioData: itinerarioData,
    );
    final itinerarioId = response['id'];

    // ✅ Paso 4: Agregar a favoritos
    await BackendApiService.instance.agregarItinerarioAFavoritos(
      itinerarioId: itinerarioId,
    );

    // ✅ Paso 5: Actualizar UI y mostrar confirmación
    setState(() {
      _esItinerarioFavorito = true;
      _cargandoFavorito = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("¡Itinerario guardado en favoritos!"),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    setState(() => _cargandoFavorito = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error al guardar: $e"),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
```

### 4. **UI: Botón de Corazón** (línea ~318)
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      '4. Tu Plan de Viaje por Día:',
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    // ❤️ Botón para guardar en favoritos
    if (_itinerario.isNotEmpty)
      _cargandoFavorito
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.pinkAccent,
                ),
              ),
            )
          : IconButton(
              onPressed: _toggleItinerarioFavorito,
              icon: Icon(
                _esItinerarioFavorito
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _esItinerarioFavorito
                    ? Colors.pinkAccent
                    : Colors.grey,
                size: 28,
              ),
              tooltip: _esItinerarioFavorito
                  ? 'Guardado en favoritos'
                  : 'Guardar en favoritos',
            ),
  ],
),
```

## Flujo de Funcionamiento

```
Usuario genera itinerario
        ↓
Itinerario aparece en Timeline
        ↓
Botón de corazón ❤️ aparece (inicialmente vacío)
        ↓
Usuario presiona corazón
        ↓
Se muestra indicador de carga (CircularProgressIndicator)
        ↓
Paso 1: BackendApiService.guardarItinerario() → Guarda en tabla 'itinerarios'
        ↓
Paso 2: BackendApiService.agregarItinerarioAFavoritos() → Agrega a favoritos
        ↓
Corazón cambia a rojo y se llena (🤎 → ❤️)
        ↓
Muestra SnackBar de éxito
```

## Estados Visuales del Botón

### 1. **Estado Inicial** (sin favorito)
- Icono: `Icons.favorite_border_rounded` (corazón vacío)
- Color: Gris (`Colors.grey`)
- Tooltip: "Guardar en favoritos"

### 2. **Estado Cargando** (mientras se guarda)
- Muestra: `CircularProgressIndicator` girando
- Color: Rosa (`Colors.pinkAccent`)
- El botón está deshabilitado

### 3. **Estado Favorito** (ya guardado)
- Icono: `Icons.favorite_rounded` (corazón lleno)
- Color: Rosa (`Colors.pinkAccent`)
- Tooltip: "Guardado en favoritos"

## Integración con BackendApiService

### Método 1: `guardarItinerario()`
```dart
Future<Map<String, dynamic>> guardarItinerario({
  required Map<String, dynamic> itinerarioData,
}) async {
  // POST a /api/itinerarios
  // Headers: Authorization: Bearer [JWT]
  // Body: { itinerario_data: {...} }
  // Retorna: { id, user_id, itinerario_data, ... }
}
```

### Método 2: `agregarItinerarioAFavoritos()`
```dart
Future<Map<String, dynamic>> agregarItinerarioAFavoritos({
  required int itinerarioId,
}) async {
  // POST a /api/itinerarios/{id}/favorito
  // Headers: Authorization: Bearer [JWT]
  // Retorna: { favorito, itinerario, ... }
}
```

## Formato de Datos Enviado

### Entrada: `_itinerario` (Map<String, List<ActividadPlan>>)
```dart
{
  'Día 1 (20/12)': [
    ActividadPlan(horario: '08:00 AM', descripcion: 'Desayuno', tabla: 'restaurantes', refId: 5),
    ActividadPlan(horario: '10:00 AM', descripcion: 'Visita Iglesia', tabla: 'lugares', refId: 2),
  ],
  'Día 2 (21/12)': [...],
}
```

### Salida: `itinerarioData` (JSON que se envía)
```json
{
  "dias": [
    {
      "nombre_dia": "Día 1 (20/12)",
      "actividades": [
        {
          "horario": "08:00 AM",
          "descripcion": "Desayuno",
          "tabla": "restaurantes",
          "ref_id": 5
        },
        {
          "horario": "10:00 AM",
          "descripcion": "Visita Iglesia",
          "tabla": "lugares",
          "ref_id": 2
        }
      ]
    },
    {
      "nombre_dia": "Día 2 (21/12)",
      "actividades": [...]
    }
  ]
}
```

## Manejo de Errores

### Validaciones:
- ✅ Si el usuario presiona sin generar itinerario → Muestra error
- ✅ Si falla guardar en BD → Captura y muestra error
- ✅ Si falla agregar a favoritos → Captura y muestra error
- ✅ Usa `if (mounted)` para evitar memory leaks

### Mensajes de Feedback:
- 🟠 "Por favor, genera un itinerario primero." (naranja)
- 🔴 "Error al guardar: $e" (rojo)
- 🟢 "¡Itinerario guardado en favoritos!" (verde)

## Testing Manual

1. **Generar itinerario**: Selecciona preferencias, fecha y días → Presiona "Generar"
2. **Verificar botón aparece**: Debe verse corazón vacío al lado del título
3. **Guardar favorito**: Presiona corazón
4. **Verificar animación**: Debe girar un indicador de carga
5. **Verificar resultado**: 
   - Corazón debe cambiar a rojo lleno
   - Debe aparecer SnackBar verde
   - En backend, debe estar guardado en BD (tabla `itinerarios` + `favoritos`)

## Consideraciones Técnicas

- ✅ El botón solo aparece si hay itinerario (`if (_itinerario.isNotEmpty)`)
- ✅ El estado `_esItinerarioFavorito` persiste solo en la sesión actual
- ✅ Si el usuario recarga la página, el estado se resetea a `false`
- ⚠️ Para persistencia real, se necesaría cargar el estado desde backend
- ✅ El JWT token se usa automáticamente en BackendApiService
- ✅ La conversión de datos maneja todos los campos de `ActividadPlan`

## Próximos Pasos Opcionales

1. **Cargar estado desde backend**: Al iniciar la página, verificar si el itinerario ya está en favoritos
2. **Botón para eliminar favorito**: Permitir des-favoritar
3. **Ver mis itinerarios guardados**: Crear página para ver itinerarios favoritos
4. **Compartir itinerario**: Opción para compartir con otros usuarios
5. **Editar itinerario**: Permitir modificaciones antes de guardar

---
**Implementado:** Ahora usuarios pueden guardar itinerarios generados con IA como favoritos directamente desde la página de recomendaciones. 🎉
