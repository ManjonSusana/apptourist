<?php

namespace App\Http\Controllers;

use App\Models\Itinerario;
use Illuminate\Http\Request;

class ItinerarioController extends Controller
{
    /**
     * Obtener todos los itinerarios del usuario autenticado
     */
    public function index()
    {
        try {
            $user = auth()->user();
            $itinerarios = $user->itinerarios()->get();

            return response()->json([
                'data' => $itinerarios,
                'count' => $itinerarios->count()
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al obtener itinerarios'], 500);
        }
    }

    /**
     * Crear un nuevo itinerario
     */
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'itinerario_data' => 'required|array',
            ]);

            $user = auth()->user();

            $itinerario = $user->itinerarios()->create([
                'itinerario_data' => $validated['itinerario_data']
            ]);

            return response()->json([
                'message' => 'Itinerario creado exitosamente',
                'data' => $itinerario
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json(['errors' => $e->errors()], 422);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al crear itinerario'], 500);
        }
    }

    /**
     * Obtener un itinerario específico
     */
    public function show($id)
    {
        try {
            $user = auth()->user();
            $itinerario = $user->itinerarios()->findOrFail($id);

            return response()->json([
                'data' => $itinerario
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json(['message' => 'Itinerario no encontrado'], 404);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al obtener itinerario'], 500);
        }
    }

    /**
     * Actualizar un itinerario
     */
    public function update(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'itinerario_data' => 'sometimes|required|array',
            ]);

            $user = auth()->user();
            $itinerario = $user->itinerarios()->findOrFail($id);

            $itinerario->update($validated);

            return response()->json([
                'message' => 'Itinerario actualizado exitosamente',
                'data' => $itinerario
            ], 200);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json(['errors' => $e->errors()], 422);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json(['message' => 'Itinerario no encontrado'], 404);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al actualizar itinerario'], 500);
        }
    }

    /**
     * Eliminar un itinerario
     */
    public function destroy($id)
    {
        try {
            $user = auth()->user();
            $itinerario = $user->itinerarios()->findOrFail($id);
            $itinerario->delete();

            return response()->json([
                'message' => 'Itinerario eliminado exitosamente'
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json(['message' => 'Itinerario no encontrado'], 404);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error al eliminar itinerario'], 500);
        }
    }
}
