<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\LugarController;
use App\Http\Controllers\RestauranteController;
use App\Http\Controllers\BarController;
use App\Http\Controllers\FechaDestacadaController;
use App\Http\Controllers\FavoritoController;
use App\Http\Controllers\ItinerarioController;

// ============================================
// Rutas públicas de autenticación
// ============================================
Route::post('/login', [AuthController::class, 'login']);

// ============================================
// Rutas protegidas por JWT
// ============================================
Route::middleware('auth:api')->group(function () {
    // Autenticación
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/refresh', [AuthController::class, 'refresh']);
    Route::get('/me', [AuthController::class, 'me']);

    // Favoritos
    Route::get('/favoritos', [FavoritoController::class, 'index']);
    Route::post('/favoritos', [FavoritoController::class, 'store']);
    Route::delete('/favoritos/{id}', [FavoritoController::class, 'destroy']);
    Route::post('/favoritos/check', [FavoritoController::class, 'check']);
    Route::get('/favoritos/tipo/{tipo}', [FavoritoController::class, 'porTipo']);

    // Itinerarios
    Route::get('/itinerarios', [ItinerarioController::class, 'index']);
    Route::post('/itinerarios', [ItinerarioController::class, 'store']);
    Route::get('/itinerarios/{id}', [ItinerarioController::class, 'show']);
    Route::put('/itinerarios/{id}', [ItinerarioController::class, 'update']);
    Route::delete('/itinerarios/{id}', [ItinerarioController::class, 'destroy']);
});

// ============================================
// Rutas públicas de recursos
// ============================================

// Lugares
Route::get('/lugares', [LugarController::class, 'index']);
Route::get('/lugares/{id}', [LugarController::class, 'show']);

// Restaurantes
Route::get('/restaurantes', [RestauranteController::class, 'index']);
Route::get('/restaurantes/{id}', [RestauranteController::class, 'show']);

// Bares
Route::get('/bares', [BarController::class, 'index']);
Route::get('/bares/{id}', [BarController::class, 'show']);

// Fechas destacadas
Route::get('/fechas', [FechaDestacadaController::class, 'index']);
Route::get('/fechas/{id}/eventos', [FechaDestacadaController::class, 'eventos']);
