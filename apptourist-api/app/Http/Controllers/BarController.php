<?php

namespace App\Http\Controllers;

use App\Models\Bar;
use Illuminate\Http\Request;

class BarController extends Controller
{
    public function index()
    {
        return Bar::all();
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

        $bar = Bar::create($data);

        return response()->json($bar, 201);
    }

    public function show(Bar $bar)
    {
        return $bar;
    }

    public function update(Request $request, Bar $bar)
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

        $bar->update($data);

        return response()->json($bar);
    }

    public function destroy(Bar $bar)
    {
        $bar->delete();

        return response()->json(null, 204);
    }
}
