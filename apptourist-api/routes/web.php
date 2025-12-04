<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\LugarController;
use App\Http\Controllers\RestauranteController;
use App\Http\Controllers\BarController;
use App\Http\Controllers\FechaDestacadaController;
use App\Http\Controllers\EventoRelacionadoController;

// ✅ Ejemplo de ruta simple para probar rápidamente
Route::get('/ping', function () {
    return response()->json(['message' => 'pong desde Laravel API']);
});

// ✅ Recursos principales
Route::apiResource('lugares', LugarController::class);
Route::apiResource('restaurantes', RestauranteController::class);
Route::apiResource('bares', BarController::class);
Route::apiResource('fechas-destacadas', FechaDestacadaController::class);
Route::apiResource('eventos-relacionados', EventoRelacionadoController::class);
