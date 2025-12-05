# 📱 Vista Previa: UI del Botón de Favoritos

## Pantalla Completa

```
┌─────────────────────────────────────────┐
│ ← Itinerario Personalizado              │  ← AppBar
├─────────────────────────────────────────┤
│                                         │
│ 1. Selecciona tus intereses principales:
│ [Histórico] [Cultural] [Gastronomía] [] │
│                                         │
│ 2. ¿Cuándo inicias tu viaje?           │
│ 📅 20/12/2024                           │
│                                         │
│ 3. Ingresa la duración de tu estadía:  │
│ [Ingresa días: ] 3                      │
│                                         │
│      [ GENERAR ITINERARIO ]             │
│                                         │
│ 4. Tu Plan de Viaje por Día:      ❤️   │  ← NUEVO: Botón aquí
│ 📅 Día 1 (20/12)                        │
│ ☀️ 08:00 - Desayuno en restaurante     │
│ 📍 10:00 - Visita Iglesia de San Felipe │
│ 🍽️ 12:30 - Almuerzo tradicional       │
│                                         │
│ 📅 Día 2 (21/12)                        │
│ ☀️ 08:00 - Tour histórico               │
│ 📍 14:00 - Mercado artesanal            │
│ 🌙 19:00 - Cena con vistas              │
│                                         │
│ 📅 Día 3 (22/12)                        │
│ 🏞️ 07:00 - Naturaleza                  │
│ ⛰️  13:00 - Senderismo                 │
│ 🌅 17:00 - Mirador                     │
│                                         │
└─────────────────────────────────────────┘
```

## Estados del Botón

### 1️⃣ **Estado Inicial** (No hay favorito)
```
┌───────────────────────────────────────────┐
│ 4. Tu Plan de Viaje por Día:        🤍   │
│                                           │
│    (Corazón VACÍO, color gris)           │
│    Al pasar el mouse: Tooltip says        │
│    "Guardar en favoritos"                │
└───────────────────────────────────────────┘
```

### 2️⃣ **Estado Cargando** (Procesando)
```
┌───────────────────────────────────────────┐
│ 4. Tu Plan de Viaje por Día:        ⟳    │
│                                           │
│    (Indicador circular girando)           │
│    Color: Rosa/Pink                       │
│    El botón está DESHABILITADO            │
└───────────────────────────────────────────┘
```

### 3️⃣ **Estado Favorito** (Guardado)
```
┌───────────────────────────────────────────┐
│ 4. Tu Plan de Viaje por Día:        ❤️   │
│                                           │
│    (Corazón LLENO, color rosa)           │
│    Al pasar el mouse: Tooltip says        │
│    "Guardado en favoritos"               │
└───────────────────────────────────────────┘
```

## Eventos y Interacciones

### Escenario 1: Usuario Presiona el Botón (Inicial)
```
ANTES:
┌─────────────────────────────┐
│ 4. Tu Plan de Viaje..  🤍   │
└─────────────────────────────┘

USUARIO PRESIONA ↓

DURANTE (1-3 segundos):
┌─────────────────────────────┐
│ 4. Tu Plan de Viaje..  ⟳    │  ← Spinner girando
└─────────────────────────────┘

BACKEND RESPONDE ✅:
┌─────────────────────────────┐
│ 4. Tu Plan de Viaje..  ❤️   │  ← Corazón lleno
└─────────────────────────────┘

NOTIFICACIÓN (SnackBar):
┌─────────────────────────────┐
│ ✓ ¡Itinerario guardado      │
│   en favoritos!             │  ← Verde, abajo
└─────────────────────────────┘
```

### Escenario 2: Error en el Guardado
```
USUARIO PRESIONA ↓

DURANTE:
┌─────────────────────────────┐
│ 4. Tu Plan de Viaje..  ⟳    │
└─────────────────────────────┘

BACKEND FALLA ❌:
┌─────────────────────────────┐
│ 4. Tu Plan de Viaje..  🤍   │  ← Vuelve al estado inicial
└─────────────────────────────┘

NOTIFICACIÓN (SnackBar):
┌─────────────────────────────┐
│ ✗ Error al guardar:         │
│   [Detalle del error]       │  ← Rojo, abajo
└─────────────────────────────┘
```

### Escenario 3: Usuario Presiona sin Generar Itinerario
```
USUARIO NO HA GENERADO ITINERARIO

NOTIFICACIÓN INMEDIATA (SnackBar):
┌─────────────────────────────┐
│ ⚠ Por favor, genera un      │
│   itinerario primero.       │  ← Naranja, abajo
└─────────────────────────────┘

BOTÓN NO APARECE:
(Row con el botón está dentro de: if (_itinerario.isNotEmpty))
```

## Dimensiones del Botón

```
IconButton (Default)
├─ Icon: 28x28 dp
├─ Tappable Area: 48x48 dp (Material spec)
├─ Padding: 12 dp
└─ Tooltip: Aparece al mantener presionado

CircularProgressIndicator (Loading)
├─ Size: 24x24 dp
├─ Stroke Width: 2 dp
└─ Color: Colors.pinkAccent
```

## Código Widget Principal

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Título (lado izquierdo)
    Text(
      '4. Tu Plan de Viaje por Día:',
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    // Botón de corazón (lado derecho)
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

## Colores Utilizados

| Elemento | Color | Código |
|----------|-------|--------|
| Corazón Vacío | Gris | `Colors.grey` |
| Corazón Lleno | Rosa/Pink | `Colors.pinkAccent` |
| Loader | Rosa/Pink | `Colors.pinkAccent` |
| Fondo Éxito | Verde | `Colors.green` |
| Fondo Error | Rojo | `Colors.redAccent` |
| Fondo Advertencia | Naranja | `Colors.orange` |

## Animaciones

### Cambio de Corazón
```
🤍 (gris, vacío)
  ↓
⟳ (loader rosa, girando)
  ↓ (después 1-3 segundos)
❤️ (rosa, lleno)
```

- **Duration**: Depende de la latencia de red
- **Curve**: Automático (CircularProgressIndicator)
- **Feedback**: Visual + Toast notification

## Responsive Design

- **Pantalla Pequeña (< 400w)**: Botón se acomoda con `mainAxisAlignment.spaceBetween`
- **Pantalla Grande (> 600w)**: Mismo comportamiento, más espacio blanco
- **Orientación**: Funciona en Portrait y Landscape

## Accesibilidad

- ✅ **Tooltip**: Mensajes descriptivos para usuarios
- ✅ **Icon Contrast**: Colores con suficiente contraste (gris/rosa)
- ✅ **Tap Target**: 48x48 dp (material spec mínimo)
- ✅ **Semantic**: IconButton proporciona semántica correcta

## Estados Posibles del Widget

```
┌─────────────────────────────────────────┐
│ if (_itinerario.isEmpty)                │
│   → Row no se renderiza (no aparece)    │
│   → Solo se ve el título sin botón      │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ if (_itinerario.isNotEmpty) &&          │
│    _cargandoFavorito == true            │
│   → Aparece Row con CircularProgressBar │
│   → Botón está "ocupado"                │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ if (_itinerario.isNotEmpty) &&          │
│    _cargandoFavorito == false           │
│   → Aparece Row con IconButton          │
│   → Icon cambia según _esItinerario     │
│     Favorito (true = lleno / false = v) │
└─────────────────────────────────────────┘
```

## Flujo de Datos

```
User presses heart button
        ↓
_toggleItinerarioFavorito() called
        ↓
setState(() => _cargandoFavorito = true)
        ↓
Convert _itinerario Map → JSON
        ↓
API Call 1: guardarItinerario()
        ↓
        └→ Returns { id: 123, user_id: 5, ... }
        ↓
API Call 2: agregarItinerarioAFavoritos(123)
        ↓
setState(() {
  _esItinerarioFavorito = true
  _cargandoFavorito = false
})
        ↓
showSnackBar("¡Itinerario guardado en favoritos!")
```

---

**Resultado Final**: Un botón elegante que permite a los usuarios guardar sus itinerarios con un solo clic, mostrando feedback visual en cada paso del proceso. ✨
