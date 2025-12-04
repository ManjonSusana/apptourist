<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Models\Lugar;
use App\Models\Restaurante;
use App\Models\Bar;
use App\Models\FechaDestacada;
use App\Models\EventoRelacionado;

Route::get('/lugares', function () {
    return Lugar::all();
});

Route::get('/lugares/{id}', function ($id) {
    return Lugar::findOrFail($id);
});

Route::get('/restaurantes', function () {
    return Restaurante::all();
});

Route::get('/restaurantes/{id}', function ($id) {
    return Restaurante::findOrFail($id);
});

Route::get('/bares', function () {
    return Bar::all();
});

Route::get('/bares/{id}', function ($id) {
    return Bar::findOrFail($id);
});

Route::get('/fechas', function () {
    return FechaDestacada::all();
});

Route::get('/fechas/{id}/eventos', function ($id) {
    return EventoRelacionado::where('hitoId', $id)->get();
});
