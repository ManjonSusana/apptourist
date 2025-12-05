<?php

namespace App\Http\Controllers;

use App\Models\Lugar;
use Illuminate\Http\Request;

class LugarController extends Controller
{
    // GET /api/lugares
    public function index()
    {
        return Lugar::all();
    }

    // POST /api/lugares
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

        $lugar = Lugar::create($data);

        return response()->json($lugar, 201);
    }

    // GET /api/lugares/{id}
    public function show(Lugar $lugar)
    {
        return $lugar;
    }

    // PUT/PATCH /api/lugares/{id}
    public function update(Request $request, Lugar $lugar)
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

        $lugar->update($data);

        return response()->json($lugar);
    }

    // DELETE /api/lugares/{id}
    public function destroy(Lugar $lugar)
    {
        $lugar->delete();

        return response()->json(null, 204);
    }
}
