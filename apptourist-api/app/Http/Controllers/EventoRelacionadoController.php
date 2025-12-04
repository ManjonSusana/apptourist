<?php

namespace App\Http\Controllers;

use App\Models\EventoRelacionado;
use Illuminate\Http\Request;

class EventoRelacionadoController extends Controller
{
    public function index()
    {
        return EventoRelacionado::with('hito')->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'hitoId'         => 'required|integer|exists:fechas_destacadas,id',
            'titulo'         => 'required|string|max:255',
            'descripcion'    => 'nullable|string',
            'ubicacion'      => 'required|string|max:255',
            'fechaHoraInicio'=> 'required|date_format:Y-m-d H:i:s',
        ]);

        $evento = EventoRelacionado::create($data);

        return response()->json($evento, 201);
    }

    public function show(EventoRelacionado $eventoRelacionado)
    {
        return $eventoRelacionado->load('hito');
    }

    public function update(Request $request, EventoRelacionado $eventoRelacionado)
    {
        $data = $request->validate([
            'hitoId'         => 'sometimes|required|integer|exists:fechas_destacadas,id',
            'titulo'         => 'sometimes|required|string|max:255',
            'descripcion'    => 'nullable|string',
            'ubicacion'      => 'sometimes|required|string|max:255',
            'fechaHoraInicio'=> 'sometimes|required|date_format:Y-m-d H:i:s',
        ]);

        $eventoRelacionado->update($data);

        return response()->json($eventoRelacionado->load('hito'));
    }

    public function destroy(EventoRelacionado $eventoRelacionado)
    {
        $eventoRelacionado->delete();

        return response()->json(null, 204);
    }
}
