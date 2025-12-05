<?php

namespace App\Http\Controllers;

use App\Models\Restaurante;
use Illuminate\Http\Request;

class RestauranteController extends Controller
{
    public function index()
    {
        return Restaurante::all();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nombre'      => 'required|string|max:255',
            'direccion'   => 'required|string|max:255',
            'categoria'   => 'required|string|max:100',
            'descripcion' => 'nullable|string',
            'imagenAsset' => 'nullable|string|max:255',
            'rating'      => 'nullable|numeric|min:0|max:5',
            'imagenes'    => 'nullable|array',
        ]);

        $rest = Restaurante::create($data);

        return response()->json($rest, 201);
    }

    public function show(Restaurante $restaurante)
    {
        return $restaurante;
    }

    public function update(Request $request, Restaurante $restaurante)
    {
        $data = $request->validate([
            'nombre'      => 'sometimes|required|string|max:255',
            'direccion'   => 'sometimes|required|string|max:255',
            'categoria'   => 'sometimes|required|string|max:100',
            'descripcion' => 'nullable|string',
            'imagenAsset' => 'nullable|string|max:255',
            'rating'      => 'nullable|numeric|min:0|max:5',
            'imagenes'    => 'nullable|array',
        ]);

        $restaurante->update($data);

        return response()->json($restaurante);
    }

    public function destroy(Restaurante $restaurante)
    {
        $restaurante->delete();

        return response()->json(null, 204);
    }
}
