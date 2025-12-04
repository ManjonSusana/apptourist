<?php

namespace App\Http\Controllers;

use App\Models\FechaDestacada;
use Illuminate\Http\Request;

class FechaDestacadaController extends Controller
{
    public function index()
    {
        // Traer fechas con sus eventos relacionados
        return FechaDestacada::with('eventos')->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'titulo'      => 'required|string|max:255',
            'descripcion' => 'nullable|string',
            'icono'       => 'nullable|string|max:10',
            'categoria'   => 'required|string|max:100',
            'fechaInicio' => 'required|date',
            'fechaFin'    => 'nullable|date',
            'permanente'  => 'boolean',
            'imagenAsset' => 'nullable|string|max:255',
        ]);

        $fecha = FechaDestacada::create($data);

        return response()->json($fecha, 201);
    }

    public function show(FechaDestacada $fechaDestacada)
    {
        return $fechaDestacada->load('eventos');
    }

    public function update(Request $request, FechaDestacada $fechaDestacada)
    {
        $data = $request->validate([
            'titulo'      => 'sometimes|required|string|max:255',
            'descripcion' => 'nullable|string',
            'icono'       => 'nullable|string|max:10',
            'categoria'   => 'sometimes|required|string|max:100',
            'fechaInicio' => 'sometimes|required|date',
            'fechaFin'    => 'nullable|date',
            'permanente'  => 'boolean',
            'imagenAsset' => 'nullable|string|max:255',
        ]);

        $fechaDestacada->update($data);

        return response()->json($fechaDestacada->load('eventos'));
    }

    public function destroy(FechaDestacada $fechaDestacada)
    {
        $fechaDestacada->delete();

        return response()->json(null, 204);
    }
}
