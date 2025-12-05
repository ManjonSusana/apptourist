<?php

namespace App\Http\Controllers;

use App\Models\Favorito;
use Illuminate\Http\Request;

class FavoritoController extends Controller
{
    /**
     * Obtener todos los favoritos del usuario autenticado
     */
    public function index()
    {
        try {
            $user = auth()->user();
            $favoritos = $user->favoritos()->with('favoritable')->get();

            return response()->json([
                'data' => $favoritos,
                'count' => $favoritos->count()
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al obtener favoritos'], 500);
        }
    }

    /**
     * Agregar un favorito
     */
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'favoritable_type' => 'required|string|in:App\Models\Bar,App\Models\Restaurante,App\Models\Lugar,App\Models\Itinerario',
                'favoritable_id' => 'required|integer|min:1'
            ]);

            $user = auth()->user();

            // Verificar si ya existe el favorito
            $favoritoExistente = $user->favoritos()
                ->where('favoritable_type', $validated['favoritable_type'])
                ->where('favoritable_id', $validated['favoritable_id'])
                ->first();

            if ($favoritoExistente) {
                return response()->json([
                    'message' => 'Este elemento ya está en favoritos'
                ], 409);
            }

            $favorito = $user->favoritos()->create([
                'favoritable_type' => $validated['favoritable_type'],
                'favoritable_id' => $validated['favoritable_id']
            ]);

            return response()->json([
                'message' => 'Favorito agregado exitosamente',
                'data' => $favorito->load('favoritable')
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json(['errors' => $e->errors()], 422);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al agregar favorito'], 500);
        }
    }

    /**
     * Eliminar un favorito
     */
    public function destroy($id)
    {
        try {
            $user = auth()->user();
            $favorito = $user->favoritos()->findOrFail($id);
            $favorito->delete();

            return response()->json([
                'message' => 'Favorito eliminado exitosamente'
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json(['message' => 'Favorito no encontrado'], 404);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al eliminar favorito'], 500);
        }
    }

    /**
     * Verificar si un elemento es favorito
     */
    public function check(Request $request)
    {
        try {
            $validated = $request->validate([
                'favoritable_type' => 'required|string|in:App\Models\Bar,App\Models\Restaurante,App\Models\Lugar',
                'favoritable_id' => 'required|integer|min:1'
            ]);

            $user = auth()->user();
            $esFavorito = $user->favoritos()
                ->where('favoritable_type', $validated['favoritable_type'])
                ->where('favoritable_id', $validated['favoritable_id'])
                ->exists();

            return response()->json([
                'is_favorite' => $esFavorito
            ], 200);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json(['errors' => $e->errors()], 422);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al verificar favorito'], 500);
        }
    }

    /**
     * Obtener todos los favoritos de un tipo específico
     */
    public function porTipo($tipo)
    {
        try {
            // Validar que el tipo sea válido
            $tiposValidos = ['Bar', 'Restaurante', 'Lugar', 'Itinerario'];

            if (!in_array($tipo, $tiposValidos)) {
                return response()->json([
                    'message' => "Tipo inválido. Tipos válidos: " . implode(', ', $tiposValidos)
                ], 422);
            }

            $user = auth()->user();
            $tipoCompleto = "App\\Models\\{$tipo}";

            $favoritos = $user->favoritos()
                ->where('favoritable_type', $tipoCompleto)
                ->with('favoritable')
                ->get();

            return response()->json([
                'tipo' => $tipo,
                'data' => $favoritos,
                'count' => $favoritos->count()
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al obtener favoritos por tipo'], 500);
        }
    }
}
